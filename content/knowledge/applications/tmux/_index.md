---
title: Tmux
summary: "Notes on Tmux - the best terminal multiplexer"
---

{{< figure src=tmux.png >}}

Find my tmux config [here](https://raw.githubusercontent.com/Allaman/dotfiles/master/tmux.conf) and [here](https://github.com/Allaman/dotfiles) all of my dotfiles

## Why tmux

1. Multiple shell windows and panes from a single connection
2. Session functionality that survives disconnects
3. Session sharing
4. Plugins extend functionality
5. Keyboard driven
6. Highly customizable

Alternative: `screen` which comes preinstalled on most distributions

## Basic concepts

1. **Windows** are like tabs in your internet browser
2. **Panes** are splits of windows each containing an individual shell
3. **Sessions** represent a state of different windows and panes

## Starting tmux

```bash
tmux # start fresh session
tmux new-session -s NAME # create new session with NAME
tmux a # attach to session
tmux a -t NAME # attach to named session
tmux ls # list running sessions
tmux kill-session -t NAME # kill session NAME
```

## Commands

Commands are composed of the **tmux prefix (default CTRL+b) and the actual command**. Be aware that my config may vary!

| command  | action                             |
| -------- | ---------------------------------- |
| prefix c | create new window                  |
| prefix n | switch to window number n          |
| prefix & | kill current window                |
| prefix w | list windows                       |
| prefix , | rename window                      |
| prefix . | move window to given number        |
| prefix % | split window vertically            |
| prefix " | split window horizontally          |
| prefix x | kill current pane                  |
| prefix d | detach tmux (back to normal shell) |
| prefix ? | list shortcuts                     |
| prefix t | show big clock                     |

## Command prompt

With `:`you can start a command prompt similar to Vim's ex mode. Tab-autocompletion is available

## Advanced

### Respawn tmux pane

In tmux command mode

```
:respawn-pane -k
```

### Set tmux as login shell

In your .bashrc or zshrc

```bash
if command -v tmux>/dev/null; then
  [[ ! $TERM =~ screen ]] && [ -z $TMUX ] && exec tmux
fi
```

### Attach to a tmux session within tmux

list sessions

```
: list-sessions
```

Attach to session identified by its number

```
: attach-session -t NUMBER
```
