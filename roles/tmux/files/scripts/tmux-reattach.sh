#!/bin/bash

# Use tmux list-sessions with fzf for interactive selection
SESSION_NAME=$(tmux list-sessions -F "#S" 2>/dev/null | fzf --height=10 --reverse)

if [ -n "$SESSION_NAME" ]; then
  tmux attach-session -t "$SESSION_NAME"
else
  echo "No session selected."
fi

