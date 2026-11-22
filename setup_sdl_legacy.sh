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

# SDL_image's Android.mk can list IMG_WIC.c even though the file is
# absent from the Android source archive. WIC is Windows-only and unused here.
# Remove any matching source-list line, but tolerate releases where it is
# already absent. This keeps setup idempotent across SDL_image archive layouts.
python3 - <<'PY'
from pathlib import Path

makefile = Path("third_party/SDL2_image/Android.mk")
lines = makefile.read_text().splitlines(keepends=True)
filtered = [line for line in lines if "IMG_WIC.c" not in line]
removed = len(lines) - len(filtered)
if removed:
    makefile.write_text("".join(filtered))
    print(f"Removed {removed} unavailable Windows-only IMG_WIC.c source entry.")
else:
    print("No IMG_WIC.c entry present; SDL2_image Android.mk already compatible.")
PY

echo "Legacy SDL sources are ready."
