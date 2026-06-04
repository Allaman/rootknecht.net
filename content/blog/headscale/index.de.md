---
title: Self-Hosted Static-IP-Tunneling mit Headscale
description: "vpn, tailscale, netzwerk, macos, linux, debian"
summary: Wie man Headscale und Tailscale für statisches IP-Routing unter Debian und macOS verwendet.
draft: false
date: 2025-04-26
tags:
  - networking
  - self-hosted
  - linux
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/headscale/)
{{< /alert >}}

Von Zeit zu Zeit benötige ich eine statische IP zum Testen bestimmter Firewall-Regeln. Leider bietet mein ISP keine statischen IPs an, aber ich habe Zugang zu einem VPS mit einer statischen öffentlichen IP. Daher war meine Idee, meinen Traffic über den VPS zu leiten, sodass alle ausgehenden Anfragen von einer statischen IP zu kommen scheinen.

Hier ist eine kurze Anleitung, wie dies mit [headscale](https://headscale.net/stable/), einer Open-Source, self-hosted Implementierung des Tailscale-Kontrollservers, erreicht werden kann.

## VPS

### headscale installieren

Der [Dokumentation](https://headscale.net/stable/setup/install/official/) folgen. Für meinen Debian-VPS:

```sh
export HEADSCALE_VERSION=0.28.0
export HEADSCALE_ARCH=amd64
wget --output-document=headscale.deb "https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_${HEADSCALE_ARCH}.deb"
sudo apt install ./headscale.deb
```

### headscale konfigurieren

Mein Setup ist recht einfach. Die [Dokumentation](https://headscale.net/stable/ref/configuration/) enthält alle Optionen und Erklärungen.

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
  nameservers:
    global:
      - 1.1.1.1
      - 1.0.0.1
      - 2606:4700:4700::1111
      - 2606:4700:4700::1001
database:
  type: sqlite
unix_socket: /var/run/headscale/headscale.sock
unix_socket_permission: "0770"
```

{{< /collapse >}}

### Nginx konfigurieren

Headscale lauscht nur auf localhost, weil meine [Nginx](https://nginx.org/)-Instanz den gesamten eingehenden Traffic verwaltet und HTTPS-Zertifikate über [certbot](https://certbot.eff.org/) handhabt.
Der folgende Ausschnitt lässt die automatisch generierte HTTPS-Konfiguration aus.

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

### Dienst aktivieren und starten

Das installierte `deb`-Paket enthält eine systemd-Konfiguration.

```sh
systemctl enable --now headscale
systemctl status headscale
# Logs
journalctl -xeu headscale.service
```

### IP-Weiterleitung

Standardmäßig leitet Debian keinen Traffic weiter, daher muss dies aktiviert werden:

```sh
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -p
```

### tailscale installieren

Ja, tailscale muss ebenfalls installiert werden! ([Dokumentation](https://tailscale.com/kb/1031/install-linux))

```sh
curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
apt update
apt install tailscale
```

### Exit Node einrichten

Aus der [tailscale-Dokumentation](https://tailscale.com/kb/1103/exit-nodes):

> You can route all your public internet traffic by setting a device on your network as an exit node. When you route all traffic through an exit node, you're effectively using default routes (0.0.0.0/0, ::/0), similar to how you would if you were using a typical VPN.

Genau das wollen wir 😊

```sh
headscale users create max.mustermann # Benutzer erstellen, um Nodes zuzuordnen
tailscale up --login-server https://example.net --advertise-exit-node
headscale nodes approve-routes --identifier 1 --routes 0.0.0.0/0 # „1" ist die Node-ID
```

[headscale-Dokumentation](https://headscale.net/stable/ref/exit-node/)

## Client-Konfiguration

Den [Anweisungen](https://tailscale.com/download) für die jeweilige Plattform folgen, um tailscale auf dem Client zu installieren.

```sh
tailscale login --login-server https://example.net
# Client authentifizieren
tailscale set --exit-node neu # Name des neuen Nodes
```

{{< figure src=gui.jpg caption="Tailscale-GUI läuft mit einem Exit Node" >}}
