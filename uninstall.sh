#!/usr/bin/env bash
#
# Linux uninstaller for jaaw
# Supports local execution & one-line uninstaller (curl -fsSL ... | bash)
# Usage: ./uninstall.sh [PREFIX] [--purge] (default PREFIX=/usr/local)

set -euo pipefail

# Colors and styling
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
RESET='\033[0m'

PREFIX="/usr/local"
PURGE=false
INTERACTIVE=true

for arg in "$@"; do
    case "$arg" in
        --purge|-p)
            PURGE=true
            INTERACTIVE=false
            ;;
        --non-interactive|-y)
            INTERACTIVE=false
            ;;
        -h|--help)
            echo -e "${BOLD}Usage:${RESET} $0 [PREFIX] [--purge]"
            echo "  PREFIX   Installation directory prefix (default: /usr/local)"
            echo "  --purge  Also delete configuration & device history (~/.config/jaaw)"
            exit 0
            ;;
        *)
            if [[ "$arg" != -* ]]; then
                PREFIX="$arg"
            fi
            ;;
    esac
done

echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${RED}${BOLD}                    UNINSTALLING JAAW                             ${RESET}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Find binary
DEST="$PREFIX/bin/jaaw"
if [ ! -f "$DEST" ] && command -v jaaw >/dev/null 2>&1; then
    DEST=$(command -v jaaw)
fi

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/jaaw"

# Remove binary
if [ -f "$DEST" ]; then
    if [ -w "$DEST" ] || [ -w "$(dirname "$DEST")" ]; then
        rm -f "$DEST"
    elif command -v sudo >/dev/null 2>&1; then
        sudo rm -f "$DEST"
    fi
    echo -e "  [✓] Berhasil menghapus binary        : ${GREEN}$DEST${RESET}"
else
    echo -e "  [i] Binary $DEST tidak ditemukan."
fi

# Remove completions
for comp in /usr/share/bash-completion/completions/jaaw \
            /etc/bash_completion.d/jaaw \
            /usr/share/zsh/site-functions/_jaaw \
            /usr/share/fish/vendor_completions.d/jaaw.fish; do
    if [ -f "$comp" ]; then
        if [ -w "$comp" ] || [ -w "$(dirname "$comp")" ]; then
            rm -f "$comp" 2>/dev/null || true
        elif command -v sudo >/dev/null 2>&1; then
            sudo rm -f "$comp" 2>/dev/null || true
        fi
        echo -e "  [✓] Berhasil menghapus completion    : ${GREEN}$comp${RESET}"
    fi
done

# Check if purge should be asked interactively
if [ "$PURGE" = false ] && [ "$INTERACTIVE" = true ] && [ -d "$CONFIG_DIR" ]; then
    if [ -t 0 ] || [ -e /dev/tty ]; then
        echo ""
        echo -ne "${YELLOW}Hapus juga seluruh riwayat & konfigurasi perangkat ($CONFIG_DIR)? [y/N]: ${RESET}"
        ans=""
        if [ -e /dev/tty ]; then
            read -r ans </dev/tty || true
        else
            read -r ans || true
        fi
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            PURGE=true
        fi
    fi
fi

# Purge config if requested
if [ "$PURGE" = true ]; then
    if [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
        echo -e "  [✓] Berhasil menghapus riwayat & config: ${GREEN}$CONFIG_DIR${RESET}"
    fi
else
    if [ -d "$CONFIG_DIR" ]; then
        echo ""
        echo -e "  ${DIM}[i] Riwayat perangkat di $CONFIG_DIR tetap dipertahankan.${RESET}"
        echo -e "  ${DIM}    (Gunakan flag '--purge' jika ingin menghapus seluruh data)${RESET}"
    fi
fi

echo ""
echo -e "${GREEN}${BOLD}[✓] Selesai! jaaw telah berhasil di-uninstall dari sistem.${RESET}"

