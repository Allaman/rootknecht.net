---
title: NixOS als Container-Host
summary: Mein erster Versuch mit NixOS war wahrscheinlich im Oktober 2021 😄. Seitdem versuchte ich mehrmals, mich an NixOS und/oder Nix als Paketmanager-Alternative zu gewöhnen, aber mit wenig Erfolg. In diesem Beitrag möchte ich erläutern, wie ich endlich einen Zweck für NixOS gefunden habe und wie mir das ermöglichte, der steilen Lernkurve auszuweichen!
description: nixos, nix, konfiguration, linux
date: 2023-07-17
tags:
  - tools
  - nixos
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/nixos-as-host/)
{{< /alert >}}

## Hintergrund

Meine früheren Versuche scheiterten immer kläglich aufgrund der enormen Unterschiede[^1] von NixOS im Vergleich zu traditionellen Linux-Distributionen und der steilen Lernkurve. Es ist, als würde man, wenn man auf etwas stößt, das man nicht versteht, wahrscheinlich auf zwei weitere Dinge stoßen, die man nicht versteht, während man versucht, das erste zu verstehen 😆.

Mein Hauptrechner ist derzeit ein MacBook Pro M1 nach 10 Jahren ThinkPads mit Linux[^2], aber ich besitze noch meinen ThinkPad X1 der 9. Generation, der als Backup-Gerät fungiert. Ich war unzufrieden mit Manjaro, und da ich zu viel Freizeit habe (nicht), kam ich auf die Idee, NixOS einen weiteren Versuch zu geben.

Dieses Mal, anstatt NixOS in einer virtuellen Maschine auszuführen oder zu versuchen, einen Server mit NixOS zu replizieren, wollte ich etwas anderes erreichen[^3].

## Ziele

