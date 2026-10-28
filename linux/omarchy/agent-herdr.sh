#!/usr/bin/env bash

cwd=$PWD
if [[ $cwd == "$HOME" && -d $HOME/Work ]]; then
  cwd=$HOME/Work
fi

workspace=$(herdr workspace create --cwd "$cwd" --focus) || exit
workspace_id=$(jq -er '.result.workspace.workspace_id' <<<"$workspace") || exit 1
pane_id=$(jq -er '.result.root_pane.pane_id' <<<"$workspace") || {
  herdr workspace close "$workspace_id" >/dev/null
  exit 1
}

command=(/usr/bin/omarchy-agent --inline)
command+=("$@")
printf -v command_arg '%q ' "${command[@]}"
command_arg=${command_arg% }

if ! herdr pane run "$pane_id" "$command_arg"; then
  herdr workspace close "$workspace_id" >/dev/null
  exit 1
fi

exec herdr
