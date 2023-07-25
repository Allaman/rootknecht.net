---
title: Patching Binaries for NixOS
type: posts
draft: false
date: 2023-07-25
tags:
  - tools
  - workflow
  - nixos
  - Neovim
resources:
  - name: error
    src: error.png
    title: Error message when running stylua
  - name: ll
    src: ll.png
    title: The file exists
  - name: file
    src: file.png
    title: Looks like a regular executable
  - name: interpreter-path
    src: interpreter-path.png
    title: Our system's interpreter path
  - name: works
    src: works.png
    title: It is working!
  - name: marksman
    src: marksman.png
    title: Same error as with stylua
  - name: ldd
    src: ldd.png
    title: Some libraries are not found
  - name: path
    src: path.png
    title: Get the path of a package/library
  - name: marksman-patched
    src: marksman-patched.png
    title: No missing libraries
---

In this blog post, I want to describe a workaround how downloaded binaries work on NixOS.

<!--more-->

{{< toc >}}

In my previous blog post [NixOS as Container Host](/blog/nixos-as-host/) I described my approach of running containers due to the incompatibility of some binaries with NixOS [^1].

After diving deeper in the world of NixOS, I stumbled over a more NixOS-ish solution for said issue.

{{< hint info >}}
Disclaimer: I am a NixOS novice and probably there are better solutions. Compare [Binaries](https://nixos.wiki/wiki/Packaging/Binaries) in the NixOS wiki.

However, this approach works for me and more importantly, it does not involve advanced stuff like packaging, derivatives, etc.
{{< /hint >}}

## No such file or directory

I rely on [Mason](https://github.com/williamboman/mason.nvim) to download required tools for my [Neovim config](https://github.com/Allaman/nvim). One such tool is `stylua` which does not work on NixOS.

{{< img name=error lazy=true >}}

Unfortunately, this error message is not very intuitive. The file does exist and is executable.

{{< img name=ll lazy=true >}}

Let's have a look at the output of `file`:

{{< img name=file lazy=true >}}

Also looking good. Well, at least for a normal Linux system. The problem is the hard coded interpreter `/lib64/ld-linux-x86-64.so.2` which does not exist at this path on NixOS.

## Patching the interpreter

{{< hint info >}}
This is based upon the [Manual Method](https://nixos.wiki/wiki/Packaging/Binaries#Manual_Method) in the NixOS wiki. However, `$NIX_CC` is not available on my system, and I was not able to successfully patch my binaries with the described commands.
{{< /hint >}}

We need to

1. Somehow tell the executable that the interpreter path is different.
1. Find the interpreter path 😄.

[patchelf](https://github.com/NixOS/patchelf) can help us with both points. Add it to your shell with e.g. `nix shell nixpkgs#patchelf` or in your `configuration.nix`.

How to find the interpreter path? We can use the following command:

```sh
patchelf --print-interpreter `which find`
```

{{< img name=interpreter-path lazy=true >}}

We can use this information to set the interpreter of our executable with the following command:

```sh
patchelf --set-interpreter $(patchelf --print-interpreter `which find`) \
$HOME/.local/share/nvim/mason/packages/stylua/stylua
```

{{< img name=works lazy=true >}}

There it is, it works! The error message is from `stylua` itself as we did not provide any Lua file.

## Patching dynamic libraries

We can use this approach to patch dynamic libraries as well!

Another binary downloaded by Mason is `marksman` that yields the same error message as before.

{{< img name=marksman lazy=true >}}

In addition to the interpreter, we can also see that there are some libraries missing.

{{< img name=ldd lazy=true >}}

In this case, we need to

1. Find which packages provide those libraries.
1. Find the path to those libraries in the nix store.

libz.so.1 is provided by `zlib` and libstdc++.so.6 is part of the C/C++ compiler tool chain. Make sure that both are installed.

Via `nix eval nixpkgs#zlib.outPath --raw` we can find the current path of the zlib package and therefore its library.

{{< img name=path lazy=true >}}

Now we can use this information to patch the binaries [rpath](https://en.wikipedia.org/wiki/Rpath):

```sh
patchelf --set-rpath "$(nix eval nixpkgs#zlib.outPath --raw)/lib:$(nix eval nixpkgs#stdenv.cc.cc.lib.outPath --raw)/lib" \
$HOME/.local/share/nvim/mason/bin/marksman
```

{{< img name=marksman-patched lazy=true >}}

By patching the rpath, marksman is now aware of the missing libraries and works on NixOS after patching the interpreter as well as shown in [Patching the interpreter](#patching-the-interpreter).

## Limitations

Obviously, this is a rather labor-intensive work that could be automated. In addition, each time, an affected binary is updated, it needs to be patched again.

However, in my current setup, only three binaries are affected, and I will stick to this workaround for now.

[^1]: See [nix-shell](/blog/nixos-as-host/#nix-shell)
