---
title: Building my DIY NAS
type: posts
draft: false
date: 2021-11-24
tags:
  - diy
  - hardware
  - server
resources:
  - name: head
    src: head.jpeg
  - name: case
    src: case.jpg
    title: Finished build - Lenovo X1 Carbon for scale
  - name: inside
    src: inside.jpg
    title: A closer look
  - name: drives
    src: drives.png
    title: Drive layout in Unraid web UI
  - name: user-scripts
    src: user-scripts.png
    title: User-scripts web UI with default scripts
  - name: krusader
    src: krusader.png
    title: Krusader file manager
  - name: syncthing
    src: syncthing.png
    title: Syncthing statistics
  - name: grafana
    src: grafana.png
    title: Some metrics from Prometheus visualized in Grafana
---

Are you planning to get a NAS (network attached storage) because your data is growing? Do you think about building a small home lab? You are a little more technical and not afraid of DIY builds and installing operating systems? Then, this post is for you 🤓 You will read about my requirements and use cases as well as my hardware and software choices for building my first DIY NAS.

<!-- more -->

{{< img name=head lazy=false description=false size=tiny >}}

{{< toc >}}

After reworking my backup concept and my expected growth of data I came to the conclusion that I need a NAS. So I decided to give my good old Synology DS211j from 2011(!) a shoot (again). Turns out that it was indeed still working, and I was happy to save time and money. Unfortunately, the NAS was extremely slow due to its weak hardware. Updating the DSM software itself took two days and the web UI was sluggish. Overall, the file operation performance was also not exciting. Finally, there is a reason to spend money on new stuff 🙈

Before shopping, I went back to the drawing board thinking about my needs and use cases for a proper replacement.

## Requirements

These requirements come in no specific order as **all** are must haves!

