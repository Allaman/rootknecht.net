---
title: Python
summary: Notes on Python
---

## Read file

```python
try:
	content = open(file, 'r').read()
	lines = open(file, 'r').readline()
except IOError as err:
    print(err)
    sys.exit()
```

## Read csv

```python
import csv
with open('FOO.csv', newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=' ', quotechar='|')
    next(reader, None) # skip header row
    for row in reader:
        print(', '.join(row))
```

[More](https://docs.python.org/3/library/csv.html)

## Date and time

```python
time_object = datetime.strptime("19-11-20", '%y-%m-%d').date() # read from string
time_object.strftime("%Y/%m/%d") # print to string
```

## One liner yaml to json

```sh
python -c 'import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=4)' < $FILE
```

## Logging

```python
import logging

loggers = {}

def mylogger(name):
    global loggers

    if loggers.get(name):
        return loggers.get(name)
    else:
        logger = logging.getLogger(name)
        logger.setLevel(logging.DEBUG)
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            '%(asctime)s %(levelname)s %(module)s %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        loggers.update(dict(name=logger))

        return logger
```

```python
from log import mylogger
logger = mylogger(__name__)
logger.info("TEXT")
logger.debug("!!!!")
```

## JSON

```python
import json

json.load(open(file.json, 'r'))
json.loads('{"hello": "world}')
```

## Functional Programming

**Iterate hash**

```python
 list(map(lambda x: x, out))
```

## Upgrade all pip packages

```bash
sudo pip freeze --local | grep -v '"'"'^\-e'"'"' | cut -d = -f 1  | xargs -n1 sudo pip install -U
```

## pip proxy

Windows `%APPDATA%\pip\pip.ini` / Linux pip.conf

```ini
[global]
    proxy = http://[domain name]%5C[username]:[password]@[proxy address]:[proxy port]
```

## pip certificate validation

**pip**

```bash
pip install install --trusted-host pypi.org --trusted-host files.pythonhosted.org
```

or in pip.ini (windowns) / pip.conf (linux)

```ini
[global]
trusted-host = pypi.python.org
               pypi.org
               files.pythonhosted.org
```

or provide certificate (in pem format) with `pip3 --cert path/to/cert install PACAKGE`

**conda**

```bash
conda config --set ssl_verify false
```

## LDAP testing

```python
#!/usr/bin/env python

from ldap3 import Server, Connection, ALL

def ldap_initialize(server, port, user, password):
    """
    Simple ldap connection test function
        :param server: mail server address
        :param port: mail server port
        :param user: user to auth
        :param password: password to auth
    """

    s = Server(server, port, get_info=ALL)
    # define the connection
    c = Connection(s, user, password, auto_bind='NONE', version=3, authentication='SIMPLE', \
    client_strategy='SYNC', auto_referrals=True, check_names=True, read_only=True, lazy=False, raise_exceptions=False)
    # perform the Bind operation
    if not c.bind():
        print('error in bind', c.result)
```

## SMTP testing

```python
import smtplib

from email.mime.text import MIMEText

def send_mail(host, me, you, user, password):
    """
   Send a test mail containing a simple ASCII message
        :param host: mail server + port
        :param me: sender address
        :param you: receiver mail address
        :param user: user to auth
        :param password: password to auth
    """
    msg = MIMEText("Hello World!")
    msg['Subject'] = 'Test mail from Python'
    msg['From'] = me
    msg['To'] = you

    s = smtplib.SMTP(host)
    s.set_debuglevel(True)
    s.login(user, password)
    s.sendmail(me, [you], msg.as_string())
    s.quit()
```

## Generate sha1 password

For example for Jupyter notebooks credentials

```python
In [1]: from IPython.lib import passwd
In [2]: passwd()
```

## CLI arguments and parameters

```python
import click
@click.group()
def main():
    """Main click group"""
    pass


@main.command()
@click.option('--count', default=10, help='number of entries')
@click.option('--path', default='pckt.db', help='path to sqlite3 file')
def update(count, path):
    """Updates/recreates the database containing all information"""
    clear_db(path)
    update_db(path, get_data(fetch_items(P, count)))


@main.command()
@click.option('--path', default='pckt.db', help='path to sqlite3 file')
def tags(path):
    """Prints tags and their figures as json"""
    print(json.dumps(get_tags_stats(select_row(path, 2))))


@main.command()
@click.option('--path', default='pckt.db', help='path to sqlite3 file')
@click.option('--row', default='complete', help='Which column to search')
@click.argument('keywords', nargs=-1)
def search(path, row, keywords):
    """Full text search all rows or specified row"""
    print(filter_entries(path, row, keywords))

if __name__ == '__main__':
    main()
```

## CLI table output

```python
import texttable

table = texttable.Texttable()
table.set_cols_width([width, width, 15, 10, 15])
for row in entries:
    table.add_row(list(row))
print(table.draw() + "\n")
```

## Count occurrence with hash values

'0' if the key is set for the first time. Otherwise adds '1' every assignment

```python
tags[tag] = tags.get(tag, 0) + 1
```

## Check keys of nested dicts

```python
def keys_exists(element, *keys):
    """Check if *keys (nested) exists in `element` (dict).
    Args:
        element (dict): the dictionary to be checked
        keys (string): one or more (nested) keys to check for existence
    Returns:
        bool: True if key exists
    """
    if not isinstance(element, dict):
        raise AttributeError('keys_exists() expects dict as first argument.')
    if len(keys) == 0:
        raise AttributeError('keys_exists() expects at least two arguments, one given.')
    for key in keys:
        try:
            element = element[key]
        except (KeyError, TypeError):
            return False
    return True
```

## Profiling

**cProfile**

```sh
python -m cProfile -o cprofile.profile main.py
```

visualize with `snakeviz cprofile.profile`

**PyCallGrap\***

```bash
pycallgraph graphviz -- ./main.py
```

open `pycallgraph.png`

## Static code analysis

[Pyan}(https://github.com/davidfraser/pyan)

## Verify Redis connection

```python
import redis
import os

try:
    conn = redis.StrictRedis(
        host="localhost",
        port=6379,
        password="s3cret",
        ssl=True,
    )
    print(conn)
    conn.ping()
    print("Connected!")
except Exception as ex:
    print("Error ", ex)
    exit("Failed to connect, terminating.")
```
