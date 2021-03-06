/*
	*** Model atom functions
	*** src/model/atom.cpp
	Copyright T. Youngs 2007-2018

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

#include "model/model.h"
#include "undo/undostate.h"
#include "undo/atom_creation.h"
#include "undo/atom_charge.h"
#include "undo/atom_colour.h"
#include "undo/atom_hide.h"
#include "undo/atom_fix.h"
#include "undo/atom_style.h"
#include "undo/atom_swap.h"
#include "undo/atom_translate.h"
#include "undo/atom_transmute.h"
#include "base/atom.h"
#include "base/pattern.h"
#include "base/forcefieldatom.h"

ATEN_USING_NAMESPACE

// Return the start of the atom list
Atom* Model::atoms() const
{
	return atoms_.first();
}

// Return the number of atoms in the model
int Model::nAtoms() const
{
	return atoms_.nItems();
}

// Add atom
Atom* Model::addAtom(short int newel, Vec3<double> r, Vec3<double> v, Vec3<double> f)
{
	Messenger::enter("Model::addAtom");
	Atom* newatom = atoms_.add();
	newatom->setParent(this);
	newatom->setElement(newel);
	newatom->setColourFromElement();
	newatom->setId(atoms_.nItems() - 1);
	newatom->r() = r;
	newatom->v() = v;
	newatom->f() = f;
	increaseMass(newel);
	logChange(Log::Structure);

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomCreationEvent* newchange = new AtomCreationEvent;
		newchange->set(true, newatom);
		recordingState_->addEvent(newchange);
	}
	Messenger::exit("Model::addAtom");
	return newatom;
}

// Add atom with specified id
Atom* Model::addAtomWithId(short int newel, Vec3<double> pos, int targetid)
{
	Messenger::enter("Model::addAtom");
	Atom* newatom = targetid == 0 ? atoms_.prepend() : atoms_.insertAfter(atoms_[targetid-1]);
	newatom->setParent(this);
	newatom->setElement(newel);
	newatom->setColourFromElement();
	newatom->setId(targetid);
	renumberAtoms(newatom);
	newatom->r() = pos;
	increaseMass(newel);
	logChange(Log::Structure);

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomCreationEvent* newchange = new AtomCreationEvent;
		newchange->set(true, newatom);
		recordingState_->addEvent(newchange);
	}
	Messenger::exit("Model::addAtom");
	return newatom;
}

// Create a new atom at the Model's current pen position
Atom* Model::addAtomAtPen(short int el)
{
	return addAtom(el, penPosition_);
}

// Add atom copy
Atom* Model::addCopy(Atom* source)
{
	Messenger::enter("Model::addCopy");
	Atom* newatom = atoms_.add();
	newatom->copy(source);
	newatom->setParent(this);
	newatom->setId(atoms_.nItems() - 1);
	logChange(Log::Structure);
	increaseMass(newatom->element());

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomCreationEvent* newchange = new AtomCreationEvent;
		newchange->set(true, newatom);
		recordingState_->addEvent(newchange);
	}

	Messenger::exit("Model::addCopy");
	return newatom;
}

// Add atom copy at specified position in list
Atom* Model::addCopy(Atom* afterthis, Atom* source)
{
	Messenger::enter("Model::addCopy");
	Atom* newatom = atoms_.insertAfter(afterthis);
	//printf("Adding copy after... %p %p\n",afterthis,source);
	newatom->copy(source);
	newatom->setParent(this);
	renumberAtoms(afterthis);
	logChange(Log::Structure);
	increaseMass(newatom->element());

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomCreationEvent* newchange = new AtomCreationEvent;
		newchange->set(true,newatom);
		recordingState_->addEvent(newchange);
	}

	Messenger::exit("Model::addCopy");
	return newatom;
}

// Remove atom
void Model::removeAtom(Atom* xatom, bool noupdate)
{
	Messenger::enter("Model::removeAtom");

	// Adjust the atomic mass of the model
	reduceMass(xatom->element());

	// Renumber the ids of all atoms in the list after this one
	if (!noupdate) for (Atom* i = xatom->next; i != NULL; i = i->next) i->decreaseId();

	// Deselect and unmark if necessary
	if (xatom->isSelected()) deselectAtom(xatom);
	if (xatom->isSelected(true)) deselectAtom(xatom, true);
	logChange(Log::Structure);

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomCreationEvent* newchange = new AtomCreationEvent;
		newchange->set(false,xatom);
		recordingState_->addEvent(newchange);
	}
	atoms_.remove(xatom);

	Messenger::exit("Model::removeAtom");
}

// Delete Atom
void Model::deleteAtom(Atom* xatom, bool noupdate)
{
	Messenger::enter("Model::deleteAtom");
	// The atom may be present in other, unassociated lists (e.g. measurements), so we must
	// also check those lists for this atom before removing it.
	if (xatom == NULL) Messenger::print("No atom to delete.");
	else
	{
		// Remove measurements
		removeMeasurements(xatom);

		// Delete All Bonds To Specific Atom
		RefListItem<Bond,int>* bref = xatom->bonds();
		while (bref != NULL)
		{
			// Need to detach the bond from both atoms involved
			Bond* b = bref->item;
			Atom* j = b->partner(xatom);
			unbondAtoms(xatom,j,b);
			bref = xatom->bonds();
		}

		// For all glyphs involving this atom, set the current coordinates
		int i;
		for (Glyph* g = glyphs_.first(); g != NULL; g = g->next)
		{
			for (i=0; i<Glyph::nGlyphData(g->type()); ++i) if (g->data(i)->atom() == xatom) g->data(i)->setVector(xatom->r());
		}
		
		// Finally, delete the atom
		removeAtom(xatom, noupdate);
	}
	Messenger::exit("Model::deleteAtom");
}

// Transmute atom
void Model::transmuteAtom(Atom* i, short int el)
{
	Messenger::enter("Model::transmuteAtom");
	if (i == NULL) Messenger::print("No atom to transmute.");
	else
	{
		short int oldel = i->element();
		if (oldel != el)
		{
			reduceMass(i->element());
			i->setElement(el);
			increaseMass(i->element());
			logChange(Log::Structure);

			// Add the change to the undo state (if there is one)
			if (recordingState_ != NULL)
			{
				AtomTransmuteEvent* newchange = new AtomTransmuteEvent;
				newchange->set(i->id(),oldel,el);
				recordingState_->addEvent(newchange);
			}
		}
	}
	Messenger::exit("Model::transmuteAtom");
}

// Return (and autocreate if necessary) the static atoms array
Atom** Model::atomArray()
{
	return atoms_.array();
}

// Clear atoms
void Model::clearAtoms()
{
	Messenger::enter("Model::clearAtoms");
	while (Atom *i = atoms_.last()) deleteAtom(i, true);
	Messenger::exit("Model::clearAtoms");
}

// Return the list index of the specified atom
int Model::atomIndex(Atom* i) const
{
	return atoms_.indexOf(i);
}

// Renumber Atoms
void Model::renumberAtoms(Atom* from)
{
	Messenger::enter("Model::renumberAtoms");
	int count;
	Atom* i;
	if (from == NULL)
	{
		count = -1;
		i = atoms_.first();
	}
	else
	{
		count = from->id();
		i = from->next;
	}
	for (i = i; i != NULL; i = i->next) i->setId(++count);
	Messenger::exit("Model::renumberAtoms");
}

// Return atom 'n' in the model
Atom* Model::atom(int n)
{
	Messenger::enter("Model::atom");
	// Check range first
	if ((n < 0) || (n >= atoms_.nItems()))
	{
		Messenger::print("Atom id '%i' is out of range for model '%s'.", n+1, qPrintable(name_));
		Messenger::exit("Model::atom");
		return NULL;
	}
	Messenger::exit("Model::atom");
	return atoms_[n];
}

// Set visibility of specified atom
void Model::atomSetHidden(Atom* i, bool hidden)
{
	if (i->isHidden() != hidden)
	{
		i->setHidden(hidden);
		logChange(Log::Style);
		// Add the change to the undo state (if there is one)
		if (recordingState_ != NULL)
		{
			AtomHideEvent* newchange = new AtomHideEvent;
			newchange->set(hidden, i->id());
			recordingState_->addEvent(newchange);
		}
	}
}

// Set fixed status of specified atom
void Model::atomSetFixed(Atom* i, bool fixed)
{
	if (i->isPositionFixed() != fixed)
	{
		i->setPositionFixed(fixed);
		logChange(Log::Style);

		// Add the change to the undo state (if there is one)
		if (recordingState_ != NULL)
		{
			AtomFixEvent* newchange = new AtomFixEvent;
			newchange->set(fixed, i->id());
			recordingState_->addEvent(newchange);
		}
	}
}

// Set charge of specified atom
void Model::atomSetCharge(Atom* target, double q)
{
	double oldcharge = target->charge();
	target->setCharge(q);
	logChange(Log::Coordinates);

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomChargeEvent* newchange = new AtomChargeEvent;
		newchange->set(target->id(), oldcharge, q);
		recordingState_->addEvent(newchange);
	}
}

// Set custom colour of specified atom
void Model::atomSetColour(Atom* i, double r, double g, double b, double a)
{
	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomColourEvent* newchange = new AtomColourEvent;
		double* oldcol = i->colour();
		newchange->set(i->id(), oldcol[0], oldcol[1], oldcol[2], oldcol[3], r, g, b, a);
		recordingState_->addEvent(newchange);
	}

	// Now set the colour....
	i->setColour(r, g, b, a);
	logChange(Log::Style);
}

// Reset custom colour of specified atom
void Model::atomResetColour(Atom* i)
{
	// Grab new colour...
	double newColour[4];
	ElementMap::copyColour(i->element(), newColour);

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomColourEvent* newchange = new AtomColourEvent;
		double* oldColour = i->colour();
		newchange->set(i->id(), oldColour[0], oldColour[1], oldColour[2], oldColour[3], newColour[0], newColour[1], newColour[2], newColour[3]);
		recordingState_->addEvent(newchange);
	}

	// Now set the colour....
	i->setColour(newColour[0], newColour[1], newColour[2], newColour[3]);
	logChange(Log::Style);
}

// Set style of individual atom
void Model::atomSetStyle(Atom* i, Prefs::DrawStyle ds)
{
	// Check current style
	if (i->style() == ds) return;

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomStyleEvent* newchange = new AtomStyleEvent;
		newchange->set(i->id(), i->style(), ds);
		recordingState_->addEvent(newchange);
	}

	i->setStyle(ds);
	logChange(Log::Style);
}

// Print coordinates of all atoms
void Model::printCoords() const
{
	Messenger::enter("Model::printCoords");
	for (Atom* i = atoms_.first(); i != NULL; i = i->next)
	{
		printf("Atom  %3i  %s  %11.6f  %11.6f  %11.6f  %9.6f\n", i->id(), ElementMap::symbol(i), i->r().x, i->r().y, i->r().z, i->charge());
	//	printf("Atom  %3i  %s  %11.6f  %11.6f  %11.6f  %9.6f  %s\n",i->id(),ElementMap::symbol(i),r.x,r.y,r.z,
	//		i->get_charge(),(ff == NULL ? " " : ff->name(i)));
	}
	Messenger::exit("Model::printCoords");
}

// Move specified atom (channel for undo/redo)
void Model::translateAtom(Atom* target, Vec3<double> delta)
{
	target->r() += delta;
	logChange(Log::Coordinates);

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomTranslateEvent* newchange = new AtomTranslateEvent;
		newchange->set(target->id(), delta);
		recordingState_->addEvent(newchange);
	}
}

// Position specified atom (channel for undo/redo)
void Model::positionAtom(Atom* target, Vec3<double> newr)
{
	static Vec3<double> delta;
	delta = newr - target->r();
	target->r() = newr;
	logChange(Log::Coordinates);

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomTranslateEvent* newchange = new AtomTranslateEvent;
		newchange->set(target->id(), delta);
		recordingState_->addEvent(newchange);
	}
}

// Return total bond order penalty of atoms in the model
int Model::totalBondOrderPenalty() const
{
	int result = 0;
	for (Atom* i = atoms_.first(); i != NULL; i = i->next) result += ElementMap::bondOrderPenalty(i, i->totalBondOrder()/2);
	return result;
}

// Count bonds of specific type
int Model::countBondsToAtom(Atom* i, Bond::BondType type)
{
	Messenger::enter("Model::countBondsToAtom");
	int count = 0;
	for (RefListItem<Bond,int>* bref = i->bonds(); bref != NULL; bref = bref->next)
		if (bref->item->order() == type) count ++;
	Messenger::exit("Model::countBondsToAtom");
	return count;
}

// Return the total mass of atoms
double Model::mass() const
{
	return mass_;
}

// Calculate and return the forcefield mass of the model
double Model::forcefieldMass() const
{
	Messenger::enter("Model::forcefieldMass");
	double ffmass = 0.0;
	for (Atom* i = atoms_.first(); i != NULL; i = i->next)
	{
		if (i->type() == NULL)
		{
			Messenger::print("Error: Atom id %i doesn't have a forcefield type - using atom mass instead...", i->id()+1);
			ffmass += ElementMap::atomicMass(i);
		}
		else ffmass += i->type()->elementMass();
	}
	Messenger::exit("Model::forcefieldMass");
	return ffmass;
}

// Reduce the mass (and unknown element count) of the model
void Model::reduceMass(int element)
{
	mass_ -= ElementMap::atomicMass(element);
	if (fabs(mass_) < 1.0e-5) mass_ = 0.0;
	if (element == 0) --nUnknownAtoms_;
}

// Increasethe mass (and unknown element count) of the model
void Model::increaseMass(int element)
{
	mass_ += ElementMap::atomicMass(element);
	if (element == 0) ++nUnknownAtoms_;
}

// Calculate mass
void Model::calculateMass()
{
	// Recalculate the mass of the atoms in the model
	Messenger::enter("Model::calculateMass");
	mass_ = 0.0;
	nUnknownAtoms_ = 0;
	for (Atom* i = atoms_.first(); i != NULL; i = i->next)
	{
		mass_ += ElementMap::atomicMass(i);
		if (i->element() == 0) ++nUnknownAtoms_;
	}
	Messenger::exit("Model::calculateMass");
}

// Return number of unknown atoms in the model
int Model::nUnknownAtoms() const
{
	return nUnknownAtoms_;
}

// Copy atom style from specified model
void Model::copyAtomStyle(Model* source)
{
	Messenger::enter("Model::copyAtomStyle");

	if (source == NULL)
	{
		Messenger::print("Internal Error: NULL reference passed to MOdel::copyAtomStyle()");
		Messenger::exit("Model::copyAtomStyle");
	}

	// Perform only one check - that the number of atoms is the same
	if (source->nAtoms() != atoms_.nItems())
	{
		Messenger::print("Error: Can't copy parent model's atom style because it has a different number of atoms (%i cf %i)", source->nAtoms(), atoms_.nItems());
		Messenger::exit("Model::copyAtomStyle");
	}
	
	// Do the loop
	Atom** ii = source->atomArray(), **jj = atomArray();
	for (int n=0; n<atoms_.nItems(); ++n) jj[n]->copyStyle(ii[n]);

	// Copy atom style and colour scheme
	setDrawStyle(source->drawStyle());
	setColourScheme(source->colourScheme());

	logChange(Log::Style);

	Messenger::exit("Model::copyAtomStyle");
}

// Clear tempBits of all atoms
void Model::clearAtomBits()
{
	for (Atom* i = atoms_.first(); i != NULL; i = i->next) i->clearBit();
}

// Move specified atom up/down in the atom list
void Model::moveAtom(int index, int delta)
{
	Messenger::enter("Model::moveAtom");
	if ((index < 0) || (index >= atoms_.nItems()))
	{
		printf("Internal Error: Atom index out of range (%i) in Model::moveAtom.", index);
		Messenger::exit("Model::moveAtom");
		return;
	}

	// Move the atom, and then renumber those atoms that will have changed...
	atoms_.move(index, delta);
	int startId = std::min(index+delta, index), endId = std::max(index+delta, index);
	for (int n=startId; n<=endId; ++n) atoms_[n]->setId(n);

	Messenger::exit("Model::moveAtom");
}

// Swap specified atoms in the atom list
void Model::swapAtoms(Atom* i, Atom* j)
{
	Messenger::enter("Model::swapAtoms");
	if ((i == NULL) || (j == NULL))
	{
		printf("Internal Error: NULL Atom pointer(s) passed to Model::swapAtoms.");
		Messenger::exit("Model::swapAtoms");
		return;
	}

	// Swap atoms and their indices
	int tempId = j->id();
	j->setId(i->id());
	i->setId(tempId);
	atoms_.swapByIndex(i->id(), j->id());

	// Add the change to the undo state (if there is one)
	if (recordingState_ != NULL)
	{
		AtomSwapEvent* newchange = new AtomSwapEvent;
		newchange->set(i->id(), j->id());
		recordingState_->addEvent(newchange);
	}
	logChange(Log::Structure);
	Messenger::exit("Model::swapAtoms");
}

// Swap specified atoms in the atom list
void Model::swapAtoms(int id1, int id2)
{
	swapAtoms(atom(id1), atom(id2));
}
