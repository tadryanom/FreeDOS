/* $Id: ctxt_vw.c 283 2001-08-21 18:21:21Z skaus $

	View all entries of the specified type

*/

#include "../config.h"

#include <assert.h>
#include <stdio.h>

#include <environ.h>

#include "../include/context.h"
#include "../include/misc.h"
#include "../strings.h"

typedef struct {
	unsigned char tag;
	unsigned count;
} view_t;

/* Because new items are appended to the context, the items
	are automatically sorted ascending */
#pragma argsused
static int view(void *arg, word segm, word ofs)
{

	assert(segm);

	if(ctxtProbeItemTag(ctxtP(segm, ofs), ((view_t*)arg)->tag)) {
		++((view_t*)arg)->count;
		fprintf(outStream, "%s\n", ctxtP(segm, ofs + 1));
	}
	return 0;                     /* don't stop */
}


int ctxtView(const Context_Tag tag, const unsigned empty)
{
	int rc;
	view_t param;

	assert(ctxtFromTag(tag) != CTXT_INVALID);

	param.tag = (unsigned char)tag;
	param.count = 0;

		/* return value == 0 --> OK */
	if((rc = env_forAll(ctxtFromTag(tag), view, (void*)&param)) == 0) {
		if(param.count)
			displayString(TEXT_MSG_ITEMS_DISPLAYED, param.count);
		else	displayString(empty);
	}

	return rc;
}
