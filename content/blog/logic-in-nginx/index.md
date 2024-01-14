---
title: Business Logic in Nginx
summary: Nginx is a popular Web-server/-proxy that is often used to serve frontend applications within a Docker container. But did you know that you can also implement some (business) logic with Nginx? Here is how!
description: nginx, lua, proxy, web-server
type: posts
draft: false
date: 2023-10-02
tags:
  - devops
  - tools
  - web
---

## Motivation

In some cases, you need a little bit more logic in your web proxy to handle certain traffic, especially if this traffic needs to be handled _before_ being directed to the "upstream" application. In this case, the proxy should implement some logic to determine actions _before_ the request is handled by the actual application.

## Lua and OpenResty

[OpenResty](https://openresty.org/en/) offers a platform with Nginx and Lua scripting capabilities (and more). [Lua](https://www.lua.org/) is a common programming language for embedding scripts in applications and is quite straightforward. For instance, [Neovim](https://neovim.io/) also offers a Lua API and I wrote my whole [Neovim configuration](https://github.com/Allaman/nvim/) in Lua.

## Example

{{< alert >}}
To follow this example, you need [Docker](https://www.docker.com/) or [Podman](https://podman.io/) installed.
{{< /alert >}}

The following snippets illustrate a simple use case:

We want requests with a parameter `id` to be handled based on the value of said parameter. If `id < 10` then we aim to redirect to Bing and if `id >= 10` then we aim to redirect to Google.

### Nginx conf

First, create a directory for our files:

```sh
mkdir nginx-logic
cd nginx-logic
```

Then we write the configuration file for Nginx with the Lua logic for handling the parameter.

```
touch default.conf
```

Edit `default.conf` with your editor of choice.

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

The magic happens in the `access_by_lua_block` which should be self-explanatory. See the [docs](https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/) for more details and much more features.

### Dockerfile

Now it is time to create our Dockerfile:

```
touch Dockerfile
```

Edit `Dockerfile` with your editor of choice.

```Dockerfile
FROM openresty/openresty
COPY default.conf /etc/nginx/conf.d/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Pretty simple, we copy our `default.conf` in to the image which is based on OpenResty.

### Running

Build the Docker image with `docker build . -t nginx-logic` and run it with `docker run -it --rm --name nginx-logic -p 3000:80 nginx-logic`

Now let's query our service (in my screenshots, I use [httpie](https://httpie.io/) as curl alternative).

```
curl -I -L localhost:3000/?id=9
```

{{< figure src=bing.png caption="Our request is forwarded to Bing" >}}

```
curl -I -L localhost:3000/?id=11
```

{{< figure src=google.png caption="Our request is forwarded to Google" >}}

```
curl -I -L localhost:3000
```

{{< figure src=default.png caption="The default page; this might be your frontend" >}}

## Conclusion

We implemented a simple use case, but you can imagine the flexibility this technique gives you. In general, I would prefer to implement business components in applications. However, in certain scenarios, it can be much cheaper to include such logic on the "infrastructure layer" instead of redesigning the application (architecture).
