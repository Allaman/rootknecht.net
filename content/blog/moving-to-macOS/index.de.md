---
title: Von Linux zu macOS wechseln
summary: In diesem Beitrag erkläre ich, warum ich nach über einem Jahrzehnt mit Lenovo-Laptops unter Linux zum „Erzfeind" macOS gewechselt bin.
description: arbeitsplatz, konfiguration, hardware, produktivität
draft: false
date: 2021-12-30
tags:
  - configuration
  - hardware
  - produktivität
  - my experience
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/moving-to-macOS/)
{{< /alert >}}

In meinem letzten [Arbeitsplatz](/blog/my-workplace-2021)-Setup-Blogbeitrag beschrieb ich mein Setup rund um meinen Lenovo X1 Carbon Gen 9 mit Manjaro Linux und warum ich Lenovo-Laptops allen anderen Herstellern vorziehe. Ich gebe zu, man könnte mich einen Lenovo-Fanboy nennen.

{{< alert >}}
Es gibt ein Update zu diesem Beitrag: [Ein Jahr mit macOS](/blog/one-year-mac)
{{< /alert >}}

{{< alert >}}
07.01.2024: Nach zwei Jahren hat Lenovo endlich ein Firmware-Update veröffentlicht, das das Lüfterverhalten behebt. Dank [u/ElRamenKnight auf Reddit](https://reddit.com/r/thinkpad/comments/18vjdb6/x1_carbon_gen9_latest_update_omg_they_finally/). Ich kann bestätigen, dass der Lüfter mit diesem Patch nicht mehr anläuft, wenn das System praktisch im Leerlauf ist. So hätte das Notebook schon beim Launch sein sollen!
{{< /alert >}}

{{< alert >}}
Keine Marke oder kein Unternehmen sponsert mich oder bezahlt mich. Dies ist meine persönliche Meinung und Erfahrung; Ihre Ergebnisse können abweichen.
{{< /alert >}}

## Warum

In diesem Kapitel beschreibe ich die Gründe für meinen Wechsel zu macOS und was ich mir von der Nutzung von macOS erwarte.

### Probleme mit meinem ThinkPad

Wie in meinem letzten [Arbeitsplatz](/blog/my-workplace-2021)-Beitrag beschrieben, gibt es drei Hauptgründe für mein früheres Setup:

- Linux[^1] ist meiner Ansicht nach das bessere Betriebssystem, weil es mir die Freiheit gibt, die Art und Weise, wie ich mit meinem Laptop interagiere, vollständig (neu) zu konfigurieren.
- Lenovos Linux-Unterstützung war immer hervorragend und ohne oder mit nur kleinen Problemen. Alle Hardware-Komponenten funktionieren in der Regel direkt nach dem Anschließen.
- Die Tastatur und der TrackPoint waren in meinen Augen immer überlegen. Mit dem TrackPoint war ich fast so schnell wie mit einer externen Maus.

Es gab von Anfang an einige Probleme mit meinem X1 Carbon (X1C) (schamloser Copy/Paste aus meinem vorherigen Beitrag):

1. Das Firmware-Update MUSS eingespielt werden. Frühere Firmware-Versionen sind von starkem Throttling betroffen, das das System nicht mehr reagieren lässt ([Lenovo Forum](https://forums.lenovo.com/topic/view/1301/5073083)).
2. Wenn an den Monitor über USB-C angeschlossen, führte ein Aufwachen nach dem Standby zu voller Last auf einem Kern, obwohl kein Prozess so viel CPU nutzte. Es stellte sich heraus, dass der `Linux S3`-Modus das Problem war. Nach dem Wechsel zu `Windows und Linux` (s0ix oder Connected Standby) in den BIOS-Einstellungen war dieses Problem behoben. Intel hat offenbar die [S3-Unterstützung](https://www.reddit.com/r/System76/comments/k7xrtz/ill_have_whatever_intel_was_smoking_when_they/) für Tiger-Lake-CPUs fallen lassen.

Nach der Lösung beider Probleme blieb noch ein [Summen](https://forums.lenovo.com/t5/ThinkPad-X-Series-Laptops/X1-Carbon-Gen-9-Buzzing-sound-upper-left-of-laptop/m-p/5082574?page=1) aus der oberen linken Ecke übrig. Obwohl mein X1C ebenfalls davon betroffen ist, war das kein Dealbreaker für mich. Es war kaum hörbar, und ich hoffte, dass es kein kritisches Problem darstellt, das die Hardware beschädigen könnte.

Leider tauchte ein neues Problem auf. Das Nervigste an meinem X1C war das unberechenbare und nicht nachvollziehbare Lüfterverhalten. Die Lüfter drehten oft auf, wenn überhaupt keine Systemlast vorhanden war oder nach dem Aufwachen aus dem Standby. Ich verbrachte Stunden und Stunden mit der Fehlersuche und fand keine Lösung. Für mich ist das ein großes Problem, weil ich erstens leicht von Lüftergeräuschen abgelenkt werde und zweitens das Vertrauen in die Hardware verliere. Das folgende Bild zeigt einen Screenshot von [s-tui](https://github.com/amanusk/s-tui). Man kann sehen, dass der Lüfter mit dem Maximum von ca. 6700 Umdrehungen pro Minute dreht (bläuliches Diagramm), während alle anderen Metriken kaum schwanken.

{{< figure src=fan.png caption="CPU-Frequenz, Auslastung, Temperatur und Lüfterdrehzahl" >}}

Obwohl ich Geld für eine erweiterte Garantie und einen Vor-Ort-Service ausgegeben habe, war ich nicht bereit, noch mehr meiner wertvollen Zeit in die Bewältigung von Problemen eines Premium-Business-Geräts zu investieren. Das schließt auch ein, Windows nicht zu installieren, weil ich Dinge erledigen und Geld verdienen muss. Außerdem: Wenn dieses Verhalten unter Windows nicht auftritt, was dann? Ich bin es seit Jahren gewohnt, Linux zu nutzen, und Windows hat mit Sicherheit seine eigenen Macken.

Aus Software-Sicht lief alles gut. [Manjaro](https://manjaro.org/), obwohl von Arch Linux abstammend, ist eine sehr ausgereifte und stabile Distribution, die gleichzeitig eine Rolling-Release-Erfahrung und Pakete für fast jede vorstellbare Software bietet. Das war der Grund, warum ich weiter nach Lösungen suchte und hoffte, mein Problem zu lösen, da ich mit meinem Setup sehr produktiv war.

Darüber hinaus besaß ich über das letzte Jahrzehnt mehrere ThinkPads (x61, x220, x230, X1C6), und jeder von ihnen war ein treuer Begleiter.

Nicht zuletzt spielte auch ein wenig Nostalgie eine Rolle während meiner Überlegungen.

Dennoch entschied ich mich, den großen Schritt zu wagen und bestellte ein MacBook Pro (MBP). Hier ist der Grund.

### Gründe für Mac

- macOS basiert auf **FreeBSD** und kann einen \*nix-basierten Workflow erfüllen.
- Man kann über Apple sagen, was man möchte, aber ihre Produkte **funktionieren** einfach. Ich kann es mir nicht mehr leisten, Stunden und Stunden mit der Fehlersuche und Bastelei zu verbringen. Während meines Studiums installierte ich jede Woche eine neue Custom-ROM auf meinen Android-Geräten oder betrieb Arch Linux Testing, das nach jedem Update fast zu einem kaputten System führte. Diese Zeiten sind vorbei, und jetzt brauche ich ein System, das einfach zu warten ist und mich produktiv sein lässt, während es mir trotzdem etwas Freiheit für eigene Workflows lässt.
- Im Grunde ist mein Computer nur ein Host für einen **Browser** (Firefox) und ein **Terminal**. Diese beiden Anwendungen können 95 % meiner Anwendungsfälle abdecken. Letzteres ist auch der Grund, warum Windows keine Option für mich ist. Ich bin sicher, dass man mit PowerShell und dem objektorientierten Ansatz ernsthafte Arbeit leisten kann, aber ich bin einfach zu sehr an (vollständiges) Bash und Linux-Terminals gewöhnt.
- Die **Hardware** des MacBook 2021 ist ein Meisterwerk in Ästhetik und Funktion. Ich mag wirklich das flache, raue und scharfe Design. Im Allgemeinen mag ich das kurvige Design vieler Technikprodukte der letzten Jahre nicht und schätze Apples Rückkehr zu einem flacheren Designsprache, wie sie es mit dem iPhone 12 getan haben. Neben dem Design sind die bemerkenswertesten Hardware-Elemente das 14-Zoll-Display (meiner Meinung nach der Sweet Spot zwischen Mobilität und Produktivität), die kleinen Blenden (endlich!), die Rückkehr der dedizierten Funktionstasten und die Hinzufügung weiterer Ports.
- Ich gebe zu: Ich war seit dem Launch sehr neugierig auf **Apple Silicon** und seine Leistung und Optimierungen. Jetzt (2021) mit der zweiten Iteration bin ich noch neugieriger. 😆
- Ein MBP würde **gut passen** neben meinem iPhone und iPad, obwohl ich die iCloud-Synchronisation auf all meinen Geräten deaktiviert habe und mich nicht auf Apples Cloud-Dienst verlasse. AirDrop allein wäre eine nette Ergänzung.

### Bedenken bezüglich Mac

Das gesagt, gab es auch ein paar Bedenken bezüglich des Wechsels zu Mac:

- Das Apple-**Tastaturlayout**: Mein Muskelgedächtnis ist an das klassische PC-Tastaturlayout gewöhnt, und ich hatte Angst vor der seltsamen Command-Taste und dem Fehlen dedizierter Bild-auf/ab-, Pos1/Ende-, Entf/Einfg- und Druck-Tasten. Das könnte ein kleines Problem sein, da ich die meiste Zeit mit einer externen Tastatur arbeiten kann. Dennoch möchte ich auch nur mit dem Laptop produktiv sein können.
- Der **macOS-Window-Manager** und seine fehlenden Fähigkeiten: Mein Workflow ist sehr tastaturzentriert und beinhaltet die Verwaltung von Anwendungen und virtuellen Desktops mit benutzerdefinierten Shortcuts.
- Inkompatibilität der **Apple-Silicon-Architektur** mit einigen erforderlichen Apps und Tools.
- Ich hatte Angst, nach dem **Einsteigen** nicht mehr aus dem Apple-Ökosystem entkommen zu können 😆

Mehr über diese Bedenken und wie ich damit umgehe, sowie andere Probleme sind in [Das Schlechte](#the-bad) und [Das Hässliche](#the-ugly) zu finden.

### Erwartungen

Meine Erwartungen an den Wechsel zu macOS und Apple-Hardware waren folgende:

- Eine absolut solide und **stabile** Benutzererfahrung, die keine Aufmerksamkeit von meiner Seite erfordert.
- Keine Notwendigkeit, sich mit **Betriebssystemkomponenten und Einstellungen** wie Kernel-Dingen, Lüftersteuerung, tlp, Grafik, Modulen/Treibern usw. zu beschäftigen.
- Alles **funktioniert einfach**, besonders im Apple-Ökosystem (iPad, AirPods, ...).
- Ein absolut **ruhiges** System ohne oder mit sehr minimalem Lüftergeräusch.
- Eine Linux-ähnliche **Terminal-Erfahrung** und ein Workflow mit all meinen verschiedenen CLI/TUI-Anwendungen.
- Obwohl ich [Ricing](https://www.reddit.com/r/unixporn/comments/3iy3wd/stupid_question_what_is_ricing/) schätze, benötige ich auch ein System, das mich **zuverlässig** bei meinen Geschäften unterstützt, aber trotzdem in einem gewissen Maß angepasst werden kann.

Im nächsten Abschnitt beschreibe ich kurz meinen Migrationspfad. 🤓

## Migration von Linux zu Mac

{{< figure src=terminal.png caption="Iterm2, Tmux, Neovim, Neofetch" >}}

Nach der Recherche zu Erfahrungen anderer mit einem solchen Wechsel, ohne zu viel zu finden, entschied ich mich, es auszuprobieren und meine Erfahrungen aufzuschreiben. Meine Ausrede war, dass Apple-Hardware keinen Wert verliert und ich das MBP nach Ablauf der 14-tägigen Rückgabefrist immer noch verkaufen könnte.

Ich bestellte ein MacBook Pro 14 Zoll mit folgenden Specs:

- M1 Pro 10-Core
- 32 GB RAM
- 1 TB Speicher

Zunächst war ich versucht, das Maximum zu wählen und den M1 Max mit 64 GB RAM zu nehmen. Nach einigen Rezensionen und Vergleichen kam ich zu dem Schluss, dass ich diese Leistung nie brauchen würde und möglicherweise auch die Akkulaufzeit einbüßen würde. RAM und Speicher entsprechen meinem X1C, daher denke ich, dass es eine gute Wahl war.

Ehrlich gesagt war ich von der Migration und ihrer Reibungslosigkeit überrascht. Aber zunächst der Reihe nach. Normalerweise gibt es bei einer solchen Migrationsaufgabe zwei Kategorien:

1. Daten (Dokumente, Bilder, ...)
2. Apps und Konfigurationen

Die Migration meiner Daten war unkompliziert. Ich kopierte die obersten Datenordner aus meinem alten Home-Verzeichnis in das Home-Verzeichnis des Macs. Ich ignorierte die speziellen macOS-Ordner wie `Documents`, `Pictures` usw., weil ich meine eigene Struktur bevorzuge, wie im folgenden Ausschnitt dargestellt.

```sh
.
├── 100_FUJI
├── Downloads
├── data
├── media
├── business
└── workspace
```

Für die Migration von Anwendungen muss zwischen Terminal-Apps und GUI-Apps unterschieden werden. Für letztere gibt es im macOS-Ökosystem in der Regel mehr alternative Apps. Die folgende Tabelle zeigt meine früheren GUI-Apps und ihre Entsprechungen auf meinem MBP.

{{< alert >}}
Meine Botschaft ist nicht zu sagen, dass die Linux-Apps schlechter sind als ihre Entsprechungen. Jede App hat ihre Stärken und Schwächen!
{{< /alert >}}

| Typ             | Linux                                                                     | macOS                                                                          |
| --------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Fotobearbeitung | [Gimp](https://www.gimp.org/)                                             | [Affinity Photo](https://affinity.serif.com/en-gb/photo/) (auch auf iPad)      |
| Vektorgrafik    | [Inkscape](https://inkscape.org/)                                         | [Vectornator](https://www.vectornator.io/) (auch auf iPad)                     |
| Dokumentenbetrachter | [Zathura](https://pwmt.org/projects/zathura/)                        | [Preview](https://support.apple.com/en-mn/guide/preview/welcome/mac)           |
| Terminal        | [Alacritty](https://github.com/alacritty/alacritty) (kein nativer Build) | [iTerm2](https://iterm2.com/)                                                  |
| Screenshot      | [Flameshot](https://github.com/flameshot-org/flameshot) (kein nativer Build) | [Xnip](http://xnipapp.com/)                                                |

Die folgende Liste zeigt alle Anwendungen, die ich weiterhin unter macOS betreibe:

| Typ                     | App                                                                                                                                                            |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Webbrowser              | [Firefox](https://www.mozilla.org/en-US/firefox/new/) (Haupt), [Chromium](https://www.chromium.org/) (Backup); ich kopierte die vollständigen Profilordner von Linux |
| Synchronisation         | [Syncthing](https://syncthing.net/)                                                                                                                            |
| IDE                     | [Jetbrains Suite](https://www.jetbrains.com/) (Backup für mein Neovim ➡️ [config](https://github.com/Allaman/nvim/))                                           |
| Proxy/Web-Inspektion    | [Burp](https://portswigger.net/burp/documentation/desktop/tools/proxy)                                                                                         |
| Passwort-Manager        | [KeePassXC](https://keepassxc.org/)                                                                                                                            |
| Office-Suite            | [Libreoffice](https://www.libreoffice.org/)                                                                                                                    |
| API-Testing/-Exploration| [Postman](https://www.postman.com/)                                                                                                                            |
| E-Book-Verwaltung       | [calibre](https://calibre-ebook.com/) (noch nicht installiert aufgrund fehlenden nativen Pakets)                                                               |

Die Migration meiner CLI/TUI-Apps verlief sehr reibungslos, dank [Homebrew](https://brew.sh/). Homebrew ist ein Paketmanager für macOS, aber man sollte keine Funktionsparität wie pacman oder aptitude erwarten. Fast jede CLI/TUI-App sowie viele GUI-Anwendungen können über brew installiert werden. Ich verwaltete die Konfiguration meines X1C mit einem Ansible-Playbook, das [hier](https://github.com/Allaman/rice) zu finden ist.

Für mein MBP wollte ich etwas Ähnliches und erstellte ein [Repo](https://github.com/Allaman/mac-setup), das alle meine Anwendungen (mit wenigen Ausnahmen) installiert und mein zsh konfiguriert.

**Überraschenderweise sind nicht nur 99 % meiner Programme über Homebrew verfügbar, sondern auch für Apple Silicon!**

Auf [doesitarm](https://doesitarm.com/) kann nachgeschaut werden, ob das eigene Programm auf ARM oder Rosetta läuft.

{{< alert >}}
Ich habe Apples Rosetta-Emulationsschicht bisher nicht aktiviert und versuche das auch nicht zu tun! Alle Programme laufen nativ!
{{< /alert >}}

## Das Gute[^2]

Was mag ich? Was macht ein MBP mit macOS besser?

### Hardware

- KEIN LÜFTER; ich weiß nicht mal, wie er klingen würde.
- Sehr solides Gehäuse und allgemeine Bauqualität. Das neue flache Design gefällt mir sehr gut.
- Über das Display kann ich nicht viel sagen, außer dass es sich glatt und hell anfühlt und für mich funktioniert. Die meiste Zeit arbeite ich mit einem externen Monitor, während der Laptop-Deckel geschlossen ist.
- Die neuen MBP-Ports: drei USB-C, ein MagSafe, ein HDMI, ein SD-Karten-Leser und ein Kopfhöreranschluss. Besonders den SD-Karten-Steckplatz vermisste ich an meinem X1C. Allgemein macht das MBP durch die neuen Ports den Einsatz ohne Adapter und Dongle möglich.
- Sehr komfortable Tastatur, die die des X1C Gen 9 übertrifft. Meiner Meinung nach hat Lenovo die IBM-Tradition fortgeführt, die besten Laptop-Tastaturen zu bauen, daher war das eine ziemliche Überraschung.
- Das MBP hat ein überlegenes Touchpad. Apple hat eine lange Tradition darin, die besten integrierten Touchpads zu bauen, also keine Überraschung.
- Sehr schneller und zuverlässiger Fingerabdrucksensor, der direkt nach dem Anschließen funktioniert.
- Sehr lange Akkulaufzeit. Ich habe keine wissenschaftlichen Tests gemacht, aber ich schätze, dass ich mit normalem Arbeiten leicht 10–12 Stunden erreiche.
- Keine Bluetooth-Probleme; gekoppelte Geräte funktionieren einfach.
- Die integrierten Lautsprecher sind unglaublich. Ich kann damit Musik hören und es genießen!
- All meine Peripheriegeräte funktionieren mit meinem MBP.

### Software

- Polierte und flüssige Benutzeroberfläche.
- Sofortiger Schlaf und Aufwachen ohne Probleme nach dem Fortsetzen.
- Alles fühlt sich etwas schneller an.
- Kein Aufwand mit Kernel-Modulen und Grafikkarten-Konfiguration und -Optimierung.
- Meine [NeoVim-Konfiguration](https://github.com/Allaman/nvim) funktioniert direkt mit macOS und iTerm2.
- Meine Ansible-Rollen für [Shell](https://github.com/Allaman/ansible-role-shell), [pip](https://github.com/Allaman/ansible-role-pip) und [Binaries](https://github.com/Allaman/ansible-role-binaries) funktionieren direkt und werden in meinem neuen [mac-setup](https://github.com/Allaman/mac-setup)-Playbook verwendet.
- CAPS auf ESC umzulegen ist eine eingebaute macOS-Option und funktioniert reibungslos. Unter Linux verwendete ich ein [xcape](https://github.com/alols/xcape)-Skript, das regelmäßig von udev „überschrieben" wurde, und schließlich [keyd](https://github.com/rvaiya/keyd), das 95 % der Zeit funktionierte.
- Die Druckereinrichtung ist sehr einfach. Kein `cupsd`-Durcheinander.

## Das Schlechte

Was mag ich nicht? Was sind die Macken eines MBP und macOS?

### Hardware

- Das MBP ist schwerer mit 1,6 kg gegenüber 1,1 kg des X1C und auch klobiger mit einigen scharfen Kanten.
- Es gibt keine mechanische Abdeckung der internen Webcam.
- Nur HDMI 2.0 (statt 2.1).
- Nur UHS-II-SD-Karten-Leser (statt UHS-III).
- Fehlender USB-A-Anschluss.
- Fehlender Ethernet-Anschluss (wie bei den meisten Konkurrenten).
- Die interne Tastatur ist ein Fingerabdruck-Magnet.
- Die Notch teilt die Meinungen. Für mich stört die Notch überhaupt nicht.
- Kein mittlere Maustaste wie mit den TrackPoint-Buttons meines X1C zum Einfügen aus der Auswahl-Zwischenablage (mit [middleclick](https://rouge41.com/labs/) einen Mittelklick mit Drei-Finger-Tippen emulieren).
- Das Scrollen mit meiner Logitech MX Vertical ist nicht flüssig und fast unbrauchbar. Außerdem funktionieren die Vor-/Zurück-Tasten nicht. Ich verwende [LinearMouse](https://linearmouse.org/), um beide Probleme zu lösen.
- Keine dedizierten `BILD-AUF`-, `BILD-AB`-, `ENDE`-, `POS1`-Tasten. Ich habe diese kaum verwendet, wegen meiner Vim-Bindings überall.

### Software

- [alacritty](https://github.com/alacritty/alacritty) ist noch nicht als nativer ARM-Build verfügbar (kann selbst kompiliert werden).
- `CMD-TAB` zeigt Anwendungen aus allen Spaces, nicht nur dem aktiven (➡️ [alt-tab](https://alt-tab-macos.netlify.app/)).
- `CMD-TAB` trennt nicht zwischen verschiedenen Anwendungsfenstern (➡️[alt-tab](https://alt-tab-macos.netlify.app/)).
- `CMD-q` schließt Fenster, besonders gefährlich beim Versuchen, `@` wie auf einer PC-Tastatur einzugeben (rechtes CMD-q schließt ebenfalls). Ich verwende eine [Karabiner](https://karabiner-elements.pqrs.org/)-Modifikation, die Anwendungen nur schließt, wenn `CMD-q` zweimal gedrückt wird.
- `Alt-.` muss konfiguriert werden oder kann durch `ESC-.` ersetzt werden (zum Einfügen vorheriger Argumente in Bash).
- Maximierte Fenster sind nicht wirklich maximiert, und die Ränder sind störend, besonders wenn man versehentlich einen Rand statt einer Scrollleiste greift.
- Warum benennt `RETURN` in Finder einen Ordner um, anstatt ihn zu öffnen?

## Das Hässliche

Was bringt mich zum Wahnsinn? 😆

### Hardware

- Das Tastaturlayout. Ich bin seit meinem ersten PC an Standard-PC-Tastaturen gewöhnt.
- Eckige Klammern: `OPT-5`: `[`, `OPT-6`: `]` und `OPT-8`: `{`, `OPT-9`: `}`
- Pipe: `OPT-7`: `|`
- Tilde: `OPT-n`: `~?` (kollidiert mit meinen tmux-Bindings)
- At-Zeichen: `OPT-l`: `@` (kollidiert mit meinen tmux-Bindings)
- Mit intensiver Nutzung von [Karabiner](https://karabiner-elements.pqrs.org/)-Modifikationen habe ich alle Tasten neu zugewiesen, um eine ähnliche Erfahrung wie bei einer PC-Tastatur zu erzielen, wenn ich meine externe Tastatur verwende.
- Trotz des exzellenten Touchpads vermisse ich den TrackPoint und seine dedizierten Maustasten, da diese es mir ermöglichten, die Finger immer auf der Grundreihe zu halten.

### Software

- Verzögerung beim Wechsel der Spaces ([Artikel mit Video](https://piunikaweb.com/2021/12/14/macos-12-monterey-workspace-switching-animation-lag-with-promotion/)). Ernsthaft, Apple?
- LUKS-verschlüsselte externe Festplatten können von macOS nicht gelesen werden (es gibt keine Umgehungslösung).
- [Calibre](https://calibre-ebook.com/) ist (noch) nicht als natives Paket verfügbar, und es gibt keine Alternative. Calibre läuft gut mit Rosetta, aber ich möchte die Emulationsschicht nicht aktivieren.
- [ueberzug](https://github.com/seebye/ueberzug) hängt von x11 ab und ist nicht verfügbar (wird für die Dateivorschau im Terminal in Verbindung mit [lf](https://github.com/gokcehan/lf) verwendet). Bisher habe ich keine Lösung dafür gefunden.
- Fehlende `primary selection` im gesamten Betriebssystem. Sie ist in iTerm2 verfügbar. Unter Linux wird jeder ausgewählte Text, egal wo, in die Zwischenablage kopiert und kann mit einem mittleren Mausklick eingefügt werden.
- Warum gibt es in Finder kein `Ausschneiden`?

## Fazit

Insgesamt bin ich sehr zufrieden mit meinem Wechsel zu Apple/macOS. Die meisten meiner Apps und Workflows funktionieren in macOS. Aus dieser Perspektive ist mein Wechsel kaum spürbar. Ich habe meinen Firefox mit allen Einstellungen, Cache und Erweiterungen, ein funktionierendes und schön aussehendes Terminal mit iTerm2, Tmux, Neovim, Neomutt usw. Was ich wahrnehme, ist eine überlegene Performance und absolut keine Geräusche. Das Einzige, was etwas Zeit in Anspruch nahm, war die Installation und Anpassung der Konfigurationen meiner (neuen) Anwendungen. Es gab keine Notwendigkeit, sich mit Kernels, OS-Optimierungen, Bluetooth, Audio und so weiter auseinanderzusetzen.

Natürlich ist das keine Langzeit-Rezension, da ich das MBP erst seit ein paar Wochen besitze. Bleiben Sie dran ([RSS](https://rootknecht.net/blog/index.xml), [Twitter](https://twitter.com/allamann)) für eine tiefergehende Rezension mit Fokus auf meine täglichen Aufgaben als **DevOps/Cloud-Engineer**.

Hier ist die [Reddit-Diskussion](https://www.reddit.com/r/MacOS/comments/ruhi3n/moving_to_macos_after_10_years_of_running_solely/)

[^1]: In diesem Beitrag wird Linux als Synonym für alle Linux-basierten Betriebssysteme verwendet, obwohl Linux technisch gesehen nur der Kernel ist.

[^2]: Alle Auflistungen sind in keiner bestimmten Reihenfolge.
