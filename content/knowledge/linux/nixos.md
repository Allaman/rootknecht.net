---
title: NixOS
summary: Notes on configuring NixOS
---

## Installation

We download the ISO image from the [official Homepage](https://nixos.org/nixos/download.html) and mount it as boot device in our virtual machine (usually through a admin panel of your provider).

{{< alert >}}
There are also some other install methods. At the time writing this namely AWS, Azure, and OVA.
{{< /alert >}}

### Preparation

Setting a German keyboard layout with `loadkeys de` was not working but we will access the live image within ssh anyway as the web panel of my machine from my provider is not very convenient. We must set a password for the root user (which is empty initially) and start the ssh daemon:

```bash
passwd # set password for current user
systemctl start sshd
```

Now we are able to ssh into our booted iso image and benefit from the better usability.

### Partitioning

First, we must create a (simple) partitioning layout.

```bash
fdisk /dev/sda
-> o new dos partitioning table
-> n new primary partition (will be /)
-> n new primary partition (will be swap)
-> w write changes
```

Now we create the filesystem

```bash
mkfs.ext4 -L nixos /dev/sda1
mkfs.ext4 -L nixos /dev/sda1
```

and mount the file system were we gonna install NixOS

```bash
mount /dev/disk/by-label/nixos /mnt
```

We enable our swap partition with `swapon /dev/disk/by-label/swap`

### NixOS Configuration

In order to install NixOS we need to create a initial configuration skeleton with `nixos-generate-config --root /mnt`. We can adjust the settings in `/mnt/etc/nixos/configuration.nix`. In my case I changed the following lines:

```
# Path where the bootloader should be installed
boot.loader.grub.device = "/dev/sda";
# german keyboard but english system language
i18n = {
  consoleFont = "Lat2-Terminus16";
  consoleKeyMap = "de";
  defaultLocale = "en_US.UTF-8";
};
# My timezone
time.timeZone = "Europe/Berlin";
# additional packages to be installed
environment.systemPackages = with pkgs; [
  wget vim curl htop
];
# add sshd and allow root login for further config
services.openssh = {
  enable = true;
  permitRootLogin = "yes";
};
```

### Install

Simple do a `nixos-install` which will last only a minute or so and asks for the root password. After a reboot NixOS should start and you can login with the root account through ssh.

## NixOS post installation

The main config file of NixOS is `/etc/nixos/configuration.nix`. After each modification the changes must be propagate to the system (see [NixOS Commands](../nixos-commands)).

### Syntax of configuration.nix

`{ config, pkgs, ... }:` defines a function with at least to arguments returning `{ option definitions}` which are a set of `name = value` pairs.

#### Options

Example for enabling Apache2 service

```
{ config, pkgs, ... }:

{ services.httpd.enable = true;
  services.httpd.adminAddr = "alice@example.org";
  services.httpd.documentRoot = "/webroot";
}
```

Which is equal to

```
{ config, pkgs, ... }:

{ services = {
    httpd = {
      enable = true;
      adminAddr = "alice@example.org";
      documentRoot = "/webroot";
    };
  };
}
```

{{< alert >}}
Dots in option names are shorthand for a set containing another set
{{< /alert >}}

Options have a specified type. The most important are:

1. Strings

   `networking.hostName = "dexter";`.
   Special characters need to be escaped with `\`. Multi-line strings are enclosed with double single quotes, e.g.

   ```
   networking.extraHosts =
       ''
           127.0.0.2 other-localhost
           10.0.0.1 server
       '';
   ```

1. Booleans

   Can be true or false, e.g. `networking.firewall.enable = true;`

1. Integers

   `boot.kernel.sysctl."net.ipv4.tcp_keepalive_time" = 60;`.
   Here, net.ivp4 is enclosed in quotes to prevent it from being interpreted is set of sets. This is just the name of the kernel option

1. Sets

   ```
       fileSystems."/boot" =
     { device = "/dev/sda1";
       fsType = "ext4";
       options = [ "rw" "data=ordered" "relatime" ];
     };
   ```

1. Lists

   `boot.kernelModules = [ "fuse" "kvm-intel" "coretemp" ];`.
   Note that elements are separated by white spaces and can be of any type, e.g. sets `swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];`

1. Packages

   ```
     environment.systemPackages =
     [ pkgs.thunderbird
       pkgs.emacs
     ];

   postgresql.package = pkgs.postgresql90;
   ```

{{< alert >}}
A comprehensive list of options can be found at [NixOS options](https://nixos.org/nixos/options.html).
{{< /alert >}}

#### Abstractions

Abstractions provide a way to reduce redundancy in your configuration.

```
let
  exampleOrgCommon =
    { hostName = "example.org";
      documentRoot = "/webroot";
      adminAddr = "alice@example.org";
      enableUserDir = true;
    };
