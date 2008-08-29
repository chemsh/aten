/*
	*** Atom location
	*** src/base/atomaddress.cpp
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

#include "base/atomaddress.h"
#include "base/messenger.h"

// Constructor
Atomaddress::Atomaddress()
{
}

// Destructor
Atomaddress::~Atomaddress()
{
}

/*
// Variable Access
*/

// Set the local molecule offset of the atom
void Atomaddress::setOffset(int i)
{
	offset_ = i;
}

// Returns the local molecule offset of the atom
int Atomaddress::getOffset()
{
	return offset_;
}

// Set the molecule id of the atom
void Atomaddress::setMolecule(int i)
{
	molecule_ = i;
}

// Returns the molecule the atom is in
int Atomaddress::molecule()
{
	return molecule_;
}

// Set the pattern pointer for the atom
void Atomaddress::setPattern(Pattern *p)
{
	pattern_ = p;
}

// Returns the current pattern for the atom
Pattern *Atomaddress::pattern()
{
	return pattern_;
}