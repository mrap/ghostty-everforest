# Screenshot Tooling Decision

## Candidates Evaluated

| # | Tool | Headless | Custom 16-ANSI Palette | PNG Output | Brew | Maintained |
|---|------|:--------:|:---------------------:|:----------:|:----:|:----------:|
| a | **vhs** (charmbracelet) | ✅ | ✅ full JSON | ✅ | ✅ | ✅ (v2.1, May 2025) |
| b | **freeze** (charmbracelet) | ✅ | ⚠️ unclear/partial | ✅ | ✅ | ✅ (v0.2.1, Apr 2025) |
| c | **asciinema + agg** | ✅ | ✅ hex-triplet flag | ❌ GIF only | ✅ | ✅ (v1.7, Nov 2025) |
| d | **termshot** (homeport) | ✅ | ⚠️ unclear | ✅ | ✅ | ✅ (v0.6.1, Feb 2025) |
| e | **headless Chrome + xterm.js** (DIY) | ✅ | ✅ full control | ✅ | ❌ | N/A |

## Scoring Against 8 Criteria

| Criterion | Weight | vhs | freeze | agg | termshot | xterm.js DIY |
|-----------|--------|-----|--------|-----|----------|--------------|
| 1. Headless | ★ critical | 5 | 5 | 5 | 5 | 5 |
| 2. Arbitrary 16-ANSI + bg/fg/cursor palette | ★ critical | 5 | 2 | 4 | 2 | 5 |
| 3. Reproducible output | ★ high | 4 | 4 | 4 | 3 | 4 |
| 4. Available via brew on macOS | ★ medium | 5 | 5 | 5 | 5 | 0 |
| 5. Installable in CI | ★ medium | 5 | 5 | 5 | 5 | 3 |
| 6. PNG output | — | 5 | 5 | 0 | 5 | 5 |
| 7. Rich-looking demo (not a colorblock grid) | — | 5 | 3 | 4 | 4 | 5 |
| 8. Active maintenance | ★ medium | 5 | 5 | 5 | 5 | N/A |
| **Total** | | **39** | **34** | **32** | **34** | **27** |

## Decision: **vhs**

Install:
```bash
brew install vhs
```
vhs also requires ffmpeg:
```bash
brew install ffmpeg
```

### Justification

vhs is the only candidate that satisfies *both* critical criteria out of the box: it runs entirely headless (using ttyd under the hood) and accepts a full JSON theme definition covering all 16 ANSI palette slots plus background, foreground, cursor, and selection colors. Its declarative `.tape` format makes the render pipeline reproducible — the same tape + theme JSON produces the same output — and the `Screenshot` command emits PNG directly without any conversion step. Compared to the next-best alternatives, freeze has incomplete 16-ANSI palette support (designed for code, not interactive sessions), agg outputs GIF not PNG, and the xterm.js DIY route would require significant custom code with no brew-installable toolchain.

## VHS Theme Format Reference

vhs accepts themes as JSON, matching the `Set Theme` command in a `.tape` file or a `--theme` flag pointing to a JSON file. The structure used in this project:

```json
{
  "name": "everforest-dark-hard",
  "background": "#1e2326",
  "foreground": "#d3c6aa",
  "cursor": "#d3c6aa",
  "selection": "#4a555b",
  "black": "#343f44",
  "red": "#e67e80",
  "green": "#a7c080",
  "yellow": "#dbbc7f",
  "blue": "#7fbbb3",
  "magenta": "#d699b6",
  "cyan": "#83c092",
  "white": "#d3c6aa",
  "brightBlack": "#868d80",
  "brightRed": "#e67e80",
  "brightGreen": "#a7c080",
  "brightYellow": "#dbbc7f",
  "brightBlue": "#7fbbb3",
  "brightMagenta": "#d699b6",
  "brightCyan": "#83c092",
  "brightWhite": "#d3c6aa"
}
```

Fields map to Ghostty palette indices 0–15 and the special bg/fg/cursor/selection keys.
