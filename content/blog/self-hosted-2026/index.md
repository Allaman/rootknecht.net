---
title: My self-hosted setup in 2026
description: "An overview of my self-hosted setup in 2026, covering services running on Unraid, a root server, and a Raspberry Pi — including backups, and file sync."
summary: "A walkthrough of my personal self-hosted infrastructure for 2026: what I run on Unraid at home, what lives on a rented root server, and how I handle backups."
date: 2026-04-10
tags:
  - hardware
  - self-hosted
  - linux
---

I am always interested in what and how people self-host stuff and enjoy reading their setups so I decided to write down my setup for you 🙂

My self-hosted setup consists of an [Unraid](https://unraid.net/) server at home and a root server rented from [netcup](https://www.netcup.com/en) as well as a Raspberry.

> [!NOTE]
> This blog post is not about configuration and or how to set up services.

## Unraid

I run an Unraid server since end of November 2021 and I am very happy how easy and powerful Unraid is. I also wrote a [blog post](/blog/building-my-nas) about my reasons for Unraid and my hardware considerations.

The majority of services run as Docker container with their own share but I also rely on some crucial plugins.

### Calibre and Calibre-Web

If you have to deal with E-books you should have come across [Calibre](https://calibre-ebook.com/), **THE** E-book management software. No surprise, I use it to manage my E-books that I usually buy from [Thalia.de](https://www.thalia.de/) (DRM-free!). [Calibre-Web](https://github.com/janeczku/calibre-web) is a light frontend for Calibre which is more suitable for browsing my collection on various devices.

### Prometheus and Grafana

[Prometheus](https://prometheus.io/docs/introduction/overview/) and [Grafana](https://grafana.com/) are both tools for monitoring. Metrics are exposed by the Prometheus Node Exporter plugin and scraped by Prometheus.

### Heimdall

[Heimdall](https://heimdall.site/) is a customisable application dashboard containing links to all my important services and bookmarks.

### Jellyfin

[Jellyfin](https://jellyfin.org/) is my media center for streaming music, movies, and shows.

### Metabase

[Metabase](https://www.metabase.com/) is probably an overkill for my use case but hey, it works! I use it to visualise my spendings. See my [accounting post](/blog/accounting) for details.

### MySpeed

With [MySpeed](https://myspeed.dev/) I am measuring my internet bandwidth (upload, download, and ping) each night.

### Photoprism

[Photoprism](https://photoprism.app/) is my picture library for my raw images shoot from my mirrorless cameras.

### Syncthing

[Syncthing](https://syncthing.net/) is the backbone of my file synchronisation for years (maybe a decade?).

### Appdata Backup

[Appdata Backup](https://forums.unraid.net/topic/137710-plugin-appdatabackup/) is a plugin that regularly creates backups from my appdata folder (located on my cache) and stores the backup on my array.

### Tailscale

[Tailscale](https://forums.unraid.net/topic/136889-plugin-tailscale/) is a plugin to connect to a [Tailscale](https://tailscale.com/) network. I use it to connect to my [headscale](#headscale) instance on my root server.

> [!NOTE]
> I could probably host (almost) everything on my home server and connect via Tailscale. Nevertheless, I still prefer to host services on my root server in parallel because a) the bandwidth is superior to my home internet and b) my family needs access to some services too.

### Unassigned Devices

[Unassigned Devices](https://forums.unraid.net/topic/92462-unassigned-devices-managing-disk-drives-and-remote-shares-outside-of-the-unraid-array/) is a plugin to manages disks not part of the Unraid array. I used it to mount a USB drive to perform backups. See [Backups](#backups).

### User Scripts

[User Scripts](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/) is a plugin to perform arbitrary scripts time-based, think of cronjobs. This plugin is a crucial part of my [backup](#backup) strategy.

## Root Server

### Syncthing

Of course, [Syncthing](https://syncthing.net/) is also installed on my root server.

### Nextcloud

[Nextcloud](https://nextcloud.com/) is a powerful "cloud alternative". It can replace many SaaS services like file-storage, PIM, chat, notes, video-conferencing and more. I just use it as file-storage for accessing files on the go and for sharing with my family. Folders are "mounted" as external storage so I can use Syncthing and the file system for synchronisation.

### Calibre-Web

[Calibre-Web](https://github.com/janeczku/calibre-web) to view my E-book library on the go.

### Forgejo

[Forgejo](https://forgejo.org/) is a GitHub/Gitlab alternative for my private repositories. What amazes me is the simple deployment. Just one binary and that's it.

### Nginx

[Nginx](https://nginx.org/) as reverse proxy is my door to my services that also does SSL termination with [Let's Encrypt](https://letsencrypt.org/)[^1] certificates automatically renewed by [certbot](https://certbot.eff.org/). If I were to start from scratch, I would probably consider [Caddy](https://caddyserver.com/) instead of Nginx.

### Supernote private cloud

[Supernote private cloud](https://support.supernote.com/setting-up-your-own-supernote-private-cloud-beta) is the self-hosted cloud for my [Supernote](https://supernote.com/) E-Ink tablets. See my [post](/blog/supernote-private-cloud) on my notes how to set up the service using Docker.

If you are interested in E-Ink tablets I wrote a [post](/blog/eink-note-taking-onyx-boox-remarkable-supernote) comparing Remarkable 2, PP, PPM, Supernote Nomad, Manta, and Onyx Boox Note Air 3 C.

### Donetick

[Donetick](https://donetick.com/) is my task manager of choice. I like it's simplicity yet good feature set and the native iOS app.

### Karakeep

[Karakeep](https://github.com/karakeep-app/karakeep) is my bucket for everything. When there is an interesting article or tool or image or note that has no place in my [knowledge management system](https://rootknecht.net/blog/why-i-tried-to-leave-obsidian-and-didnt/), I just drop it in Karakeep. It is automatically tagged and a offline copy is stored.

### FreshRSS

[FreshRSS](https://github.com/FreshRSS/FreshRSS) is my RSS (am I old?) aggregator of choice and replaced [TinyTinyRSS](https://tt-rss.org/) which I used for years.

### Atuin

[Atuin](https://github.com/atuinsh/atuin) is a tool to store and sync your shell history across devices via [self-hosted](https://docs.atuin.sh/cli/self-hosting/server-setup/) sync-server.

### Headscale

[Headscale](https://headscale.net/stable/) is a self-hosted alternative of [Tailscale](https://tailscale.com/). And the best part: It works with official Tailscale clients!

### Copyparty

[Copyparty](https://github.com/9001/copyparty) is an all in one file server where I still try to figure out if I need it when I have Nextcloud.

## Raspberry

A Raspberry Pi 4 Model B runs [Pi-hole](https://pi-hole.net/) for network-wide ad blocking. Initially, I was running Pi-hole on my Unraid but I recogized that this was not a good idea for such a crucial networking component. Since then, I had no issues and it is rock stable on my Pi.

## Backups

All my data is synced to my Unraid server. From there, I have several backup methods in place:

1. My data is backuped every night at 03:00 to [Backblaze](https://www.backblaze.com/cloud-storage) up via user script using [Restic](https://restic.net/) with snapshots and encrypted.
2. Media is backuped weekly to [pCloud](https://www.pcloud.com/) via user script using [Rclone](https://rclone.org/).
3. Monthly I plug in a SSD and perform a manual backup of all my data via user script using [Restic](https://restic.net/) with snapshots and encrypted.

[^1]: Do you remember the time before Let's Encrypt? I do, what a struggle! I think the impact of Let's Encrypt cannot be emphasized enough!
