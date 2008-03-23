/*
	*** Variable command functions
	*** src/command/variables.cpp
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

// Decrease variable by 1
int CommandData::function_CA_DECREASE(Command *&c, Bundle &obj)
{
	c->arg(0)->decrease(1);
	return CR_SUCCESS;
}

// Evaluate expression and assign to variable
int CommandData::function_CA_EVAL(Command *&c, Bundle &obj)
{
	c->arg(0)->set(evaluate(c->argc(2), &c->parent()->variables));
	return CR_SUCCESS;
}

// Set variable to value or variable
int CommandData::function_CA_LET(Command *&c, Bundle &obj)
{
	// If the first var is a pointer, second must be a pointer!
	if (c->argt(0) >= VT_ATOM)
	{
		if (c->argt(0) != c->argt(2))
		{
			msg(DM_NONE,"Incompatible pointer types for variable assignment of contents of '%s' to '%s'.\n", c->arg(0)->name(), c->arg(2)->name());
			return CR_FAIL;
		}
		else c->arg(0)->copyPointer(c->arg(2));
	}
	else c->arg(0)->set(c->argc(2));
	return CR_SUCCESS;
}

// Increase variable
int CommandData::function_CA_INCREASE(Command *&c, Bundle &obj)
{
	c->arg(0)->increase(1);
	return CR_SUCCESS;
}
