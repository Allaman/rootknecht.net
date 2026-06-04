---
title: Mein self-hosted Setup 2026
description: "Ein Überblick über mein self-hosted Setup im Jahr 2026, mit Diensten auf Unraid, einem Root-Server und einem Raspberry Pi – einschließlich Backups und Dateisynchronisation."
summary: "Ein Durchgang durch meine persönliche self-hosted Infrastruktur für 2026: Was ich auf Unraid zu Hause betreibe, was auf einem gemieteten Root-Server läuft, und wie ich Backups handhabe."
date: 2026-04-10
tags:
  - hardware
  - self-hosted
  - linux
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/self-hosted-2026/)
{{< /alert >}}

Ich interessiere mich immer dafür, was und wie Menschen Dinge self-hosten, und lese gerne von deren Setups. Daher habe ich beschlossen, mein Setup für Sie aufzuschreiben 🙂

Mein self-hosted Setup besteht aus einem [Unraid](https://unraid.net/)-Server zu Hause, einem Root-Server, der bei [netcup](https://www.netcup.com/en) gemietet ist, sowie einem Raspberry Pi.

> [!NOTE]
> Dieser Blogbeitrag behandelt nicht die Konfiguration und die Einrichtung von Diensten.

## Unraid

Ich betreibe seit Ende November 2021 einen Unraid-Server und bin sehr zufrieden damit, wie einfach und leistungsfähig Unraid ist. Ich habe auch einen [Blogbeitrag](/blog/building-my-nas) über meine Gründe für Unraid und meine Hardware-Überlegungen geschrieben.

Die meisten Dienste laufen als Docker-Container mit eigener Freigabe, aber ich verlasse mich auch auf einige wichtige Plugins.

### Calibre und Calibre-Web

Wer mit E-Books zu tun hat, sollte über [Calibre](https://calibre-ebook.com/) gestolpert sein, **DEM** E-Book-Verwaltungsprogramm. Es überrascht nicht, dass ich es zur Verwaltung meiner E-Books verwende, die ich in der Regel bei [Thalia.de](https://www.thalia.de/) (DRM-frei!) kaufe. [Calibre-Web](https://github.com/janeczku/calibre-web) ist ein leichtes Frontend für Calibre, das besser zum Durchsuchen meiner Sammlung auf verschiedenen Geräten geeignet ist.

### Prometheus und Grafana

[Prometheus](https://prometheus.io/docs/introduction/overview/) und [Grafana](https://grafana.com/) sind beides Tools für die Überwachung. Metriken werden vom Prometheus Node Exporter-Plugin exponiert und von Prometheus gesammelt.

### Heimdall

[Heimdall](https://heimdall.site/) ist ein anpassbares Anwendungs-Dashboard mit Links zu all meinen wichtigen Diensten und Lesezeichen.

### Jellyfin

[Jellyfin](https://jellyfin.org/) ist mein Media-Center für das Streaming von Musik, Filmen und Serien.

### Metabase

[Metabase](https://www.metabase.com/) ist wahrscheinlich overkill für meinen Anwendungsfall, aber hey, es funktioniert! Ich nutze es zur Visualisierung meiner Ausgaben. Weitere Details in meinem [Buchhaltungs-Beitrag](/blog/accounting).

### MySpeed

Mit [MySpeed](https://myspeed.dev/) messe ich jede Nacht meine Internet-Bandbreite (Upload, Download und Ping).

### Photoprism

[Photoprism](https://photoprism.app/) ist meine Bildbibliothek für meine RAW-Bilder, die mit meinen spiegellosen Kameras aufgenommen wurden.

### Syncthing

[Syncthing](https://syncthing.net/) ist seit Jahren (vielleicht einem Jahrzehnt?) das Rückgrat meiner Dateisynchronisation.

### Appdata Backup

[Appdata Backup](https://forums.unraid.net/topic/137710-plugin-appdatabackup/) ist ein Plugin, das regelmäßig Backups meines Appdata-Ordners (auf dem Cache) erstellt und das Backup im Array speichert.

### Tailscale

[Tailscale](https://forums.unraid.net/topic/136889-plugin-tailscale/) ist ein Plugin, um sich mit einem [Tailscale](https://tailscale.com/)-Netzwerk zu verbinden. Ich verwende es, um mich mit meiner [Headscale](#headscale)-Instanz auf meinem Root-Server zu verbinden.

> [!NOTE]
> Ich könnte wahrscheinlich (fast) alles auf meinem Heimserver hosten und über Tailscale verbinden. Dennoch ziehe ich es vor, Dienste parallel auf meinem Root-Server zu hosten, weil a) die Bandbreite meinem Heim-Internet überlegen ist und b) meine Familie auch Zugang zu einigen Diensten benötigt.

### Unassigned Devices

[Unassigned Devices](https://forums.unraid.net/topic/92462-unassigned-devices-managing-disk-drives-and-remote-shares-outside-of-the-unraid-array/) ist ein Plugin zur Verwaltung von Festplatten, die nicht Teil des Unraid-Arrays sind. Ich verwendete es, um ein USB-Laufwerk für Backups einzubinden. Siehe [Backups](#backups).

### User Scripts

[User Scripts](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/) ist ein Plugin zur zeitbasierten Ausführung beliebiger Skripte, vergleichbar mit Cronjobs. Dieses Plugin ist ein wichtiger Teil meiner [Backup](#backup)-Strategie.

## Root-Server

### Syncthing

Natürlich ist [Syncthing](https://syncthing.net/) auch auf meinem Root-Server installiert.

### Nextcloud

[Nextcloud](https://nextcloud.com/) ist eine leistungsfähige „Cloud-Alternative". Es kann viele SaaS-Dienste wie Dateispeicher, PIM, Chat, Notizen, Videokonferenzen und mehr ersetzen. Ich nutze es nur als Dateispeicher für den Zugriff unterwegs und zum Teilen mit meiner Familie. Ordner werden als externer Speicher „eingebunden", sodass ich Syncthing und das Dateisystem für die Synchronisation nutzen kann.

### Calibre-Web

[Calibre-Web](https://github.com/janeczku/calibre-web) zum Anzeigen meiner E-Book-Bibliothek unterwegs.

### Forgejo

[Forgejo](https://forgejo.org/) ist eine GitHub/GitLab-Alternative für meine privaten Repositories. Was mich beeindruckt, ist das einfache Deployment. Nur ein Binary, und das war's.

### Nginx

[Nginx](https://nginx.org/) als Reverse Proxy ist meine Tür zu meinen Diensten und übernimmt die SSL-Terminierung mit [Let's Encrypt](https://letsencrypt.org/)[^1]-Zertifikaten, die automatisch von [certbot](https://certbot.eff.org/) erneuert werden. Wenn ich von vorne anfangen würde, würde ich wahrscheinlich [Caddy](https://caddyserver.com/) anstelle von Nginx in Betracht ziehen.

### Supernote Private Cloud

[Supernote Private Cloud](https://support.supernote.com/setting-up-your-own-supernote-private-cloud-beta) ist die self-hosted Cloud für meine [Supernote](https://supernote.com/) E-Ink-Tablets. Mein [Beitrag](/blog/supernote-private-cloud) zeigt, wie der Dienst mit Docker eingerichtet wird.

Wer sich für E-Ink-Tablets interessiert, für den habe ich einen [Beitrag](/blog/eink-note-taking-onyx-boox-remarkable-supernote) geschrieben, der Remarkable 2, PP, PPM, Supernote Nomad, Manta und Onyx Boox Note Air 3 C vergleicht.

### Donetick

[Donetick](https://donetick.com/) ist mein bevorzugter Task-Manager. Ich mag seine Einfachheit bei gleichzeitig gutem Feature-Set und der nativen iOS-App.

### Karakeep

[Karakeep](https://github.com/karakeep-app/karakeep) ist mein Sammelbecken für alles. Wenn es einen interessanten Artikel, ein Tool, ein Bild oder eine Notiz gibt, das keinen Platz in meinem [Wissensmanagement-System](https://rootknecht.net/blog/why-i-tried-to-leave-obsidian-and-didnt/) hat, werfe ich es einfach in Karakeep. Es wird automatisch getaggt und eine Offline-Kopie gespeichert.

### FreshRSS

[FreshRSS](https://github.com/FreshRSS/FreshRSS) ist mein bevorzugter RSS-Aggregator (bin ich altmodisch?) und hat [TinyTinyRSS](https://tt-rss.org/) ersetzt, das ich jahrelang verwendet habe.

### Atuin

[Atuin](https://github.com/atuinsh/atuin) ist ein Tool zum Speichern und Synchronisieren des Shell-Verlaufs über Geräte hinweg via [self-hosted](https://docs.atuin.sh/cli/self-hosting/server-setup/) Sync-Server.

### Headscale

[Headscale](https://headscale.net/stable/) ist eine self-hosted Alternative zu [Tailscale](https://tailscale.com/). Und das Beste: Es funktioniert mit offiziellen Tailscale-Clients!

### Copyparty

[Copyparty](https://github.com/9001/copyparty) ist ein All-in-One-Fileserver, bei dem ich immer noch herausfinden muss, ob ich ihn brauche, wenn ich Nextcloud habe.

## Raspberry

Ein Raspberry Pi 4 Modell B betreibt [Pi-hole](https://pi-hole.net/) für netzwerkweites Anzeigen-Blockieren. Anfangs lief Pi-hole auf meinem Unraid, aber ich erkannte, dass das keine gute Idee für eine so wichtige Netzwerkkomponente war. Seitdem hatte ich keine Probleme, und es läuft absolut stabil auf meinem Pi.

## Backups

Alle meine Daten werden auf meinen Unraid-Server synchronisiert. Von dort aus gibt es mehrere Backup-Methoden:

1. Meine Daten werden jede Nacht um 03:00 Uhr via User Script mit [Restic](https://restic.net/) mit Snapshots und verschlüsselt zu [Backblaze](https://www.backblaze.com/cloud-storage) gesichert.
2. Medien werden wöchentlich via User Script mit [Rclone](https://rclone.org/) zu [pCloud](https://www.pcloud.com/) gesichert.
3. Monatlich stecke ich eine SSD an und führe ein manuelles Backup aller meiner Daten via User Script mit [Restic](https://restic.net/) mit Snapshots und verschlüsselt durch.

[^1]: Erinnern Sie sich noch an die Zeit vor Let's Encrypt? Ich schon, was für ein Kampf! Ich denke, die Auswirkungen von Let's Encrypt können nicht genug betont werden!
