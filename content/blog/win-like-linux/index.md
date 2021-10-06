---
title: "Make Windows 10 more Linux like"
type: posts
date: 2020-01-22
tags:
  - workflow
  - configuration
---

Trying to make Windows work as a Linux user.

<!--more-->

{{< toc >}}

## Motivation

I am a Linux[^1] user for over a decade and my workflow and productivity is optimized to this environment especially the shell[^2]. For some insights of my workflow and tools have a look at [here](https://knowledge.rootknecht.net/linux-productivity). From time to time my work demands from me to work on a Windows machine despite the fact that in my kind of business, Infrastructure and DevOps, the majority of systems and tools is Linux driven.

Now the question is how to get the best Linux like experience on a Windows 10[^3] machine specifically how to get the best shell experience and the tools that I am used to.

I want to describe some Windows tweaks and three ways of getting a more Linux like experience on your Windows 10 machine as follows:

1. A combination of a virtual machine running Linux and a local SSH client
2. The Windows Subsystem for Linux basically a compatibility layer for running linux binaries (ELF)
3. Tweak and enhance the Powershell

## Built-in Windows Tools

Windows 10 finally has built-in functionality that is available on Linux since my beginning: **virtual desktops** and a **clipboard manager**!

You can access the clipboard manager by pressing `Win + v`. Although it is not as powerful as some Linux managers it is a start. Also have a look at [ditto](https://ditto-cp.sourceforge.io/) for a replacement.

Virtual desktops are crucial for my workflow! I use them to structure my apps and keep my applications organized on different desktops. Unfortunatley, the shortcuts for interacting with virtual desktops are not customizable out of the box. [Virtual Desktop Enhancer](https://github.com/sdias/win-10-virtual-desktop-enhancer) fills the gap and allows me to create more "home row friendly" shortcuts.

## Software

Generally speaking, I always prefer cross-platform software to be able to have an as much as possible unified user experience across different platforms. That said have a look at my [CLI Applications](https://knowledge.rootknecht.net/cli-applications) and [GUI Applications](https://knowledge.rootknecht.net/gui-applications) summaries. Particularly, most of the GUI applications I am running are cross platform capable. Nevertheless, find some useful Windows applications that are not necessary useful or available on Linux systems:

- [ConEmu](https://conemu.github.io/) - An enhanced terminal featuring tabs, Guake drop down style, various different shells and much customization options
- [Terminus](https://github.com/Eugeny/terminus) - Alternative to ConEmu, configurable, includes patched fonts, integrated SSH client, Powershell, WSL, CMD and more
- [MobaXterm](https://mobaxterm.mobatek.net/) - A fully featured SSH, FTP, RDP and more client with session management, tunneling, its own shell and more
- [Autohotkey](https://www.autohotkey.com/) - An open source Windows scripting tool for automation and key binding settings for instance mapping ESC to CAPS.
- [Virtual Desktop Enhancer](https://github.com/sdias/win-10-virtual-desktop-enhancer) - Customizing shortcuts for built-in virtual desktops
- [ditto](https://ditto-cp.sourceforge.io/) - A free clipboard manager for those that want more customization than the built-in one offers
- [PowerToys](https://github.com/microsoft/PowerToys) - Tools from Microsoft for power users
- [WinFile](https://github.com/microsoft/winfile) - Original Microsoft Windows file manager (very fast, no special folders)

### Autohotkey

To automatically start an AHK script simply add [capstoesc.ahk](capstoesc.ahk) to your Windows startup folder (`Win+r -> shell:startup`)

### Powershell

Good [guide](https://gist.github.com/jchandra74/5b0c94385175c7a8d1cb39bc5157365e) to customize and bring color into Powershell

1. Generate new default profile for Powershell

```powershell
new-item $profile -itemtype file -force
```

2. Edit profile

```powershell
ise $PROFILE
```

3. Different profiles

There are six [different profiles](https://devblogs.microsoft.com/scripting/understanding-the-six-Powershell-profiles/)

| Current User, Current Host – console | $Home\[My ]Documents\WindowsPowershell\Profile.ps1
| All Users, Current Host – console | $PsHome\Microsoft.Powershell_profile.ps1

4. Bash -> Powershell

| Bash                          | Powershell                                                           |
| ----------------------------- | -------------------------------------------------------------------- |
| ls -ltr                       | Get-ChildItem . \| Sort-Object -Property LastWriteTime               |
| find . -type f -iname "azure" | Get-ChildItem -Filter "_azure_" -Recurse -File                       |
| cp -R Tools ~/                | Copy-Item '.\Tools\' $env:USERPROFILE -Recurse                       |
| mkdir                         | New-Item -ItemType Directory -Name ‘NewFolder’                       |
| touch{1..4}                   | 1..4 \| ForEach-Object { New-Item -ItemType File -Name "MyFile$\_" } |
| tail -n7 ./MyFile1            | Get-Content -Tail 7 .\MyFile1                                        |
| tail -f ./MyFile1             | Get-Content -Wait .\MyFile1                                          |
| grep                          | where-object and select-string -pattern                              |
| redirect output               | \*>&1 > log.txt                                                      |

5. Environment

- List environment `Get-ChildItem Env:s`
- See Env for current session `Get-ChildItem Env:*path* | format-list` or `$env:path`
- Set env for current session `$env:myX = "alice"` or `$env:path = $env:path + ";C:\Program Files (x86)\app\bin"`
- Remove env for current session `Remove-Item env:myX`
- See Permanent Env variable `[environment]::GetEnvironmentVariable("myY", "[User|Process|Machine]")`
- Create permanent Env variable `[Environment]::SetEnvironmentVariable("myY", "la la", "User")`
- Removing Permanent Env variable `[Environment]::SetEnvironmentVariable("myY", $null, "User")`

#### Powershell extensions

Install [PSReadLine](https://github.com/lzybkr/PSReadLine) (optionally as current user if you are lacking admin rights). PSReadLine provides several features which are known from bash like a history search, undo/redo, and more.

```powershell
Install-Module [-Scope CurrentUser] PSReadLine
```

Add `Import-Module PSReadLine` to `C:\Users\<user>\Documents\WindowsPowershell\Microsoft.PowerShell_profile.ps1` (create file if necessary) to autoload the module upon Powershell start.

Set keybinding to Emacs to use common bash key combos, e.g. `ctrl+a` for jumping to the beginning of the line

```powershell
Set-PSReadlineOption -EditMode Emacs
```

Enable history search forward/backward auto-completion with

```powershell
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
```

- [posh-git](https://github.com/dahlbyk/posh-git) for Powershell Git integration: Install-Module posh-git `Import-Module posh-git`to your Powershell Profile
- [posh-docker](https://github.com/samneirinck/posh-docker) for Docker completion: Install-Module posh-docker and add `Import-Module posh-docker` to your Powershell Profile

#### Aliase

To create persistent aliases create the file `C:\Users\<user>\Documents\WindowsPowershell\Microsoft.PowerShell_profile.ps1` (folder might not exist).

You might have to allow the execution of Powershell scripts on your system: `Set-ExecutionPolicy -Scope CurrentUser BYPASS`
{{< hint warning >}}
keep security policies in mind
{{< /hint >}}

```powershell
function f_workspace {Set-Location "C:\Users\<user>\Documents\workspace"}
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

## VM + SSH Client

Requirements:

- A hypervisor installed. I prefer [VirtualBox](https://www.virtualbox.org/). Alternatively, use [VMware Workstation](https://www.vmware.com/de/products/workstation-player.html)
- A ssh client. I prefer [MobaXterm](https://mobaxterm.mobatek.net/) but [Putty](https://www.putty.org/) will get the job done as well

| Pros                       | Cons                                    |
| -------------------------- | --------------------------------------- |
| normal Linux               | virtualisation overhead                 |
| close to native experience | hardware pass through might be an issue |
| shared folders             | no GUI (at least in headless mode)      |

## WSL

Requirements:

- [Enable/Install WSL](https://docs.microsoft.com/de-de/windows/wsl/install-win10)
- Choose and install a Linux distribution from. As of now the choice is Ubuntu, OpenSUSE, SLES, Kali Linux, or Debian GNU/Linux. I prefer Ubuntu for the easiest usage
- [Bonus](https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/]

Basically, configure it like your Linux. Install zsh, clone your dotfiles, install tools like ripgrep, fzf, etc. Generally speaking WSL is intended to be used to access Linux toolchain and not for server or GUI applications (altough possible). Also keep in mind that there might be issues due to differences in both, Windows' and Linux' filessystems.

| Pros                    | Cons                            |
| ----------------------- | ------------------------------- |
| Easy Setup              | Needs admin rights              |
| Close to native Linux   | Not all distributions available |
| Your Linux config works | Can be slow (emulation)         |

## Powershell

Requirements:

- Powershell 4+

| Pros                  | Cons                               |
| --------------------- | ---------------------------------- |
| native                | not Bash                           |
| object oriented       | awkward commands coming from Linux |
| Integrated in Windows | missing tools                      |

## Start Linux GUI Applications in Winodws

Linux GUI applications usually require a running [X Server](https://en.wikipedia.org/wiki/X_Window_System) in order to display their window. You can dowload some X server implementation for Winodws like [Xming](https://sourceforge.net/projects/xming/). After installing and starting the x server on your Windows machine you just enter `export DISPLAY=:0` in your WSL. Now you can launch GUI applications within this WSL shell.

[^1]: Linux is referred to as an Linux based operations system like Ubuntu, Arch, Debian
[^2]: or CLI, console, terminal, you name it
[^3]: WSL is only available on Windows 10 64bit systems
