#!/opt/homebrew/bin/bash
set -euo pipefail
#
# workspace-setup.sh <workspace-number>
#
# Sets up a workspace with:
#   1. Ghostty running zellij (with a named session) in the project directory
#   2. A named Chrome window with configured URLs
#
# Chrome windows are named "ws-<N>-<name>" so aerospace can route them
# back to the correct workspace on restart via on-window-detected rules.
#
# Config: ~/.config/aerospace/workspaces.toml

WORKSPACE="${1:?Usage: workspace-setup.sh <workspace-number>}"
CONFIG="$HOME/.config/aerospace/workspaces.toml"

if [[ ! -f "$CONFIG" ]]; then
    echo "No workspace config found at $CONFIG" >&2
    exit 1
fi

# --- Parse TOML config (simple parser, no external deps) ---
parse_config() {
    local ws="$1"
    local in_section=false
    local key value

    NAME=""
    DIR=""
    URLS=()

    while IFS= read -r line; do
        # Strip comments only if # is not inside a quoted string
        if [[ "$line" != *'"'*'#'*'"'* ]]; then
            line="${line%%#*}"
        fi
        line="$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
        [[ -z "$line" ]] && continue

        if [[ "$line" =~ ^\[workspace\.(.+)\]$ ]]; then
            if [[ "${BASH_REMATCH[1]}" == "$ws" ]]; then
                in_section=true
            else
                $in_section && break
                in_section=false
            fi
            continue
        fi

        if [[ "$line" =~ ^\[.+\]$ ]]; then
            $in_section && break
            continue
        fi

        $in_section || continue

        if [[ "$line" =~ ^([a-z_]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            value="${value#\"}"
            value="${value%\"}"

            case "$key" in
                name) NAME="$value" ;;
                dir) DIR="${value/#\~/$HOME}" ;;
                urls)
                    value="${value#\[}"
                    value="${value%\]}"
                    if [[ -n "$value" ]]; then
                        while IFS= read -r url; do
                            url="$(echo "$url" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/^"//' | sed 's/"$//' | sed 's/,$//')"
                            [[ -n "$url" ]] && URLS+=("$url")
                        done <<< "$(echo "$value" | tr ',' '\n')"
                    fi
                    ;;
            esac
        fi
    done < "$CONFIG"

    if [[ -z "$NAME" ]]; then
        echo "No config found for workspace $ws" >&2
        return 1
    fi
}

parse_config "$WORKSPACE" || exit 1

CHROME_WINDOW_NAME="ws-${WORKSPACE}-${NAME}"

echo "Setting up workspace $WORKSPACE: $NAME"
echo "  dir:  $DIR"
echo "  urls: ${URLS[*]:-none}"
echo "  chrome window name: $CHROME_WINDOW_NAME"

# --- Switch to the workspace ---
aerospace workspace "$WORKSPACE"

# --- Check what's already on this workspace ---
has_ghostty=false
has_chrome=false
while IFS= read -r line; do
    case "$line" in
        *Ghostty*) has_ghostty=true ;;
        *"Google Chrome"*) has_chrome=true ;;
    esac
done < <(aerospace list-windows --workspace "$WORKSPACE" --format '%{app-name}')

# --- Launch Ghostty with zellij ---
if ! $has_ghostty; then
    echo "Launching Ghostty + zellij session '$NAME' in $DIR"
    open -na "Ghostty.app" --args \
        --title="$NAME" \
        -e bash -c "cd '$DIR' && exec zellij attach --create '$NAME'"

    # Wait for the window to appear, then move it to the workspace
    for i in $(seq 1 30); do
        sleep 0.3
        # Check if it landed on our workspace already
        ON_WS=$(aerospace list-windows --workspace "$WORKSPACE" --format '%{window-id} %{app-name}' \
            | grep "Ghostty" | head -1 | awk '{print $1}')
        if [[ -n "$ON_WS" ]]; then
            break
        fi
        # Otherwise find the new Ghostty window and move it
        NEW_WIN=$(aerospace list-windows --all --format '%{window-id} %{app-name} %{workspace}' \
            | grep "Ghostty" | grep -v " ${WORKSPACE}$" | head -1 | awk '{print $1}')
        if [[ -n "$NEW_WIN" ]]; then
            aerospace move-node-to-workspace --window-id "$NEW_WIN" "$WORKSPACE"
            aerospace focus --window-id "$NEW_WIN"
            break
        fi
    done
fi

# --- Resolve dynamic URLs ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -x "$SCRIPT_DIR/workspace-urls.sh" ]]; then
    URLS=()
    while IFS= read -r _url; do
        [[ -n "$_url" ]] && URLS+=("$_url")
    done < <("$SCRIPT_DIR/workspace-urls.sh" "$WORKSPACE")
    echo "Resolved ${#URLS[@]} URLs"
fi

# --- Open named Chrome window ---
if ! $has_chrome && [[ ${#URLS[@]} -gt 0 ]]; then
    echo "Opening Chrome window '$CHROME_WINDOW_NAME'..."

    # Snapshot existing Chrome window IDs so we can find the new one
    BEFORE_IDS=$(aerospace list-windows --all --format '%{window-id} %{app-name}' | grep 'Google Chrome' | awk '{print $1}' | sort)

    # Open first URL in a new window
    open -na "Google Chrome" --args --new-window "${URLS[0]}"
    sleep 2

    # Open remaining URLs as tabs in the frontmost Chrome window
    for url in "${URLS[@]:1}"; do
        open -na "Google Chrome" --args "$url"
        sleep 0.3
    done

    # Find the new Chrome window by diffing window IDs
    NEW_WIN=""
    for i in $(seq 1 20); do
        AFTER_IDS=$(aerospace list-windows --all --format '%{window-id} %{app-name}' | grep 'Google Chrome' | awk '{print $1}' | sort)
        NEW_WIN=$(comm -13 <(echo "$BEFORE_IDS") <(echo "$AFTER_IDS") | head -1)
        [[ -n "$NEW_WIN" ]] && break
        sleep 0.3
    done

    if [[ -n "$NEW_WIN" ]]; then
        # Name the Chrome window via AppleScript
        osascript <<EOF
tell application "Google Chrome"
    set windowList to every window
    repeat with w in windowList
        set wId to id of w
        -- Chrome window IDs and aerospace window IDs may differ;
        -- name the frontmost (most recently opened) window
    end repeat
    set given name of window 1 to "${CHROME_WINDOW_NAME}"
end tell
EOF

        # Move to workspace
        aerospace move-node-to-workspace --window-id "$NEW_WIN" "$WORKSPACE"
        echo "Moved Chrome window $NEW_WIN to workspace $WORKSPACE"
    else
        echo "Warning: could not find new Chrome window" >&2
        # Still try to name window 1 as fallback
        osascript -e "tell application \"Google Chrome\" to set given name of window 1 to \"${CHROME_WINDOW_NAME}\""
    fi
fi

echo "Workspace $WORKSPACE ($NAME) is ready!"
