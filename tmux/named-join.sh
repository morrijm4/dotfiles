#!/usr/bin/env bash
# Preserve a window's name across join-pane / break-pane.
#
# join-pane destroys the source window (and its name) when its last pane
# moves. We stash the name on the pane as a user option so a later
# break-pane can restore it. The pane option travels with the pane.

case "${1:-}" in
  join)
    win=${2:-}
    [ -n "$win" ] || exit 0
    name=$(tmux display-message -p -t "$win" '#{window_name}')
    tmux set -p -t "$win" @orig_win_name "$name"
    tmux join-pane -h -s "$win"
    ;;
  break)
    name=$(tmux display-message -p '#{@orig_win_name}')
    if [ -n "$name" ]; then
      # name explicitly chosen earlier; pin it so auto-rename can't clobber it
      tmux break-pane -n "$name"
      tmux set -w automatic-rename off
      tmux set -pu @orig_win_name
    else
      tmux break-pane
    fi
    ;;
esac
