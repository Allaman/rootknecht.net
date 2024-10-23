---
title: Bash
summary: Notes on working with Bash
---

## Shebang

```bash
#!/bin/bash
#!/usr/bin/env bash # suitable for NixOS!
```

## Strict

```bash
set -euo pipefail
```

## Debugging

```bash
bash -x script
```

```bash
set -x # start debugging from here
echo Hello World!
set +x # stop debugging from here
```

```bash
set -v # print shell inputs as they are read
echo Hello World!
set +v # stops showing shell inputs
```

```bash
#!/bin/bash -xv # combining options for whole scripts in the shebang
```

## Loops

```bash
for i in $( ls ); do
	echo item: $i
done
```

```bash
for i in `seq 1 10`;
	do
		echo $i
done
```

```bash
COUNTER=0
while [  $COUNTER -lt 10 ]; do
   	echo The counter is $COUNTER
       	let COUNTER=COUNTER+1
done
```

```bash
COUNTER=20
until [  $COUNTER -lt 10 ]; do
	echo COUNTER $COUNTER
    	let COUNTER-=1
done
```

## IF Condition

### One-liner

```bash
  [[ -f $tmpfile ]] || rm $tmpfile
```

### Env

```bash
if [ "$ENV_VAR" = "true" ] ; then
	echo $ENV_VAR
fi
```

### Files

```bash
[ -a FILE ] # True if file exists
[ -d FILE ] # True if file exists and is a directory
[ -f FILE ] # True if file exists and is a regular file
[ -h FILE ] # True if file exists and is a symbolic link
[ -s FILE ] # True if file exists and its size is greater than 0
[ -rwx FILE ] # True if file exists and is readable, writable, executable
[ FILE1 -nt FILE2 ] # True if FILE1 has been changed more recently or if FILE1 exists and FILE2 does not
[ FILE1 -ot FILE2 ] # True if FILE1 is older or FILE1 exists and FILE2 does not
```

### Strings

```bash
[ -z "STRING" ] # True if length of STRING is zero
[ "STRING1" != "STRING2" ] # True if strings are (not) equal
```

### String in file

```bash
if grep -q <PATTERN> <FILE>; then
  echo "True"
else
  echo "FALSE"
fi
```

## Integers

```bash
[ NUM1 -eq NUM2 ] # True if NUM1 is equal to NUM2
[ NUM1 -ne NUM2 ] # True if NUM1 is not equal to NUM2
[ NUM1 -gt NUM2 ] # True if NUM1 is greater than NUM2
[ NUM1 -ge NUM2 ] # True if NUM1 is greater or equal to NUM2
[ NUM1 -lt NUM2 ] # True if NUM1 is leass than NUM2
[ NUM1 -le NUM2 ] # True if NUM1 is less than or equal to NUM2
# Former statements work with double parentheses e.g. ((NUM1 <= NUM2))
[ NUM1 -lt NUM2 ]
[ NUM1 -lt NUM2 ]
```

## Special variables

```bash
$# # number of arguments
$@ # array of all arguments
$? # last exit code
```

## Case (switch) statement

```bash
case $1 in
    pattern1 )
        statements
        ;;
    pattern2 )
        statements
        ;;
    ...
esac
```

## Combining Expressions

```bash
[ EXPR1 -a EXPR2 ] # True if both are true
[ EXPR1 -o EXPR2 ] # True if 1 or 2 is true
```

## Create array from whitespace separated string

```bash
arr=($string)
```

## Add up a list of numbers

```bash
<list of numbers> | paste -sd+ - | bc
```

## Checks

### Website

```sh
	while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost/grafana/login)" != "200" ]]; do sleep 5; done
```

### Program

```bash
command -v PROGRAM >/dev/null 2>&1 || { echo >&2 "require foo"; exit 1; }
```

```bash
for program in awk sed grep sort uniq rm mktemp; do
  command -v "$program" > /dev/null 2>&1 || { echo "Not found: $program"; exit 1; }
done
```

```sh
checkUtils() {
    readonly MSG="not found. Please make sure this is installed and in PATH."
    readonly UTILS="awk basename cat column echo git grep head seq sort tput \
		tr uniq wc"

    for u in $UTILS
    do
        command -v "$u" >/dev/null 2>&1 || { echo >&2 "$u ${MSG}"; exit 1; }
    done
}
```

### Process

