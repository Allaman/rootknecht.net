---
title: "Network Troubleshooting"
---

{{< toc >}}

## Check DNS

Check `dnsmasq` and `/etc/resolv.conf`

### nslookup

```bash
nslookup DOMAIN.TLD # A record
nslookup IP # rDNS
nslookup -query=any DOMAIN.TLD # query all DNS records
```

### dig

```bash
dig DOMAIN.tld [+short]
dig -x IP +short # rDNS
dig DOMAIN.tld TTL # TTL record
dig DOMAIN.tld ANY +noall +answer # query all DNS records
```

## Check Traceroute

```bash
traceroute www.google.com # uses UDP data on random port
traceroute -I www.google.com # uses ICMP data
traceroute -T -p 80 www.google.com # fix TCP port to test path to services to bypass firewalls
tracepath www.google.com # similar to traceroute but does not require root privilege as it does not manipulate raw packages
mtr -rw www.google.com #send 10 packets and generate report
```

## Check DHCP traffic

```bash
dhcpdump -i INTERFACE
# udp 67 server, udp 68 client
tcpdump -i INTERFACE port 67 or port 68 -e -n
```

## Check bandwidth

### iperf

On your server start

```bash
iperf -s -p SERVERPORT
```

On your client

```bash
iperf -c SERVERIP -p SERVERPORT -t 15 -i 1 -f m
```

- -t 15 runs for 15 seconds
- -l 1 shows output every second
- -f m shows rate in Mbps

## Check local IP

```sh
ip a
ifconfig # deprecated

```

## Routes

List routes

```bash
ip r
route -n # deprecated
```

Add default gateway

```bash
ip route add default via GATEWAYIP
route add default gw GATEWAYIP # deprecated
```

## Check open ports

locally

```bash
lsof -i -P -n [ | grep LISTEN]
ss -tulpen
netstat -tulpen # deprecated
```

on remote

```bash
telnet HOST PORT
nc -zv HOST PORT[-][PORT]
nmap -source-port PORT HOST
```

on remote with minimal tools

```sh
awk 'function hextodec(str,ret,n,i,k,c){
    ret = 0
    n = length(str)
    for (i = 1; i <= n; i++) {
        c = tolower(substr(str, i, 1))
        k = index("123456789abcdef", c)
        ret = ret * 16 + k
    }
    return ret
}
function getIP(str,ret){
    ret=hextodec(substr(str,index(str,":")-2,2));
    for (i=5; i>0; i-=2) {
        ret = ret"."hextodec(substr(str,i,2))
    }
    ret = ret":"hextodec(substr(str,index(str,":")+1,4))
    return ret
}
NR > 1 {{if(NR==2)print "Local - Remote";local=getIP($2);remote=getIP($3)}{print local" - "remote}}' /proc/net/tcp
```

<small>[origin](https://staaldraad.github.io/2017/12/20/netstat-without-netstat/)</small>

programmatically

```bash
#!/bin/bash
ip=$1
ports=( 5443 3443 6443 8443 7443 22 23 7079 8079 80 8080 )
for port in "${ports[@]}"
do
  nc -z -v -w5 $ip $port
done
```

## Check traffic on interface

```bash
iftop -i INTERFACE
nethogs device INTERFACE
```

## Scan with nmap

```bash
nmap -p 1-100 # scan ports
nmap -p- # scan all ports
nmap -sT # use  TCP connect
nmap -sS # use TCP SYN
nmap -sU # scan UDP
nmap -A # OS and service detection
nmap -sV [--version-intensity 5] # Standard service detection (increased aggressivity
nmap -oX outputfile.xml # save as XML
nmap -oG outputfile.txt # save for grep
nmap -sV -sC # use default save scripts
locate nse | grep script # list available scripts
```

Analyze nmap output with [NetworkScanViewer](http://www.woanware.co.uk/network/networkscanviewer.html)
