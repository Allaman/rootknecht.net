---
title: Testing this webpage (Hurl+Hugo+Docker)
summary: Recently, I stumbled over Hurl which is an exciting tool in my opinion. To play around with it, I created a sort of integration test for this homepage utilizing Hugo, Docker, GitHub actions, and Hurl.
description: web development, testing, integration, hurl
date: 2022-12-10
tags:
  - tools
  - web
  - devops
---

# Overview of Hurl

[Hurl](https://hurl.dev/) describes itself as

> Hurl is a command line tool that runs HTTP requests defined in a simple plain text format.

Those who know me better know that the term `simple plain text format` catches me 😀

Let's have a look at a minimal hurl file

```
GET https://rootknecht.net/
```

Run the file with `hurl --test minimal.hurl`.

The output is as follows:

```
❯ hurl --test minimal.hurl
minimal.hurl: Running [1/1]
minimal.hurl: Success (1 request(s) in 650 ms)
----------------------------------------------
Executed files:  1
Succeeded files: 1 (100.0%)
Failed files:    0 (0.0%)
Duration:        655 ms
```

PASSED 😃

In the following section, I describe how I use hurl to run certain tests against the webpage you are reading.

{{< alert >}}
I barely scratch the surface of what Hurl is capable of. Refer to their excellent [Tutorial](https://hurl.dev/docs/tutorial/your-first-hurl-file.html) to get a deeper insight!
{{< /alert >}}

# Tests for my webpage

My webpage is a static website built with [Hugo](https://gohugo.io/). There is no database and no server, expect a plain web server, involved. With Hurl, it is also possible to test certain elements of the page.

{{< alert >}}
The test file runs against localhost because it is integrated in my CICD. More on that in [Automation with GitHub actions](#automation-with-github-actions)
{{< /alert >}}

The source code of my test file is [here](https://raw.githubusercontent.com/Allaman/rootknecht.net/main/test/test.hurl)

## Check main elements

```
GET http://localhost:1313
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/h1)" == "Knowledge is Power"
xpath "string(/html/body/div/footer/div/div[1]/span[1])" contains "Michael Peter 2022©"
```

This test ensures that there is my `h1` header on the landing page and that I don't forget to update the year 😉

## Check certain pages

```
# Check error handling
GET http://localhost:1313/foobar
HTTP/1.1 404
[Asserts]
xpath "string(/html/body/div/main/div/div[2]/div[1])" == "Lost?"

# Check imprint is available
GET http://localhost:1313/imprint/
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/p[3])" contains "Verantwortlich für den Inhalt"

# Check privacy is available
GET http://localhost:1313/privacy/
HTTP/1.1 200
[Asserts]
xpath "string(//*[@id=\"dsg-general-controller\"])" contains "Verantwortlicher"
```

These tests just ensure that important pages are displayed

## Check RSS

```
# Check RSS elements
GET http://localhost:1313/blog/index.xml
HTTP/1.1 200
[Asserts]
xpath "string(//rss/channel/title)"       == "Blog on Rootknecht.net"
xpath "string(//rss/channel/description)" == "Recent content in Blog on Rootknecht.net"
```

My blog offers an RSS feed, which I am a big fan of, and of course the feed should be available.

## Check article count

```
# Checking article count
GET http://localhost:1313/blog/
HTTP/1.1 200
[Asserts]
xpath "count(/html/body/div/main/div/article)" >= 22
```

You can also count certain elements. In this case a test the number of blog posts on my webpage.

{{< alert >}}
As I said, I barely scratch the surface of what is possible. Due to the simplicity of my homepage, there are not many super useful test cases. This changes with more complex pages or APIs (JSON is also supported). For instance, when you have to chain requests or capture certain responses and more.
{{< /alert >}}

# Automation with GitHub actions

I am a big fan of automation, so the next logical step is to automate the test. Furthermore, an error in the test must prevent the page from being deployed.

My deployment is straight forward. In my [deploy.yml](https://raw.githubusercontent.com/Allaman/rootknecht.net/main/.github/workflows/deploy.yml) I push the `public` folder which consists my built homepage to my root server via ssh.

The interesting part is how to run hurl in GitHub actions. The [tutorial](https://hurl.dev/docs/tutorial/ci-cd-integration.html) also got you covered!

First things first, I had to build a Docker image that serves my webpage within a pipeline. My [Dockerfile](https://github.com/Allaman/rootknecht.net/blob/main/Dockerfile) is a multi-stage build. The first stage builds the public folder and the second stage uses the previously built folder to serve it via [Caddy](https://caddyserver.com/) (a server I can highly recommend!)

[test.sh](https://raw.githubusercontent.com/Allaman/rootknecht.net/main/test/test.sh) is the glue adopted from Hurl's tutorial that controls the test. It builds the Docker image, starts the container, checks the availability, runs Hurl tests, and stops the container at the end.

[ci.yml](https://raw.githubusercontent.com/Allaman/rootknecht.net/main/.github/workflows/ci.yml) is the workflow that triggers `test.sh` via GitHub action.

{{< alert >}}
This workflow utilizes `docker buildx` because the Dockerfile utilizes multi-platform-images. See my blog post on [Building multi arch Docker images](/blog/multi-arch-docker/)
{{< /alert >}}

# Outlook

In my opinion, Hurl is a useful tool for certain automation tasks and testing. Due to its straight forward installation via single-binary and its plain text input files (GitOps!), the possibilities are infinite. I am looking forward to incorporating Hurl in my customer's continuous integration!
