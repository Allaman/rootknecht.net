---
title: My Workplace
type: posts
draft: false
date: 2021-10-11
tags:
  - business
  - configuration
  - hardware
  - workflow
resources:
  - name: head
    src: head.png
  - name: carbon
    src: carbon.jpg
    title: Lenovo x1 Carbon Gen 9
  - name: desktop
    src: desktop.png
    title: Minimal desktop view
  - name: shell
    src: shell.png
    title: Alacritty with tmux and Git/K8s context/AWS profile info
  - name: neovim
    src: neovim.png
    title: Neovim and Go
  - name: ansible
    src: ansible.png
    title: Ansible playbook running
  - name: desk
    src: desk.jpg
    title: office
---

This is the successor of my blog post [my laptop setup](/blog/my-laptop-setup) where I want to give an update for my hardware and software I use for my daily business.
This article is divided into three parts. In the first part I want to give you an overview about the hardware I am currently working with. In the second part I want to talk about the software running on my laptop and in the last part I want to talk about my desk.

<!--more-->

{{< img name=head lazy=false description=false >}}

{{< toc >}}

## Hardware[^1]

### Laptop

{{< img name=carbon lazy=true >}}

Recently, I upgraded my [Lenovo X1 Carbon Gen 6](/blog/my-laptop-setup/#laptop) to the [Gen 9 model](https://www.lenovo.com/de/de/laptops/thinkpad/thinkpad-x1/X1-Carbon-G9/p/22TP2X1X1C9) with the following specs:

- Intel® Core™ i7-1165G7 11. generation (2,80 GHz, up to 4,70 GHz Turbo Boost, 4 cores, 8 threads, 12 MB Cache)
- Intel® Iris® Xe Graphics
- 32 GB LPDDR4X 4266MHz (soldered)
- 1 TB PCIe-SSD
- 14.0" WUXGA (1920x1200) IPS, mate, 400 cd/m², 100% sRGB, Multitouch
- Intel Wi-Fi 6 AX201 (2x2 AX) & Bluetooth® 5.0
- Quectel EM120R-GL 4G/LTE Cat. 12

The main reason for upgrading my perfectly running Gen 6 model (which will replace my father's loyal [x220](http://localhost:1313/blog/my-laptop-setup/#why-lenovo)) was RAM. Although equipped with 16 GB memory there are scenarios where RAM was the limitation. For instance compiling [native Quarkus applications](https://quarkus.io/guides/building-native-image) which is a huge RAM eater or running a local multi node Kubernetes cluster including deployments like Prometheus/Grafana monitoring stack.

The second major change of my new X1 is the display which you might think is a step back from the 4k display of my previous Gen 6 model. While technically spoken this is true there was a huge drawback from running 4k resolution. It was quite hard for me to read text because it was just so tiny and working with 4k was too exhausting for my eyes. But there is scaling, isn't it? Unfortunately, scaling is something that does not work so well in most Linux desktop environments (for me!). Either you can only scale to 200%, no steps in between, (too big 😠) or scaling does not affect every application or scaling for different screens is not possible/feasible. A full HD screen with an 14" panel is in my opinion the perfect sweet spot without any scaling needs.

Read more about my reasons for Lenovo [in my old post](blog/my-laptop-setup/#why-lenovo).

Unfortunately, I experienced some quirks:

1. You MUST upgrade your firmware. Earlier firmware versions are affected by heavy throttling making the system unresponsive ([Lenovo Forum](https://forums.lenovo.com/topic/view/1301/5073083)).
2. While being connected to my monitor via USB-C a wake-up after suspension resulted in full load on one core, although no process was using that much CPU. Turns out that `Linux S3` mode was the issue. After switching to `Windows and Linux` (s0ix or connected standby) in the BIOS settings this issue was resolved. Apparently, Intel [dropped S3 support](https://www.reddit.com/r/System76/comments/k7xrtz/ill_have_whatever_intel_was_smoking_when_they/) for there Tiger Lake CPUs.

### Keyboard and mouse

My keyboard of choice is currently a [Razer BlackWidow Elite](https://www.razer.com/gaming-keyboards/razer-blackwidow-elite/RZ03-02620200-R3U1). It is a solid (and heavy) mechanical keyboard with nice (tactile) feel and also very usable for non gaming tasks 😉. The USB pass through and the audio volume dial are some handy features. I never got used to my [Ergodox-ez](/blog/ergodox-ez/) because it is so different that my productivity dramatically decreases when trying to use this keyboard. Unfortunately, I do not have the patience of practicing and refactoring my muscle memory.

There is no difference for my mice to my previous setup. My main mouse is a [Logitech MX vertical](https://www.logitech.com/de-de/product/mx-vertical-ergonomic-mouse) because of the ergonomic advantages compared to a "traditional" mouse. My travel mouse is a [Logitech MX Anywhere 2S](https://www.logitech.com/de-de/product/mx-anywhere-2s-flow). I am very happy with both of them and the ability to safe three devices on the Logitechs and switch per hardware button is awesome!

{{< hint info >}}
I am not running any software from Razer or Logitech, so I cannot tell something about the value of their software, e.g. customizing. All functionality I use from my mice/keyboard is in the default kernel drivers.
{{< /hint >}}

### Periphery

I am still using [Panasonic Bluetooth RP-HD605NE-K9](https://www.panasonic.com/de/consumer/home-entertainment/kopf-ohrhoerer/kopfhoerer/rp-hd605n.html) headphones and the [Inateck USB C Hub](https://www.amazon.de/gp/product/B07QXYS1WM) dock (especially for mobile work to be prepared for all potential connectivity needs). I added a [Logitech C930e](https://www.logitech.com/de-de/products/webcams/c930e-business-webcam.960-000972.html) webcam and an iPad Pro 2020 for taking notes, reading books and drawing logos/images for my media needs 🙂.

### Monitor

My eyes are looking at the [Dell UltraSharp 27 4K-USB-C](https://www.dell.com/de-de/shop/ultrasharp-27-4k-usb-c-monitor-u2720q/apd/210-aves/monitore-und-monitorzubeh%C3%B6r). I have chosen this one because of its IPS panel and built in USB-C dock. This allows me to only connect my laptop via the USB-C and my other devices (webcam, keyboard, USB-sticks, ...) are connected via the monitor and passed through the monitor to my laptop. To increase the number of available USB ports I connected a [Aukey USB Hub](https://www.aukey.com/products/aukey-usb-3-0-hub-ultra-slim-aluminum-4-port-usb-hub) to the monitor.

The monitor itself is mounted on a [1home Full Motion Gas Spring Single Arm Desk](https://www.amazon.de/gp/product/B079HQQPJT). This gives me a cleaner desk and more room on my table. Furthermore, I can easily adjust my monitor angles if necessary. As mentioned earlier 4k resolution is too tiny and scaling was not the best experience for me. Therefore, my monitor is not set to its maximum resolution but to 2560x1440.

You might ask why I am not running a second monitor? Then you would be surprised when I tell you that my laptop screen is switched off while connected to the Dell monitor 🙂. **For me** one single screen to look at is the most efficient way of getting things done. Firstly, My eyes and head are focused straight forward of me and I do not need to turn around to look at another screen. Secondly, while using only one screen I always know exactly where all my apps are opened, and I don't need to search them on other monitors. Of course, I do make heavy use of virtual desktops!

## Software

### OS

My OS of choice is still [Manjaro](https://manjaro.org/). Despite the fact that it is based on [Arch Linux](https://archlinux.org/) it is a very user-friendly distribution and highly recommended even for not experienced Linux users in contrast to the "pure" Arch. I replaced my previous used [window manager](https://en.wikipedia.org/wiki/Window_manager) [i3wm](https://i3wm.org/) with a full [desktop environment](https://en.wikipedia.org/wiki/Desktop_environment): [XFCE](https://www.xfce.org/)

Reasons for my switch from i3wm to XFCE:

1. Although I would still prefer tiling window managers over desktop environments I needed something more reliable. Don't get me wrong, i3wm is reliable and stable! By reliable, I mean something that is more comfortable to use without writing a new script to accomplish a task or without reading man pages for commands I rarely use.
2. XFCE offers a lightweight alternative to KDE (which I was using for several years) or GNOME
3. I started my computer story with Windows, and I am used to a traditional layout (task bar)🙈. XFCE offers a classic desktop, although you can heavily customize this (surprise 😉).

{{< img name=desktop lazy=true >}}

### Applications

{{< img name=shell lazy=true >}}

#### PIM

I am still running the [same setup](/blog/my-laptop-setup/#pim-setup) expect that I switched from [Mutt](http://www.mutt.org/) to its fork [NeoMutt](https://neomutt.org/)

#### Coding

I removed every text editor from my toolbox and all my text editing / coding needs are satisfied with NeoVim. You can find my config at [Github](https://github.com/Allaman/nvim).

{{< img name=neovim lazy=true >}}

#### Shell

I switched back to [alacritty](https://github.com/alacritty/alacritty) as my terminal emulator after running [wezterm](https://github.com/wez/wezterm) a couple of months. Both are fast, GPU accelerated and customizable emulators.

My favorite shell is still [zsh](https://www.zsh.org/). I don't use [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) anymore or any other kind of plugin manager but manage everything "manually" respectively let Ansible manage my [shell configuration](https://github.com/Allaman/ansible-role-shell) in conjunction with my [dotfiles configuration](https://github.com/Allaman/ansible-role-dotfiles) and [binaries repo](https://github.com/Allaman/ansible-role-binaries).

Besides NeoVim and Zsh plugins there are some tools I heavily rely on:

- [zoxide](https://github.com/ajeetdsouza/zoxide) for fast "jumping" to folders
- [ripgrep](https://github.com/BurntSushi/ripgrep) as convenient replacement for `grep`
- [fd](https://github.com/sharkdp/fd) as convenient replacement for `find`
- [gitui](https://github.com/extrawurst/gitui) a feature rich Git TUI
- [p10k](https://github.com/romkatv/powerlevel10k) a flexible and fast Zsh theme
- [lf](https://github.com/gokcehan/lf) a customizable and lightweight file manager
- [tmux](https://github.com/tmux/tmux) an advanced terminal multiplexer
- [xbindkeys](https://linux.die.net/man/1/xbindkeys) for managing my keyboard shortcuts without being dependent on a specific desktop environment or window manager
- [flameshot](https://github.com/flameshot-org/flameshot) a feature rich screenshot tool
- [keepassxc](https://keepassxc.org/) open source password manager
- [Firefox](https://www.mozilla.org/de/firefox/new/) anti chromium based browser 😉
- [hledger](https://hledger.org/) for keeping track of my expenses

... and a lot more. Have a look at my list of [CLI](/knowledge/applications/cli/) and [GUI](/knowledge/applications/gui/) applications.

### Automation

For the configuration of my laptop I use [Ansible](https://www.ansible.com/). Ansible is a common tool in the area of [Infrastructure as Code](/blog/devops/#infrastructure-as-code) for IT automation purposes.

You can find my playbook at [Github](https://github.com/Allaman/rice). This playbook allows me to automatically configure 90% of my settings and tools of a fresh installation in a matter of minutes.

{{< img name=ansible lazy=true >}}

## Desk/Chair

{{< img name=desk lazy=true >}}

My desk consists of two parts:

1. The [table top](https://www.amazon.de/boho-m%C3%B6belwerkstatt-Schreibtischplatte-Kratzfestigkeit-Belastbarkeit/dp/B07BFJBKC8) — really just a wooden plate ☺
2. The [stand](https://www.amazon.de/gp/product/B07K7PDWYK/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1) — vertically adjustable stands with a small electrical engine and up to 4 memory slots

Both of them feel very solid and reliable and gives my desk a clean and tidy look.

My chair is a [noblechairs Epic](https://www.noblechairs.de/epic-series/gaming-stuhl-pu-leder). This is my first ergonomic "gaming" chair, and I am very happy the ergonomics and quality. This is on another level compared to the run-of-the-mill office chair.

[^1]: I am not sponsored by any company in this article
