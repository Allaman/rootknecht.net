---
title: Multi-Arch-Docker-Images bauen
summary: In diesem Beitrag möchte ich kurz beschreiben, wie Docker-Images für beide Plattformen gebaut werden, am Beispiel eines Docker-Images für Debugging-Zwecke, insbesondere innerhalb eines Kubernetes-Clusters.
description: kubernetes, docker, arm, amd64, macOS, apple silicon, multi-arch
type: posts
date: 2022-01-19
tags:
  - devops
  - tools
  - docker
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/multi-arch-docker/)
{{< /alert >}}

In meinem Blogbeitrag [Von Linux zu macOS wechseln](/blog/moving-to-macos) beschrieb ich meine Motivation für den Wechsel zu macOS. Eine Konsequenz dieses Wechsels ist, dass sich meine CPU-Architektur von [x86-64](https://en.wikipedia.org/wiki/X86-64) auf [ARM](https://en.wikipedia.org/wiki/ARM_architecture) geändert hat.

{{< alert >}}
Den Quellcode des Docker-Images findet man [hier](https://github.com/Allaman/problemsolver).
{{< /alert >}}

## Voraussetzungen

- Docker
- [buildx](https://docs.docker.com/buildx/working-with-buildx/) (in Docker Desktop für Windows und macOS enthalten)
- Optional: Github- und Dockerhub-Konto, wenn das Image automatisch gebaut und veröffentlicht werden soll

## Dockerfile

Natürlich muss das Docker-Image auf einem Basis-Image aufgebaut werden, das alle Zielplattformen unterstützt. Mit dem folgenden Ausschnitt verwendet Docker automatisch die richtige Architektur des Basis-Images.

```Dockerfile
ARG ARCH=
FROM ${ARCH}debian:stable-slim
```

Wie können Anwendungen für die jeweilige Architektur heruntergeladen werden? Es gibt eine [Liste](https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope) von Variablen, die beim Bauen von Images mit buildkit (der Ansatz in diesem Beitrag) automatisch gesetzt werden. Mit den relevanten Variablen kann die Plattform bestimmt werden. Diese Variablen müssen am Anfang des Dockerfiles vor der Verwendung in RUN-Abschnitten exponiert werden.

```Dockerfile
ARG TARGETOS # Betriebssystem, z. B. linux
ARG TARGETARCH # CPU-Architektur, z. B. amd64
ARG TARGETVARIANT # z. B. v8

RUN curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}
```

## Bauen

Das Bauen ist fast so einfach wie der übliche Build. Einfach die Zielplattform(en) zum Befehl hinzufügen. Weitere Details unter [Multi-Plattform-Images bauen](https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images).

{{< figure src=build.png caption="AMD64-Build auf meinem ARM M1 MacBook" >}}

```sh
docker buildx build --platform linux/amd64 -t test .
```

## Automatische Builds auf Github

Wenn das Image automatisch über Github Actions gebaut (und gepusht) werden soll, ist ein Workflow verfügbar. Dazu den [Workflow meines Repos](https://github.com/Allaman/problemsolver/blob/main/.github/workflows/ci.yml) einsehen.

{{< figure src=dockerhub.png caption="Image-Detailansicht mit allen verfügbaren Architekturen" >}}
