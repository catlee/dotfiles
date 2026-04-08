#!/bin/bash
set -euo pipefail
# Toggle gaps in aerospace config between 0 and 10

# Resolve symlink to actual file (macOS compatible)
CONFIG=$(realpath "$HOME/.config/aerospace/aerospace.toml")

# Check current gap value
current=$(grep 'inner.horizontal' "$CONFIG" | head -1 | grep -o '[0-9]*')

if [ "$current" = "0" ]; then
    # Turn gaps on
    sed -i '' 's/inner.horizontal = 0/inner.horizontal = 10/' "$CONFIG"
    sed -i '' 's/inner.vertical = 0/inner.vertical = 10/' "$CONFIG"
    sed -i '' 's/outer.left = 0/outer.left = 10/' "$CONFIG"
    sed -i '' 's/outer.right = 0/outer.right = 10/' "$CONFIG"
    sed -i '' 's/outer.top = 0/outer.top = 10/' "$CONFIG"
    sed -i '' 's/outer.bottom = 0/outer.bottom = 10/' "$CONFIG"
    echo "Gaps ON"
else
    # Turn gaps off
    sed -i '' 's/inner.horizontal = [0-9]*/inner.horizontal = 0/' "$CONFIG"
    sed -i '' 's/inner.vertical = [0-9]*/inner.vertical = 0/' "$CONFIG"
    sed -i '' 's/outer.left = [0-9]*/outer.left = 0/' "$CONFIG"
    sed -i '' 's/outer.right = [0-9]*/outer.right = 0/' "$CONFIG"
    sed -i '' 's/outer.top = [0-9]*/outer.top = 0/' "$CONFIG"
    sed -i '' 's/outer.bottom = [0-9]*/outer.bottom = 0/' "$CONFIG"
    echo "Gaps OFF"
fi

aerospace reload-config
