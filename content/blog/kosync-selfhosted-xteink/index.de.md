---
title: Einen self-hosted KOReader-Sync mit XTEINK einrichten
summary: Wie man einen KOReader-Sync-Server mit kosync-dotnet und Docker selbst hostet, ihn hinter Nginx einrichtet und mit einem mit Crosspoint-Firmware geflashten XTEINK-Gerät verbindet – einschließlich einer Lösung für den Fehler „document hash not found" beim ersten Sync.
description: Einen KOReader-Sync-Server mit kosync-dotnet, Docker und Nginx self-hosten — und den Lesefortschritt mit dem XTEINK unter Crosspoint-Firmware synchronisieren.
date: 2026-05-08
tags:
  - self-hosted
  - docker
  - eink
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/kosync-selfhosted-xteink/)
{{< /alert >}}

{{< figure src=xteinks.png caption="Meine XTEINK-Sammlung ([mein X4-Case, gedruckt mit PLA Basic und Bambulab P1S](https://makerworld.com/en/models/2657757-xteink-x4-full-body-case?from=search#profileId-2939295))" >}}

Ich war einer der frühen Besitzer[^1] eines [XTEINK](https://www.xteink.com/)-Geräts, nachdem ich die [Rezension](https://www.youtube.com/watch?v=eBW8JeAaMZ8) von [@jvscholz](https://www.youtube.com/@jvscholz) des X4 gesehen hatte. Nach dem Aufkommen dieser kleinen E-Ink-Lesegeräte basierend auf der [ESP-32](https://en.wikipedia.org/wiki/ESP32)-Plattform wurden von der Community mehrere benutzerdefinierte [Firmwares](https://www.readme.club/firmware) entwickelt.

Ich denke, die erste davon, und meine Wahl, ist [Crosspoint](https://github.com/Crosspoint-reader/Crosspoint-reader). Diese Firmware fügt unter vielen anderen Funktionen und Verbesserungen die Fähigkeit hinzu, den X4/X3 mit KOReader zu synchronisieren. In diesem Blogbeitrag beschreibe ich kurz, wie ich einen self-hosted Sync-Server eingerichtet habe und welche Probleme ich dabei hatte.

> [!INFO]
> Dieser Beitrag deckt keine technischen Grundlagen ab und richtet sich eher an erfahrene Leser.

## Docker Compose

Die Mehrheit meiner Workloads läuft heutzutage als Docker-Container, daher war es naheliegend, auch den Sync-Server als Docker-Container zu deployen.

Zunächst schaute ich mir [koreader/koreader-sync-server](https://github.com/koreader/koreader-sync-server), die offizielle Implementierung, an. Dabei stieß ich auf zwei Probleme:

1. Das offizielle Docker-Image [wurde seit 9 Jahren nicht mehr aktualisiert](https://github.com/koreader/koreader-sync-server/issues/37), also baute ich das Image selbst.
2. Es funktionierte nicht. Ich verbrachte zwei Stunden mit der Fehlersuche und gab auf.

Dann fand ich [kosync-dotnet](https://github.com/jberlyn/kosync-dotnet), _eine selbst hostbare Implementierung des KOReader-Sync-Servers, geschrieben in .NET_.

Hier ist die compose.yml.

```
services:
  kosync:
    container_name: kosync
    image: ghcr.io/jberlyn/kosync-dotnet:latest
    restart: unless-stopped
    volumes:
      - ~/kosync-dotnet/:/app/data
    ports:
      - "127.0.0.1:17200:17200"
    environment:
      - ASPNETCORE_URLS=http://0.0.0.0:17200
      - ADMIN_PASSWORD=foobar
      - REGISTRATION_DISABLED=true
      - TRUSTED_PROXIES=192.168.178.74, 127.0.0.1, 172.30.0.1
    user: 1000:1000
```

- Port ist für `127.0.0.1` und nicht für alle Interfaces, da ein Proxy vor dem Docker-Container steht.
- `ASPNETCORE_URLS` lauscht auf allen Interfaces.
- `REGISTRATION_DISABLED` sollte auf false gesetzt werden, wenn alle Benutzer bereits registriert sind.
- `TRUSTED_PROXIES` ist auf die Server-IP und die Docker-Gateway-IP gesetzt.
- `user` ist auf meine Benutzer-`id` und `gid` gesetzt, um Berechtigungen korrekt zu handhaben.

Nach dem üblichen `docker compose up -d` kann der Server mit folgendem Befehl geprüft werden: `curl -k -v -H "Accept: application/vnd.koreader.v1+json" http(s)://<server-adresse>/healthcheck`

## Nginx

Wie bereits erwähnt, steht ein Nginx-Reverse-Proxy vor meinen Containern, der auch die SSL-Terminierung übernimmt. Die Konfiguration für kosync-dotnet ist sehr geradlinig:

```
server {
    server_name example.com;

    location / {
        proxy_pass http://127.0.0.1:17200; # entsprechend der compose.yml-Ports
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Die kosync-dotnet-API

Zunächst möchte ich sagen, dass ich KOReader-Sync noch nie verwendet habe, obwohl ich technisch gesehen einen Kobo-Reader besitze – es ist ein umgelabeltes Gerät von [Tolino](https://mytolino.com/products/tolino-vision-color/) mit seiner eigenen Cloud-Synchronisation. Das war also Neuland für mich. Aber ich habe es zum Laufen gebracht 😜

Bevor wir mit der Einrichtung von Crosspoint fortfahren, müssen wir unseren Benutzer über die API anlegen.

Die vollständige API in der `http`-Syntax ist im [Anhang](#appendix) zu finden.

> [!WARNING]
> X-Auth-Key ist nicht das Passwort, sondern der MD5-Hash des Passworts!

```http
@authKey = 3a41...
@authUser = admin
@host = <server-adresse>

POST /manage/users HTTP/1.1
Content-Type: application/json
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}

{
  "username": "NewUserName",
  "password": "super-strong-password"
}
```

## Crosspoint einrichten

Die Sync-Server-Einstellungen könnten auf dem Gerät konfiguriert werden, aber ich finde es bequemer, das Gerät mit WLAN zu verbinden und die Einstellungen über einen Webbrowser aufzurufen.

{{< figure src=Crosspoint-settings.png caption="Crosspoint KOReader-Sync-Einstellungen" >}}

Ich denke, die Einstellungen erklären sich von selbst. Die Einstellungen nicht vergessen zu speichern.

Zurück auf dem Gerät zu Einstellungen - System - KOReader Sync gehen. Die konfigurierten Einstellungen sollten angezeigt werden. Jetzt „Authentifizieren" drücken und der Lesegerät sollte authentifiziert sein.

Jetzt ein E-Book öffnen, „Fortschritt synchronisieren" drücken und der Fortschritt wird synchronisiert. An diesem Punkt erhielt ich den Fehler `Sync failed - Server error`.

Ein Blick in die Logs offenbarte den Fehler `Document hash [ed5a5fd24a25f214d580d2cd196ab373] not found for user [allaman]`.
Ich weiß nicht warum, aber anscheinend können Dokumente, die noch nicht synchronisiert wurden, nicht synchronisiert werden. Leider hatte ich kein anderes Gerät mit KOReader verfügbar, und die Installation auf macOS war defekt.
Glücklicherweise kann die API verwendet werden, um einen „gefälschten Fortschritt" zu erstellen:

```http
PUT /syncs/progress HTTP/1.1
Content-Type: application/json
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}

{
  "document": "ed5a5fd24a25f214d580d2cd196ab373",
  "progress": "0",
  "percentage": 0,
  "device": "manual",
  "device_id": "manual"
}
```

Für `document` den Hash des Dokuments aus der Fehlermeldung des Servers eingeben.

Wenn jetzt die Synchronisation auf dem Gerät ausgelöst wird, findet es das Dokument und fragt, ob der Fortschritt durch den lokalen Stand ersetzt werden soll. 🚀

## Anhang

### Variablen

```http
@authKey = 6a54...
@authUser = admin
@host = <server-adresse>
```

### Alle Benutzer auflisten

```http
GET /manage/users HTTP/1.1
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}
```

### Neuen Benutzer erstellen

```http
POST /manage/users HTTP/1.1
Content-Type: application/json
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}

{
"username": "max.mustermann",
"password": "super-strong-password"
}
```

### Benutzer löschen

```http
DELETE /manage/users?username=max.mustermann HTTP/1.1
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}
```

### Dokumente für einen Benutzer abrufen

```http
GET /manage/users/documents?username=max.mustermmann HTTP/1.1
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}
```

### Ein Dokument für einen Benutzer löschen

```http
DELETE /manage/users/documents?username=max.mustermann
&documentHash=3523356ee72c43ba61f5c1bd7b821207 HTTP/1.1
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}
```

### Aktiv-Status eines Benutzers umschalten

```http
PUT /manage/users/active?username=max.mustermann HTTP/1.1
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}
```

### Passwort eines Benutzers aktualisieren

```http
PUT /manage/users/password?username=max.mustermann HTTP/1.1
Content-Type: application/json
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}

{
"password": "super-super-strong-password"
}
```

### Ein Dokument hinzufügen

```http
PUT /syncs/progress HTTP/1.1
Content-Type: application/json
Host: {{host}}
X-Auth-Key: {{authKey}}
X-Auth-User: {{authUser}}

{
"document": "980485cdba3a2d578bdb88ce9d7b0bb9",
"progress": "0",
"percentage": 0,
"device": "manual",
"device_id": "manual"
}
```

[^1]: Bestellt am 1. November 2025 und geliefert am 8. November 2025.
