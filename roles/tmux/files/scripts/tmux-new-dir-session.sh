#!/usr/bin/env bash

CHOSEN_DIR=$(fd \
  --type d \
  --strip-cwd-prefix \
  --hidden \
  --follow \
  --exclude .git \
  --maxdepth 2 \
  | fzf --border \
  --margin 1 \
  --padding 1 \
  --info inline \
  --layout reverse \
  --header $'Select new TMUX session working directory' \
  --prompt 'Dir> ' \
  --bind 'ctrl-p:up,ctrl-n:down,J:down,K:up' \
  --walker=dir \
  --tmux center)
if [ -z "$CHOSEN_DIR" ]; then
  exit 0
fi


# Create the new session
tmux new-session -d -s ${CHOSEN_DIR%/} -c ${CHOSEN_DIR%/} -F ${CHOSEN_DIR%/} -P

# Attach to the new session
tmux switch-client -t ${CHOSEN_DIR%/}
