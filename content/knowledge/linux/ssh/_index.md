---
title: SSH
---

{{< toc >}}

## Basic usage with custom port and custom key

```bash
ssh -i ~/.ssh/id_rsa -p PORT USER@HOST
```

## Local port forwarding

```bash
ssh -L BINDADDRESS:PORT:DSTHOST:DSTPORT USER@HOST
```

For examlpe:

```bash
ssh -L localhost:9000:127.0.0.1:80 admin@rootknecht.net
```

When you now visit `localhost:9000` in your browser you will be tunneled to your machine. There you get the return of the url `127.0.0.1:80` without actually logging into your machine.

## Remote port forwarding

```bash
ssh -R BINDADDRESS:PORT:LOCALHOST:LOCALPORT USER@HOST
```

Essentially the other way of local port forwarding for example:

```bash
ssh -R 9000:localhost:80 admin@rootknect.net
```

Now if you visit your remote server on port `900` it is directed to your local machine port `80`

In sshd_config make sure to add the line `GatewayPorts yes`.

## Run command on host

```bash
ssh -i ~/.ssh/id_rsa USER@HOST "sudo apt-get update && sudo apt-get upgrade"
```

## SSH related files

| File                   | Purpose                                             |
| ---------------------- | --------------------------------------------------- |
| ~/.ssh/                | User specific ssh settings                          |
| ~/.ssh/authorized_keys | Public keys which are allowed to login as this user |
| ~/.ssh/config          | User specific ssh config file                       |
| ~/.ssh/id\_\*          | Common prefix for public/private ssh keys           |
| ~/.ssh/known_hosts     | Public host keys known to user                      |
| /etc/ssh/ssh_config    | Global ssh client config                            |
| /etc/ssh/sshd_config   | Global ssh server config                            |

## Add authorized key

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
#  remotley
ssh-copy-id -i ~/.ssh/id_rsa USER@HOST
```

## Copy files

**From host**

```bash
scp USER@HOST:/path/to/file.txt /tmp/file.txt
```

**To host**

```bash
scp /tmp/file.txt USER@HOST:/tmp/file.txt
```

**Options**

- _-r_ &#8594; copy recursive
- _-P_ &#8594; custom port (note capital P in contrast to ssh)
