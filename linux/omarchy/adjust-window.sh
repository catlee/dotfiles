#!/usr/bin/env bash
set -euo pipefail

kind=${1:?Expected gaps or opacity}
direction=${2:?Expected up or down}
[[ $direction == up || $direction == down ]] || exit 2

case $kind in
  gaps)
    delta=5
    [[ $direction == down ]] && delta=-5
    for option in gaps_in gaps_out; do
      current=$(hyprctl -j getoption "general:$option" | jq -r '.int // (.css | split(" ")[0] | tonumber)')
      next=$((current + delta))
      ((next < 0)) && next=0
      hyprctl eval "hl.config({ general = { $option = $next } })" >/dev/null
    done
    ;;
  opacity)
    current=$(hyprctl getprop active opacity | grep -Eo '[0-9]+([.][0-9]+)?' | tail -n1)
    [[ -n $current ]] || exit 1
    delta=0.05
    [[ $direction == down ]] && delta=-0.05
    next=$(awk -v current="$current" -v delta="$delta" 'BEGIN { value=current+delta; if (value<0.2) value=0.2; if (value>1) value=1; printf "%.2f", value }')
    hyprctl eval "hl.dispatch(hl.dsp.window.set_prop({ prop = 'opacity', value = '$next override $next override 1.0 override', window = 'active' }))"
    ;;
  *)
    echo "Expected gaps or opacity" >&2
    exit 2
    ;;
esac
