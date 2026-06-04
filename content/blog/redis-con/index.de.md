---
title: Konnektivität zu einem Redis prüfen
summary: Kürzlich musste ich die Verbindung zu einer Redis-6-Instanz mit aktiviertem TLS und Passwortschutz prüfen. In diesem Beitrag möchte ich einen Überblick über die verschiedenen Ansätze geben, um zu verifizieren, ob ein Redis erreichbar ist.
description: devops, redis, go, cli, troubleshooting
date: 2022-04-09
tags:
  - shell
  - programming
  - devops
  - golang
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/redis-con/)
{{< /alert >}}

## Redis-cli

Das offizielle [CLI](https://redis.io/docs/manual/cli/) ist das Erste, was einem in den Sinn kommt. Das CLI kann auf verschiedene Weisen installiert werden:

1. Über das Paket `redis-tools` in Debian-basierten Distributionen. Dieses Paket könnte veraltet sein (je nach Betriebssystem). Mit Homebrew ist dieses Paket nicht verfügbar (es gibt ein [tap](https://github.com/aoki/homebrew-redis-cli), das nicht gepflegt zu sein scheint).
2. Als Teil des Pakets `redis-server`, das Redis selbst enthält. Dieses Paket könnte ebenfalls veraltet sein (je nach Betriebssystem) und installiert die Server-Komponente, die nicht erforderlich ist.
3. Aus dem [Tarball](http://download.redis.io/redis-stable.tar.gz) mit make. Das erfordert einige Pakete wie gcc und etwas Zeit, da es aus dem Quellcode kompiliert wird, was nicht ideal ist.

**Beispielaufruf**

```sh
redis-cli -h localhost -p 6379 [--tls --skipVerify -a <passwort>]
```

## redli

[Redli](https://github.com/IBM-Cloud/redli) ist _eine menschlichere Alternative zu redis-cli_, die nicht gepflegt zu sein scheint und keinen Darwin-ARM-Build bietet. M1-Mac-Benutzer müssen es selbst kompilieren.

**Beispielaufruf**

```sh
redli -h localhost -p 6379 [--tls --skipverify -a <passwort>]
```

## nc und ncat

Es kann auch [netcat](https://www.compose.com/articles/how-to-talk-raw-redis/) (oder nmap's ncat) verwendet werden, um die Verbindung zu prüfen!

```sh
#!/bin/bash
export REDISAUTH=<passwort>
export REDISHOST=localhost
export REDISPORT=6379
echo -e "*2\r\n\$4\r\nAUTH\r\n\$16\r\n$REDISAUTH\r\n*2\r\n\$4\r\nINFO\r\n\$5\r\nSTATS\r\n" | [nc|ncat] $REDISHOST $REDISPORT
```

Das hat leider auf meinem Rechner nicht funktioniert.

## chkRedis

Keine dieser Optionen war auf meinem M1 Mac sehr angenehm, also entschied ich mich, mein eigenes kleines Hilfstool zur Überprüfung der Verbindung zu einem Redis-Datenspeicher zu schreiben.

Die Anforderungen waren recht einfach:

- Go und plattformübergreifender Build einschließlich Darwin ARM. Durch Bereitstellen eines plattformübergreifenden Binaries kann auf jedem System von derselben Funktionalität profitiert werden, auch ohne Root-Rechte für die Paketinstallation.
- Argumente zur Konfiguration der Adresse, TLS, skipVerify und eines Passworts.
- `PING`-Befehl ausführen, um die Verbindung zu verifizieren.

Das [Repo](https://github.com/Allaman/chkRedis) und seine [Releases](https://github.com/Allaman/chkRedis/releases) zeigen das Ergebnis 😊
