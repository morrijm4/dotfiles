# dotfiles

Personal configuration for macOS — zsh, neovim, git, karabiner, claude code.

## Install

```sh
git clone https://github.com/morrijm4/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh`:
1. Symlinks every tracked file into its expected location under `$HOME`. If a real file already exists at the destination, it's backed up as `<path>.backup.<timestamp>` before the symlink replaces it.
2. Installs Homebrew if it's missing, then runs `brew bundle install --file=Brewfile` to install the listed CLI tools and casks.

Re-running `install.sh` is safe — existing symlinks are replaced in place, and `brew bundle` is idempotent.

## Layout

| Source | Linked to |
|---|---|
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/zprofile` | `~/.zprofile` |
| `git/gitconfig` | `~/.gitconfig` |
| `git/gitignore_global` | `~/.config/git/ignore` |
| `karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` |
| `nvim/` | `~/.config/nvim` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `Brewfile` | (read by `brew bundle install`) |

Source files are stored without the leading dot for easier browsing on GitHub; the install script adds the dot when linking.

## Adding a new file

1. Move the file into the repo (e.g. `mv ~/.tmux.conf tmux/tmux.conf`).
2. Add a `link` line to `install.sh`.
3. Re-run `./install.sh`.
4. Commit.

## Adding a brew package

Edit `Brewfile`, add `brew "<name>"` for CLI tools or `cask "<name>"` for GUI apps, then `brew bundle install --file=Brewfile`. To snapshot everything currently installed, run `brew bundle dump --force --file=Brewfile`.

## Not tracked

SSH keys, `gh`/`op` auth, shell history, completion caches, and most of `~/.claude/` (sessions, history, projects) are intentionally excluded. The repo `.gitignore` rejects common secret patterns as a safety net.
