---
title: "CLI Applications"
geekdocDescription: A list and description of CLI apps I use in my workflow
---

A brief overview of **c**ommand **l**ine **i**nterface applications I use and highly recommend!
See [GUI Applications](https://knowledge.rootknecht.net/gui-applications) for more.

{{< toc >}}

## awless

[awless](https://github.com/wallix/awless)

- AWS CLI wrapper
- written in Go
- intuitive set of (sub)commands
- templating language
- different terminal outputs
- see also [bash-my-aws](#bash-my-aws)

## bash-my-aws

[bash-my-aws](gghttps://github.com/bash-my-aws/bash-my-aws)

- AWS CLI wrapper scripts
- written in Bash
- Unix pipeline friendly
- short memorable commands
- command completion
- see also [awless](#awless)

## bat

[bat](https://github.com/sharkdp/bat)

- `cat` alternative
- written in Rust
- syntax highlighting
- Git integration
- automatic paging

## broot

[broot](https://github.com/Canop/broot)

- navigate your files with ease from your terminal
- cd+ls+tree+du replacement and more
- written in R
- configurable and scriptable

## cheat.sh

[cheat.sh](https://github.com/chubin/cheat.sh)

- cheatsheet interface
- written in Python
- 56 programming languages, several DBMSes, and more than 1000 UNIX/Linux commands
- simple curl/browser interface
- fast
- CLI client `cht.sh`

## cloc

[cloc](https://github.com/AlDanial/cloc)

- count lines of code
- written in Perl
- autodetects languages
- comments agnostic

## delta

[delta](https://github.com/dandavison/delta)

- alternative to [diff-so-fancy](#diff-so-fancy)
- enhanced and customizable diff view
- written in Rust

## diff-so-fancy

[diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)

- alternative for `git diff`
- customizable and nice looking
- written in Perl

## direnv

[direnv](https://github.com/direnv/direnv)

- automatic context aware .profile
- written in Go
- shell hooks for zsh, fish, bash, ...

## dua-cli

[dua-cli](https://github.com/Byron/dua-cli)

- alternativ to `du`
- written in Rust
- cross platform
- very fast
- interactive (`dua i`)

## duf

[duf](https://github.com/muesli/duf)

- alternativ to `df`
- cross platform
- written in Go
- very fast
- nice looking

## entr

[entr](https://github.com/eradman/entr)

- run arbitrary commands when files change
- cross platform
- written in Go
- endless possibilities

## exa

[exa](https://the.exa.website/)

- `ls` alternative
- similar to [lsd](#lsd)
- written in Rust
- fast
- colored multi column output
- respects git status
- single binary

## extract

[extract](https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/extract/extract.plugin.zsh)

- oh-my-zsh plugin
- written in bash
- auto detects and extracts various compressed formats
- simple and easy to use
- required "backend" commands (like zip or tar) must be installed

## fd

[fd](https://github.com/sharkdp/fd)

- `find` alternative
- written in Rust
- fast
- provides sane defaults
- does not intend to fully replace find

## figlet

[figlet](http://www.figlet.org/)

- ASCII letter generator
- cross platform
- customizable

## fasd

[fasd](https://github.com/clvv/fasd)

- fast navigation in your shell
- written in shell
- quickaccess to files, directories
- inspired by autojump, z, and v

## forgit

[forgit](https://github.com/wfxr/forgit)

- interactive git
- written in Bash
- utilizes [fzf](#fzf)
- see [tig](#tig) for an alternative

## fzf

[fzf](https://github.com/junegunn/fzf)

- command line fuzyy finder
- written in Golang
- endless use cases
- portable
- Integration in tmux, vim, bash, zsh, ...
- [skim](https://github.com/lotabout/skim) - alternative written in Rust

See [here](https://knowledge.rootknecht.net/fzf) for some of my tweaks

## gitui

[gitui](https://github.com/extrawurst/gitui)

- Git TUI
- written in Rust
- cross platform
- customizable
- vim like bindings
- [my conf](https://github.com/Allaman/dotfiles/tree/master/config/gitui)

## glances

[glances](https://github.com/nicolargo/glances)

- fancy top alternative
- written in Python
- similar to [gotop](#gotop) and [htop](#htop)
- including webserver
- cross platform
- remote monitoring

## glow

[glow](https://github.com/charmbracelet/glow)

- render markdown on the cli
- written in Go
- styles and paging
- read from URL
- similar to [bat](#bat)

## gotop

[gotop](https://github.com/cjbassi/gotop)

- fancy top alternative
- written in Go
- similar to [glances](#glances) and [htop](#htop)
- colorscheme support
- includes network, temperatures and more

## hledger

[hledger](https://hledger.org/)

- double entry accounting
- written in Haskell
- ledger compatible
- Web UI, ncurses, API, reports, and more

## htop

[htop](https://github.com/hishamhm/htop)

- enhanced version of `top`
- written in C
- ncurses UI
- Alternatives: [glances](#glances) and [gotop](#gotop)

## iftop

[iftop](http://www.ex-parrot.com/pdw/iftop/)

- `top` like interface for bandwidth usage
- written in C

## iotop

[iotop](http://guichaz.free.fr/iotop/)

- `top` like interface for ingoing/outgoing
- written in python

## isync

[isync](http://isync.sourceforge.net/)

- IMAP and MailDir synchronization
- written in C
- control every aspect of synchronization

## jq

[jq](https://github.com/stedolan/jq)

- process json files
- cross platform
- written in C

## khard

[khard](https://github.com/scheibler/khard)

- CardDAV client
- written in Python
- [mutt](#mutt) integration
- in combination with [vdirsyncer](#vdirsyncer)

## khal

[khal](https://github.com/pimutils/khal)

- calendar application
- written in Python
- reads and writes events/icalendars
- in combination with [vdirsyncer](#vdirsyncer)

## lazygit

[lazygit](https://github.com/jesseduffield/lazygit)

- alternative to [tig](#tig)
- simple terminal UI for git
- written in Go
- no dependencies
- cross platform

## lf

[lf](https://github.com/gokcehan/lf)

- file manager
- written in Go
- three pane style
- vim like keybindings
- no dependencies
- similar to [ranger](#ranger)
- alternatives: [nnn](https://github.com/jarun/nnn), [vifm](#vifm), [ranger](#ranger)

## lsd

[lsd](https://github.com/Peltoche/lsd)

- `ls` alternative
- similar to [exa](#exa)
- written in Rust
- fast
- colored multi column output
- single binary
- icons

## mstmp

[msmtp](https://marlam.de/msmtp/)

- SMTP Client
- written in C
- sendmail compatible

## mu-repo

[mu-repo](http://fabioz.github.io/mu-repo/)

- manage multiple git repos
- run git commands on multiple repos
- discover git repos in your file system

## mutt

[mutt](http://www.mutt.org/)

- full featured mail client
- written in C
- highly customizable and scriptable
- vim like keybindings

## ncdu

[ncdu](https://dev.yorhel.nl/ncdu)

- ncurses disk usage
- written in C
- fast and simple to use

## ngrep

[ngrep](https://github.com/jpr5/ngrep)

- user friendly `tcpdump` alternative
- written in C
- PCAP based

## nnn

[nnn](https://github.com/jarun/nnn)

- terminal file manager
- written in C
- cross platform
- very fast
- highly customizable

## pandoc

[Pandoc](https://pandoc.org/)

- text converter
- written in Haskell
- supports many many formats
- md to pdf, html, ...

## pdfgrep

[pdfgrep](https://gitlab.com/pdfgrep/pdfgrep)

- grep for pdfs
- cross platform
- written in C++

## prettyping

[prettyping](https://github.com/denilsonsa/prettyping)

- wrapper around ping
- written in bash
- colorful and easy to read

## procs

[procs](https://github.com/dalance/procs)

- alternative to `ps`
- written in Rust
- open source
- nice looking and handy functionality
- customizable

## ranger

[ranger](https://github.com/ranger/ranger)

- file manager
- written in Python
- three pane or two pane style
- highly customizable and scriptable
- vim like keybindings
- alternatives: [vifm](#vifm), [nnn](https://github.com/jarun/nnn), [mc](https://midnight-commander.org/), [lf](#lf)

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep)

- `grep` alternative
- written in Rust
- fast
- mostly grep compatible
- sane default settings

[Comprehensive comparison](https://beyondgrep.com/feature-comparison/) of grep alternatives.

## rofi

[rofi](https://github.com/davatorium/rofi)

- window switcher, application launcher, ssh, scripting and more
- written in C
- highly customizable and scriptable
- vim like keybindings

## spacemacs

[spacemacs](https://github.com/syl20bnr/spacemacs)

- Emacs distribution
- combines Emacs and Vim
- written in elisp

## spacevim

- Vim distribution
- like spacemacs for Vim
- written in Vim script

## ssh_scan

[ssh_scan](https://github.com/mozilla/ssh_scan)

- SSH configuration and policy scanner
- written in Ruby
- by Mozilla
- portable and configurable

## storm

[storm](https://github.com/emre/storm)

- ssh management wrapper
- written in Python
- add, edit, delete, and list your `.ssh/config` entries
- various UIs

## sxhkd

[sxhkd](https://github.com/baskerville/sxhkd)

- hotkey utility
- written in C
- works across all Distributions with x server

## thefuck

[thefuck](https://github.com/nvbn/thefuck)

- corrects previously entered commands
- written in Python
- supports various commands like git, apt, etc
- can be extended with custom rules

## translate-shell

[translate-shell](https://github.com/soimort/translate-shell)

- language translation in your shell
- powered by Google Translate (default) , Bing Translator, Yandex.Translate, and Apertium
- written in Awk
- self contained executable

## tig

[tig](https://github.com/jonas/tig)

- modern text interface for git
- written in C
- ncurses UI

## tmux

[tmux](https://github.com/tmux/tmux)

- terminal multiplexer
- alternative to `screen`
- written in C
- [basic intro](https://knowledge.rootknecht.net/tmux)

## tokei

[tokei](https://github.com/XAMPPRocky/tokei)

- count lines of code
- cross platform
- written in Rust

## trash-cli

[trash-cli](https://github.com/andreafrancia/trash-cli)

- `rm` alternative with trashcan
- written in Python
- deleted files can be restored

## urlview

[urlview](https://github.com/sigpipe/urlview)

- extract URLs from text
- written in C
- [mutt](#mutt) and [tmux](#tmux) integration and more

## vagrant

[vagrant](https://github.com/hashicorp/vagrant)

- build your environments
- VirtualBox, VMWare, KVM, Public Cloud, ...
- written in Ruby
- cross platform

## vdirsyncer

[vdirsyncer](https://github.com/pimutils/vdirsyncer)

- synchronize calendars and contacts
- written in Python
- CardDAV / CalDAV support
- fine control

## viddy

[viddy](https://github.com/sachaos/viddy)

- `watch` replacement
- cross platform
- written in Go
- "rewind" function
- vim like keymaps

## vidir

[vdir](https://linux.die.net/man/1/vidir)

- bulk edit directories and files in a vim buffer
- part of most Linux distributions

## vifm

[vifm](https://github.com/vifm/vifm)

- file manager
- written in C
- [MC](https://midnight-commander.org/) look and feel
- highly customizable and scriptable
- vim like keybindings
- alternatives: [ranger](#ranger), [nnn](https://github.com/jarun/nnn), [lf](#lf)

## w3m

[w3m](http://w3m.sourceforge.net/)

- text-based web browser
- written in C
- Vim like keybindings
- renders html for other apps (like mutt)
- alternatives: [links2](http://links.twibright.com/), [Lynx](https://lynx.browser.org/), [Elinks](http://elinks.or.cz/index.html)

## xsv

[xsv](https://github.com/BurntSushi/xsv)

- CSV parsing and manipulation
- written in Rust
- indexing, slicing, analyzing, splitting and joining

## youtube-dl

[youtube-dl](https://ytdl-org.github.io/youtube-dl/index.html)

- download videos from video platforms
- written in Python
- by far not limited to youtube
- convert videos to mp4

## yq

[yq](https://github.com/mikefarah/yq)

- [jq](#jq) for yaml
- cross platform
- written in Go

## Webservices

### Weather

```sh
curl wttr.in/München
```

### Crypto currencies

```sh
curl eur.rate.sx/eth
```

### External IP

```sh
curl ipecho.net/plain
```

### Translator

Translates marked text to **de** with the Google translate API and displays the result via `notify-send`

```sh
notify-send --icon=info "$(xsel -o)" \
	"$(wget -U "Mozilla/5.0" -qO - "http://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=de&dt=t&q=$(xsel -o | sed "s/[\"'<>]//g")" \
    | sed "s/,,,0]],,.*//g" | awk -F'"' '{print $2, $6}')"
```

### Cheatsheet

```sh
curl cht.sh/ls
curl cht.sh/python/dirs+recursive
```

See [cheat.sh](https://knowledge.rootknecht.net/cli-applications#cheat-sh)

### Latencies

```sh
curl cheat.sh/latencies
```

### Generate QR codes

```sh
curl qrenco.de/https://google.com
curl qrenco.de/Hello%20World
```

### URL Shortener

```sh
curl -s http://tinyurl.com/api-create.php\?url=https://google.com
```

### Random commit messages

```sh
curl -sk https://whatthecommit.com/index.txt
```

### Star Wars in terminal

```sh
nc towel.blinkenlights.nl 23
```
