---
title: Easy reverse proxy with Caddy
description: "devops, proxy, caddy, self-hosted"
summary: "Imagine you require a simple reverse proxy for one of your servers but you don't have the permission to install Nginx, Apache etc. Or you really just need a simple proxy and don't want to mess around with proxy configuration. In this post we will have a look for an comparatively new proxy called `Caddy` which is a perfect match for this scenario."
draft: false
date: 2022-03-05
tags:
  - self-hosted
  - tools
  - devops
---

## What is Caddy[^1]

[Caddy](https://github.com/caddyserver/caddy)

> ... is a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go

Caddy offers way more than just being a simple reverse proxy. Here are some of its features from the README:

- Automatic HTTPS by default
- Dynamic configuration with the [JSON API](https://caddyserver.com/docs/api)
- Production-ready after serving trillions of requests and managing millions of TLS certificates
- Highly extensible modular architecture lets Caddy do anything without bloat
- Runs anywhere with no external dependencies (not even libc)
- ...

## Installation

Caddy can be installed with traditional package managers. Refer to the [install](https://caddyserver.com/docs/install) page. Additionally, caddy is also available as cross platform single binary from the [releases](https://github.com/caddyserver/caddy/releases) or [download](https://caddyserver.com/download) pages. This way, you don't need root privileges on your system and Caddy can be "installed" and run by a non root user.

Here is an example of a minimal installation script:

```sh
#/bin/sh

curl -fsSL "https://caddyserver.com/api/download?os=$(uname)&arch=$(uname --processor)" -o caddy
chmod +x caddy
```

## Configuration

Caddy can be run by just command line arguments for basic usage, e.g. `caddy reverse-proxy -from 0.0.0.0:8080 -to google.com`.

`Caddyfiles`, Caddy's configuration file, offer more control over caddy. The following configuration tells Caddy ...

- ... to listen on port 8080
- ... to disable automatic HTTPS
- ... to disable the admin interface (dynamic configuration vir API)
- ... to log in json format
- ... to proxy requests to `/` to google.com
- ... to set the header

```
{
  admin off
  auto_https off
}
:8080 {
  log {
    format json
    output stdout
  }
  reverse_proxy /* {
    to https://google.com
    header_up Host {http.reverse_proxy.upstream.hostport}
  }
}
```

[Direct Download](./Caddyfile) of the example Caddyfile.

There are many more configuration options for example load balancing and health checking, see [reverse-proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy) for a full list of options.

Start Caddy with this config via `caddy run -config Caddyfile`

## Running

A Caddy installation via a package manager usually contains a service file for controlling (start, stop) Caddy via systemd. When you only download the caddy binary you can write your own service file. There is even a [documentation](https://caddyserver.com/docs/running#manual-installation) for creating a service.

But there is an easier method! Most Unix systems have [screen](https://en.wikipedia.org/wiki/GNU_Screen) pre installed. Screen is a terminal multiplexer and highly recommended for your toolbox, not only on servers but also on your local workstations. [Tmux](https://github.com/tmux/tmux/wiki) is a an alternative for screen which usually is not pre installed. As we probably don't have root permissions to install Tmux we will focus on screen. I also wrote an [intro](/knowledge/applications/tmux/) for Tmux.

The most important feature for our use case is that a screen shell is not terminated after you logout of your (parent) shell but continues to run and the application started inside as well.

Let's have a look at a simple demonstration: You can start a new screen session with `screen`. Now, run a command, for instance `top` or `htop`. To detach from the current screen session hit `Ctrl-a d`. This will bring you back to your original shell. To reattach your screen session run `screen -r`. Note that your (h)top program is still running!

We can use this feature to start our Caddy server. Log into your machine and run the following commands.

```sh
screen
caddy run -config Caddyfile
<Ctrl-a d>
```

Now, Caddy is running in a screen session and you can log out from your server without terminating the Caddy process.

## Wrap up

In this post we only scratched the surface of the features of Caddy and there is much more to discover. Coming from old school Apache/HAproxy/Nginx servers, it is so exciting how easy and fast you can spin up a functional (proxy) server that is production ready. There are also solutions for topics not covered in this post, like [monitoring](https://caddyserver.com/docs/metrics), [logging](https://caddyserver.com/docs/logging), or [TLS](https://caddyserver.com/docs/automatic-https).

[^1]: Did you recognize the misspelled name in the hero image? DALL-E is to blame :grinning_face:
