---
title: One year macOS (after 10 years Linux)
type: posts
draft: false
date: 2022-11-26
tags:
  - business
  - configuration
  - hardware
  - workflow
---

In my post [moving from Linux to macOS](/blog/moving-to-macOS/) from Dezember 2021 I described my motivation and my process of switching from Linux to macOS as my daily driver. In this post I want to describe my experience with macOS and especially "the bad" and "the ugly" topics from last year's post.

<!--more-->

{{< toc >}}

{{< hint info >}}
No brand or company is sponsoring/paying me. This is my personal opinion and experience, your mileage may vary.
{{< /hint >}}

## Overall experience

I am pretty happy with my move to macOS and don't regret it. What I still see as superior to my previous Lenovo X1 Carbon / Linux setup is as follows:

- No fan noise (if it is running at all)
- Long lasting battery
- Better selection of certain applications, e.g. the [Affinity Suite](https://affinity.serif.com/en-gb/)
- No Kernel / firmware / driver shenanigans
- No hassle with audio devices and switching between them
- Confident (un)docking with my Dell UltraSharp monitor
- Flawless sleep and wake up

In the next section I will pick up the complaints from my previous post and the current situation.

## The bad

### Hardware

    The MBP is heavier at 1.6 kg in contrast to the 1.1 kg of the X1C and also bulkier with some sharp edges.

Well, this is still the case but 95% of the time my MBP is docked, and I work with external keyboards and mice.

    There is no mechanical cover of the internal webcam.

Also, no change. 90% of the time the MBP's lid is closed, and I work with my external monitor.

    Only HDMI 2.0 (instead of 2.1).

Since I bought the MBP I have never used its HDMI port.

    Only UHS-II SD card reader (instead of UHS-III).

It is fast enough for my use cases.

    Missing USB-A port.

Most of my peripherals have USB-C connectors. In addition, while docked I can use my monitor's USB-A ports.

    Missing Ethernet port (like most of its competitors).

99% of the time my (slower) WLAN connection is sufficient. When I really need Ethernet because of transfer speed I use my little USB-C dock.

    THe internal keyboard is a fingerprint magnet.

Most of the time I don't work with the internal keyboard.

    The notch divides opinions. For me, the notch is not disturbing at all.

Still, the notch is not an issue at all for me.

    No middle mouse button as with my X1C’s Trackpoint buttons for pasting from the selection clipboard (use middleclick for emulating middle click with three finger tap)

[MiddleClick](https://middleclick.app/) is working absolutely fine.

    Scrolling with my Logitech MX vertical is not smooth and almost not usable. Furthermore, the back/forward keys do not work. I use LinearMouse to solve both issues.

[LinearMouse](https://github.com/linearmouse/linearmouse) works flawlessly

    No dedicated PAGE-UP, PAGE-DOWN, END, HOME Keys. I barely used those because of my Vim bindings everywhere.

Most of the time I work with an external (PC style) keyboard and I still prefer vim movement where possible.

### Software

    alacritty is not yet available as native ARM build (you could compile it yourself)

Alacritty has now an [ARM build](https://github.com/alacritty/alacritty/pull/4727).

    CMD-TAB shows applications from all spaces and not just the active one (➡️ alt-tab)
    CMD-TAB does not separate between different application windows (➡️alt-tab)

[alt-tab](https://alt-tab-macos.netlify.app/) does its job

    CMD-q closes windows, especially dangerous when trying to type @ like on a PC keyboard (right CMD-q will also close). I use a karabiner modification that only quits applications when CMD-q is pressed twice.

Still running the karabiner modification and absolutely happy.

    Alt-. must be configured or can be replaced by ESC-. (for inserting previous arguments in bash).

I am used to `ESC-.`.

    Maximized windows are not really maximized, and the borders are disruptive, especially when grabbing a border by mistake instead of a scroll bar.

This is still the case, but I don't notice it anymore.

    Why does RETURN in finder rename a folder and not enter it?

I replaced Finder with [Forklift 3](https://binarynights.com/)

## The ugly

### Hardware

    The keyboard layout. I am used to a standard PC keyboards since my first PC.

    Brackets: OPT-5: [, OPT-6: ] and OPT-8: {, OPT-9: }
    Pipe: OPT-7: |
    Tilde: OPT-n: ~? (conflicts with my tmux bindings)
    At: OPT-l: @ (conflicts with my tmux bindings)
    With heavy use of karabiner modifications, I remapped all keys for a similar experience to a PC keyboard while using my external keyboard.

Most of the time I am working with an external keyboard. I have a lot of Karabiner modifications to simulate a QWERTZ keyboard that I am used to. I even have modifications for the internal keyboard so that there is no difference compared to an external keyboard. For instance my right command key is mapped to act as `altGr` key allowing me to type `@`, `|`, and `~` like I am used to from a QWERTZ PC layout.

    Despite the excellent Touchpad, I miss the Trackpoint and its dedicated mouse buttons as those allowed me to keep my finger always on the home row.

When I am working with the internal keyboard this is still the case despite the excellent touchpad. But again, the majority of the time I am working with external peripherals.

### Software

    Lag after switching spaces (article with video). Seriously Apple?

[yabai](https://github.com/koekeishiya/yabai) is an alternative tiling window manager for macOS. With yabai there is no lag when switching desktops with its own shortcuts which is the main reason for using it. Yabai has a so called `float` mode which does not manage your window layout meaning you don't need to use its tiling window features.

    LUKS encrypted external hard drive cannot be read by macOS (there is no workaround)

I don't use LUKS encrypted hard drives with my MBP.

    Calibre is not (yet) available as native package, and there is no alternative. Calibre runs with Rosetta well, but I don’t want to enable the emulation layer.

In the meantime, calibre is available as native ARM build.

    ueberzug depends on x11 and is not available (used for preview files in Terminal in conjunction with lf). Till now, I came to no solution for this (special) setup.

I switched from alacritty to Kitty which comes with builtin support for [icat](https://sw.kovidgoyal.net/kitty/kittens/icat/). Nevertheless, my need for image preview in the terminal decreased.

    Missing primary selectionacross the OS. It is available in iTerm2. In Linux every text selected, no matter where, is copied to the clipboard and can be pasted with a mouse middle click.

No change. At the beginning it was annoying, but now I barely think about this topic.

    Why is there no cut in finder?

I got used to it 😆

## New thoughts

On macOS [Homebrew](https://brew.sh/) is pretty much mandatory. I learned that there is also [Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux) which allows me to manage my tools on Linux the same way as on macOS[^1]. Furthermore, Linux distribution profit from a larger and more recent software selection. In the future, I want to try [nix](https://github.com/NixOS/nix) as alternative to Homebrew which is also available on Linux and macOS.

Common Unix tools on macOS are the BSD variants and therefore behave slightly different. As I want my scripts and commands work the same on all my hosts I installed the GNU versions via Homebrew and added them to my PATH.

I moved from using [RCM](https://github.com/thoughtbot/rcm) for managing my [dotfiles](https://github.com/Allaman/dotfiles) for many years to [chezmoi](https://www.chezmoi.io/) and my new [dots](https://github.com/Allaman/dots) repo. My main reasons for the move are the templating feature and the ease of installation (chezmoi is only a single cross-platform binary). This allows me to manage my dotfiles on different platforms more convenient.

Currently, I am not updating to macOS 13 Ventura. I was once told to not upgrade to x.0 versions of macOS and in addition I see no huge improvements or new features I am excited about.

[^1]: Casks are not available on Linux
