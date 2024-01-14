---
title: How I handle multiple Git configurations
summary: I have to handle multiple git configurations for my clients and for my different repositories. Here is how I handle them!
description: git, workflow, configuation
date: 2022-09-25
tags:
  - shell
  - workflow
  - configuration
---

I do work on multiple repositories all the time, be it for personal stuff like my [Neovim configuration](https://github.com/Allaman/nvim/), [this webpage](https://github.com/Allaman/rootknecht.net), or for my clients. That means that I need to manage different `user.name` and `user.email` settings for my Git configuration (in addition to SSH keys).

## Direnv

{{< alert >}}
For historical purpose I want to describe my old approach. If you just want to read about the (in my opinion) better approach you can skip this section.
{{< /alert >}}

For years, I used [direnv](https://direnv.net/) to solve this problem of multiple Git configurations.

> direnv is an extension for your shell. It augments existing shells with a new feature that can load and unload environment variables depending on the current directory.

Direnv lets you define certain aspects of your shell, e.g. exported variables, on a per directory basis. Direnv "hooks" into your zsh (or bash) and whenever you cd into a directory containing a `.envrc` file it gets sourced. Direnv also looks for `.envrc` in the parent directories allowing you to define one `.envrc` file for a whole bunch of subdirectories, e.g. for a certain client or project.

The second part of my old approach is a bash script to set global Git settings:

```sh
case $param in
    client1 )
        notify "Generating client1 config"
        git config --global user.email "michael.peter@client1.de"
        git config --global user.name "Michael Peter"
        git config --global credential.username "michael.peter"
        ;;
    github )
        notify "Generating github config"
        git config --global user.email "michaeljohannpeter@gmail.com"
        git config --global user.name "Michael"
        git config --global credential.username "allaman"
        ;;
esac
```

Combining those results in a `.envrc` file containing the call to the script and the appropriate parameter like so

```sh
~/.local/bin/gitconfig.sh github
```

Those `.envrc` files are place in the root folder of my projects (with the appropriate argument):

```sh
kunden
└── client1
    ├── project1
    ├── project2
    └── .envrc
└── client2
    ├── project1
    ├── project2
    └── .envrc
workspace
└── github
    ├── project1
    ├── project2
    └── .envrc
└── gitea
    ├── project1
    ├── project2
    └── .envrc
```

Every time I cd into a project the `.envrc` of the root directory is read and my global Git configuration is updated.

There are two major disadvantages of this approach:

1. It is "slow". Each time I cd into a project folder the script is called by Direnv. Even when my Git credentials are already correct. I could implement a check in the bash script but the check alone would probably be more logic than the configuration logic itself. I don't know why executing such a small script via Direnv takes a notable time but maybe because of the little misuse ;). I use Direnv farther for setting project specific ENV variables.
2. It is not as "safe" as I would like it to be. As I said when ever I cd into a directory my Git configuration is altered. Imagine I work for client1 in one Tmux window and suddenly must switch to client2 in another Tmux window. When switching back to client1 and its Tmux window my Git is configured to client2 because I did not cd into a client1 project! So I always have to be somehow aware of my contexts and of course I forgot it from time to time resulting in a wrong commit author.

## IncludeIf

Due to those disadvantages I was thinking about a new approach how to handle my various Git configurations. I came across the [IncludeIf](https://git-scm.com/docs/git-config#_includes) directive which looks like it exists for some years now _facepalm_. This allows me to configure my `user.name` and `user.email` setting (and more) in a separate file per client and reference it in my global `~/.gitconfig`. Refer to the previously linked documentation for more filter options.

`cat ~/.gitconfig`

```ini
[includeIf "gitdir:~/kunden/client1/"]
  path = ~/.gitconfig-client1
[includeIf "gitdir:~/workspace/github.com/"]
  path = ~/.gitconfig-gh
```

`cat .secrets/gitconfig-gh-allaman`

```ini
[user]
	email = michaeljohannpeter@gmail.com
	name = Michael
```

The benefits over this approach are as follows:

1. No shell manipulation or scripting is involved
2. No need to cd into a folder to activate the correct settings (or do so manually)

## SSH keys

To be able to authenticate I specify the SSH key for each repository in my `~/.ssh/config` e.g.

```
Host github.com
 HostName github.com
 User git
 AddKeysToAgent yes
 IdentityFile ~/.ssh/id_rsa
```
