#!/usr/bin/env bash
set -euo pipefail

DISPLAYS_JSON="$(yabai -m query --displays)"
SPACES_JSON="$(yabai -m query --spaces)"

DISPLAY_COUNT="$(echo "$DISPLAYS_JSON" | jq 'length')"
SPACE_COUNT="$(echo "$SPACES_JSON" | jq 'length')"

if [[ "$DISPLAY_COUNT" -eq 0 ]]; then
  echo "No displays found."
  exit 1
fi

# Calculate base allocation
SPACES_PER_DISPLAY=$((SPACE_COUNT / DISPLAY_COUNT))
REMAINDER=$((SPACE_COUNT % DISPLAY_COUNT))

# Get ordered lists
DISPLAY_INDEXES=($(echo "$DISPLAYS_JSON" | jq -r '.[].index'))
SPACE_INDEXES=($(echo "$SPACES_JSON" | jq -r '.[].index'))

echo "Number of displays to rearrange: ${DISPLAY_COUNT}"
echo "Number of spaces to rearrange: ${SPACE_COUNT}"
echo "Number of spaces per display: ${SPACES_PER_DISPLAY}"

space_cursor=0

for i in "${!DISPLAY_INDEXES[@]}"; do
  display_index="${DISPLAY_INDEXES[$i]}"

  # Distribute remainder to first displays
  extra=0
  if [[ "$i" -lt "$REMAINDER" ]]; then
    extra=1
  fi

  allocation=$((SPACES_PER_DISPLAY + extra))

  for ((j = 0; j < allocation; j++)); do
    space="${SPACE_INDEXES[$space_cursor]}"
    yabai -m space "$space" --display "$display_index"
    ((space_cursor++))
  done
done
