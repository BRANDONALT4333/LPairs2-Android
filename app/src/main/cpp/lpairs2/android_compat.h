/*
 * android_compat.h - Android port helpers for LPairs2.
 *
 * Desktop LPairs2 reads its theme from DATADIR with plain stdio/dirent
 * calls and keeps its config in $HOME. Neither works on Android (assets
 * live inside the APK, there is no $HOME), so on Android:
 *   - DATADIR  = a writable copy of the APK assets in app-private storage
 *   - CONFIGDIR = app-private config directory
 * The asset copy is made on first launch (and again after an update).
 */
#ifndef ANDROID_COMPAT_H_
#define ANDROID_COMPAT_H_

#ifdef __ANDROID__
#include <string>

const std::string &androidDataDir();   /* extracts assets on first use */
const std::string &androidConfigDir();

#define DATADIR   (androidDataDir().c_str())
#define CONFIGDIR (androidConfigDir().c_str())
#endif

#endif /* ANDROID_COMPAT_H_ */
