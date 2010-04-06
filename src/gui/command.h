/*
	*** Qt GUI: Command/Script Window
	*** src/gui/command.h
	Copyright T. Youngs 2007-2010

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

#ifndef ATEN_COMMANDWINDOW_H
#define ATEN_COMMANDWINDOW_H

#include "gui/ui_command.h"

// Script/command window
class AtenCommand : public QDialog
{
	// All Qt declarations derived from QObject must include this macro
	Q_OBJECT

	/*
	// Window Functions
	*/
	public:
	void showWindow();
	void refresh();
	private slots:
	void dialogFinished(int result);
	void on_CommandPrompt_returnPressed();

	/*
	// Public Functions
	*/
	public:
	// Set list of commands in command tab
	void setCommandList(QStringList cmds);
	// Return list of commands stored in command tab
	QStringList commandList();

	/*
	// Widgets
	*/
	public:
	// Constructor
	AtenCommand(QWidget *parent = 0, Qt::WindowFlags flags = 0);
	// Destructor
	~AtenCommand();
	// Main form declaration
	Ui::CommandDialog ui;
	// Finalise widgets (things that couldn't be done in Qt Designer)
	void finaliseUi();
	// Set controls to reflect program variables
	void setControls();
};

#endif