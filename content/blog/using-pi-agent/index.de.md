---
title: Den Blast-Radius von pi.dev reduzieren
description: "Wie ich Pis Blast-Radius reduziere, indem ich es in isolierten Tart-VMs ausführe und Erweiterungen hinzufüge, die riskante Datei- und Git-Operationen blockieren."
summary: "Ein praktischer Blick darauf, wie man Pi sicherer nutzt: jedes Projekt in einer Tart-basierten virtuellen Maschine isolieren, nur die benötigten Verzeichnisse freigeben und Pi-Erweiterungen verwenden, um riskante Zugriffsmuster und destruktive Git-Befehle zu blockieren."
draft: false
date: 2026-06-13
tags:
  - tools
  - AI
  - workflow
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/using-pi-agent/)
{{< /alert >}}

Das [Pi](https://pi.dev/) _minimal agent harness_ hat als Open-Source-Alternative zu [Claude Code](https://claude.com/product/claude-code) und [Codex](https://openai.com/codex/) etwas Aufmerksamkeit bekommen, weil es das Rückgrat eines kleinen Projekts namens [OpenClaw](https://github.com/openclaw/openclaw) ist 😉. Pi kommt standardmäßig mit aktiviertem YOLO-Modus [^1]. Manche Leute, mich eingeschlossen, fühlen sich damit nicht wohl, daher beschreibe ich in diesem Beitrag, wie ich Pis Macht einschränke.

## YOLO Mode

Ich denke, eine gute Erklärung für YOLO (you only live once) ist der Vergleich von Pi mit Claude Codes [permission mode](https://code.claude.com/docs/en/permission-modes), der die Fähigkeiten des Harness einschränkt. Man kann alle Berechtigungen deaktivieren, indem man `--permission-mode bypassPermissions` übergibt. Dadurch kann der Agent im Grunde eigenständig arbeiten, ohne dass Interaktion nötig ist. Das ist der Standardmodus für Pi. Zusätzlich schließt Pi auch Pfade außerhalb des aktuellen Arbeitsverzeichnisses ein, was mir überhaupt nicht gefällt.

## VMs for the Win

In Pis Dokumentation gibt es eine eigene Seite zur [Containerization](https://pi.dev/docs/latest/containerization). Keine der dort beschriebenen Optionen entspricht meinen Vorlieben oder meinem Geschmack. Ich bin auf [tart](https://tart.run/) gestoßen, _ein Virtualisierungs-Toolset zum Erstellen, Ausführen und Verwalten von macOS- und Linux-VMs auf Apple Silicon._ Als [UTM](https://mac.getutm.app/)-Benutzer sah die CLI-getriebene Funktion von tart sehr verlockend aus, also habe ich es ausprobiert.

### Tart Intro

Tart funktioniert, indem es vorgefertigte OS-Images herunterlädt und ausführt, die out of the box funktionieren. Es ist nicht nötig, eine Installations-ISO herunterzuladen und das Betriebssystem wie bei UTM zu installieren.

```sh
tart clone ghcr.io/cirruslabs/ubuntu:latest ubuntu
tart run ubuntu

ssh admin@$(tart ip ubuntu)
```

Die Standard-Zugangsdaten sind admin/admin. Jetzt ist man mit einem normalen Ubuntu Linux verbunden. Nach dem Klonen startet eine VM in nur wenigen Sekunden. Wie cool ist das!

### Mein Tart-Workflow

Tart bietet die Möglichkeit, eine virtuelle Maschine mit `tart clone` zu klonen. Also hatte ich die Idee, diese Funktion zu nutzen, um zwei Fliegen mit einer Klappe zu schlagen:

1. Ein Basis-Image erstellen (ein ["golden image"](https://www.redhat.com/en/topics/linux/what-is-a-golden-image), wenn man so will)
2. Eine dedizierte virtuelle Maschine für jedes Projekt starten, in dem ich Pi nutze

#### Basis-Image

Ich bin ein Debian-Typ, daher bevorzuge ich Debian natürlich als Basis-Image gegenüber dem Rest. 😄

```sh
tart clone ghcr.io/cirruslabs/debian:latest debian-base
```

Jetzt habe ich mein Basis-Image heruntergeladen und muss es nur noch konfigurieren. Ich habe darüber nachgedacht, [Ansible](https://github.com/ansible/ansible) für die Konfiguration zu verwenden, aber das war angesichts der geringen benötigten Konfiguration Overkill, und es ist eine einmalige Sache, da mein Basis-Image beibehalten wird.

Systempakete aktualisieren und installieren

```sh
apt update && apt upgrade
```

Node 25 installieren

```sh
apt install extrepo
extrepo search node
extrepo enable node_25.x
apt update
apt install nodejs
```

Pi installieren

```sh
npm install -g @earendil-works/pi-coding-agent
```

Geteilte Ordner mounten

In `/etc/fstab` hinzufügen

```fstab
com.apple.virtio-fs.automount /mnt/shared virtiofs rw,relatime 0 0
```

Man fragt sich vielleicht, worum es bei der `fstab`-Änderung geht. Im Grunde starte ich eine virtuelle Maschine mit folgendem Befehl:

```sh
tart run --dir=pi:~/.pi/ --dir=project:"$PWD" --no-graphics foobar
```

Dieser Befehl mountet zwei Verzeichnisse: meine Pi-Konfiguration vom Host und das aktuelle Arbeitsverzeichnis.
Anstatt jedes Mal `mount` aufzurufen, wenn eine virtuelle Maschine startet, persistiert der `fstab`-Eintrag diese Konfiguration in meinem Basis-Image.

```sh
admin@debian:~$ ls /mnt/shared/
pi  project
```

Zum Schluss die Pi-Konfiguration symlinken

```sh
# Als admin-Benutzer, nicht als root
ln -s /mnt/shared/pi $HOME/.pi
```

Jetzt ist das Basis-Image einsatzbereit und ich kann virtuelle Maschinen starten.

#### Virtuelle Maschinen verwalten

Ich habe einen Wrapper (mit Hilfe von Pi) um `tart` geschrieben, um mehrere virtuelle Maschinen für mehrere Projekte auszuführen. Hier ist die Synopsis:

```sh
❯ vms
usage: vms <command> [args]
  start               start VM for current directory and SSH in (clones from debian-base if needed)
  stop [vm...]        stop running VMs (fzf if no args)
  ssh [vm...]         SSH into running VMs (fzf if no args)
  list                list all VMs
  clone <src> <name>  clone a VM
  delete [vm...]      delete VMs (fzf if no args)
  destroy [vm...]     stop and delete VMs (fzf if no args)
```

Der Quellcode befindet sich in meinem [dots](https://github.com/Allaman/dots/blob/d77a09f6136360edce550cbf89cb660a13f48d64/dot_local/bin/executable_vms)-Repository auf GitHub.

Mein üblicher Workflow ist also, dass ich immer dann, wenn ich einen Agenten brauche, ein neues tmux-Pane im Verzeichnis meines Projekts öffne und `vms start` ausführe. Das startet die virtuelle Maschine des Projekts oder klont eine neue virtuelle Maschine von meinem Basis-Image.

## Vor- und Nachteile

Pi nur in einer VM auszuführen hat einige Vor- und Nachteile.

### Vorteile

- Hohes Maß an Isolation
- Nur `.pi` und das aktuelle Arbeitsverzeichnis sind für Pi zugänglich
- `tart` reduziert den Overhead beim Ausführen virtueller Maschinen erheblich
- Änderungen von Pi werden sofort auf der Host-Maschine sichtbar, wo meine regulären Tools verfügbar sind
- Nicht alle Tools sind verfügbar, sodass Pi keine gefährlichen Befehle aufrufen kann, z. B. `terraform apply`

### Nachteile

- Eine zusätzliche Schicht mit zusätzlicher Komplexität
- Mehr Wartung, um das Basis-Image aktuell zu halten und virtuelle Maschinen von Zeit zu Zeit zu zerstören
- Man muss darüber nachdenken, welches Verzeichnis man mounten möchte
- Nicht alle Tools sind verfügbar, sodass Pi nicht so autonom agieren kann (fehlende Feedback-Schleife)

## Extensions

Pi hat ein [extension](https://pi.dev/docs/latest/extensions)-System, das Pi Erweiterungen für sich selbst schreiben lässt. Warum also Pi nicht zusätzlich dazu einschränken, dass es in einer isolierten Umgebung läuft? Dazu habe ich eine lustige Geschichte zu erzählen:

Ich sagte Pi, es solle eine Erweiterung schreiben, die das Lesen und Schreiben von `.*env*`-Dateien verbietet. Pi schrieb diese Erweiterung fröhlich für mich, und nach einem `reload` wurde sie erfolgreich geladen. Als ich dem Agenten sagte, er solle die nun verbotene Datei lesen, war ich überrascht. Eines von Pis vier Tools [^2] ist `read`. Die Erweiterung blockierte dies erfolgreich; jedoch benutzte Pi dann `python`, um ein Skript zu schreiben, das die verbotene Datei liest. 🤯 Dann sagte ich Pi, es solle die Erweiterung verbessern, um auch andere Tools wie Python oder Node vom Lesen abzuhalten.

Zusätzlich ließ ich Pi eine Erweiterung schreiben, die gefährliche Git-Operationen blockiert, die zu den wenigen Befehlen neben den eingebauten Befehlen gehören, die zu Datenverlust führen könnten.

## Fazit

Das ist mein Workflow zum Ausführen von Pi, bei dem ich mich wohlfühle, dass Pi keine dummen Dinge auf meiner Maschine macht. Behalte im Hinterkopf, dass dieser Ansatz ebenfalls keine 100%ige Sicherheit garantiert. Wenn du Pi weiter einschränken möchtest, wäre ein dedizierter physischer Host mit eingeschränktem Netzwerkzugang der nächste Schritt. Oder du könntest nach verschiedenen eingeschränkten "Geschmacksrichtungen" von Pi suchen.

[^1]: Der Autor von Pi begründet diese Entscheidung in seinem Blog-[Beitrag](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/#toc_13)

[^2]: `read`, `write`, `edit` und `bash`; siehe [First session](https://pi.dev/docs/latest/quickstart#first-session) für weitere Details.
