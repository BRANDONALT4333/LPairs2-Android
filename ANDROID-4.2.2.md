# LPairs2 Android 4.2.2 legacy port

This branch targets the Samsung Galaxy Tab 2 10.1 (GT-P5113) and other
32-bit ARM devices running Android 4.2.2 (API 17).

## Why this is a separate build

The modern Android port uses a newer SDL2 stack that requires Android API 19
or later. This branch uses the older SDL 2.0.7 Android build system, which
supports API 17. The modern `main` branch is intentionally left unchanged.

## Legacy dependency set

- SDL 2.0.7
- SDL_image 2.0.2
- SDL_ttf 2.0.14
- SDL_mixer 2.0.2

The game uses JPEG/PNG images and WAV sound effects, so optional WebP and
music-codec backends are disabled in the Android NDK build.

## Build

The legacy build requires Java 8, Android SDK platform 28, Build Tools 28.0.3,
and Android NDK r15c (15.2.4203891). The native target is API 17 and ABI
`armeabi-v7a`.

Run:

```sh
./setup_sdl_legacy.sh
./gradlew clean assembleDebug
```

GitHub Actions builds the same debug APK and publishes it as the
`lpairs2-android-4.2.2-armv7-debug` workflow artifact.

## Status

This is an in-progress compatibility port. A successful CI build is not the
same as device validation. The APK must still be installed and tested on a
physical GT-P5113 running official Android 4.2.2 before it is described as
working on that device.
