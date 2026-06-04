---
title: Windows 10 Linux-ähnlicher machen
summary: Versuche, Windows für einen Linux-Benutzer zum Laufen zu bringen.
description: linux, produktivität, windows, konfiguration
date: 2020-01-22
tags:
  - produktivität
  - configuration
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/win-like-linux/)
{{< /alert >}}

## Motivation

Ich bin seit über einem Jahrzehnt Linux[^1]-Benutzer, und mein Workflow und meine Produktivität sind auf diese Umgebung optimiert, insbesondere die Shell[^2]. Für Einblicke in meinen Workflow und meine Tools gibt es [hier](https://knowledge.rootknecht.net/linux-productivity) mehr. Von Zeit zu Zeit verlangt meine Arbeit von mir, auf einer Windows-Maschine zu arbeiten, obwohl in meiner Branche, Infrastruktur und DevOps, die Mehrheit der Systeme und Tools Linux-gesteuert ist.

Jetzt stellt sich die Frage, wie man die bestmögliche Linux-ähnliche Erfahrung auf einer Windows-10[^3]-Maschine erhält, insbesondere wie man die beste Shell-Erfahrung und die Tools bekommt, an die man gewöhnt ist.

Ich möchte einige Windows-Tweaks und drei Wege beschreiben, um eine mehr Linux-ähnliche Erfahrung auf Windows 10 zu erhalten:

1. Eine Kombination aus einer virtuellen Maschine mit Linux und einem lokalen SSH-Client
2. Das Windows Subsystem for Linux, im Grunde eine Kompatibilitätsschicht zum Ausführen von Linux-Binaries (ELF)
3. Die PowerShell anpassen und erweitern

## Eingebaute Windows-Tools

Windows 10 hat endlich integrierte Funktionen, die unter Linux seit meinen Anfängen verfügbar sind: **virtuelle Desktops** und einen **Clipboard-Manager**!

Der Clipboard-Manager kann durch Drücken von `Win + v` aufgerufen werden. Obwohl er nicht so leistungsfähig ist wie einige Linux-Manager, ist es ein Anfang. Auch [ditto](https://ditto-cp.sourceforge.io/) als Ersatz ist einen Blick wert.

Virtuelle Desktops sind entscheidend für meinen Workflow! Ich nutze sie, um meine Apps zu strukturieren und auf verschiedenen Desktops organisiert zu halten. Leider sind die Shortcuts für die Interaktion mit virtuellen Desktops standardmäßig nicht anpassbar. [Virtual Desktop Enhancer](https://github.com/sdias/win-10-virtual-desktop-enhancer) füllt diese Lücke und ermöglicht es, mehr „home-row-freundliche" Shortcuts zu erstellen.

## Software

Generell bevorzuge ich immer plattformübergreifende Software, um eine möglichst einheitliche Benutzererfahrung auf verschiedenen Plattformen zu haben. In diesem Sinne sind meine Zusammenfassungen zu [CLI-Anwendungen](https://knowledge.rootknecht.net/cli-applications) und [GUI-Anwendungen](https://knowledge.rootknecht.net/gui-applications) empfehlenswert. Insbesondere die meisten GUI-Anwendungen, die ich nutze, sind plattformübergreifend verfügbar. Dennoch gibt es einige nützliche Windows-Anwendungen, die nicht unbedingt nützlich oder verfügbar auf Linux-Systemen sind:

- [ConEmu](https://conemu.github.io/) – Ein erweitertes Terminal mit Tabs, Guake-Drop-Down-Stil, verschiedenen Shells und vielen Anpassungsoptionen
- [Terminus](https://github.com/Eugeny/terminus) – Alternative zu ConEmu, konfigurierbar, enthält gepatchte Schriften, integrierten SSH-Client, PowerShell, WSL, CMD und mehr
- [MobaXterm](https://mobaxterm.mobatek.net/) – Ein vollausgestatteter SSH-, FTP-, RDP- und mehr-Client mit Session-Management, Tunneling, eigener Shell und mehr
- [Autohotkey](https://www.autohotkey.com/) – Ein Open-Source-Windows-Scripting-Tool zur Automatisierung und für Key-Binding-Einstellungen, z. B. ESC auf CAPS mappen
- [Virtual Desktop Enhancer](https://github.com/sdias/win-10-virtual-desktop-enhancer) – Anpassen von Shortcuts für eingebaute virtuelle Desktops
- [ditto](https://ditto-cp.sourceforge.io/) – Ein kostenloser Clipboard-Manager für diejenigen, die mehr Anpassungsmöglichkeiten als der eingebaute bietet
- [PowerToys](https://github.com/microsoft/PowerToys) – Tools von Microsoft für Power-User
- [WinFile](https://github.com/microsoft/winfile) – Originaler Microsoft-Windows-Dateimanager (sehr schnell, keine Sonderordner)

### Autohotkey

Um ein AHK-Skript automatisch zu starten, einfach [capstoesc.ahk](capstoesc.ahk) zum Windows-Startordner hinzufügen (`Win+r -> shell:startup`).

### PowerShell

Guter [Leitfaden](https://gist.github.com/jchandra74/5b0c94385175c7a8d1cb39bc5157365e) zum Anpassen und Einfärben der PowerShell.

1. Neues Standard-Profil für PowerShell generieren

```powershell
new-item $profile -itemtype file -force
```

2. Profil bearbeiten

```powershell
ise $PROFILE
```

3. Verschiedene Profile

Es gibt sechs [verschiedene Profile](https://devblogs.microsoft.com/scripting/understanding-the-six-Powershell-profiles/).

| Aktueller Benutzer, aktueller Host – Konsole | $Home\[My ]Documents\WindowsPowershell\Profile.ps1
| Alle Benutzer, aktueller Host – Konsole | $PsHome\Microsoft.Powershell_profile.ps1

4. Bash → PowerShell

| Bash                          | PowerShell                                                           |
| ----------------------------- | -------------------------------------------------------------------- |
| ls -ltr                       | Get-ChildItem . \| Sort-Object -Property LastWriteTime               |
| find . -type f -iname "azure" | Get-ChildItem -Filter "_azure_" -Recurse -File                       |
| cp -R Tools ~/                | Copy-Item '.\Tools\' $env:USERPROFILE -Recurse                       |
| mkdir                         | New-Item -ItemType Directory -Name 'NewFolder'                       |
| touch{1..4}                   | 1..4 \| ForEach-Object { New-Item -ItemType File -Name "MyFile$\_" } |
| tail -n7 ./MyFile1            | Get-Content -Tail 7 .\MyFile1                                        |
| tail -f ./MyFile1             | Get-Content -Wait .\MyFile1                                          |
| grep                          | where-object and select-string -pattern                              |
| Ausgabe umleiten              | \*>&1 > log.txt                                                      |

5. Umgebung

- Umgebung auflisten `Get-ChildItem Env:s`
- Env für aktuelle Sitzung anzeigen `Get-ChildItem Env:*path* | format-list` oder `$env:path`
- Env für aktuelle Sitzung setzen `$env:myX = "alice"` oder `$env:path = $env:path + ";C:\Program Files (x86)\app\bin"`
- Env für aktuelle Sitzung entfernen `Remove-Item env:myX`
- Permanente Env-Variable anzeigen `[environment]::GetEnvironmentVariable("myY", "[User|Process|Machine]")`
- Permanente Env-Variable erstellen `[Environment]::SetEnvironmentVariable("myY", "la la", "User")`
- Permanente Env-Variable entfernen `[Environment]::SetEnvironmentVariable("myY", $null, "User")`

#### PowerShell-Erweiterungen

[PSReadLine](https://github.com/lzybkr/PSReadLine) installieren (optional als aktueller Benutzer, wenn keine Admin-Rechte vorhanden sind). PSReadLine bietet mehrere aus Bash bekannte Features wie eine Verlaufssuche, Rückgängig/Wiederherstellen und mehr.

```powershell
Install-Module [-Scope CurrentUser] PSReadLine
```

`Import-Module PSReadLine` zu `C:\Users\<benutzer>\Documents\WindowsPowershell\Microsoft.PowerShell_profile.ps1` hinzufügen (Datei erstellen, wenn nicht vorhanden), um das Modul beim PowerShell-Start automatisch zu laden.

Emacs-Tastenbelegung setzen, um gängige Bash-Tastenkombinationen zu nutzen, z. B. `Ctrl+a` zum Springen an den Anfang der Zeile:

```powershell
Set-PSReadlineOption -EditMode Emacs
```

Verlaufssuche vorwärts/rückwärts mit Auto-Vervollständigung aktivieren:

```powershell
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
```

- [posh-git](https://github.com/dahlbyk/posh-git) für PowerShell-Git-Integration: `Install-Module posh-git` und `Import-Module posh-git` zum PowerShell-Profil hinzufügen
- [posh-docker](https://github.com/samneirinck/posh-docker) für Docker-Vervollständigung: `Install-Module posh-docker` und `Import-Module posh-docker` zum PowerShell-Profil hinzufügen

#### Aliase

Um persistente Aliase zu erstellen, die Datei `C:\Users\<benutzer>\Documents\WindowsPowershell\Microsoft.PowerShell_profile.ps1` erstellen (Ordner existiert möglicherweise nicht).

Möglicherweise muss die Ausführung von PowerShell-Skripten auf dem System erlaubt werden: `Set-ExecutionPolicy -Scope CurrentUser BYPASS`
{{< alert >}}
Sicherheitsrichtlinien im Hinterkopf behalten
{{< /alert >}}

```powershell
function f_workspace {Set-Location "C:\Users\<benutzer>\Documents\workspace"}
Set-Alias workspace f_workspace
function f_up {docker-compose.exe up }
Set-Alias dup f_up
function f_images {docker images}
Set-Alias di f_images
function f_ps {docker ps}
Set-Alias dps f_ps
function f_dexec {docker exec -it}
Set-Alias dexec f_dexec
```

## VM + SSH-Client

Voraussetzungen:

- Ein installierter Hypervisor. Ich bevorzuge [VirtualBox](https://www.virtualbox.org/). Alternativ [VMware Workstation](https://www.vmware.com/de/products/workstation-player.html) verwenden.
- Ein SSH-Client. Ich bevorzuge [MobaXterm](https://mobaxterm.mobatek.net/), aber [Putty](https://www.putty.org/) tut es ebenfalls.

| Vorteile                    | Nachteile                                        |
| --------------------------- | ------------------------------------------------ |
| Normales Linux              | Virtualisierungs-Overhead                        |
| Fast native Erfahrung       | Hardware-Passthrough könnte ein Problem sein     |
| Gemeinsame Ordner           | Keine GUI (zumindest im Headless-Modus)          |

## WSL

Voraussetzungen:

- [WSL aktivieren/installieren](https://docs.microsoft.com/de-de/windows/wsl/install-win10)
- Eine Linux-Distribution auswählen und installieren. Derzeit stehen Ubuntu, OpenSUSE, SLES, Kali Linux oder Debian GNU/Linux zur Verfügung. Für die einfachste Nutzung empfehle ich Ubuntu.
- [Bonus](https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/)

Grundsätzlich wie Linux konfigurieren: zsh installieren, Dotfiles klonen, Tools wie ripgrep, fzf usw. installieren. WSL ist generell dazu gedacht, auf Linux-Toolchains zuzugreifen, nicht für Server- oder GUI-Anwendungen (obwohl möglich). Auch zu beachten: Mögliche Probleme aufgrund von Unterschieden in den Dateisystemen von Windows und Linux.

| Vorteile                    | Nachteile                                      |
| --------------------------- | ---------------------------------------------- |
| Einfache Einrichtung        | Benötigt Admin-Rechte                          |
| Nah an nativem Linux        | Nicht alle Distributionen verfügbar            |
| Eigene Linux-Konfiguration funktioniert | Kann langsam sein (Emulation)      |

## PowerShell

Voraussetzungen:

- PowerShell 4+

| Vorteile               | Nachteile                                    |
| ---------------------- | -------------------------------------------- |
| Nativ                  | Nicht Bash                                   |
| Objektorientiert       | Umständliche Befehle, wenn man von Linux kommt |
| In Windows integriert  | Fehlende Tools                               |

## Linux-GUI-Anwendungen in Windows starten

Linux-GUI-Anwendungen benötigen in der Regel einen laufenden [X-Server](https://en.wikipedia.org/wiki/X_Window_System), um ihr Fenster anzuzeigen. Es kann eine X-Server-Implementierung für Windows wie [Xming](https://sourceforge.net/projects/xming/) heruntergeladen werden. Nach der Installation und dem Start des X-Servers auf der Windows-Maschine einfach `export DISPLAY=:0` in der WSL eingeben. Jetzt können GUI-Anwendungen innerhalb dieser WSL-Shell gestartet werden.

[^1]: Linux bezieht sich auf ein Linux-basiertes Betriebssystem wie Ubuntu, Arch, Debian.

[^2]: Oder CLI, Konsole, Terminal, wie auch immer man es nennen möchte.

[^3]: WSL ist nur auf Windows 10 64-Bit-Systemen verfügbar.
