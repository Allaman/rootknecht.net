---
title: Business Logic in Nginx
summary: Nginx ist ein beliebter Web-Server/-Proxy, der häufig verwendet wird, um Frontend-Anwendungen in einem Docker-Container bereitzustellen. Aber wussten Sie, dass man mit Nginx auch (Business-)Logik implementieren kann? Hier ist wie!
description: nginx, lua, proxy, webserver
type: posts
draft: false
date: 2023-10-02
tags:
  - devops
  - tools
  - web
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/logic-in-nginx/)
{{< /alert >}}

## Motivation

In manchen Fällen braucht man etwas mehr Logik im Web-Proxy, um bestimmten Traffic zu verarbeiten, insbesondere wenn dieser Traffic _bevor_ er an die „Upstream"-Anwendung weitergeleitet wird, behandelt werden muss. In diesem Fall soll der Proxy eine Logik implementieren, um Aktionen zu bestimmen, _bevor_ die Anfrage von der eigentlichen Anwendung verarbeitet wird.

## Lua und OpenResty

[OpenResty](https://openresty.org/en/) bietet eine Plattform mit Nginx und Lua-Scripting-Fähigkeiten (und mehr). [Lua](https://www.lua.org/) ist eine gängige Programmiersprache zur Einbettung von Skripten in Anwendungen und ist recht unkompliziert. Zum Beispiel bietet auch [Neovim](https://neovim.io/) eine Lua-API, und ich habe meine gesamte [Neovim-Konfiguration](https://github.com/Allaman/nvim/) in Lua geschrieben.

## Beispiel

{{< alert >}}
Um diesem Beispiel zu folgen, muss [Docker](https://www.docker.com/) oder [Podman](https://podman.io/) installiert sein.
{{< /alert >}}

Die folgenden Ausschnitte veranschaulichen einen einfachen Anwendungsfall:

Anfragen mit einem Parameter `id` sollen basierend auf dem Wert dieses Parameters behandelt werden. Wenn `id < 10`, soll zu Bing weitergeleitet werden, und wenn `id >= 10`, soll zu Google weitergeleitet werden.

### Nginx-Konfiguration

Zunächst ein Verzeichnis für die Dateien erstellen:

```sh
mkdir nginx-logic
cd nginx-logic
```

Dann die Konfigurationsdatei für Nginx mit der Lua-Logik zur Verarbeitung des Parameters schreiben.

```
touch default.conf
```

`default.conf` mit einem Editor bearbeiten.

```
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    location / {
        access_by_lua_block {
            local args = ngx.req.get_uri_args()
            for key, val in pairs(args) do
                if key == "id" then
                    if tonumber(val) >= 10 then
                        return ngx.redirect("https://google.com/?q=" .. val , ngx.HTTP_MOVED_PERMANENTLY)
                    end
                    if tonumber(val) < 10 then
                        return ngx.redirect("https://bing.com/?q=" .. val , ngx.HTTP_MOVED_PERMANENTLY)
                    end
                end
            end
        }
    }
}
```

Die Magie liegt im `access_by_lua_block`, der sich von selbst erklärt. Weitere Details und viele weitere Features finden sich in der [Dokumentation](https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/).

### Dockerfile

Nun das Dockerfile erstellen:

```
touch Dockerfile
```

`Dockerfile` mit einem Editor bearbeiten.

```Dockerfile
FROM openresty/openresty
COPY default.conf /etc/nginx/conf.d/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Ganz einfach: Die `default.conf` wird in das Image kopiert, das auf OpenResty basiert.

### Ausführen

Das Docker-Image mit `docker build . -t nginx-logic` bauen und mit `docker run -it --rm --name nginx-logic -p 3000:80 nginx-logic` ausführen.

Nun den Dienst abfragen (in den Screenshots verwende ich [httpie](https://httpie.io/) als curl-Alternative).

```
curl -I -L localhost:3000/?id=9
```

{{< figure src=bing.png caption="Unsere Anfrage wird zu Bing weitergeleitet" >}}

```
curl -I -L localhost:3000/?id=11
```

{{< figure src=google.png caption="Unsere Anfrage wird zu Google weitergeleitet" >}}

```
curl -I -L localhost:3000
```

{{< figure src=default.png caption="Die Standardseite; das könnte Ihr Frontend sein" >}}

## Fazit

Ein einfacher Anwendungsfall wurde implementiert, aber man kann sich vorstellen, welche Flexibilität diese Technik bietet. Im Allgemeinen würde ich es vorziehen, Business-Komponenten in Anwendungen zu implementieren. In bestimmten Szenarien kann es jedoch viel günstiger sein, eine solche Logik auf der „Infrastrukturebene" einzubeziehen, anstatt die Anwendungsarchitektur zu überarbeiten.
