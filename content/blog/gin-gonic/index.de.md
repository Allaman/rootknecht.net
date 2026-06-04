---
title: Single-Binary-Webanwendung mit Gin-Gonic
summary: Was ist so besonders an einem Single Binary mit Go, könnte man fragen? Das ist eigentlich nichts Besonderes und ein Hauptmerkmal von Go. Die Dinge ändern sich, wenn man Template-Dateien und statische Assets für eine Gin-Gonic-Webanwendung in einem einzigen Binary bündeln möchte. In diesem Beitrag erkläre ich, wie ich eine Single-Binary-Webanwendung mit eingebetteten HTML-Templates, CSS, JS und mehr gebaut habe.
description: golang, gin, webentwicklung, binary, deployment
type: posts
draft: false
date: 2022-02-24
tags:
  - tools
  - golang
  - programming
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/gin-gonic/)
{{< /alert >}}

## Gin-Gonic

[Gin-Gonic](https://github.com/gin-gonic/gin) ist ein Web-Framework für Go, das ich für ein kleines Nebenprojekt gewählt habe (das immer größer wird, aber das ist eine andere Geschichte 😆)

> Gin is an HTTP web framework written in Go (Golang). It features a Martini-like API with much better performance -- up to 40 times faster. If you need smashing performance, get yourself some Gin.

Eine Entscheidung für mein Projekt war, kein dediziertes Frontend schreiben zu wollen, sondern es altmodisch und eher einfach zu halten. Willkommen, Server-Side Rendering (SSR) 🎉

Gin hat eine gute Unterstützung für [HTML-Rendering](https://github.com/gin-gonic/gin#html-rendering), und es war recht unkompliziert damit zu arbeiten (vielleicht weil ich es gewohnt war, `{{}}` aus Helm-Dateien zu schreiben 😉)

## HTML rendern

Ein Hello World mit Gin-gerenderten HTML-Templates sieht wie folgt aus.

`index.tmpl`

```html
<html>
  <h1>{{ .title }}</h1>
</html>
```

`main.go`

```go
package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()
	router.LoadHTMLFiles("index.tmpl")
	router.GET("/index", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.tmpl", gin.H{
			"title": "Hello Gin!",
		})
	})
	router.Run(":8080")
}
```

Das Beispiel mit folgenden Befehlen ausführen:

```sh
go mod init hello-gin
go mod tidy
go run .
```

`http://localhost:8080` im Browser aufrufen und „Hello Gin!" sollte zu sehen sein!

{{< figure src=hello-world.png caption="HTML-Antwort, gerendert von Gin" >}}

Um die Anwendung zu bauen und auf den Server zu verteilen, wird `go build` ausgeführt.

Dieser Befehl gibt ein einzelnes Binary `hello-gin` im Projektverzeichnis aus. Zum Testen die Datei in einen anderen Ordner verschieben und ausführen:

```sh
mv hello-gin /tmp
cd /tmp
./hello-gin
```

Wenn jetzt `http://localhost:8080` aufgerufen wird, ist der Bildschirm leer, und die Anwendung wirft einen Fehler wie diesen:

{{< figure src=hello-world-error.png caption="Fehlender index.tmpl Server-Fehler" >}}

Offensichtlich kann Gin die Template-Datei nicht finden, die sich nur im Projektverzeichnis neben den Quelldateien befindet. Durch das Laden einer Template-Datei wurde eine externe Abhängigkeit für die Anwendung eingeführt. Das ist für mich ein wesentlicher Nachteil, da ich die Einfachheit, nur mit einem einzelnen Binary umgehen zu müssen, nicht betonen kann. Daher habe ich einige Zeit damit verbracht, Wege zu recherchieren, alles, was meine Gin-Anwendung benötigt, in ein einziges Binary zu bündeln.

Im nächsten Kapitel beschreibe ich zwei Methoden, Templates für das Rendern von HTML sowie alle statischen Assets wie CSS und JS einzuschließen, die aus der Gin-Anwendung heraus bereitgestellt werden sollen.

## Embed

Bevor wir fortfahren, müssen neue Dateien zur Anwendung hinzugefügt werden. Wir möchten etwas CSS-Styling vornehmen, eine neue Route zusätzlich zu /index implementieren und ein Favicon bereitstellen.

```

├── assets
│   ├── style.css
│   └── favicon.png
├── go.mod
├── go.sum
├── main.go
└── templates
    ├── index.tmpl
    └── ping.tmpl
```

Seit Version 1.16 unterstützt Golang [embed](https://pkg.go.dev/embed), was es im Wesentlichen ermöglicht, ein Dateisystem (mit Dateien) zu erstellen und einzubinden, das wir für unser Ziel nutzen werden.

Ein neues Dateisystem zu erstellen ist sehr einfach. Man fügt einfach die `go:embed`-Direktive vor einer Variablendeklaration hinzu.

{{< alert >}}
In der Direktive können `.` und `..` nicht verwendet werden. Daher können keine Dateien aus übergeordneten Verzeichnissen eingebunden werden, sondern nur aus dem aktuellen Verzeichnis oder Unterverzeichnissen!
{{< /alert >}}

```go
//go:embed assets templates
var embeddedFiles embed.FS
```

Das ergibt folgende Struktur des eingebetteten Dateisystems:

```
├── assets
│   ├── style.css
│   └── favicon.png
└── templates
    ├── index.tmpl
    └── ping.tmpl
```

{{< figure src=assets.png caption="CSS und Favicon sowie HTML werden bereitgestellt" >}}

### HTML-Templates

Jetzt kann das erstellte Dateisystem verwendet werden, um dem Gin-Router die Templates bereitzustellen:

```go
templ := template.Must(template.New("").ParseFS(embeddedFiles, "templates/*"))
router.SetHTMLTemplate(templ)
```

### Statische Dateien

Statische Dateien wie CSS, JS und Bilder bereitzustellen ist noch einfacher. Zu beachten ist:

```go
router.StaticFS("/public", http.FS(embeddedFiles))
```

In den HTML-Templates kann auf die Assets so verwiesen werden:

```html
<link rel="stylesheet" href="/public/assets/style.css" />
```

### Favicon

Das Favicon hat eine besondere Rolle, da es unter dem Root bereitgestellt werden sollte. Dafür wird eine dedizierte Route erstellt, die ein `FileFromFS` zurückgibt.

```go
	router.GET("/favicon.png", func(c *gin.Context) {
		c.FileFromFS(".", FaviconFS())
	})
```

`FaviconFS` ist eine Hilfsfunktion, die nur den Unterpfad des Favicons selbst zurückgibt:

```go
func FaviconFS() http.FileSystem {
	sub, err := fs.Sub(embeddedFiles, "assets/favicon.png")
	if err != nil {
		panic(err)
	}
	return http.FS(sub)
}
```

{{< alert >}}
[Hier](https://github.com/Allaman/gin-demo) ist der vollständige Quellcode
{{< /alert >}}

Jetzt die App bauen, in einen anderen Ordner verschieben und ausführen:

```
go build
mv hello-gin /tmp
cd /tmp
./hello-gin
```

Wenn `http://localhost:8080/` geöffnet wird, ist die funktionierende Webseite zu sehen. Um zu bestätigen, dass alle Ressourcen geladen werden, können die Entwicklertools des Browsers geöffnet werden.

## Zusammenfassung

Ich war wirklich überrascht, wie einfach es ist, statische Dateien in ein Go-Binary einzubinden und Build und Verteilung so einfach und unkompliziert zu gestalten. - [Gin](https://github.com/codegangsta/gin) ist auch sehr praktisch beim Entwickeln einer Gin-gonic-gestützten App. Mit Gin kann die Anwendung durch einfaches Ausführen von `gin --appPort 8080 run` live neu geladen werden.
