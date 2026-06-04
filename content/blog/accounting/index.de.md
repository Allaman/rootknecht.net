---
title: Mein Plain-Text-Buchhaltungsworkflow mit hledger
description: "plain text, buchhaltung, hledger, finanzen, cli, produktivität"
summary: "Wie ihr wahrscheinlich wisst, bin ich ein großer Fan des Plain-Text-Dateiformats. Wann immer es eine Lösung auf Basis von Plain-Text-Dateien gibt, werde ich sie (wahrscheinlich) nutzen. In diesem Beitrag erkläre ich, wie ich dieses Prinzip auf meinen persönlichen Buchhaltungsworkflow anwende."
draft: false
date: 2023-03-26
tags:
  - diy
  - tools
  - produktivität
  - shell
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/accounting/)
{{< /alert >}}

## hledger und doppelte Buchführung

[hledger](https://github.com/simonmichael/hledger) beschreibt sich selbst wie folgt:

> hledger is lightweight, cross platform, multi-currency, double-entry accounting software. It lets you track money, investments, cryptocurrencies, invoices, time, inventory and more, in a safe, future-proof plain text data format with full version control and privacy.

Was mir an hledger am meisten gefällt, ist, dass es mit Plain-Text-Dateien arbeitet, was mir erlaubt, viele Werkzeuge und Workflows zu nutzen, die ich bereits kenne:

- Ich kann meine Buchhaltungsdaten durchsuchen (grep).
- Ich kann meine Buchhaltungsdaten einfach sichern.
- Ich kann meine Buchhaltungsdaten mit Git unter Versionskontrolle stellen.
- Ich kann meine Buchhaltungsdaten mit [Syncthing](https://syncthing.net/) synchronisieren.

Eine Sache, an die ich mich gewöhnen musste, war die doppelte Buchführung. Dank hledger habe ich jetzt aber ein (sehr) grundlegendes Verständnis davon. Das Wichtigste — und wahrscheinlich Verwirrlichste — bei der doppelten Buchführung ist, dass man immer zwei Buchungen hat, sodass die Summe stets null ergibt. Lassen Sie mich das an einem einfachen Beispiel erklären. Sie kaufen Brot für 2 € und der Eintrag in Ihrer Journal-Datei würde wie folgt aussehen:

{{< alert >}}
Ich habe meine Standardwährung in meiner Journal-Datei mit `commodity €` auf € konfiguriert.
{{< /alert >}}

```
2023-03-26 Bread
    expenses:lebensmittel               2
    assets:cash                        -2
```

Man sieht, dass auf meinem Konto `expenses:lebensmittel` (Lebensmittel) ein positiver Betrag und auf meinem Konto `assets:cash` ein negativer Betrag gebucht wird. Mein Bargeldkonto wird also belastet, um 2 € auf das (virtuelle) Konto `expenses:lebensmittel` zu zahlen.

Wenn ich Geld erhalte, zum Beispiel mein Gehalt, ist es umgekehrt. Das (virtuelle) Konto meines Unternehmens wird mit dem Betrag meines Gehalts belastet, der auf mein Bank-Asset gebucht wird.

```
2023-03-26 Salary
    assets:bank                1000
    expenses:mijope           -1000
```

{{< alert >}}
Ich bin kein Buchhalter, und das kratzt nur an der Oberfläche der doppelten Buchführung und der Möglichkeiten von hledger. Es reicht jedoch für meine Bedürfnisse aus, meine Ausgaben und Einnahmen auf einfachste Weise zu erfassen.
{{< /alert >}}

## Einträge hinzufügen

Mein Workflow zum Hinzufügen von Einträgen besteht aus einem [Alfred](https://www.alfredapp.com/)-Workflow[^1], der mein Lieblingsterminal [kitty](https://sw.kovidgoyal.net/kitty/) startet und `hledger add` ausführt.

{{< figure src=add.png caption="Transaktionen hinzufügen" >}}

{{< alert >}}
In meinem Fall liest hledger die Umgebungsvariable `LEDGER_FILE`, um den Pfad zur Journal-Datei zu ermitteln. Alternativ kann hledger mit `-f pfad/zu/ihrer/ledgerdatei` aufgerufen werden.
{{< /alert >}}

hledger unterstützt beim Hinzufügen mit automatischer Vervollständigung von Konten und Vorschlägen basierend auf älteren Einträgen.

Nach jedem Jahr verweise ich meine `main.ledger`-Datei per Symlink auf eine neue `<year>.ledger`-Datei und beginne mit einem neuen Anfangssaldo.

```
.
├── 2016.db
├── 2016.ledger
├── 2017.db
├── 2017.ledger
├── 2018.db
├── 2018.ledger
├── 2019.db
├── 2019.ledger
├── 2020.db
├── 2020.ledger
├── 2021.db
├── 2021.ledger
├── 2022.db
├── 2022.ledger
├── 2023.ledger -> main.ledger
├── all.db
├── all.ledger
└── main.ledger
```

`all.ledger` „besteht" aus allen meinen Ledger-Dateien mit der `include`-Direktive: `include 20*.ledger`. Im nächsten Kapitel erkläre ich, was es mit den `db`-Dateien auf sich hat!

## Visualisieren und Analysieren[^2]

Mein Ziel ist es, folgende Fragen beantworten zu können:

- Wie entwickeln sich meine Ausgaben?
- Wofür gebe ich Geld aus?
- Gibt es Ausreißer oder Anomalien?

Solche Fragen lassen sich am besten mit Diagrammen und Dashboards beantworten! Was brauche ich, um Dashboards interaktiv und explorativ zu erstellen? Glücklicherweise gibt es Tools, die Business-Intelligence-Teams (auf weitaus ausgefeiltere Weise) dabei unterstützen, Antworten auf solche Fragen zu finden[^3].

Meine Wahl fiel auf die Open-Source-Version von [metabase](https://www.metabase.com/), das sich selbst so beschreibt:

> Fast analytics with the friendly UX and integrated tooling to let your company explore data on their own.

Eine (**nicht produktionsbereite**) Instanz lässt sich ganz einfach über einen einzigen Docker-Container starten, und die Benutzeroberfläche ist unter `http://localhost:3000` erreichbar:

```sh
docker run --rm -d -p 3000:3000 -v $(PWD):/app/data --name metabase metabase
```

`-v $(PWD):/app/data` hängt den aktuellen Ordner des Terminals in den Metabase-Container ein, sodass die Inhalte für die Anwendung verfügbar sind. Metabase kann sich mit verschiedenen [Quellen verbinden](https://www.metabase.com/docs/latest/databases/connecting), aber wir bleiben beim Einfachen und nutzen SQLite. Glücklicherweise bietet hledger einen Befehl, um die Transaktionen in SQL zu exportieren.

Folgender Befehl gibt das Journal als SQL aus und erstellt damit eine SQLite-Datenbank[^4]:

```
hledger print -O sql | sed 's/id serial/id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL/g' | sqlite3 ledger.db
```

Dieser Befehl erstellt eine Datenbank, die Metabase lesen und abfragen kann. Jetzt beginnt der Spaß![^5]

## Eindrücke

Ich stehe noch am Anfang des Aufbaus meiner Abfragen und Dashboards, aber bisher sieht es vielversprechend aus! Beachten Sie, dass diese Diagramme nicht statisch sind, sondern interaktiv angepasst werden können. Beträge sind unkenntlich gemacht. 😉

{{< figure src=lebensmittel.png caption="Lebensmittelausgaben pro Monat" >}}

{{< figure src=sprit.png caption="Benzinausgaben pro Monat" >}}

{{< figure src=dashboard.png caption="Beide Diagramme in der Dashboard-Ansicht" >}}

## Metabase nicht lokal betreiben

Ich betreibe ein [Unraid](blog/building-my-nas/) NAS / Home-Lab-System mit einem enthaltenen Docker-Host. Meine Daten, einschließlich meiner Ledger-Dateien, werden mit einer Freigabe auf diesem Server synchronisiert, und Metabase ist als Community-Anwendung mit wenigen Klicks installiert. Die einzige Anpassung, die ich vornehmen musste, war, dem Container mitzuteilen, dass er meinen Ledger-Ordner einbinden soll.

{{< figure src=unraid.png caption="Einbinden meines Ledger-Ordners in den Metabase-Container" >}}

Das Hinzufügen einer SQLite-Datenbank ist unkompliziert. Beachten Sie, dass der Pfad in der Anwendung mit dem „Container Path" in der Container-Konfiguration übereinstimmen muss.

{{< figure src=database.png caption="Datenbank zu Metabase hinzufügen" >}}

Jetzt kann ich meine Datenbanken in Metabase auf meinem Home-Lab hinzufügen und bearbeiten und von all meinen Geräten auf die Dashboards zugreifen. 🚀

Man könnte die Erstellung der SQLite-Dateien auch automatisieren, aber für jetzt mache ich das manuell, wann immer ich meine Daten analysieren möchte — meist am Ende eines Monats oder Jahres.

**Danke fürs Lesen!** 🤗

[^1]:
    Dies ist mein Alfred-Workflow-Skript, dem ich eine Tastenkombination zugewiesen habe.

    ```
    on alfred_script(q)
    tell application "kitty" to activate
    do shell script "/Applications/Kitty.app/Contents/MacOS/kitty @ --to unix:/tmp/mykitty new-window --new-tab --title='hledger add'"
    tell application "System Events" to keystroke "hledger add"
    tell application "System Events"
    key code 36 -- enter key
    end tell
    end alfred_script

    ```

[^2]: Ich wurde durch die Kommentare zu meiner Frage auf [reddit](https://www.reddit.com/r/plaintextaccounting/comments/121ka8m/how_do_you_visualize_drill_down_your_financial/) zum Thema „Wie visualisiert ihr eure Finanzdaten mit hledger" inspiriert.

[^3]: hledger verfügt über eine ziemlich leistungsstarke eingebaute [Berichtsfunktion](https://hledger.org/1.29/hledger.html#reporting). Es gibt verschiedene Befehle zum Abfragen und Filtern der Transaktionen, und ein Spickzettel wie [dieser](https://devhints.io/hledger) ist praktisch. Es gibt auch Optionen, Einträge in verschiedene Formate auszugeben, einschließlich CSV, und die Daten z. B. mit gnuplot zu plotten. Diese könnten für Sie ausreichen!

[^4]: Für eine Erklärung des `sed`-Teils verweise ich auf [diesen](https://github.com/simonmichael/hledger/issues/2017) GitHub-Issue.

[^5]: Weitere Informationen zur Arbeit mit Metabase finden Sie in der [Metabase-Dokumentation](https://www.metabase.com/docs/latest/)!
