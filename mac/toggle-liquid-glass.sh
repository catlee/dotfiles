#!/bin/bash
set -euo pipefail
# Toggle macOS Liquid Glass (Solarium) effects on/off

CURRENT=$(defaults read -g com.apple.SwiftUI.DisableSolarium 2>/dev/null || echo "0")

if [ "$CURRENT" = "1" ]; then
    # Currently disabled, enable Liquid Glass
    defaults delete -g com.apple.SwiftUI.DisableSolarium
    echo "Liquid Glass ENABLED (default macOS style)"
else
    # Currently enabled, disable Liquid Glass
    defaults write -g com.apple.SwiftUI.DisableSolarium -bool YES
    echo "Liquid Glass DISABLED (classic style)"
fi

echo ""
echo "Restart apps (or log out/in) to see changes."
echo "Affected: Finder, Music, System Settings, and other SwiftUI apps."
