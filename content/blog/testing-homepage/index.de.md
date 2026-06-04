---
title: Diese Webseite testen (Hurl+Hugo+Docker)
summary: Kürzlich stieß ich auf Hurl, ein Tool, das meiner Meinung nach sehr interessant ist. Um damit zu spielen, erstellte ich eine Art Integrationstest für diese Homepage, der Hugo, Docker, GitHub Actions und Hurl nutzt.
description: webentwicklung, testing, integration, hurl
date: 2022-12-10
tags:
  - tools
  - web
  - devops
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/testing-homepage/)
{{< /alert >}}

# Überblick über Hurl

[Hurl](https://hurl.dev/) beschreibt sich selbst als

> Hurl is a command line tool that runs HTTP requests defined in a simple plain text format.

Wer mich besser kennt, weiß, dass der Begriff `simple plain text format` mich anspricht 😀

Schauen wir uns eine minimale Hurl-Datei an:

```
GET https://rootknecht.net/
```

Die Datei mit `hurl --test minimal.hurl` ausführen.

Die Ausgabe ist folgende:

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

BESTANDEN 😃

Im folgenden Abschnitt beschreibe ich, wie ich Hurl verwende, um bestimmte Tests gegen die Webseite, die Sie gerade lesen, durchzuführen.

{{< alert >}}
Ich kratze kaum an der Oberfläche dessen, was Hurl kann. Für einen tieferen Einblick das ausgezeichnete [Tutorial](https://hurl.dev/docs/tutorial/your-first-hurl-file.html) von Hurl empfohlen!
{{< /alert >}}

# Tests für meine Webseite

Meine Webseite ist eine statische Website, die mit [Hugo](https://gohugo.io/) gebaut wurde. Es gibt keine Datenbank und keinen Server, außer einem einfachen Webserver. Mit Hurl ist es auch möglich, bestimmte Elemente der Seite zu testen.

{{< alert >}}
Die Test-Datei läuft gegen localhost, weil sie in meinem CI/CD integriert ist. Mehr dazu in [Automatisierung mit GitHub Actions](#automation-with-github-actions).
{{< /alert >}}

Der Quellcode meiner Test-Datei ist [hier](https://raw.githubusercontent.com/Allaman/rootknecht.net/main/test/test.hurl).

## Hauptelemente prüfen

```
GET http://localhost:1313
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/h1)" == "Knowledge is Power"
xpath "string(/html/body/div/footer/div/div[1]/span[1])" contains "Michael Peter 2022©"
```

Dieser Test stellt sicher, dass es meinen `h1`-Header auf der Startseite gibt und dass ich nicht vergesse, das Jahr zu aktualisieren 😉

## Bestimmte Seiten prüfen

```
# Fehlerbehandlung prüfen
GET http://localhost:1313/foobar
HTTP/1.1 404
[Asserts]
xpath "string(/html/body/div/main/div/div[2]/div[1])" == "Lost?"

# Prüfen, ob Impressum verfügbar ist
GET http://localhost:1313/imprint/
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/p[3])" contains "Verantwortlich für den Inhalt"

# Prüfen, ob Datenschutz verfügbar ist
GET http://localhost:1313/privacy/
HTTP/1.1 200
[Asserts]
xpath "string(//*[@id=\"dsg-general-controller\"])" contains "Verantwortlicher"
```

Diese Tests stellen sicher, dass wichtige Seiten angezeigt werden.

## RSS prüfen

```
# RSS-Elemente prüfen
GET http://localhost:1313/blog/index.xml
HTTP/1.1 200
[Asserts]
xpath "string(//rss/channel/title)"       == "Blog on Rootknecht.net"
xpath "string(//rss/channel/description)" == "Recent content in Blog on Rootknecht.net"
```

Mein Blog bietet einen RSS-Feed an, den ich sehr mag, und natürlich sollte der Feed verfügbar sein.

## Artikelanzahl prüfen

```
# Artikelanzahl prüfen
GET http://localhost:1313/blog/
HTTP/1.1 200
[Asserts]
xpath "count(/html/body/div/main/div/article)" >= 22
```

Bestimmte Elemente können auch gezählt werden. In diesem Fall teste ich die Anzahl der Blogbeiträge auf meiner Webseite.

{{< alert >}}
Wie gesagt, ich kratze kaum an der Oberfläche des Möglichen. Aufgrund der Einfachheit meiner Homepage gibt es nicht viele super nützliche Testfälle. Das ändert sich bei komplexeren Seiten oder APIs (JSON wird ebenfalls unterstützt). Zum Beispiel, wenn Anfragen verkettet oder bestimmte Antworten erfasst werden müssen und mehr.
{{< /alert >}}

# Automatisierung mit GitHub Actions

Ich bin ein großer Fan der Automatisierung, also ist der nächste logische Schritt, den Test zu automatisieren. Außerdem muss ein Fehler im Test das Deployment der Seite verhindern.

Mein Deployment ist unkompliziert. In meiner [deploy.yml](https://raw.githubusercontent.com/Allaman/rootknecht.net/main/.github/workflows/deploy.yml) pushe ich den `public`-Ordner, der meine gebaute Homepage enthält, über SSH auf meinen Root-Server.

Der interessante Teil ist, wie man Hurl in GitHub Actions ausführt. Das [Tutorial](https://hurl.dev/docs/tutorial/ci-cd-integration.html) hat Sie auch hier abgedeckt!

Zunächst musste ich ein Docker-Image bauen, das meine Webseite innerhalb einer Pipeline bereitstellt. Mein [Dockerfile](https://github.com/Allaman/rootknecht.net/blob/main/Dockerfile) ist ein mehrstufiger Build. Die erste Stufe baut den public-Ordner, und die zweite Stufe verwendet den zuvor gebauten Ordner, um ihn über [Caddy](https://caddyserver.com/) bereitzustellen (ein Server, den ich wärmstens empfehlen kann!).

[test.sh](https://raw.githubusercontent.com/Allaman/rootknecht.net/main/test/test.sh) ist der Leim, übernommen aus Hurls Tutorial, das den Test steuert. Es baut das Docker-Image, startet den Container, prüft die Verfügbarkeit, führt Hurl-Tests durch und stoppt den Container am Ende.

[ci.yml](https://raw.githubusercontent.com/Allaman/rootknecht.net/main/.github/workflows/ci.yml) ist der Workflow, der `test.sh` über GitHub Action auslöst.

{{< alert >}}
Dieser Workflow nutzt `docker buildx`, weil das Dockerfile Multi-Plattform-Images verwendet. Mehr dazu in meinem Blogbeitrag über [Multi-Arch-Docker-Images bauen](/blog/multi-arch-docker/).
{{< /alert >}}

# Ausblick

Meiner Meinung nach ist Hurl ein nützliches Tool für bestimmte Automatisierungsaufgaben und Tests. Aufgrund seiner einfachen Installation als Single-Binary und seiner Plain-Text-Eingabedateien (GitOps!) sind die Möglichkeiten unendlich. Ich freue mich darauf, Hurl in die kontinuierliche Integration meiner Kunden einzubinden!
