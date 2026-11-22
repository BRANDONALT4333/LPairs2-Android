#!/usr/bin/env bash
# Fetch the SDL2 family sources into third_party/ (needed once, needs internet).
set -euo pipefail
cd "$(dirname "$0")"

SDL2_VER=2.32.10
IMAGE_VER=2.8.8
TTF_VER=2.24.0
MIXER_VER=2.8.1

fetch() {  # name version repo
  local name=$1 ver=$2 repo=$3
  if [ -f "third_party/$name/CMakeLists.txt" ]; then
    echo "$name already present, skipping"; return
  fi
  local url="https://github.com/libsdl-org/$repo/releases/download/release-$ver/$name-$ver.tar.gz"
  echo "Fetching $url"
  mkdir -p third_party
  curl -fL --retry 3 -o "third_party/$name.tar.gz" "$url" \
    || { echo "Download failed. Check the version/tag at https://github.com/libsdl-org/$repo/releases"; exit 1; }
  tar -xzf "third_party/$name.tar.gz" -C third_party
  mv "third_party/$name-$ver" "third_party/$name"
  rm "third_party/$name.tar.gz"
}

fetch SDL2        "$SDL2_VER"  SDL
fetch SDL2_image  "$IMAGE_VER" SDL_image
fetch SDL2_ttf    "$TTF_VER"   SDL_ttf
fetch SDL2_mixer  "$MIXER_VER" SDL_mixer
echo "Done. Now run: ./gradlew assembleDebug"
