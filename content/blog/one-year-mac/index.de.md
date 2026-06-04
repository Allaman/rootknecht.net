---
title: Ein Jahr macOS (nach 10 Jahren Linux)
summary: In diesem Beitrag möchte ich meine Erfahrungen mit macOS beschreiben und insbesondere die Themen „Das Schlechte" und „Das Hässliche" aus dem Beitrag des letzten Jahres aufgreifen.
description: macos, linux, produktivität, konfiguration, my experience
date: 2022-11-26
tags:
  - configuration
  - hardware
  - produktivität
  - my experience
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/one-year-mac/)
{{< /alert >}}

In meinem Beitrag [Von Linux zu macOS wechseln](/blog/moving-to-macOS/) vom Dezember 2021 beschrieb ich meine Motivation und meinen Prozess des Wechsels von Linux zu macOS als meinen täglichen Treiber. Hier ist, wie es sich entwickelt hat :nerd_face:

{{< alert >}}
Kein Unternehmen sponsert mich oder bezahlt mich. Dies ist meine persönliche Meinung und Erfahrung; Ihre Ergebnisse können abweichen.
{{< /alert >}}

## Gesamterfahrung

Ich bin ziemlich zufrieden mit meinem Wechsel zu macOS und bereue ihn nicht. Was ich immer noch als überlegen gegenüber meinem früheren Lenovo X1 Carbon / Linux-Setup betrachte:

