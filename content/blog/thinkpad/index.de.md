---
title: ThinkPad-Geschichten
summary: Einige Abenteuer mit ThinkPads
description: thinkpad, diy
date: 2020-02-06
tags:
  - diy
  - hardware
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/thinkpad/)
{{< /alert >}}

Ich ❤️ ThinkPads. Hier können einige meiner Geschichten damit gelesen werden 🙂

## Zwei x60 werden zu einem

Der x60 ist das letzte ThinkPad-Modell mit dem IBM-Branding, also musste ich einen haben. Leider gab es nur ein Modell mit einem Intel Core Duo Prozessor mit einer 32-Bit-Architektur. Das ist ein Nachteil, da die meisten modernen Linux-Distributionen die i386-Unterstützung eingestellt haben, was meine Idee, den x60 als täglichen Treiber alternativ zu meinem x230 zu betreiben, erschwert.

Glücklicherweise verkaufte mir ein Kollege ein x60-Tablet-Modell mit einem Intel Core **2** Duo Prozessor mit einer 64-Bit-Architektur. Mein Plan war, das Mainboard meines x60 durch das Mainboard der x60-Tablet-Edition zu ersetzen. Die Tablet-Version selbst war nicht attraktiv für mich.

- Seitenweise Gegenüberstellung. Links der x60, rechts das x60-Tablet! Man beachte die Form des Lüftergehäuses. Glücklicherweise ist das des x60-Tablets kleiner als das des x60. Das Gehäuse des x60 passt ohne weitere Modifikationen nicht in das Tablet-Gehäuse.

  {{< figure src=sidetoside.jpg caption="Seite an Seite" >}}

- Nahaufnahme des x60

  {{< figure src=x60.jpg caption="x60 (kein Tablet)" >}}

- Nahaufnahme des x60-Tablets

  {{< figure src=tablet.jpg caption="x60-Tablet" >}}

- Zerlegter x60

  {{< figure src=disassembled-x60.jpg caption="Der zerlegte x60" >}}

- Funktionierender x60 mit dem Mainboard des Tablets

  {{< figure src=workingx60.jpg caption="Der fertige x60" >}}

## Ein Mainboard backen

Dummerweise überlebte mein x100e das Kompilieren des Gentoo-Kernels nicht. Nach einem Absturz startete er nicht mehr, sondern ließ nur den Lüfter mit einem blinkenden Cursor drehen. Nach vielen Recherchen und Tests stellte sich heraus, dass einige Lötstellen des eingelöteten Grafikchips geschmolzen waren. Ich war ziemlich verzweifelt und versuchte etwas wirklich Verrücktes: _Das Mainboard in den Backofen legen!_

- Zerlegter x100e

  {{< figure src=disassembledx100.jpg caption="Der zerlegte x100" >}}

- Das Mainboard

  {{< figure src=motherboard.jpg caption="Das x100-Mainboard" >}}

- In Folie gewickelt und für 10 Minuten bei 180 Grad Celsius Umluft in den Backofen gelegt

  {{< figure src=oven.jpg caption="Das im Ofen backende Mainboard" >}}

_Nach dem Zusammensetzen funktionierte das Gerät wieder einwandfrei!_

## x230-Tastatur ersetzen

Leider war mein x230 das erste Modell mit der neuen Chiclet-Tastatur, die im Vergleich zu anderen Marken immer noch sehr gut ist, aber die klassische x220-Tastatur war meiner Meinung nach viel komfortabler. Glücklicherweise konnten ThinkPads dieser Ära leicht auseinandergenommen und Teile ausgetauscht werden.

Ich stieß auf ein nettes Tutorial zur [Installation einer klassischen Tastatur auf einem xx30-Series-ThinkPad](http://www.thinkwiki.org/wiki/Install_Classic_Keyboard_on_xx30_Series_ThinkPads).

Ich bestellte folgende Teile bei eBay:

- Lenovo **45N2153** Tastatur Deutsch für Thinkpad T410 T420 T510 T520 W510 W520 für 60 Euro
- Lenovo Thinkpad X220 X220i X220s Palmrest Plastic Cover **04W1410 H44** (mit Fingerabdruck-Ausschnitt) für 16 Euro

{{< alert >}}
Zu beachten ist, dass die klassische Tastatur keine Hintergrundbeleuchtung hat.
{{< /alert >}}

- Originale Tastatur

  {{< figure src=original.jpg caption="Die originale Tastatur" >}}

- Zerlegtes Gerät

  {{< figure src=disassembled.jpg caption="Das zerlegte Gerät" >}}

- Palmrest-Vergleich. Man beachte das unterschiedliche Layout, das wir korrigieren müssen.

  {{< figure src=palmrests.jpg caption="Palmrests nebeneinander" >}}

- Palmrest-Korrektur

  {{< figure src=fixed_palmrest.jpg caption="Der korrigierte Palmrest" >}}

- Originale Fingerabdruckplatte passt nicht

  {{< figure src=fingerprint-plate.jpg caption="Die Fingerabdruckplatte" >}}

- Geklebtes Fingerabdruckmodul

  {{< figure src=glued.jpg caption="Das geklebte Board" >}}

- Zurechtgeschnittene Platte

  {{< figure src=cut.jpg caption="Die zurechtgeschnittene Platte" >}}

- Endergebnis

  {{< figure src=final.jpg caption="Das Endergebnis" >}}

## Meinen Lenovo X1 Carbon mit einem Skin versehen

Ich bin ein großer Fan von [dbrand](https://dbrand.com). Sie bieten extrem gut aussehende und perfekt passende Skins für verschiedene Geräte an. Alle meine Galaxy-Geräte hatten sie, und ich dachte, es wäre an der Zeit, meinem X1 Carbon einen neuen Look zu verpassen. Hier ist das Ergebnis:

{{< figure src=front.jpg caption="Der vordere Skin" >}}

{{< figure src=bottom.jpg caption="Der untere Skin" >}}

{{< figure src=open.jpg caption="Der innere Skin" >}}
