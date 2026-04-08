#!/bin/bash
set -euo pipefail
# Toggle window between floating (centered) and tiling
# Only one floating window allowed at a time

# Get focused window ID
FOCUSED_ID=$(aerospace list-windows --focused --format '%{window-id}')

# Tile any other floating windows first
aerospace list-windows --workspace focused --format '%{window-id} %{window-layout}' | while read -r win_id layout; do
    if [ "$layout" = "floating" ] && [ "$win_id" != "$FOCUSED_ID" ]; then
        aerospace layout --window-id "$win_id" tiling
    fi
done

# Toggle the focused window
aerospace layout floating tiling

# # Check if window is now floating
LAYOUT=$(aerospace list-windows --focused --format '%{window-layout}')

if [ "$LAYOUT" = "floating" ]; then
    # Window is floating - resize and center it
    ~/.config/aerospace/scripts/center-window 2>&1 || true
fi
