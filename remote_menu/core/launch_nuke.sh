#!/bin/bash
#  _____                         _
# |   __|___ ___ ___ ___ ___ ___| |_ _ _ ___ ___
# |  |  | -_| . | -_|   |_ -|  _|   | | |_ -|_ -|
# |_____|___|_  |___|_|_|___|___|_|_|___|___|___|
#           |___|
#
# Launch the newest installed macOS Nuke in Indie mode, in the
# foreground so the console output stays in this terminal (mirror of
# the farm launcher).

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat << 'EOF'
Usage: ./launch_nuke.sh [nuke-args...]

Launch the latest installed macOS Nuke in Indie mode, foregrounded so
console logs stream into this terminal. Extra arguments pass through
to Nuke.
EOF
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

if [ "$UI_OS" != "mac" ]; then
    fail "This launcher is for the macOS Nuke build (use the farm menu on Linux)"
    exit 1
fi

ui_play_logo
header "LAUNCH NUKE INDIE (MAC)"

# Newest versioned install, e.g. /Applications/Nuke17.0v3. Trailing
# slash keeps stray files out of the match.
LATEST_INSTALL=$(printf '%s\n' /Applications/Nuke*/ 2>/dev/null | sort -V | tail -n 1)
LATEST_INSTALL=${LATEST_INSTALL%/}

# -d, not -z: with no match the glob stays literal ("/Applications/Nuke*"),
# so the variable is never empty.
if [ ! -d "$LATEST_INSTALL" ]; then
    fail "No Nuke installation found in /Applications"
    exit 1
fi

# Folder "Nuke17.0v3" -> app bundle "Nuke17.0v3.app" -> binary "Nuke17.0"
FOLDER_NAME=$(basename "$LATEST_INSTALL")
BINARY_NAME=${FOLDER_NAME%v*}
NUKE_BINARY_PATH="$LATEST_INSTALL/$FOLDER_NAME.app/Contents/MacOS/$BINARY_NAME"

if [ ! -x "$NUKE_BINARY_PATH" ]; then
    fail "Binary not found at $NUKE_BINARY_PATH"
    warn "Check if the binary name matches the folder name prefix"
    exit 1
fi

info "Using ${C_ACCENT}$FOLDER_NAME${C_RESET} (Indie)"
info "Starting Nuke ${C_DIM}(logs stay here; Ctrl-C returns to the menu)${C_RESET}"
exec "$NUKE_BINARY_PATH" --indie "$@"
