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

echo
echo "done. backups (if any) live alongside originals as *.backup.<timestamp>"
