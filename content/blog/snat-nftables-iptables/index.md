---
title: Basic SNAT with nftables and iptables
description: "networking, linux, debian, proxy, firewall, iptables, nftables, snat"
summary: SNAT replaces a client's IP with a static IP to simplify; this can be set up using iptables or nftables, as shown in a Docker example.
draft: false
date: 2025-07-09
tags:
  - networking
  - self-hosted
  - linux
---

## SNAT in a nutshell

SNAT stands for _Source Network Address Translation_ and is a type of _Network Address Translation_ (NAT).
SNAT replaces the client IP address (source), which might be dynamic, with a static IP address.
Advantages include, for instance, that firewall rules can be applied to a known static IP, and network details can be hidden.

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

A Client talks to the server via the Proxy's IP address. The [docker-example](#docker-example) deploys this scenario.

## IP forwarding

IP forwarding must be enabled so that the proxy is capable of forwarding packets to other destinations.

Check if it is allready enabled with `cat /proc/sys/net/ipv4/ip_forward`.

Enable it with:

```sh
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sysctl -p
```

You also need to modify your client’s routing table so that traffic is routed through the proxy.

Example of a very basic setup with no other networking layers in between:

```sh
ip route add 172.20.0.4/32 via 172.20.0.3 dev eth0
```

## iptables

iptables is the classic Linux programm to configure the Kernel's firewall.

{{< alert >}}
There might be some issues on systems where `iptables` actually refers to `iptables-nft`. The following code works with `iptables-legacy`.
{{< /alert >}}

```sh
SOURCE_NET=192.168.178.0/24
IP=$(ip -4 -o addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)
sudo iptables -t nat -A POSTROUTING -s $SOURCE_NET -o eth0 -j SNAT --to-source $IP
```

{{< alert icon="fire" cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
This is not persistent. Have a look at iptables-save(8)
{{< /alert >}}

## nftables

nftables replaces iptables. The following code is equivalent to the iptables rule above.

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

## Docker example

This Compose file starts three containers acting as a client, a proxy, and a server, illustrating the chart in [SNAT in a nutshell](#snat-in-a-nutshell)

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
    caption="Server sees the request coming from the proxy."
    >}}
