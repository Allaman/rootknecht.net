---
title: Moving from Linux to macOS
type: posts
draft: false
date: 2021-12-30
tags:
  - business
  - configuration
  - hardware
  - workflow
resources:
  - name: head
    src: apple.png
  - name: fan
    src: fan.png
    title: CPU frequency, utilization, temperature, and fan speed
  - name: terminal
    src: terminal.png
    title: Iterm2, Tmux, Neovim, Neofetch
---

In my last [workplace](/blog/my-workplace-2021) setup blog post, I described my setup centered around my Lenovo X1 Carbon Gen 9 running Manjaro Linux and why I prefer Lenovo laptops over all other manufactures. I admit, you could call me a Lenovo fanboy. In this post, I will explain why I switched from Lenovo laptops running Linux for over a decade to the "arch enemy" macOS.

<!--more-->

{{< hint info >}}
There is an update to this post: [One year with macOS](/blog/one-year-mac)
{{< /hint >}}

{{< hint info >}}
2024-01-07: After two years, Lenovo finally released a firmware which fixes the fan behaviour. Thanks to [u/ElRamenKnight of Reddit](https://reddit.com/r/thinkpad/comments/18vjdb6/x1_carbon_gen9_latest_update_omg_they_finally/). I can confirm that with this patch the fan won't fire up when the system is practically idle. This is how the notebook should be at launch!
{{< /hint >}}

{{< img name=head lazy=false description=false size=small >}}

{{< toc >}}

{{< hint info >}}
No brand or company is sponsoring/paying me. This is my personal opinion and experience, your mileage may vary.
{{< /hint >}}

## Why

In this chapter, I describe the reasons behind my switch to macOS and what I expect from running macOS.

### Issues with my ThinkPad

As described in my last [workplace](/blog/my-workplace-2021) post, there are three main reasons for my former setup:

- Linux[^1] is from my point of view the better operating system because it gives me the freedom to fully (re)configure the way how I interact with my laptop
- Lenovo's Linux support was always outstanding and with no or only minor issues. All hardware components usually work out of the box.
- The keyboard and the TrackPoint was always superior in my mind. I was so comfortable using the TrackPoint that I was almost as fast as with an external mouse.

There were some issues with my X1 Carbon (X1C) right from the beginning (shameless copy / paste from my previous post):

1. You MUST upgrade your firmware. Earlier firmware versions are affected by heavy throttling, making the system unresponsive ([Lenovo Forum](https://forums.lenovo.com/topic/view/1301/5073083)).
2. While being connected to my monitor via USB-C, a wake-up after suspension resulted in a full load on one core, although no process was using that much CPU. It turned out that `Linux S3` mode was the issue. After switching to `Windows and Linux` (s0ix or connected standby) in the BIOS settings, this issue was resolved. Apparently, Intel [dropped S3 support](https://www.reddit.com/r/System76/comments/k7xrtz/ill_have_whatever_intel_was_smoking_when_they/) for Tiger Lake CPUs.

After solving both issues, the only one left was a [buzzing sound](https://forums.lenovo.com/t5/ThinkPad-X-Series-Laptops/X1-Carbon-Gen-9-Buzzing-sound-upper-left-of-laptop/m-p/5082574?page=1) from the upper left corner. Although my X1C is also impacted by this behavior, this was not a dealbreaker for me. It was almost inaudible, and my hope was that it is not a critical problem with the potential of damaging the hardware.

Unfortunately, a new issue raised. The most annoying thing with my X1C was the unpredictable and not justifiable fan behavior. The fans often spin up when no system load at all was present or after waking up from standby. I spent hours and hours troubleshooting this weird behavior and came to no solution. For me, this is a big deal because firstly I am easily distracted by fan noise and second I lose faith in the hardware. The following picture shows a screenshot of [s-tui](https://github.com/amanusk/s-tui). You can see that the fan is spinning at the maximum of ~6700 rounds per minute (bluish chart) while all other metrics are barely waving.

{{< img name=fan lazy=true size=small >}}

Although I spent money for extended guarantee and on-site service, I was not willing to invest more of my valuable time into dealing with issues of a premium business device. This also includes not to install Windows because I need to get things done and make money. Furthermore, if this behavior will not occur with Windows, what should I do then? I am used to running Linux for years and Windows has for sure its own flaws.

From a software point of view, everything was running well. [Manjaro](https://manjaro.org/), despite originating from Arch Linux, is a very mature and stable distribution while offering a rolling release experience and packages for almost every software you can imagine. This was the reason why I kept troubleshooting and hoped to solve my issue, as I was highly productive with setup.

Furthermore, I owned several ThinkPads (x61, x220, x230, X1C6) over the last decade and each of them was a faithful companion.

Last but not least, without my switch to Linux from Windows back in the days, my career wouldn't look the same. My Linux knowledge was always a key skill and for sure an advantage for me and employers. As you might guess, a little of nostalgia played a role during my thoughts as well.

Nevertheless, I decided to make the huge step and ordered a MacBook Pro (MBP) and here is why.

### Reasons for Mac

- macOS is built upon **FreeBSD** and can fulfill a \*nix based workflow.
- You can say what you want about Apple, but their stuff usually **just works**. I cannot justify spending hours and hours in troubleshooting and tinkering anymore. During my studies I installed a new custom ROM on my Android devices each week or ran Arch Linux testing which caused a broken system almost after each update. Those times are gone, and now I need a system that is easy to maintain and that enables me to be productive while still give me some freedom for my own workflows.
- Basically, my computer is just a host for a **browser** (Firefox) and a **terminal**. Those two applications can fulfill 95% of my use cases. The latter is also the reason why Windows is not an option for me. I am sure that you can do some serious work with PowerShell and the object-oriented approach is quite appealing, but I am just too used to (full) Bash and Linux terminals.
- The **Hardware** of the 2021 MacBook is a masterpiece in both aesthetic and function. I really like the flat, rough, and sharp design. In general, I don't like the curvy design of many tech over the last years and I appreciate Apple's move back to a more flat design language as they have done it with the iPhone 12. Besides design, the most notable hardware elements are the 14-inch screen, which is in my opinion the sweet spot in terms of mobility and productivity, the small bezels (finally), the return of dedicated function keys, and the addition of more ports.
- I must admit: I was very curious about **Apple silicone** and its performance and optimizations since the launch. Now (2021) with the second iteration I am even more curious. 😆
- A MBP would **fit well** besides my iPhone and iPad, although I disabled iCloud synchronization on all my devices and don't rely on Apple's cloud service. AirDrop on its own would be a nice addition.

### Concerns about Mac

That being said, there were also a couple of concerns about switching to Mac:

- The Apple **keyboard layout**: My muscle memory is used to the classic PC keyboard layout, and I was afraid of the weird command key and the lack of dedicated page up/down, HOME/END, DELETE/INSERT, and PRINT keys. This might be a minor issue because most of the time I can work with an external keyboard attached. Nevertheless, I want to be able to be productive with just the laptop as well.
- The **macOS window manager** and its lack of capabilities: My workflow is very keyboard centric and involves managing applications and virtual desktops with custom shortcuts.
- Incompatibility with the **Apple Silicon architecture** of some required apps and tools.
- I was afraid of not being able to jump off the Apple train once **locked in** 😆

Read more about those concerns and how I deal with them, as well as other issues in [The bad](#the-bad) and [The ugly](#the-ugly)

### Expectations

My expectations from a switch to macOS and Apple hardware were as follows:

- A rock solid and **stable** user experience that does not need any attention from my side.
- No need for dealing with **OS components and settings** like Kernel stuff, fan control, tlp, graphics, modules/drivers, etc.
- Everything just **works out of the box**, especially within the Apple ecosystem (iPad, AirPods, ...).
- An absolutely **quiet** system with no to very minimal fan noise.
- A Linux like **terminal experience** and workflow with all my various CLI/TUI applications.
- Although I appreciate [ricing](https://www.reddit.com/r/unixporn/comments/3iy3wd/stupid_question_what_is_ricing/) I also require a system that enables me to **reliably** do my business but still can be customized to a certain degree.

Finally, in the next section, I briefly describe my migration path. 🤓

## Migrating from Linux to Mac

{{< img name=terminal lazy=true size=small >}}

After researching for experience others made with such a switch and not finding too much I decided to give it a shot and write down my experience. My excuse was that Apple hardware does not lose value and I can always sell the MBP after the 14 days refund policy.

I ordered a MacBook Pro 14 inch with the following specs:

- M1 Pro 10-Core
- 32 GB RAM
- 1TB storage

At first, I was tempted to max out and go for the M1 Max with 64 GB RAM. After viewing some reviews and comparisons, I came to the conclusion that I would never need that much power and additionally would potentially lose battery life. The RAM and the storage are equal to my X1C so I feel like this was a good choice.

Honestly, I was surprised about the migration and how smooth it was. But first things first. Usually, there are two categories for such a migration task:

1. Data (documents, images, ...)
2. Apps and configurations

The migration of my data was straight forward. I copied the top level data folders from my old home directory to the Home directory of the Mac. I ignored the special folders of macOS like `Documents`, `Pictures`, etc. because I prefer to keep my own structure as illustrated in the following snippet.

```sh
.
├── 100_FUJI
├── Downloads
├── data
├── media
├── business
└── workspace
```

For migrating applications, I must distinguish between terminal apps and GUI apps. For the latter ones, there usually exist more alternative apps in the macOS ecosystem. The following table shows my former GUI apps and their replacement on my MBP.

{{< hint info >}}
My message here is not to say that the Linux apps are worse than their counterparts. Every app does have its strengths and weaknesses!
{{< /hint >}}

| Type            | Linux                                                                     | macOS                                                                          |
| --------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Photo editing   | [Gimp](https://www.gimp.org/)                                             | [Affinity Photo](https://affinity.serif.com/en-gb/photo/) (on my iPad as well) |
| Vector graphics | [Inkscape](https://inkscape.org/)                                         | [Vectornator](https://www.vectornator.io/) (on my iPad as well)                |
| Document viewer | [Zathura](https://pwmt.org/projects/zathura/)                             | [Preview](https://support.apple.com/en-mn/guide/preview/welcome/mac)           |
| Terminal        | [Alacritty](https://github.com/alacritty/alacritty) (no native build)     | [iTerm2](https://iterm2.com/)                                                  |
| Screenshot      | [Flameshot](https://github.com/flameshot-org/flameshot) (no native build) | [Xnip}(http://xnipapp.com/)]                                                   |

The following list shows all applications that I will continue to run on macOS:

| Type                    | App                                                                                                                                                            |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Web browser             | [Firefox](https://www.mozilla.org/en-US/firefox/new/) (main), [Chromium](https://www.chromium.org/) (backup); I copied the complete profile folders from Linux |
| Synchronization         | [Syncthing](https://syncthing.net/)                                                                                                                            |
| IDE                     | [Jetbrains Suite](https://www.jetbrains.com/) (backup for my Neovim ➡️ [config](https://github.com/Allaman/nvim/))                                             |
| Proxy/web inspection    | [Burp](https://portswigger.net/burp/documentation/desktop/tools/proxy)                                                                                         |
| Password manager        | [KeePassXC](https://keepassxc.org/)                                                                                                                            |
| Office suite            | [Libreoffice](https://www.libreoffice.org/)                                                                                                                    |
| API testing/exploration | [Postman](https://www.postman.com/)                                                                                                                            |
| Ebook management        | [calibre](https://calibre-ebook.com/) (not yet installed due to the lack of a native package)                                                                  |

The migration of my CLI/TUI apps was very flawless, thanks to [Homebrew](https://brew.sh/). Homebrew is a package manager for macOS but don't expect feature parity like pacman or aptitude. Almost every CLI/TUI app as well as many GUI applications can be installed via brew. I managed my configuration of my X1C with an Ansible playbook that you can find [here](https://github.com/Allaman/rice).

For my MBP, I wanted something similar and created a [repo](https://github.com/Allaman/mac-setup) that installs all my applications (with a few exceptions) and configures my zsh.

**Surprisingly, not only that 99% of my programs are available with Homebrew but also are available for Apple Silicon!**

Check [doesitarm](https://doesitarm.com/) if your program runs on ARM or Rosetta.

{{< hint info >}}
For now, I haven't enabled Apple's Rosetta emulation layer and I try to not do so! All programs do run natively!
{{< /hint >}}

## The good[^2]

What do I like? What does a MBP with macOS do better?

### Hardware

- NO FAN; I don't even know how it would sound.
- Very solid case and overall build quality. The new flat design is very appealing to me.
- I cannot say much about the display but that it feels smooth, bright and works for me. Most of the time I work with an external monitor while the laptop lid is closed.
- The new MBP comes with three USB-C, one MagSafe, one HDMI, one SD card, and one Headphone jack port. Especially, I missed the SD card slot in my X1C. Generally, the new ports make the MBP more capable of being used without dongles and adapters.
- Highly comfortable keyboard that beats the one of my X1C Gen 9. In my opinion Lenovo continued the IBM tradition of building the best laptop keyboards, so this was quite a surprise for me.
- The MBP has a superior Touchpad. Apple has a long tradition of building the best integrated Touchpads, so no surprise here.
- A very fast and reliable fingerprint sensor that works out of the box. To be honest, I've never tried getting fingerprint sensors to work on Linux.
- A very long lasting battery. I made no scientific tests, but I guess I can easily achieve 10-12 hours of usual work.
- No Bluetooth issues, paired devices just work.
- The integrated speakers are incredible. I can listen to music with them and I can enjoy it!
- All my peripherals work with my MBP.

### Software

- Polished and smooth UI.
- Instant sleep and wake up with no issues after resume.
- Everything feels a little snappier.
- No hassle with kernel modules and graphics card configuration and optimization
- My [NeoVim config](https://github.com/Allaman/nvim) works out of the box with macOS and iTerm2.
- My Ansible roles for [shell](https://github.com/Allaman/ansible-role-shell), [pip](https://github.com/Allaman/ansible-role-pip), and [binaries](https://github.com/Allaman/ansible-role-binaries) work out of the box and are used in my new [mac-setup](https://github.com/Allaman/mac-setup) playbook.
- Remapping CAPS to ESC is a built-in option of macOS and works flawlessly. On Linux I used a [xcape](https://github.com/alols/xcape) script which was regularly "overwritten" by udev and finally [keyd](https://github.com/rvaiya/keyd) which worked 95% of the time.
- Printer setup is very easy. No `cupsd` shenanigans.

## The bad

What do I dislike? What are the quirks of a MBP and macOS?

### Hardware

- The MBP is heavier at 1.6kg in contrast to the 1.1kg of the X1C and also bulkier with some sharp edges.
- There is no mechanical cover of the internal webcam.
- Only HDMI 2.0 (instead of 2.1).
- Only UHS-II SD card reader (instead of UHS-III).
- Missing USB-A port.
- Missing Ethernet port (like most of its competitors).
- THe internal keyboard is a fingerprint magnet.
- The notch divides opinions. For me, the notch is not disturbing at all.
- No middle mouse button as with my X1C's Trackpoint buttons for pasting from the selection clipboard (use [middleclick](https://rouge41.com/labs/) for emulating middle click with three finger tap)
- Scrolling with my Logitech MX vertical is not smooth and almost not usable. Furthermore, the back/forward keys do not work. I use [LinearMouse](https://linearmouse.org/) to solve both issues.
- No dedicated `PAGE-UP`, `PAGE-DOWN`, `END`, `HOME` Keys. I barely used those because of my Vim bindings everywhere.

### Software

- [alacritty](https://github.com/alacritty/alacritty) is not yet available as native ARM build (you could compile it yourself)
- `CMD-TAB` shows applications from all spaces and not just the active one (➡️ [alt-tab](https://alt-tab-macos.netlify.app/))
- `CMD-TAB` does not separate between different application windows (➡️[alt-tab](https://alt-tab-macos.netlify.app/))
- `CMD-q` closes windows, especially dangerous when trying to type `@` like on a PC keyboard (right CMD-q will also close). I use a [karabiner](https://karabiner-elements.pqrs.org/) modification that only quits applications when `CMD-q` is pressed twice.
- `Alt-.` must be configured or can be replaced by `ESC-.` (for inserting previous arguments in bash).
- Maximized windows are not really maximized, and the borders are disruptive, especially when grabbing a border by mistake instead of a scroll bar.
- Why does `RETURN` in finder rename a folder and not enter it?

## The ugly

What drives me crazy? 😆

### Hardware

- The keyboard layout. I am used to a standard PC keyboards since my first PC.
- Brackets: `OPT-5`: `[`, `OPT-6`: `]` and `OPT-8`: `{`, `OPT-9`: `}`
- Pipe: `OPT-7`: `|`
- Tilde: `OPT-n`: `~?` (conflicts with my tmux bindings)
- At: `OPT-l`: `@` (conflicts with my tmux bindings)
- With heavy use of [karabiner](https://karabiner-elements.pqrs.org/) modifications, I remapped all keys for a similar experience to a PC keyboard while using my external keyboard.
- Despite the excellent Touchpad, I miss the Trackpoint and its dedicated mouse buttons as those allowed me to keep my finger always on the home row.

### Software

- Lag after switching spaces ([article with video](https://piunikaweb.com/2021/12/14/macos-12-monterey-workspace-switching-animation-lag-with-promotion/)). Seriously Apple?
- LUKS encrypted external hard drive cannot be read by macOS (there is no workaround)
- [Calibre](https://calibre-ebook.com/) is not (yet) available as native package, and there is no alternative. Calibre runs with Rosetta well, but I don't want to enable the emulation layer.
- [ueberzug](https://github.com/seebye/ueberzug) depends on x11 and is not available (used for preview files in Terminal in conjunction with [lf](https://github.com/gokcehan/lf)). Till now, I came to no solution for this (special) setup.
- Missing `primary selection`across the OS. It is available in iTerm2. In Linux every text selected, no matter where, is copied to the clipboard and can be pasted with a mouse middle click.
- Why is there no `cut` in finder?

## Conclusion

Overall, I am very happy with my move to Apple/macOS. Most of my apps and workflows work in macOS. From this point of view, my switch is barely notable. I do have my Firefox with all settings and cache and extensions, a working and nice looking terminal with iTerm2, Tmux, Neovim, Neomutt, etc. What I perceive is a superior performance and absolutely no noise. The only thing that took some time was to install and adjust the configs of my (new) applications. There was no need to deal with Kernels, OS optimizations, Bluetooth, audio and so on.

Of course, this is not a long term review, as I own the MBP just a couple of weeks now. Stay tuned ([RSS](https://rootknecht.net/blog/index.xml), [Twitter](https://twitter.com/allamann)) for a more in-depth review with a focus on my daily tasks as a **DevOps/Cloud Engineer**.

Here is the [Reddit Discussion](https://www.reddit.com/r/MacOS/comments/ruhi3n/moving_to_macos_after_10_years_of_running_solely/)

[^1]: In this post, Linux is used as a synonym for all Linux based operating systems though technically, Linux is only the Kernel.
[^2]: All listings are in no particular order
