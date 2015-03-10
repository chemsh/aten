/*
	*** Viewer - Main scene render function
	*** src/gui/viewer_scene.cpp
	Copyright T. Youngs 2007-2015

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

#include "gui/viewer.uih"
#include "render/glextensions.h"
#include "main/aten.h"
#include "base/sysfunc.h"

// Setup OpenGL ready for drawing
void Viewer::setupGL()
{
	Messenger::enter("Viewer::setupGL");

	// Clear colour
	GLfloat col[4];
	prefs.copyColour(Prefs::BackgroundColour, col);
	glClearColor(col[0],col[1],col[2],col[3]);
// 	glClearDepth(1.0);
// 	glColorMask(GL_TRUE,GL_TRUE,GL_TRUE,GL_TRUE);
// 	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// Perspective hint
	glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_FASTEST);

	// Enable depth buffer
	glEnable(GL_DEPTH_TEST);

	// Smooth shading
	glShadeModel(GL_SMOOTH);

	// Auto-calculate surface normals
	glEnable(GL_NORMALIZE);

	// Set alpha-blending function
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	//glBlendFunc(GL_SRC_ALPHA_SATURATE, GL_ONE);

	// Set up the light model
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glEnable(GL_LIGHTING);
	prefs.copySpotlightColour(Prefs::AmbientComponent, col);
	glLightfv(GL_LIGHT0, GL_AMBIENT, col);
	prefs.copySpotlightColour(Prefs::DiffuseComponent, col);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, col);
	prefs.copySpotlightColour(Prefs::SpecularComponent, col);
	glLightfv(GL_LIGHT0, GL_SPECULAR, col);
	prefs.copySpotlightPosition(col);
	glLightfv(GL_LIGHT0, GL_POSITION, col);
	prefs.spotlightActive() ? glEnable(GL_LIGHT0) : glDisable(GL_LIGHT0);

	// Set specular reflection colour
	prefs.copyColour(Prefs::SpecularColour, col);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, col);
	glMateriali(GL_FRONT_AND_BACK, GL_SHININESS, prefs.shininess());
	glDisable(GL_BLEND);
	glDisable(GL_LINE_SMOOTH);
	glDisable(GL_POLYGON_SMOOTH);
	glDisable(GL_MULTISAMPLE);

	// Configure antialiasing
	if (prefs.multiSampling()) glEnable(GL_MULTISAMPLE);
	if (prefs.lineAliasing())
	{
		glEnable(GL_BLEND);
		glHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
		glEnable(GL_LINE_SMOOTH);
	}
	if (prefs.polygonAliasing())
	{
		glEnable(GL_BLEND);
		glHint(GL_POLYGON_SMOOTH_HINT,GL_NICEST);
		glEnable(GL_POLYGON_SMOOTH);
	}
	// Configure fog effects
	if (prefs.depthCue())
	{
		glFogi(GL_FOG_MODE, GL_LINEAR);
		prefs.copyColour(Prefs::BackgroundColour, col);
		glFogfv(GL_FOG_COLOR, col);
		glFogf(GL_FOG_DENSITY, 0.35f);
		glHint(GL_FOG_HINT, GL_NICEST);
		glFogi(GL_FOG_START, prefs.depthNear());
		glFogi(GL_FOG_END, prefs.depthFar());
		glEnable(GL_FOG);
	}
	else glDisable(GL_FOG);

	// Configure face culling
	glCullFace(GL_BACK);
	prefs.backfaceCulling() ? glEnable(GL_CULL_FACE) : glDisable(GL_CULL_FACE);

	Messenger::exit("Viewer::setupGL");
}

// Perform main rendering
void Viewer::renderScene(const GLExtensions* extensions)
{
	Messenger::enter("Viewer::renderScene");
	QColor color;
	QRect currentBox;
	Refitem<Model,int>* first, localri;
	int px, py, nperrow = prefs.nModelsPerRow(), nRows, col, row, nModels;
	bool modelIsCurrentModel;
	Model* m;

	// Before we do anything else, make sure primitives are up-to-date
	updatePrimitives(primitiveSet_);

	// Make sure all models are up-to-date (after making list...) ATEN2 TODO

	// Set the first item to consider - set localri to the passed iconSource (if there was one)
// 	localri.item = NULL;	// ATEN2 TODO
	nModels = aten_->nVisibleModels();
	first = aten_->visibleModels();

	// Clear view
	glViewport(0, 0, contextWidth_, contextHeight_);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// Reset local renderGroup_
	renderGroup_.clear();

	// Set up some useful values
	nRows = nModels / nperrow + ( nModels %nperrow == 0 ? 0 : 1);
	py = contextHeight_ / nRows;
	px = ( nModels == 1 ? contextWidth_ : contextWidth_ / nperrow);

	// Loop over model refitems in list (or single refitem)
	col = 0;
	row = 0;
	for (Refitem<Model,int>* ri = first; ri != NULL; ri = ri->next)
	{
		// Grab model pointer
		m = ri->item;
		if (m == NULL) continue;

		// Render the whole model
		renderModel(m, col*px, contextHeight_-(row+1)*py, px, py);

		// Render additional data for active model
		if (m == aten_->currentModel())
		{
			// Render embellishments for current UserAction
			renderUserActions(m);

			// Render extras arising from open tool windows (current model only)
	// 		renderWindowExtras(source);	// ATEN2 TODO
		}

		// Render overlays
	// 	renderModelOverlays(source); // ATEN2 TODO Text labels!


		// Increase counters
		++col;
		if (col%nperrow == 0)
		{
			col = 0;
			++row;
		}
	}
	
	// Start of QPainter code
	QBrush nobrush(Qt::NoBrush), solidbrush(Qt::SolidPattern);
	QPen pen;
	QPainter painter(this);

	// Draw box around current model
	color.setRgbF(0.0,0.0,0.0,1.0);
	pen.setColor(color);
	pen.setWidth(2);
	painter.setBrush(nobrush);
	painter.setPen(Qt::SolidLine);
	painter.setPen(pen);

	if (prefs.frameCurrentModel()) painter.drawRect(currentBox);
	if (prefs.frameWholeView())
	{
		currentBox.setRect(0, 0, contextWidth_, contextHeight_);
		painter.drawRect(currentBox);
	}

	// Render active user modes
// 	if (renderType == OnscreenScene) renderActiveModes(painter, width, height);  ATEN2 TODO

	// Done
	painter.end();

	Messenger::exit("Viewer::renderScene");
}

// Update all primitives (following prefs change, etc.)
void Viewer::updatePrimitives(Viewer::PrimitiveQuality targetQuality)
{
	// Set (possibly new) quality
	int quality = (targetQuality == Viewer::LowQuality ? prefs.primitiveQuality() : prefs.imagePrimitiveQuality());
	primitives_[targetQuality].setQuality(quality);

	// Recalculate adjustments in PrimitiveSets
	primitives_[targetQuality].calculateAdjustments();

	// Grab topmost GLExtensions object
	GLExtensions* extensions = extensionsStack_.last();
	if (extensions == NULL)
	{
		Messenger::print("Internal Error: No GLEXtensions object on stack in Viewer::updatePrimitives().\n");
		return;
	}

	// Pop and push a context
	primitives_[targetQuality].recreatePrimitives();

	if (primitives_[targetQuality].nInstances() != 0) primitives_[targetQuality].popInstance(context(), extensions);
	primitives_[targetQuality].pushInstance(context(), extensions);
}