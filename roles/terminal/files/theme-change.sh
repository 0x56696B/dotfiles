#!/bin/bash

# Get the directory where the script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dark_theme=$(sed -n '2p' "$script_dir/kitty.conf" | cut -d'=' -f2)
light_theme=$(sed -n '3p' "$script_dir/kitty.conf" | cut -d'=' -f2)

# Detect macOS theme
theme=$(osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')

# Apply the appropriate theme
if [ "$theme" = "true" ]; then
  kitty +kitten themes --reload-in=all --config-file-name "./theme.conf" "$dark_theme"
else
  kitty +kitten themes --reload-in=all --config-file-name "./theme.conf" "$light_theme"
fi
