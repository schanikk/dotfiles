#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing Linux system dependencies..."
sudo apt-get update -q
sudo apt-get install -y --no-install-recommends \
  git curl wget unzip gcc make \
  ripgrep fd-find \
  nodejs npm \
  python3 python3-pip \
  xclip xsel \
  ca-certificates \
  zsh

# Debian/Ubuntu ships fd as 'fdfind'; nvim/telescope expect 'fd'
if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
  sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
fi

# Install Neovim from official tarball (apt version is often too old)
echo "==> Installing Neovim (stable)..."
ARCH="$(uname -m)"
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  NVIM_ASSET="nvim-linux-arm64.tar.gz"
else
  NVIM_ASSET="nvim-linux-x86_64.tar.gz"
fi
curl -Lo /tmp/nvim.tar.gz \
  "https://github.com/neovim/neovim/releases/download/stable/${NVIM_ASSET}"
sudo tar -C /opt -xzf /tmp/nvim.tar.gz
sudo ln -sfn "/opt/${NVIM_ASSET%.tar.gz}/bin/nvim" /usr/local/bin/nvim
rm /tmp/nvim.tar.gz
echo "  $(nvim --version | head -1)"

# Install Oh My Zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc
fi

bash "$DOTFILES/bootstrap/common.sh"
