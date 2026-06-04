---
title: "Wie diese Seite aufgebaut ist (und warum)"
summary: In diesem Artikel erkläre ich, warum ich mich für Grav CMS, eine vielleicht weniger bekannte Lösung, für knowledge.rootknecht.net entschieden habe.
description: webentwicklung, grav, cms, my experience
date: 2019-09-15
tags:
  - web
  - self-hosted
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/webpage/)
{{< /alert >}}

{{< alert >}}
Ich bin von Grav zu Hugo gewechselt!
{{< /alert >}}

## Klassische CMS

Die Hauptakteure im Bereich der schweren CMS sind [Wordpress](https://wordpress.org/), [Joomla](https://www.joomla.com/), [Drupal](http://www.drupal.org/) und [Typo3](https://typo3.org/). Ich habe Wordpress ausprobiert und betreibe eine gehostete Joomla-Instanz. All diese sind für meinen Anwendungsfall einer relativ einfachen und kleinen Webseite überdimensioniert, angesichts der Komplexität im Betrieb und in der Nutzung. Das erinnert mich immer an meine frühen Anfänge in der Informatik, als ich für ein Hello World Visual Studio startete :-)

## Statische Site-Generatoren

Ich mag statische Site-Generatoren sehr gut. Sie sind einfach, hackbar und sicher. Hackbar von mir natürlich, und sicher, weil keine Datenbank und kein _irgendwas-dynamisches-Web-Server_ beteiligt ist, sondern nur einfaches HTML und etwas CSS und JavaScript. Leider sind sie in gewisser Weise begrenzt. Es gibt keine Web-GUI; alles muss in Dateien über einen Editor erledigt werden. Das ist irgendwie einschränkend, da ich meine Seite auch bearbeiten möchte, wenn ich nicht an meiner privaten Workstation bin.

Einige wichtige statische Site-Generatoren sind:

- [Hugo](https://gohugo.io/) → geschrieben in Go (sehr schnell), leistungsstarke Shortcodes
- [Jekyll](https://jekyllrb.com/) → geschrieben in Ruby, betreibt GitHub Pages
- [Nikola](https://getnikola.com/) → geschrieben in Python, funktioniert gut mit orgmode
- und viele mehr

## „Neue" CMS

Es gibt einige neue CMS-Systeme, die versuchen, die Lücke zwischen den vollwertigen klassischen CMS und den minimalistischen statischen Site-Generatoren zu füllen.

### Kommerzielle Systeme

Kommerzielle Systeme wie [Kirby](https://getkirby.com/) oder [statamic](https://statamic.com/) waren von Anfang an keine Option. Erstens möchte ich mich auf öffentliche, community-getriebene Tools konzentrieren, und zweitens weiß ich nicht, ob ich genug an meiner Homepage arbeiten werde, um das Geld zu rechtfertigen (obwohl beide erschwinglich sind) ;-)

### Datenbankbasiert

Ich mag keine Datenbanken :-D Außerdem bin ich ein großer Fan von Plain-Text-Dateien, da sie so einfach zu handhaben sind. Keine Sorgen um Backups, einfach den ganzen Ordner zippen, kein Ärger nach Datenbank-/Schema-Upgrades und keine SQL-Injections ;-)

### Flat-File-basiert

Im Gegensatz zu statischen Site-Generatoren, die ebenfalls flat-file-basiert sind, besteht der Hauptvorteil von flat-file-basierten CMS in der Kombination beider Welten – der klassischen CMS und der statischen Site-Generatoren.

Zunächst eine Zusammenfassung meiner Anforderungen:

1. Keine Datenbank
2. Nur Markdown – nicht viel Aufwand mit HTML, JavaScript, ...
3. Eine Web-Benutzeroberfläche

Ich schaute mir vier Systeme an:

1. [OctoberCMS](https://octobercms.com/) → Sieht recht vielversprechend aus für jemanden, der keine Angst vor dem fast leeren Blatt hat, aber für mich ist es zu viel HTML- und JavaScript-Aufwand.
2. [Bludit](https://www.bludit.com/) → Schöne Web-UI, aber speichert Daten leider als JSON, was nicht direkt bearbeitet werden soll.
3. [Pico](http://picocms.org/) → Bietet keine Web-UI.
4. [Grav](https://getgrav.org/) → Hat alles, was ich brauchte (und mehr, das ich noch nicht wusste, dass ich brauche :-D)

## Grav-Performance verbessern

Ein Überblick über Techniken zur Verbesserung der Seitengeschwindigkeit von Grav zur Erhöhung des Rankings in verschiedenen Web-Performance-Rankings:

- Komprimierung aktivieren
- CSS, HTML und JavaScript minimieren
- Bilder optimieren
- Browser-Cache-Kontrolle
- Cache in Grav aktivieren (hier Redis)
- HTTP/2 aktivieren
