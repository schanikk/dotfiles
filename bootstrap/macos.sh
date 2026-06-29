#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing macOS dependencies via Homebrew..."
brew install neovim ripgrep fd node python3 unzip

bash "$DOTFILES/bootstrap/common.sh"
