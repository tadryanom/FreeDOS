/* $Id: resfile.c 257 2001-07-05 22:18:35Z skaus $

	Return the name of the resource file

*/

#include "../config.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include <dfn.h>

#include "../include/command.h"
#include "../include/misc.h"

char *comResFile(void)
{  if(isSwapFile) {
       static char *p = 0;

       myfree(p);
       if((p = strdup(comFile())) != 0) {
           assert(strlen(p) == isSwapFile + 3);
           memcpy(p + isSwapFile, "SWP", 3);
           if(exist(p))
			   return p;
       }
   }

   return comFile();
}
