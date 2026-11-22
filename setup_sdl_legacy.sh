#!/usr/bin/env bash
# Download SDL versions compatible with the Android API 17 legacy port.
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p third_party

fetch() {
  local base_url="$1" archive="$2" extracted="$3" dest="$4"
  local dir="third_party/$dest"
  if [ -f "$dir/Android.mk" ] || [ -f "$dir/CMakeLists.txt" ]; then
    echo "$dest already present; skipping"
    return
  fi

  echo "Downloading $base_url/$archive"
  curl -fL --retry 3 "$base_url/$archive" -o "third_party/$archive"
  tar -xzf "third_party/$archive" -C third_party
  mv "third_party/$extracted" "$dir"
  rm "third_party/$archive"
}

# Use the maintained SDL release archive rather than retired GitHub release assets.
fetch "https://www.libsdl.org/release" "SDL2-2.0.7.tar.gz" "SDL2-2.0.7" "SDL2"
fetch "https://www.libsdl.org/projects/SDL_image/release" "SDL2_image-2.0.2.tar.gz" "SDL2_image-2.0.2" "SDL2_image"
fetch "https://www.libsdl.org/projects/SDL_ttf/release" "SDL2_ttf-2.0.14.tar.gz" "SDL2_ttf-2.0.14" "SDL2_ttf"
fetch "https://www.libsdl.org/projects/SDL_mixer/release" "SDL2_mixer-2.0.2.tar.gz" "SDL2_mixer-2.0.2" "SDL2_mixer"

SDL_ACTIVITY="third_party/SDL2/android-project/src/org/libsdl/app/SDLActivity.java"
python3 - "$SDL_ACTIVITY" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
source = source.replace("import java.util.Objects;\n", "")
source = source.replace('if (!Objects.equals(hint, "")) {', 'if (hint != null && !hint.equals("")) {')
path.write_text(source)
PY

# SDL_image 2.0.2's Android.mk lists IMG_WIC.c, a Windows Imaging
# Component backend that is not present in every release source archive and
# is not used on Android. Remove the stale source entry when the file is absent.
python3 - <<'PY'
from pathlib import Path
import re

image_dir = Path("third_party/SDL2_image")
makefile = image_dir / "Android.mk"
wic_source = image_dir / "IMG_WIC.c"
if not wic_source.exists():
    source = makefile.read_text()
    source, removed = re.subn(r"^[ \t]*IMG_WIC\.c[ \t]*\\[ \t]*\n", "", source, flags=re.MULTILINE)
    if removed != 1:
        raise SystemExit(f"Expected one IMG_WIC.c entry in {makefile}, removed {removed}")
    makefile.write_text(source)
    print("Removed unavailable Windows-only IMG_WIC.c from SDL2_image Android sources.")
PY

echo "Legacy SDL sources are ready."
