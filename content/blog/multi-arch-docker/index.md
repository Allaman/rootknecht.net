---
title: Building multi arch Docker images
summary: In this post I want to briefly describe how to build Docker images for both platforms at the example of a Docker image for troubleshooting purposes especially within a Kubernetes cluster.
description: kubernetes, docker, arm, amd64, macOS, apple silicone, multi-arch
type: posts
date: 2022-01-19
tags:
  - devops
  - tools
  - docker
---

In my blog post [Moving from Linux to macOS](/blog/moving-to-macos), I described my motivation for moving to macOS. One consequence of this move is that my CPU architecture changed from [x86-64](https://en.wikipedia.org/wiki/X86-64) to [ARM](https://en.wikipedia.org/wiki/ARM_architecture).

{{< alert >}}
The source of the Docker image can be found [here](https://github.com/Allaman/problemsolver)
{{< /alert >}}

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

How to download applications for the specific architecture? There is a [list](https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope) of variables that are automatically set when building images with buildkit (the approach in this post). We can use the relevant variables to determine the platform. These variables must be exposed at the top of your Dockerfile before you can use them in RUN sections.

```Dockerfile
ARG TARGETOS # operating system, e.g. linux
ARG TARGETARCH # CPU architecture, e.g. amd64
ARG TARGETVARIANT # e.g. v8

RUN curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}
```

## Building

Building is almost as easy as your usual build. Just add your target platform(s) to the command. Refer to [build multi platform images](https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images) for more details.

{{< figure src=build.png caption="AMD64 build on my ARM M1 MacBook" >}}

```sh
docker buildx build --platform linux/amd64 -t test .
```

## Automatic builds on Github

If you want to automatically build (and push) your image via Github actions there is workflow available. Refer to my [repo's workflow](https://github.com/Allaman/problemsolver/blob/main/.github/workflows/ci.yml).

{{< figure src=dockerhub.png caption="Image detail view with all available architectures" >}}