in
{
  services.httpd.virtualHosts =
    [ exampleOrgCommon
      (exampleOrgCommon // {
        enableSSL = true;
        sslServerCert = "/root/ssl-example-org.crt";
        sslServerKey = "/root/ssl-example-org.key";
      })
    ];
}
```

This method also works on functions, here we generate a couple of virtual hosts which only differs by their hostnames:

```
{
  services.httpd.virtualHosts =
    let
      makeVirtualHost = name:
        { hostName = name;
          documentRoot = "/webroot";
          adminAddr = "alice@example.org";
        };
    in
      [ (makeVirtualHost "example.org")
        (makeVirtualHost "example.com")
        (makeVirtualHost "example.gov")
        (makeVirtualHost "example.nl")
      ];
}
```

A further improvement of this configuration is the use of `map`

```
{
  services.httpd.virtualHosts =
    let
      makeVirtualHost = ...;
    in map makeVirtualHost
      [ "example.org" "example.com" "example.gov" "example.nl" ];
}
```

Functions can also have more than one argument:

```
 let
      makeVirtualHost = { name, root }:
        { hostName = name;
          documentRoot = root;
          adminAddr = "alice@example.org";
        };
    in map makeVirtualHost
```

#### Modularity

NixOS configuration can be split into different \*.nix files and imported with `imports = [ ./mod1.nix ./mod2.nix ];` into the main configuration. The modules have the same syntax as the main file. When necessary you can specify the ordering and the preference of settings. the `config` variable contains all options merged across all config files. Access to this value is possible in your config

```
if config.services.xserver.enable then
      [ pkgs.firefox
        pkgs.thunderbird
      ]
    else
      [ ];
```

and by using the command `nixos-option OPTION` which prints the value to stdout.

### Package management

NixOS supports two styles of package management:

1. Declarative with your `configuration.nix` and `nixos-rebuild`where NixOS will ensure a consistent set of binaries
2. Ad hoc with `nix-env` similar to traditional package management allowing to mix packages from different Nixpkgs versions.This is the only choice for non-root users.

#### Declarative

By adding the desired package to `environment.systemPackages = [ ... ];`. Executing `nix-env -qaP '*' --description` lists all available packages. To uninstall a package simple remove it from the file. After modifying your packages run e.g. `nixos-rebuild switch`

Some packages allow further configuration e.g. firefox `nixpkgs.config.firefox.enableGoogleTalkPlugin = true;`

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
Unfortunately, Nixpkgs currently lacks a way to query available configuration options.
{{< /alert >}}

- Even more advanced customisation is possible!
- When a package is not available you can build your own package and optionally patch the official repo.

#### Ad hoc

Installing a package can be done with `nix-env -iA nixos.thunderbird`. As root the package is saved in the nix profile `/nix/var/nix/profiles/default` and visible in the whole system. Otherwise as user it is installed in `/nix/var/nix/profiles/per-user/username/profile` and only visible to that user. The -A flag specifies the package by its attribute name; without it, the package is installed by matching against its package name (e.g. thunderbird). The latter is slower because it requires matching against all available Nix packages, and is ambiguous if there are multiple matching packages.

For updating packages run `nix-channel --update nixos` and than `nix-env -i` again. Other packages in the profile are not affected and that's a crucial difference to the declarative method where 'nixos-rebuild' updates all packages from the channel. However, you can update all packages with `nix-env -u '*'`.

Uninstalling works with `nix-env -e thunderbird` and rollback with `nix-env --rollback`.

### Enable automatic updates

```
system.autoUpgrade.enable = true;
```

### Add new user

Like in [Package Management](#package_management) declarative and ad hoc style is possible.

```
  users.extraUsers.USERNAME = {
    createHome = true;
    home = "/home/user";
    extraGroups = [ "wheel" ];
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [ "ssh-rsa ..." ];
    uid = 1000;
  };
