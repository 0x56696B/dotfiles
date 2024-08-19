#!/usr/bin/env bash

HOME_DIR=$(env | grep "^HOME=" | cut -d"=" -f2)
LIST_DIRS=$(fd --type d --max-depth 1 --exclude '.*' --follow --search-path "$HOME_DIR/personal" --search-path "$HOME_DIR/work" | sort)

CHOSEN_DIR=$(echo "$LIST_DIRS" |
  fzf --border \
    --margin 1 \
    --padding 1 \
    --info inline \
    --layout reverse \
    --header $'Select new TMUX session working directory' \
    --prompt 'Dir> ' \
    --bind 'ctrl-p:up,ctrl-n:down,J:down,K:up' \
    --tmux center)

if [ -z "$CHOSEN_DIR" ]; then
  exit 0
fi

NO_TRAILING="${CHOSEN_DIR%/}"
BASENAME="$(basename "$NO_TRAILING")"

# Create the new session
tmux new-session -d -s "$BASENAME" -c "$NO_TRAILING"

# Attach to the new session
tmux switch-client -t "$BASENAME"
