/*
	*** PatternBound Access
	*** src/variables/pboundaccess.cpp
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

#include "variables/patternboundaccess.h"
#include "variables/accessstep.h"
#include "variables/vaccess.h"
#include "classes/forcefieldbound.h"
#include "base/pattern.h"
#include "base/elements.h"
#include "base/messenger.h"

PatternBoundAccessors pboundAccessors;

// Constructor
PatternBoundAccessors::PatternBoundAccessors()
{
	accessorPointers[PatternBoundAccessors::Data] = addAccessor("data",		VTypes::RealData, FALSE);
	accessorPointers[PatternBoundAccessors::Data]->setListArray();
	accessorPointers[PatternBoundAccessors::Form] = addAccessor("form",		VTypes::CharacterData, FALSE);
	accessorPointers[PatternBoundAccessors::TypeNames] = addListAccessor("typenames",	VTypes::CharacterData);
};

// Retrieve specified data
bool PatternBoundAccessors::retrieve(void *classptr, AccessStep *step, ReturnValue &rv)
{
	msg.enter("PatternBoundAccessors::retrieve");
	bool result = TRUE;
	// Cast pointer into PatternBound*
	PatternBound *pb = (PatternBound*) classptr;
	if (pb == NULL) printf("Warning - NULL PatternBound pointer passed to PatternBoundAccessors::retrieve.\n");
// 	printf("Enumerated ID supplied to PatternBoundAccessors is %i.\n", vid);
	// Check range of supplied vid
	int vid = step->variableId();
	if ((vid < 0) || (vid > PatternBoundAccessors::nAccessors))
	{
		printf("Unknown enumeration %i given to PatternBoundAccessors::set.\n", vid);
		msg.exit("PatternBoundAccessors::set");
		return FALSE;
	} 
	// Get arrayindex (if there is one) and check that we needed it in the first place
	int index;
	if (step->hasArrayIndex())
	{
		if (accessorPointers[vid]->isArray())
		{
			// Get index and do simple lower-limit check
			index = step->arrayIndex();
			if (index < 1)
			{
				printf("Array index '%i' given to member '%s' in PatternBoundAccessors::retrieve is out of bounds.\n", index, accessorPointers[vid]->name());
				msg.exit("PatternBoundAccessors::retrieve");
				return FALSE;
			}
		}
		else
		{
			printf("Array index given to member '%s' in PatternBoundAccessors::retrieve, but it is not an array.\n", accessorPointers[vid]->name());
			msg.exit("PatternBoundAccessors::retrieve");
			return FALSE;
		}
	}
	else
	{
		if (accessorPointers[vid]->isArray())
		{
			printf("Array index missing for member '%s' in PatternBoundAccessors::retrieve.\n", accessorPointers[vid]->name());
			msg.exit("PatternBoundAccessors::retrieve");
			return FALSE;
		}
	}
	// Retrieve value based on enumerated id
	switch (vid)
	{
		case (PatternBoundAccessors::Data):
			if (pb->data() == NULL)
			{
				msg.print("NULL ForcefieldBound pointer found in PatternBound class.\n");
				result = FALSE;
			}
			else rv.set(pb->data()->parameter(index-1));
			break;
		case (PatternBoundAccessors::Form):
			if (pb->data() == NULL)
			{
				msg.print("NULL ForcefieldBound pointer found in PatternBound class.\n");
				result = FALSE;
			}
			else rv.set(pb->data()->formText());
			break;
		default:
			printf("PatternBoundAccessors::retrieve doesn't know how to use member '%s'.\n", accessorPointers[vid]->name());
			result = FALSE;
			break;
	}
	msg.exit("PatternBoundAccessors::retrieve");
	return result;
}

// Set specified data
bool PatternBoundAccessors::set(void *classptr, AccessStep *step, Variable *srcvar)
{
	msg.enter("PatternBoundAccessors::set");
	bool result = TRUE;
	// Cast pointer into PatternBound*
	PatternBound *pb = (PatternBound*) classptr;
	if (pb == NULL) printf("Warning - NULL PatternBound pointer passed to PatternBoundAccessors::set.\n");
// 	printf("Enumerated ID supplied to PatternBoundAccessors is %i.\n", vid);
	// Check range of supplied vid
	int vid = step->variableId();
	if ((vid < 0) || (vid > PatternBoundAccessors::nAccessors))
	{
		printf("Unknown enumeration %i given to PatternBoundAccessors::set.\n", vid);
		msg.exit("PatternBoundAccessors::set");
		return FALSE;
	}
	// Get arrayindex (if there is one) and check that we needed it in the first place
	int index;
	if (step->hasArrayIndex())
	{
		if (accessorPointers[vid]->isArray())
		{
			// Get index and do simple lower-limit check
			index = step->arrayIndex();
			if (index < 1)
			{
				printf("Array index '%i' given to member '%s' in PatternBoundAccessors::retrieve is out of bounds.\n", index, accessorPointers[vid]->name());
				msg.exit("PatternBoundAccessors::set");
				return FALSE;
			}
		}
		else
		{
			printf("Array index given to member '%s' in PatternBoundAccessors::set, but it is not an array.\n", accessorPointers[vid]->name());
			msg.exit("PatternBoundAccessors::set");
			return FALSE;
		}
	}
	else
	{
		if (accessorPointers[vid]->isArray())
		{
			printf("Array index missing for member '%s' in PatternBoundAccessors::set.\n", accessorPointers[vid]->name());
			msg.exit("PatternBoundAccessors::set");
			return FALSE;
		}
	}
	// Set value based on enumerated id
	switch (vid)
	{
		case (PatternBoundAccessors::Data):
			msg.print("Member '%s' in PatternBound is read-only.\n", accessorPointers[vid]->name());
			result = FALSE;
			break;
		default:
			printf("PatternBoundAccessors::set doesn't know how to use member '%s'.\n", accessorPointers[vid]->name());
			result = FALSE;
			break;
	}
	msg.exit("PatternBoundAccessors::set");
	return result;
}