```

This user has no password and is only able to login with its private ssh key. In order to use `sudo -i` a password is required. To set a password loin as root and execute `passwd USERNAME`.

As ad hoc style you can use standard linux commands such as useradd, usermod, groupadd, etc.

### Automatic garbage collection

```
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};
```

### Zsh

In configuration.nix

```
  environment.systemPackages = with pkgs; [
        zsh
        oh-my-zsh
  ];

  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit = ''
    export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

    # Customize your oh-my-zsh options here
    ZSH_THEME="robbyrussell"
    plugins=(git docker)

    bindkey '\e[5~' history-beginning-search-backward
    bindkey '\e[6~' history-beginning-search-forward

    HISTFILESIZE=500000
    HISTSIZE=500000
    setopt SHARE_HISTORY
    setopt HIST_IGNORE_ALL_DUPS
    setopt HIST_IGNORE_DUPS
    setopt INC_APPEND_HISTORY
    autoload -U compinit && compinit
    unsetopt menu_complete
    setopt completealiases

    if [ -f ~/.aliases ]; then
      source ~/.aliases
    fi

    source $ZSH/oh-my-zsh.sh
  '';
  programs.zsh.promptInit = "";

  users.extraUsers.USER = {
    shell = pkgs.zsh;
  };
```

### Firewall

NixOS comes with a simple stateful firewall which is enabled per default. You can disable it with `networking.firewall.enable = false;`. To allow TCP/UDP ports use `networking.firewall.allowedTCPPorts = [ 80 443 ];` (respective `networking.firewall.allowedUDPPorts`).

### Configuration commands

#### Activate your configuration but not reboot persistent

```bash
nixos-rebuild test
```

#### Activate your configuration not before reboot

```bash
nixos-rebuild boot
```

#### Activate your configuration and make it permanent

```bash
nixos-rebuild switch
```

#### List automatic tasks

```bash
systemctl list-timers
```

#### Clean system

```sh
nix-collect-garbage -d # as root to clear system profile
```

#### Optimize store

```sh
nix-store --optimise
```

## Package installation/update

### See subscribed channels

```bash
nix-channel --list | grep nixos
```

### Switch channel

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
Channels are per user so switching a channel as user will not affect the main config!
{{< /alert >}}

```bash
nix-channel --add https://nixos.org/channels/channel-name nixos
# for example unstable channel
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update
```

### Remove channel

```bash
nix-channel --remove CHANNEL_ALIAS
```

### Upgrading/Installation of packages

```bash
nixos-rebuild switch --upgrade
```

### Access NixOS config options

```bash
nixos-option OPTION-SET
nixos-option services.sshd
```

### Search package

```bash
nix-env -qaP '.*PACKAGE.*'
```

### Show package description

```bash
nix-env -qa --description '.*PACKAGE.*'
```

### Upgrade package(s)

```bash
nix-env -u PACKAGE
nix-env -u
```

### (Un)Install package

```bash
nix-env -i PACKAGE
nix-env -e PACKAGE
```

### Install package from source

```bash
nix-env -f https://github.com/NixOS/nixpkgs/archive/master.tar.gz -iA pkgs.NAME
```