1. Enough storage
2. Drive failure does not lead to data loss
3. Manageable via web UI
4. [Syncthing](https://syncthing.net/) must run (highly recommended masterpiece of software!)
5. Enough performance for some home lab stuff
6. [Docker](https://www.docker.com/) must be available
7. Only reachable from within my home network
8. Disk encryption
9. Caching

## Use cases

- 75% (shared) file storage
- 15% home lab running some Docker containers and VMs
- 10% automation tasks
- **No** media streaming or gaming server

The next decision to think about was to **make** or to **buy**. Of course, at first I looked at the current lineup of Synology and QNAP systems. Some models are promising, but in my opinion they do lack power for my home lab use case in terms of CPU or RAM. Additionally, I want to have a hacker friendlier system and not a "proprietary" OS. Furthermore, building my own system is cheaper (at least that's what I thought 🤣).

In the next chapter I will give you an overview of my shopping list for the new system.

## Hardware

{{< hint info >}}
I am not a hardware guy and my last DIY build was in my youth 😆
{{< /hint >}}

My hardware is based on [this article](https://www.elefacts.de/test-120-nas_advanced_3.0b__6x_sata_mit_amd_athlon_3000g) (GER). I must admit that I was a little overwhelmed thinking about my hardware choices, so I was very happy to find this article.

- Case: [Fractal Design Define R6 Black Tempered Glass](https://www.amazon.de/gp/product/B078JKF674)
- Mainboard: [Asus Prime A320M-A Mainboard Sockel AM4](https://www.amazon.de/gp/product/B074BHVHL9) [^1]
- Power supply: [be Quiet! Pure Power 11 400W cm](https://www.amazon.de/gp/product/B07JJFBNH2)
- CPU: [AMD Ryzen 5 Pro 2400g](https://www.amd.com/en/products/apu/amd-ryzen-5-pro-2400g)
- CPU fan: [Noctua NH-L9a-AM4 chromax.Black, Low-Profile](https://www.amazon.de/gp/product/B083LQVX5W)
- RAM: [Crucial CT2K16G4DFD8266 32GB Kit (16GB x2, DDR4, 2666 MT/s)](https://www.amazon.de/gp/product/B0736W5BH2)
- HDD: [WD Rot Pro 4TB 3.5" - 7200 RPM](https://www.amazon.de/gp/product/B07B1WK3N5)
- SSD: [Samsung SSD 870 EVO, 1 TB](https://www.amazon.de/dp/B08PC5DKZQ)

All components are working and the build itself was not too difficult. The case is quiet big and offers plenty of space for these components as well as for your (thick) fingers 😉

{{< hint warning >}}
Be aware that this is not an ECC RAM build!
{{< /hint >}}

{{< img name=case lazy=true size=small >}}

{{< img name=inside lazy=true size=small >}}

## Software

The next decision to think about was which operating system to run. From the beginning it was obvious to me that I can not run a plain Linux distribution. I will need a special OS for this purpose.

In the area of NAS operating systems a major player is [TrueNAS](https://www.truenas.com/) CORE which is formerly known as FreeNAS. TrueNAS is an enterprise level storage solution and is build upon [FreeBSD](https://www.freebsd.org/) and the [ZFS](https://en.wikipedia.org/wiki/ZFS) file system.

While researching about TrueNAS I stumbled over [Unraid](https://unraid.net/) which claims to be a solution for all data users for any combination of hardware. Unraid is based upon [Slackware Linux](http://www.slackware.com/) and [XFS](https://en.wikipedia.org/wiki/XFS) (though a community [ZFS plugin](https://forums.unraid.net/topic/41333-zfs-plugin-for-unraid/) is available).

Of course, there are other alternatives like [openmediavault](https://www.openmediavault.org/), [EasyNAS](https://easynas.org/), [Rockstar](https://rockstor.com/), [Proxmox](https://www.proxmox.com/en/), and more. Some of them are specialized for certain purposes like Media streaming and some of them just looked not very appealing or widely used for me.

In the following section I want to list the key features of Unraid and TrueNAS.

### Unraid

- Unraid is based upon Slackware Linux distribution, and I am quite familiar with Linux which makes me fell more comfortable and more confident.
- Unraid offers a great flexibility regarding your hardware especially your drives. You can mix disks with arbitrary sizes and increase easily increase your storage by adding just a single drive to it. The only limitation is that the parity drive(s) must be equal or greater than your storage disks.
- As mentioned, the default file systems are XFS for storage disks and [btrfs](https://en.wikipedia.org/wiki/Btrfs) for the cache disks. I have some experience with both file systems and in my opinion they are easier to handle.
- Unraid requires a [paid license](https://unraid.net/pricing) based upon the number of drives you want to use. There is a 30 days trail with all features available.

### TrueNAS

- TrueNAS is based upon FreeBSD. Though, (Free)BSD is a Unix based system (at the time writing this)I don't feel very comfortable and confident in using BSD based systems. Additionally, I have doubt that every software I might want to run is available. In the future this might change with [TrueNAS SCALE](https://www.truenas.com/community/threads/truenas-scale-the-voyage-begins-with-version-20-10.88049/) but for now I don't want to run beta software for my NAS.
- ZFS is the file system of TrueNAS which I consider as superior file system with one drawback. I am not too familiar with it and a solution without learning a new complex file system would be preferable.
- Being a [RAID](https://en.wikipedia.org/wiki/RAID) based NAS you have to think about your RAID setup and also consider drive swapping. I would prefer a system without the complexity of a RAID.
- TrueNAS CORE is free and open source.

### Both

- Handle drive failure
- Come with a web UI
- Support drive encryption
- Large adoption and community
- Extensible and configurable

Considering all mentioned aspects I decided to install Unraid!

## Unraid config and apps

### Installation

Unraid boots **only** from a USB disk and runs completely from memory.

> Your USB drive must contain a unique GUID (Globally Unique Identifier) and be a minimum 1GB in size and a maximum 32GB in size.

{{< hint warning >}}
You should consider buying a stick from a well known brand.
{{< /hint >}}

Strangely, Unraid does not offer the official [USB-creator](https://github.com/limetech/usb-creator) for Linux.

Here are the steps to create an Unraid boot USB stick on Linux:

- Download the [release](https://unraid.net/download#stable-releases) archive.
- Format your USB drive for instance with [gparted](https://gparted.org/):
  - GPT table
  - New FAT32 partition
  - Mark it as bootable
  - Label the partition with **UNRAID** (Important!)
  - Copy the archive's content to the USB stick
  - Run `make_bootable_linux` located on your disk (not the USB). The script should confirm that the stick is ready

You should not require a monitor or keyboard/mouse. If your BIOS is configured to automatically boot from USB, Unraid will start in the default non GUI mode and is available at its local IP. Try to open http://unraid.local or look in your router network settings for the IP of your system.

### Drive set up

The Asus Prime A320M-A mainboard has 6 SATA ports. My decision for the drive layout was as follows:

- two [parity](https://wiki.unraid.net/Parity) drives which will cover two simultaneous drive failures.
- two drives for the actual storage (the so called **array**) which are protected by the parity drives.
- two SSD drives for caching. As the cache is not protected by the parity I decided to go with a pool of two SSDs so that the cache content is stored on two disks.

This layout will provide me my required fail-safe of two disks at the same time, a fast SSD cache and for my purpose enough space with the 2x4GB Array.

{{< img name=Drives lazy=true size=small >}}

{{< hint info >}}
I could have bought bigger drives for the parity because if I want to increase the capacity I have to buy a drive for the parity as well as for the storage itself. This restriction originates from the fact that parity drives must always be equal or bigger then the biggest array drive and I can not just add another 4 GB drive because of no free SATA ports.
{{< /hint >}}

### Shares

My data at the top level is structured in folders for personal data, business data, source code, media, etc. For each folder I created a share. Most of my shares are configured to use the cache with the "yes:cache" option. New files are primarily created on the cache (SSDs) if sufficient space is available. As the cache is not protected a so-called mover component moves files from the cache to the array. My mover is set up to start every night. Only critical data is directly written to the array.

My shares are auto mounted at access by [systemd](https://wiki.archlinux.org/title/Samba#automount).

### Plugins and Apps

This section gives an overview of my most important plugins and apps. Installation of the [Community Apps Plugin](https://unraid.net/community/apps) is highly recommended.

#### Syncthing

I use [Syncthing](https://syncthing.net/) for many years as my synchronization software. Never had an issue with it. Folders are synchronized between my Laptop, NAS, and my root server. Syncthing is available as Docker app (via community apps).

{{< img name=syncthing lazy=true size=small >}}

#### Restic

Syncthing is **not** a backup software! For backups, I use [restic](https://restic.net/). Restic creates client side encrypted repositories on various storage providers (S3, SFTP, Wasabi, GCS, ...). My provider of choice is [backblaze](https://www.backblaze.com/). Restic is configured to keep several snapshots allowing me to restore data from a specific point in time. Restic's [installation](https://blog.themainframe.co.uk/backup-unraid-part-two/) is easy as it consists of a single binary. I wrote a script that runs a backup operation for each share.

Here is a snippet of my backup script. The first line runs the backup command for a share to a bucket. The second command checks that only 20 snapshots are kept.

```sh
/usr/local/bin/restic -r $BUCKET:foo backup /mnt/user/foo
/usr/local/bin/restic -r $BUCKET:foo forget --keep-last 20 --prune
```

#### User scripts

[User scripts](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/) is a plugin that provides a front end to manage scripts that run periodically. Think of it as a cron management UI. My formerly mentioned restic script is triggered by this plugin. It also provides a log viewer via the web browser.

{{< img name=user-scripts lazy=true >}}

#### Krusader

[Krusader](https://krusader.org/) is a file manager similar to [Midnight](http://midnight-commander.org/) and [Total Commander](https://www.ghisler.com/). It is available as Docker app (via community apps) and I use it for browsing my files directly on the NAS.

{{< img name=krusader lazy=true >}}

#### Prometheus/Grafana

I use [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) for monitoring my system. Both tools are very common across the industry ranging from large enterprises to small startups or private users. Prometheus is a time series database which stores metrics. Grafana is used to visualize those metrics via dashboards. [Node-exporter](https://forums.unraid.net/topic/110995-plugin-prometheus-unraid-plugins/) is a plugin that provides the actual metrics to Prometheus.

{{< img name=grafana lazy=true >}}

## Conclusion

I can't say much about the hardware except it works, and my time spent on researching and buying was acceptable ☺. Unraid itself is really awesome. Of course, this can not be a comprehensive comparison because I've never got in touch with TrueNAS. Unraid offers simple storage and application management via a comfortable and snappy web UI. Unraid's documentation is also well maintained and there are awesome community resources like [Spaceinvader ONE's](https://www.youtube.com/channel/UCZDfnUn74N0WeAPvMqTOrtA) and [The Geed Freaks](https://www.youtube.com/watch?v=8v74as9Meko&list=PLk4WsoMYr8AKWBhabC6VihHcBwLwNY3SN) YouTube channels.

[^1]: The mainboard features 6 SATA ports and one NVMe connection. SATA 5 and 6 ports are not be available when a NVMe drive is connected!
