# LPairs2 for Android (unofficial port)

An unofficial Android port of **LPairs2**, a classic memory (pairs) game with animal pictures, originally written for Linux by Michael Speck. The game itself is unchanged: same rules, same modes, same sounds and artwork. This project wraps the original C++/SDL2 code in an Android app and adjusts it for touch screens.

> This is not an official release and is not affiliated with or endorsed by the original author.

## Features (from the original game)

- Classic pairs, plus triplets and quadruplets for a harder game
- Play against a CPU opponent, or against another human on the same device
- Survivor mode: start at 4x4 cards, with sets that grow up to 10x7
- Adjustable set size, card close delay and animations

## What is different on Android

| Area | Change |
|---|---|
| Controls | Tap to flip cards. Tap anywhere to restart a finished game. |
| Back button | In a sub-menu: up one level. In a game: open or close the menu. On the start screen: exit. |
| Menus | Larger text and rows for touch; a tapped item always takes focus (touch has no hover). |
| Display | Fullscreen, landscape. There is no window mode. |
| Captions | Off by default (the original "On Shift" mode needs a keyboard). Choose "Always" under New Game. |
| Settings | Saved when you quit or leave the app (the desktop version never saved them). |
| Images | The progressive JPEG images (all card pictures and the metal background) were re-saved as baseline JPEG, because the image decoder used in this build displayed them corrupted. No visible difference. |
| Memory | A large stack buffer in the card-shadow code was replaced with heap memory. |
| Languages | Translations are not included; the interface is English only. |

All source changes are marked with `#ifdef __ANDROID__`, so they are easy to find.

## Status

All game modes have been played through and work on every device below. Game, sound and graphics are fine.

| Device | Android | CPU |
|---|---|---|
| Chromebook (Intel Celeron N4500) | ChromeOS Android runtime | x86_64 |
| Samsung Galaxy S25 Ultra | 17 | ARM64 |
| Google Pixel 4a | not recorded | ARM64 |
| Samsung Galaxy S21 | not recorded | ARM64 |

This is a small test group, so other devices may behave differently. If you find a problem, please open an issue and include your device model and Android version. The APK is built for `arm64-v8a`, `armeabi-v7a` and `x86_64`; the 32-bit ARM build (`armeabi-v7a`) has not been tested on a real device.

## Building

Requirements: Android SDK platform 35, build-tools 35.0.0, NDK 27.2.12479018, CMake 3.22.1, JDK 17 or newer, about 5 GB of free disk space, and an internet connection for the first build.

```
./setup_sdl.sh                                         # downloads the SDL2 family sources into third_party/
echo "sdk.dir=$HOME/Android/Sdk" > local.properties    # path to your Android SDK
./gradlew assembleDebug
```

The APK is written to `app/build/outputs/apk/debug/app-debug.apk`. Install it with `adb install -r <apk>`. Logs: `adb logcat -s lpairs2 SDL`.

`setup_sdl.sh` downloads these libraries (versions are set at the top of the script): SDL2 2.32.10, SDL2_image 2.8.8, SDL2_ttf 2.24.0 and SDL2_mixer 2.8.1.

More technical notes are in `README-ANDROID.md`.

## Project layout

```
app/src/main/cpp/lpairs2/      game source (original code with Android patches)
app/src/main/cpp/CMakeLists.txt  builds SDL2 + the game
app/src/main/assets/themes/    the default theme (images, fonts, sounds) and manifest.txt
setup_sdl.sh                   fetches the SDL sources
```

If you add or remove theme files, regenerate `app/src/main/assets/manifest.txt` and bump `ASSET_REV` in `tools.cpp`, otherwise installed copies keep their old files.

## License

The game code is licensed under the **GNU General Public License, version 3 or later**, the same as the original LPairs2. See `COPYING`. The complete corresponding source of this port is this repository.

The artwork, fonts and sounds come from several sources under different licenses. **Their attribution is in `app/src/main/assets/themes/Standard/CREDITS`; please keep that file with any redistribution.** In summary:

- Fonts: Source Sans Pro, SIL Open Font License
- Backgrounds: public domain
- Animal pictures: from Wikipedia and its contributors, under CC-BY, CC-BY-SA, GFDL and public-domain terms, as listed per image in `CREDITS`
- Card images and sounds: public domain

The picture files in this repository were re-encoded as baseline JPEG (see "What is different"); the image content was not edited.

## Credits

- **Michael Speck** - author of LPairs2 and the LGames project, whose open-source release made this port possible
- **Photographers and artists** listed in `CREDITS`
- **[YOUR NAME]** - idea, building, and device testing
- **Simurated** - playtesting
- **Claude (Anthropic)** - wrote the Android port of the code and project setup
- **ChatGPT (OpenAI)** - helped produce the APK build

Parts of the code and documentation in this port were written with AI assistance.

## Links

- Original LPairs2 / LGames: https://lgames.sourceforge.io/ (check for the current upstream location)
- This port: [YOUR REPOSITORY URL]
