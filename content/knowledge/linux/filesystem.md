---
title: Linux Filesystem Hierarchy Standard
summary: A short description of where you can expect certain files in Linux
---

## Overview

```
/
├── bin
├── boot
├── dev
├── etc
├── home
├── initrd
├── lib
├── lib64
├── media
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin
├── srv
├── usr
│   ├── bin
│   ├── include
│   ├── lib
│   ├── lib64
│   ├── local
│   ├── sbin
│   ├── share
│   ├── src
└── var
└── tmp
```

## Folders explained

- bin &rarr; useful commands that are of use to both the system administrator as well as on-privileged users, e.g. cat, chmod, cp, echo, pwd, rm, sed, ...
- boot &rarr; everything required for the boot process except for configuration files not needed at boot time
- dev &rarr; special or device files. Hard drives and DVD drives are block devices. Serial ports, parallel ports are character devices.
- etc &rarr; all system related configuration files defined as local files used to control the operation of a program which must be static and cannot be an executable binary.
- home &rarr; each user is also assigned a specific directory that is accessible only to them and the system administrator which are subdirectories of /home
- initrd &rarr; capability to load a RAM disk by the boot loader
- lib and lib64 &rarr; kernel modules and those shared library images needed to boot the system and run the commands in the root filesystem like /bin and /sbin
- media &rarr; containing mount points for removable media
- mnt &rarr; generic mount point for filesystems or devices
- opt &rarr; reserved for all the software and add-on packages that are not part of the default installation
- proc &rarr; virtual filesystem. Sometimes referred to as a process information pseudo-file system. Contains runtime system information (e.g. system memory, devices mounted, hardware configuration, etc). Can be regarded as a control and information centre for the kernel.
- root &rarr; Home directory of the root account
- run &rarr; Similar to /var/run but tools like systemd or udev require this location early in the boot process where /var is not mounted
- sbin &rarr; only binaries essential for booting, restoring, recovering, and/or repairing the system in addition to the binaries in /bin, e.g. fdisk, init, route, swapof,
- srv &rarr; site-specific data which is served by this system.
- usr ("user system resources") &rarr; user-land programs and data (as opposed to 'system land' programs and data)
  - _bin_ &rarr; vast majority of binaries
  - _include_ &rarr; 'header files', needed for compiling user space source code.
  - _lib_ &rarr; program libraries.
  - _lib64_
  - _local_ &rarr; self-compiled or third-party programs safe from being overwritten by system updates
  - _sbin_ &rarr; programs for administering a system, meant to be run by 'root', e.g. chroot, useradd
  - _share_ &rarr; 'shareable', architecture-independent files (man pages, icons, fonts etc)
  - _src_ &rarr; the Linux kernel sources, header-files and documentation.
- var &rarr; variable data like system logging files, mail and printer spools, and temporary files.
- tmp &rarr; files that are required temporarily

More [details](https://www.tldp.org/LDP/Linux-Filesystem-Hierarchy/html/)
