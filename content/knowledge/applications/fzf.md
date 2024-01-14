---
title: FZF
summary: Notes on working with FZF, the swiss army knife of CLI fuzzy searching
---

## fzf

[fzf](https://github.com/junegunn/fzf) is a CLI fuzzy finder with endless possibilities. If you want to improve your terminal workflow you **must** check this out.

Use cases (at least for me - there are way more):

- fuzzy find any file on your machine
- fuzzy find the shell history
- fuzzy find directories
- open and search files within vim
- search through tags, lines, commits, and windows in vim

## fzf.vim

- make ESC work in fzf buffer

```sh
autocmd  FileType fzf tnoremap <Esc> <C-c>
      \| autocmd BufLeave <buffer> tnoremap <Esc> <C-\><C-n>
```

- Keymappings

```sh
nnoremap <C-p> :Files<CR>
nnoremap <leader>rg :Rg<CR>
nnoremap <leader>fr :History<CR>
nnoremap <leader>w :Windows<CR>
nnoremap <leader>; :BLines<CR>
nnoremap <leader>: :BTags<CR>
nnoremap <leader>c :Commits<CR>
nnoremap <leader>ft :Filetypes<CR>
```

- Adjust colortheme

```sh
let g:fzf_colors =
\ { 'fg':      ['fg', 'Comment'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'String'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Boolean'],
  \ 'pointer': ['fg', 'Boolean'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
```

- Adjust layout

```sh
let $FZF_DEFAULT_OPTS .= ' --no-height'
" disable statusline overwriting
let g:fzf_nvim_statusline = 0
" In Neovim, you can set up fzf window using a Vim command
let g:fzf_layout = { 'window': 'enew' }
let g:fzf_layout = { 'window': '-tabnew' }
let g:fzf_layout = { 'window': '10split enew' }
```

## fzf tweaks

- `export FZF_COMPLETION_TRIGGER=',,'`

  Allows to trigger fzf after arbitrary commands, for instance `vim ,,` /TAB/ invokes fzf

- `export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute:vim {} > /dev/tty'"`

  Enables you to directly open a file for fzf results with ctrl-o

- `export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"`

  Shows a preview of highlighted files in fzf

- `export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"`

  Directory structure preview of highlighted directories within fzf

- `command -v rg >/dev/null 2>&1 && export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'`

  Use [ripgrep](https://github.com/BurntSushi/ripgrep) when it is installed as default
