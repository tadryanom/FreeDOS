/*	$id$
	$Locker$	$Name$	$State$

	msgSegment() - return the segment of memory the STRINGS have been
		loaded to; if they are not present in memory, they are loaded
		from the resources
	unloadMsgs() - deallocate the loaded STRINGS segment

	This file bases on MESSAGES.C of FreeCOM v0.81 beta 1.

	$Log$
	Revision 1.1  2001/04/12 00:33:53  skaus
	chg: new structure
	chg: If DEBUG enabled, no available commands are displayed on startup
	fix: PTCHSIZE also patches min extra size to force to have this amount
	   of memory available on start
	bugfix: CALL doesn't reset options
	add: PTCHSIZE to patch heap size
	add: VSPAWN, /SWAP switch, .SWP resource handling
	bugfix: COMMAND.COM A:\
	bugfix: CALL: if swapOnExec == ERROR, no change of swapOnExec allowed
	add: command MEMORY
	bugfix: runExtension(): destroys command[-2]
	add: clean.bat
	add: localized CRITER strings
	chg: use LNG files for hard-coded strings (hangForEver(), init.c)
		via STRINGS.LIB
	add: DEL.C, COPY.C, CBREAK.C: STRINGS-based prompts
	add: fixstrs.c: prompts & symbolic keys
	add: fixstrs.c: backslash escape sequences
	add: version IDs to DEFAULT.LNG and validation to FIXSTRS.C
	chg: splitted code apart into LIB\*.c and CMD\*.c
	bugfix: IF is now using error system & STRINGS to report errors
	add: CALL: /N

 */

#include "../config.h"

#include <assert.h>
#include <dos.h>
#include <stdio.h>
#include <string.h>

#include <suppl.h>

#include "../include/misc.h"
#include "../include/resource.h"
#include "../include/res.h"
#include "../strings.h"
#include "../include/strings.typ"

typedef enum {
	  STRINGS_LOADED
	, STRINGS_ID_MISMATCH
	, STRINGS_SIZE_MISMATCH
	, STRINGS_NOT_FOUND
	, STRINGS_READ_ERROR
	, STRINGS_OUT_OF_MEMORY
} loadStatus;

unsigned msgSegm = 0;    /* strings segment if loaded */
string_count_t strCnt = 0;		/* number of strings */

/* Remove the string segment from memory */
void unloadMsgs(void) 
{
  if (msgSegm) {
    freeBlk(msgSegm);
    dprintf( ("[Message segment 0x%04x deallocated.]\n", msgSegm) );
  }
  msgSegm = 0;
}

/* Number of bytes of preceeding the index array:
	ID string
	+ trailer (\r\n\x1a\0)
	+ count of entries
	+ size of data portion
*/
#define STRINGS_HEADER_SIZE sizeof(STRINGS_ID) + STRINGS_ID_TRAILER	\
	+ sizeof(string_size_t) + sizeof(string_count_t) - 1

/* Callback function for enumResources() */
/* Called if the resource locator found a resource with a matching
	major ID --> we ignore all the rest of IDs and probe for the
	validation string at the beginning of the resource data */
