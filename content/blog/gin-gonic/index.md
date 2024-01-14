---
title: Single binary web app with Gin-Gonic
summary: What is so special about a single binary with Go you might ask? That is nothing special and a major feature of Go out of the box. Things change when you want to bundle template files and static assets for your Gin-Gonic web application in one binary. In this post I'll explain how I built a single binary web application with HTML templates, CSS, JS and more included.
description: golang, gin, web development, binary, deployment
type: posts
draft: false
date: 2022-02-24
tags:
  - tools
  - golang
  - programming
---

## Gin-Gonic

[Gin-Gonic](https://github.com/gin-gonic/gin) is a Web framework for Go that I have chosen for a little side project (that keeps growing, but this is another story😆)

> Gin is an HTTP web framework written in Go (Golang). It features a Martini-like API with much better performance -- up to 40 times faster. If you need smashing performance, get yourself some Gin.

One decision for my project was that I don't want to write a dedicated front end but keep it old school and rather simple. Enter Server-side rendering (SSR) 🎉

Gin has a nice support for [HTML rendering](https://github.com/gin-gonic/gin#html-rendering) and it was quite straight forward to work with (maybe because I was used to writing `{{}}` from Helm files 😉)

## Rendering HTML

A Hello World with Gin rendered HTML templates looks like as follows.

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

Run the example with the following commands:

```sh
go mod init hello-gin
go mod tidy
go run .
```

You can visit `http://localhost:8080` in your browser and should see your Hello Gin!

{{< figure src=hello-world.png caption="HTML response rendered by Gin" >}}

To build our application and distribute it to our server we run `go build`.

This command will output a single binary `hello-gin` in your project's directory. For demonstrating purpose, move this file to another folder and run it:

```sh
mv hello-gin /tmp
cd /tmp
./hello-gin
```

Now, when you visit `http://localhost:8080` you will see an empty screen and your application will throw an error like this

{{< figure src=hello-world-error.png caption="Missing index.tmpl server error" >}}

Obviously, Gin cannot find the template file which is only in our project's directory together with the source files. By loading a template file I included an external dependency for my application. For me, this is a major drawback as I cannot emphasize the simplicity of only having to deal with a single binary. Therefore, I took some time and researched ways to bundle everything my Gin application requires in one single binary.

In the next chapter, I will to describe two methods to include your templates for rendering HTML as well as all the static assets like CSS, JS, you want to deliver from your Gin application.

## Embed

Before we continue we need to add new files to our application. We want to do some styling with CSS, implement a new route in addition to /index and serve a favicon.

```

├── assets
│   ├── style.css
│   └── favicon.png
├── go.mod
├── go.sum
├── main.go
└── templates
    ├── index.tmpl
    └── ping.tmpl
```

Since version 1.16 Golang supports [embed](https://pkg.go.dev/embed) which basically allows you to create and include a file system (with files) which we will utilize for our goal.

Creating a new file system is very easy. You just add the `go:embed` directive before a variable declaration.

{{< alert >}}
You can not use `.` and `..` in your directive. So you cannot include files files from parent directories just from the current directory or subdirectories!
{{< /alert >}}

```go
//go:embed assets templates
var embeddedFiles embed.FS
```

This results in the following structure of the embedded file system:

```
├── assets
│   ├── style.css
│   └── favicon.png
└── templates
    ├── index.tmpl
    └── ping.tmpl
```

{{< figure src=assets.png caption="CSS and favicon as well as HTML are served" >}}

### HTML templates

Now we can use the created file system to provide the templates to our Gin router:

```go
templ := template.Must(template.New("").ParseFS(embeddedFiles, "templates/*"))
router.SetHTMLTemplate(templ)
```

### Static files

Providing static files like css, js, and images is even easier. Keep in mind

```go
router.StaticFS("/public", http.FS(embeddedFiles))
```

We can reference our assets in our HTML templates like this

```html
<link rel="stylesheet" href="/public/assets/style.css" />
```

### Favicon

Favicon has a special role since it should be served under the root. To accomplish this, I create a dedicated route that returns a `FileFromFS`.

```go
	router.GET("/favicon.png", func(c *gin.Context) {
		c.FileFromFS(".", FaviconFS())
	})
```

`FaviconFS` is a helper function that only return the subpath of the favicon itself:

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
[Here](https://github.com/Allaman/gin-demo) is the full source code
{{< /alert >}}

Now let's build out app, move it to a different folder, and run it:

```
go build
mv hello-gin /tmp
cd /tmp
./hello-gin
```

When we open `http://localhost:8080/` we see our functional web page. To confirm that all resources are loaded we can have a look at our browser's dev tools.

## Wrap up

I was really surprised how easy it is to included static files in your Go binary and keep the build and the distribution so simple and straight forward. - [Gin](https://github.com/codegangsta/gin) is also quite handy when you are building your Gin-gonic powered app. With Gin you can live reload your application by just running `gin --appPort 8080 run`
