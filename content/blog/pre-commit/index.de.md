---
title: Pre-commit-Hook für YAML-doc-start
summary: In meinem täglichen Geschäft habe ich es mit vielen YAML-Dateien zu tun. Meiner Meinung nach ist es Best Practice, `---` (drei Bindestriche) am Anfang einer YAML-Datei zu schreiben. Dieser Beitrag beschreibt, wie Git-Pre-Commit-Hooks genutzt werden können, um `---` automatisch am Anfang der YAML-Dateien einzufügen, bevor sie committed werden.
description: git, yaml, workflow, best-practices
date: 2022-03-19
tags:
  - devops
  - programming
  - configuration
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/pre-commit/)
{{< /alert >}}

## Was ist überhaupt ---?

Aus der [YAML-Spezifikation](https://yaml.org/spec/1.1/#id857577):

> YAML uses three dashes ("---") to separate documents within a stream

Beispiel:

```yaml
---
doc: 1
foo: bar
---
doc: 2
foo: bar
```

Das wäre eine gültige YAML-Datei mit zwei Dokumenten. Obwohl man technisch gesehen eine gültige Ein-Dokument-YAML-Datei ohne die drei Bindestriche schreiben kann, halte ich es für Best Practice, sie auch in Ein-Dokument-YAML-Dateien einzuschließen.

## Was sind Git-Hooks?

Aus der [Git-Dokumentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks):

> Like many other Version Control Systems, Git has a way to fire off custom scripts when certain important actions occur. There are two groups of these hooks: client-side and server-side. Client-side hooks are triggered by operations such as committing and merging, while server-side hooks run on network operations such as receiving pushed commits. You can use these hooks for all sorts of reasons.

Ein `pre-commit`-Hook wird wie folgt beschrieben:

> The pre-commit hook is run first, before you even type in a commit message. It's used to inspect the snapshot that's about to be committed, to see if you've forgotten something, to make sure tests run, or to examine whatever you need to inspect in the code. Exiting non-zero from this hook aborts the commit ...

Das passt perfekt zu unserem Anwendungsfall:

**Bevor** wir etwas committen, wollen wir sicherstellen, dass unsere YAMLs mit `---` beginnen. Wenn `---` fehlt, wollen wir es am Anfang der Datei hinzufügen und den Commit abbrechen, damit wir die Änderungen hinzufügen können.

{{< alert >}}
YAML-Direktiven müssen vor `---` geschrieben werden und werden in diesem Anwendungsfall nicht berücksichtigt. Bitte das Skript erweitern, wenn solche YAML-Dateien verarbeitet werden müssen.
{{< /alert>}}

## Automatisieren!

Wir wollen nicht darüber nachdenken müssen, ob jede unserer YAML-Dateien die drei Bindestriche enthält. Wir wollen eine Automatisierung, die unsere YAMLs vor dem Commit überprüft und korrigiert. So geht's.

### Python

Eine recht triviale Implementierung zur Überprüfung und Einfügung von `---`. Nach Bedarf verbessern oder anpassen.

- `checkDocumentStart` prüft jede angegebene Datei, ob sie mit `---\n` beginnt. Wenn nicht, ruft es `insertDocumentStart` auf.
- `insertDocumentStart` fügt `---\n` vor der ersten Zeile der Datei ein.

Wenn `insertDocumentStart` aufgerufen wird, gibt das Skript den Exit-Code 1 zurück, der Git anweist, den aktuellen Commit abzubrechen. So können die vom Skript vorgenommenen Änderungen zum vorherigen Commit hinzugefügt werden.

```python
#!/usr/bin/env python3

import os
import sys
from pathlib import Path

found = False


def insertDocumentStart(path):
    p = Path(path)
    contents = p.read_text()
    contents = "---\n" + contents
    p.write_text(contents, encoding="utf8")
    return contents


def checkDocumentStart(path):
    global found
    with open(path, "r") as file:
        first_line = file.readline()
        if first_line != "---\n":
            print(f"Inserting document-start in '{path}'")
            found = True
            insertDocumentStart(path)


# Über alle yaml/yml-Dateien im aktuellen Verzeichnis iterieren
# Alle Pfade mit "special" ausschließen
directory_name = "."
for subdir, dirs, filenames in os.walk(directory_name):
    # Speziellen Ordner nicht anfassen
    if "special" in dirs:
        dirs.remove("special")
    for filename in filenames:
        path = subdir + os.sep + filename
        if not path.lower().endswith((".yaml", ".yml")):
            continue
        checkDocumentStart(path)

if found:
    print("Please add the changes to your commit")
    # Pre-commit-Hook fehlschlagen lassen
    os._exit(1)
```

### Pre-commit

Git-Hooks werden in `.git/hooks/` gespeichert. Ein Standard-Git-Repo enthält eine Reihe von Hooks. Um einen der Standard-Hooks zu „aktivieren", einfach die `.sample`-Erweiterung entfernen.

Da wir möchten, dass unser Team ebenfalls von unserem Pre-Commit-Hook profitiert, müssen wir ihn verteilen. Aus Sicherheitsgründen werden Änderungen in einem lokalen `.git/hooks/`-Verzeichnis von Git nicht in das Remote-Repo gepusht[^1].

Um unsere Pre-Commit-Skripte zu verteilen, legen wir sie in unserem Repo wie normalen Code ab, z. B. in einem Ordner namens `scripts`. Zusätzlich fügen wir unser `pre-commit`-Skript hinzu, das in `.git/hooks` verlinkt wird.

```
.
├── scripts
│   ├── pre-commit
│   └── yaml-doc-start.py
```

Das `pre-commit`-Skript ruft einfach alle unsere Pre-Commit-Skripte auf. In diesem Fall nur das Python-Skript, aber es können beliebig viele Skripte hinzugefügt werden.

`❯ cat scripts/pre-commit`

```sh
#!/usr/bin/env bash

python3 scripts/yaml-doc-start.py
```

Jetzt kann der `scripts`-Ordner zu Git hinzugefügt und gepusht werden. Ein Kollege kann den Pre-Commit-Hook in seinem lokalen Repo „installieren", indem er ihn nach `.git/hooks` verlinkt. Der Bequemlichkeit halber kann ein Makefile mit folgendem Target hinzugefügt werden:

```makefile
hooks: ## Git-Hooks installieren
	@ln -s -f ../../scripts/pre-commit .git/hooks
	@echo "Hooks installed"
```

Beim Ausführen von `make hooks` wird der Pre-Commit-Hook in das lokale Git-Repo verlinkt und ist damit „aktiv".

{{< figure src=precommit.png caption="Ein verlinkter Pre-Commit-Hook" >}}

Um den Hook zu testen, kann `bash .git/hooks/pre-commit` ausgeführt werden.

Jedes Mal, wenn `git commit` ausgeführt wird, wird das Python-Skript aufgerufen und alle YAML-Dateien des Repos werden verarbeitet. Wenn der Hook übersprungen werden soll, kann `git commit --no-verify` ausgeführt werden.

[^1]: Man stelle sich vor, bösartige Skripte zu pushen, die automatisch ausgeführt werden 💥
