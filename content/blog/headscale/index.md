---
title: Self-Hosted Static IP Tunneling with Headscale
description: "vpn, tailscale, networking, macos, linux, debian"
summary: How to use Headscale and Tailscale for static IP routing on Debian and macOS.
draft: false
date: 2025-04-26
tags:
  - networking
  - self-hosted
  - linux
---

From time to time, I require a static IP for testing specific firewall rules. Unfortunately, my ISP does not offer static IPs, but I have access to a VPS with a static public IP. Therefore, my idea was to route my traffic through the VPS so that all outgoing requests would appear from a static IP address.

Here is a brief tutorial on how to achieve this using [headscale](https://headscale.net/stable/), an open-source, self-hosted implementation of the Tailscale control server.

## VPS

### Install headscale

Follow the ([docs](kttps://headscale.net/stable/setup/install/official/)). For my Debian VPS:

```sh
export HEADSCALE_VERSION=0.25.1
export HEADSCALE_ARCH=amd64
wget --output-document=headscale.deb "https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_${HEADSCALE_ARCH}.deb"
sudo apt install ./headscale.deb
```

### Configure headscale

My setup is rather basic. Refer to the [docs]([Documentation](https://headscale.net/stable/ref/configuration/)) for all options and explanations.

{{< collapse "/etc/headscale/config.yaml" >}}

```yaml
---
server_url: https://example.com
listen_addr: 127.0.0.1:8989
metrics_listen_addr: 127.0.0.1:9090
grpc_listen_addr: 127.0.0.1:50443
grpc_allow_insecure: false
private_key_path: /var/lib/headscale/private.key
noise:
  private_key_path: /var/lib/headscale/noise_private.key
prefixes:
  v6: fd7a:115c:a1e0::/48
  v4: 100.64.0.0/10
derp:
  server:
    enabled: false
    region_id: 999
    region_code: "headscale"
    region_name: "Headscale Embedded DERP"
    stun_listen_addr: "0.0.0.0:3478"
  urls:
    - https://controlplane.tailscale.com/derpmap/default
  paths: []
  auto_update_enabled: true
  update_frequency: 24h
disable_check_updates: false
ephemeral_node_inactivity_timeout: 30m
node_update_check_interval: 10s
log:
  format: text
  level: info
dns:
  magic_dns: false
database:
  type: sqlite
unix_socket: /var/run/headscale/headscale.sock
unix_socket_permission: "0770"
```

{{< /collapse >}}

### Configure Nginx

Headscale only listens on localhost because my [Nginx](https://nginx.org/) instance handles all incoming traffic and manages HTTPS certificates via [certbot](https://certbot.eff.org/).
The following snippet omits the auto-generated HTTPS configuration.

{{< collapse "/etc/nginx/sites-available/example.com.conf" >}}

```
map $http_upgrade $connection_upgrade {
    default      upgrade;
    ''           close;
}

server {

    access_log /var/log/nginx/scale.access.log;
    error_log  /var/log/nginx/scale.error.log;

    server_name example.com;

    location / {
        proxy_pass http://127.0.0.1:8989;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        # proxy_set_header Connection $connection_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $server_name;
        proxy_redirect http:// https://;
        proxy_buffering off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;
    }
}
```

{{< /collapse >}}

### Enable and start service

The installed `deb` package includes a systemd config.

```sh
systemctl enable --now headscale
systemctl status headscale
# logs
journalctl -xeu headscale.service
```

### IP Forwarding

By default, Debian does not forward traffic so we need to enabled it:

```sh
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -p
```

### Install tailscale

Yes, we need tailscale installed as well! ([Docs](https://tailscale.com/kb/1031/install-linux))

```sh
curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
apt update
apt install tailscale
```

### Setup a Exit node

From the [tailscale docs](https://tailscale.com/kb/1103/exit-nodes)
> You can route all your public internet traffic by setting a device on your network as an exit node. When you route all traffic through an exit node, you're effectively using default routes (0.0.0.0/0, ::/0), similar to how you would if you were using a typical VPN.

which is exactley what we want 😊

```sh
tailscale up --login-server https://example.net --advertise-exit-node
headscale routes enable -r 3 # ID of the new node
headscale routes enable -r 4 # ID of the new node
```

[headscale docs](https://headscale.net/stable/ref/exit-node/)

## Client config

Follow the [instructions](https://tailscale.com/download) for your platform to install tailscale on your client.

```sh
tailscale login --login-server https://example.net
# Authenticate your client
tailscale set --exit-node neu # name of the new node
```

{{< figure src=gui.jpg caption="Tailscale GUI running with an Exit node" >}}