```bash
pgrep -x <PROCESSNAME> >/dev/null && echo "Process found" || echo "Process not found"
ps -C <PROCESSNAME> >/dev/null && echo "Running" || echo "Not running"
```

### User

```bash
getent passwd USER
id -u name
```

### Root user

POSIX compliant

```sh
if ! [ $(id -u) = 0 ]; then
   echo "Must be run as root!"
   exit 1
fi
```

BASH

```sh
#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Must be run as root!"
   exit 1
fi
```

### Check if file is being sourced

Works for bash, ksh. zsh

```bash
([[ -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT =~ :file$ ]] ||
 [[ -n $KSH_VERSION && $(cd "$(dirname -- "$0")" &&
    printf '%s' "${PWD%/}/")$(basename -- "$0") != "${.sh.file}" ]] ||
 [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) || { echo "This script should be sourced for convenience as it sets env variables in your parent shell!"; exit 1; }
```

### PostgreSQL connection

```bash
apt-get install postgresql-client

while ! pg_isready -h ${HOST} -p ${PORT} &> /dev/null; do
	echo "Connection to ${HOST} ${PORT} failed "
	sleep 1
done
```

### Argument count

```sh
  if [ $# -eq 0 ]; then
    echo "Missing argument(s)"
    echo "Usage: $(basename $0) foo"
    echo "Usage: $(basename $0) foo bar"
    exit 1
  fi
```

### Git directory

```sh
if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then
  echo "This is a git directory"
else
  echo "This is not a git directory"
fi
```

## SED

### Prepend text on multiple files

```sh
fd -e yaml | xargs sed -i '1s;^;TO-BE-PREPENDED;'
```

{{< alert >}}
This command will edit all yaml files inplace! Backup!
{{< /alert >}}

### Search / Replace

```bash
	sed -i \
	        -e "s;^\\(application-port\\)=.*;\\1=8080;g" \
	        -e "s;^\\(application-host\\)=.*;\\1=0.0.0.0;g" \
            -e "s/#\{0,1\}api_interface.*/api_interfaces:\"eth1\"/" \
	        /PATH/TO/FILE
```

#### capture groups

```bash
sed -i 's/httpCode:\([0-9]\+\)/StatusCode:\1/'
```

#### search and replace in multiple files

```bash
find . -type f -name 'config' | xargs sed -i -e  's/PATTERN/STRING/g'
```

#### Delete lines containing a pattern from multiple files

```bash
find . -type f -name '*.md' | xargs sed -i -e '/PATTERN/d'
```

## AWK

### Search and delete pattern

```bash
awk '{gsub(/search_pattern/,x); }'
```

### Custom separator

```bash
awk -F= # = separator for e.g. columns
```

### Column of line

```sh
free -h | awk '/Mem:/{print $2}'
```

### Print all columns from nth column

```sh
awk '{$1=$2=""; print $0}'
```

### Remove first line

```sh
awk '{if (NR!=1) {print}}'
```

### Split a string

```sh
echo -n "eins:zwei:drei | awk '{split($0,r,":"); print r[1]}';) # returns zwei
```

### Sum up time durations

```sh
awk -F : '{acch+=$1;accm+=$2;} ENDFILE { print acch+int(accm/60)  ":" accm%60; }'
```

## Get parent directory of a file

```sh
parent_dir="$(dirname -- "$(readlink -f -- "$file_name")")"
```

## Time/Date

```sh
date --rfc-3339=seconds
```

## Arrays

```bash
arr=(hello word array)
for i in ${arr[*]}; do
        echo "her is $i"
done
```

## Iterate over a list of strings

```sh
LIST="crazymax/diun:4.20.1
grafana/grafana:8.3.2
k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.2.4
prom/blackbox-exporter:v0.19.0
prom/pushgateway:v1.4.1
quay.io/prometheus-operator/prometheus-config-reloader:v0.52.1
quay.io/prometheus-operator/prometheus-operator:v0.52.1
quay.io/prometheusmsteams/prometheus-msteams:v1.5.0"

while IFS= read -r line; do
	echo "$line" | awk -F':' '{print $2}'
done < <(printf '%s\n' "$LIST")
```

Will output:

```
4.20.1
8.3.2
v2.2.4
v0.19.0
v1.4.1
v0.52.1
v0.52.1
v1.5.0
```

## Yes no choice selection

with known options

