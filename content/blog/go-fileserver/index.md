---
title: Single binary fileserver based on Go's 'embed' feature
description: "networking, golang, programming, devops, server"
summary: "Poor Man's Web Framework: How Go's embed Package Replaces Your Entire Web Stack"
draft: false
date: 2025-07-11
tags:
  - networking
  - programming
  - golang
---

While it probably won't replace all quadrillion JS frameworks, in this blog post I'll show you how you can distribute a web app in a single binary.

## What is the embed package

From the [docs](https://pkg.go.dev/embed):

> Package embed provides access to files embedded in the running Go program.

In other words, you can 'package' any files within a Go binary and access them.

## Use cases and advantages

- manageable for non-frontend/sysadmin engineers
- single binary deployment
- no external dependencies
- no need to configure Nginx/Apache/Caddy...
- secure as the filesystem is self-contained
- include HTML/template files
- for internal (admin) dashboards
- for quick file distribution
- but also for full-fledged web apps where your backend and frontend are distributed in one single binary

## Example

"A minimal fileserver example that serves an index.html file.
These lines tell Go to embed all files from the "static" directory. It's that simple 🙂

```go
//go:embed static/*
var staticFiles embed.FS
```

Create a sub-filesystem with the fs package and "trims static" from the path.

```go
 staticFS, err := fs.Sub(staticFiles, "static")
```

Create a http.handler with this filesystem.

```go
 fileServer := http.FileServer(http.FS(staticFS))
```

Finally, setup routes

```go
 http.Handle("/", fileServer)
```

{{< collapse "Click to open the complete code" >}}

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

`go run .` and open `http://localhost:8080` in your browser.

{{< /collapse >}}
