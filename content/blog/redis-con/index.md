---
title: Check the connection to Redis
summary: Recently, I had to check the connectivity to a Redis 6 TLS enabled and password protected instance. In this post, I want to give you an overview of the different approaches to verify if a Redis is up and reachable.
description: devops, redis, go, cli, troubleshooting
date: 2022-04-09
tags:
  - shell
  - programming
  - devops
  - golang
---

## Redis-cli

The official [CLI](https://redis.io/docs/manual/cli/) is the first thing that comes into mind. You can install the CLI in different ways:

1. Via the package `redis-tools` in Debian based distributions. This package might be outdated (depending on your OS). With Homebrew, this package is not available (there is a [tap](https://github.com/aoki/homebrew-redis-cli) that looks unmaintained)
2. As part of the package `redis-server` which includes Redis itself. This package might be outdated as well (depending on your OS) and installs the server component, which is not required.
3. Form the [tarball](http://download.redis.io/redis-stable.tar.gz) with make. This requires some packages like gcc and some time as it is build from source, which is not ideal.

**Example call**

```sh
redis-cli -h localhost -p 6379 [--tls --skipVerify -a <password>]
```

## redli

[Redli](https://github.com/IBM-Cloud/redli) is _a humane alternative to redis-cli_ that looks unmaintained and does not offer a Darwin ARM build. M1 Mac users must build it themself.

**Example call**

```sh
redli -h localhost -p 6379 [--tls --skipverify -a <password>]
```

## nc and ncat

You can use [netcat](https://www.compose.com/articles/how-to-talk-raw-redis/) (or nmap's ncat) to check the connection as well!

```sh
#!/bin/bash
export REDISAUTH=<password>
export REDISHOST=localhost
export REDISPORT=6379
echo -e "*2\r\n\$4\r\nAUTH\r\n\$16\r\n$REDISAUTH\r\n*2\r\n\$4\r\nINFO\r\n\$5\r\nSTATS\r\n" | [nc|ncat] $REDISHOST $REDISPORT
```

Unfortunately, this was not working on my machine.

## chkRedis

Neither of these options was very pleasant on my M1 Mac, so I decided to write my own little helper tool to check the connection to a Redis data store.

The requirements were rather simple:

- Go and cross-platform build including Darwin ARM. By providing a cross-platform binary, I can benefit from the same functionality on every system even without the need of root permissions to install packages.
- Arguments to configure the address, TLS, skipVerify and a password.
- Execute `PING` command to verify the connection.

Have a look at the [repo](https://github.com/Allaman/chkRedis) and its [releases](https://github.com/Allaman/chkRedis/releases) for the result 😊
