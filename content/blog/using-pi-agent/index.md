---
title: Reducing the blast radius of running pi.dev
description: "How I reduce Pi's blast radius by running it in isolated Tart VMs and adding extensions that block risky file and Git operations."
summary: "A practical look at making Pi safer to use: isolating each project in a Tart-based virtual machine, sharing only the required directories, and using Pi extensions to block risky access patterns and destructive Git commands."
draft: false
date: 2026-06-13
tags:
  - tools
  - AI
  - workflow
---

The [Pi](https://pi.dev/) _minimal agent harness_ got some attention as an open-source alternative to [Claude Code](https://claude.com/product/claude-code) and [Codex](https://openai.com/codex/) because it is the backbone of a small project called [OpenClaw](https://github.com/openclaw/openclaw) 😉. Pi comes with YOLO mode [^1] enabled by default. Some people, including me, are not comfortable with this, so in this post I describe how I restrict Pi's power.

## YOLO Mode

I think a good explanation for YOLO (you only live once) is to compare Pi with Claude Code's [permission mode](https://code.claude.com/docs/en/permission-modes), which restricts the capabilities of the harness. You can disable all permissions by passing `--permission-mode bypassPermissions`. This allows the agent to basically work on its own with no interaction needed. This is the default mode for Pi. In addition, Pi also includes paths outside the current working directory, which I don't like at all.

## VMs for the Win

In Pi's documentation, there is a dedicated [Containerization](https://pi.dev/docs/latest/containerization) page. Neither of the described options suits my preferences or taste. I came across [tart](https://tart.run/), _a virtualization toolset to build, run and manage macOS and Linux virtual machines on Apple Silicon._ As a [UTM](https://mac.getutm.app/) user, the CLI-driven feature of tart looked very tempting, so I gave it a shot.

### Tart Intro

Tart works by downloading and running prebuilt OS images that work out of the box. No need to download an installation ISO and install the OS like with UTM.

```sh
tart clone ghcr.io/cirruslabs/ubuntu:latest ubuntu
tart run ubuntu

ssh admin@$(tart ip ubuntu)
```

The default credentials are admin/admin. Now you are connected to a normal Ubuntu Linux. After cloning, a VM starts in only seconds. How cool is that!

### My Tart Workflow

Tart offers the possibility to clone a virtual machine with `tart clone`. So I had the idea to use this feature to kill two birds with one stone:

1. Create a base image (a ["golden image"](https://www.redhat.com/en/topics/linux/what-is-a-golden-image) if you will)
2. Spin up a dedicated virtual machine for each project where I use Pi

#### Base Image

I am a Debian guy, so I naturally prefer Debian as a base image over the rest. 😄

```sh
tart clone ghcr.io/cirruslabs/debian:latest debian-base
```

Now I have my base image downloaded and just need to configure it. I thought about using [Ansible](https://github.com/ansible/ansible) to do the configuration, but this was overkill given how little configuration is needed, and it is a one-time thing since my base image will be kept.

Update and install system packages

```sh
apt update && apt upgrade
```

Install Node 25

```sh
apt install extrepo
extrepo search node
extrepo enable node_25.x
apt update
apt install nodejs
```

Install Pi

```sh
npm install -g @earendil-works/pi-coding-agent
```

Mount shared folders

In `/etc/fstab`, add

```
com.apple.virtio-fs.automount /mnt/shared virtiofs rw,relatime 0 0
```

You might wonder what the `fstab` change is all about. Basically, I start a virtual machine with the following command:

```sh
tart run --dir=pi:~/.pi/ --dir=project:"$PWD" --no-graphics foobar
```

This command mounts two directories, my host's Pi config and the current working directory.
Instead of calling `mount` each time a virtual machine spins up, the `fstab` entry persists this configuration in my base image.

```sh
admin@debian:~$ ls /mnt/shared/
pi  project
```

Finally, symlink the Pi configuration

```sh
# As the admin user, not as root
ln -s /mnt/shared/pi $HOME/.pi
```

Now, the base image is ready to go and I can spin up virtual machines.

#### Managing Virtual Machines

I wrote a wrapper (with the help of Pi) around `tart` for running multiple virtual machines for multiple projects. Here is the synopsis:

```sh
❯ vms
usage: vms <command> [args]
  start               start VM for current directory and SSH in (clones from debian-base if needed)
  stop [vm...]        stop running VMs (fzf if no args)
  ssh [vm...]         SSH into running VMs (fzf if no args)
  list                list all VMs
  clone <src> <name>  clone a VM
  delete [vm...]      delete VMs (fzf if no args)
  destroy [vm...]     stop and delete VMs (fzf if no args)
```

The source code is in my [dots](https://github.com/Allaman/dots/blob/d77a09f6136360edce550cbf89cb660a13f48d64/dot_local/bin/executable_vms) repository on GitHub.

So my usual workflow is that whenever I need an agent, I open a new tmux pane in my project's directory and run `vms start`. This will start the project's virtual machine or clone a new virtual machine from my base image.

## Pros and Cons

Running Pi only in a VM has some advantages and disadvantages.

### Advantages

- High level of isolation
- Only `.pi` and the current working directory are accessible to Pi
- `tart` greatly reduces the overhead of running virtual machines
- Changes from Pi are immediately reflected on the host machine where my regular tooling is available
- Not all tools are available, so Pi cannot call dangerous commands, e.g. `terraform apply`

### Disadvantages

- An additional layer with additional complexity
- More maintenance to keep the base image up-to-date and destroy virtual machines from time to time
- You need to think about which directory you want to mount
- Not all tools are available, so Pi cannot act as autonomously (lack of feedback loop)

## Extensions

Pi has an [extension](https://pi.dev/docs/latest/extensions) system that lets Pi write extensions for itself. So why not restrict Pi itself in addition to running it in an isolated environment? Here, I have a funny story to tell:

I told Pi to write an extension that forbids reading and writing `.*env*` files. Pi happily wrote this extension for me, and after a `reload` it was successfully loaded. When I told the agent to read the now-forbidden file, I was surprised. One of Pi's four tools [^2] is `read`. The extension successfully blocked this; however, Pi then used `python` to write a script that reads the forbidden file. 🤯 I then told Pi to improve the extension to also block other tools from reading, like Python or Node.

In addition, I had Pi write an extension that blocks dangerous Git operations, which are among the few commands besides the built-in commands that could lead to data loss.

## Verdict

This is my workflow for running Pi, where I feel comfortable that Pi won't do silly things on my machine. Keep in mind that this approach also does not guarantee 100% security or safety. If you want to further limit Pi, a dedicated physical host with restricted networking would be the next step. Or you could search for different restricted "flavors" of Pi.

[^1]: The author of Pi justifies this decision in his blog [post](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/#toc_13)

[^2]: `read`, `write`, `edit`, and `bash`; refer to [First session](https://pi.dev/docs/latest/quickstart#first-session) for more details.