- Ein sehr stabiles und (gewissermaßen) unveränderliches Betriebssystem betreiben.
- Alles ist als Code konfiguriert. Ich bin ein großer Befürworter des Infrastructure-as-Code-Prinzips und nutze Tools wie Terraform, Ansible, Flux2 usw. Mein gesamtes System soll über Code bzw. allgemeiner über „Textdateien" konfigurierbar sein.
- In der Lage sein, meinen ThinkPad von Grund auf reproduzierbar zu konfigurieren.
- Meine bestehenden [Dotfiles](https://github.com/Allaman/dots), verwaltet über [chezmoi](https://www.chezmoi.io/), müssen verwendet werden und sollen weiterhin mit meinem MacBook Pro funktionieren.
- In der Lage sein, dedizierte Umgebungen für verschiedene Kunden/Projekte zu erstellen.

## Einschränkungen

- Fokus auf die grundlegendsten Features von NixOS, um die Lernkurve zu reduzieren.
- [Flakes](https://nixos.wiki/wiki/Flakes) auslassen, um die Lernkurve weiter zu reduzieren, und ehrlich gesagt habe ich immer noch Schwierigkeiten, Flakes zu verstehen.
- [home-manager](https://github.com/nix-community/home-manager) auslassen, weil nicht alle meine Rechner home-manager betreiben werden und ich nicht mehrere Dotfiles pflegen möchte, insbesondere nicht meine [Neovim](https://github.com/Allaman/nvim/)-Konfiguration duplizieren möchte.
- [i3wm](https://i3wm.org/) als Window Manager verwenden, da ich Erfahrung mit i3 habe und seine Konfiguration in einer einzigen Datei unkompliziert ist.
- Nur ein Benutzer und ein einzelner Rechner (vorerst).

## Ansatz

Mein Plan ist es, NixOS als Basis-/Host-System mit sehr wenigen grundlegenden Programmen/Tools zu verwenden. Auf NixOS aufbauend werde ich [distrobox](https://github.com/89luca89/distrobox)-Container starten, die alle für meine Workflows notwendigen Tools enthalten. Diese Container sind wegwerfbar, da a) keine Daten darin gespeichert werden und b) sie automatisch konfiguriert werden.

{{< alert >}}
Die Konfiguration ist in meinem [dots](https://github.com/Allaman/dots/tree/main/dot_nixos)-Repo zu finden.
{{< /alert >}}

### NixOS als Host-System

#### Syncthing

Um meine [Dotfiles](https://github.com/Allaman/dots) einzurichten, benötige ich meinen SSH-Schlüssel und meinen [Age](https://github.com/FiloSottile/age)-Schlüssel, um `chezmoi` ausführen zu können. Ich bin ein intensiver Nutzer von [Syncthing](https://syncthing.net/), um meine Dateien über Geräte hinweg zu synchronisieren, wobei mein Home-Lab als zentraler „Datensink" dient. Um Syncthing einzurichten, meinen SSH- und Age-Schlüssel zu „pullen", verwende ich folgenden Ausschnitt in meiner `configuration.nix`-Datei:

```nix
  services = {
    syncthing = {
      enable = true;
      user = "michael";
      configDir = "/home/michael/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      extraOptions = {
        globalAnnounceEnabled = false;
      }
      devices = {
        "unraid" = { id = "42GWJCT-VAONXMN-UNQVPRX-MVX6VHC-CSFKYFI-7MJX7QT-7VPK7SV-XJUFHAG"; addresses = [ "tcp://192.168.178.62:22222" ]; };
      };
      folders = {
        "secrets" = {
          id = "lkumh-nvc74";
          path = "~/.secrets/";
          devices = [ "unraid" ];
          type = "receiveonly";
          ignorePerms = false;
        };
      };
    };
  };
```

#### Pakete

Wie gesagt, soll NixOS nur als Host-System für meine DistroBox-Container fungieren und nur sehr wenige GUI- und grundlegende Tools ausführen.

Meine vom System verwalteten Nix-Pakete sind folgende:

```nix
environment.systemPackages = with pkgs; [
    acpi
    arandr
    brightnessctl
    curl
    gcc
    git
    gnumake
    htop
    networkmanagerapplet
    pulseaudio
    unzip
    wget
    xorg.xhost
    zip
];
```

Meine benutzerspezifischen Nix-Pakete sind folgende:

```nix
packages = with pkgs; [
    firefox
    alacritty
    xautolock
    flameshot
    keepassxc
    distrobox
];
```

Diese Pakete betrachte ich als allgemein und sehr grundlegend, daher werden sie auf Host-Ebene verwaltet.

### Podman

Um Podman in NixOS zu aktivieren, habe ich folgenden Ausschnitt zu meiner `configuration.nix` hinzugefügt:

```nix
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
  };
```

Jetzt kann ich vertraute Docker-Befehle wie `docker ps` verwenden.

## DistroBox

DistroBox ermöglicht es,

> Use any Linux distribution inside your terminal.

Mit DistroBox kann ich wegwerfbare und projekt-/kundenspezifische Container erstellen, ohne das Host-System zu verändern[^4].

### Den Standard-Container erstellen

Dieser Container dient als Standard-Container für nicht projektspezifische Aufgaben.

```sh
distrobox-create --name default --init --image docker.io/library/archlinux:latest
distrobox-enter default
```

`--name` setzt den Namen des Containers und seinen Hostnamen.
`--init` aktiviert das Init-System innerhalb des Containers, was auch den Zugriff auf die Host-Prozesse verhindert.
`--image` gibt an, welches Docker-Image verwendet werden soll.

### Den Standard-Container konfigurieren

Vorerst führe ich nur ein einfaches Bash-Skript aus, um den Container zu konfigurieren, aber ich könnte z. B. auf Ansible umsteigen für einen ausgefeilteren Ansatz.

```sh
#!/bin/bash
set -e

sudo pacman --noconfirm -S base-devel ueberzug

# Brew installieren
NONINTERACTIVE=1 /bin/bash -c \
 "$(curl -fsSL \
  https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH

# Pakete installieren
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

# Neovim Nightly installieren
brew install neovim --head

# Mein Dotfiles-Bootstrap-Skript herunterladen
wget https://raw.githubusercontent.com/Allaman/dots/main/bootstrap.sh
chmod +x bootstrap.sh
```

{{< alert >}}
Weitere Details auf der [Homepage](https://distrobox.privatedns.org/).
{{< /alert >}}

### Host-Integration

Mein Standard-Terminal-Shortcut öffnet ein Terminal innerhalb meines Standard-Containers:

```
bindsym $mod+Return exec --no-startup-id alacritty -e distrobox-enter default
```

Um das Teilen der System-Zwischenablage zwischen Containern zu ermöglichen, wird xhost beim Start aufgerufen.

```
exec --no-startup-id xhost +si:localuser:$USER
```

## Nix Shell

Wer mit Nix(OS) vertraut ist, fragt sich vielleicht, warum `nix shell` bzw. `nix-shell` nicht verwendet wird? Eine berechtigte Frage!

Ehrlich gesagt wegen Neovim. Meine Neovim-[Konfiguration](https://github.com/Allaman/nvim) hängt von Mason ab, um die für meine Konfiguration benötigten Binaries herunterzuladen[^5]. Aufgrund der Natur von NixOS funktioniert das Ausführen von Binaries nicht immer[^6]. Bezüglich meines Setups sind `stylua`, `lua-language-server` und `marksman` betroffene Binaries mit vermutlich fest codierten Pfaden. Es gibt in [^6] beschriebene Lösungen, aber sie sind für mich etwas anspruchsvoll.

Wie ich bereits erwähnte, bin ich nicht bereit, meine Neovim-Konfiguration umzuschreiben. Mit diesem Ansatz kann ich diese Einschränkung umgehen, indem ich Neovim innerhalb eines Containers mit einem „normalen" Linux-Dateisystem ausführe, wo Pfade verfügbar sind.

## Fazit

Mit diesem Ansatz kann ich das Beste aus zwei Welten kombinieren. NixOS als felsenfestes, unzerstörbares und gewissermaßen unveränderliches Host-System und Distrobox als Schicht, wo „normale Linux-Regeln" gelten.

[^1]: Ich werde nicht im Detail erläutern, was NixOS/Nix ist und welche Vor- und Nachteile es hat.

[^2]: Siehe meinen Beitrag [Von Linux zu macOS wechseln](https://rootknecht.net/blog/moving-to-macOS/).

[^3]: Inspiriert von [NixOS: Containerized and Immutable](https://www.youtube.com/watch?v=VqUKpNXnRxs) auf YouTube.

[^4]: Zu beachten ist, dass das [Home-Verzeichnis des Hosts immer eingebunden wird](https://github.com/89luca89/distrobox/blob/main/docs/usage/distrobox-create.md), selbst wenn ein [benutzerdefiniertes Home-Verzeichnis](https://github.com/89luca89/distrobox/blob/main/docs/useful_tips.md#create-a-distrobox-with-a-custom-home-directory) angegeben wird. Aufgrund dieses Verhaltens entschied ich mich, kein dediziertes Home-Verzeichnis für meine Container anzugeben. Daher wird das Home-Verzeichnis meines Hosts zwischen meinen Containern geteilt.

[^5]: Warum Mason, ein weiterer Paketmanager, und nicht aptitude, pacman, brew, nix oder ...? Meine Idee war, Mason die Pakete auf die gleiche Weise auf jedem Betriebssystem verwalten zu lassen und nicht mit der Einrichtung jedes Paketmanagers auf meinen verschiedenen Systemen zu kämpfen.

[^6]: „Das Herunterladen und Versuchen, ein Binary auf NixOS auszuführen, wird fast nie funktionieren. Das liegt an fest codierten Pfaden in der ausführbaren Datei." aus dem [NixOS Wiki](https://nixos.wiki/wiki/Packaging/Binaries).
