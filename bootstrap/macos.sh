#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# C compiler is needed to build treesitter parsers
if ! xcode-select -p &>/dev/null; then
  echo "==> Xcode Command Line Tools missing; starting installer..."
  xcode-select --install || true
  echo "Re-run ./install.sh once the installation has finished."
  exit 1
fi

echo "==> Installing macOS dependencies via Homebrew..."
brew bundle --file="$DOTFILES/Brewfile"

bash "$DOTFILES/bootstrap/common.sh"
