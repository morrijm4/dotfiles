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
echo "done. backups (if any) live alongside originals as *.backup.<timestamp>"
