---
title: Shell
resources:
  - name: startup
    src: "shell-startup-order.png"
    title: Startup order
---

{{< toc >}}

## Auto complete a command with history-search

This setting allows you to enter shell commands quite efficient. You just enter the first couple of letters of a coomand and press page up/down. The shell tries to auto complete them based on your previous commands.

In /etc/inputrc

```bash
# alternate mappings for "page up" and "page down" to search the history
"\e[5~": history-search-backward
"\e[6~": history-search-forward
```

## jq / yq

{{< hint info >}}
Some yq commands refer to v3. See [upgrading from v3](https://mikefarah.gitbook.io/yq/upgrading-from-v3)
{{< /hint >}}

Filter json:

```sh
jq -r '.report.problems[] | select(.category=="Error") | [.filename, .sourceId, .details] | @csv' $file.json >> summary.csv
```

- `-r` raw format (do not quote)
- `|` pipe the result to the next query
- `select` supports `and` and `or`
- `[ ... ]` transforms objets to an array
- @csv converts an array to csv format

Input `conf.yaml`:

```yaml
packages:
	cli:
      - vim
      - emacs
    sys:
      - strace
      - devel-base
```

Return a combined list from cli and sys

```
yq r conf.yaml --collect packages.*.*
```

Add an entry to cli list

```sh
yq w -i conf.yaml packages.cli[+] FOO
```

Remove FOO from cli list

```sh
yq w -i conf.yaml packages.cli[+] FOO
```

## CSV manipulation

With [xsv](/knowledge/applications/cli#xsv)

**Search by column and output specific columns**

```sh
  xsv search -d ';' -s Role \
  data.csv  \
  | xsv select Name,Location \
  | xsv table
```

**Join two csv tables and write in new csv**

```sh
xsv join -d ';' Name data.csv Name status.csv | xsv fmt -t ';' > joined.csv
```

## Env substitution via find (on all yamls)

This command will "iterate" over all yaml files in `FOLDER` and call `envsubst` replacing the original file with the modified one

```sh
find <FOLDER> -type f -name \*.yaml -print0 | xargs -0 -I{} sh -c 'envsubst < "$1" | sponge "$1"' -- {}
```

## Force changes to /etc/hosts

```bash
systemctl restart nscd
```

## Write multiple lines without editor

```bash
echo "line 1
line 2" >> multiple
```

or

```bash
cat <<EOT >> multiple
line 1
line 2
EOT
```

## Disable HTTPS Certificate Verification

{{< tabs "disablehttpscert" >}}
{{< tab "wget" >}}

```bash
--no-check-certificate
```

{{< /tab >}}
{{< tab "curl" >}}

```bash
--insecure
```

{{< /tab >}}
{{< /tabs >}}

## Create user with predefined password

```bash
useradd -p $(openssl passwd -1 $PASS) $USER
```

## Generate hash for passwords

```bash
echo "password" | sha1sum
```

## Add existing user to group

```bash
usermod -a -G GROUP USER
```

## Force reload of group membership without logout

```sh
sg NEW_GROUP -c "bash"
```

```sh
newgrp NEW_GROUP
newgrp $(id -gn) # ensure membership in own group
```

Those will create additional login shells!

```sh
exec su -l USER_NAME
```

This will not create an additional login shell but will require the users password. When passwordless sudo is enabled use sudo before su

## Copy permissions from existing file

```bash
chown --reference=otherfile newFile
chmod --reference=otherfile newFile
```

## Fix messed up permissions

```bash
fd -t f | xargs -d '\n' chmod u-x && fd -t f | xargs -d '\n' chmod g-x
```

- recursively all files in current folder
- remove executable bit from user and group
- handle spaces in filenames

## Modify ownership of symlinks

```bash
chown -h USER:GROUP SYMLINK
```

## Inherit permissions from parent directory

```bash
chmod g+s /path/to/parent
```

## Add user and allow sudo without password

```sh
groupadd -g ${gid} ${name} && useradd -d /home/${name} -u ${uid} -g ${gid} -m -s /bin/zsh -r ${name} &&\
    echo "${name} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers &&\
```

1. Create group, create user with homedirectory, uid/gi, zsh login shell, system account
2. Add line to sudoers file to allow user passwordless sudo

````

## Curl for REST API
**Auth**
```bash
# Auth with username password and store cookie information
curl -c cookies.txt -X POST -d 'username=admin&password=admin' https://example.com/login
# Use cookie auth information to post data from json file
curl -b cookies.txt -d @data.json -H "Content-Type: application/json" -X POST https://example.com/rest
# Use auth token
curl -H "X-Auth-Token: <Token ID>" https://example.com/login
````

**GET**

```bash
curl -H "Accept:application/json" https://httpbin.org/get
```

**POST**

```bash
curl \
-h "Content-type: application/json" \
-X POST \
-d '{"title": "Test Title", "note": "Test note"}' \
https://httpbin.org/
```

## Reduce size of pdf files with ghostscript

```bash
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=OPTION -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf input.pdf
```

common options for dPDFSETTINGS are:

- dPDFSETTINGS=/screen lower quality, smaller size.
- dPDFSETTINGS=/ebook for better quality, but slightly larger pdfs.
- dPDFSETTINGS=/prepress output similar to Acrobat Distiller "Prepress Optimized" setting
- dPDFSETTINGS=/printer selects output similar to the Acrobat Distiller "Print Optimized" setting
- dPDFSETTINGS=/default selects output intended to be useful across a wide variety of uses, possibly at the expense of a larger output file

## Run multiple commands in background

```bash
(command1 &) && (command2 &)
```

## Get RAM usage

```sh
ps -o pid,user,%mem,command ax | sort -b -k3 -r
```

## Execute command as different user

```sh
su - targetuser -s /bin/bash -c "/bin/echo hello world"
```

## Shows what is in file 2 but not in file 1

```bash
grep -v -F -x -f
```

## Merge all pdf files in current directory

```bash
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=merged.pdf *.pdf
```

## Generate handout from given pdf file

```bash
pdfjam --nup 2x3 --frame true --noautoscale false --delta "0.2cm 0.3cm" --scale 0.95
```

## List all executable files in current dir

```sh
find . -executable -type f
```

## Get BIOS version

```bash
sudo dmidecode | grep BIOS
```

## Get external IP

```bash
echo $(curl -ss http://ipecho.net/plain)
```

## Find primary network interface

```sh
route -n | awk '($1 == "0.0.0.0") { print $NF }'
```

## Get IP from interface

```sh
ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1
```

## List files from a packages managed by package managers

{{< tabs "listfilesfroma" >}}
{{< tab "DPKG" >}}

```sh
dpkg-query -L <PACKAGE_NAME>
dpkg-deb -c <FILE-NAME>
apt-file list <PACKAGE_NAME> (package not installed)
```

{{< /tab >}}
{{< tab "Pacman" >}}

```sh
pacman -Ql  <PACKAGE_NAME>
```

{{< /tab >}}
{{< tab "RPM" >}}

```sh
rpm -ql <PACKAGE_NAME>
```

{{< /tab >}}
{{< /tabs >}}

## Get system information

Basics e.g. modelnumber, manufactorer

```bash
dmidecode -t1
```

Ram slots

```bash
dmidecode -t memory
```

## Shell Boot Order

{{< img name="startup" lazy="true" >}}

<small>from [here](https://blog.flowblok.id.au/2013-02/shell-startup-scripts.html)</small>

## Zsh sourcing

- zsh always sources '~/.zshenv'.
- Interactive shells source `~/.zshrc`
- Login shells source `~/.zprofile` and `~/.zlogin`

## Types of shells

1. Interactive

   Interactive means that the commands are run with user-interaction from keyboard, so the shell can prompt the user to enter input.

1. Non-interactive

   The shell is probably run from an automated process so it can't assume if can request input or that someone will see the output.

1. Login

   Means that the shell is run as part of the login of the user to the system. Typically used to do any configuration that a user needs/wants to establish his work-environment.

1. Non-login

   Any other shell run by the user after logging on, or which is run by any automated process which is not coupled to a logged in user.

## Custom ps command

```bash
ps axo user:20,pid,pcpu,pmem,vsz,rss,tty,stat,start,time,comm
```

## Download whole website with wget

```bash
wget \
     --recursive \
     --no-clobber \
     --page-requisites \
     --html-extension \
     --convert-links \
     --restrict-file-names=windows \
     --domains example.com \
     --no-parent \
         www.example.com/home/wiki/
```

## zip folder with password

```bash
zip -rP PASSWORD file.zip folder/
```

## Add user and group

```sh
groupadd GROUP && useradd -g|-G GROUP user
```

- lower g when group exists
- optional -M for no home directory

## PHP modules

```bash
php -m
```

/etc/php/php.ini

## Print the value of an alias

```bash
type ALIAS
```

## Show output of a background process

```sh
tail -f /proc/<PID>/fd/
```

- 1 is stdout
- 2 is stderr

## Convert svg to all in one icon

```bash
convert -density 384 NAME.svg -define icon:auto-resize NAME.ico
```

## Kill process by name in one line

I want to match not just only the program but its arguments (here for entr)

```bash
ps ax | grep "xelatex main.tex" | grep -v grep | awk '{print "kill -9 " $1}' | sh
```

## Generate random number

```sh
awk -v min=1 -v max=100 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'
```

## Rsync

This command recursively syncs two folders with advanced matching options I am running for syncing my documents to my [eInk Reader](https://onyxboox.com/boox_novapro).

```sh
rsync -rv \
--omit-dir-times \ # ignore timestamps
--prune-empty-dirs \ # don't create emtpy directories
--delete \ # also delete files at the destination
--exclude='dir1' --exclude='dir2' \ # exclude dir1 and dir2
--include='*/' \ # but include all other directories
--exclude='.*' \ # exclude all hidden files
--include='*.pdf' --include='*.epub' \ # include .pdf and .epub files
--exclude='*' \ # exclude all the rest
-e "ssh -p8022" \ # copy over ssh
source \ # source directory to sync
user@host:/destination # target directory on remote
```

## Show dd status

1. with builtin methods
   ```bash
   watch -n 3 'kill -USR1 $(pgrep "^dd$")'
   ```
1. with package pv
   ```bash
   dd if=/dev/urandom | pv | dd of=/dev/null
   ```
   use pv -s 4G for ETA, here approximately 4G
1. with new status
   ```bash
   dd if=/dev/urandom of=/dev/null status=progress
   ```

## Inline file returning

instead of

```sh
grep string1 file1 > result1
grept string1 file2 > result
diff result1 result2
```

use `<()`

```sh
diff <(grep string1 file1) <(grep string1 file2)
```

## Mount Windows Virtualbox vmdk

`ndb` (network device block) module and `qemu-nbd` command is required!

```bash
#!/bin/bash

for i in "$@"
do

case $i in
    -m|--mount)
        echo "modprobe nbd, creating device and mounting"
        sudo rmmod nbd
		sudo modprobe nbd max_part=63
        sudo qemu-nbd -c /dev/nbd0 '~/path/to/disk.vmdk'
        echo "Device created"
		if [[ -f /dev/nbd0p1 ]]
		then
			sudo mount /dev/nbd0p1 ~/mounts/tmp
		else
			sudo partprobe /dev/nbd0
			sudo mount /dev/nbd0p1 ~/mounts/tmp
		fi
        echo "Mounted at ~/mounts/tmp"
        shift
        ;;
    -u|--umount)
        echo "Unmounting, deleting device and removing nbd module"
        sudo umount ~/mounts/tmp
        sudo qemu-nbd -d /dev/nbd0
        sudo rmmod nbd
        shift
        echo "Done"
        ;;
    \?)
        echo "invalid option"
esac

done
```

## Unban a IP blocked from fail2ban.

**Check if IP is really banned**

```bash
iptables -L -n | grep IP
```

**Look for the appropriate rule name**

```bash
iptables -L -n
```

**Get fail2ban jail list**

```bash
fail2ban-client status
```

**Unban IP**

```bash
fail2ban-client set JAILNAME unbanip IP
```

## Mount a virtualbox shared folder in a linux guest

in `/etc/fstab`

```bash
SHARED_FOLDER_NAME /PATH/TO/MOUNT_POINT vboxsf rw,dmask=770,fmask=600,uid=1000,gid=109 0 0
```

- uid is the id of your user in the guest
- gid is the id of the vboxsf-group in the guest
- dmask sets the default permissions for directories
- fmask sets the default permissions for files

{{< hint info >}}
Ensure that your linux user is in vboxsf group ( `sudo usermod -aG vboxsf USER`)

Ensure that the vboxsf module is loaded (`sudo modprobe -a vboxsf`)
{{< /hint >}}
