---
title: First look at Supernote private cloud setup
summary: Setting up a self-hosted Supernote private cloud using Docker compose and Nginx.
description: productivity, E-ink, Note-taking, Supernote A5X2 Manta, self-hosting, Docker
date: 2025-11-14
tags:
  - productivity
  - self-hosted
  - docker
---

With the recent release of [Chauvet 3.25.39](https://supernote.com/blogs/supernote-blog/private-cloud-for-data-sovereignty-serverlink-for-remote-files-control-via-webdav) for Supernote Manta and Nomad, the option to self-host the cloud for synchroizing has been introduced.

In this blog post I will take a look at the [Deployment Using Docker Containers (pdf)](https://ib.supernote.com/private-cloud/Supernote-Private-Cloud-Manual-Deployment-Method-Using-Docker-Containers.pdf). A "manual" (Linux/Synology NAS) deployment is also [available (pdf)](https://ib.supernote.com/private-cloud/Supernote-Private-Cloud-Deployment-Manual.pdf).

## Docker

Looking at the linked document, I was a little disappointed that no compose file was provided, so I asked my LLM of choice to write one for me.

The next thing that bothered me was the outdated references to MariaDB and Redis on their Docker Hub. I decided to try the official latest Docker images, and apparently, they also work.

I also exposed only the Supernote app ports and limited access to 127.0.0.1 instead of 0.0.0.0 (for my reverse proxy setup).

After downloading the SQL file, which creates the table structure for the database,

```sh
curl -O https://supernote-private-cloud.supernote.com/cloud/supernotedb.sql
```

and creating the directories to store sn data and config I can finally spin up my cloud.

```sh
mkdir ~/supernote ~/sndata
```

My compose file looks like this now:

{{< collapse "compose.yml" >}}

```yml
services:
  mariadb:
    image: mariadb:12.0.2-ubi
    container_name: mariadb
    networks:
      - supernote-net
    environment:
      MYSQL_ROOT_PASSWORD: "foo"
      MYSQL_DATABASE: supernotedb
      MYSQL_USER: "supernote_user"
      MYSQL_PASSWORD: "foo"
    volumes:
      - mariadb_data:/var/lib/mysql
      - ./supernotedb.sql:/docker-entrypoint-initdb.d/supernotedb.sql:ro
    restart: unless-stopped

  redis:
    image: redis:7.4.7
    container_name: redis_supernote
    networks:
      - supernote-net
    volumes:
      - redis_data:/data
    command: redis-server --requirepass 'bar' --dir /data --dbfilename dump.rdb
    restart: unless-stopped

  notelib:
    image: docker.io/supernote/notelib:6.9.3
    container_name: notelib
    networks:
      - supernote-net
    restart: unless-stopped

  supernote-service:
    image: docker.io/supernote/supernote-service:25.11.04
    container_name: supernote-service
    networks:
      - supernote-net
    ports:
      - "127.0.0.1:18072:18072"
      - "127.0.0.1:19072:8080"
    volumes:
      - ~/sndata/recycle:/home/supernote/recycle
      - ~/supernote:/home/supernote/data
      - ~/sndata/logs/cloud:/home/supernote/cloud/logs
      - ~/sndata/logs/app:/home/supernote/logs
      - ~/sndata/logs/web:/var/log/nginx
      - ~/sndata/convert:/home/supernote/convert
      - /etc/localtime:/etc/localtime:ro
    environment:
      MYSQL_DATABASE: supernotedb
      MYSQL_USER: "supernote_user"
      MYSQL_PASSWORD: "foo"
      REDIS_HOST: redis
      REDIS_PORT: 6379
      REDIS_PASSWORD: "bar"
    depends_on:
      - mariadb
      - redis
      - notelib
    restart: unless-stopped

networks:
  supernote-net:
    name: supernote-net

volumes:
  mariadb_data:
  redis_data:
```

{{< /collapse >}}

## Nginx (reverse proxy)

Supernote provided [configuration](https://support.supernote.com/Whats-New/setting-up-your-own-supernote-private-cloud-beta) snippet for Nginx as a reverse proxy for handling HTTPS termination which is exactly what I do :) I just replaced `YOUR_PRIVATE_CLOUD_IP_ADDRESS` with `127.0.0.1` and removed the SSL settings as these are managed by [Certbot](https://certbot.eff.org/).

## Login

When opening the private cloud page I was greeted with a login/register page. To be able to register, I had to configure mail settings. Although the test mail from my primary mail provider [mailbox.org](https://mailbox.org/en/) was sent and received I did not receive the registration mail for my actual registration. Only when I configured my backup Gmail account my registration mail was succesfully delivered and I could create an account.

## Sync

After logging out of my Supernote account, I was able to enable the private cloud in the settings and log in with my account. However, a sync throws a “network error” and does not work. I assume that this is caused by the missing “exposed port.” Remember the compose file:

```yml
ports:
  - "127.0.0.1:18072:18072"
  - "127.0.0.1:19072:8080"
```

Port `19072` is for the homepage and apparently for the login of the device, but `18072` is probably the synchronization protocol’s port, which is not reachable from the internet. I wonder how this is supposed to work because I do not want to open the port on my machine without HTTPS. Or maybe the protocol itself is encrypted? I will update this part once I know more.
