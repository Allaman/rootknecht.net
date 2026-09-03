---
title: Setting up a selfhosted KOReader Sync featuring XTEINK
summary: How to self-host a KOReader sync server using kosync-dotnet and Docker, wire it up behind Nginx, and connect it to a Crosspoint-flashed XTEINK device — including a fix for the "document hash not found" error on first sync.
description: Self-host a KOReader sync server with kosync-dotnet, Docker, and Nginx — and sync reading progress to your XTEINK running Crosspoint firmware.
date: 2026-05-08
tags:
  - self-hosted
  - docker
  - eink
---

{{< figure src=xteinks.png caption="My XTEINK collection ([my X4 case printed with PLA Basic and Bambulab P1S](https://makerworld.com/en/models/2657757-xteink-x4-full-body-case?from=search#profileId-2939295))" >}}
I was one of the early owners[^1] of a [XTEINK](https://www.xteink.com/) device after watching [@jvscholz'](https://www.youtube.com/@jvscholz) [review](https://www.youtube.com/watch?v=eBW8JeAaMZ8) of the X4. After the rise of these little E-Ink readers based on the [ESP-32](https://en.wikipedia.org/wiki/ESP32) platform, several custom [firmwares](https://www.readme.club/firmware) were created by the community.

I think the first of them, and my choice, is [Crosspoint](https://github.com/Crosspoint-reader/Crosspoint-reader). This firmware adds, among many other features and quality of life improvements, the ability to sync the X4/X3 with KOReader. In this blog post, I briefly describe how I set up a self-hosted sync server and the issues I encountered.

> [!INFO]
> This post does not cover the technical basics and is more geared towards the experienced readers.

## Docker Compose

The majority of my workloads nowadays run as Docker containers so it is a no-brainer to also deploy the sync server as Docker container.

At first, I looked at [koreader/koreader-sync-server](https://github.com/koreader/koreader-sync-server), the official implementation. I encountered two issues with this project:

1. The official docker image [hasn't been updated for 9 years](https://github.com/koreader/koreader-sync-server/issues/37) so I built the image myself.
2. It did not work. I spent two hours troubleshooting and gave up.

Then, I found [kosync-dotnet](https://github.com/jberlyn/kosync-dotnet), _A self-hostable implementation of the KOReader sync server, written in .NET_.

Here is the compose.yml.

```
services:
  kosync:
    container_name: kosync
    image: ghcr.io/jberlyn/kosync-dotnet:latest
    restart: unless-stopped
    volumes:
      - ~/kosync-dotnet/:/app/data
    ports:
      - "127.0.0.1:17200:17200"
    environment:
      - ASPNETCORE_URLS=http://0.0.0.0:17200
      - ADMIN_PASSWORD=foobar
      - REGISTRATION_DISABLED=true
      - TRUSTED_PROXIES=192.168.178.74, 127.0.0.1, 172.30.0.1
    user: 1000:1000
```

- Port is for `127.0.0.1` and not on all interfaces because a proxy is in front of my Docker container.
- `ASPNETCORE_URLS` does listen on all interfaces.
- `REGISTRATION_DISABLED` should be set to false when all users are registered already
- `TRUSTED_PROXIES` is set to my server's IP, and the Docker Gateway IP.
- `user` is set to my users `id` and `gid` to handle permissions correct

After the usual `docker compose up -d` you can check the server with `curl -k -v -H "Accept: application/vnd.koreader.v1+json" http(s)://<server-address>/healthcheck`

## Nginx

As mentioned, a Nginx reverse proxy is in front of my containers that also handles SSL-Termination. The configuration for kosync-dotnet is very straight-forward:

```
server {
    server_name example.com;

    location / {
        proxy_pass http://127.0.0.1:17200; # according to you compose.yml ports
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## The Kosync-dotnet API

First of all, let me say that I never used KOReader sync, though technically I own a Kobo Reader, it is a rebranded device from [Tolino](https://mytolino.com/products/tolino-vision-color/) with its own cloud sync. So this was new territory for me. However, I got it working 😜

Before we continue to set up Crosspoint, we need to create our user with the API.

You can find the `http` syntax for the complete API in the [Appendix](#appendix).

> [!WARNING]
> X-Auth-Key is not the password but the md5 hash of the password!

```http
@authKey = 3a41...
@authUser = admin
@host = <server-address>

POST /manage/users HTTP/1.1
Content-Type: application/json
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}

{
  "username": "NewUserName",
  "password": "super-strong-password"
}
```

## Setting up Crosspoint

You could configure your sync server on device, but I find it more convenient to connect my device with WiFi and access the settings through a web browser

{{< figure src=Crosspoint-settings.png caption="Crosspoint KOReader Sync Settings" >}}

I think the settings are self-explanatory. Don't forget to save the settings.

Back on the device go to Settings - System - KOReader Sync. You should see your configured settings. Now hit "Authenticate" and your reader should be authenticated.

Now you can open an Ebook, hit "Sync Progress" and your progress will be synced. At this point, I got the error `Sync failed - Server error` [^2]

A look in the logs revealed the error `Document hash [ed5a5fd24a25f214d580d2cd196ab373] not found for user [allaman]`.
I don't know why but apparently, documents that are not synced yet cannot be synced. Unfortunately, I have no other device with KOReader available and the installation on macOS was broken.
Fortunately, I can use the API to create a "fake progress" like so:

```http
PUT /syncs/progress HTTP/1.1
Content-Type: application/json
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}

{
  "document": "ed5a5fd24a25f214d580d2cd196ab373",
  "progress": "0",
  "percentage": 0,
  "device": "manual",
  "device_id": "manual"
}
```

For `document` enter the document's hash from the server's error message

Now, when triggering the sync on my device, it finds the document and asks to replace the progress with its local state. 🚀

## Appendix

### Variables

```http
@authKey = 6a54...
@authUser = admin
@host = <server-address>
```

### List all users

```http
GET /manage/users HTTP/1.1
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}
```

### Create a new user

```http
POST /manage/users HTTP/1.1
Content-Type: application/json
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}

{
"username": "max.mustermann",
"password": "super-strong-password"
}
```

### Delete a user

```http
DELETE /manage/users?username=max.mustermann HTTP/1.1
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}
```

### Get documents for a user

```http
GET /manage/users/documents?username=max.mustermmann HTTP/1.1
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}
```

### Delete a document for a user

```http
DELETE /manage/users/documents?username=max.mustermann
&documentHash=3523356ee72c43ba61f5c1bd7b821207 HTTP/1.1
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}
```

### Toggle active status of a user

```http
PUT /manage/users/active?username=max.mustermann HTTP/1.1
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}
```

### Update password for a user

```http
PUT /manage/users/password?username=max.mustermann HTTP/1.1
Content-Type: application/json
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}

{
"password": "super-super-strong-password"
}
```

### Add a document

```http
PUT /syncs/progress HTTP/1.1
Content-Type: application/json
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}

{
"document": "980485cdba3a2d578bdb88ce9d7b0bb9",
"progress": "0",
"percentage": 0,
"device": "manual",
"device_id": "manual"
}
```

[^1]: Ordered at Nov. 1st 2025 and delivered on Nov. 8th 2025

[^2]: Update: There is a sync server from the crosspoint-reader organization itself, [crosspoint-sync](https://github.com/crosspoint-reader/crosspoint-sync) which works perfectly, even for the very first sync!
