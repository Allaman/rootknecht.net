---
title: How to not accidentally delete your data with rm
type: posts
draft: false
date: 2023-10-30
tags:
  - server
  - tools
  - cli
  - linux
---

When you are working with the shell on Linux, there is, in my opinion, one law: There will be a point when you accidentally delete important data by running `rm -rf` in the wrong place or with the wrong arguments!

In this blog post, I want to illustrate technical and “organizational” strategies to prevent you from accidentally deleting your $HOME (guess who has achieved this medal 🙈).

<!--more-->

In my early days working with Linux, I was deleting some logs or temp files with `rm -rf *`. By now, you might guess what happened further … When I wanted to delete some stuff in my $HOME folder, I accidentally hit the arrow up key too often, and boom. I executed `rm -rf *` in my $HOME directory 🤯. I immediately recognized my mistake and hit ctrl-c but as you probably know, the rm command is really fast, and the damage was done. All my files in my $HOME directory are gone. The rm command is nasty in that it deletes files pretty quickly and well. One could try to immediately turn off the affected storage and run recovery tools, or send the storage to a professional provider.

What have I changed since then to prevent such a mistake? Here is my list of technical and “organizational” strategies I have taken to prevent an accidental deletion.

{{< toc >}}

## Backup Backup Backup

Things will go wrong. Have a working backup concept and ensure that restoring also works.

## Do not use autocompletion

Whenever I use `rm` I will fully type the path(s) and barely use tab-complete and never use history-up.

## Do not run rm as root user if you don't have to

This applies to working on the command line in general. Always work with the least privileged account to get the job done. In the event of a mistake, this can prevent you from deleting stuff because of insufficient permissions.

## Use -r and -f with care

Only use them if necessary!

## rmdir to remove empty dirs

In case you didn't know - `rmdir` allows you to remove empty directories.

## Delete your shell history

Whenever I have to run a potentially risky command like `rm -rf` I immediately delete the entry in my shell history. This prevents me from accidentally running this command when I mess up my history-search.

## Alias rm

This is a controversial method, but it has worked for me for many years. I have an alias (`alias rm='trash'`) that binds rm to trash-cli, a CLI program that moves the content to be deleted in the trashcan instead of deleting it permanently. For instance, running `rm foo/` moves the directory foo to the trashcan. The directory can also be restored by trash-cli. Notice that there is no need to specify `-r` with trash-cli to delete a folder. However, `rm` is a very “low level” command, and by aliasing it, you might mess something up. Instead of aliasing, you could use trash directly instead of rm, but my muscle memory is just too strong, and I want consistency on machines where trash-cli is not available. You can “escape” this alias, and aliases in general, by calling \rm which will call the original command.

## Focus

Finally, whenever I need to run `rm -rf` I ensure that there is no distraction and that I am not rushing.

I hope you never find yourself in the aforementioned situation and that one tip or another helps you to avoid a disaster. I have to admit that I actually found myself in the situation where I accidentally deleted my $HOME directory, again! After the initial shock, I was able to restore everything exactly using trash-cli. In the absolute worst-case scenario, I would have had a recent backup!
