FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
# Override at build time: docker build --build-arg DOTFILES_REPO=https://github.com/you/dotfiles.git
ARG DOTFILES_REPO=https://github.com/tillschaland/dotfiles.git

RUN apt-get update -q && apt-get install -y --no-install-recommends \
    git curl wget unzip gcc make \
    ripgrep fd-find \
    nodejs npm \
    python3 python3-pip \
    xclip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf "$(which fdfind)" /usr/local/bin/fd

# Install Neovim from official tarball (handles x86_64 and arm64)
RUN ARCH="$(uname -m)"; \
    [ "$ARCH" = "aarch64" ] \
      && ASSET="nvim-linux-arm64.tar.gz" \
      || ASSET="nvim-linux-x86_64.tar.gz"; \
    curl -Lo /tmp/nvim.tar.gz \
      "https://github.com/neovim/neovim/releases/download/stable/${ASSET}" \
    && tar -C /opt -xzf /tmp/nvim.tar.gz \
    && ln -sfn "/opt/${ASSET%.tar.gz}/bin/nvim" /usr/local/bin/nvim \
    && rm /tmp/nvim.tar.gz

# Clone dotfiles and link nvim config
RUN git clone ${DOTFILES_REPO} /root/dotfiles \
    && mkdir -p /root/.config \
    && ln -s /root/dotfiles/nvim /root/.config/nvim

# Install lazy.nvim plugins — separate layer so Mason rebuilds don't bust this cache
RUN nvim --headless "+Lazy! sync" +qa 2>&1 || true

# Install Mason LSP servers and tools
RUN nvim --headless \
    "+MasonInstall lua-language-server pyright typescript-language-server html-lsp tailwindcss-language-server clangd prettier stylua autopep8 isort flake8 mypy markdownlint ast-grep autoflake oxlint markdown-oxide" \
    +qa 2>&1 || true

WORKDIR /workspace
CMD ["/bin/bash"]
