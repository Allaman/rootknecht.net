---
title: DevOps
description: "devops, definition, methodik"
summary: "Was ich unter DevOps und den verwandten Themen Cloud Computing und Infrastructure as Code verstehe"
date: 2019-10-06
showHero: false
tags:
  - devops
  - cloud
  - my experience
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/devops/)
{{< /alert >}}

## Begriffe und Definitionen

{{< alert >}}
Diese Seite beschreibt bestimmte Aspekte im Bereich DevOps. Sofern nicht anders angegeben, sind diese Aussagen meine eigene Formulierung, basierend auf meinem eigenen Denken und meiner Erfahrung, ohne Gewähr für Richtigkeit oder Übereinstimmung mit anderen Meinungen.
{{< /alert >}}

## DevOps

{{< alert >}}
Eine Unternehmens**kultur**, die darauf abzielt, hochwertige Software in kurzer Durchlaufzeit und mit hoher Effizienz unter Berücksichtigung aller Stakeholder zu liefern.
{{< /alert >}}

### Dev vs. Ops

| Was Dev will             | Was Ops will               |
| :----------------------- | :------------------------- |
| Schnell liefern          | Verfügbarkeit sicherstellen|
| Häufig liefern           | Vorsicht walten lassen     |
| Neue Features liefern    | Stabilität und Sicherheit  |

### Prinzipien

**CAMS**<small> von D. Edwards und J. Willis</small>

- **C**ulture (Kultur)
- **A**utomation (Automatisierung)
- **M**easurement (Messung)
- **S**haring (Teilen)

### Continuous Everything

**demnächst verfügbar**

## Cloud Computing

{{< alert >}}
Nutzung **dynamischer** IT-Ressourcen, die von einer Cloud-Service-Plattform über ein Netzwerk angeboten werden.
{{< /alert >}}

### Arten von Cloud-Computing-Diensten

Cloud Computing lässt sich in _Infrastructure as a Service_, _Platform as a Service_, _Software as a Service_ und _Function as a Service_ unterteilen. Das folgende Bild veranschaulicht die wesentlichen Unterschiede dieser Typen und vergleicht sie mit klassischen On-Premise-Rechenzentren.

{{< figure src=cc.png caption="Cloud Computing" >}}

Beispiele im Amazon-Ökosystem:

| Dienst   | Amazon-Produkt                                                                                                    |
| :------- | :---------------------------------------------------------------------------------------------------------------- |
| IaaS     | [Amazon Web Services Elastic Compute Cloud (AWS EC2)](https://aws.amazon.com/de/ec2/?nc2=h_m1)                    |
| PaaS     | [Amazon Web Services Elastic Compute Cloud Container Service (AWS ECS)](https://aws.amazon.com/de/ecs/?nc2=h_m1) |
| FaaS     | [Amazon Web Services Lambda (AWS Lambda)](https://aws.amazon.com/lambda/)                                         |
| SaaS[^1] | [Amazon Web Services SaaS](https://aws.amazon.com/de/partners/saas-on-aws/)                                       |

### Arten der Cloud-Computing-Bereitstellung

| Cloud         | Merkmal                                                                           |
| :------------ | :-------------------------------------------------------------------------------- |
| Public Cloud  | Über das öffentliche Internet erreichbar                                          |
| Private Cloud | Dedizierte Cloud für eine einzelne Organisation, intern oder extern verwaltet     |
| Hybrid Cloud  | Mischung aus Public Cloud und Private Cloud                                       |

### Vorteile des Cloud Computings

- Keine Notwendigkeit, in Rechenzentren zu investieren
- Nur so viel zahlen, wie man verbraucht
- Von reduzierten Kosten durch Skaleneffekte profitieren
- Komplexität der Kapazitätsplanung reduzieren
- Geschwindigkeit und Agilität steigern
- Mehr Fokus auf das Geschäft statt auf die Infrastruktur

## Infrastructure as Code

{{< alert >}}
Automatisiertes Management des Lebenszyklus aller Infrastrukturkomponenten in ihrer Gesamtheit durch die Nutzung von Methoden und Best Practices aus dem Bereich der Software-Engineering.
{{< /alert >}}

### Definition

Infrastructure as Code ist ein Ansatz zur Infrastrukturautomatisierung, der auf bereits in der klassischen Softwareentwicklung etablierten Praktiken basiert. Er betont konsistente, wiederholbare Routinen für die Bereitstellung und Änderung von Systemen sowie deren Konfiguration. Engineers nutzen und setzen Techniken durch, die in der Softwareentwicklung allgemein bekannt sind, wie Versionskontrollsysteme, automatisiertes Testen, Deployment-Orchestrierung, testgetriebene Entwicklung und kontinuierliche Integration/Auslieferung. Daher wird Infrastruktur behandelt, als wäre sie Software und Daten.

### Herausforderungen im Cloud-Zeitalter

1. Server Sprawl[^2]
2. Configuration Drift
3. Snowflake-Server
4. Fragile Infrastruktur
5. Automatisierungsangst
6. Erosion

### Prinzipien

1. **Systeme sollten reproduzierbar sein**

- Minimiert den Overhead und die Kosten für alle Beteiligten und hilft, die Teameffizienz zu steigern
- Minimiert die Automatisierungsangst und die Risiken durch Änderungen

2. **Systeme sollten wegwerfbar sein**

- Robuste, homogene und gut getestete Infrastruktur
- Von unzuverlässiger Software auf zuverlässiger Hardware hin zu zuverlässiger Software auf unzuverlässiger Hardware

3. **Systeme sollten konsistent sein**

- Configuration Drift verhindern
- Automatisierungsangst bekämpfen

4. **Prozesse sollten wiederholbar sein**

- Wegwerfbare Systeme sind leichter zu erreichen, da Systeme mehrfach einfach erstellt werden können.
- Kostenreduktion, da IT-Personal keine Zeit mit repetitiven Aufgaben verschwendet.

5. **Das Design sollte flexibel sein**

- Den Einfluss einer „Big-Bang"-Änderung reduzieren.
- Infrastruktur kann sich an Geschäftsanforderungen anpassen und ist ein Enabler, kein Hemmnis

### IaC und DevOps

Infrastructure as Code bietet DevOps-Teams folgende Vorteile:

1. Entwickeln und testen gegen produktionsähnliche Systeme
2. Mit wiederholbaren, zuverlässigen Prozessen deployen
3. Betriebsqualität überwachen und validieren
4. Qualität verbessern

[^1]: Bekanntere Beispiele für SaaS-Lösungen sind Gmail oder Office365
[^2]: Laut „Infrastructure as Code - Managing Servers in the Cloud" von Kief Morris – ein ausgezeichnetes Buch
