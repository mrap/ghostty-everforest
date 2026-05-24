#!/bin/sh
# Install Everforest themes for Ghostty.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEMES_SRC="$SCRIPT_DIR/themes"

# Detect OS and set target directory
if [ "$(uname)" = "Darwin" ]; then
  THEMES_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty/themes"
else
  THEMES_DIR="$HOME/.config/ghostty/themes"
fi

echo "Installing Everforest themes to: $THEMES_DIR"
mkdir -p "$THEMES_DIR"

for theme in "$THEMES_SRC"/everforest-*; do
  name="$(basename "$theme")"
  cp "$theme" "$THEMES_DIR/$name"
  echo "  installed: $name"
done

echo ""
echo "Done. Add one of the following to your Ghostty config:"
echo ""
echo "  theme = everforest-dark-hard"
echo "  theme = everforest-dark-medium"
echo "  theme = everforest-dark-soft"
echo "  theme = everforest-light-hard"
echo "  theme = everforest-light-medium"
echo "  theme = everforest-light-soft"
echo ""
if [ "$(uname)" = "Darwin" ]; then
  echo "Config location: ~/Library/Application Support/com.mitchellh.ghostty/config"
else
  echo "Config location: ~/.config/ghostty/config"
fi
