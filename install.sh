#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  already linked $dst"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "  backing up $dst -> ${dst}.bak"
    rm -rf "${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sfn "$src" "$dst"
  echo "  linked $dst"
}

echo "==> Linking config files..."
link "$DOTFILES/nvim"        "$HOME/.config/nvim"
link "$DOTFILES/zsh/.zshrc"  "$HOME/.zshrc"

echo "==> Running bootstrap..."
OS="$(uname)"
if [ "$OS" = "Darwin" ]; then
  bash "$DOTFILES/bootstrap/macos.sh"
elif [ "$OS" = "Linux" ]; then
  bash "$DOTFILES/bootstrap/linux.sh"
else
  echo "Unsupported OS: $OS" && exit 1
fi
