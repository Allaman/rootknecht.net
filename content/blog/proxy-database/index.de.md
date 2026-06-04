---
title: Datenbank via SSH tunneln
summary: Eine kurze Demonstration, wie eine Verbindung zu einer PostgreSQL-Datenbank über SSH hergestellt wird, implementiert mit Docker Compose.
description: datenbank, cloud, netzwerk, linux, ssh
date: 2025-01-20
tags:
  - devops
  - docker
  - configuration
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/proxy-database/)
{{< /alert >}}

## Warum?

Als Workaround für den Zugriff auf Datenbanken zu Debugging-Zwecken, wie z. B. verwaltete Datenbanken in AWS, Azure usw., bietet sich ein SSH-Proxy an, der zur eigenen Umgebung passt.
Man kann beispielsweise eine minimale virtuelle Maschine im selben Netzwerk wie die Datenbank verwenden, aber mit einer öffentlichen Netzwerkschnittstelle.

## Direkt zum Code

```yaml
---
services:
  # Man beachte den fehlenden `ports`-Schlüssel. Postgres öffnet keinen Port auf dem Host.
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: db
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  ssh-proxy:
    image: debian
    # SSH-Daemon installieren und konfigurieren
    command: >
      bash -c "apt-get update &&
              apt-get install -y openssh-server &&
              mkdir /run/sshd &&
              echo 'root:test' | chpasswd &&
              sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config &&
              sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config &&
              sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config &&
              /usr/sbin/sshd -D"
    ports:
      - "443:22"
    networks:
      - backend
    depends_on:
      postgres:
        condition: service_healthy

networks:
  backend:
    driver: bridge
```

In diesem Beispiel haben wir Port 443 für unseren SSH-Proxy konfiguriert (anstelle des üblichen Ports 22).
Das kann in Umgebungen nützlich sein, die nur HTTP(S)-Ports erlauben.

Demo starten:

```sh
docker compose up [-d]
```

Port-Weiterleitung auf dem lokalen Rechner öffnen[^1]:

```sh
ssh -p 443 root@localhost -L 5432:postgres:5432
```

`test` als Passwort eingeben[^2].

Nur prüfen, ob eine TCP-Verbindung hergestellt werden kann (falls kein psql-Client verfügbar ist 😄):

```sh
nc -zv localhost 5432 # netcat
```

Wie gewohnt mit der Datenbank verbinden:

```sh
psql -h localhost -U postgres -d db
```

`postgres` als Passwort verwenden.

## Die „Magie"

Für mich fühlte sich das wie Magie an, als ich zum ersten Mal von `-L` von einem erfahrenen Kollegen hörte.

Aus `man ssh`:

> Specifies that connections to the given TCP port or Unix socket on the local (client) host are to be forwarded to the given host and port, or Unix socket, on the remote side.

Mit anderen Worten bedeutet `5432:postgres:5432`, dass der lokale Port `5432` zum Host `postgres` auf Port `5432` weitergeleitet werden soll, was dem Datenbankcontainer entspricht.

## Überlegungen

- Potenzielle Sicherheitsimplikationen und Compliance-Anforderungen im Hinterkopf behalten. Obwohl die Datenbank technisch intern bleibt, wird eine Tür geöffnet.
- Den Proxy nur bei Bedarf starten.
- SSH-Schlüssel anstelle von Passwort-Authentifizierung in Betracht ziehen.
- Dedizierte Dienste des Cloud-Anbieters für dieses Szenario in Betracht ziehen, wie (verwaltete) Bastions oder VPNs.

[^1]: Einige IDEs bieten eine SSH-Proxy-Einstellung, sodass dieser Schritt nicht nötig ist.

[^2]: Die Sitzung muss geöffnet bleiben, solange mit der Datenbank gearbeitet wird.
