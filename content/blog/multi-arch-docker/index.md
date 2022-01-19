---
title: Building multi arch Docker images
type: posts
draft: false
date: 2022-01-19
tags:
  - docker
  - devops
  - tools
  - kubernetes
resources:
  - name: build
    src: build.png
    title: AMD64 build on my ARM M1 MacBook
  - name: dockerhub
    src: dockerhub.png
    title: Image detail view with all available architectures
---

In my blog post [Moving from Linux to macOS](/blog/moving-to-macos), I described my motivation for moving to macOS. One consequence of this move is that my CPU architecture changed from [x86-64](https://en.wikipedia.org/wiki/X86-64) to [ARM](https://en.wikipedia.org/wiki/ARM_architecture). In this post I want to briefly describe how to build Docker images for both platforms at the example of a Docker image for troubleshooting purposes especially within a Kubernetes cluster.

<!--more-->

{{< toc >}}

{{< hint info >}}
The source of the Docker image can be found [here](https://github.com/Allaman/problemsolver)
{{< /hint >}}

## Requirements

- Docker
- [buildx](https://docs.docker.com/buildx/working-with-buildx/) (included in Docker Desktop for Windows and macOS)
- Optional: Github and Dockerhub account if you want to automatically build and publish your image

## Dockerfile

Of course, you must build your Docker image upon a base image that supports all target platforms. With the following snippet Docker will automatically use the right architecture of the base image.

```Dockerfile
ARG ARCH=
FROM ${ARCH}debian:stable-slim
```

How to download applications for the specific architecture? The following snippet shows how to determine the architecture at build time and accordingly exports the right `ARCH`variable to use in the download URL.

```Dockerfile
RUN if [ x"$(uname -m)" = x"aarch64" ]; then export ARCH=arm64; fi && \
    if [ x"$(uname -m)" = x"x86_64" ]; then export ARCH=amd64; fi && \
    curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}
```

## Building

Building is almost as easy as your usual build. Just add your target platform(s) to the command. Refer to [build multi platform images](https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images) for more details.

{{< img name=build lazy=true size=small >}}

```sh
docker buildx build --platform linux/amd64 -t test .
```

## Automatic builds on Github

If you want to automatically build (and push) your image via Github actions there is workflow available. Refer to my [repo's workflow](https://github.com/Allaman/problemsolver/blob/main/.github/workflows/ci.yml).

{{< img name=dockerhub lazy=true >}}
