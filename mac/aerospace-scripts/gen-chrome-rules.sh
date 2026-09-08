#!/bin/bash
set -euo pipefail
#
# gen-chrome-rules.sh
#
# Reads workspaces.toml and outputs aerospace on-window-detected rules
# for Chrome windows. Paste the output into aerospace.toml.
#
# Named Chrome windows have titles like "ws-3-shell - <tab title> - Google Chrome"
# so we match on "ws-N-name" as a substring.

CONFIG="$HOME/.config/aerospace/workspaces.toml"

echo "# Auto-generated Chrome workspace rules (from workspaces.toml)"
echo "# Paste into aerospace.toml"
echo ""

grep '^\[workspace\.' "$CONFIG" | sed 's/\[workspace\.\(.*\)\]/\1/' | while read -r ws; do
    name=$(sed -n "/^\[workspace\.${ws}\]/,/^\[/{ s/^name *= *\"\(.*\)\"/\1/p; }" "$CONFIG")
    if [[ -n "$name" ]]; then
        tag="ws-${ws}-${name}"
        cat <<EOF
[[on-window-detected]]
if.app-id = "com.google.Chrome"
if.window-title-regex-substring = "^${tag} - "
run = 'move-node-to-workspace ${ws}'

EOF
    fi
done
