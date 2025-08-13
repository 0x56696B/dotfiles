#!/usr/bin/env bash
set -euo pipefail

# Determine base directory: 1) arg from tmux, 2) pane path via tmux, 3) fallback to $PWD
BASE="${1:-}"
if [[ -z "$BASE" || ! -d "$BASE" ]]; then
  if [[ -n "${TMUX:-}" ]]; then
    BASE="$(tmux display-message -p -F "#{pane_current_path}")"
  else
    BASE="$PWD"
  fi
fi

cd "$BASE"

CHOSEN_DIR=$(
  fd \
    --type d \
    --hidden \
    --follow \
    --exclude .git \
    --maxdepth 1 \
    --strip-cwd-prefix \
    . |
    fzf --border \
      --margin 1 \
      --padding 1 \
      --info inline \
      --layout reverse \
      --header $'Select new TMUX session working directory' \
      --prompt 'Dir> ' \
      --bind 'ctrl-p:up,ctrl-n:down,J:down,K:up' \
      --tmux center ||
    true
)

if [ -z "$CHOSEN_DIR" ]; then
  exit 0
fi

# Create the new session
tmux new-session -d -s "${CHOSEN_DIR%/}" -c "$(pwd)/${CHOSEN_DIR%/}"

# Attach to the new session
tmux switch-client -t "${CHOSEN_DIR%/}"
