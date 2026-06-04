---
title: Einfacher Reverse Proxy mit Caddy
description: "devops, proxy, caddy, self-hosted"
summary: "Stellen Sie sich vor, Sie benötigen einen einfachen Reverse Proxy für einen Ihrer Server, haben aber keine Berechtigung, Nginx, Apache usw. zu installieren. Oder Sie brauchen wirklich nur einen einfachen Proxy und möchten sich nicht mit Proxy-Konfigurationen herumschlagen. In diesem Beitrag schauen wir uns einen vergleichsweise neuen Proxy namens `Caddy` an, der für dieses Szenario ideal ist."
draft: false
date: 2022-03-05
tags:
  - self-hosted
  - tools
  - devops
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/caddy-proxy/)
{{< /alert >}}

## Was ist Caddy[^1]

[Caddy](https://github.com/caddyserver/caddy)

> ... is a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go

Caddy bietet weit mehr als nur einen einfachen Reverse Proxy. Hier sind einige Funktionen aus der README:

- Automatisches HTTPS standardmäßig
- Dynamische Konfiguration mit der [JSON API](https://caddyserver.com/docs/api)
- Produktionsreif nach dem Bedienen von Billionen von Anfragen und dem Verwalten von Millionen von TLS-Zertifikaten
- Hochgradig erweiterbare modulare Architektur lässt Caddy alles tun, ohne unnötig aufzublähen
- Läuft überall ohne externe Abhängigkeiten (nicht einmal libc)
- ...

## Installation

Caddy kann mit herkömmlichen Paketmanagern installiert werden. Siehe die [Installationsseite](https://caddyserver.com/docs/install). Außerdem ist Caddy als plattformübergreifendes Single-Binary von den [Releases](https://github.com/caddyserver/caddy/releases)- oder [Download](https://caddyserver.com/download)-Seiten erhältlich. Dadurch sind keine Root-Rechte auf dem System erforderlich, und Caddy kann von einem Nicht-Root-Benutzer „installiert" und ausgeführt werden.

Hier ist ein Beispiel für ein minimales Installationsskript:

```sh
#/bin/sh

curl -fsSL "https://caddyserver.com/api/download?os=$(uname)&arch=$(uname --processor)" -o caddy
chmod +x caddy
```

## Konfiguration

Caddy kann für den grundlegenden Einsatz nur über Kommandozeilenargumente ausgeführt werden, z. B. `caddy reverse-proxy -from 0.0.0.0:8080 -to google.com`.

`Caddyfiles`, Caddys Konfigurationsdatei, bieten mehr Kontrolle. Die folgende Konfiguration weist Caddy an, ...

- ... auf Port 8080 zu lauschen
- ... automatisches HTTPS zu deaktivieren
- ... die Admin-Schnittstelle zu deaktivieren (dynamische Konfiguration via API)
- ... im JSON-Format zu loggen
- ... Anfragen an `/` an google.com weiterzuleiten
- ... den Header zu setzen

```
{
  admin off
  auto_https off
}
:8080 {
  log {
    format json
    output stdout
  }
  reverse_proxy /* {
    to https://google.com
    header_up Host {http.reverse_proxy.upstream.hostport}
  }
}
```

[Direkter Download](./Caddyfile) des Beispiel-Caddyfiles.

Es gibt viele weitere Konfigurationsoptionen, z. B. Load Balancing und Health Checking. Siehe [reverse-proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy) für eine vollständige Liste der Optionen.

Caddy mit dieser Konfiguration starten: `caddy run -config Caddyfile`

## Betrieb

Eine Caddy-Installation über einen Paketmanager enthält normalerweise eine Service-Datei zur Steuerung (Start, Stop) von Caddy via systemd. Wer nur das Caddy-Binary herunterlädt, kann eine eigene Service-Datei schreiben. Es gibt sogar eine [Dokumentation](https://caddyserver.com/docs/running#manual-installation) zur Erstellung eines Services.

Es gibt aber einen einfacheren Weg! Die meisten Unix-Systeme haben [screen](https://en.wikipedia.org/wiki/GNU_Screen) vorinstalliert. Screen ist ein Terminal-Multiplexer und für die eigene Toolbox dringend empfehlenswert, nicht nur auf Servern, sondern auch auf lokalen Workstations. [Tmux](https://github.com/tmux/tmux/wiki) ist eine Alternative zu screen, die normalerweise nicht vorinstalliert ist. Da wahrscheinlich keine Root-Rechte vorhanden sind, um Tmux zu installieren, konzentrieren wir uns auf screen. Ich habe auch eine [Einführung](/knowledge/applications/tmux/) für Tmux geschrieben.

Die wichtigste Funktion für unseren Anwendungsfall ist, dass eine screen-Shell nach dem Ausloggen aus der (übergeordneten) Shell nicht beendet wird, sondern weiterläuft – ebenso wie die darin gestartete Anwendung.

Hier ist eine einfache Demonstration: Eine neue screen-Sitzung kann mit `screen` gestartet werden. Jetzt einen Befehl ausführen, z. B. `top` oder `htop`. Um sich von der aktuellen screen-Sitzung zu trennen, `Ctrl-a d` drücken. Das bringt einen zurück zur ursprünglichen Shell. Um die screen-Sitzung wieder anzuhängen, `screen -r` ausführen. Das (h)top-Programm läuft noch!

Diese Funktion kann genutzt werden, um den Caddy-Server zu starten. In die Maschine einloggen und folgende Befehle ausführen:

```sh
screen
caddy run -config Caddyfile
<Ctrl-a d>
```

Jetzt läuft Caddy in einer screen-Sitzung, und man kann sich vom Server ausloggen, ohne den Caddy-Prozess zu beenden.

## Zusammenfassung

In diesem Beitrag haben wir nur an der Oberfläche der Funktionen von Caddy gekratzt, und es gibt noch viel mehr zu entdecken. Für jemanden, der von altgedienten Apache/HAproxy/Nginx-Servern kommt, ist es so aufregend, wie einfach und schnell ein funktionaler (Proxy-)Server aufgesetzt werden kann, der produktionsreif ist. Es gibt auch Lösungen für Themen, die in diesem Beitrag nicht behandelt wurden, wie [Monitoring](https://caddyserver.com/docs/metrics), [Logging](https://caddyserver.com/docs/logging) oder [TLS](https://caddyserver.com/docs/automatic-https).

[^1]: Haben Sie den falsch geschriebenen Namen im Hero-Bild bemerkt? DALL-E ist schuld :grinning_face:
