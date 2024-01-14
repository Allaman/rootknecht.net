---
title: Thinkpad Stories
summary: Some shenanigans with ThinkPads
description: thinkpad, diy
date: 2020-02-06
tags:
  - diy
  - hardware
---

I ❤️ Thinkpads. Here you can read about some of my stories with them 🙂

## Two x60 getting one

The x60 is the last thinkpad model with the IBM branding so I had to get one. Unfortunately, there was only a model with a Intel Core Duo processor with a 32-bit architecture. That's a drawback due to the fact that most modern Linux distributions dropped i386 support which complicates my idea of operating the x60 as a daily driver alternative to my x230.

Luckily, a co-worker sold me a x60 tablet model running a Intel Core **2** Duo processor with a 64-bit architecture. My plan was to replace the motherboard of my x60 with the x60 tablet edition's motherboard. The tablet version itself was not appealing to me.

- Side to side comparison. On the left side the x60 and on the right side the x60 tablet! Pay attention to the form factor of the fan unit. Luckily, the x60 tablet's unit is smaller than the x60's. The x60's unit won't fit into the tablet's case without further modding.

  {{< figure src=sidetoside.jpg caption="Side to side" >}}

- Closer view of the x60

  {{< figure src=x60.jpg caption="x60 (non tablet)" >}}

- Closer view of the x60 tablet

  {{< figure src=tablet.jpg caption="x60 tablet" >}}

- Disassembled x60

  {{< figure src=disassembled-x60.jpg caption="The disassembled x60" >}}

- Working x60 with the tablet's motherboard

  {{< figure src=workingx60.jpg caption="The final x60" >}}

## Backing a motherboard

Stupid enough, my x100e did not survive compiling the gentoo kernel. After a crash it did not boot up just burstig the fan with a blinking cursor. After a lot of research and testing it turned out that some soldered points of the onboard graphics chips were melted. I was quite desperately and tried something really insane: _Putting the motherboard in a oven!_

- Disassembled x100e

  {{< figure src=disassembledx100.jpg caption="The disassembled x100" >}}

- The motherboard

  {{< figure src=motherboard.jpg caption="The x100 motherboard" >}}

- Wrapped into alloy and put into the oven for 10 minutes at 180 degrees celsius circulating air

  {{< figure src=oven.jpg caption="The motherboard baking in the oven" >}}

_After reassembling the unit was working fine!_

## Replacing x230 keyboard

Unfortunately, my x230 was the first model with the new chiclet style keyboard which is still very good in comparison to other brands but the classic x220 keyboard was far more comfortable in my opinion. Luckily Thinkpads of this era could be easily disambled and parts swapped out.

I stumbled over a nice tutorial on [install a classic keyboard on a xx30 series thinkpad](http://www.thinkwiki.org/wiki/Install_Classic_Keyboard_on_xx30_Series_ThinkPads).

I ordered the following parts at ebay:

- Lenovo **45N2153** Tastatur Deutsch für Thinkpad T410 T420 T510 T520 W510 W520 for 60 Euros
- Lenovo Thinkpad X220 X220i X220s Palmrest Plastic Cover **04W1410 H44** (with fingerprint cut out) for 16 Euros

{{< alert >}}
Be aware that the classic keyboard does not have the backlight feature
{{< /alert >}}

- Original keyboard

  {{< figure src=original.jpg caption="The original keyboard" >}}

- Disassembled device

  {{< figure src=disassembled.jpg caption="The disassembled device" >}}

- Palmrest comparison. Note the different layout which we must fix

  {{< figure src=palmrests.jpg caption="Palmrests next to each other" >}}

- Palmrest fix

  {{< figure src=fixed_palmrest.jpg caption="The fixed palmrest" >}}

- Original fingerprint plate not fitting

  {{< figure src=fingerprint-plate.jpg caption="The fingerprint plate" >}}

- Glued fingerprint module

  {{< figure src=glued.jpg caption="The glued board" >}}

- Cut plate

  {{< figure src=cut.jpg caption="The cut plate" >}}

- Final result

  {{< figure src=final.jpg caption="The final result" >}}

## Dbranding my Lenovo X1 Carbon

I am a huge fan of [dbrand](https://dbrand.com). They offer extreme nice looking and perfectly fitting skins for various devices. All my Galaxy Devices had them applied and I thought it was about time to give my X1 Carbon a new look. here is the result

{{< figure src=front.jpg caption="The front skin" >}}

{{< figure src=bottom.jpg caption="The bottom skin" >}}

{{< figure src=open.jpg caption="The inner skin" >}}
