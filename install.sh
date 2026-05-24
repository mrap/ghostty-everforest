#!/bin/sh
# Install Everforest themes for Ghostty.
# Detects your Ghostty config dir by looking for an existing config file —
# XDG ($XDG_CONFIG_HOME/ghostty or ~/.config/ghostty) takes precedence over
# the macOS app-support path, since Ghostty itself prefers XDG when present.
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEMES_SRC="$SCRIPT_DIR/themes"

xdg_base="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
mac_base="$HOME/Library/Application Support/com.mitchellh.ghostty"

# Precedence:
#   1. Existing config file (XDG, then macOS) — install next to it.
#   2. Existing config directory (XDG, then macOS).
#   3. Default per OS: macOS → app-support; everything else → XDG.
if   [ -f "$xdg_base/config" ];  then BASE="$xdg_base"
elif [ -f "$mac_base/config" ];  then BASE="$mac_base"
elif [ -d "$xdg_base" ];         then BASE="$xdg_base"
elif [ -d "$mac_base" ];         then BASE="$mac_base"
elif [ "$(uname)" = "Darwin" ];  then BASE="$mac_base"
else                                  BASE="$xdg_base"
fi

THEMES_DIR="$BASE/themes"
CONFIG_FILE="$BASE/config"

echo "Detected Ghostty base:  $BASE"
echo "Installing themes to:   $THEMES_DIR"
mkdir -p "$THEMES_DIR"

for theme in "$THEMES_SRC"/everforest-*; do
  name="$(basename "$theme")"
  cp "$theme" "$THEMES_DIR/$name"
  echo "  installed: $name"
done

echo ""
echo "Done. Add one of the following to $CONFIG_FILE:"
echo ""
echo "  theme = everforest-dark-hard"
echo "  theme = everforest-dark-medium"
echo "  theme = everforest-dark-soft"
echo "  theme = everforest-light-hard"
echo "  theme = everforest-light-medium"
echo "  theme = everforest-light-soft"
