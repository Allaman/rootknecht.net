---
title: Mein Arbeitsplatz
summary: Ein Blogbeitrag über mein aktuelles Arbeitsplatz-Setup
description: produktivität konfiguration hardware
type: posts
draft: false
date: 2021-10-11
tags:
  - configuration
  - hardware
  - produktivität
  - linux
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/my-workplace-2021/)
{{< /alert >}}

Dies ist der Nachfolger meines Blogbeitrags [Mein Laptop-Setup](/blog/my-laptop-setup), in dem ich ein Update zu meiner Hardware und Software für das tägliche Geschäft geben möchte.
Dieser Artikel ist in drei Teile gegliedert. Im ersten Teil gebe ich einen Überblick über die Hardware, mit der ich derzeit arbeite. Im zweiten Teil spreche ich über die Software auf meinem Laptop, und im letzten Teil über meinen Schreibtisch.

## Hardware[^1]

### Laptop

{{< figure src=carbon.jpg caption="Lenovo X1 Carbon Gen 9" >}}

Kürzlich habe ich meinen [Lenovo X1 Carbon Gen 6](/blog/my-laptop-setup/#laptop) auf das [Gen-9-Modell](https://www.lenovo.com/de/de/laptops/thinkpad/thinkpad-x1/X1-Carbon-G9/p/22TP2X1X1C9) aktualisiert mit folgenden Specs:

- Intel® Core™ i7-1165G7 11. Generation (2,80 GHz, bis zu 4,70 GHz Turbo Boost, 4 Kerne, 8 Threads, 12 MB Cache)
- Intel® Iris® Xe Graphics
- 32 GB LPDDR4X 4266 MHz (verlötet)
- 1 TB PCIe-SSD
- 14,0" WUXGA (1920x1200) IPS, matt, 400 cd/m², 100% sRGB, Multitouch
- Intel Wi-Fi 6 AX201 (2x2 AX) & Bluetooth® 5.0
- Quectel EM120R-GL 4G/LTE Cat. 12

Der Hauptgrund für das Upgrade meines einwandfrei laufenden Gen-6-Modells (das den treuen [x220](http://localhost:1313/blog/my-laptop-setup/#why-lenovo) meines Vaters ersetzen wird) war RAM. Obwohl mit 16 GB Arbeitsspeicher ausgestattet, gibt es Szenarien, bei denen RAM der Engpass war. Zum Beispiel beim Kompilieren von [nativen Quarkus-Anwendungen](https://quarkus.io/guides/building-native-image), was sehr viel RAM benötigt, oder beim Betreiben eines lokalen Multi-Node-Kubernetes-Clusters mit Deployments wie dem Prometheus/Grafana-Monitoring-Stack.

Die zweite wesentliche Änderung an meinem neuen X1 ist das Display, was man vielleicht als einen Rückschritt vom 4K-Display meines früheren Gen-6-Modells sehen könnte. Technisch gesehen ist das zwar richtig, aber das 4K-Display hatte einen großen Nachteil. Es war für mich ziemlich schwer, Text zu lesen, weil er so winzig war, und das Arbeiten mit 4K war zu anstrengend für meine Augen. Aber es gibt doch Skalierung! Leider ist Skalierung etwas, das in den meisten Linux-Desktop-Umgebungen (für mich!) nicht so gut funktioniert. Entweder kann man nur auf 200 % skalieren (zu groß 😠) oder die Skalierung betrifft nicht jede Anwendung, oder die Skalierung für verschiedene Bildschirme ist nicht möglich/machbar. Ein Full-HD-Bildschirm mit einem 14-Zoll-Panel ist meiner Meinung nach der perfekte Sweet Spot, ohne Skalierungsbedarf.

Mehr über meine Gründe für Lenovo [in meinem alten Beitrag](blog/my-laptop-setup/#why-lenovo).

Leider erlebte ich einige Macken:

1. Das Firmware-Update MUSS eingespielt werden. Frühere Firmware-Versionen sind von starkem Throttling betroffen, das das System nicht mehr reagieren lässt ([Lenovo Forum](https://forums.lenovo.com/topic/view/1301/5073083)).
2. Wenn an den Monitor über USB-C angeschlossen, führte ein Aufwachen nach dem Standby zu voller Last auf einem Kern, obwohl kein Prozess so viel CPU nutzte. Es stellte sich heraus, dass der `Linux S3`-Modus das Problem war. Nach dem Wechsel zu `Windows und Linux` (s0ix oder Connected Standby) in den BIOS-Einstellungen war dieses Problem behoben. Intel hat offenbar [S3-Unterstützung](https://www.reddit.com/r/System76/comments/k7xrtz/ill_have_whatever_intel_was_smoking_when_they/) für Tiger-Lake-CPUs fallen lassen.

### Tastatur und Maus

Meine bevorzugte Tastatur ist derzeit eine [Razer BlackWidow Elite](https://www.razer.com/gaming-keyboards/razer-blackwidow-elite/RZ03-02620200-R3U1). Es ist eine solide (und schwere) mechanische Tastatur mit gutem (taktilen) Gefühl und auch für Nicht-Gaming-Aufgaben sehr gut verwendbar 😉. Der USB-Passthrough und der Audio-Lautstärke-Drehregler sind einige praktische Features. An meine [Ergodox-EZ](/blog/ergodox-ez/) habe ich mich nie gewöhnt, weil sie so anders ist, dass meine Produktivität drastisch sinkt, wenn ich versuche, diese Tastatur zu benutzen. Leider habe ich nicht die Geduld, mein Muskelgedächtnis zu üben und umzuschreiben.

Für meine Mäuse gibt es im Vergleich zum vorherigen Setup keinen Unterschied. Meine Hauptmaus ist eine [Logitech MX Vertical](https://www.logitech.com/de-de/product/mx-vertical-ergonomic-mouse) wegen der ergonomischen Vorteile gegenüber einer „traditionellen" Maus. Meine Reisemaus ist eine [Logitech MX Anywhere 2S](https://www.logitech.com/de-de/product/mx-anywhere-2s-flow). Mit beiden bin ich sehr zufrieden, und die Möglichkeit, drei Geräte zu speichern und per Hardware-Taste zu wechseln, ist großartig!

{{< alert >}}
Ich betreibe keine Software von Razer oder Logitech, daher kann ich nichts über den Wert ihrer Software (z. B. Anpassen) sagen. Alle Funktionen, die ich von meinen Mäusen/Tastaturen verwende, sind in den Standard-Kernel-Treibern enthalten.
{{< /alert >}}

### Peripherie

Ich verwende weiterhin [Panasonic Bluetooth RP-HD605NE-K9](https://www.panasonic.com/de/consumer/home-entertainment/kopf-ohrhoerer/kopfhoerer/rp-hd605n.html)-Kopfhörer und den [Inateck USB C Hub](https://www.amazon.de/gp/product/B07QXYS1WM)-Dock (besonders für mobile Arbeit, um für alle potenziellen Konnektivitätsbedürfnisse gerüstet zu sein). Ich habe eine [Logitech C930e](https://www.logitech.com/de-de/products/webcams/c930e-business-webcam.960-000972.html)-Webcam und ein iPad Pro 2020 zum Notizen-Machen, Bücher-Lesen und Zeichnen von Logos/Bildern für meinen Medienbedarf hinzugefügt 🙂.

### Monitor

Meine Augen schauen auf den [Dell UltraSharp 27 4K-USB-C](https://www.dell.com/de-de/shop/ultrasharp-27-4k-usb-c-monitor-u2720q/apd/210-aves/monitore-und-monitorzubeh%C3%B6r). Ich habe diesen gewählt wegen seines IPS-Panels und des eingebauten USB-C-Docks. Damit muss nur der Laptop über USB-C angeschlossen werden, und meine anderen Geräte (Webcam, Tastatur, USB-Sticks, ...) sind über den Monitor angeschlossen und werden durch den Monitor an den Laptop weitergeleitet. Um die Anzahl der verfügbaren USB-Ports zu erhöhen, habe ich einen [Aukey USB Hub](https://www.aukey.com/products/aukey-usb-3-0-hub-ultra-slim-aluminum-4-port-usb-hub) an den Monitor angeschlossen.

Der Monitor selbst ist auf einem [1home Full Motion Gas Spring Single Arm Desk](https://www.amazon.de/gp/product/B079HQQPJT) montiert. Das gibt mir einen saubereren Schreibtisch und mehr Platz. Außerdem kann ich die Monitor-Winkel bei Bedarf einfach anpassen. Wie bereits erwähnt, ist die 4K-Auflösung zu klein, und Skalierung war für mich keine gute Erfahrung. Daher ist mein Monitor nicht auf seine maximale Auflösung eingestellt, sondern auf 2560x1440.

Man könnte fragen, warum ich keinen zweiten Monitor betreibe? Dann würden Sie überrascht sein zu hören, dass mein Laptop-Bildschirm ausgeschaltet ist, wenn er an den Dell-Monitor angeschlossen ist 🙂. **Für mich** ist ein einziger Bildschirm die effizienteste Art, Dinge zu erledigen. Erstens sind meine Augen und mein Kopf geradeaus auf mich ausgerichtet, und ich muss mich nicht umdrehen, um einen anderen Bildschirm anzuschauen. Zweitens weiß ich beim Verwenden nur eines Bildschirms immer genau, wo alle meine Apps geöffnet sind. Natürlich nutze ich virtuelle Desktops intensiv!

## Software

### Betriebssystem

Mein bevorzugtes Betriebssystem ist weiterhin [Manjaro](https://manjaro.org/). Trotz der Tatsache, dass es auf [Arch Linux](https://archlinux.org/) basiert, ist es eine sehr benutzerfreundliche Distribution, die selbst für unerfahrene Linux-Benutzer empfehlenswert ist, im Gegensatz zu „reinem" Arch. Ich habe meinen zuvor verwendeten [Window Manager](https://en.wikipedia.org/wiki/Window_manager) [i3wm](https://i3wm.org/) durch eine vollständige [Desktop-Umgebung](https://en.wikipedia.org/wiki/Desktop_environment) ersetzt: [XFCE](https://www.xfce.org/).

Gründe für meinen Wechsel von i3wm zu XFCE:

1. Obwohl ich Tiling Window Manager immer noch Desktop-Umgebungen vorziehe, brauchte ich etwas Zuverlässigeres. Missverstehen Sie mich nicht, i3wm ist zuverlässig und stabil! Mit zuverlässig meine ich etwas, das komfortabler zu verwenden ist, ohne ein neues Skript für eine Aufgabe schreiben oder Man-Pages für selten verwendete Befehle lesen zu müssen.
2. XFCE bietet eine leichtgewichtige Alternative zu KDE (das ich mehrere Jahre lang verwendet habe) oder GNOME.
3. Ich habe meine Computer-Geschichte mit Windows begonnen, und ich bin an ein traditionelles Layout (Taskleiste) gewöhnt 🙈. XFCE bietet einen klassischen Desktop, obwohl dieser stark angepasst werden kann (Überraschung 😉).

{{< figure src=desktop.png caption="Minimale Desktop-Ansicht" >}}

### Anwendungen

{{< figure src=shell.png caption="Alacritty mit tmux und Git/K8s-Kontext/AWS-Profil-Info" >}}

#### PIM

Ich betreibe weiterhin das [gleiche Setup](/blog/my-laptop-setup/#pim-setup), außer dass ich von [Mutt](http://www.mutt.org/) zu seinem Fork [NeoMutt](https://neomutt.org/) gewechselt bin.

#### Coding

Ich habe jeden Texteditor aus meinem Werkzeugkasten entfernt, und alle meine Textbearbeitungs-/Coding-Bedürfnisse werden mit NeoVim erfüllt. Die Konfiguration ist auf [Github](https://github.com/Allaman/nvim) zu finden.

{{< figure src=neovim.png caption="Neovim und Go" >}}

#### Shell

Ich bin nach einigen Monaten mit [wezterm](https://github.com/wez/wezterm) zu [alacritty](https://github.com/alacritty/alacritty) als Terminal-Emulator zurückgekehrt. Beide sind schnelle, GPU-beschleunigte und anpassbare Emulatoren.

Meine bevorzugte Shell ist weiterhin [zsh](https://www.zsh.org/). Ich verwende [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) nicht mehr oder irgendeinen anderen Plugin-Manager, sondern verwalte alles „manuell" bzw. lasse Ansible meine [Shell-Konfiguration](https://github.com/Allaman/ansible-role-shell) in Verbindung mit meiner [Dotfiles-Konfiguration](https://github.com/Allaman/ansible-role-dotfiles) und dem [Binaries-Repo](https://github.com/Allaman/ansible-role-binaries) verwalten.

Neben NeoVim und Zsh-Plugins gibt es einige Tools, auf die ich mich stark verlasse:

- [zoxide](https://github.com/ajeetdsouza/zoxide) für schnelles „Springen" zu Ordnern
- [ripgrep](https://github.com/BurntSushi/ripgrep) als praktischen Ersatz für `grep`
- [fd](https://github.com/sharkdp/fd) als praktischen Ersatz für `find`
- [gitui](https://github.com/extrawurst/gitui) eine funktionsreiche Git-TUI
- [p10k](https://github.com/romkatv/powerlevel10k) ein flexibles und schnelles Zsh-Theme
- [lf](https://github.com/gokcehan/lf) ein anpassbarer und leichtgewichtiger Dateimanager
- [tmux](https://github.com/tmux/tmux) ein fortgeschrittener Terminal-Multiplexer
- [xbindkeys](https://linux.die.net/man/1/xbindkeys) zur Verwaltung meiner Tastaturkürzel, ohne von einer bestimmten Desktop-Umgebung oder einem Window Manager abhängig zu sein
- [flameshot](https://github.com/flameshot-org/flameshot) ein funktionsreiches Screenshot-Tool
- [keepassxc](https://keepassxc.org/) Open-Source-Passwort-Manager
- [Firefox](https://www.mozilla.org/de/firefox/new/) Anti-Chromium-basierter Browser 😉
- [hledger](https://hledger.org/) zum Verfolgen meiner Ausgaben

... und viele mehr. Meine Listen von [CLI-](/knowledge/applications/cli/) und [GUI-](/knowledge/applications/gui/)Anwendungen bieten weitere Details.

### Automatisierung

Für die Konfiguration meines Laptops verwende ich [Ansible](https://www.ansible.com/). Ansible ist ein gängiges Tool im Bereich [Infrastructure as Code](/blog/devops/#infrastructure-as-code) für IT-Automatisierungszwecke.

Das Playbook ist auf [Github](https://github.com/Allaman/rice) zu finden. Dieses Playbook ermöglicht es mir, 90 % meiner Einstellungen und Tools einer Frischinstallation in wenigen Minuten automatisch zu konfigurieren.

{{< figure src=ansible.png caption="Ansible-Playbook läuft" >}}

## Schreibtisch/Stuhl

{{< figure src=desk.jpg caption="Mein Büro" >}}

Mein Schreibtisch besteht aus zwei Teilen:

1. Die [Tischplatte](https://www.amazon.de/boho-m%C3%B6belwerkstatt-Schreibtischplatte-Kratzfestigkeit-Belastbarkeit/dp/B07BFJBKC8) — eigentlich nur eine Holzplatte ☺
2. Das [Gestell](https://www.amazon.de/gp/product/B07K7PDWYK/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1) — vertikal verstellbare Gestelle mit einem kleinen Elektromotor und bis zu 4 Speicherplätzen

Beide fühlen sich sehr solide und zuverlässig an und geben meinem Schreibtisch ein sauberes und ordentliches Aussehen.

Mein Stuhl ist ein [noblechairs Epic](https://www.noblechairs.de/epic-series/gaming-stuhl-pu-leder). Das ist mein erster ergonomischer „Gaming"-Stuhl, und ich bin sehr zufrieden mit der Ergonomie und Qualität. Das ist auf einem anderen Niveau im Vergleich zu einem normalen Bürostuhl.

[^1]: Ich werde von keinem Unternehmen in diesem Artikel gesponsert.
