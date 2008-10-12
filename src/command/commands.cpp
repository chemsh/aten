/*
	*** Command definitions
	*** src/command/commands.cpp
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
#include "command/commands.h"
#include "main/aten.h"
#include "base/bundle.h"

// Singleton
Command commands;

// Command action
CommandData Command::data[Command::CA_NITEMS] = {
	// Variables
	{ "character",		"",		"<variables>",
				"Create character (string) variables with the names provided" },
	{ "integer",		"",		"<variables>",
				"Create integer variables with the names provided" },
	{ "double",		"",		"<variables>",
				"Create double variables with the names provided" },
	{ "atom",		"",		"<variables>",
				"Create atom* variables with the names provided" },
	{ "bond",		"",		"<variables>",
				"Create bond* variables with the names provided" },
	{ "pattern",		"",		"<variables>",
				"Create pattern* variables with the names provided" },
	{ "bound",		"",		"<variables>",
				"Create patternbound* variables with the names provided" },
	{ "model",		"",		"<variables>",
				"Create model* variables with the names provided" },
	{ "grid",		"",		"<variables>",
				"Create grid* variables with the names provided" },
	{ "ffatom",		"",		"<variables>",
				"Create ffatom* variables with the names provided" },
	{ "ffbound",		"",		"<variables>",
				"Create ffbound* variables with the names provided" },
	{ "_cellvar_",		"",		"<variables>",
				"Create cell* variables with the names provided" },
	{ "forcefield",		"",		"<variables>",
				"Create forcefield* variables with the names provided" },
	{ "_prefsvar_",		"",		"<variables>",
				"Create prefs* variables with the names provided" },
	
	// Root node
	{ "_ROOTNODE_",		"",		"",
				"" },
	
	// Analysis commands
	{ "finalise",		"",		"",
				"Finalise all calculated quantities" },
	{ "frameanalyse",	"",		"",
				"Analyse quantities for the current trajectory frame" },
	{ "geometry",		"NEEENNNnn",	"<name> <min> <binwidth> <nbins> <filename> <site1> <site2> [site3 [site4]]",
				"Calculate geometries" },
	{ "modelanalyse",	"",		"",
				"Analyse quantities for the current model" },
	{ "pdens",		"NEENNN",	"<name> <griddelta> <nsteps> <filename> <site1> <site2> ",
				"Request calculation of a probability density between sites" },
	{ "listjobs",		"",		"",
				"Print the current list of quantities to calculate" },
	{ "rdf",		"NEEENNN",	"<name> <rmin> <binwidth> <nbins> <filename> <site1> <site2>",
				"Request calculation of radial distribution function between sites" },
	{ "savequantities",	"",		"",
				"Save calculated quantities to file" },
	{ "trajanalyse",	"EEe",		"<startframe> <frameskip> [nframes]",
				"Analyse quantities for all frames in current trajectory" },
	
	// Atom commands
	{ "atomstyle",		"N",		"<style>",
				"Set the individual style of the current atom selection" },
	{ "getatom",		"Ea",		"<id> [variable]",
				"Retrieve information for atom id, placing in variable supplied" },
	{ "hide",		"",		"",
				"Hide the current selection of atoms" },
	{ "setcharge",		"Ee",		"<q> [id]",
				"Set the charge of the current (or specified) atom" },
	{ "setcoords",		"EEEe",		"<x> <y> <z> [id]",
				"Set the coordinates of the current (or specified) atom" },
	{ "setelement",		"Ne",		"<element> [id]",
				"Set the element of the current (or specified) atom" },
	{ "setforces",		"EEEe",		"<fx> <fy> <fz> [id]",
				"Set the forces of the current (or specified) atom" },
	{ "setfx",		"Ee",		"<fx> [id]",
				"Set the x force of the current (or specified) atom" },
	{ "setfy",		"Ee",		"<fy> [id]",
				"Set the y force of the current (or specified) atom" },
	{ "setfz",		"Ee",		"<fz> [id]",
				"Set the z force of the current (or specified) atom" },
	{ "setid",		"Ee",		"<id> [id]",
				"Set the id of the current (or specified) atom" },
	{ "setrx",		"Ee",		"<rx> [id]",
				"Set the x coordinate of the current (or specified) atom" },
	{ "setry",		"Ee",		"<ry> [id]",
				"Set the y coordinate of the current (or specified) atom" },
	{ "setrz",		"Ee",		"<rz> [id]",
				"Set the z coordinate of the current (or specified) atom" },
	{ "setvelocities",	"EEEe",		"<vx> <vy> <vz> [id]",
				"Set the velocities of the current (or specified) atom" },
	{ "setvx",		"Ee",		"<vx> [id]",
				"Set the x velocity of the current (or specified) atom" },
	{ "setvy",		"Ee",		"<vy> [id]",
				"Set the y velocity of the current (or specified) atom" },
	{ "setvz",		"Ee",		"<vz> [id]",
				"Set the z velocity of the current (or specified) atom" },
	{ "show",		"",		"",
				"Show the current selection of atoms" },
	{ "showall",		"",		"",
				"Show all atoms in the current model" },

	// Bonding commands
	{ "augment",		"",		"",
				"Automatically augment all bonds in the current model" },
	{ "bondtolerance",	"E",		"<tolerance>",
				"Set bonding tolerance for automatic calculation" },
	{ "clearbonds",		"",		"",
				"Delete all bonds in the current model" },
	{ "getbond",		"EB",		"<id> <variable>",
				"Retrieve information for bond 'id', placing in variable supplied" },
	{ "newbond",		"EEn",		"<atom1> <atom2> [bondtype]",
				"Create a bond between specified atoms" },
	{ "newbondid",		"EEn",		"<id1> <id2> [bondtype]",
				"Create a bond between atoms with ids specified" },
	{ "rebondpatterns",	"",		"",
				"Calculate bonds between atoms, restricted to atoms in pattern molecules" },
	{ "rebondselection",	"",		"",
				"Calculate bonds between atoms in the current selection" },
	{ "rebond",		"",		"",
				"Calculate bonding in the current model" },
	
	// Build commands
	{ "addhydrogen",	"e",		"[atom|id]",
				"Hydrogen satisfy all (or specified) atom in model" },
	{ "bohr",		"v*",		"<object> [object...]",
				"Convert coordinates in the specified object " },
	{ "chain",		"Neeee",	"<element> [bondtype] | <element> <x> <y> <z> [bondtype]",
				"Create a new atom in the current model, bound to the last" },
	{ "endchain",		"",		"",
				"End the current bond chain (the next call to 'chain' will create an unbound atom)" },
	{ "locate",		"EEE",		"<x> <y> <z>",
				"Position pen at specified coordinates" },
	{ "move",		"EEE",		"<dx> <dy> <dz>",
				"Move pen by specified coordinates" },
	{ "newatom",		"Neee",		"<element> [x y z]",
				"Create a new atom in the current model" },
	{ "newatomfrac",	"NEEE",		"<element> <fracx> <fracy> <fracz>",
				"Create a new atom in the current model, converting fractional coordinates to real coordinates" },
	{ "resetpen",		""		"",
				"Reset the pen orientation to the identity matrix (but leave the current position intact)" },
	{ "rotx",		"E",		"<angle>",
				"Rotate pen about its x axis by given angle" },
	{ "roty",		"E",		"<angle>",
				"Rotate pen about its y axis by given angle" },
	{ "rotz",		"E",		"<angle>",
				"Rotate pen about its z axis by given angle" },
	{ "shiftdown",		"e",		"[n]",
				"Shift current atom selection down 1 (or 'n') places" },
	{ "shiftup",		"e",		"[n]",
				"Shift current atom selection up 1 (or 'n') places" },
	{ "toend",		"",		"",
				"Move current atom selection to end of list" },
	{ "tostart",		"",		"",
				"Move current atom selection to start of list" },
	{ "transmute",		"E",		"<element>",
				"Transmute selection to element given" },
	
	// Cell commands
	{ "addgenerator",	"N",		"<generator>",
				"Manually add a spacegroup generator definition to the current model's cell" },
	{ "adjustcell",		"NE",		"<quantity> <change>",
				"Adjust a single value of the current cell specification (e.g. <quantity> = a, beta, cz, etc.)" },
	{ "cell",		"EEEEEE",	"<a> <b> <c> <alpha> <beta> <gamma>",
				"Set or create a unit cell for the current model from lengths/angles provided" },
	{ "cellaxes",		"EEEEEEEEE",	"<ax> <ay> <az> <bx> <by> <bz> <cx> <cy> <cz>",
				"Set or create a unit cell for the current model from the cell axes provided" },
	{ "fold",		"",		"",
				"Fold atoms into model's unit cell" },
	{ "foldmolecules",	"",		"",
				"Fold molecules (defined by patterns) so that they are unbroken across cell boundaries" },
	{ "fractoreal",		"",		"",
				"Convert (assumed) fractional model coordinates to real coordinates" },
	{ "nocell",		"", 		"",
				"Remove any cell definition from the current model" },
	{ "pack",		"",		"",
				"Pack the unit cell with symmetry operators list in associated spacegroup" },
	{ "printcell",		"",		"",
				"Print the unit cell of the current model" },
	{ "replicate",		"EEEEEE",	"<negx> <negy> <negz> <posx> <posy> <posz>",
				"Replicate the cell along the directions given" },
	{ "scale",		"EEE",		"<x> <y> <z>",
				"Scale the unit cell of the current model" },
	{ "setcell",		"NE",		"<quantity> <value>",
				"Set a single value of the current cell specification (e.g. <quantity> = a, beta, cz, etc.)" },
	{ "spacegroup",		"N",		"<spgrp>",
				"Set the spacegroup for the current model" },
	
	// Charge commands
	{ "chargeff",		"",		"",
				"Charge atoms in the model according to their forcefield atom types" },
	{ "chargefrommodel",	"",		"",
				"Charge atoms in the current trajectory frame from the parent model" },
	{ "chargepatom",	"EE",		"<id> <q>",
				"Set charges for specific atom id in all molecules of the current pattern" },
	{ "charge",		"E",		"<q>",
				"Set charges of atoms in the current selection" },
	{ "chargetype",		"EE",		"<type> <q>",
				"Set charges of all atoms of the given type" },
	{ "clearcharges",	"",		"",
				"Zero all charges in the current model" },

	// Colourscale commands
	{ "addpoint",		"EEEEEe",	"<scaleid> <value> <r> <g> <b> [a]",
				"Add a new point to the specified colourscale" },
	{ "clearpoints",	"E",		"<scaleid>",
				"Clear all points from the specified colourscale" },
	{ "listscales",		"",		"",
				"List details on all colourscales" },
	{ "removepoint",	"EE",		"<scaleid> <point>",
				"Remove the selected point from the specified colourscale" },
	{ "scalename",		"En",		"<scaleid> [name]",
				"Print (or set) the name of the colourscale specified" },
	{ "scalevisible",	"EN",		"<scaleid> true|false",
				"Set the visibility of the specified colourscale" },
	{ "setpoint",		"EEEEEEe",	"<scaleid> <point> <value> <r> <g> <b> [a]",
				"Set an existing point on the specified colourscale" },
	{ "setpointcolour", 	"EEEEEe",	"<scaleid> <point> <r> <g> <b> [a]",
				"Set the colour for an existing colourscale point" },
	{ "setpointvalue", 	"EEE",		"<scaleid> <point> <value>",
				"Set the value for an existing colourscale point" },

	// Disordered Builder Commands
	{ "disorder",		"E",		"<nsteps>",
				"Run the disordered builder" },
	{ "listcomponents",	"",		"",
				"Print a list of the components requested in the disordered builder" },
	{ "nmols",		"E",		"<n>",
				"Set the number of molecules required for the component" },
	{ "region",		"NEEEEEEN",	"<shape> <cx> <cy> <cz> <x> <y> <z> yes|no",
				"Set the shape, centre, size, and overlap flag of the region for the current model" },
	{ "regioncentre",	"EEE",		"<x> <y> <z>",
				"Set the region centre of the current model" },
	{ "regioncentref",	"EEE",		"<x> <y> <z>",
				"Set the region centre of the current model (fractional coordinates)" },
	{ "regionf",		"NEEEEEEN",	"<shape> <cx> <cy> <cz> <x> <y> <z> yes|no",
				"Set the shape, centre, size, and overlap flag of the region for the current model (fractional coordinates)" },
	{ "regiongeometry",	"EEEe",		"<x> <y> <z> [l]",
				"Set the region geometry of the current model" },
	{ "regiongeometryf",	"EEEe",		"<x> <y> <z> [l]",
				"Set the region geometry of the current model (fractional coordinates)" },
	{ "regionoverlap",	"N",		"yes|no",
				"Set the overlap flag of the current model" },
	{ "regionshape",	"N",		"<shape>",
				"Set the region shape of the current model" },
	{ "vdwscale",		"E",		"<scale>",
				"Set the VDW scaling factor to use in the disordered builder" },

	// Edit commands
	{ "copy",		"",		"",
				"Copy selected atoms" },
	{ "cut",		"",		"",
				"Cut the selected atoms" },
	{ "delete",		"",		"",
				"Delete selected atoms" },
	{ "paste",		"eee",		"[dx] [dy] [dz]",
				"Paste previously-cut or copied atoms to the model (with optional shift from original position" },
	{ "redo",		"",		"",
				"Redo last change" },
	{ "undo",		"",		"",
				"Undo last change" },

	// Energy commands
	{ "frameenergy",	"",		"",
				"Calculate the energy of the current trajectory frame" },
	{ "modelenergy",	"",		"",
				"Calculate the energy of the current model" },
	{ "printelec",		"",		"",
				"Print the electrostatic pattern matrix of the last calculated energy" },
	{ "printewald",		"",		"",
				"Print the Ewald decomposition of the last calculated energy" },
	{ "printinter",		"",		"",
				"Print the total intermolecular pattern matrix of the last calculated energy" },
	{ "printintra",		"",		"",
				"Print the total intramolecular pattern matrix of the last calculated energy" },
	{ "printenergy",	"",		"",
				"Print a short description of the last calculated energy" },
	{ "printsummary",	"",		"",
				"Print a one-line summary of the last calculated energy" },
	{ "printvdw",		"",		"",
				"Print the EDW pattern matrix of the last calculated energy" },

	// Flow control
	{ "break",		"",		"",
				"Exit from the current for loop" },
	{ "continue",		"",		"",
				"Skip to the next iteration of the current loop" },
	{ "else",		"",		"",
				"Perform the subsequent block if all previous if/elseif tests failed" },
	{ "elseif",		"ESE",		"<variable> <condition> <variable|constant>",
				"Perform a conditional test on the supplied variable against the second variable (or constant), if all previous tests failed" },
	{ "end",		"",		"",
				"End the current for/if block" },
	{ "for",		"Vee",		"<variable> [start] [end]",
				"" },
	{ "_GOTO_",		"",		"",
				"" },
	{ "_GOTONONIF_",	"",		"",
				"" },
	{ "if",			"ESE",		"<expression> <condition> <expression>",
				"Perform a conditional test between the supplied expressions (or variables or constants)" },
	{ "_TERMINATE_",	"",		"",
				"" },
	
	// Force commands
	{ "frameforces",	"",		"",
				"Calculate forces for the current trajectory frame" },
	{ "modelforces",	"",		"",
				"Calculate forces for the current model" },
	{ "printforces",	"",		"",
				"Print calculated forces for the current model" },
	
	// Forcefield commands
	{ "angledef",		"NNNNEeeeee", "<form> <name1> <name2> <name3> <data1> [data2 ... data6]",
				"Add an angle definition to the current forcefield." },
	{ "bonddef",		"NNNEeeeee", "<form> <name1> <name2> <data1> [data2 ... data6]",
				"Add a bond definition to the current forcefield." },
	{ "clearmap",		"",		"",
				"Clear manual type mapping list." },
	{ "createexpression",	"",		"",
				"Create and fill a forcefield expression for the current model" },
	{ "defaultff",		"N",		"<ff>",
				"Make named forcefield the default for occasions where no other is specified." },
	{ "equivalents",	"NN",		"<name> <'names...'>",
				"Define forcefield equivalents" },
	{ "ffmodel",		"n",		"[name]",
				"Associate current (or named) forcefield to current model" },
	{ "ffpattern",		"",		"",
				"Associate current forcefield to current pattern" },
	{ "ffpatternid",	"E",		"<patternid>",
				"Associate current forcefield to specified pattern ID" },
	{ "finaliseff",		"",		"",
				"Finalise current forcefield." },
	{ "genconvert",		"E*",		"<data1> [data2..data10]",
				"Set energetic generator data to convert" },
	{ "generator",		"EEeeeeeeeee",	"<typeId> <data1> [data2...data10]",
				"Set generator data for specified atom type" },
	{ "getff",		"N",		"<name>",
				"Select named (loaded) forcefield and make it current" },
	{ "loadff",		"Nn",		"<filename> [name]",
				"Load forcefield" },
	{ "map",		"N",		"<name=element,...>",
				"Add typename mappings" },
	{ "newff",		"N",		"<name>",
				"Create a new, empty forcefield." },
	{ "printsetup",		"",		"",
				"Print the current energy/force calculation setup" },
	{ "rules",		"N",		"<rules set>",
				"Set rules set to use for parameter generation" },
	{ "saveexpression",	"NN",		"<format> <filename>",
				"Save the expression for the current model" },
	{ "torsiondef",		"NNNNNEeeeee", "<form> <name1> <name2> <name3> <name4> <data1> [data2 ... data6]",
				"Add a torsion definition to the current forcefield." },
	{ "typedef",		"ENNNn", "<typeid> <name> <element> <type> [description]",
				"Add an atom type to the current forcefield." },
	{ "typemodel",		"",		"",
				"Perform atom typing on the current model" },
	{ "typetest",		"EE",		"<ffid> <atomid>",
				"Test atomtype score on atom provided" },
	{ "units",		"N",		"<energy unit>",
				"Set energy unit of forcefield" },
	{ "vdwdef",		"NEEEeeeee", "<form> <typeid> <charge> <data1> [data2...data6]",
				"Add a new EDW definition to the current forcefield." },

	// Glyph commands
	{ "autoellipsoids",	"n*",		"[options]",
				"Automatically add ellipsoids to the current atom selection" },
	{ "autopolyhedra",	"n*",		"[options]",
				"Automatically add polyhedra to the current atom selection" },
	{ "glyphatomf",		"Ee",		"<n> [atom|atomid]",
				"Set current (or specified) atom's forces as data <n> in current glyph" },
	{ "glyphatomr",		"Ee",		"<n> [atom|atomid]",
				"Set current (or specified) atom's coordinates as data <n> in current glyph" },
	{ "glyphatomv",		"Ee",		"<n> [atom|atomid]",
				"Set current (or specified) atom's velocities data <n> in current glyph" },
	{ "glyphatomsf",	"Eeee",		"<atom|atomid> [atom|atomid] [atom|atomid] [atom|atomid]",
				"Set all atom forces data in current glyph" },
	{ "glyphatomsr",	"Eeee",		"<atom|atomid> [atom|atomid] [atom|atomid] [atom|atomid]",
				"Set all atom coordinates data in current glyph" },
	{ "glyphatomsv",	"Eeee",		"<atom|atomid> [atom|atomid] [atom|atomid] [atom|atomid]",
				"Set all atom velocities data in current glyph" },
	{ "glyphcolour",	"EEEEe",	"<n> <r> <g> <b> [a]",
				"Set colour data <n> in current glyph" },
	{ "glyphdata",		"EEee",		"<n> <x> <y> <z>",
				"Set vector data <n> in current glyph" },
	{ "glyphsolid",		"N",		"<true|false>",
				"Set the glyph to be drawn in solid (true) or wireframe (false) modes (glyph-permitting)" },
	{ "glyphtext",		"N",		"<text>",
				"Set text data in current glyph" },
	{ "newglyph",		"Nn",		"<style> [options]",
				"Add a glyph with the specified style to the current model" },

	// Grid commands
	{ "addgridpoint",	"EEEE",		"<ix> <iy> <iz> <value>",
				"Set specific gridpoint value" },
	{ "addnextgridpoint",	"E",		"<value>",
				"Add next gridpoint value" },
	{ "finalisegrid",	"",		"",
				"Finalise grid import" },
	{ "getgrid",		"EV",		"<id> <variable>",
				"Retrieve data for grid with id specified, placing in variable supplied" },
	{ "gridaxes",		"EEEEEEEEE",	"<ax> <ay> <az> <bx> <by> <bz> <cx> <cy> <cz>",
				"Set axes for current grid" },
	{ "gridcolour",		"EEEe",		"<r> <g> <b> [a]",
				"Set the (positive) colour of the surface (when not using a colourscale)" },
	{ "gridcolournegative",	"EEEe",		"<r> <g> <b> [a]",
				"Set the negative colour of the surface (when not using a colourscale)" },
	{ "gridcolourscale",	"E",		"<scaleID>",
				"Links the surface to the specified colour scale (or zero to return to internal colour)" },
	{ "gridcubic",		"E",		"<l>",
				"Set the axes system for the current grid to be cubic" },
	{ "gridcutoff",		"E",		"<cutoff>",
				"Set the cutoff for the current grid" },
	{ "gridlooporder",	"N",		"<xyz|zyx|213...>",
				"Set the loop ordering to use in 'addnextgridpoint'" },
	{ "gridorigin",		"EEE",		"<x> <y> <z>",
				"Set the origin of the axes system for the current grid" },
	{ "gridortho",		"EEE",		"<a> <b> <c>",
				"Set the axes system for the current grid to be orthorhombic" },
	{ "gridsize",		"EEE",		"<nx> <ny> <nz>",
				"Set the number of points along each axis for the current grid" },
	{ "gridstyle",		"N",		"<style>",
				"Set the drawing style of the current grid" },
	{ "gridsymmetric",	"N",		"yes|no",
				"Set whether the isodata is symmetric about zero (i.e. whether to draw both halves)" },
	{ "gridtransparency",	"E",		"<alpha>",
				"Set the transparency of the surface (when not using a colourscale)" },
	{ "gridusez",		"N",		"yes|no",
				"Whether a 2D surface uses the vertex data value as its z (height) data" },
	{ "loadgrid",		"N",		"<gridfile>",
				"Load grid data" },
	{ "newgrid",		"N",		"<title>",
				"Create new grid data" },

	// Image commands
	{ "savebitmap",		"NNnn",		"<format> <filename> [width] [height]",
				"Save the current model view as a bitmap image: formats available are bmp, jpg, png, ppm, xbm, and xpm" },
	{ "savevector",		"NN",		"<format> <filename>",
				"Save the current model view as a vector image: formats available are ps, eps, tex, pdf, svg, and pgf" },
	
	// Labeling commands
	{ "clearlabels",	"",		"",
				"Remove all atom labels in the current model" },
	{ "label",		"N",		"<label>",
				"Add labels to the current atom selection" },
	{ "removelabel",	"N",		"<label>",
				"Remove labels from the current atom selection" },

	// MC commands
	{ "mcaccept",		"NE",		"<movetype> <energy>",
				"Set Monte Carlo move type acceptance energies" },
	{ "mcallow",		"NN",		"<movetype> yes|no",
				"Restrict or allow Monte Carlo move types" },
	{ "mcmaxstep",		"NE",		"<movetype> <step>",
				"Set maximum step sizes for Monte Carlo move types" },
	{ "mcntrials",		"NE",		"<movetype> <ntrials>",
				"Set trial numbers for Monte Carlo move types" },
	{ "printmc",		"",		"",
				"Print current Monte Carlo parameters" },
	
	// Measurements
	{ "clearmeasurements",	"",		"",
				"Clear all measurements in the current model" },
	{ "listmeasurements",	"",		"",
				"List all measurements in the current model" },
	{ "measure",		"EEee",		"<id1> <id2> [id3] [id4]",
				"Make a measurement between the specified atoms" },

	// Messaging
	{ "error",		"G",		"<message>",
				"Raise an error message (causes exit of current command list)" },
	{ "print",		"G",		"<message>",
				"Print a message" },
	{ "verbose",		"G",		"<message>",
				"Print a message when verbose output is enabled" },
	{ "warn",		"G",		"<message>",
				"Raise a warning message (command list will continue)" },
	
	// Minimisation commands
	{ "cgminimise",		"",		"",
				"Run a conjugate gradient minimiser on the current model" },
	{ "converge",		"EE",		"<energy> <forces>",
				"Set energy and RMS force convergence limits for minimisation algorithms" },
	{ "linetol",		"E",		"<tolerance>",
				"Set tolerance of line minimiser" },
	{ "mcminimise",		"E",		"<maxsteps>",
				"Run Monte Carlo minimiser on the current model" },
	{ "sdminimise",		"E",		"<maxsteps>",
				"Run steepest descent minimiser on the current model" },
	{ "simplexminimise",	"",		"",
				"Run the Simplex minimiser on the current model" },
	
	// Model commands
	{ "createatoms",	"",		"",
				"Create enough atoms in the current trajectory frame to match the parent model" },
	{ "finalisemodel",	"",		"",
				"Finalise the current model" },
	{ "getmodel",		"Nm",		"<name> [variable]",
				"Select the named (loaded) model and make it current [and set variables]" },
	{ "info",		"",		"",
				"Print data on the current model" },
	{ "listmodels",		"",		"",
				"List the currently-loaded models" },
	{ "loadmodel",		"Nn",		"<filename> [name]",
				"Load a model from file" },
	{ "loginfo",		"",		"",
				"Print log information for model" },
	{ "modeltemplate",	"",		"",
				"Template the atoms in the current trajectory frame, matching the parent model" },
	{ "newmodel",		"N",		"<name>",
				"Create a new model" },
	{ "nextmodel",		"",		"",
				"Skip to the next loaded model" },
	{ "prevmodel",		"",		"",
				"Skip to the previous loaded model" },
	{ "savemodel",		"NN",		"<format> <filename>",
				"Save the current model to <filename> in the specified model <format>" },
	{ "setname",		"N",		"<name>",
				"Set the name of the current model" },

	// Pattern commands
	{ "clearpatterns",	"",		"",
				"Remove all pattern definitions from the current model" },
	{ "createpatterns",	"",		"",
				"Automatically determine pattern definitions for the current model" },
	{ "getpattern",		"Np",		"<name|id> [variable]",
				"Select the named pattern (or pattern id) and make it current" },
	{ "listpatterns",	"",		"",
				"Print the pattern definition for the current model" },
	{ "newpattern",		"NEE",		"<name> <nmols> <natoms>",	
				"Add a pattern definition to the current model" },

	// Preferences commands
	{ "anglelabel",		"N",		"<text>",
				"Set the units label to use for angles" },
	{ "atomdetail",		"E",		"<n>",
				"Set the quadric detail of atoms" },
	{ "bonddetail",		"E",		"<n>",
				"Set the quadric detail of bonds" },
	{ "colour",		"NEEEe",	"<colour> <r> <g> <b> [a]",
				"Set the specified colour" },
	{ "commonelements",	"N",		"<elements...>",
				"Set the common elements that appear in the Select Element dialog" },
	{ "densityunits",	"N",		"atomsperang|gpercm",
				"Set the unit of density to use" },
	{ "distancelabel",	"N",		"<text>",
				"Set the units label to use for distances" },
	{ "ecut",		"N",		"<cutoff>",
				"Set the electrostatic cutoff distance" },
	{ "elec",		"Neeee",	"<none|coulomb|ewald|ewaldauto> [ <precision> | <alpha> <kx> <ky> <kz> ]",
				"Set the style of electrostatic energy calculation" },
	{ "elementambient",	"NEEE",		"<element> <r> <g> <b>",
				"Set ambient colour of element" },
	{ "elementdiffuse",	"NEEE",		"<element> <r> <g> <b>",
				"Set diffuse colour of element" },
	{ "elementradius",	"NE",		"<element> <radius>",
				"Set effective radius of element" },
	{ "energyunits",	"N",		"j|kj|cal|kcal|ha",
				"Set the unit of energy to use" },
	{ "gl",			"NN",		"<option> <<on|off>>",
				"Turn on/off various OpenGL options: fog, linealias, polyalias, backcull" },
	{ "intra",		"N",		"<<on|off>>",
				"Turn on/off energy and force calculation of intramolecular terms" },
	{ "key",		"NN",		"ctrl|shift|alt <action>",
				"Set the action of modifier keys" },
	{ "labelsize",		"E",		"<pointsize>",
				"Set the integer pointsize for label text" },
	{ "light",		"N",		"<<on|off>>",
				"Turn the spotlight on/off" },
	{ "lightambient",	"EEE",		"<r> <g> <b>",
				"Set the ambient colour component of the spotlight" },
	{ "lightdiffuse",	"EEE",		"<r> <g> <b>",
				"Set the diffuse colour component of the spotlight" },
	{ "lightposition",	"EEE",		"<x> <y> <z>",
				"Set the coordinates of the spotlight" },
	{ "lightspecular",	"EEE",		"<r> <g> <b>",
				"Set the specular colour component of the spotlight" },
	{ "mouse",		"NN",		"left|middle|right|wheel <action>",
				"Set the action of mouse buttons" },
	{ "radius",		"NE",		"<style> <r>",
				"Set the general atom scales for view styles" },
	{ "replicatefold",	"N",		"<on|off>",
				"Set whether to fold atoms before cell replicate" },
	{ "replicatetrim",	"N",		"<on|off>",
				"Set whether to trim atoms after cell replicate" },
	{ "scheme",		"n",		"[colour scheme]",
				"SHow (or set) the atomic colouring scheme to use" },
	{ "shininess",		"E",		"<n>",
				"Set the shininess of atoms" },
	{ "showonscreen",	"nn",		"[object] yes|no",
				"Set (or lists) the visibility of view objects on-screen" },
	{ "showonimage",	"nn",		"<object> yes|no",
				"Set (or lists) the visibility of view objects on saved images" },
	{ "style",		"n",		"[style]",
				"Set (or show) the current model drawing style" },
	{ "usenicetext",	"N",		"<<on|off>>",
				"Use QPainter (on) or QGlWidget (off) to render label text" },
	{ "vcut",		"E",		"<cutoff>",
				"Set the EDW cutoff distance" },
	{ "vdw",		"N",		"<on|off>",
				"Turn on/off EDW energy/force calculation" },

	// Read / Write Commands
	{ "addreadoption",	"N",		"<option>",
				"Add a read option: usequotes, skipblanks, stripbrackets" },
	{ "find",		"NVv",		"<string> <resultvar> [linevar]",
				"Search for a string in the input file" },
	{ "getline",		"C",		"<variable>",
				"Read the next line from the file and place it in the supplied variable" },
	{ "readchars",		"VE",		"<variable> <nchars>",
				"Read a number of characters from the input file" },
	{ "readfloat",		"V",		"<variable>",
				"Read a floating point value from the input file" },
	{ "readint",		"V",		"<variable>",
				"Read an integer value from the input file" },
	{ "readline",		"F",		"<formatting string>",
				"Read and parse a line from the input file" },
	{ "readnext",		"V",		"<variable>",
				"Read the next delimited item from the file" },
	{ "readvar",		"VJ",		"<variable> <formatting string>",
				"Parse a variable according to the supplied format" },
	{ "removereadoption",	"N",		"<option>",
				"Remove a read option" },
	{ "rewind",		"",		"",
				"Rewind to the start of the input file" },
	{ "skipchars",		"E",		"<nchars>",
				"Skip a number of characters in the input file" },
	{ "skipline",		"e",		"[nlines]",
				"Skip a number of lines in the input file" },
	{ "writeline",		"G",		"<formatting string>",
				"Write a line to the output file" },
	{ "writevar",		"VK",		"<variable> <formatting string>",
				"Write a line to the specified variable" },

	// Script commands
	{ "listscripts",	"",		"",
				"List available scripts" },
	{ "loadscript",		"Nn",		"<filename> [nickname]",
				"Load script from file" },
	{ "runscript",		"N",		"<name>",
				"Execute the named script" },

	// Selection commands
	{ "deselect",		"Q*",		"<id|el|id-id|el-el|+id|+el|id+|el+,...>",
				"Deselect specific atoms / ranges in the current model" },
	{ "invert",		"",		"",
				"Invert the current selection" },
	{ "select",		"Q*",		"<id|el|id-id|el-el|+id|+el|id+|el+,...>",
				"Select specific atoms / ranges in the current model" },
	{ "selectall",		"",		"",
				"Select all atoms in the current model" },
	{ "selectfftype",	"N",		"<typename>",
				"Select all atoms of a specific forcefield type" },
	{ "selectnone",		"",		"",
				"Deselect all atoms in the current model" },
	{ "selectoverlaps",	"E",		"<tolerance>",
				"Select all atoms which are within a given distance of each other" },
	{ "selectpattern",	"n",		"[name]",
				"Select all atoms in the current (or named) pattern" },
	{ "selecttype",		"NN",		"<element> <typedesc>",
				"Select all atoms that match the provided atomtype description" },
	
	// Site commands
	{ "getsite",		"N",		"<name>",
				"Select the defined site and make it current" },
	{ "listsites",		"",		"",
				"Print all sites defined for the current model" },
	{ "newsite",		"NNn",		"<name> <pattern> [atomlist]",
				"Adds a new site definition to the current model" },
	{ "siteaxes",		"NN",		"<atomlist> <atomlist>",
				"Set the axis definitions for the current site" },

	// System commands
	{ "debug",		"N",		"<mode>",
				"Toggle debugging for the specified mode" },
	{ "gui",		"",		"",
				"Start the GUI (if it is not already active)" },
	{ "help",		"N",		"<command>",
				"Provide short help on the command supplied" },
	{ "seed",		"E",		"<seed>",
				"Set the random seed" },
	{ "quit",		"",		"",
				"Exit the program" },

	// Trajectory commands
	{ "finaliseframe",	"",		"",
				"Finalise the current trajectory frame" },
	{ "firstframe",		"",		"",
				"Go to the first frame in the current trajectory" },
	{ "lastframe",		"",		"",
				"Go to the last frame in the current trajectory" },
	{ "loadtrajectory",	"N",		"<filename>",
				"Load the specified trajectory and associate it to the current model" },
	{ "nextframe",		"",		"",
				"Go to the next frame in the current trajectory" },
	{ "prevframe",		"",		"",
				"Go to the previous frame in the current trajectory" },
	{ "seekframe",		"E",		"<frame>",
				"Jump to the specified frame in the current trajectory" },
	
	// Transformation commands		// Transformation commands
	{ "centre",		"EEE",		"<x> <y> <z>",
				"Centre the atom selection of the current model at the specified coordinates" },
	{ "translate",		"EEE",		"<dx> <dy> <dz>",
				"Translate the atom selection of the current model" },
	{ "translateatom",	"EEE",		"<dx> <dy> <dz>",
				"Translate the current atom" },
	{ "translatecell",	"EEE",		"<dx> <dy> <dz>",
				"Translate the current selection along the cell axes by the fractional axes specified" },
	{ "mirror",		"N",		"<axis>",
				"Mirror the atom selection of the current model about its geometric centre in the specified axis" },
	
	// Variables
	{ "dec",		"V",		"<variable>",
				"Decrease the specified variable" },
	{ "inc",		"V",		"<variable>",
				"Increase the specified variable" },
	{ "let",		"VOE",		"<variable> [-+/*]= <variable|value|expression>",
				"Set the specified variable" },
	{ "letchar",		"V~N",		"<variable> =|+= <variable|value>",
				"Set the specified character variable" },
	{ "letptr",		"V=V",		"<variable> = <variable>",
				"Set the specified pointer variable" },
	
	// View
	{ "getview",		"",		"",
				"Print the rotation matrix, camera position, and camera z-rotation for the current model" },
	{ "orthographic",	"",		"",
				"Render in an orthographic projection" },
	{ "perspective",	"e",		"[fov]",
				"Render in a perspective projection" },
	{ "resetview",		"",		"",
				"Reset the camera and rotation for the current model" },
	{ "rotateview",		"EE",		"<x> <y>",
				"Rotate the current model about the x and y axes by the specified amounts" },
	{ "setview",		"EEEEEEEEEEEEe","<ax> <ay> <az> <bx> <by> <bz> <cx> <cy> <cz> <camx> <camyu> <camz> [zrot]",
				"Set the rotation matrix, camera position, and camera z-rotation for the current model" },
	{ "speedtest",		"e",		"[nrender]",
				"Time 100 (or 'nrender') updates of the model display." },
	{ "translateview",	"EEE",		"<dx> <dy> <dz>",
				"Translate the camera for the current model" },
	{ "viewalong",		"EEE",		"<x> <y> <z>",
				"Set the rotation for the current model so the view is along the specified vector" },
	{ "viewalongcell",	"EEE",		"<x> <y> <z>",
				"Set the rotation for the current model so the view is along the specified cell vector" },
	{ "zoomview",		"E",		"<dz>",
				"Zoom in/out the camera - equivalent to 'translateview 0 0 dz'" },
	{ "zrotateview",	"E",		"<dr>",
				"Rotate the model in the plane of the screen" }
};

// Return enumerated command from string
Command::Function Command::command(const char *s)
{
	int result;
	for (result = CA_CHAR; result < CA_NITEMS; result++) if (strcmp(data[result].keyword,s) == 0) break;
	return (Command::Function) result;
}

// Constructor
Command::Command()
{
	// Create pointer list
	initPointers();
}

// Return whether command accepts any arguments
bool CommandData::hasArguments()
{
	return (!(arguments[0] == '\0'));
}

// Execute command
int Command::call(Command::Function cf, CommandNode *&c)
{
// 	return CALL_COMMAND(commands,pointers_[cf])(c, aten.current);
	return (this->pointers_[cf])(c, aten.current);
}
