#!/bin/bash

# Use tmux list-sessions with fzf for interactive selection
CHOSEN_DIR=$(fd --max-depth 2 --type d | fzf \
  --border \
  --margin 1 \
  --padding 1 \
  --info inline \
  --layout reverse \
  --header $'Select new TMUX session working directory' \
  --prompt 'Dir> ' \
  --bind 'ctrl-p:up,ctrl-n:down,J:down,K:up' \
  --walker=dir)

# Create the new session
tmux new-session -d -s ${CHOSEN_DIR%/} -c ${CHOSEN_DIR%/} -F ${CHOSEN_DIR%/} -P

# Attach to the new session
tmux attach-session -c ${CHOSEN_DIR%/}
