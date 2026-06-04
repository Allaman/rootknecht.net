---
title: Mein Laptop-Setup
summary: In diesem Beitrag gebe ich einen Überblick über meinen aktuellen Laptop und einige der Hardware, die ich für die Arbeit verwende.
description: lenovo, linux, produktivität, konfiguration
type: posts
date: 2020-08-30
tags:
  - produktivität
  - hardware
  - configuration
  - linux
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/my-laptop-setup/)
{{< /alert >}}

{{< alert >}}
Bitte besuchen Sie [Mein Arbeitsplatz 2021](/blog/my-workplace-2021/) für eine aktualisierte Version!
{{< /alert >}}

## Hardware

### Laptop

Ich nutze einen Lenovo X1 Carbon der 6. Generation[^1] mit folgenden Specs:

- Intel Core i7-8550U Prozessor (8 MB Cache, bis zu 4,00 GHz)
- Intel UHD-Grafik 620
- 16 GB LPDDR3 2.133 MHz (verlötet)
- 1 TB SSD, M.2 2280, PCIe, NVMe, OPAL 2.0-fähig
- 35,6 cm (14") WQHD (2.560 x 1.440), IPS, entspiegelt, 300 cd/m²
- Intel Dualband-Wireless-AC 8265 (2x2) WLAN
- Fibocom Cat9 L850-GL 4G LTE

{{< figure src=x1carbon.png caption="Lenovo X1 Carbon 6. Gen" >}}

### Warum Lenovo

Mein erster Lenovo-Laptop war der überlegene [x220](https://thinkwiki.de/X220), und ich war total beeindruckt von seinem leichten Formfaktor _und_ seiner Leistung. Mein Vater nutzt ihn heute noch (Stand Juli 2020)! Ich war so begeistert, dass ich nach nur einem Jahr zum Nachfolger [x230](https://thinkwiki.de/X230) wechselte, der bis Mai 2019 meine Hauptarbeitsmaschine war!

An diesem Punkt hatte ich mich vollständig auf Lenovo-Laptops eingeschossen, aus zwei Hauptgründen:

1. Lenovos TrackPoint. Ich bin mit dem TrackPoint fast so schnell wie mit einer echten Maus, obwohl mein [Workflow](#workflow-philosophy) stark tastaturzentriert ist.
2. Lenovos Tastaturen sind erstklassig! Die klassischen noch mehr als die neueren Chiclet-Tastaturen, aber immer noch erstklassig! Ich habe sogar die Tastatur des x230 [ersetzt](https://knowledge.rootknecht.net/thinkpad-adventures#replacing-x230-keyboard) durch eine ältere :)

Natürlich gibt es weitere Gründe wie exzellente Leistung, Bauqualität und das klassische Aussehen.

### Peripheriegeräte und Gadgets

Neben meinem X1 verwende ich eine [ErgoDX EZ](https://knowledge.rootknecht.net/ergodox-ez)- oder [Lioncast LK 30](https://knowledge.rootknecht.net/ergodox-ez)-Tastatur, eine [Logitech MX Anywhere 2S](https://www.logitech.com/de-de/product/mx-anywhere-2s-flow) unterwegs oder eine ergonomische [Logitech MX Vertical](https://www.logitech.com/de-de/product/mx-vertical-ergonomic-mouse) im Büro, und schließlich ein [Panasonic Bluetooth RP-HD605NE-K9](https://www.panasonic.com/de/consumer/home-entertainment/kopf-ohrhoerer/kopfhoerer/rp-hd605n.html). Für mehr Ports verwende ich den [Inateck USB C Hub](https://www.amazon.de/gp/product/B07QXYS1WM). Für Notizen und das Lesen von Büchern empfehle ich das [ONYX BOOX Nova](https://onyxboox.com/boox_nova) E-Ink-Gerät.

## Betriebssystem

Ich betreibe den [i3wm](https://i3wm.org/)-Flavor von [Manjaro Arch Linux](https://manjaro.org/).

Meiner Meinung nach ist Manjaro das beste Desktop-Betriebssystem, da es eine gute Balance zwischen dem Bleeding Edge von reinem Arch und der Stabilität von nicht-[Rolling-Release](https://en.wikipedia.org/wiki/Rolling_release)-Distributionen wie Ubuntu bietet.

Außerdem stellen [Pacman](https://wiki.archlinux.org/index.php/Pacman) und das [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository) im Grunde Pakete für jede vorstellbare Software bereit.

Nicht zuletzt leistet die [Arch-Community](https://wiki.archlinux.org/index.php/Main_page) hervorragende Arbeit bei der Erstellung von Dokumentation und hilfreichen Artikeln. Meiner Meinung nach ist es die größte Wissensdatenbank einer Distribution, die oft auch auf andere Distributionen anwendbar ist.

## Desktop-Umgebung

Derzeit betreibe ich keine [Desktop-Umgebung (DE)](https://en.wikipedia.org/wiki/Desktop_environment) wie KDE, Gnome, XFCE usw. Wie bereits erwähnt, betreibe ich einen [Window Manager (WM)](https://en.wikipedia.org/wiki/Window_manager) namens i3wm. Ein Window Manager ist normalerweise Teil einer DE und für die Verwaltung von Fenstern innerhalb einer grafischen Benutzeroberfläche zuständig.

Eindrücke meines Setups:

{{< figure src=desktop.png caption="Mein Hintergrundbild der Wahl" >}}
{{< figure src=de.png caption="Einige Terminals" >}}
{{< figure src=gtop.png caption="gtop laufend" >}}

## Anwendungen

{{< alert >}}
Bitte sehen Sie sich [CLI-Anwendungen](https://knowledge.rootknecht.net/cli-applications) und [GUI-Anwendungen](https://knowledge.rootknecht.net/gui-applications) für weitere Anwendungen an, die ich nutze und empfehle.
{{< /alert >}}

### PIM-Setup

[PIM](https://de.wikipedia.org/wiki/Personal_Information_Manager) verwaltet meine Kontakte, Kalender und Mails. Derzeit werden Aufgaben nur in einer einfachen Markdown-Datei verfolgt.

Das Ziel ist, die Möglichkeit zu haben, folgende Fragen zu beantworten, und die Daten lokal und in Plain-Text-Dateien zu halten, um mächtige Text-Operationen nutzen zu können. Daher werden zwei Komponenten benötigt: eine zum Synchronisieren aller Daten mit Servern, damit mein Mobilgerät aktuell ist, und eine zum Anzeigen der Daten.

Zum Synchronisieren von Servern auf die Festplatte und umgekehrt verwende ich folgende zwei Tools: [isync](https://knowledge.rootknecht.net/cli-applications#isync) und [vdirsyncer](https://knowledge.rootknecht.net/cli-applications#vdirsyncer). Beide Tools sprechen gängige Protokolle wie [CalDAV (Kalender)](https://en.wikipedia.org/wiki/CalDAV), [CardDAV (Kontakte)](https://en.wikipedia.org/wiki/CardDAV) bzw. [IMAP (Mail)](https://en.wikipedia.org/wiki/Internet_Message_Access_Protocol).

Zum Anzeigen und Interagieren verwende ich [khal (Kalender)](https://knowledge.rootknecht.net/cli-applications#khal), [khard (Kontakte)](https://knowledge.rootknecht.net/cli-applications#khard) und [mutt (Mail)](https://knowledge.rootknecht.net/cli-applications#mutt).

### Coding

Mein Haupteditor/IDE ist ein stark angepasstes [Neovim](https://neovim.io/), ein Fork des berühmten [Vim](https://www.vim.org/). Von Zeit zu Zeit verwende ich auch den Insiders-Build von [Visual Studio Code](https://code.visualstudio.com/insiders/) zum Debuggen. VSC ist derzeit der beste grafische Editor/IDE. Mein Backup-Texteditor ist irgendwie [Sublime Text](https://www.sublimetext.com/). Sublime Text glänzt durch Geschwindigkeit und Einfachheit, obwohl es auch durch viele Plugins erweitert werden kann.

Die NeoVim-Konfiguration ist auf [Github](https://github.com/Allaman/nvim) zu finden.

### Dienstprogramme

Mein Workflow ist hauptsächlich terminalbasiert. Außer beim Surfen im Web verbringe ich die meiste Zeit vor einem schwarzen Fenster :) Um meine Erfahrung zu verbessern, verwende ich einige großartige Tools.

Beginnen wir mit der Shell selbst. Ich verwende zsh mit [Fish-ähnlichen Autovorschlägen für zsh](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) und [zsh-completions](https://github.com/zsh-users/zsh-completions).
Zusätzlich habe ich einige Dutzend Aliases erstellt, um Befehle schnell auszuführen oder alte Befehle auf neue ausführbare Dateien umzulegen. Ein weiteres wichtiges Feature jeder Shell sollte eine vernünftige Verlaufskonfiguration sein, d. h. eine unbegrenzte Verlaufsdatei, gemeinsamer Verlauf zwischen Sitzungen und sofortiges Anhängen von Einträgen an den Verlauf.

{{< figure src=neofetch.png caption="Obligatorische neofetch-Ausgabe" >}}

Als Terminal verwende ich [termite](https://github.com/thestinger/termite), das sehr schnell, minimalistisch und tastaturgesteuert ist, oder [alacritty](https://github.com/alacritty/alacritty), ein superschnelles plattformübergreifendes Terminal.

Um im Terminal schnell navigieren und Dinge finden zu können, verwende ich einige Kommandozeilen-Tools. Die wichtigsten sind [fzf](https://github.com/junegunn/fzf) und [fasd](https://github.com/clvv/fasd). fzf ermöglicht das schnelle Fuzzy-Finden von Dateien und Ordnern sowie die Suche im Verlauf. Durch die Möglichkeit, stdin an fzf zu pipen, sind die Anpassungsmöglichkeiten nahezu endlos.

{{< figure src=fzf.png >}}

Hier sieht man fzf find, aufgerufen durch `Ctrl+t`. Man beachte auch das Vorschaufenster auf der rechten Seite. Mit `Ctrl+o` kann die ausgewählte Datei im Editor geöffnet werden, oder durch einfaches Drücken der Eingabetaste wird der Pfad zur Datei am Cursor im Terminal eingefügt. Die Möglichkeiten sind wirklich endlos. Es gibt auch eine [Vim-Integration](https://github.com/junegunn/fzf.vim).

fasd ermöglicht das schnelle Springen zu Ordnern durch Indizierung und Gewichtung besuchter Ordner. Mit fasd muss der vollständige Pfad eines Ordners nicht eingegeben werden, da es auch mit Fuzzy-Matching funktioniert. Oft reicht es aus, nur den Basisnamen des Ordners einzugeben, ohne den vollständigen Pfad, und fasd erledigt den Rest.

`find`, `grep`, `ps`, `cat` und `ls` sind bekannte Tools als Linux-Benutzer. Sie sind auf jeder großen Distribution vorinstalliert und sicherlich die ersten Tools, die man kennenlernen würde. Es gibt aber Alternativen, die gute Standardwerte bieten, schneller, einfacher zu verwenden und schöner aussehend sind, und die versuchen, Kompatibilität mit den Argumenten und Flags der ursprünglichen Programme zu erreichen.

| Original | Alternative                                                                    |
| -------- | ------------------------------------------------------------------------------ |
| find     | [fd](https://github.com/sharkdp/fd)                                            |
| grep     | [ripgrep](https://github.com/BurntSushi/ripgrep)                               |
| ps       | [procs](https://github.com/dalance/procs)                                      |
| cat      | [bat](https://github.com/sharkdp/bat)                                          |
| ls       | [exa](https://github.com/ogham/exa) oder [lsd](https://github.com/Peltoche/lsd/) |
| htop     | [gtop](https://github.com/aksakalli/gtop)                                      |

{{< alert >}}
Dennoch empfehle ich ausdrücklich, die originalen Tools zu lernen, da man nicht davon ausgehen kann, diese Ersatztools auf jedem System zu finden!
{{< /alert >}}

## Dotfiles

[Hier](https://github.com/Allaman/dotfiles) sind einige meiner Dotfiles zu finden.

## Workflow-Philosophie

Ich bin ein Tastatur-Fan. Für die Dinge, die ich tue, ist die Tastatur die primäre Eingabemethode, da ich die meiste Zeit mit einer Form von Textdaten arbeite. Mein eigentlicher Grund für den Wechsel zu Linux von Windows war, meinen Laptop nur mit der Tastatur bedienen zu können, weil ich immer meine Maus vergaß. Nach einigen Jahren der Angst vor Vim, verursacht durch die Unfähigkeit, es zu beenden, entschied ich mich, es tiefer auszuprobieren, ohne zu ahnen, welche Auswirkungen das auf meinen Arbeitsstil haben würde!

Seitdem haben sich meine Vim-Kenntnisse sehr verbessert, und ich entdecke täglich neue Features. Außerdem hat Vims [modales Bearbeiten](https://en.wikipedia.org/wiki/Vi#Interface) mich inspiriert, nur Anwendungen zu verwenden, die Vim-ähnliche Tastenbelegungen unterstützen. Meiner Meinung nach steigert die Produktivität stark, wenn man nicht nur Tastaturkürzel verwendet, sondern auch kaum die [Home Row](https://www.computerhope.com/jargon/h/hrk.htm) verlässt.

Hier ist eine unvollständige Liste von Anwendungen, die Vim-ähnliche Tastenbelegungen unterstützen:

- [Vim Vixen](https://en.wikipedia.org/wiki/Vi#Interface) → ein Vim-Plugin für Firefox
- [mutt](http://www.mutt.org/) und [neomutt](https://neomutt.org/) → Mail-Clients mit Vim-Tastenbelegungen
- [vifm](https://vifm.info/) und [ranger](https://github.com/ranger/ranger) → Dateimanager
- [zathura](https://git.pwmt.org/pwmt/zathura) → tastaturgesteuerter leichtgewichtiger PDF-Betrachter
- [newsboat](https://newsboat.org/) → Terminal-RSS-Reader
- [sc-im](https://github.com/andmarti1424/sc-im) → ncurses-Tabellenkalkulation mit Vims modalem Bearbeiten
- [sxiv](https://github.com/muennich/sxiv) → ein Bildbetrachter
- [qutebrowser](http://qutebrowser.org/) → tastaturfokussierter Webbrowser
- [tig](https://github.com/jonas/tig) → ein Git-ncurses-Interface
- [termite](https://github.com/thestinger/termite) → ein Terminal mit eingebauten Vim-ähnlichen Tastenbelegungen
- jede größere IDE/Editor wie [Visual Studio Code](https://code.visualstudio.com/), [Intellij IDEA](https://www.jetbrains.com/idea/), [Eclipse](https://www.eclipse.org/ide) usw. kann mit einem Vim-Plugin erweitert werden

Ein weiterer Aspekt, der durchaus kontrovers ist, ist meine Präferenz beim Multi-Monitor-Betrieb. Die habe ich nicht! Meiner Meinung nach kann ich am besten arbeiten, wenn ich mich nur auf einen Bildschirm mit einem maximierten Fenster und optional Bereichen wie Vims Split-Ansicht konzentriere. Es ist für mich zu ablenkend, mit zwei oder mehr Monitoren zu arbeiten. Um mit nur einem Bildschirm produktiv zu sein, habe ich einige Regeln, die tief in meinem Unterbewusstsein verankert sind:

1. Virtuelle Desktops verwenden und sie strikt ordnen, z. B. ist auf meinem ersten Desktop immer mein Webbrowser.
2. Shortcuts für den effizienten Wechsel zwischen Desktops verwenden.
3. Shortcuts oder einen Tiling Window Manager verwenden, um bei Bedarf einfach zwei Fenster auf einem Desktop nebeneinander anzuordnen.
4. Eine Launcher-Anwendung verwenden, um Anwendungen schnell zu starten.
5. Weniger aufgeblähte Anwendungen verwenden, um GUI-Elemente zu reduzieren und sich auf den Inhalt zu konzentrieren.
6. Ein Drop-Down-Terminal wie [Yakuake](https://kde.org/applications/system/org.kde.yakuake) für schnelle Terminal-Aufgaben verwenden, ohne den aktuellen Desktop zu verändern.
7. Den WM die Fensterverwaltung übernehmen lassen ;)

[^1]: Ich werde von keinem Unternehmen in diesem Artikel gesponsert.

[^2]: Ich kann nicht für [dvorak](https://en.wikipedia.org/wiki/Dvorak_Simplified_Keyboard), [neo](https://neo-layout.org/) und andere spezielle Layouts sprechen.
