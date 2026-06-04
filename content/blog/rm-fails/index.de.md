---
title: Wie man Daten nicht versehentlich mit rm löscht
summary: In diesem Blogbeitrag möchte ich technische und „organisatorische" Strategien vorstellen, um zu verhindern, dass versehentlich das $HOME-Verzeichnis gelöscht wird (raten Sie mal, wer diese Auszeichnung erhalten hat 🙈).
description: linux, tutorial, best-practices, my experience, produktivität
date: 2023-10-30
tags:
  - produktivität
  - linux
  - shell
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/rm-fails/)
{{< /alert >}}

Wenn man mit der Shell unter Linux arbeitet, gibt es meiner Meinung nach ein Gesetz: Es wird einen Punkt geben, an dem man wichtige Daten versehentlich löscht, indem man `rm -rf` am falschen Ort oder mit den falschen Argumenten ausführt!

In meinen frühen Tagen mit Linux löschte ich einige Logs oder temporäre Dateien mit `rm -rf *`. Jetzt können Sie sich wahrscheinlich vorstellen, was als nächstes passierte … Als ich einige Dinge in meinem $HOME-Ordner löschen wollte, drückte ich versehentlich zu oft die Pfeil-hoch-Taste und – schwups – führte ich `rm -rf *` in meinem $HOME-Verzeichnis aus 🤯. Ich erkannte meinen Fehler sofort und drückte Strg-c, aber wie Sie wahrscheinlich wissen, ist der rm-Befehl wirklich schnell, und der Schaden war bereits angerichtet. Alle meine Dateien im $HOME-Verzeichnis waren weg. Der rm-Befehl ist tückisch, weil er Dateien sehr schnell und gründlich löscht. Man könnte versuchen, das betroffene Speichermedium sofort auszuschalten und Wiederherstellungstools zu verwenden, oder den Speicher zu einem professionellen Anbieter schicken.

Was habe ich seitdem geändert, um einen solchen Fehler zu verhindern? Hier ist meine Liste technischer und „organisatorischer" Strategien, die ich ergriffen habe.

## Backup Backup Backup

Dinge werden schiefgehen. Ein funktionierendes Backup-Konzept haben und sicherstellen, dass die Wiederherstellung auch funktioniert.

## Keine Autovervollständigung verwenden

Immer wenn ich `rm` verwende, tippe ich den/die Pfad(e) vollständig aus und verwende kaum Tab-Vervollständigung und nie Verlauf-hoch.

## rm nicht als Root-Benutzer ausführen, wenn es nicht nötig ist

Das gilt für die Arbeit in der Kommandozeile im Allgemeinen. Immer mit dem am wenigsten privilegierten Konto arbeiten, um die Arbeit zu erledigen. Im Falle eines Fehlers kann das verhindern, dass Dinge aufgrund unzureichender Berechtigungen gelöscht werden.

## -r und -f mit Bedacht verwenden

Nur wenn nötig verwenden!

## rmdir zum Entfernen leerer Verzeichnisse

Falls man es nicht wusste: `rmdir` ermöglicht das Entfernen leerer Verzeichnisse.

## Shell-Verlauf löschen

Immer wenn ich einen potenziell riskanten Befehl wie `rm -rf` ausführen muss, lösche ich sofort den Eintrag in meinem Shell-Verlauf. Das verhindert, dass ich diesen Befehl versehentlich ausführe, wenn ich bei meiner Verlaufssuche durcheinanderkomme.

## rm aliasieren

Das ist eine umstrittene Methode, aber sie hat für mich viele Jahre lang funktioniert. Ich habe einen Alias (`alias rm='trash'`), der rm an trash-cli bindet, ein CLI-Programm, das den zu löschenden Inhalt in den Papierkorb verschiebt, anstatt ihn dauerhaft zu löschen. Zum Beispiel verschiebt das Ausführen von `rm foo/` das Verzeichnis foo in den Papierkorb. Das Verzeichnis kann auch von trash-cli wiederhergestellt werden. Man beachte, dass `-r` nicht benötigt wird, um mit trash-cli einen Ordner zu löschen. Allerdings ist `rm` ein sehr „niederschwelliger" Befehl, und durch das Aliasieren könnte man etwas durcheinanderbringen. Anstatt zu aliasieren, könnte man trash direkt statt rm verwenden, aber mein Muskelgedächtnis ist einfach zu stark, und ich möchte Konsistenz auf Maschinen, auf denen trash-cli nicht verfügbar ist. Dieser Alias und Aliase im Allgemeinen können durch Aufrufen von `\rm` umgangen werden, was den Originalbefehl aufruft.

## Fokus

Immer wenn ich `rm -rf` ausführen muss, stelle ich sicher, dass es keine Ablenkungen gibt und dass ich es nicht überstürze.

Ich hoffe, dass Sie sich nie in der oben genannten Situation wiederfinden und dass der eine oder andere Tipp Ihnen hilft, eine Katastrophe zu vermeiden. Ich muss zugeben, dass ich mich tatsächlich in der Situation befand, mein $HOME-Verzeichnis versehentlich erneut zu löschen! Nach dem anfänglichen Schock konnte ich mit trash-cli alles genau wiederherstellen. Im absolut schlimmsten Fall hätte ich ein aktuelles Backup gehabt!
