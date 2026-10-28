#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc
fi

echo "==> Installing Neovim plugins via lazy.nvim (this may take a minute)..."
nvim --headless "+Lazy! sync" +qa 2>&1

echo "==> Installing Mason LSP servers and tools (this may take several minutes)..."
nvim --headless "+MasonToolsInstallSync" +qa 2>&1

echo "==> Installing treesitter parsers..."
# Keep in sync with the filetypes list in nvim/init.lua
nvim --headless -c "lua require('nvim-treesitter').install({ 'bash', 'c', 'diff', 'html', 'json', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'query', 'toml', 'vim', 'vimdoc', 'yaml' }):wait(300000)" -c qa 2>&1

echo ""
echo "==> Setup complete. Run 'nvim' to start."
