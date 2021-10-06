---
title: Vim
---

{{< toc >}}

## My NeoVim config

{{< hint info >}}
You can find my obsolete [vimrc](https://raw.githubusercontent.com/Allaman/dotfiles/master/vimrc) that should work both with Vim >8.0 and NeoVim. My new [NeoVim >0.5 configuration](https://github.com/Allaman/nvim) is the current setup I use for all of my daily tasks.
{{< /hint >}}

## Safe file opend by an user as root

```
:w !sudo tee %
```

## Search and replace over multiple files

{{< hint info >}}
This is the native vim way. There are plugins like [FAR](https://github.com/brooth/far.vim) that will also do that for you.
{{< /hint >}}

In order to edit multiple files at once you need to load all of them in vim buffers by doing

```
:args `fd -e yaml`
```

!!! You can replace the `fd` command that is responsible for generating the file list with any other suitable command like the regular `find`

Check your buffers with `:buffers`. Your desired files should be loaded.

Now execute a command on all opened buffers, in this case the search and replace:

```
:bufdo %s/SEARCH/REPLACE/ge | update
```

- `bufdo` execute commands on all open buffers
- `%` search the whole buffer
- `g` globally meaning do not stop after the first hit in a line
- `e` suppress warning when pattern is not found
- `update` save all changes

## Delete empty lines

```
:g/^$/d
```

## Replace currently selected text with default register without yanking it

```
vnoremap p "_dP
```

## Open file in binary mode

```bash
vim -b
```

## Add string at the end of lines

- `SHIFT-v` to select lines
- `:norm Astring'

norm means `type the following commands` and the `A` stands for append

## Add string at the start of lines

- `^` to move to the start of the line
- `CTRL-v' to block select your lines
- `SHIFT-I` to insert your string (on _one_ line)
- `ESC` to insert the string on all lines

## Open multiple files in vim tabs

```bash
vim -p [file1] [file2] ...
```

## Convert line endings

```sh
vim +':w ++ff=unix' +':q' FILE
```

or for other endings

- `:w ++ff=dos`
- `:w ++ff=mac`

## Show mappings

```
:map [<C-j>]
:verbose map [<C-j>]
```

## Print infos (within) vim

Prints various information about vim like version, enabled features, compile flags and loaded configuration files.

```
:version
```

## Folding

config using indent as fold method (see also [Modeline](#modeline)):

```
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2
```

- **za**: Toggle at the current line
- **zo**: Open fold
- **zc**: Close fold
- **zR**: Open all folds
- **zM**: Close all folds
- **zm**: Increases the foldlevel by one
- **zr**: Decreases the foldlevel by one
- **zj** Moves the cursor to the next fold
- **zk**: Moves the cursor to the previous fold
- **\[z**: Move to start of open fold
- **]z**: Move to end of open fold
- **zf#j**: Creates a fold from the cursor down # lines
- **zf/string** Creates a fold from the cursor to string
- **zd**: Deletes the fold at the cursor
- **zE**: Deletes all folds

## Modeline

By setting `set modeline=1` you can enable the [Modeline Magic](http://vim.wikia.com/wiki/Modeline_magic). When it is not working you can check the setting with the following command:

```
:verbose set modeline?
```

Some distros disable it with `nomodeline` in /etc/vimrc

Example usage folding: This line at the bottom of a file tells vim to use `marker` as foldmethod and fold all foldings after opening the file

```
" vim:foldmethod=marker:foldlevel=0
```

## Startup time

```bash
vim --startuptime vim.log
```

## Debug lag in vim

After starting vim

```
:profile start profile.log
:profile func *
:profile file *
```

Do the stuff that lags and then run `:profile pause` and quit vim. Inspect `profile.log`

## Open vim in debug mode

```bash
vim -D
```

## Quickfix window

```bash
:ccl[ose]
:cope[n]
:cp
:cn
```

## Location window

```bash
:lcl[ose]
:lop[en]
:lp
:ln
```

## Use CAPS as ESC

In Linux use `setxkbmap`:

```bash
setxkbmap -option caps:escape # More options available
setxkbmap -option # to reset changes
```

## NeoVim and vimrc

In `.config/nvim/init.vim` (create if not existing)

```
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
```

## Enter copyright symbol

1. In insert mode
2. `C-k` a question mark will appear
3. Enter `Co`

[Here](https://devhints.io/vim-digraphs) is a cheatsheet about digraphs (how this is called)

## Tabs vs buffers

    A buffer is the in-memory text of a file.
    A window is a viewport on a buffer.
    A tab page is a collection of windows.
