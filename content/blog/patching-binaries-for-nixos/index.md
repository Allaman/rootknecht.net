---
title: Patching Binaries for NixOS
summary: In this blog post, I want to describe a workaround how to get downloaded binaries to work on NixOS.
description: nixos, configuration, linux
date: 2023-07-25
tags:
  - tools
  - workflow
  - nixos
---

In my previous blog post [NixOS as Container Host](/blog/nixos-as-host/) I described my approach of running containers due to the incompatibility of some binaries with NixOS [^1].

After diving deeper in the world of NixOS, I stumbled over a more NixOS-ish solution for said issue.

{{< alert >}}
Disclaimer: I am a NixOS novice and probably there are better solutions. Compare [Binaries](https://nixos.wiki/wiki/Packaging/Binaries) in the NixOS wiki.

However, this approach works for me and more importantly, it does not involve advanced stuff like packaging, derivatives, etc.
{{< /alert >}}

## No such file or directory

I rely on [Mason](https://github.com/williamboman/mason.nvim) to download required tools for my [Neovim config](https://github.com/Allaman/nvim). One such tool is `stylua` which does not work on NixOS.

{{< figure src=error.png caption="Error message when running stylua" >}}

Unfortunately, this error message is not very intuitive. The file does exist and is executable.

{{< figure src=ll.png caption="The file exists" >}}

Let's have a look at the output of `file`:

{{< figure src=file.png caption="Looks like a regular executable" >}}

Also looking good. Well, at least for a normal Linux system. The problem is the hard coded interpreter `/lib64/ld-linux-x86-64.so.2` which does not exist at this path on NixOS.

## Patching the interpreter

{{< alert >}}
This is based upon the [Manual Method](https://nixos.wiki/wiki/Packaging/Binaries#Manual_Method) in the NixOS wiki. However, `$NIX_CC` is not available on my system, and I was not able to successfully patch my binaries with the described commands.
{{< /alert >}}

We need to

1. Somehow tell the executable that the interpreter path is different.
1. Find the interpreter path 😄.

[patchelf](https://github.com/NixOS/patchelf) can help us with both points. Add it to your shell with e.g. `nix shell nixpkgs#patchelf` or in your `configuration.nix`.

How to find the interpreter path? We can use the following command:

```sh
patchelf --print-interpreter `which find`
```

{{< figure src=interpreter-path.png caption="Our system's interpreter path" >}}

We can use this information to set the interpreter of our executable with the following command:

```sh
patchelf --set-interpreter $(patchelf --print-interpreter `which find`) \
$HOME/.local/share/nvim/mason/packages/stylua/stylua
```

{{< figure src=works.png caption="It is working!" >}}

There it is, it works! The error message is from `stylua` itself as we did not provide any Lua file.

## Patching dynamic libraries

We can use this approach to patch dynamic libraries as well!

Another binary downloaded by Mason is `marksman` that yields the same error message as before.

{{< figure src=marksman.png caption="Same error as with stylua" >}}

In addition to the interpreter, we can also see that there are some libraries missing.

{{< figure src=ldd.png caption="Some libraries are not found" >}}

In this case, we need to

1. Find which packages provide those libraries.
1. Find the path to those libraries in the nix store.

libz.so.1 is provided by `zlib` and libstdc++.so.6 is part of the C/C++ compiler tool chain. Make sure that both are installed.

Via `nix eval nixpkgs#zlib.outPath --raw` we can find the current path of the zlib package and therefore its library.

{{< figure src=path.png caption="Get the path of a package/library" >}}

Now we can use this information to patch the binaries [rpath](https://en.wikipedia.org/wiki/Rpath):

```sh
patchelf --set-rpath "$(nix eval nixpkgs#zlib.outPath --raw)/lib:$(nix eval nixpkgs#stdenv.cc.cc.lib.outPath --raw)/lib" \
$HOME/.local/share/nvim/mason/bin/marksman
```

{{< figure src=marksman-patched.png caption="No missing libraries" >}}

By patching the rpath, marksman is now aware of the missing libraries and works on NixOS after patching the interpreter as well as shown in [Patching the interpreter](#patching-the-interpreter).

## Limitations

Obviously, this is a rather labor-intensive work that could be automated. In addition, each time, an affected binary is updated, it needs to be patched again.

However, in my current setup, only three binaries are affected, and I will stick to this workaround for now.

[^1]: See [nix-shell](/blog/nixos-as-host/#nix-shell)
