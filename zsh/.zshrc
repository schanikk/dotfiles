# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Homebrew (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
  plugins=(git macos)
else
  plugins=(git)
fi

source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

# Keep PATH entries unique
typeset -U path

# pipx / local binaries
path+=("$HOME/.local/bin")

# bun
export BUN_INSTALL="$HOME/.bun"
path=("$BUN_INSTALL/bin" $path)
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias cot="open -a CotEditor"
fi
alias claude-work='CLAUDE_CONFIG_DIR=~/.claude-work ~/.local/bin/claude'
alias claude-personal='CLAUDE_CONFIG_DIR=~/.claude-personal ~/.local/bin/claude'
alias claude="echo 'Use specific commands: claude-work or claude-personal'"
