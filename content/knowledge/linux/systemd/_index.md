---
title: systemd
---

{{< toc >}}

## Simple generic service file

`/etc/systemd/system/foo.service`

```ini
[Unit]
Description=Foo
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/foo
LimitNOFILE=1024
PIDFile=/var/run/foo/running.pid
ExecStart=/bin/foo start
ExecStop=/bin/foo stop
KillSignal=SIGTERM
Restart=on-abort
User=nobody
Group=nobody
RestartSec=9
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=foo

[Install]
WantedBy=multi-user.target
```

## Mappings of limits

Credits to [this](https://unix.stackexchange.com/questions/345595/how-to-set-ulimits-on-service-with-systemd/345596#345596) StackOverflow answer!

| Directive        | ulimit equivalent | Unit                       |
| ---------------- | ----------------- | -------------------------- |
| LimitCPU=        | ulimit -t         | Seconds                    |
| LimitFSIZE=      | ulimit -f         | Bytes                      |
| LimitDATA=       | ulimit -d         | Bytes                      |
| LimitSTACK=      | ulimit -s         | Bytes                      |
| LimitCORE=       | ulimit -c         | Bytes                      |
| LimitRSS=        | ulimit -m         | Bytes                      |
| LimitNOFILE=     | ulimit -n         | Number of File Descriptors |
| LimitAS=         | ulimit -v         | Bytes                      |
| LimitNPROC=      | ulimit -u         | Number of Processes        |
| LimitMEMLOCK=    | ulimit -l         | Bytes                      |
| LimitLOCKS=      | ulimit -x         | Number of Locks            |
| LimitSIGPENDING= | ulimit -i         | Number of Queued Signals   |
| LimitMSGQUEUE=   | ulimit -q         | Bytes                      |
| LimitNICE=       | ulimit -e         | Nice Level                 |
| LimitRTPRIO=     | ulimit -r         | Realtime Priority          |
| LimitRTTIME=     | No equivalent     |

```
ulimit -c unlimited is the same as LimitCORE=infinity
ulimit -v unlimited is the same as LimitAS=infinity
ulimit -m unlimited is the same as LimitRSS=infinity
```

## Interact with systemd

Reload changes

```sh
systemctl daemon-reload
```

List unit files

```sh
systemctl list-unit-files [--state=[LODA|SUB|ACTIVE|failed]]
```

Enable/Disable unit

```sh
systemctl enable|disable FOO
```

Edit unit file

```sh
systemctl edit --full FOO # or just by directly editing the file
```

Start/Stop/Reload/Restart

```sh
systemctl start/stop/reload/restart FOO
```
