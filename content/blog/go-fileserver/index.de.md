---
title: Single-Binary-Fileserver auf Basis von Go's embed-Feature
description: "netzwerk, golang, programmierung, devops, server"
summary: "Poor Man's Web Framework: Wie Go's embed-Paket den gesamten Web-Stack ersetzt"
draft: false
date: 2025-07-11
tags:
  - networking
  - programming
  - golang
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/go-fileserver/)
{{< /alert >}}

Obwohl es wahrscheinlich nicht alle gefühlten Milliarden JS-Frameworks ersetzen wird, zeige ich in diesem Blogbeitrag, wie man eine Webanwendung in einem einzigen Binary verteilen kann.

## Was ist das embed-Paket

Aus der [Dokumentation](https://pkg.go.dev/embed):

> Package embed provides access to files embedded in the running Go program.

Mit anderen Worten: Man kann beliebige Dateien in ein Go-Binary „verpacken" und darauf zugreifen.

## Anwendungsfälle und Vorteile

- Handhabbar für Nicht-Frontend-Entwickler/Systemadministratoren
- Deployment als einzelnes Binary
- Keine externen Abhängigkeiten
- Kein Nginx/Apache/Caddy konfigurieren nötig
- Sicher, da das Dateisystem in sich geschlossen ist
- HTML/Template-Dateien einbinden
- Für interne (Admin-)Dashboards
- Zur schnellen Dateiverteilung
- Aber auch für vollwertige Web-Apps, bei denen Backend und Frontend in einem einzigen Binary verteilt werden

## Beispiel

Ein minimales Fileserver-Beispiel, das eine index.html-Datei bereitstellt.
Diese Zeilen weisen Go an, alle Dateien aus dem Verzeichnis „static" einzubetten. So einfach ist das 🙂

```go
//go:embed static/*
var staticFiles embed.FS
```

Ein Sub-Dateisystem mit dem fs-Paket erstellen und „static" vom Pfad entfernen.

```go
 staticFS, err := fs.Sub(staticFiles, "static")
```

Einen http.handler mit diesem Dateisystem erstellen.

```go
 fileServer := http.FileServer(http.FS(staticFS))
```

Zum Abschluss Routen einrichten:

```go
 http.Handle("/", fileServer)
```

{{< collapse "Klicken, um den vollständigen Code zu öffnen" >}}

```go
package main

import (
 "embed"
 "io/fs"
 "log"
 "net/http"
)

//go:embed static/*
var staticFiles embed.FS

func main() {

 staticFS, err := fs.Sub(staticFiles, "static")
 if err != nil {
  log.Fatal("Failed to create sub-filesystem:", err)
 }

 fileServer := http.FileServer(http.FS(staticFS))

 http.Handle("/", fileServer)

 if err := http.ListenAndServe(":8080", nil); err != nil {
  log.Fatal("Server failed to start:", err)
 }
}
```

In `static/index.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Embedded File Server</title>
  </head>
  <body>
    <div>
      <h1>🚀 Embedded File Server</h1>
      <p>This page is served from an embedded filesystem!</p>
      <div>
        <h3>Features:</h3>
        <ul>
          <li>All files embedded in single binary</li>
          <li>No external dependencies</li>
          <li>Cross-platform compatible</li>
          <li>Easy deployment</li>
        </ul>
      </div>
    </div>
  </body>
</html>
```

`go run .` ausführen und `http://localhost:8080` im Browser öffnen.

{{< /collapse >}}
