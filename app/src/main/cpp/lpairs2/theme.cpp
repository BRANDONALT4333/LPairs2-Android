/*
 * theme.cpp
 * (C) 2018 by Michael Speck
 */

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include "tools.h"
#include "sdl.h"
#include "mixer.h"
#include "theme.h"
#include "game.h"

extern SDL_Renderer *mrc;

/* Everything is sized relative to screen height which gives ~4% tall menu
 * entries: fine for a mouse, too small for a finger. Scale up on Android:
 * HUD text slightly, menu text and rows more so they are easy to hit. */
#ifdef __ANDROID__
static const double HUD_SCALE  = 1.2;
static const double MENU_SCALE = 1.5;
#else
static const double HUD_SCALE  = 1.0;
static const double MENU_SCALE = 1.0;
#endif

/** Load resources and scale if necessary using bricks screen height.
 * Whatever is missing: Fall back to Standard theme. */
void Theme::load(string name, Renderer &r)
{
	string path, fpath;
	vector<string> fnames;
	Texture cbase, card; /* card front and assembled card */
	Texture pic;
	int dx, dy, dw, dh;

	path = string(DATADIR) + "/themes/" + name;

	if (!fileExists(path))
		_logerr("CRITICAL ERROR: theme %s not found. We continue but most likely it will crash...\n",path.c_str());
	_loginfo("Loading theme %s\n",path.c_str());

	/* load theme.ini */
	relIconSize = 94;
	if (fileExists(path + "/theme.ini")) {
			FileParser fp(path + "/theme.ini");
			fp.get("relIconSize",relIconSize);
	}

	Texture::setRenderScaleQuality(1);

	readDir(path, RD_FILES, fnames);

	/* fonts */
	fSmall.load(testRc(path,"f_normal.otf"), r.ry2sy(0.028 * HUD_SCALE));
	fNormal.load(testRc(path,"f_bold.otf"), r.ry2sy(0.037 * HUD_SCALE));
	fNormalHighlighted.load(testRc(path,"f_bold.otf"), r.ry2sy(0.037 * HUD_SCALE));
	fNormalHighlighted.setColor(255,220,0,255);

	/* base images for cards */
	cardBack.load(testRc(path,"c_back.png"));
	cardFocus.load(testRc(path,"c_focus.png"));
	cbase.load(testRc(path,"c_front.png"));
	cardShadow.createShadow(cbase);

	/* menu */
#ifdef __ANDROID__
	menuX = r.rx2sx(0.19);
	menuY = r.ry2sy(0.55);
	menuItemWidth = r.rx2sx(0.30);
#else
	menuX = r.rx2sx(0.16);
	menuY = r.ry2sy(0.63);
	menuItemWidth = r.rx2sx(0.22);
#endif
	menuItemHeight = r.ry2sy(0.037 * MENU_SCALE);
	menuBackground.load(testRc(path,"menu.png"));
	fMenuNormal.load(testRc(path,"f_normal.otf"), r.ry2sy(0.033 * MENU_SCALE));
	fMenuNormal.setColor({255,255,255,255});
	fMenuFocus.load(testRc(path,"f_bold.otf"), r.ry2sy(0.037 * MENU_SCALE));
	fMenuFocus.setColor({255,220,0,255});

	/* sounds */
	sClick.load(testRc(path,"s_click.wav"));
	sRemove.load(testRc(path,"s_remove.wav"));
	sFail.load(testRc(path,"s_fail.wav"));
	sMenuClick.load(testRc(path,"s_menuclick.wav"));
	sMenuMotion.load(testRc(path,"s_menumotion.wav"));

	readDir(path + "/backgrounds", RD_FILES, fnames);

	/* load wallpapers */
	numWallpapers = 0;
	for (uint i = 0; i < fnames.size(); i++) {
		if (fnames[i][0] == '.')
			continue;
		wallpapers[numWallpapers].load(path + "/backgrounds/" + fnames[i]);
		wallpapers[numWallpapers].setBlendMode(0);
		numWallpapers++;
		if (numWallpapers == MAXWALLPAPERS)
			break;
	}
	if (numWallpapers == 0) {
		wallpapers[0].load(stdPath + "/backgrounds/metal.jpg");
		wallpapers[0].setBlendMode(0);
		numWallpapers = 1;
	}

	readDir(path + "/motifs", RD_FILES, fnames);

	/* motifs - no fallback this has to be present */
	numMotifs = 0;
	for (uint i = 0; i < fnames.size(); i++) {
		if (fnames[i][0] == '.')
			continue;
		_logdebug(1,"  Building %s\n",fnames[i].c_str());
		pic.load(path + "/motifs/" + fnames[i]);
		card.duplicate(cbase);
		card.setBlendMode(1);
		r.setTarget(card);
		if (pic.getWidth() > pic.getHeight()) {
			dw = relIconSize * cbase.getWidth() / 100;
			dh = dw * pic.getHeight() / pic.getWidth();
		} else {
			dh = relIconSize * cbase.getHeight() / 100;
			dw = dh * pic.getWidth() / pic.getHeight();
		}
		dx = (cbase.getWidth() - dw) / 2;
		dy = (cbase.getHeight() - dh) / 2;
		pic.copy(dx,dy,dw,dh);
		r.clearTarget();
		motifs[numMotifs].set(card,fnames[i],fSmall);
		numMotifs++;
		if (numMotifs == MAXMOTIFS)
			break;
	}

}
