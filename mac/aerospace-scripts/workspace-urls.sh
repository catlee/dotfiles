#!/opt/homebrew/bin/bash
set -euo pipefail
#
# workspace-urls.sh <workspace-number>
#
# Outputs URLs to open for a workspace:
#   1. Static URLs from workspaces.toml
#   2. Your open PRs matching configured branch patterns (drafts first)
#   3. Review requests matching branch patterns

WORKSPACE="${1:?Usage: workspace-urls.sh <workspace-number>}"
CONFIG="$HOME/.config/aerospace/workspaces.toml"
REPO="shop/world"

# --- Parse workspace config ---
NAME=""
STATIC_URLS=()
BRANCHES=()

in_section=false
while IFS= read -r line; do
    if [[ "$line" != *'"'*'#'*'"'* ]]; then
        line="${line%%#*}"
    fi
    line="$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ ^\[workspace\.(.+)\]$ ]]; then
        if [[ "${BASH_REMATCH[1]}" == "$WORKSPACE" ]]; then in_section=true; else $in_section && break; in_section=false; fi
        continue
    fi
    if [[ "$line" =~ ^\[.+\]$ ]]; then $in_section && break; continue; fi
    $in_section || continue
    if [[ "$line" =~ ^([a-z_]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
        key="${BASH_REMATCH[1]}"; value="${BASH_REMATCH[2]}"
        value="${value#\"}"; value="${value%\"}"
        case "$key" in
            name) NAME="$value" ;;
            urls|branches)
                arr_value="${value#\[}"; arr_value="${arr_value%\]}"
                if [[ -n "$arr_value" ]]; then
                    while IFS= read -r item; do
                        item="$(echo "$item" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/^"//' | sed 's/"$//' | sed 's/,$//')"
                        if [[ -n "$item" ]]; then
                            case "$key" in
                                urls) STATIC_URLS+=("$item") ;;
                                branches) BRANCHES+=("$item") ;;
                            esac
                        fi
                    done <<< "$(echo "$arr_value" | tr ',' '\n')"
                fi
                ;;
        esac
    fi
done < "$CONFIG"

[[ -z "$NAME" ]] && { echo "No config for workspace $WORKSPACE" >&2; exit 1; }

# --- Collect URLs ---
ALL_URLS=()

# Static URLs
for url in "${STATIC_URLS[@]+${STATIC_URLS[@]}}"; do
    ALL_URLS+=("$url")
done

# If no branch patterns, just return static URLs
if [[ ${#BRANCHES[@]} -eq 0 ]]; then
    [[ ${#ALL_URLS[@]} -gt 0 ]] && printf '%s\n' "${ALL_URLS[@]}"
    exit 0
fi

# Build jq filter for branch matching
# select(.headRefName | startswith("pattern1") or startswith("pattern2"))
JQ_BRANCH_MATCH=""
for pat in "${BRANCHES[@]}"; do
    if [[ -n "$JQ_BRANCH_MATCH" ]]; then
        JQ_BRANCH_MATCH="${JQ_BRANCH_MATCH} or "
    fi
    JQ_BRANCH_MATCH="${JQ_BRANCH_MATCH}startswith(\"${pat}\")"
done

# Convert github PR URL to graphite URL
to_graphite() {
    echo "$1" | sed "s|github.com/${REPO}/pull/|app.graphite.com/github/pr/${REPO}/|"
}

# My open PRs matching branch patterns (drafts first, then non-drafts)
while IFS= read -r url; do
    [[ -n "$url" ]] && ALL_URLS+=("$(to_graphite "$url")")
done < <(gh pr list --author catlee --repo "$REPO" --limit 30 \
    --json url,headRefName,isDraft \
    --jq "[.[] | select(.headRefName | ${JQ_BRANCH_MATCH})] | sort_by(.isDraft | not) | .[].url" 2>/dev/null || true)

# Review requests matching branch patterns
while IFS= read -r url; do
    [[ -n "$url" ]] && ALL_URLS+=("$(to_graphite "$url")")
done < <(gh pr list --search "review-requested:catlee" --repo "$REPO" --limit 20 \
    --json url,headRefName \
    --jq "[.[] | select(.headRefName | ${JQ_BRANCH_MATCH})] | .[].url" 2>/dev/null || true)

# Deduplicate
[[ ${#ALL_URLS[@]} -gt 0 ]] && printf '%s\n' "${ALL_URLS[@]}" | awk '!seen[$0]++'
