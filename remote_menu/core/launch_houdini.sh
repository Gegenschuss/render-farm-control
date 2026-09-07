#!/bin/bash
#  _____                         _
# |   __|___ ___ ___ ___ ___ ___| |_ _ _ ___ ___
# |  |  | -_| . | -_|   |_ -|  _|   | | |_ -|_ -|
# |_____|___|_  |___|_|_|___|___|_|_|___|___|___|
#           |___|
#
# Launch the newest installed macOS Houdini in the foreground so the
# console output stays in this terminal (mirror of the farm launcher).

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat << 'EOF'
Usage: ./launch_houdini.sh [houdini-args...]

Launch the latest installed macOS Houdini with -foreground so console
logs stream into this terminal. Extra arguments pass through to houdini.
EOF
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ui.sh"

if [ "$UI_OS" != "mac" ]; then
    fail "This launcher is for the macOS Houdini build (use the farm menu on Linux)"
    exit 1
fi

ui_play_logo
header "LAUNCH HOUDINI (MAC)"

# Newest versioned install; the [0-9] glob keeps the "Current" symlink
# and stray files out of the match.
HOUDINI_DIR=$(printf '%s\n' /Applications/Houdini/Houdini[0-9]* 2>/dev/null | sort -V | tail -n 1)
HFS="$HOUDINI_DIR/Frameworks/Houdini.framework/Versions/Current/Resources"

if [ ! -d "$HFS" ]; then
    fail "No Houdini install found under /Applications/Houdini"
    exit 1
fi

info "Using ${C_ACCENT}$(basename "$HOUDINI_DIR")${C_RESET}"
cd "$HFS" || exit 1
source ./houdini_setup
pass "Environment sourced (HFS=$HFS)"

info "Starting houdini -foreground ${C_DIM}(logs stay here; Ctrl-C returns to the menu)${C_RESET}"
exec houdini -foreground "$@"