```bash
echo "Continue?"
select choice in "Yes" "No"; do
    case $choice in
        Yes ) echo "Going on; break;;
        No ) exit;;
    esac
done
```

with unknown options

```bash
array=("Option1" "Option2" "Option3")
select choice in "${array[@]}"; do
    [[ -n $choice ]] || { echo "Invalid choice. Please try again." >&2; continue; }
    break
done
```

or

```sh
read -p "Run? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cowsay
fi
```

## Print date/time string

```sh
date -u +"%Y-%m-%dT%H:%M:%SZ"
```

## Redirect command output

**stderr and stdout**

```bash
command > /dev/null 2>&1
# bash only
command &> /dev/null
```

**only stderr**

```bash
command 2> /dev/null
```

**only stdout**

```bash
command 1> /dev/null
```

## Replace whitespace with underscore in all filenames in current directory

```bash
for f in *\ *; do mv "$f" "${f// /_}"; done
```

## Prevent a script from exiting your shell

If you source a script file any `exit` in a function will exit the shell as it runs in the current shell instead of spawning a subshell. Prevent this behaviour by using `return`!
When a 3rd party script you cannot modify is called which exits your shell than wrap the call with `()` which spawns a subshell for this call

## Printf

More stable and powerful than echo. Comparable to C's function.

```bash
printf "%s with %s\\n" "VAL1" "VAL2" >> test.txt
```

## Make all files with shebang in a folder executable

```bash
grep -rl '^#!' FOLDER | xargs chmod +x
```

## Empty/clear a file

```bash
echo > FILE
cat /dev/null > FILE
```

## String manipulation

### Substrings

```sh
echo "id=12" | cut -d'=' -f 2 # 12
```

## Omit first line of stdout

```bash
awk '{if(NR>1)print}'
```

## Find

### Find directories containing the most amount of files

```sh
find . -type d -exec sh -c "fc=\$(find '{}' -type f | wc -l); echo -e \"\$fc\t{}\"" \; | sort -nr
```

### File or directory listings

```sh
find PATH -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | exec -0 ls -l
find PATH -maxdepth 1 -mindepth 1 -type f -not -name README.md | exec -0 ls -l
```

### Convert all files in the directory to unix line endings

```sh
find . -type f -print0 | xargs -0 dos2unix
```

## Do not list the root directory

```sh
find deployments ! -path deployments -type d -printf "%f\n"
```

## basename functionality

```sh
find . -printf "%f\n"
```

## Working with geopts

```sh
#!/bin/bash

OPTIND=1
while getopts "ewa:" opt
do
  case "$opt" in
    e) echo "ethernet" ;;
    w) echo "wifi" ;;
    a) echo $OPTARG ;;
  esac
done
shift $(expr $OPTIND - 1)
```

## Create a simple menu with zenity

```sh
#!/bin/bash

choice="AA BB CC DD EE"
response=$(zenity --height=300 --width=200 --list --title='Snippet' --column=choice $choice)

case $response in
  AA)
    echo Your choice is $response
    ;;
  BB)
    echo Your choice is $response
    ;;
  CC)
    echo Your choice is $response
    ;;
  DD)
    echo Your choice is $response
    ;;
esac
```

Notify function for scripting

```sh
function notify {
	if [[ -z "${DISPLAY// }" ]]
	then
		# no x server detected
		echo "$1"
	elif ! [[ -z "${DISPLAY// }" ]]
	then
		# x server detected
		notify-send "$1"
	else
		# error
		echo "Cannot check for running x server"
		exit 1
	fi
}
```

## Arch check

```sh
go_arch() {
  arch="$(uname -m)"
  case "${arch}" in
    aarch64_be|aarch64|arm64|armv8b|armv8l)
      echo "arm64" ;;
    arm)
      echo "arm" ;;
    i386|i686)
      echo "386" ;;
    mips)
      echo "mips" ;;
    mips64)
      echo "mips64" ;;
    s390|s390x)
      echo "s390x" ;;
    x86_64)
      echo "amd64" ;;
  esac
}
```

## OS check

```sh
os_name() {
  os="$(uname -o)"
  case "${os}" in
    "GNU/Linux")
      echo "linux" ;;
    "Darwin")
      echo "darwin" ;;
  esac
}
```

## die

```sh
readonly ERR="❌"
die() {
  echo >&2 "${ERR} ${*}"
  exit 1
}
```
