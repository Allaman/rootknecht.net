---
title: "Ich versuchte, Obsidian zu ersetzen — und schätzte es danach noch mehr"
summary: Ich testete AFFiNE, Anytype und Appflowy als self-hosted Alternativen zu Obsidian. Das Ergebnis überraschte mich — und veränderte meine Sichtweise auf Obsidian.
description: Vergleich von AFFiNE, Anytype und Appflowy als self-hosted Obsidian-Alternativen für persönliches Wissensmanagement (PKM).
date: 2026-01-24
tags:
  - produktivität
  - self-hosted
  - my experience
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/why-i-tried-to-leave-obsidian-and-didnt/)
{{< /alert >}}

## Überblick über mein System

Nur um etwas Kontext zu geben. Das verwende ich derzeit:

1. Notizen/Memos unterwegs oder wenn ich keine Zeit zum Tippen habe: [Plaud Note Pro](https://www.plaud.ai/) (keine sensiblen Notizen).
2. Kreative Arbeit, Ideen skizzieren, Meeting-Notizen, Einkaufsliste: [Supernote](https://supernote.eu/) (in Verbindung mit Supernotes [Private Cloud](https://rootknecht.net/blog/supernote-private-cloud/)).
3. Mein Aufgabenmanagement: [donetick](https://github.com/donetick/donetick) (self-hosted)
4. Mein langfristiges PKM: Derzeit [Obsidian](https://obsidian.md/) — worum es in diesem Beitrag geht.

Ich suche wirklich nur nach einem Ort für alles, meistens textbasiert, das ich behalten und merken möchte. Ich habe dedizierte Apps für Notizen, Skizzieren und Projekt-/Aufgabenmanagement.

## Warum überhaupt Obsidian verlassen?

- Die Trennung von Bearbeitungs- und Ansichtsmodus ist nervig.
- Obsidian kann alles sein, aber ich brauche nicht so viel Macht und Anpassbarkeit.
- (Größere) Markdown-Tabellen sind umständlich zu bearbeiten, besonders wenn man „reichhaltige" Inhalte (Links, Emojis, Bilder) schreiben möchte.
- Das ist nur mein Kopf, aber ich zögere immer, andere Dateien als Markdown zu meinem Vault hinzuzufügen, weil ich Angst vor Unordnung oder verschwendetem Speicherplatz habe 🤦‍♂️
- Die Oberfläche und die Optionen können überwältigend sein, was mich manchmal daran hindert, es zu nutzen.[^2]
- Ich finde [Notion](https://www.notion.com/) immer so schick und glänzend 🫣, aber Notion ist für mich keine Option[^3].

## Was suche ich?

- Selbst gehostet
- Eine gute mobile Erfahrung, zumindest zum Lesen. Mein Hauptanwendungsfall unterwegs ist meist nur das Lesen oder Suchen meiner Notizen.
- Gute Bild- und Dateihandhabung
- Einfach zu bedienen und intuitiv
- Läuft auf macOS, Linux, Android, iOS
- Angenehm anzusehen

Schön zu haben:

- Kollaborationsfunktionen
- Web-App

## Ansatz

Ich traf eine Auswahl von drei Tools[^1], die meiner Meinung nach einen Versuch wert sind, und führte einige praktische Tests durch.

- [AFFiNE](https://affine.pro/)
- [Anytype](https://anytype.io/)
- [Appflowy](https://appflowy.com/)

Mein Testansatz war, meine Meinung und Ergebnisse für jedes Tool innerhalb des Tools selbst zu schreiben. Obsidian wird verwendet, um den eigentlichen Blogbeitrag zu verfassen.

Dieser Ansatz ist keineswegs umfassend, und Ihre Erfahrungen können je nach Workflow variieren. Zum Beispiel gebe ich keinen Deut um KI- und Kalenderintegration.

## Überblick auf hoher Ebene

| Feature        | Obsidian 1.11.5                                                                    | AFFiNE 0.25.7 | anytype 0.53.1 | Appflowy 0.10.8 |
| -------------- | ---------------------------------------------------------------------------------- | ------------- | -------------- | --------------- |
| Selbst gehostet| Ich tue es nicht, aber es ist möglich                                              | Ja            | Ja             | Ja              |
| Mobil          | Gut ([1.11.](https://obsidian.md/changelog/2026-01-12-mobile-v1.11.4/))            | Gut           | OK             | Gut             |
| Emojis         | [Plugin](https://github.com/oliveryh/obsidian-emoji-toolbar)                       | Nein          | Nein           | Ja              |
| Tabellen       | OK                                                                                 | Gut           | Gut            | Gut             |
| Bildhandhabung | Schlecht                                                                           | Gut           | Gut            | Schlecht        |
| Spalten        | [Plugin](https://github.com/efemkay/obsidian-modular-css-layout)                   | Nein          | Ja             | Ja              |
| Kollaboration  | [Begrenzt](https://help.obsidian.md/sync/collaborate)                              | Ja            | Ja             | Ja              |
| Web-App        | [Extra-Aufwand](https://github.com/sytone/obsidian-remote)                         | Ja            | lokal-modus    | Ja              |

## AFFiNE

### Self-Hosting

- [Docker Compose](https://docs.affine.pro/self-host-affine/install/docker-compose-recommend) mit Nginx-Reverse-Proxy und TLS dauerte ca. 20 Minuten.
- Das Deployment besteht aus nur drei Containern, was Betrieb und Wartung erleichtern sollte.

### Hauptorganisationseinheiten

1. Workspace
2. Dokument
    1. Seitenmodus
    2. Edgeless Canvas (nicht mein Anwendungsfall, daher keine Meinung)
3. Journals (nicht mein Anwendungsfall, daher keine Meinung)

### Was mir gefällt

- Sehr saubere und intuitive Oberfläche
- Tabs
- Split-Ansicht
- Link-Handhabung (Karten und inline)
- Bildhandhabung
- Kollaborationsfunktion könnte gut für Familien und Teams sein, aber nicht mein Anwendungsfall
- Rechte Sidebar (Toggle-Bar) ähnlich wie Obsidian (ToC, Properties und mehr)
- Property-Handling ähnlich wie Obsidian
- Export (PNG, MD, HTML, Snapshot)

### Was mir nicht gefällt

- Tastaturkürzel sind nicht konfigurierbar
- Kein Cover
- Keine Suchen-und-Ersetzen-Funktion
- Keine Emojis
- Selbst gehostete Version ist nicht unbegrenzt

## Anytype

### Self-Hosting

- Self-Hosting hat nicht funktioniert
  - [any-sync-dockercompose](https://github.com/anyproto/any-sync-dockercompose)
  - Zeitlich begrenzt auf ca. 45 Minuten
  - Hochkomplex (Compose besteht aus 14 Diensten und Dutzenden von Umgebungsvariablen)
  - Eines ist das Deployment, ein anderes die Wartung und Upgrades
- „Nur-lokal-Modus" funktioniert auf meinem macOS 15.7 und iOS 26.1

### Hauptorganisationseinheiten

1. Channels
2. Objects
    1. Pages
    2. Notes
    3. Bookmarks
    4. Projects
    5. Images
    6. und mehr
    7. Custom Objects

### Was mir gefällt

- Objects scheinen sehr leistungsfähig zu sein
- Obsidian-Import möglich, aber erfordert einige Bereinigung
- Andere Seiten (Objects) über `/` und Autovervollständigung referenzieren
- Dedizierte Notes-, Bookmarks-, Images- und weitere Objects
- Tastaturkürzel sind konfigurierbar
- Bildausrichtung und -handhabung
- Die (rechte) Sidebar ist nicht so ausgereift und zeigt nur das Inhaltsverzeichnis
- Unterstützt Mermaid, LaTeX, Drawio und Excalidraw
- Mehrere Objects (z. B. Aufzählungspunkte) markieren und verschieben ist sehr intuitiv
- Spalten (intuitiv, wenn man [weiß wie](https://www.reddit.com/r/Anytype/comments/192omvq/how_to_create_columns_like_in_the_anytype_demo/) 😅)

### Was mir nicht gefällt

- Web-Link-Handhabung ist umständlich, wenn man jahrelang `[foo](www.bar.com)` geschrieben hat
- Ein- und Ausklappen nicht per Maus möglich und per Shortcut nicht funktionierend
- Keine Suchen-und-Ersetzen-Funktion
- Keine Emojis
- Code-Block ist nicht konfigurierbar (Zeilennummern, Beschriftung) und nicht faltbar
- Keine Tabs und keine Split-Ansicht
- Dunkelmodus ist **sehr** dunkel
- Self-Hosting ist komplex

## Appflowy

### Self-Hosting

- Docker Compose mit Nginx als Reverse Proxy und TLS in ~1 Stunde
- Hohe Komplexität (10 Dienste in der Compose-Datei), aber weniger als Anytype. AFFiNE führt.

### Hauptorganisationseinheiten

1. Workspace(s)
2. Space(s)
3. Dokument, Raster, Board, Kalender

### Was mir gefällt

- Eingebauter Emoji-Picker
- Sehr einfache und saubere Oberfläche (meine Präferenz: AFFiNE -> Appflowy -> Anytype)
- Tabs
- Viele Schriften verfügbar
- Spalten
- Tabellen haben Kopfzeilen, Farben und Ausrichtung

### Was mir nicht gefällt

- Keine Suchen-und-Ersetzen-Funktion
- Keine Split-Ansicht
- KI-fokussiert
- Bildhandhabung. Ein eingefügtes Bild wird in voller Größe eingefügt, ohne Optionen zur Änderung.
- Faltbare Überschriften sind ein dedizierter Typ im Gegensatz zu normalen Überschriften
- Nur Überschriften 1-3
- Kein Foto von der Kamera auf dem Mobilgerät hinzufügen
- Kein Export zu PDF usw.
- Trennungsprobleme

## Fazit oder warum Obsidian überlegen ist

Während meiner Tests und beim Schreiben dieses Blogbeitrags erkannte ich (erneut), wie vielseitig Obsidian ist und dass es nicht nur ums Schicke geht. Hier sind sieben Gründe, Obsidian zu behalten:

1. Es ist sehr beruhigend zu wissen, dass alle Daten **leicht als Textdateien zugänglich sind**. Außerdem gibt mir das die Möglichkeit, meine Dateien mit leistungsfähigen Kommandozeilen-Tools wie [yq](https://github.com/mikefarah/yq) (zum Parsen der Front Matter), [ripgrep](https://github.com/BurntSushi/ripgrep), [Neovim](https://neovim.io/) und mehr abzufragen oder zu bearbeiten. Ich muss mir keine Gedanken darüber machen, wie ich Daten aus einer Datenbank extrahiere, egal ob es sich nur um SQLite oder PostgreSQL handelt.
2. Backups sind einfach. Ich muss nur alle Dateien irgendwohin kopieren. Das war's. Keine Notwendigkeit, auf Konsistenz von Datenbank-Dumps zu achten und zu überprüfen, ob Backups tatsächlich funktionieren.
3. **Keine Wartung** für Obsidian. Obwohl das ein schlechter Vergleich ist, weil ich Obsidian als self-hosted Server betreiben sollte, um es vergleichen zu können, vertraue ich Obsidians E2E-Verschlüsselung genug, um ihren [Sync](https://obsidian.md/sync) zu verwenden.
4. Obsidian ist so **hackbar** und hat eine große Community (von Plugin-Entwicklern). Obsidian kann fast alles sein, was man möchte.
5. Keines der oben genannten Tools bietet eine **Suchen-und-Ersetzen-Funktion** oder eine globale Suche. Letztere ist besonders nützlich, um alle Notizen nach bestimmten Schlüsselwörtern zu durchsuchen.
6. Während alle drei getesteten Alternativen schick und Notion-ähnlich aussehen, schätzte ich die **rohe Effizienz von Markdown** wieder.
7. Die **Mobile-App ist leistungsfähig** und keine abgespeckte Version von Obsidian.

[^1]: Ich schwöre, ich habe recherchiert und *nicht* einfach die ersten drei alphabetisch ausgewählt 😅

[^2]: Wer ein [Boox](https://www.boox.com/)-Gerät besitzt, könnte dasselbe fühlen. Obwohl viel leistungsfähiger, mag ich [Remarkable](https://remarkable.com/)- und [Supernote](https://supernote.eu/)-Geräte mehr, weil sie nicht so überladen sind.

[^3]: Datenschutzbedenken, schlechte mobile App, „Enshittification" steht bevor (nur meine Meinung basierend auf nichts anderem als meinem Bauchgefühl).