- Kein Lüftergeräusch (wenn er überhaupt läuft)
- Lange Akkulaufzeit
- Bessere Auswahl bestimmter Anwendungen, z. B. die [Affinity Suite](https://affinity.serif.com/en-gb/)
- Keine Kernel-/Firmware-/Treiber-Probleme
- Kein Ärger mit Audio-Geräten und dem Wechsel zwischen ihnen
- Vertrauensvolles (Ab-)Koppeln mit meinem Dell UltraSharp-Monitor
- Reibungsloses Schlafen und Aufwachen

Im nächsten Abschnitt greife ich die Beschwerden aus meinem vorherigen Beitrag und den aktuellen Stand auf.

## Das Schlechte

### Hardware

> Das MBP ist schwerer mit 1,6 kg gegenüber 1,1 kg des X1C und auch klobiger mit einigen scharfen Kanten.

Nun, das ist immer noch der Fall, aber 95 % der Zeit ist mein MBP angeschlossen, und ich arbeite mit externen Tastaturen und Mäusen.

> Es gibt keine mechanische Abdeckung der internen Webcam.

Auch keine Änderung. 90 % der Zeit ist der MBP-Deckel geschlossen, und ich arbeite mit meinem externen Monitor.

> Nur HDMI 2.0 (statt 2.1).

Seit dem Kauf des MBP habe ich seinen HDMI-Anschluss nie benutzt.

> Nur UHS-II-SD-Karten-Leser (statt UHS-III).

Es ist für meine Anwendungsfälle schnell genug.

> Fehlender USB-A-Anschluss.

Die meisten meiner Peripheriegeräte haben USB-C-Anschlüsse. Außerdem kann ich beim Andocken die USB-A-Ports meines Monitors verwenden.

> Fehlender Ethernet-Anschluss (wie bei den meisten Konkurrenten).

99 % der Zeit reicht meine (langsamere) WLAN-Verbindung aus. Wenn ich wirklich Ethernet wegen der Übertragungsgeschwindigkeit brauche, verwende ich meinen kleinen USB-C-Dock.

> Die interne Tastatur ist ein Fingerabdruck-Magnet.

Die meiste Zeit arbeite ich nicht mit der internen Tastatur.

> Die Notch teilt die Meinungen. Für mich stört die Notch überhaupt nicht.

Die Notch ist für mich immer noch kein Problem.

> Kein mittlere Maustaste wie mit den TrackPoint-Buttons des X1C zum Einfügen aus der Auswahl-Zwischenablage (mit MiddleClick einen Mittelklick mit Drei-Finger-Tippen emulieren).

[MiddleClick](https://middleclick.app/) funktioniert absolut einwandfrei.

> Scrollen mit meiner Logitech MX Vertical ist nicht flüssig und fast unbrauchbar. Außerdem funktionieren die Vor-/Zurück-Tasten nicht. Ich verwende LinearMouse, um beide Probleme zu lösen.

[LinearMouse](https://github.com/linearmouse/linearmouse) funktioniert reibungslos.

> Keine dedizierten BILD-AUF-, BILD-AB-, ENDE-, POS1-Tasten. Ich habe diese kaum verwendet, wegen meiner Vim-Bindings überall.

Die meiste Zeit arbeite ich mit einer externen (PC-Stil-)Tastatur und bevorzuge immer noch Vim-Bewegungen wo möglich.

### Software

> alacritty ist noch nicht als nativer ARM-Build verfügbar (kann selbst kompiliert werden).

Alacritty hat jetzt einen [ARM-Build](https://github.com/alacritty/alacritty/pull/4727).

> CMD-TAB zeigt Anwendungen aus allen Spaces, nicht nur dem aktiven (➡️ alt-tab).
> CMD-TAB trennt nicht zwischen verschiedenen Anwendungsfenstern (➡️ alt-tab).

[alt-tab](https://alt-tab-macos.netlify.app/) erfüllt seinen Zweck.

> CMD-q schließt Fenster, besonders gefährlich beim Versuchen, @ wie auf einer PC-Tastatur einzugeben. Ich verwende eine Karabiner-Modifikation, die Anwendungen nur schließt, wenn CMD-q zweimal gedrückt wird.

Ich betreibe weiterhin die Karabiner-Modifikation und bin absolut zufrieden.

> Alt-. muss konfiguriert werden oder kann durch ESC-. ersetzt werden.

Ich habe mich an `ESC-.` gewöhnt.

> Maximierte Fenster sind nicht wirklich maximiert, und die Ränder sind störend.

Das ist immer noch der Fall, aber ich bemerke es nicht mehr.

> Warum benennt RETURN in Finder einen Ordner um, anstatt ihn zu öffnen?

Ich habe Finder durch [Forklift 3](https://binarynights.com/) ersetzt.

## Das Hässliche

### Hardware

> Das Tastaturlayout. Ich bin seit meinem ersten PC an Standard-PC-Tastaturen gewöhnt. \
> Eckige Klammern: OPT-5: [, OPT-6: ] und OPT-8: {, OPT-9: } \
> Pipe: OPT-7: | \
> Tilde: OPT-n: ~? (kollidiert mit meinen tmux-Bindings) \
> At-Zeichen: OPT-l: @ (kollidiert mit meinen tmux-Bindings) \
> Mit intensiver Nutzung von Karabiner-Modifikationen habe ich alle Tasten neu zugewiesen.

Die meiste Zeit arbeite ich mit einer externen Tastatur. Ich habe viele Karabiner-Modifikationen, um eine QWERTZ-Tastatur zu simulieren, die ich gewohnt bin. Ich habe sogar Modifikationen für die interne Tastatur, sodass kein Unterschied zu einer externen Tastatur besteht. Zum Beispiel ist meine rechte Command-Taste so zugewiesen, dass sie wie eine `AltGr`-Taste funktioniert, sodass ich `@`, `|` und `~` wie gewohnt von einem QWERTZ-PC-Layout eingeben kann.

> Trotz des exzellenten Touchpads vermisse ich den TrackPoint und seine dedizierten Maustasten.

Wenn ich mit der internen Tastatur arbeite, ist das immer noch der Fall, trotz des exzellenten Touchpads. Aber auch hier arbeite ich die meiste Zeit mit externen Peripheriegeräten.

### Software

> Verzögerung beim Wechsel der Spaces. Ernsthaft, Apple?

[yabai](https://github.com/koekeishiya/yabai) ist ein alternativer Tiling Window Manager für macOS. Mit yabai gibt es keine Verzögerung beim Wechsel der Desktops mit eigenen Shortcuts, was der Hauptgrund für seine Verwendung ist. Yabai hat einen sogenannten `float`-Modus, der das Fensterlayout nicht verwaltet, was bedeutet, dass seine Tiling-Window-Features nicht genutzt werden müssen.

> LUKS-verschlüsselte externe Festplatten können von macOS nicht gelesen werden.

Ich verwende keine LUKS-verschlüsselten Festplatten mit meinem MBP.

> Calibre ist nicht als natives Paket verfügbar, und es gibt keine Alternative.

Inzwischen ist Calibre als nativer ARM-Build verfügbar.

> ueberzug hängt von x11 ab und ist nicht verfügbar.

Ich bin von alacritty zu Kitty gewechselt, das eingebaute Unterstützung für [icat](https://sw.kovidgoyal.net/kitty/kittens/icat/) hat. Dennoch ist mein Bedarf an Bildvorschau im Terminal gesunken.

> Fehlende primary selection im gesamten Betriebssystem.

Keine Änderung. Am Anfang war es ärgerlich, aber jetzt denke ich kaum noch darüber nach.

> Warum gibt es in Finder kein „Ausschneiden"?

Ich habe mich daran gewöhnt 😆

## Neue Gedanken

Unter macOS ist [Homebrew](https://brew.sh/) praktisch obligatorisch. Ich lernte, dass es auch [Homebrew für Linux](https://docs.brew.sh/Homebrew-on-Linux) gibt, was mir ermöglicht, meine Tools auf Linux genauso zu verwalten wie auf macOS[^1]. Außerdem profitieren Linux-Distributionen von einer größeren und aktuelleren Software-Auswahl. In Zukunft möchte ich [nix](https://github.com/NixOS/nix) als Alternative zu Homebrew ausprobieren, das auch auf Linux und macOS verfügbar ist.

Gängige Unix-Tools auf macOS sind die BSD-Varianten und verhalten sich daher leicht anders. Da ich meine Skripte und Befehle auf allen meinen Hosts einheitlich nutzen möchte, installierte ich die GNU-Versionen über Homebrew und fügte sie meinem PATH hinzu.

Ich bin von [RCM](https://github.com/thoughtbot/rcm) zur Verwaltung meiner [Dotfiles](https://github.com/Allaman/dotfiles) für viele Jahre zu [chezmoi](https://www.chezmoi.io/) und meinem neuen [dots](https://github.com/Allaman/dots)-Repo gewechselt. Die Hauptgründe für den Wechsel sind das Templating-Feature und die Einfachheit der Installation (chezmoi ist nur ein einziges plattformübergreifendes Binary). Das ermöglicht mir, meine Dotfiles auf verschiedenen Plattformen bequemer zu verwalten.

Derzeit aktualisiere ich nicht auf macOS 13 Ventura. Man hat mir einmal geraten, nicht auf x.0-Versionen von macOS upzugraden, und außerdem sehe ich keine großen Verbesserungen oder neuen Features, über die ich begeistert wäre.

[^1]: Casks sind unter Linux nicht verfügbar.
