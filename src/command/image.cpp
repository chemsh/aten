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
#include "gui/gui.h"
#include "gui/mainwindow.h"
#include "gui/tcanvas.uih"
#include "model/model.h"
#include "classes/prefs.h"

// Save current view as bitmap image
int CommandData::function_CA_SAVEBITMAP(Command *&c, Bundle &obj)
{
	if (obj.notifyNull(Bundle::ModelPointer)) return Command::Fail;
	// Flag any surfaces to be rerendered for use in this context
	obj.rs->rerenderGrids();
	// Create a QPixmap of the current scene setting and restoring the original view object bitvectors
	int screenbits = prefs.screenObjects();
	prefs.setScreenObjects(prefs.imageObjects());
	QPixmap pixmap;
	gui.mainView.postRedisplay();

	if (c->hasArg(3)) pixmap = gui.mainWidget->renderPixmap(c->argi(2), c->argi(3), FALSE);
	else pixmap = gui.mainWidget->renderPixmap(0, 0, FALSE);
	prefs.setScreenObjects(screenbits);
	// Flag any surfaces to be rerendered so they are redisplayed in the original context
	obj.rs->rerenderGrids();
	// Reconfigure canvas to widget size (necessary if image size was changed)
	gui.mainView.configure(gui.mainWidget->width(), gui.mainWidget->height());

	// Convert format to bitmap_format
	bitmap_format bf = BIF_from_text(c->argc(0));
	if (bf != BIF_NITEMS)
	{
		pixmap.save(c->argc(1), extension_from_BIF(bf), -1);
		msg.print("Saved current view as '%s'\n",c->argc(1));
	}
	else
	{
		msg.print("Unrecognised bitmap format.\n");
		return Command::Fail;
	}
	return Command::Success;
}

// Save current view a vector graphic
int CommandData::function_CA_SAVEVECTOR(Command *&c, Bundle &obj)
{
	if (obj.notifyNull(Bundle::ModelPointer)) return Command::Fail;
	vector_format vf = VIF_from_text(c->argc(0));
	if (vf == VIF_NITEMS)
	{
		msg.print("Unrecognised vector format '%s'.\n",c->argc(0));
		return Command::Fail;
	}
	// If gui exists, use the main canvas. Otherwise, use the offscreen canvas
	gui.mainView.saveVector(obj.rs, vf, c->argc(1));
	return Command::Success;
}
