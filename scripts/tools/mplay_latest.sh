#!/bin/bash
#  _____                         _
# |   __|___ ___ ___ ___ ___ ___| |_ _ _ ___ ___
# |  |  | -_| . | -_|   |_ -|  _|   | | |_ -|_ -|
# |_____|___|_  |___|_|_|___|___|_|_|___|___|___|
#           |___|
#
# Open an EXR in mplay from the latest Houdini in /opt.
# Registered as the desktop handler for image/x-exr, so double-clicking an
# EXR in the file manager lands here. If the file is part of a numbered
# sequence, the whole sequence is handed to mplay as file.$F4.exr.

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat << 'EOF'
Usage: ./mplay_latest.sh <file.exr>
       ./mplay_latest.sh --install

Open an EXR in mplay from the latest Houdini in /opt. If the filename ends in
a frame number (name.0001.exr, name_001.exr) and siblings exist, the whole
sequence is opened instead of the single frame.

  --install   Install ~/.local/share/applications/mplay.desktop and make it
              the default handler for image/x-exr on this workstation.
EOF
  exit 0
fi

DESKTOP_FILE="$HOME/.local/share/applications/mplay.desktop"

if [[ "${1:-}" == "--install" ]]; then
  target="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  mkdir -p "$(dirname "$DESKTOP_FILE")"
  cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Houdini mplay (Latest)
Exec=$target %F
Type=Application
MimeType=image/x-exr;
Icon=houdini
Categories=Graphics;
EOF
  update-desktop-database "$(dirname "$DESKTOP_FILE")" 2>/dev/null
  xdg-mime default mplay.desktop image/x-exr 2>/dev/null
  echo "  Installed $DESKTOP_FILE -> $target"
  echo "  image/x-exr now opens with: $(xdg-mime query default image/x-exr 2>/dev/null)"
  exit 0
fi

file="$1"
if [[ -z "$file" ]]; then
  echo "  Error: no file given. See --help." >&2
  exit 1
fi

# Find the latest installed Houdini version
HFS=$(printf '%s\n' /opt/hfs* 2>/dev/null | sort -V | tail -n 1)
if [[ ! -d "$HFS" ]]; then
  echo "  Error: no Houdini install found in /opt" >&2
  exit 1
fi

dir=$(dirname "$file")
base=$(basename "$file")
name="${base%.*}"
ext="${base##*.}"

# Match a frame number at the end, like file.0001.exr or file_001.exr
if [[ "$name" =~ (.*)([._-])([0-9]{3,5})$ ]]; then
    prefix="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
    frame="${BASH_REMATCH[3]}"
    padlen=${#frame}
    matches=($(ls "$dir" | grep -E "^${prefix}[0-9]{$padlen}\.$ext$"))
    if (( ${#matches[@]} > 1 )); then
        # Hand mplay the sequence pattern: file.$F4.exr
        exec "$HFS/bin/mplay" "$dir/$prefix\$F$padlen.$ext"
    fi
fi

# Otherwise, just open the single file
exec "$HFS/bin/mplay" "$file"
