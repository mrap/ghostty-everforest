#!/usr/bin/env bash
# Outputs rich terminal demo content demonstrating an Everforest theme variant.
# Usage: bash demo-content.sh <variant-name>
VARIANT="${1:-everforest}"

R='\033[0m'   B='\033[1m'   D='\033[2m'
K='\033[30m'  RED='\033[31m'  GRN='\033[32m'  YLW='\033[33m'
BLU='\033[34m' MAG='\033[35m'  CYN='\033[36m'  WHT='\033[37m'
BK='\033[90m' BR='\033[91m' BG='\033[92m' BY='\033[93m'
BB='\033[94m' BM='\033[95m' BC='\033[96m' BW='\033[97m'

# ── Banner ──────────────────────────────────────────────────────────────────
echo ""
printf "  ${B}${GRN}╔══════════════════════════════════════════════════════════════╗${R}\n"
printf "  ${B}${GRN}║  ${YLW}🌲 Everforest Theme for Ghostty${GRN}                              ║${R}\n"
printf "  ${B}${GRN}║  ${D}${WHT}%-60s${R}${B}${GRN}║${R}\n" "$VARIANT"
printf "  ${B}${GRN}╚══════════════════════════════════════════════════════════════╝${R}\n"
echo ""

# ── Color Palette ────────────────────────────────────────────────────────────
printf "  ${D}# ANSI color palette${R}\n"
printf "  "
for c in 40 41 42 43 44 45 46 47; do
    printf "\033[${c}m    ${R}"
done
printf "\n  "
for c in 100 101 102 103 104 105 106 107; do
    printf "\033[${c}m    ${R}"
done
printf "\n\n"

# ── System info (neofetch-style) ─────────────────────────────────────────────
printf "  ${GRN}         .${R}            ${B}everforest${D}@${B}ghostty${R}\n"
printf "  ${GRN}        .${YLW}+${GRN}.${R}           ${D}──────────────────────────────${R}\n"
printf "  ${GRN}       ${YLW}.++++.${GRN}          ${CYN}OS:${R}       macOS 15.5 Sequoia\n"
printf "  ${GRN}      ${YLW}.+++++++.${GRN}         ${CYN}Shell:${R}    zsh 5.9 / bash 5.2\n"
printf "  ${GRN}     .++++++++++.        ${CYN}Theme:${R}    ${GRN}${VARIANT}${R}\n"
printf "  ${GRN}    .++++++++++++++.     ${CYN}Editor:${R}   neovim 0.10\n"
printf "  ${GRN}   .+++.       .+++.     ${CYN}Font:${R}     JetBrains Mono 15\n"
printf "  ${GRN}  .+++.         .+++.    ${CYN}Source:${R}   github.com/sainnhe/everforest\n"
echo ""

# ── Code snippet ─────────────────────────────────────────────────────────────
printf "  ${D}# ~/projects/everforest-demo.py${R}\n"
printf "  ${BLU}import${R} sys\n"
printf "  ${BLU}from${R} pathlib ${BLU}import${R} Path\n"
printf "  ${BLU}from${R} dataclasses ${BLU}import${R} dataclass, field\n"
echo ""
printf "  ${D}# Ghostty theme data class${R}\n"
printf "  ${MAG}@dataclass${R}\n"
printf "  ${YLW}class${R} ${GRN}GhosttyTheme${R}:\n"
printf "      ${WHT}name${R}: ${CYN}str${R}\n"
printf "      ${WHT}background${R}: ${CYN}str${R}  ${D}= \"#2d353b\"${R}\n"
printf "      ${WHT}foreground${R}: ${CYN}str${R}  ${D}= \"#d3c6aa\"${R}\n"
printf "      ${WHT}palette${R}: ${CYN}list[str]${R} ${D}= field(default_factory=list)${R}\n"
echo ""
printf "  ${YLW}    def${R} ${GRN}to_ghostty_config${R}(${WHT}self${R}) -> ${CYN}str${R}:\n"
printf "          lines = []\n"
printf "          ${YLW}for${R} i, color ${YLW}in${R} ${BLU}enumerate${R}(${WHT}self${R}.palette):\n"
printf "              lines.append(${MAG}f\"palette = {i}={color}\"${R})\n"
printf "          ${YLW}return${R} ${MAG}\"\\n\"${R}.join(lines)\n"
echo ""

# ── Git diff ─────────────────────────────────────────────────────────────────
printf "  ${D}# git diff HEAD~1 -- themes/everforest-dark-medium${R}\n"
printf "  ${CYN}diff --git a/themes/everforest-dark-medium b/themes/everforest-dark-medium${R}\n"
printf "  ${CYN}index 2a4f8c1..9e3d720 100644${R}\n"
printf "  ${CYN}--- a/themes/everforest-dark-medium${R}\n"
printf "  ${CYN}+++ b/themes/everforest-dark-medium${R}\n"
printf "  ${D}@@ -1,8 +1,10 @@${R}\n"
printf "   palette = 0=#475258\n"
printf "   palette = 1=#e67e80\n"
printf "  ${GRN}+palette = 2=#a7c080${R}\n"
printf "  ${GRN}+palette = 3=#dbbc7f${R}\n"
printf "   palette = 4=#7fbbb3\n"
printf "   palette = 5=#d699b6\n"
printf "  ${RED}-background = #2c3439${R}\n"
printf "  ${GRN}+background = #2d353b${R}\n"
printf "  ${RED}-foreground = #d3c5a9${R}\n"
printf "  ${GRN}+foreground = #d3c6aa${R}\n"
echo ""
printf "  ${D}# 2 files changed, 4 insertions(+), 2 deletions(-)${R}\n"
echo ""
