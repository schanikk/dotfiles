#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v apt-get &>/dev/null; then
  echo "Unsupported distro: only Debian/Ubuntu (apt-get) is supported." >&2
  exit 1
fi

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO=sudo

echo "==> Installing Linux system dependencies..."
$SUDO apt-get update -q
$SUDO apt-get install -y --no-install-recommends \
  git curl wget unzip gcc libc6-dev make \
  ripgrep fd-find \
  python3 python3-venv \
  xclip xsel \
  ca-certificates \
  zsh fontconfig gzip tar xz-utils

# Debian/Ubuntu ships fd as 'fdfind'; nvim/telescope expect 'fd'
if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
  $SUDO ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

# apt's nodejs is often too old; use NodeSource LTS if missing or < 20
NODE_MAJOR=0
command -v node &>/dev/null && NODE_MAJOR="$(node -v | sed 's/^v//; s/\..*//')"
if [ "$NODE_MAJOR" -lt 20 ]; then
  echo "==> Installing Node.js LTS (NodeSource)..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | ${SUDO:+$SUDO -E} bash -
  $SUDO apt-get install -y nodejs
fi

ARCH="$(uname -m)"
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  NVIM_ASSET="nvim-linux-arm64.tar.gz"
  TS_ASSET="tree-sitter-linux-arm64.gz"
else
  NVIM_ASSET="nvim-linux-x86_64.tar.gz"
  TS_ASSET="tree-sitter-linux-x64.gz"
fi

# Install Neovim from official tarball (apt version is often too old)
echo "==> Installing Neovim (stable)..."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -fL -o "$TMP/nvim.tar.gz" \
  "https://github.com/neovim/neovim/releases/download/stable/${NVIM_ASSET}"
$SUDO rm -rf "/opt/${NVIM_ASSET%.tar.gz}"
$SUDO tar -C /opt -xzf "$TMP/nvim.tar.gz"
$SUDO ln -sfn "/opt/${NVIM_ASSET%.tar.gz}/bin/nvim" /usr/local/bin/nvim
echo "  $(nvim --version | head -1)"

# nvim-treesitter (main branch) needs the tree-sitter CLI
if ! command -v tree-sitter &>/dev/null; then
  echo "==> Installing tree-sitter CLI..."
  curl -fL -o "$TMP/tree-sitter.gz" \
    "https://github.com/tree-sitter/tree-sitter/releases/latest/download/${TS_ASSET}"
  gunzip -f "$TMP/tree-sitter.gz"
  $SUDO install -m 0755 "$TMP/tree-sitter" /usr/local/bin/tree-sitter
fi

# Nerd Font (only useful when a font cache exists, i.e. desktop/terminal host)
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
if command -v fc-cache &>/dev/null && [ ! -d "$FONT_DIR" ]; then
  echo "==> Installing JetBrainsMono Nerd Font..."
  mkdir -p "$FONT_DIR"
  curl -fL -o "$TMP/JetBrainsMono.tar.xz" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
  tar -C "$FONT_DIR" -xJf "$TMP/JetBrainsMono.tar.xz"
  fc-cache -f
fi

# Default shell -> zsh (non-fatal)
if [ "$(basename "${SHELL:-}")" != "zsh" ] && command -v chsh &>/dev/null; then
  chsh -s "$(command -v zsh)" || echo "  could not change shell; run: chsh -s \$(command -v zsh)"
fi

bash "$DOTFILES/bootstrap/common.sh"
