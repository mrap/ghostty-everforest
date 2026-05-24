#!/usr/bin/env bash
# Render all 6 Everforest theme screenshots using vhs + ffmpeg.
# vhs v0.11 does not support PNG output directly (only gif/mp4/webm and
# requires relative output paths). We output a GIF via the -o flag, then
# extract the last frame as PNG with ffmpeg.
# Usage: bash scripts/render-screenshots.sh (no arguments)
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_DIR="$REPO_ROOT/themes"
SCREENSHOTS_DIR="$REPO_ROOT/screenshots"
DEMO_SCRIPT="$REPO_ROOT/scripts/demo-content.sh"

VARIANTS=(
    everforest-dark-hard
    everforest-dark-medium
    everforest-dark-soft
    everforest-light-hard
    everforest-light-medium
    everforest-light-soft
)

# ── Dependencies ──────────────────────────────────────────────────────────────
install_if_missing() {
    local cmd="$1" pkg="${2:-$1}"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "==> Installing $pkg via brew..."
        brew install "$pkg" || { echo "ERROR: brew install $pkg failed"; exit 1; }
    fi
}

install_if_missing vhs vhs
install_if_missing ffmpeg ffmpeg

# ── Ghostty theme → VHS JSON ──────────────────────────────────────────────────
ghostty_to_vhs_json() {
    local theme_file="$1"
    python3 - "$theme_file" <<'PYEOF'
import sys, re, json

NAMES = [
    "black","red","green","yellow","blue","magenta","cyan","white",
    "brightBlack","brightRed","brightGreen","brightYellow",
    "brightBlue","brightMagenta","brightCyan","brightWhite",
]

out = {}
with open(sys.argv[1]) as f:
    for line in f:
        line = line.strip()
        m = re.match(r'^palette = (\d+)=#([0-9a-f]{6})$', line)
        if m:
            out[NAMES[int(m.group(1))]] = '#' + m.group(2)
            continue
        m = re.match(r'^background = (#[0-9a-f]{6})$', line)
        if m:
            out['background'] = m.group(1)
            continue
        m = re.match(r'^foreground = (#[0-9a-f]{6})$', line)
        if m:
            out['foreground'] = m.group(1)
            continue
        m = re.match(r'^cursor-color = (#[0-9a-f]{6})$', line)
        if m:
            out['cursor'] = m.group(1)
            continue
        m = re.match(r'^selection-background = (#[0-9a-f]{6})$', line)
        if m:
            out['selection'] = m.group(1)

print(json.dumps(out, separators=(',', ':')))
PYEOF
}

# ── Render loop ───────────────────────────────────────────────────────────────
for variant in "${VARIANTS[@]}"; do
    theme_file="$THEMES_DIR/$variant"
    out_png="$SCREENSHOTS_DIR/$variant.png"
    tmp_gif="/tmp/vhs-ef-${variant}.gif"

    echo "==> Rendering $variant ..."

    if [ ! -f "$theme_file" ]; then
        echo "ERROR: theme file not found: $theme_file"
        exit 1
    fi

    vhs_theme_json=$(ghostty_to_vhs_json "$theme_file")
    if [ -z "$vhs_theme_json" ]; then
        echo "ERROR: failed to convert theme to VHS JSON for $variant"
        exit 1
    fi

    tape_file=$(mktemp /tmp/vhs-XXXXXXXX.tape)

    # vhs v0.11 requires relative paths in the Output directive;
    # we override with -o flag (absolute path is fine for -o).
    cat > "$tape_file" <<TAPE
Output out.gif

Set Theme $vhs_theme_json
Set Width 1200
Set Height 850
Set FontSize 14
Set Padding 24
Set Shell bash

Hide
Type "export TERM=xterm-256color"
Enter
Sleep 200ms
Type "clear"
Enter
Sleep 200ms
Show

Type "bash $DEMO_SCRIPT $variant"
Enter
Sleep 6s
TAPE

    vhs -o "$tmp_gif" "$tape_file"
    vhs_exit=$?
    rm -f "$tape_file"

    if [ $vhs_exit -ne 0 ]; then
        echo "ERROR: vhs failed for $variant (exit $vhs_exit)"
        exit 1
    fi

    if [ ! -f "$tmp_gif" ]; then
        echo "ERROR: expected gif not found: $tmp_gif"
        exit 1
    fi

    # Extract the LAST frame of the GIF as a PNG.
    # Approach: count total frames with ffprobe, then select the final one.
    nframes=$(ffprobe -v error -select_streams v:0 -count_frames \
        -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 \
        "$tmp_gif" 2>/dev/null)
    if [ -z "$nframes" ] || [ "$nframes" -lt 1 ]; then
        echo "ERROR: ffprobe failed to count frames in $tmp_gif"
        exit 1
    fi
    last=$((nframes - 1))
    ffmpeg -y -i "$tmp_gif" -vf "select='eq(n,$last)'" -vframes 1 "$out_png" 2>/dev/null
    ffmpeg_exit=$?
    rm -f "$tmp_gif"

    if [ $ffmpeg_exit -ne 0 ]; then
        echo "ERROR: ffmpeg failed to extract PNG for $variant"
        exit 1
    fi

    if [ ! -f "$out_png" ]; then
        echo "ERROR: expected output PNG not found: $out_png"
        exit 1
    fi

    echo "    -> $out_png"
done

echo ""
echo "Done. All 6 screenshots written to screenshots/"
