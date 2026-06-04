---
title: Artikel lesen und speichern mit Obsidian und Remarkable2
description: "remarkable, pim, wissensdatenbank, obsidian, produktivität"
summary: Mein Workflow zum Lesen und Speichern von Artikeln aus dem Web mit dem reMarkable2 und Obsidian.
draft: false
date: 2022-08-02
tags:
  - produktivität
  - eink
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/article-workflow/)
{{< /alert >}}

Immer wenn ich im Web über einen interessanten Artikel stolpere, möchte ich diesen „archivieren", damit ich jederzeit darauf zugreifen kann – auch wenn der ursprüngliche Blog oder die Webseite offline geht. Jahrelang bezahlte ich für den [Pocket](https://getpocket.com/en/) Premium-Plan, der nicht nur URLs speichert, sondern die gesamte Seite, sodass der Inhalt immer zugänglich bleibt.

Nachdem ich Obsidian entdeckt hatte, war ich begeistert, wie es all meine Wünsche für Plain-Text abdeckt und die Daten dabei im eigenen Dateisystem verwaltet. Es war naheliegend, dass ich meine Artikel auch in Obsidian speichern wollte! Dazu später mehr.

Kurze Zeit später fand ich ein neues Tool, das meinen Workflow verbessern sollte: das [reMarkable 2](https://remarkable.com/) (RM2). Neu ist relativ – sagen wir einfach, ich habe der Versuchung lange widerstanden! Albern von mir ;) Das RM2 ist ein großartiges Stück Technologie, nicht für jeden geeignet, aber es hält, was es verspricht – und ich habe es genau dafür gekauft. Ein ablenkungsfreies, papierähnliches Erlebnis mit einem Hauch von Digitalisierung und einem hackbaren, Linux-basierten Betriebssystem. Das könnte aber ein eigener Blogbeitrag werden.

Einerseits ist es großartig, Daten als Textdateien zu speichern und mit Obsidian zu bearbeiten. Andererseits wäre es toll, (technische) Artikel auf einem etwa zehn Zoll großen E-Ink-Display mit der Mobilität des RM2 lesen zu können.

Dieser Blogbeitrag beschreibt meinen Workflow zum Herunterladen, Lesen und Speichern interessanter Artikel.

## Die Webseite abrufen

Am Anfang steht eine Webseite, die heruntergeladen werden soll. Traditionell würde man eine Seite als PDF „drucken" oder ein Screenshot-Tool bzw. ein Browser-Add-on verwenden, um ein Bild der Seite zu speichern. Offensichtlich passen beide Methoden nicht zu meinem Plain-Text-Workflow. Glücklicherweise gibt es [MarkDownload](https://addons.mozilla.org/en-US/firefox/addon/markdownload/), ein Firefox-Add-on, das die Webseite nimmt und in eine Markdown-Datei konvertiert bzw. speichert – das native Format von Obsidian! Erledigt.

## Den Artikel auf dem RM2 lesen

Jetzt wird es etwas knifflig. Markdown ist kein unterstütztes Format für das RM2. Wir brauchen eine PDF-Datei. Natürlich könnte man einwenden, einfach ein PDF aus dem Browser zu drucken! Aber erstens ist das zu einfach, und zweitens – und das ist viel wichtiger – interessiert mich nur der Text und die Bilder eines Artikels, nicht der ganze Kram drumherum. MarkDownload lädt kein schickes JavaScript oder Werbung herunter.

Darf ich vorstellen: [Pandoc](https://github.com/jgm/pandoc). Wer mit Text in irgendeiner Form arbeitet, muss dieses Tool kennen. Für mich ist es das Schweizer Taschenmesser für textbasierte Dateien. Mit Pandoc lässt sich eine Markdown-Datei wie folgt in ein PDF konvertieren:

```bash
pandoc my-article.md --pdf-engine=tectonic -o my-article.pdf
```

Dieser Befehl erstellt `my-article.pdf` aus `my-article.md`. Ich verwende [tectonic](https://github.com/tectonic-typesetting/tectonic) als PDF-Engine. Andere gängige Engines sind `pdflatex` und `xelatex`. Tutorials zur Installation von [LaTeX](https://www.latex-project.org/) auf dem eigenen System finden sich im Netz.

Wir kommen dem Ziel näher! Jetzt müssen wir das PDF auf das RM2 übertragen! Da das RM2 ein hackbares Gerät ist, nutzen wir gutes altes [SSH](https://en.wikipedia.org/wiki/Secure_Shell) und verzichten auf alle Cloud-Lösungen!

Zunächst sollte man sich mit dem [SSH-Zugriff auf das RM2](https://remarkablewiki.com/tech/ssh) vertraut machen. Die dort angegebenen Warnungen sollte man beachten! Wenn man sich mit dem RM2 verbinden kann, muss man den `Passwortlosen Login mit SSH-Schlüsseln` konfigurieren.

Wenn man sich ohne Passwort mit dem RM2 verbinden kann, ist der letzte Schritt vorbereitet! Da das RM2 Dateien in einem eigenen Format speichert, **kann** man das PDF nicht einfach per `scp` kopieren und fertig sein. Es gibt verschiedene Skripte, die die interne Dateistruktur des RM2 aus einem PDF erstellen und kopieren. Meine Wahl ist [pdf2remarkable.sh](https://github.com/adaerr/reMarkableScripts/blob/master/pdf2remarkable.sh) (die Kommentare in der Datei erklären die Funktion).

Ein PDF zu kopieren ist so einfach wie das Aufrufen des Skripts mit der Datei als Argument:

```bash
./pdf2remarkable.sh my-article.pdf
```

Das Skript erstellt die interne Darstellung des PDFs und kopiert sie per SSH via scp auf das RM2 (xochitl muss vom Skript über eine ENV-Variable oder manuell per `systemctl restart xochitl` neu gestartet werden).

{{< figure src=rm2.jpg caption="Dieser Artikel auf meinem RM2" >}}

[Hier](https://github.com/Allaman/dotfiles/blob/master/local/bin/article-to-rm.sh) findet sich mein vollständiges Skript, das alle Teile integriert.

Das Skript iteriert über meinen Inbox-Ordner, nimmt jede Markdown-Datei darin, schiebt eine erzeugte PDF-Datei auf das RM2 und verschiebt anschließend die Markdown-Dateien in meinen Reading-Ordner – als Hinweis, dass ich sie gerade auf dem RM2 lese. Die erzeugten PDFs werden am Ende gelöscht.

Nach dem Lesen der Artikel auf dem RM2 kann ich entscheiden, ob sie es wert sind, aufzubewahren, und wie ich sie taggen möchte. Danach verschiebe ich die Markdown-Datei aus meinem Reading-Ordner in mein Vault und genieße meine reine Plain-Text-Datenbank.
