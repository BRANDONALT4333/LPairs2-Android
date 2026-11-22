# LPairs2 for Android

Android port of LPairs2 2.3.2 (Michael Speck, GPLv3). It keeps the original
C++/SDL2 game code and wraps it in an Android Gradle project, so gameplay is
identical to the desktop version.

> **Status:** first on-device test: game, audio and graphics work; card icons were corrupt (progressive JPEGs vs. the stb_image decoder) and were fixed by converting the motifs to baseline JPEG (`ASSET_REV` -android2). The original text below predates that test.
>
> **Original status: not yet built or run.** The port was prepared in a sandbox with no
> Android SDK/NDK and no access to Google/Maven/GitHub, so no APK has been
> produced. The new C++ (asset extraction) was syntax-checked against stubs; the
> rest is unbuilt. Expect to fix a small build problem or two on first build
> (see Troubleshooting).

## Build

Needs: Android Studio (or the command-line SDK) with **NDK** and **CMake 3.22.1**
installed from SDK Manager, JDK 17, internet for the first build.

    ./setup_sdl.sh          # downloads SDL2, SDL2_image, SDL2_ttf, SDL2_mixer into third_party/
    echo "sdk.dir=$HOME/Android/Sdk" > local.properties   # or open the folder in Android Studio
    ./gradlew assembleDebug
    # -> app/build/outputs/apk/debug/app-debug.apk
    adb install -r app/build/outputs/apk/debug/app-debug.apk

Debug logs: `adb logcat -s lpairs2 SDL`.

## What changed from the desktop game

| Area | Change |
|---|---|
| Files | Theme assets ship in the APK and are copied to app-private storage on first launch (`androidDataDir()` in `tools.cpp`); the game's plain `fopen/opendir` code then works unchanged. Re-copied when `ASSET_REV` changes. |
| Config | Stored in app-private storage. Upstream never called `Config::save()`; the port saves on quit and when the app goes to background. |
| Back button | In a sub-menu: up one level. In game: open/close menu. At the start screen: exit. |
| Restart | Tap anywhere when the game is over (replaces right-click / R). |
| Menu taps | A tapped item now takes focus itself (touch has no hover event, and the main loop discards motion events). |
| Touch sizing | HUD text x1.2, menu text and rows x1.5, menu widened; see `theme.cpp`. |
| Window mode | Removed (always fullscreen, landscape). |
| Captions | Default Off (the "On Shift" mode needs a keyboard); choose "Always" in New Game. |
| Hover highlight | Disabled (it would stick to the last tap). |
| Memory | `Texture::createShadow` used a ~775 KB stack array; now a `std::vector`. |
| Images | The bundled progressive JPEGs (all card motifs, metal.jpg) were re-saved as baseline JPEG; the stb_image decoder used by the build rendered them corrupt. |
| Logging | Goes to logcat. |
| Translations | Not included (no gettext on Android); UI is English. |

Original source is otherwise untouched; patches are marked with `#ifdef __ANDROID__`.

## Layout

    app/src/main/cpp/lpairs2/   game sources (patched)       app/src/main/cpp/CMakeLists.txt   builds SDL2 family + game
    app/src/main/assets/        themes + manifest.txt        app/src/main/java/.../LPairs2Activity.java
    setup_sdl.sh                fetches SDL sources          (SDL's own Java glue is compiled from third_party/)

If you add or remove theme files, regenerate the list:
`cd app/src/main/assets && find themes -type f | sort > manifest.txt` and bump `ASSET_REV` in `tools.cpp`.

## Troubleshooting

* `setup_sdl.sh` 404: version tags are pinned at the top of the script; pick existing ones from the libsdl-org release pages.
* CMake option errors in SDL2_image/ttf/mixer: option names are in `CMakeLists.txt`; they differ slightly between releases.
* Menu feels cramped on small phones: tune `HUD_SCALE` / `MENU_SCALE` in `theme.cpp`.
* Not handled: recovering GPU textures if the OS destroys the GL context while backgrounded (rare on modern devices; a restart fixes it).
* Release builds need your own signing config; the debug APK installs as is.

License: GPLv3 (see COPYING), same as upstream.
