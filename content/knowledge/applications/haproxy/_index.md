---
title: HAProxy
media_order: haproxy_http_log_format.pdf
---

{{< toc >}}

## Forward only config

Can be used as Ansible template; valid for HaProxy 1.8

```
global
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    log         127.0.0.1:514 local2 notice
    log         127.0.0.1:514 local3

    stats socket /var/lib/haproxy/stats

defaults
    mode                    {{ mode }}
    log                     global
{% if mode == "http" %}
    option                  httplog
    option forwardfor       except 127.0.0.0/8
{% else %}
    option                  tcplog
{% endif %}
    option                  dontlognull
    option                  http-server-close
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

backend backend1
    balance     roundrobin
    server      backend1 {{ forward_server1 }}
backend backend2
    balance     roundrobin
    server      backend2 {{ forward_server2 }}

frontend frontend1
    bind *:{{ bind_port1 }}
    default_backend backend1
frontend frontend2
    bind *:{{ bind_port2 }}
    default_backend backend2

listen health_check_http_url
    bind :8888
    mode http
    monitor-uri /health
    option      dontlognull
```

## HAProxy log format

[haproxy_http_log_format.pdf](haproxy_http_log_format.pdf)
