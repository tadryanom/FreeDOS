/*	$id$
	$Locker$	$Name$	$State$

 *  Perform an option check and parse value for boolean

	This file bases on CMDLINE.C of FreeCOM v0.81 beta 1.

	$Log$
	Revision 1.1.4.2  2001/07/30 00:45:17  skaus
	Update #13 / Beta 27: plain dynamic context

	Revision 1.1.4.1  2001/07/02 21:04:07  skaus
	Update #4
	
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
#include <process.h>
#include <stdio.h>

#include "../include/command.h"
#include "../include/cmdline.h"
#include "../err_fcts.h"

int optScanBoolB_(const char * const optstr, int bool, const char *arg, FLAG far *value)
{
  assert(optstr);
  assert(value);

  if(arg) {
    error_opt_arg(optstr);
    return E_Useage;
  }
  switch(bool) {
  case -1:  *value = 0; break;
  case 0:   *value = !*value; break;
  case 1:   *value = 1; break;
#ifndef NDEBUG
  default:  fprintf(stderr, "Invalid boolean option value: in file %s line %u\n", __FILE__, __LINE__);
    abort();
#endif
  }
  return 0;
}
