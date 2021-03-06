/*	$id$
	$Locker$	$Name$	$State$

	Returns the number of a drive (0..31)
	0 -> current drive
	1..32 -> input - 1
	else -> input - 'A'

	This file bases on MISC.C of FreeCOM v0.81 beta 1.

	$Log$
	Revision 1.1.4.1  2001/08/21 18:18:16  skaus
	Update #14 / Beta 29: Direct access to dynamic context

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
#include <ctype.h>
#include <dir.h>

#include "../include/misc.h"

int drvNum(int drive)
{
	if(drive == 0)		/* current drive */
		return getdisk();
	if(drive <= 32)		/* numerical drive */
		return drive - 1;
	return toupper(drive) - 'A';
}
