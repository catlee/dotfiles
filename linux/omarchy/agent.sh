#!/usr/bin/env bash

args=("$@")
for ((i = 0; i < ${#args[@]}; i++)); do
  case ${args[i]} in
    --inline)
      exec /usr/bin/omarchy-agent "${args[@]}"
      ;;
    --prompt)
      ((i++))
      ;;
  esac
done

exec omarchy-launch-terminal "$HOME/.local/bin/omarchy-agent-herdr" "${args[@]}"
