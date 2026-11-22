package org.lgames.lpairs2;

import org.libsdl.app.SDLActivity;

/** Thin launcher: SDLActivity (from the SDL2 sources in third_party/) does the work. */
public class LPairs2Activity extends SDLActivity {
    @Override
    protected String[] getLibraries() {
        return new String[] { "SDL2", "SDL2_image", "SDL2_ttf", "SDL2_mixer", "main" };
    }
}
