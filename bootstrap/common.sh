#!/usr/bin/env bash
set -e

echo "==> Installing Neovim plugins via lazy.nvim (this may take a minute)..."
nvim --headless "+Lazy! sync" +qa 2>&1

echo "==> Installing Mason LSP servers and tools (this may take several minutes)..."
nvim --headless \
  "+MasonInstall lua-language-server pyright typescript-language-server html-lsp tailwindcss-language-server clangd prettier stylua autopep8 isort flake8 mypy markdownlint ast-grep autoflake oxlint markdown-oxide" \
  +qa 2>&1

echo ""
echo "==> Setup complete. Run 'nvim' to start."