#pragma argsused
static int loadStrings(res_majorid_t major
	, res_minorid_t minor
	, long length
	, FILE* f
	, void * const arg)
{	loadStatus *ls = arg;
	char fdid[sizeof(STRINGS_ID)];
	string_size_t len, firstStr;
	string_index_t far*idx;
	int i;

	if((unsigned long)length >= 0x10000ul
	 || (unsigned)length < STRINGS_HEADER_SIZE) {
		*ls = STRINGS_SIZE_MISMATCH;
		return 0;
	}

	fread(fdid, sizeof(STRINGS_ID) - 1, 1, f);

	if (memcmp(fdid, STRINGS_ID, sizeof(STRINGS_ID) - 1)) {
		*ls = STRINGS_ID_MISMATCH;
		return 0;			/* Continue searching */
	}
	/* immediately after the ID a trailer follows */
	fseek(f, (long)STRINGS_ID_TRAILER, 1);

		/* Read the strings dimensionating parameters */
	if(ferror(f)
	 || fread(&strCnt, sizeof(strCnt), 1, f) != 1
	 || fread(&len, sizeof(len), 1, f) != 1) { /* Read error */
	 	*ls = STRINGS_READ_ERROR;
	 	return 0;			/* Continue searching */
	}
	/* At this point f is positioned at the very first string index
	 the data area is NUMBER_OF_STRINGS * sizeof(index) +
	 SIZE_OF_STRINGS   */
	len += firstStr = strCnt * sizeof(string_index_t);
	if((unsigned)length - STRINGS_HEADER_SIZE < len) {
		*ls = STRINGS_SIZE_MISMATCH;
		return 0;
	}
		/* allocation mode: last fit, high first */
	if ((msgSegm = allocBlk(len, 0x82)) == 0) {
		*ls = STRINGS_OUT_OF_MEMORY;
		return 0;
	}

	if(farread(MK_FP(msgSegm, 0), len, f) != len) {
		unloadMsgs();			/* Remove the message segment */
		*ls = STRINGS_READ_ERROR;
		return 0;
	}

	/* Now the offset of the index array are updated to point to the
		real offset instead of the displacement based on the first
		byte of the string data area */
	idx = MK_FP(msgSegm, 0);
	for(i = 0; i < strCnt; ++i)
		idx[i].index += firstStr;

	*ls = STRINGS_LOADED;
	return 1;		/* Stop searching */
}

/*
 *  If the messages are NOT loaded and if there is an error during
 *  the load, the automatic load process might hang here infinitely.
 */
unsigned msgSegment(void)              /* load messages into memory */
{	static int recurs = 1;
	loadStatus status = STRINGS_NOT_FOUND;
#ifndef DEBUG		/* To ensure the error is displayed only once */
	static int displayed = 0;
#endif

	if(!msgSegm) {     /* not loaded, yet */
		/* prevent reentrance */
		if(--recurs == 0) {		/* OK */
			enumResources(RES_ID_STRINGS, loadStrings, &status);
			switch(status) {
			case STRINGS_LOADED:
			  assert(msgSegm);
			  dprintf(("[Messages successfully loaded to segment 0x%04x]\n"
			   , msgSegm));
			   break;
#ifdef DEBUG
			/* Don't use dprintf() to ensure the message is issued, even
				if fddebug is OFF */
			case STRINGS_NOT_FOUND:
				assert(msgSegm == 0);
				dbg_outsn("[No STRINGS resource found!]");
				break;
			case STRINGS_ID_MISMATCH:
				assert(msgSegm == 0);
				dbg_outsn("[STRINGS ID string mismatch.]");
				break;
			case STRINGS_READ_ERROR:
				assert(msgSegm == 0);
				dbg_outsn("[Read error while loading STRINGS.]");
				break;
			case STRINGS_SIZE_MISMATCH:
				assert(msgSegm == 0);
				dbg_outsn("[STRINGS resource has invalid size.]");
				break;
			case STRINGS_OUT_OF_MEMORY:
				assert(msgSegm == 0);
				dbg_outsn("[Out of memory loading STRINGS.]");
				break;
			default:
				assert(msgSegm == 0);
				dbg_outsn("[Unknown error loading STRINGS.]");
				break;
#else	/* Even in non-debugging, an error should
								be displayed */
			case STRINGS_OUT_OF_MEMORY:
				assert(msgSegm == 0);
				puts("[Out of memory loading STRINGS.]");
				break;
			default:	
				assert(msgSegm == 0);
				if(!displayed) {
					displayed = 1;
					puts("\n\a[Could not load STRINGS resource.]");
				}
				break;
#endif
			}
		}

		++recurs;
	}

	return msgSegm;
}
