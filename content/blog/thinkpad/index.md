---
title: Thinkpad Stories
type: posts
date: 2020-02-06
tags:
  - DIY
  - hardware
resources:
  - name: head
    src: "head.jpg"
  - name: bottom
    src: "bottom.jpg"
    title: The bottom skin
  - name: cut
    src: "cut.jpg"
    title: The cut plate
  - name: disassembled-x60
    src: "disassembled-x60.jpg"
    title: The disassembled x60
  - name: disassembled
    src: "disassembled.jpg"
    title: The disassembled device
  - name: disassembledx100
    src: "disassembledx100.jpg"
    title: The disassembled x100
  - name: final
    src: "final.jpg"
    title: The final result
  - name: fingerprint-plate
    src: "fingerprint-plate.jpg"
    title: The fingerprint plate
  - name: fixed_palmrest
    src: "fixed_palmrest.jpg"
    title: The fixed palmrest
  - name: front
    src: "front.jpg"
    title: The front skin
  - name: glued
    src: "glued.jpg"
    title: The glued board
  - name: motherboard
    src: "motherboard.jpg"
    title: The x100 motherboard
  - name: open
    src: "open.jpg"
    title: The inner skin
  - name: original
    src: "original.jpg"
    title: The original keyboard
  - name: oven
    src: "oven.jpg"
    title: The motherboard baking in the oven
  - name: palmrests
    src: "palmrests.jpg"
    title: Palmrests next to each other
  - name: sidetoside
    src: "sidetoside.jpg"
    title: Side to side
  - name: tablet
    src: "tablet.jpg"
    title: x60 tablet
  - name: workingx60
    src: "workingx60.jpg"
    title: The final x60
  - name: x60
    src: "x60.jpg"
    title: x60 (non tablet)
---

I ❤️ Thinkpads. Here you can read about some of my stories with them 🙂

<!--more-->

{{< img name=head lazy=false description=false >}}

{{< toc >}}

## Two x60 getting one

The x60 is the last thinkpad model with the IBM branding so I had to get one. Unfortunately, there was only a model with a Intel Core Duo processor with a 32-bit architecture. That's a drawback due to the fact that most modern Linux distributions dropped i386 support which complicates my idea of operating the x60 as a daily driver alternative to my x230.

Luckily, a co-worker sold me a x60 tablet model running a Intel Core **2** Duo processor with a 64-bit architecture. My plan was to replace the motherboard of my x60 with the x60 tablet edition's motherboard. The tablet version itself was not appealing to me.

- Side to side comparison. On the left side the x60 and on the right side the x60 tablet! Pay attention to the form factor of the fan unit. Luckily, the x60 tablet's unit is smaller than the x60's. The x60's unit won't fit into the tablet's case without further modding.

  {{< img name="sidetoside" lazy=true >}}

- Closer view of the x60

  {{< img name="x60" lazy=true >}}

- Closer view of the x60 tablet

  {{< img name="tablet" lazy=true >}}

- Disassembled x60

  {{< img name="disassembled-x60" lazy=true >}}

- Working x60 with the tablet's motherboard

  {{< img name="workingx60" lazy=true >}}

## Backing a motherboard

Stupid enough, my x100e did not survive compiling the gentoo kernel. After a crash it did not boot up just burstig the fan with a blinking cursor. After a lot of research and testing it turned out that some soldered points of the onboard graphics chips were melted. I was quite desperately and tried something really insane: _Putting the motherboard in a oven!_

- Disassembled x100e

  {{< img name="disassembledx100" lazy=true >}}

- The motherboard

  {{< img name="motherboard" lazy=true >}}

- Wrapped into alloy and put into the oven for 10 minutes at 180 degrees celsius circulating air

  {{< img name="oven" lazy=true >}}

_After reassembling the unit was working fine!_

## Replacing x230 keyboard

Unfortunately, my x230 was the first model with the new chiclet style keyboard which is still very good in comparison to other brands but the classic x220 keyboard was far more comfortable in my opinion. Luckily Thinkpads of this era could be easily disambled and parts swapped out.

I stumbled over a nice tutorial on [install a classic keyboard on a xx30 series thinkpad](http://www.thinkwiki.org/wiki/Install_Classic_Keyboard_on_xx30_Series_ThinkPads).

I ordered the following parts at ebay:

- Lenovo **45N2153** Tastatur Deutsch für Thinkpad T410 T420 T510 T520 W510 W520 for 60 Euros
- Lenovo Thinkpad X220 X220i X220s Palmrest Plastic Cover **04W1410 H44** (with fingerprint cut out) for 16 Euros

{{< hint warning >}}
Be aware that the classic keyboard does not have the backlight feature
{{< /hint >}}

- Original keyboard

  {{< img name="original" lazy=true >}}

- Disassembled device

  {{< img name="disassembled" lazy=true >}}

- Palmrest comparison. Note the different layout which we must fix

  {{< img name="palmrests" lazy=true >}}

- Palmrest fix

  {{< img name="fixed_palmrest" lazy=true >}}

- Original fingerprint plate not fitting

  {{< img name="fingerprint-plate" lazy=true >}}

- Glued fingerprint module

  {{< img name="glued" lazy=true >}}

- Cut plate

  {{< img name="cut" lazy=true >}}

- Final result

  {{< img name="final" lazy=true >}}

## Dbranding my Lenovo X1 Carbon

I am a huge fan of [dbrand](https://dbrand.com). They offer extreme nice looking and perfectly fitting skins for various devices. All my Galaxy Devices had them applied and I thought it was about time to give my X1 Carbon a new look. here is the result

{{< img name="front" lazy=true >}}

{{< img name="bottom" lazy=true >}}

{{< img name="open" lazy=true >}}
