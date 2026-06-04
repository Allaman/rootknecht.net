---
title: "Eigenen Nachrichtendienst mit Huginn aufbauen"
description: "rss, self-hosted, wissensdatenbank"
summary: "Ich bin (noch immer) ein großer Fan von RSS-Feeds und habe eine ansehnliche Sammlung von Feeds in meinem self-hosted Tiny Tiny RSS aufgebaut. Allerdings bieten nicht alle interessanten Blogs einen RSS-Feed an. In diesem Beitrag zeige ich, wie ich via Huginn eigene RSS-Feeds aus diesen Blogs erzeuge."
date: 2022-01-02
tags:
  - diy
  - tools
  - self-hosted
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/build-news-service/)
{{< /alert >}}

## Huginn

### Was ist das

[Huginn](https://github.com/huginn/huginn) beschreibt sich selbst als

> Huginn is a system for building agents that perform automated tasks for you online.
> \
> Think of it as a hackable version of IFTTT or Zapier on your own server

Mit anderen Worten: Huginn stellt Agenten verschiedener Typen bereit, die unterschiedliche Aufgaben ausführen können. Sie können periodisch laufen oder ausgelöst werden. Die Ausgabe einer Aufgabe kann die Eingabe einer anderen sein, was die Erstellung komplexer Abläufe ermöglicht.

### Deployment

Ich betreibe Huginn via docker-compose auf meinem Root-Server. Huginn kann auf fast allem deployed werden: dem Home-Lab, einem Raspberry Pi usw. Andere Methoden sind in der [Dokumentation](https://github.com/huginn/huginn/wiki#deploying-huginn) beschrieben.

```yaml
version: '3'
services:
  huginn:
    image: huginn/huginn
    restart: always
    container_name: huginn
    ports:
      - 127.0.0.1:3001:3000
    volumes:
      - /home/michael/huginn/mysql-data:/var/lib/mysql
    environment:
      # Don't create the default "admin" user with password "password".
      DO_NOT_SEED: "true"
      ENABLE_INSECURE_AGENTS: "true"
      DELAYED_JOB_MAX_RUNTIME: 5
      DELAYED_JOB_MAX_RUNTIME: 100
      # General Configuration
      INVITATION_CODE: XXX
      TIMEZONE: Berlin
      # Email Configuration (only for mail instead of RSS needed)
      SMTP_DOMAIN: XXX
      EMAIL_FROM_ADDRESS: Huginn <XXX>
      SMTP_USER_NAME: "XXX"
      SMTP_PASSWORD: "XXX"
      SMTP_SERVER: "XXX"
      SMTP_PORT: "587"
```

## Den eigenen Nachrichtendienst aufbauen

Schauen wir uns nun an, wie ein eigener Nachrichten-Feed erstellt wird. Es werden neue Beiträge gesammelt und daraus ein RSS-Feed veröffentlicht. Das folgende Bild veranschaulicht mein Setup:

{{< figure src=agents.png caption="Übersicht aller meiner Agenten" >}}

{{< alert >}}
Für meinen Blog ist diese Technik nicht nötig. Es gibt einen [RSS-Feed](https://rootknecht.net/blog/index.xml) 😉
{{< /alert >}}

### Neue Beiträge sammeln

Um Daten von Webseiten zu sammeln, bietet Huginn den `Website Agent`:

> The Website Agent scrapes a website, XML document, or JSON feed and creates Events based on the results.

Im folgenden Beispiel möchten wir neue Blogbeiträge von https://appliedgo.com/blog abrufen. Die vollständige JSON-Konfiguration befindet sich am Ende dieses Kapitels.

Nach dem Erstellen eines neuen Agenten über das Agentenmenü gibt es links einige allgemeine Optionen und die Agenteneinstellungen. Rechts befindet sich die Dokumentation des Agenten mit allen Optionen.

{{< figure src=new-agent.png caption="Das Formular für den neuen Website-Agenten" >}}

Für unsere Zwecke geben wir nur einen Namen ein und legen den gewünschten Zeitplan des Agenten fest.

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
Seien Sie sparsam mit dem Agenten und erzeugen Sie keine unnötige Last! Bedenken Sie auch, dass Beiträge verpasst werden können, wenn die Häufigkeit neuer Beiträge höher ist als der eigene Zeitplan!
{{< /alert >}}

Der interessante Teil ist die Scrape-Konfiguration des Agenten nach den allgemeinen Einstellungen. Mit `toggle view` kann in die JSON-Ansicht gewechselt werden.

Jetzt möchten wir die Elemente `title` und `link` extrahieren, da das für unsere Zwecke ausreicht. Wir verwenden den XPath des entsprechenden Elements, um dem Agenten mitzuteilen, welche Daten extrahiert werden sollen. Der zu extrahierende Inhalt kann über `xpath` oder `css` (CSS-Selektor im Browser) angegeben werden.

Um den Pfad des Elements zu ermitteln, öffnet man die Entwicklertools im Browser, klickt auf den „Inspektor"-Button, fährt über das Element (die Überschrift) und klickt links. Dann kann der Pfad des markierten Code-Abschnitts kopiert werden.

{{< figure src=inspect.png caption="Inspektion der Überschrift des neuesten Docker-Blogbeitrags (Firefox)" >}}

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
Diese Methoden sind natürlich nicht so stabil wie eine reguläre API, und es ist gut möglich, dass Pfade sich brechen. Man kann den Wert `expected_update_period_in_days` auf eine Zahl setzen, innerhalb derer man einen neuen Beitrag erwartet. Wenn in diesem Zeitraum kein Beitrag erscheint, z. B. wegen geänderter Pfade, markiert Huginn den Agenten als „nicht funktionierend" (führt ihn aber weiter aus).
{{< /alert >}}

Um den Wert der Überschrift zu erhalten, wird `./node()` verwendet, für den Wert des Links `@href`.

Wenn ein Link nur relativ ist, kann er aus dem Feed heraus nicht angeklickt werden, also muss dem Blog-Pfad der Host vorangestellt werden. Der Abschnitt `template` „baut" die Ausgabe des Agenten.

Außerdem muss sichergestellt werden, dass `mode` auf `on_change` gesetzt ist. Mit dieser Einstellung beobachtet Huginn nur Änderungen der Nutzlast. So werden alte Beiträge, die von Huginn bereits verarbeitet wurden, ignoriert.

Das folgende JSON zeigt die Konfiguration für den Agenten:

```json
{
  "expected_update_period_in_days": "30",
  "url": "https://appliedgo.com/blog",
  "type": "html",
  "mode": "on_change",
  "extract": {
    "title": {
      "xpath": "/html/body/div[1]/div[3]/div/div/div[2]/div[1]/div/div/a[2]/h3",
      "value": "./node()"
    },
    "link": {
      "value": "@href",
      "xpath": "/html/body/div[1]/div[3]/div/div/div[2]/div[1]/div/div/a[2]"
    }
  },
  "template": {
    "url": "https://go.dev/{{ link }}",
    "title": "{{ title }}"
  }
}
```

Mit der Schaltfläche `Dry Run` kann der Agent getestet werden.

{{< figure src=dry-run.png caption="Probelauf des Applied Go Blog-Agenten, der Titel und Link des neuesten Beitrags zurückgibt" >}}

### Einen RSS-Feed erstellen

Es gibt einen Agenten, der Daten extrahieren kann, aber mit diesen Daten passiert noch nichts. Um sie zu verarbeiten, wird die Funktion genutzt, dass die Ausgabe eines Agenten die Eingabe eines anderen sein kann.

Ein neuer Agent vom Typ `Data Output Agent` wird erstellt. Dem Agenten wird ein Name gegeben und der Website-Agent unter `Sources` hinzugefügt. Außerdem muss der Secret-Key in den Optionen geändert werden. Dieser wird Teil der URL und sollte privat gehalten werden, wenn die Huginn-Instanz öffentlich ist.

{{< figure src=data-agent.png caption="Das Formular für den neuen Data Output Agent" >}}

Nach dem Speichern des Agenten ist die URL in der Zusammenfassung zu sehen. Mit einem RSS-Reader der Wahl kann diese URL abonniert werden.

{{< figure src=feed-url.png caption="RSS-Feed-URL für den eigenen RSS-Reader" >}}

### Alternative: E-Mail

Wer kein RSS mag, kann sich von Huginn per E-Mail benachrichtigen lassen.

{{< alert >}}
Stellen Sie sicher, dass die SMTP-Einstellungen in Huginn konfiguriert sind!
{{< /alert >}}

Ein neuer Agent vom Typ `Email Agent` wird erstellt. Dem Agenten wird ein Name gegeben, der Website-Agent als `Source` hinzugefügt und Betreff und Inhalt der E-Mail konfiguriert. Nach dem Speichern wartet der Agent auf Ereignisse vom Website-Agenten, um an die Standard-E-Mail-Adresse des Huginn-Kontos zu senden. Um eine bestimmte E-Mail-Adresse anzugeben, kann der Schlüssel `recipient` in den Optionen gesetzt werden.

## Fazit

In diesem Beitrag wurde ein eigener Nachrichtendienst aus Blogs erstellt, die keine RSS-Feeds oder nur Newsletter per E-Mail anbieten. Mit diesem Ansatz muss man keinen Newsletter abonnieren oder alle interessanten Blogs manuell prüfen.
Diese Lösung erfordert jedoch einige technische Kenntnisse und Aufwand, und es gibt möglicherweise einfachere Wege, dies zu erreichen. Nichtsdestotrotz schätze ich den Vorteil, die volle Kontrolle über jeden Aspekt zu haben.

{{< alert >}}
Bedenken Sie auch, dass wir nur an der Oberfläche der Möglichkeiten von Huginn gekratzt haben!
{{< /alert >}}
