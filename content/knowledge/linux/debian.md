---
title: Debian
summary: How to do various tasks in Debian
---

## Apt-get upgrade

Do not add or remove dependencies

```bash
apt-get upgrade
```

Only add new dependencies

```bash
apt-get upgrade --with-new-pkgs
```

Add and remove dependencies

```bash
apt-get dist-upgrade
```

## Automatic and quiet apt-get

```sh
DEBIAN_FRONTEND="noninteractive" &&\
apt-get -qq update < /dev/null > /dev/null &&\
apt-get -qq upgrade < /dev/null > /dev/null &&\
apt-get -qq install htop vim </dev/null > /dev/null
```

## Fix apt-get Hashsum mismatch in Debian 9

Usually occurring behind a (enterprise) proxy setup

/etc/apt/apt.conf.d/99fixbadproxy

```
Acquire::http::Pipeline-Depth 0;
Acquire::http::No-Cache true;
Acquire::BrokenProxy    true;
```

## Different version of packages

```bash
apt-cache policy PACKAGE
apt-get install PACKAGE=VERSION
```

## Hold packages

```bash
apt-mark hold PACKAGE
apt-mark unhold PACKAGE
apt-mark showhold
```

## Create and enable Swap

```bash
touch /var/swap
chmod 600 /var/swap
dd if=/dev/zero of=/var/swap bs=1M count=SIZE_OF_RAM_IN_MB
mkswap /var/swap
swapon /var/swap
echo "/var/swap    none    swap    sw    0    0" >> /etc/fstab
```
