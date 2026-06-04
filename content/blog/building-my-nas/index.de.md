---
title: Mein selbstgebautes NAS
description: "diy, nas, self-hosted, unraid"
summary: "Planen Sie, ein NAS (Network Attached Storage) anzuschaffen, weil Ihre Daten wachsen? Denken Sie über den Aufbau eines kleinen Home-Labs nach? Sind Sie etwas technisch versiert und nicht scheu vor DIY-Projekten und dem Installieren von Betriebssystemen? Dann ist dieser Beitrag für Sie :nerd_face: Sie lesen über meine Anforderungen und Anwendungsfälle sowie meine Hardware- und Softwareentscheidungen beim Bau meines ersten selbstgebauten NAS."
type: posts
draft: false
date: 2021-11-24
showHero: true
tags:
  - diy
  - hardware
  - self-hosted
  - linux
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/building-my-nas/)
{{< /alert >}}

Nach der Überarbeitung meines Backup-Konzepts und angesichts des erwarteten Datenwachstums kam ich zu dem Schluss, dass ich ein NAS benötige. Also beschloss ich, meinem alten Synology DS211j aus dem Jahr 2011(!) eine Chance zu geben (wieder). Es funktionierte tatsächlich noch, und ich war froh, Zeit und Geld zu sparen. Leider war das NAS aufgrund seiner schwachen Hardware extrem langsam. Das Update der DSM-Software selbst dauerte zwei Tage, und die Web-Oberfläche war träge. Auch die allgemeine Performance bei Dateioperationen war nicht begeisternd. Endlich ein Grund, Geld für neue Hardware auszugeben 🙈

Bevor ich einkaufen ging, setzte ich mich wieder ans Reißbrett und dachte über meine Bedürfnisse und Anwendungsfälle für einen geeigneten Ersatz nach.

## Anforderungen

Diese Anforderungen sind in keiner bestimmten Reihenfolge aufgelistet, da **alle** ein Muss sind!

