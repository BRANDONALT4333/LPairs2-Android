#!/usr/bin/env bash
# Download the last SDL2 generation that supports Android API 17.
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p third_party
fetch() {
  local repo="$1" name="$2" version="$3"
  local dir="third_party/$name"
  if [ -f "$dir/Android.mk" ] || [ -f "$dir/CMakeLists.txt" ]; then
    echo "$name already present; skipping"
    return
  fi
  local archive="$name-$version.tar.gz"
  local url="https://github.com/libsdl-org/$repo/releases/download/release-$version/$archive"
  echo "Downloading $url"
  curl -fL --retry 3 "$url" -o "third_party/$archive"
  tar -xzf "third_party/$archive" -C third_party
  mv "third_party/$name-$version" "$dir"
  rm "third_party/$archive"
}

fetch SDL SDL2 2.0.7
fetch SDL_image SDL2_image 2.0.2
fetch SDL_ttf SDL2_ttf 2.0.14
fetch SDL_mixer SDL2_mixer 2.0.2

SDL_ACTIVITY="third_party/SDL2/android-project/src/org/libsdl/app/SDLActivity.java"
python3 - "$SDL_ACTIVITY" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
s = s.replace("import java.util.Objects;\n", "")
s = s.replace('if (!Objects.equals(hint, "")) {', 'if (hint == null || !hint.equals("")) {')
p.write_text(s)
PY

echo "Legacy SDL sources are ready."
