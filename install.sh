#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "Backing up $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sfn "$src" "$dst"
  echo "  linked $dst"
}

echo "==> Linking config files..."
mkdir -p "$HOME/.config"
link "$DOTFILES/nvim"          "$HOME/.config/nvim"
link "$DOTFILES/zsh/.zshrc"   "$HOME/.zshrc"

echo "==> Running bootstrap..."
OS="$(uname)"
if [ "$OS" = "Darwin" ]; then
  bash "$DOTFILES/bootstrap/macos.sh"
elif [ "$OS" = "Linux" ]; then
  bash "$DOTFILES/bootstrap/linux.sh"
else
  echo "Unsupported OS: $OS" && exit 1
fi
