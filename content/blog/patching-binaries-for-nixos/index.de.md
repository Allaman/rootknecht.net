---
title: Binaries für NixOS patchen
summary: In diesem Blogbeitrag möchte ich einen Workaround beschreiben, wie heruntergeladene Binaries unter NixOS zum Laufen gebracht werden können.
description: nixos, konfiguration, linux
date: 2023-07-25
tags:
  - tools
  - nixos
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/patching-binaries-for-nixos/)
{{< /alert >}}

In meinem vorherigen Blogbeitrag [NixOS als Container-Host](/blog/nixos-as-host/) beschrieb ich meinen Ansatz, Container zu betreiben, aufgrund der Inkompatibilität einiger Binaries mit NixOS[^1].

Nach tieferem Eintauchen in die Welt von NixOS stieß ich auf eine NixOS-gemäßere Lösung für dieses Problem.

{{< alert >}}
Disclaimer: Ich bin ein NixOS-Neuling, und es gibt wahrscheinlich bessere Lösungen. Vergleiche auch [Binaries](https://nixos.wiki/wiki/Packaging/Binaries) im NixOS-Wiki.

Dieser Ansatz funktioniert jedoch für mich und beinhaltet vor allem keine fortgeschrittenen Dinge wie Packaging, Derivate usw.
{{< /alert >}}

## No such file or directory

Ich verlasse mich auf [Mason](https://github.com/williamboman/mason.nvim), um erforderliche Tools für meine [Neovim-Konfiguration](https://github.com/Allaman/nvim) herunterzuladen. Ein solches Tool ist `stylua`, das unter NixOS nicht funktioniert.

{{< figure src=error.png caption="Fehlermeldung beim Ausführen von stylua" >}}

Diese Fehlermeldung ist leider nicht sehr intuitiv. Die Datei existiert und ist ausführbar.

{{< figure src=ll.png caption="Die Datei existiert" >}}

Schauen wir uns die Ausgabe von `file` an:

{{< figure src=file.png caption="Sieht wie eine reguläre ausführbare Datei aus" >}}

Auch das sieht gut aus. Nun, zumindest für ein normales Linux-System. Das Problem ist der fest kodierte Interpreter `/lib64/ld-linux-x86-64.so.2`, der unter diesem Pfad auf NixOS nicht existiert.

## Den Interpreter patchen

{{< alert >}}
Dies basiert auf der [Manual Method](https://nixos.wiki/wiki/Packaging/Binaries#Manual_Method) im NixOS-Wiki. Allerdings ist `$NIX_CC` auf meinem System nicht verfügbar, und ich konnte meine Binaries mit den beschriebenen Befehlen nicht erfolgreich patchen.
{{< /alert >}}

Wir müssen:

1. Der ausführbaren Datei irgendwie mitteilen, dass der Interpreter-Pfad anders ist.
1. Den Interpreter-Pfad finden 😄.

[patchelf](https://github.com/NixOS/patchelf) kann uns bei beiden Punkten helfen. Es kann mit z. B. `nix shell nixpkgs#patchelf` zur Shell hinzugefügt oder in `configuration.nix` aufgenommen werden.

Wie den Interpreter-Pfad finden? Mit folgendem Befehl:

```sh
patchelf --print-interpreter `which find`
```

{{< figure src=interpreter-path.png caption="Der Interpreter-Pfad unseres Systems" >}}

Diese Information kann verwendet werden, um den Interpreter der ausführbaren Datei mit folgendem Befehl zu setzen:

```sh
patchelf --set-interpreter $(patchelf --print-interpreter `which find`) \
$HOME/.local/share/nvim/mason/packages/stylua/stylua
```

{{< figure src=works.png caption="Es funktioniert!" >}}

Da ist es, es funktioniert! Die Fehlermeldung stammt von `stylua` selbst, da wir keine Lua-Datei angegeben haben.

## Dynamische Bibliotheken patchen

Wir können diesen Ansatz auch zum Patchen dynamischer Bibliotheken verwenden!

Ein anderes von Mason heruntergeladenes Binary ist `marksman`, das dieselbe Fehlermeldung wie zuvor liefert.

{{< figure src=marksman.png caption="Gleicher Fehler wie bei stylua" >}}

Zusätzlich zum Interpreter sehen wir auch, dass einige Bibliotheken fehlen.

{{< figure src=ldd.png caption="Einige Bibliotheken werden nicht gefunden" >}}

In diesem Fall müssen wir:

1. Finden, welche Pakete diese Bibliotheken bereitstellen.
1. Den Pfad zu diesen Bibliotheken im Nix-Store finden.

libz.so.1 wird von `zlib` bereitgestellt, und libstdc++.so.6 ist Teil der C/C++-Compiler-Toolchain. Sicherstellen, dass beide installiert sind.

Über `nix eval nixpkgs#zlib.outPath --raw` kann der aktuelle Pfad des zlib-Pakets und damit seiner Bibliothek gefunden werden.

{{< figure src=path.png caption="Den Pfad eines Pakets/einer Bibliothek ermitteln" >}}

Jetzt kann diese Information verwendet werden, um den [rpath](https://en.wikipedia.org/wiki/Rpath) der Binaries zu patchen:

```sh
patchelf --set-rpath "$(nix eval nixpkgs#zlib.outPath --raw)/lib:$(nix eval nixpkgs#stdenv.cc.cc.lib.outPath --raw)/lib" \
$HOME/.local/share/nvim/mason/bin/marksman
```

{{< figure src=marksman-patched.png caption="Keine fehlenden Bibliotheken mehr" >}}

Durch das Patchen des rpath kennt marksman jetzt die fehlenden Bibliotheken und funktioniert auf NixOS nach dem Patchen des Interpreters wie in [Den Interpreter patchen](#patching-the-interpreter) gezeigt.

## Einschränkungen

Offensichtlich ist das eine recht arbeitsintensive Aufgabe, die automatisiert werden könnte. Außerdem muss jedes Mal, wenn ein betroffenes Binary aktualisiert wird, es erneut gepatcht werden.

In meinem aktuellen Setup sind jedoch nur drei Binaries betroffen, und ich werde vorerst bei diesem Workaround bleiben.

[^1]: Siehe [nix-shell](/blog/nixos-as-host/#nix-shell).