1. Genügend Speicherplatz
2. Festplattenausfall führt nicht zu Datenverlust
3. Verwaltbar über eine Web-Oberfläche
4. [Syncthing](https://syncthing.net/) muss laufen (sehr empfehlenswertes Meisterwerk!)
5. Genug Performance für etwas Home-Lab-Betrieb
6. [Docker](https://www.docker.com/) muss verfügbar sein
7. Nur aus dem Heimnetzwerk erreichbar
8. Festplattenverschlüsselung
9. Caching

## Anwendungsfälle

- 75 % (gemeinsamer) Dateispeicher
- 15 % Home-Lab mit einigen Docker-Containern und VMs
- 10 % Automatisierungsaufgaben
- **Kein** Media-Streaming oder Gaming-Server

Die nächste Entscheidung war: **Selbst bauen** oder **kaufen**. Natürlich schaute ich mir zunächst das aktuelle Angebot von Synology und QNAP an. Einige Modelle sind vielversprechend, aber meiner Meinung nach fehlt es für meinen Home-Lab-Anwendungsfall an CPU-Leistung oder RAM. Außerdem möchte ich ein hackerfreundlicheres System und kein „proprietäres" Betriebssystem. Darüber hinaus ist der Eigenbau günstiger (zumindest dachte ich das 🤣).

Im nächsten Kapitel gebe ich einen Überblick über meine Einkaufsliste für das neue System.

## Hardware

{{< alert >}}
Ich bin kein Hardware-Experte, und mein letzter DIY-Build liegt in meiner Jugend 😆
{{< /alert >}}

Meine Hardware basiert auf [diesem Artikel](https://www.elefacts.de/test-120-nas_advanced_3.0b__6x_sata_mit_amd_athlon_3000g). Ich muss zugeben, dass ich bei der Hardware-Auswahl etwas überfordert war, daher war ich sehr froh, diesen Artikel gefunden zu haben.

- Gehäuse: [Fractal Design Define R6 Black Tempered Glass](https://www.amazon.de/gp/product/B078JKF674)
- Mainboard: [Asus Prime A320M-A Mainboard Sockel AM4](https://www.amazon.de/gp/product/B074BHVHL9) [^1]
- Netzteil: [be Quiet! Pure Power 11 400W cm](https://www.amazon.de/gp/product/B07JJFBNH2)
- CPU: [AMD Ryzen 5 Pro 2400g](https://www.amd.com/en/products/apu/amd-ryzen-5-pro-2400g)
- CPU-Lüfter: [Noctua NH-L9a-AM4 chromax.Black, Low-Profile](https://www.amazon.de/gp/product/B083LQVX5W)
- RAM: [Crucial CT2K16G4DFD8266 32GB Kit (16GB x2, DDR4, 2666 MT/s)](https://www.amazon.de/gp/product/B0736W5BH2)
- HDD: [WD Rot Pro 4TB 3.5" - 7200 RPM](https://www.amazon.de/gp/product/B07B1WK3N5)
- SSD: [Samsung SSD 870 EVO, 1 TB](https://www.amazon.de/dp/B08PC5DKZQ)

Alle Komponenten funktionieren, und der Zusammenbau selbst war nicht allzu schwierig. Das Gehäuse ist recht groß und bietet reichlich Platz für diese Komponenten sowie für dicke Finger 😉

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
Achtung: Dies ist kein ECC-RAM-Build!
{{< /alert >}}

{{< figure src=case.png caption="Fertiger Build – Lenovo X1 Carbon als Maßstab" >}}

{{< figure src=inside.png caption="Ein näherer Blick" >}}

## Software

Die nächste Entscheidung war, welches Betriebssystem verwendet werden soll. Von Anfang an war klar, dass eine einfache Linux-Distribution nicht ausreicht. Es wird ein spezielles Betriebssystem für diesen Zweck benötigt.

Im Bereich der NAS-Betriebssysteme ist [TrueNAS](https://www.truenas.com/) CORE, früher bekannt als FreeNAS, ein wichtiger Akteur. TrueNAS ist eine Speicherlösung auf Enterprise-Niveau, die auf [FreeBSD](https://www.freebsd.org/) und dem [ZFS](https://en.wikipedia.org/wiki/ZFS)-Dateisystem aufbaut.

Bei der Recherche zu TrueNAS stieß ich auf [Unraid](https://unraid.net/), das behauptet, eine Lösung für alle Datennutzer bei jeder Hardware-Kombination zu sein. Unraid basiert auf [Slackware Linux](http://www.slackware.com/) und [XFS](https://en.wikipedia.org/wiki/XFS) (obwohl ein Community-[ZFS-Plugin](https://forums.unraid.net/topic/41333-zfs-plugin-for-unraid/) verfügbar ist).

Natürlich gibt es andere Alternativen wie [openmediavault](https://www.openmediavault.org/), [EasyNAS](https://easynas.org/), [Rockstar](https://rockstor.com/), [Proxmox](https://www.proxmox.com/en/) und mehr. Einige davon sind auf bestimmte Zwecke spezialisiert, wie Media-Streaming, und andere wirkten auf mich nicht sehr ansprechend oder weit verbreitet.

Im folgenden Abschnitt möchte ich die wichtigsten Funktionen von Unraid und TrueNAS auflisten.

### Unraid

- Unraid basiert auf der Slackware-Linux-Distribution, mit der ich ziemlich vertraut bin, was mir mehr Sicherheit gibt.
- Unraid bietet eine große Flexibilität bezüglich der Hardware, insbesondere der Laufwerke. Festplatten beliebiger Größe können gemischt werden, und die Speicherkapazität lässt sich durch Hinzufügen eines einzelnen Laufwerks leicht erweitern. Die einzige Einschränkung: Das/die Paritätslaufwerk(e) muss/müssen gleich groß oder größer als die Speicherlaufwerke sein.
- Die Standard-Dateisysteme sind XFS für Speicherlaufwerke und [btrfs](https://en.wikipedia.org/wiki/Btrfs) für Cache-Laufwerke. Mit beiden habe ich Erfahrung und halte sie für einfacher handhabbar.
- Unraid erfordert eine [kostenpflichtige Lizenz](https://unraid.net/pricing) basierend auf der Anzahl der zu verwendenden Laufwerke. Es gibt eine 30-tägige Testphase mit allen Funktionen.

### TrueNAS

- TrueNAS basiert auf FreeBSD. Obwohl (Free)BSD ein Unix-basiertes System ist, fühle ich mich zum Zeitpunkt des Schreibens mit BSD-basierten Systemen nicht sehr wohl. Außerdem bezweifle ich, dass jede Software, die ich ausführen möchte, verfügbar ist. In Zukunft könnte sich das mit [TrueNAS SCALE](https://www.truenas.com/community/threads/truenas-scale-the-voyage-begins-with-version-20-10.88049/) ändern, aber vorerst möchte ich keine Beta-Software für mein NAS betreiben.
- ZFS ist das Dateisystem von TrueNAS, das ich als überlegenes Dateisystem betrachte, mit einem Nachteil: Ich bin nicht sehr vertraut damit, und eine Lösung ohne das Erlernen eines neuen komplexen Dateisystems wäre vorzuziehen.
- Als [RAID](https://en.wikipedia.org/wiki/RAID)-basiertes NAS muss man über die RAID-Konfiguration nachdenken und auch den Festplattentausch berücksichtigen. Ich würde ein System ohne die Komplexität eines RAIDs bevorzugen.
- TrueNAS CORE ist kostenlos und Open Source.

### Beide

- Bewältigen Festplattenausfälle
- Haben eine Web-Oberfläche
- Unterstützen Laufwerksverschlüsselung
- Große Verbreitung und Community
- Erweiterbar und konfigurierbar

Unter Berücksichtigung aller genannten Aspekte habe ich mich für die Installation von Unraid entschieden!

## Unraid-Konfiguration und Apps

### Installation

Unraid bootet **ausschließlich** von einem USB-Stick und läuft vollständig aus dem Speicher.

> Your USB drive must contain a unique GUID (Globally Unique Identifier) and be a minimum 1GB in size and a maximum 32GB in size.

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
Es empfiehlt sich, einen Stick einer bekannten Marke zu kaufen.
{{< /alert >}}

Seltsamerweise bietet Unraid den offiziellen [USB-Creator](https://github.com/limetech/usb-creator) nicht für Linux an.

So wird ein Unraid-Boot-USB-Stick unter Linux erstellt:

- Das [Release](https://unraid.net/download#stable-releases)-Archiv herunterladen.
- Das USB-Laufwerk z. B. mit [gparted](https://gparted.org/) formatieren:
  - GPT-Tabelle
  - Neue FAT32-Partition
  - Als bootfähig markieren
  - Partition mit **UNRAID** bezeichnen (wichtig!)
  - Den Archivinhalt auf den USB-Stick kopieren
  - `make_bootable_linux` ausführen, das sich auf dem Laufwerk (nicht dem USB-Stick) befindet. Das Skript sollte bestätigen, dass der Stick bereit ist.

Monitor oder Tastatur/Maus sollten nicht erforderlich sein. Wenn das BIOS so konfiguriert ist, dass es automatisch von USB bootet, startet Unraid im Standard-Non-GUI-Modus und ist unter seiner lokalen IP erreichbar. http://tower.local im Browser öffnen oder in den Router-Netzwerkeinstellungen nach der IP des Systems suchen.

### Laufwerk-Setup

Das Asus Prime A320M-A-Mainboard hat 6 SATA-Ports. Meine Entscheidung für das Laufwerk-Layout war wie folgt:

- Zwei [Paritäts](https://wiki.unraid.net/Parity)-Laufwerke, die zwei gleichzeitige Laufwerksausfälle abfangen.
- Zwei Laufwerke für den eigentlichen Speicher (das sogenannte **Array**), die durch die Paritätslaufwerke geschützt sind.
- Zwei SSD-Laufwerke für Caching. Da der Cache nicht durch die Parität geschützt ist, entschied ich mich für einen Pool aus zwei SSDs, sodass der Cache-Inhalt auf zwei Datenträgern gespeichert wird.

Dieses Layout bietet die erforderliche Ausfallsicherheit für zwei Festplatten gleichzeitig, einen schnellen SSD-Cache und für meine Zwecke genügend Platz mit dem 2×4-GB-Array.

{{< figure src=drives.png caption="Laufwerk-Layout in der Unraid-Web-Oberfläche" >}}

{{< alert >}}
Ich hätte größere Laufwerke für die Parität kaufen sollen, denn wenn ich die Kapazität erhöhen möchte, muss ich sowohl ein Laufwerk für die Parität als auch für den Speicher kaufen. Diese Einschränkung ergibt sich daraus, dass Paritätslaufwerke immer gleich groß oder größer als das größte Array-Laufwerk sein müssen, und ich kann kein weiteres 4-GB-Laufwerk hinzufügen, weil keine freien SATA-Ports mehr vorhanden sind.
{{< /alert >}}

### Freigaben

Meine Daten sind auf oberster Ebene in Ordnern für persönliche Daten, Geschäftsdaten, Quellcode, Medien usw. strukturiert. Für jeden Ordner habe ich eine Freigabe erstellt. Die meisten meiner Freigaben sind so konfiguriert, dass sie den Cache mit der Option `yes:cache` nutzen. Neue Dateien werden primär auf dem Cache (SSDs) erstellt, wenn genügend Platz vorhanden ist. Da der Cache nicht geschützt ist, verschiebt eine sogenannte Mover-Komponente Dateien vom Cache auf das Array. Mein Mover ist so eingestellt, dass er jede Nacht läuft. Nur kritische Daten werden direkt auf das Array geschrieben.

Meine Freigaben werden beim Zugriff automatisch von [systemd](https://wiki.archlinux.org/title/Samba#automount) eingebunden.

### Plugins und Apps

Dieser Abschnitt gibt einen Überblick über meine wichtigsten Plugins und Apps. Die Installation des [Community Apps Plugins](https://unraid.net/community/apps) wird dringend empfohlen.

#### Syncthing

Ich nutze [Syncthing](https://syncthing.net/) seit vielen Jahren als meine Synchronisationssoftware. Hatte nie ein Problem damit. Ordner werden zwischen meinem Laptop, dem NAS und meinem Root-Server synchronisiert. Syncthing ist als Docker-App (über Community Apps) verfügbar.

{{< figure src=syncthing.png caption="Syncthing-Statistiken" >}}

#### Restic

Syncthing ist **keine** Backup-Software! Für Backups verwende ich [restic](https://restic.net/). Restic erstellt clientseitig verschlüsselte Repositories bei verschiedenen Speicheranbietern (S3, SFTP, Wasabi, GCS, ...). Mein bevorzugter Anbieter ist [backblaze](https://www.backblaze.com/). Restic ist so konfiguriert, dass es mehrere Snapshots behält, sodass Daten aus einem bestimmten Zeitpunkt wiederhergestellt werden können. Die [Installation](https://blog.themainframe.co.uk/backup-unraid-part-two/) von Restic ist einfach, da es aus einem einzigen Binary besteht. Ich habe ein Skript geschrieben, das für jede Freigabe eine Backup-Operation ausführt.

Hier ist ein Ausschnitt meines Backup-Skripts. Die erste Zeile führt den Backup-Befehl für eine Freigabe in einen Bucket aus. Der zweite Befehl stellt sicher, dass nur 20 Snapshots aufbewahrt werden.

```sh
/usr/local/bin/restic -r $BUCKET:foo backup /mnt/user/foo
/usr/local/bin/restic -r $BUCKET:foo forget --keep-last 20 --prune
```

#### User Scripts

[User Scripts](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/) ist ein Plugin, das ein Frontend zur Verwaltung von periodisch laufenden Skripten bietet. Man kann es als Cron-Verwaltungs-UI bezeichnen. Das zuvor erwähnte Restic-Skript wird durch dieses Plugin ausgelöst. Es bietet auch einen Log-Viewer über den Webbrowser.

{{< figure src=user-scripts.png caption="User-Scripts-Web-UI mit Standardskripten" >}}

#### Krusader

[Krusader](https://krusader.org/) ist ein Dateimanager ähnlich wie [Midnight](http://midnight-commander.org/) und [Total Commander](https://www.ghisler.com/). Er ist als Docker-App (über Community Apps) verfügbar und wird genutzt, um Dateien direkt auf dem NAS zu durchsuchen.

{{< figure src=krusader.png caption="Krusader-Dateimanager" >}}

#### Prometheus/Grafana

Für die Systemüberwachung werden [Prometheus](https://prometheus.io/) und [Grafana](https://grafana.com/) eingesetzt. Beide Tools sind in der Branche weit verbreitet, von großen Unternehmen bis hin zu kleinen Startups oder Privatanwendern. Prometheus ist eine Zeitreihendatenbank, die Metriken speichert. Grafana wird verwendet, um diese Metriken über Dashboards zu visualisieren. [Node-exporter](https://forums.unraid.net/topic/110995-plugin-prometheus-unraid-plugins/) ist ein Plugin, das Prometheus mit den eigentlichen Metriken versorgt.

{{< figure src=grafana.png caption="Einige Metriken aus Prometheus, visualisiert in Grafana" >}}

## Fazit

Zur Hardware kann ich nicht viel sagen, außer dass sie funktioniert und mein Zeitaufwand für Recherche und Kauf akzeptabel war ☺. Unraid selbst ist wirklich großartig. Natürlich kann dies kein umfassender Vergleich sein, da ich nie wirklich in Berührung mit TrueNAS gekommen bin. Unraid bietet einfaches Speicher- und Anwendungsmanagement über eine komfortable und schnelle Web-Oberfläche. Die Dokumentation von Unraid ist ebenfalls gut gepflegt, und es gibt tolle Community-Ressourcen wie [Spaceinvader ONE](https://www.youtube.com/channel/UCZDfnUn74N0WeAPvMqTOrtA) und [The Geed Freaks](https://www.youtube.com/watch?v=8v74as9Meko&list=PLk4WsoMYr8AKWBhabC6VihHcBwLwNY3SN) auf YouTube.

[^1]: Das Mainboard verfügt über 6 SATA-Ports und eine NVMe-Verbindung. Die SATA-Ports 5 und 6 sind nicht verfügbar, wenn ein NVMe-Laufwerk angeschlossen ist!
