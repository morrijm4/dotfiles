#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1" dst="$HOME/$2"
  if [[ ! -e "$src" ]]; then
    echo "skip $dst (source $src missing)" >&2
    return
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local backup="$dst.backup.$(date +%s)"
    mv "$dst" "$backup"
    echo "backed up $dst -> $backup"
  fi
  ln -sfn "$src" "$dst"
  echo "linked $dst -> $src"
}

link zsh/zshrc                .zshrc
link zsh/zprofile             .zprofile
link git/gitconfig            .gitconfig
link git/gitignore_global     .config/git/ignore
link karabiner/karabiner.json .config/karabiner/karabiner.json
link nvim                     .config/nvim
link claude/settings.json     .claude/settings.json

echo

# Install Homebrew if missing, then install packages from Brewfile.
if ! command -v brew >/dev/null 2>&1; then
  echo "homebrew not found; installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if command -v brew >/dev/null 2>&1 && [[ -f "$DOTFILES/Brewfile" ]]; then
  echo "running brew bundle..."
  brew bundle install --file="$DOTFILES/Brewfile"
fi

# Install Neovim from official release tarball (not via brew — see ~/notes).
# Bump NVIM_VERSION to upgrade.
NVIM_VERSION="v0.11.7"
NVIM_DIR="$HOME/.local/nvim/$NVIM_VERSION"

if [[ ! -x "$NVIM_DIR/bin/nvim" ]]; then
  arch="$(uname -m)"
  case "$arch" in
    arm64)  asset="nvim-macos-arm64" ;;
    x86_64) asset="nvim-macos-x86_64" ;;
    *) echo "unsupported arch for nvim install: $arch" >&2; exit 1 ;;
  esac
  url="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$asset.tar.gz"
  tmp="$(mktemp -d)"
  echo "installing neovim $NVIM_VERSION from $url..."
  curl -fsSL "$url" | tar -xz -C "$tmp"
  xattr -c "$tmp/$asset/bin/nvim" 2>/dev/null || true
  mkdir -p "$(dirname "$NVIM_DIR")"
  mv "$tmp/$asset" "$NVIM_DIR"
  rm -rf "$tmp"
  echo "installed neovim to $NVIM_DIR"
else
  echo "neovim $NVIM_VERSION already at $NVIM_DIR"
fi

mkdir -p "$HOME/.local/bin"
ln -sfn "$NVIM_DIR/bin/nvim" "$HOME/.local/bin/nvim"
echo "linked $HOME/.local/bin/nvim -> $NVIM_DIR/bin/nvim"

echo
echo "done. backups (if any) live alongside originals as *.backup.<timestamp>"
