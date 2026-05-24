#!/usr/bin/env python3
"""
Pixel-verify that each screenshot's top-left corner matches its theme's bg0.

Tolerance: per-channel ±8 (simple RGB comparison, no colorspace conversion).
Sampling region: pixel at (10, 10) — safely outside any rendered text or prompt.

Exit 0 = all 6 variants pass. Non-zero = at least one failed.
"""
import sys
import re
import os

try:
    from PIL import Image
except ImportError:
    print("ERROR: Pillow not installed. Run: pip install Pillow", file=sys.stderr)
    sys.exit(1)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THEMES_DIR = os.path.join(REPO_ROOT, "themes")
SCREENSHOTS_DIR = os.path.join(REPO_ROOT, "screenshots")

VARIANTS = [
    "everforest-dark-hard",
    "everforest-dark-medium",
    "everforest-dark-soft",
    "everforest-light-hard",
    "everforest-light-medium",
    "everforest-light-soft",
]

TOLERANCE = 8  # per-channel max delta
SAMPLE_X, SAMPLE_Y = 10, 10  # pixel coordinates — guaranteed background region


def read_background(theme_path):
    """Return (r, g, b) from the 'background = #rrggbb' line in a Ghostty theme file."""
    with open(theme_path) as f:
        for line in f:
            m = re.match(r"^background = #([0-9a-f]{6})$", line.strip())
            if m:
                h = m.group(1)
                return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    raise ValueError(f"No background line found in {theme_path}")


def check_variant(variant):
    theme_path = os.path.join(THEMES_DIR, variant)
    png_path = os.path.join(SCREENSHOTS_DIR, f"{variant}.png")

    if not os.path.isfile(theme_path):
        print(f"FAIL {variant}: theme file missing: {theme_path}")
        return False
    if not os.path.isfile(png_path):
        print(f"FAIL {variant}: screenshot missing: {png_path}")
        return False

    er, eg, eb = read_background(theme_path)
    img = Image.open(png_path).convert("RGB")
    pr, pg, pb = img.getpixel((SAMPLE_X, SAMPLE_Y))

    dr, dg, db = abs(pr - er), abs(pg - eg), abs(pb - eb)
    max_delta = max(dr, dg, db)

    if max_delta <= TOLERANCE:
        print(
            f"PASS {variant}: expected=#{er:02x}{eg:02x}{eb:02x} "
            f"got=#{pr:02x}{pg:02x}{pb:02x} "
            f"delta=({dr},{dg},{db}) max={max_delta}"
        )
        return True
    else:
        print(
            f"FAIL {variant}: expected=#{er:02x}{eg:02x}{eb:02x} "
            f"got=#{pr:02x}{pg:02x}{pb:02x} "
            f"delta=({dr},{dg},{db}) max={max_delta} > tolerance={TOLERANCE}"
        )
        return False


def main():
    results = [check_variant(v) for v in VARIANTS]
    passed = sum(results)
    total = len(results)
    print(f"\n{passed}/{total} variants passed pixel verification (tolerance ±{TOLERANCE} per channel)")
    if passed < total:
        sys.exit(1)


if __name__ == "__main__":
    main()
