# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# macOS-specific plugins
if [[ "$OSTYPE" == "darwin"* ]]; then
  plugins=(git dotenv macos)
else
  plugins=(git dotenv)
fi

source $ZSH/oh-my-zsh.sh

# Preferred editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

# pipx
export PATH="$PATH:$HOME/.local/bin"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Aliases
alias cot="open -a CotEditor"
