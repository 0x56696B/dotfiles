#!/usr/bin/env bash

CHOSEN_DIR=$(fd \
  --type d \
  --strip-cwd-prefix \
  --hidden \
  --follow \
  --exclude .git \
  --maxdepth 1 \
  --full-path \
  "$(pwd)" |
  fzf --border \
    --margin 1 \
    --padding 1 \
    --info inline \
    --layout reverse \
    --header $'Select new TMUX session working directory and append base dir name' \
    --prompt 'Dir> ' \
    --bind 'ctrl-p:up,ctrl-n:down,J:down,K:up' \
    --tmux center)

if [ -z "$CHOSEN_DIR" ]; then
  exit 0
fi

# This it will append the PWD to the name of the chosen directory
# Useful for when you want 2 dirs opened with the same name
# Example: ./dotfiles/scripts => dotfiles-scripts
CHOSEN_NAME="$(basename $(pwd))-${CHOSEN_DIR%/}"

# Create the new session
tmux new-session -d -s "$CHOSEN_NAME" -c "$(pwd)/${CHOSEN_DIR%/}"

# Attach to the new session
tmux switch-client -t "$CHOSEN_NAME"
