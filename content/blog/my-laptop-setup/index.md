---
title: My Laptop Setup
summary: In this post I give an overview of my current Laptop and some of my hardware I use for work.
description: lenovo, linux, productivity, configuration
type: posts
date: 2020-08-30
tags:
  - productivity
  - hardware
  - configuration
  - linux
---

{{< alert >}}
Please visit [My Workplace 2021](/blog/my-workplace-2021/) for an updated version!
{{< /alert >}}

## Hardware

### Laptop

I am running a Lenovo X1 Carbon 6th Generation[^1] with following specs:

- Intel Core i7-8550U processor (8 MB Cache, up to 4,00 GHz)
- Intel UHD-Grafik 620
- 16 GB LPDDR3 2.133 MHz (soldered)
- 1 TB SSD, M.2 2280, PCIe, NVMe, OPAL 2.0-enabled
- 35,6 cm (14") WQHD (2.560 x 1.440), IPS, anti-glare, 300 cd/m²
- Intel Dualband-Wireless-AC 8265 (2x2) WLAN
- Fibocom Cat9 L850-GL 4G LTE

{{< figure src=x1carbon.png caption="Lenovo x1 Carbon 6th Gen" >}}

### Why Lenovo

My first Lenovo Laptop was the superior [x220](https://thinkwiki.de/X220) and I was totally impressed by its lightweight form factor _and_ its performance. My father is still running it today (as of July 2020)! I was so impressed that I even upgraded just after one year to the successor [x230](https://thinkwiki.de/X230) that was my main working machine until May 2019!

At this point I was totally committed to run Lenovo laptops for two main reasons:

1. Lenovo's trackpoint. I am almost as fast as with a real mouse by using the trackpoint despite my [workflow](#workflow-philosophy) being heavily keyboard centric.
2. Lenovo's keyboards are top notch! The classical ones even more than the newer chiclet ones but still top notch! I even [replaced](https://knowledge.rootknecht.net/thinkpad-adventures#replacing-x230-keyboard) my keyboard of the x230 with an old one :)

Of course there are more reasons like excellent performance, build quality, and the classical look.

### Peripherals and Gadgets

Besides my X1 I use an [ErgoDZ EZ](https://knowledge.rootknecht.net/ergodox-ez) or [Lioncast LK 30](https://knowledge.rootknecht.net/ergodox-ez) keyboard, a [Logitech MX Anywhere 2S](https://www.logitech.com/de-de/product/mx-anywhere-2s-flow) when I am on the go or an ergonomic [Logtiech MX Vertical](https://www.logitech.com/de-de/product/mx-vertical-ergonomic-mouse) at the office, and finally a [Panasonic Bluetooth RP-HD605NE-K9](https://www.panasonic.com/de/consumer/home-entertainment/kopf-ohrhoerer/kopfhoerer/rp-hd605n.html). For more ports I use the [Inateck USB C Hub](https://www.amazon.de/gp/product/B07QXYS1WM) USB C port replicator. For taking notes and reading books I can recommend the [ONYX BOOX Nova](https://onyxboox.com/boox_nova) E-ink device.

## Operating System

I am running the [i3wm](https://i3wm.org/) flavor of [Manjaro Arch Linux](https://manjaro.org/).

In my opinion Manjaro is the best desktop operating system as it provides a good balance between the bleeding edge of pure Arch and the stability of non [rolling release](https://en.wikipedia.org/wiki/Rolling_release) distributions like Ubuntu.

Furthermore, [Pacman](https://wiki.archlinux.org/index.php/Pacman) and the [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository) provide basically packages for every software you can imagine.

Last but not least, the [Arch community](https://wiki.archlinux.org/index.php/Main_page) does a superior job in creating documentation and helpful articles. In my opinion it is the biggest knowledge base of a distribution that is often also applicable for other distributions.

## Desktop Environmnent

Currently, I am not running a [Desktop Environment (DE)](https://en.wikipedia.org/wiki/Desktop_environment) like KDE, Gnome, XFCE, etc. As mentioned earlier I am running a [Window Manager (WM)](https://en.wikipedia.org/wiki/Window_manager) named i3wm. A window manager is usually part of a DE and is responsible for the management of windows within a graphical user interface.

Impressions of my setup:

{{< figure src=desktop.png caption="My wallpaper of choice" >}}
{{< figure src=de.png caption="Some terminals" >}}
{{< figure src=gtop.png caption="Running gtop" >}}

## Applications

{{< alert >}}
Please have a look at [CLI-Applications](https://knowledge.rootknecht.net/cli-applications) and [GUI-Applications](https://knowledge.rootknecht.net/gui-applications) for additional applications I use and recommend.
{{< /alert >}}

### PIM setup

[PIM](https://de.wikipedia.org/wiki/Personal_Information_Manager) manages my contacts, calendar and mails. Currently, my tasks are tracked just in a simple markdown file.

The goal here is to keep my data local and in plain text files to be able utilize powerful text operations. Therefore, there are tow components necessary: One to sync all data to servers so that my mobile is up to data as well and one to display the data.

For synchronizing form servers to my disk and vice versa I use the following two tools: [isync](https://knowledge.rootknecht.net/cli-applications#isync) and [vdirsyncer](https://knowledge.rootknecht.net/cli-applications#vdirsyncer). Both tools speak common protocols like [CaldDAV (calendar](https://en.wikipedia.org/wiki/CalDAV), [CardDAV (contacts)](https://en.wikipedia.org/wiki/CardDAV) respectively [IMAP (mail)](https://en.wikipedia.org/wiki/Internet_Message_Access_Protocol).

For displaying and interacting I use [khal (calendar)](https://knowledge.rootknecht.net/cli-applications#khal), [khard (contacts)](https://knowledge.rootknecht.net/cli-applications#khard), and [mutt (mail)](https://knowledge.rootknecht.net/cli-applications#mutt)

### Coding

My main editor/IDE is a heavily customized [Neovim](https://neovim.io/) a fork of the infamous [Vim](https://www.vim.org/). From time to time I also use the Insiders build of [Visual Studio Code](https://code.visualstudio.com/insiders/) for instance for debugging. At this time VSC is the best graphical editor/IDE available. Somehow my backup text editor is [Sublime Text](https://www.sublimetext.com/). Sublime Text shines with speed and simplicity though it also can be extended with plenty of plugins.

You can find my NeoVim config at [Github](https://github.com/Allaman/nvim)

### Utilities

My workflow is mainly terminal based. Except browsing the web I spend most of the time in front of a black window :) To enhance my experience I use some awesome tools.

Let's begin with the shell itself. I am using zsh with [Fish-like autosuggestions for zsh](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), and [zsh-completions](https://github.com/zsh-users/zsh-completions).
Additionally, I created some dozens of aliases in order to fast execute commands or remap old commands to the new executables. Another important feature of each shell should be a sane history configuration meaning an unlimited history file, shared history between sessions and immediately appending items to the history.

{{< figure src=neofetch.png caption="Compulsory neofetch output" >}}

As terminal I use [termite](https://github.com/thestinger/termite) which is very fast, minimalistic and keyboard-driven or [alacritty](https://github.com/alacritty/alacritty) a super fast cross platform terminal.

In order to move around and find things fast in my terminal there I use a couple of commandline tools. The most important tools are [fzf](https://github.com/junegunn/fzf) and [fasd](https://github.com/clvv/fasd). fzf allows you to quickly fuzzy find files and folders and search your history. Due to the ability to stdin to fzf the customizations are nearly endless.

{{< figure src=fzf.png >}}

Here you can see fzf find invoked by `Ctrl+t`. Notice also the preview window on the right side. By hitting `Ctrl+o` I can open the selected file in my editor or by just entering the path to the file is entered at the cursor in my terminal. As I said the possibilities are endless and you should really give it a try. There is also a [Vim integration](https://github.com/junegunn/fzf.vim).

fasd allows you to quickly jump to folders by indexing and weighting your visited folders. With fasd you don't need to enter the full path of a folder as it also works with fuzzy matching. It is often enough to just enter the folders basename ignoring the full path and fasd will do the rest

`find`, `grep`, `ps`, `cat`, and `ls` are well known tools as Linux user. They are pre installed on each major distribution and are for sure the first tools one would to learn. But there are some alternatives which provide good defaults, are faster, easier to use, looking better, and trying to achieve compatibility to the original programs' arguments and flags.

| original | alternative                                                                    |
| -------- | ------------------------------------------------------------------------------ |
| find     | [fd](https://github.com/sharkdp/fd)                                            |
| grep     | [ripgrep](https://github.com/BurntSushi/ripgrep)                               |
| ps       | [procs](https://github.com/dalance/procs)                                      |
| cat      | [bat](https://github.com/sharkdp/bat)                                          |
| ls       | [exa](https://github.com/ogham/exa) or [lsd](https://github.com/Peltoche/lsd/) |
| htop     | [gtop](https://github.com/aksakalli/gtop)                                      |

{{< alert >}}
Nevertheless, I strongly recommend to learn the original tools as you cannot assume to find those replacements on each system!
{{< /alert >}}

## Dotfiles

[Here](https://github.com/Allaman/dotfiles) you can find some of my dotfiles.

## Workflow Philosophy

I am a keyboard fan. For the things I do the keyboard is the primary input method as most of the time I handle with some form of textual data. Actually, my main reason for switching to a Linux OS back in 2009 was to be able to operate my Laptop with my keyboard only because I always forgot my mouse. After some years of fear of Vim, caused by not being able to quit it, I decided to give it a deeper try not aware of the impact of my style of work!

Since that my usage of Vim improved a lot and I discovered and still discover new features every day. Furthermore, Vim's [modal editing](https://en.wikipedia.org/wiki/Vi#Interface) approach inspired me to only use applications that support Vim-like key bindings. In my opinion the productivity highly increases when not just using keyboard shortcuts but also barely leave the Home Row. Vim-like key bindings strongly support not this pattern on regular keyboard layouts[1], I decided to give it a deeper try. My skills in using Vim improved a lot and I discovered and still discover new features every day. Furthermore, Vim's modal editing approach inspired me to only use applications that support Vim-like key bindings. In my opinion the productivity highly increases when not just using keyboard shortcuts but also barely leave the [Home Row](https://www.computerhope.com/jargon/h/hrk.htm). Vim-like key bindings strongly support not this pattern on regular keyboard layouts[^2] like qwert[z|y].

Here is a not comprehensive list of applications that support Vim-like key bindings:

- [Vim Vixen](https://en.wikipedia.org/wiki/Vi#Interface) &rarr; a vim plugin for Firefox
- [mutt](http://www.mutt.org/) and [neomutt](https://neomutt.org/) &rarr; mail clients with vim key bindings
- [vifm](https://vifm.info/) and [ranger](https://github.com/ranger/ranger) &rarr; file managers
- [zathura](https://git.pwmt.org/pwmt/zathura) &rarr; keyboard driven lightweight pdf viewer
- [newsboat](https://newsboat.org/) &rarr; terminal RSS reader
- [sc-im](https://github.com/andmarti1424/sc-im) &rarr; ncurses spreadsheet with Vim's modal editing
- [sxiv](https://github.com/muennich/sxiv) &rarr; an image viewer
- [qutebrowser](http://qutebrowser.org/) &rarr; keyboard-focused web browser
- [tig](https://github.com/jonas/tig) &rarr; a git ncurses interface
- [termite](https://github.com/thestinger/termite) &rarr; a terminal with build in vim like keybindings
- every major IDE/editor like [Visual Studio Code](https://code.visualstudio.com/), [Intellij IDEA](https://www.jetbrains.com/idea/), [Eclipse](https://www.eclipse.org/ide), etc. can be extended with a Vim plugin

Another aspect which is quite controversy is my preference when it comes to multi monitor operation. I don't have one! In my opinion I can work best by only focusing on one screen with one maximized window and optionally panes like Vim's split view. I find it way to distracting working with two or more monitors to properly identify which window is active, where my mouse is and always turning my head in the right direction. In order to be productive with just one screen I have some rules that are anchored in my subconsciousness:

1. Use virtual desktops and strictly order them e.g. on my first desktop is always my web browser
1. Use shortcuts to efficiently switch between desktops
1. Use shortcuts or a tiling window manager to be able to easily tile two windows on one desktop if necessary
1. Use a launcher application to start applications fast
1. Use less bloated applications to reduce GUI elements and focus on content
1. Use a drop down Terminal like [Yakuake](https://kde.org/applications/system/org.kde.yakuake) for quick terminal tasks without modifying your current desktop
1. Let the WM handle the window management ;)

[^1]: I am not sponsored by any company in this article

[^2]: I cannot speak for [dvorak](https://en.wikipedia.org/wiki/Dvorak_Simplified_Keyboard), [neo](https://neo-layout.org/), and other special layouts
