/*
	*** Image command functions
	*** src/command/image.cpp
	Copyright T. Youngs 2007,2008

	This file is part of Aten.

	Aten is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	Aten is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Aten.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "command/commandlist.h"
#include "base/debug.h"
#include "base/master.h"
#include "gui/gui.h"
#include "gui/mainwindow.h"
#include "classes/grid.h"

// Save current view as bitmap image
int CommandData::function_CA_SAVEBITMAP(Command *&c, Bundle &obj)
{
	if (obj.notifyNull(BP_MODEL)) return CR_FAIL;
	// Flag any surfaces to be rerendered for use in this context
	for (Grid *g = master.grids(); g != NULL; g = g->next) g->requestRerender();
	// Create a QPixmap of the current scene
	QPixmap pixmap;
	if (gui.exists()) pixmap = gui.mainWindow->ui.ModelView->renderPixmap(0,0,FALSE);
	// Flag any surfaces to be rerendered so they are redisplayed in the original context
	for (Grid *g = master.grids(); g != NULL; g = g->next) g->requestRerender();

	// Convert format to bitmap_format
	bitmap_format bf = BIF_from_text(c->argc(0));
	if (bf != BIF_NITEMS)
	{
		pixmap.save(c->argc(1), extension_from_BIF(bf), -1);
		msg(Debug::None,"Saved current view as '%s'\n",c->argc(1));
	}
	else
	{
		msg(Debug::None,"Unrecognised bitmap format.\n");
		return CR_FAIL;
	}
	return CR_SUCCESS;
}

// Save current view a vector graphic
int CommandData::function_CA_SAVEVECTOR(Command *&c, Bundle &obj)
{
	if (obj.notifyNull(BP_MODEL)) return CR_FAIL;
	vector_format vf = VIF_from_text(c->argc(0));
	if (vf == VIF_NITEMS)
	{
		msg(Debug::None,"Unrecognised vector format '%s'.\n",c->argc(0));
		return CR_FAIL;
	}
	// If gui exists, use the main canvas. Otherwise, use the offscreen canvas
	if (gui.exists()) gui.mainView.saveVector(obj.m, vf, c->argc(1));
	else
	{
		gui.offscreenCanvas.saveVector(obj.m, vf, c->argc(1));
	}
	return CR_SUCCESS;
}
