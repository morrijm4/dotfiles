# dotfiles

Personal configuration for macOS — zsh, neovim, git, karabiner, claude code.

## Install

```sh
git clone https://github.com/morrijm4/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks every tracked file into its expected location under `$HOME`. If a real file already exists at the destination, it's backed up as `<path>.backup.<timestamp>` before the symlink replaces it.

Re-running `install.sh` is safe — existing symlinks are replaced in place.

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

Source files are stored without the leading dot for easier browsing on GitHub; the install script adds the dot when linking.

## Adding a new file

1. Move the file into the repo (e.g. `mv ~/.tmux.conf tmux/tmux.conf`).
2. Add a `link` line to `install.sh`.
3. Re-run `./install.sh`.
4. Commit.

## Not tracked

SSH keys, `gh`/`op` auth, shell history, completion caches, and most of `~/.claude/` (sessions, history, projects) are intentionally excluded. The repo `.gitignore` rejects common secret patterns as a safety net.
