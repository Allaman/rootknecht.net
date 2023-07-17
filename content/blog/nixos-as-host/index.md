---
title: NixOS as Container Host
type: posts
draft: false
date: 2023-07-17
tags:
  - container
  - tools
  - workflow
  - nixos
---

My first experiment with NixOS was likely in October 2021, at least according to my Git log for my slightly outdated [NixOS](https://rootknecht.net/knowledge/linux/nixos/) page 😄. Since then, I tried to get used to NixOS and/or Nix as a package manager alternative several times but with little success. In this post I want to illustrate how I finally found a purpose for NixOS and also how this allowed me to dodge its steep learning curve!

<!--more-->

{{< toc >}}

## Background

My previous attempts always failed miserable due to the enormous differences[^1] of NixOS compared to traditional Linux distributions and the steep learning curve. It's like if you stumbled over one thing you don't understand, you probably come across two more things, you don't understand, while trying to figure out the first thing 😆.

Currently, my main machine is a MacBook Pro M1 after 10 years of ThinkPads with Linux[^2], but I still owe my ThinkPad X1 9th Generation which acts as a backup device. I was unhappy with Majaro and I have too much free time (not) so I came up with the idea to give NixOS another shoot.

This time, instead of running NixOS in a virtual machine or trying to replicate a server with NixOS, I wanted to achieve something different [^3].

## Goals

- Running a very stable and (kind of) immutable OS.
- Everything is configured as code. I am a huge advocate of the Infrastructure as Code principle utilizing tools like Terraform, Ansible, Flux2, etc. My complete system should be configurable via code, respectively more generic, via "text files".
- Be able to reproducible configure my ThinkPad from scratch.
- My existing [dotfiles](https://github.com/Allaman/dots) managed via [chezmoi](https://www.chezmoi.io/) must be used and should still work with my MacBook Pro.
- Be able to create dedicated environments for different customers/projects.

## Constraints

- Focus on the very basic features of NixOS to reduce the learning curve.
- Omit [Flakes](https://nixos.wiki/wiki/Flakes) to further reduce the learning curve and to be honest, I have still a hard time understanding flakes.
- Omit [home-manager](https://github.com/nix-community/home-manager) because not all my machines will run home-manager and I don't want to maintain multiple dotfiles and especially duplicate my [Neovim](https://github.com/Allaman/nvim/) configuration.
- Use [i3wm](https://i3wm.org/) as window manager because I have experience with i3 and its configuration is straight forward within a single file.
- Single user and single machine only (for now).

## Approach

My plan is to use NixOS as a base system / host system with very little basic programs / tools. On top of NixOS I will spawn [distrobox](https://github.com/89luca89/distrobox) containers including all the tools necessary for my workflows. Those containers are disposable as a) no data is stored inside and b) they are automatically configured.

{{< hint info >}}
You can have a look at my configuration in my [dots](https://github.com/Allaman/dots/tree/main/dot_nixos) repo.
{{< /hint >}}

### NixOS aka the host system

#### Syncthing

In order to set up my [dotfiles](https://github.com/Allaman/dots), I require my SSH key and my [Age](https://github.com/FiloSottile/age) key to be able to run `chezmoi`. I am a heavy user of [Syncthing](https://syncthing.net/) to sync my files across devices, relying on my home lab as a central "data sink". To set up Syncthing to "pull" my SSH and my Age key, I use the following snippet in my `configuration.nix` file:

```nix
  services = {
    syncthing = {
      enable = true;
      user = "michael";
      configDir = "/home/michael/.config/syncthing";
      overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      overrideFolders = true;     # overrides any folders added or deleted through the WebUI
      extraOptions = {
        globalAnnounceEnabled = false;
      }
      devices = {
        # https://docs.syncthing.net/users/faq.html#should-i-keep-my-device-ids-secret
        "unraid" = { id = "42GWJCT-VAONXMN-UNQVPRX-MVX6VHC-CSFKYFI-7MJX7QT-7VPK7SV-XJUFHAG"; addresses = [ "tcp://192.168.178.62:22222" ]; };
      };
      folders = {
        "secrets" = {                  # Label of the folder
          id = "lkumh-nvc74";          # ID of the folder
          path = "~/.secrets/";        # Which folder to add to Syncthing
          devices = [ "unraid" ];      # Which devices to share the folder with
          type = "receiveonly";        # One of "sendreceive" "sendonly" "receiveonly" "receiveencrypted"
          ignorePerms = false;         # Whether to ignore permission changes
        };
      };
    };
  };
```

#### Packages

As said, NixOS should only act as a host system for my DistroBox containers and only run mostly GUI and very basic tools.

My system packages managed by Nix are as follows:

```nix
environment.systemPackages = with pkgs; [
    acpi # battery interfae
    arandr # simple app to configure displays
    brightnessctl # for manipulating screen brightness
    curl
    gcc
    git
    gnumake
    htop
    networkmanagerapplet # tray icon
    pulseaudio # for audio controlls
    unzip
    wget
    xorg.xhost # give permission to access X-server from a container
    zip
];
```

My user packages managed by Nix are as follows:

```nix
packages = with pkgs; [
    firefox # best browser
    alacritty # terminal application
    xautolock # automatic screen locking
    flameshot # Screenshots
    keepassxc # password manager
    distrobox # Linux distribution as Podman/Docker
];
```

I consider this packages as common and very basic, so they are managed at the host level.

### Podman

To enable Podman in NixOS, I added the following snippet to my `configuration.nix`:

```nix
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
  };
```

Now, I can utilize familiar Docker commands like `docker ps`.

## DistroBox

DistroBox allows you to

> Use any Linux distribution inside your terminal.

With DistroBox I can create disposable and project-/client-specific containers without altering the host system [^4]

### Create the default container

This container acts as my default container for non project specific tasks.

```sh
distrobox-create --name default --init --image docker.io/library/archlinux:latest
distrobox-enter default
```

`--name` sets the name of the container and its hostname.
`--init` enables the init system inside the container which also prevents from accessing the host's processes.
`--image` specifies which Docker image to use.

### Configure the default container

For now, I only run a simple bash script to configure the container, but I could switch to e.g. Ansible for a more sophisticated approach.

```sh
#!/bin/bash
set -e

sudo pacman --noconfirm -S base-devel ueberzug

# Install brew
NONINTERACTIVE=1 /bin/bash -c \
	"$(curl -fsSL \
		https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH

# Install packages
brew install \
	age \
	chezmoi \
	fd \
	gcc \
	git \
	gitui \
	go \
	java \
	lf \
	libnotify \
	nodejs \
	ripgrep \
	tig \
	tmux \
	trash-cli \
	xclip \
	zoxide

# Install Neovim nightly
brew install neovim --head

# Download my dotfiles bootstrap script
wget https://raw.githubusercontent.com/Allaman/dots/main/bootstrap.sh
chmod +x bootstrap.sh
```

{{< hint info >}}
Refer to the [homepage](https://distrobox.privatedns.org/) for more details.
{{< /hint >}}

### Host integration

My default terminal shortcut opens a terminal within my default container:

```
bindsym $mod+Return exec --no-startup-id alacritty -e distrobox-enter default
```

In order to allow sharing the system clipboard between containers xhost is called at startup.

```
exec --no-startup-id xhost +si:localuser:$USER
```

## Nix shell

If you are familiar with Nix(OS) you might ask why are you not using `nix shell` respectively `nix-shell`? A legitimate question!

To be honest, the answer is because of Neovim. My Neovim [config](https://github.com/Allaman/nvim) depends on Mason for downloading the required binaries for my config[^5]. Due to the nature of NixOS, running binaries does not always work[^6]. Regarding my setup, `stylua`, `lua-language-server`, and `marksman` are affected binaries with presumably hard coded paths. There are solutions described in [^6], but they are a little bit challenging for me.

As I mentioned earlier, I am not willing to rewrite my Neovim configuration. With this approach, I can circumvent this limitation by running Neovim inside a container with a "normal" Linux file system where paths are available.

## Conclusion

With this approach I can combine the best of two worlds. NixOS as a rock solid unbreakable and sort of immutable host system and Distrobox providing a layer where "normal Linux rules" apply.

[^1]: I won't go into detail what NixOS/Nix is and what its benefits and culprits are.
[^2]: See my post [Moving from Linux to macOS](https://rootknecht.net/blog/moving-to-macOS/)
[^3]: Inspired by [NixOS: Containerized and Immutable](https://www.youtube.com/watch?v=VqUKpNXnRxs) on YouTube
[^4]: Be aware that the [hosts home directory is always mounted](https://github.com/89luca89/distrobox/blob/main/docs/usage/distrobox-create.md), even if you specify a [custom home directory](https://github.com/89luca89/distrobox/blob/main/docs/useful_tips.md#create-a-distrobox-with-a-custom-home-directory). Because of this behavior I decided to not specify a dedicated home directory for my containers. Therefore, my hosts home directory is shared between my containers.
[^5]: Why Mason, another package manager, and not aptitude, or pacman, or brew, or nix, or ...? My idea was, to let Mason manage the packages the same way on each OS and not to struggle with setting up each package manager on my various systems.
[^6]: "Downloading and attempting to run a binary on NixOS will almost never work. This is due to hard-coded paths in the executable." from the [NixOS wiki](https://nixos.wiki/wiki/Packaging/Binaries)
