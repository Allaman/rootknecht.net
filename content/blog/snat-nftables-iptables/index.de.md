---
title: Grundlegendes SNAT mit nftables und iptables
description: "netzwerk, linux, debian, proxy, firewall, iptables, nftables, snat"
summary: SNAT ersetzt die IP eines Clients durch eine statische IP; dies kann mit iptables oder nftables eingerichtet werden, wie in einem Docker-Beispiel gezeigt.
draft: false
date: 2025-07-09
tags:
  - networking
  - self-hosted
  - linux
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/snat-nftables-iptables/)
{{< /alert >}}

## SNAT kurz erklärt

SNAT steht für _Source Network Address Translation_ und ist eine Art _Network Address Translation_ (NAT).
SNAT ersetzt die Client-IP-Adresse (Quelle), die dynamisch sein könnte, durch eine statische IP-Adresse.
Vorteile sind beispielsweise, dass Firewall-Regeln auf eine bekannte statische IP angewendet werden können und Netzwerkdetails verborgen bleiben.

{{< mermaid >}}
graph LR
A["`Client
172.20.0.2`"] e1@--> C["`Proxy
172.20.0.3`"]
e1@{ animate: slow }
C e2@--> D["`Server
172.20.0.4`"]
e2@{ animate: slow }
D e3@-- 172.20.0.3 --- A
e3@{ animate: slow }
{{< /mermaid >}}

Ein Client spricht mit dem Server über die IP-Adresse des Proxys. Das [Docker-Beispiel](#docker-example) stellt dieses Szenario bereit.

## IP-Weiterleitung

IP-Weiterleitung muss aktiviert sein, damit der Proxy in der Lage ist, Pakete an andere Ziele weiterzuleiten.

Prüfen, ob sie bereits aktiviert ist: `cat /proc/sys/net/ipv4/ip_forward`.

Aktivieren mit:

```sh
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sysctl -p
```

Außerdem muss die Routing-Tabelle des Clients angepasst werden, damit Traffic über den Proxy geleitet wird.

Beispiel für ein sehr einfaches Setup ohne weitere Netzwerkschichten dazwischen:

```sh
ip route add 172.20.0.4/32 via 172.20.0.3 dev eth0
```

## iptables

iptables ist das klassische Linux-Programm zur Konfiguration der Kernel-Firewall.

{{< alert >}}
Auf Systemen, wo `iptables` tatsächlich auf `iptables-nft` verweist, kann es Probleme geben. Der folgende Code funktioniert mit `iptables-legacy`.
{{< /alert >}}

```sh
SOURCE_NET=192.168.178.0/24
IP=$(ip -4 -o addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)
sudo iptables -t nat -A POSTROUTING -s $SOURCE_NET -o eth0 -j SNAT --to-source $IP
```

{{< alert icon="fire" cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
Das ist nicht persistent. Einen Blick auf iptables-save(8) werfen.
{{< /alert >}}

## nftables

nftables ersetzt iptables. Der folgende Code ist äquivalent zur oben stehenden iptables-Regel.

```sh
SOURCE_NET=192.168.178.0/24
IP=$(ip -4 -o addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)
sudo tee /etc/nftables.conf <<EOF
#!/usr/sbin/nft -f

flush ruleset

table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100;
        ip saddr $SOURCE_NET oifname "eth0" snat to $IP
    }
}
EOF

sudo systemctl enable nftables
sudo systemctl start nftables
```

## Docker-Beispiel

Diese Compose-Datei startet drei Container, die als Client, Proxy und Server agieren, und veranschaulicht das Diagramm aus [SNAT kurz erklärt](#snat-in-a-nutshell).

{{< collapse "compose.yml" >}}

```yaml
---
services:
  proxy:
    image: debian:12
    container_name: proxy
    hostname: proxy
    command: |
      bash -c "
        apt-get update && apt-get install -y nftables iproute2
        cat > /etc/nftables.conf << 'EOF'
      #!/usr/sbin/nft -f

      flush ruleset

      table ip nat {
          chain postrouting {
              type nat hook postrouting priority 100;
              ip saddr 172.20.0.0/24 oifname \"eth0\" snat to 172.20.0.3
          }
      }
      EOF
        nft -f /etc/nftables.conf
        tail -f /dev/null
      "
    privileged: true
    networks:
      frontend:
        ipv4_address: 172.20.0.3

  echo-server:
    image: allaman/gecho:main
    container_name: echo-server
    hostname: echo-server
    networks:
      frontend:
        ipv4_address: 172.20.0.4

  client:
    image: debian:12
    container_name: client
    hostname: client
    command: >
      bash -c "
        apt-get update && apt-get install -y iproute2 curl
        ip route add 172.20.0.4/32 via 172.20.0.3 dev eth0
        curl 172.20.0.4:8080
        tail -f /dev/null
      "
    privileged: true
    networks:
      frontend:
        ipv4_address: 172.20.0.2
    depends_on:
      - proxy
      - echo-server

networks:
  frontend:
    ipam:
      config:
        - subnet: 172.20.0.0/24
```

{{< /collapse >}}

{{< figure
    src="curling.jpg"
    alt="curl"
    caption="Der Server sieht die Anfrage als vom Proxy kommend."
    >}}
