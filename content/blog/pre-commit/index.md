---
title: Pre-commit hook for YAML doc-start
summary: In my daily business I have to deal with a lot of YAML files. In my opinion, it is best practice to write `---` (three dashes) at the beginning of a YAML file. This post describes how to utilize Git pre-commit hooks to automatically insert `---` at the beginning of your YAML files before committing them.
description: git, yaml, workflow, best-practices
date: 2022-03-19
tags:
  - devops
  - programming
  - configuration
---

## What even is ---?

From the [YAML spec](https://yaml.org/spec/1.1/#id857577)

> YAML uses three dashes (“---”) to separate documents within a stream

Example:

```yaml
---
doc: 1
foo: bar
---
doc: 2
foo: bar
```

This would be a valid YAML file containing two documents. Although, technically you can write a valid single document YAML file without the three dashes I consider it as best practice to include them in single document YAML files as well.

## What are Git hooks

From the [Git docs](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)

> Like many other Version Control Systems, Git has a way to fire off custom scripts when certain important actions occur. There are two groups of these hooks: client-side and server-side. Client-side hooks are triggered by operations such as committing and merging, while server-side hooks run on network operations such as receiving pushed commits. You can use these hooks for all sorts of reasons.

Furthermore, a `pre-commit` hook is described as follows:

> The pre-commit hook is run first, before you even type in a commit message. It’s used to inspect the snapshot that’s about to be committed, to see if you’ve forgotten something, to make sure tests run, or to examine whatever you need to inspect in the code. Exiting non-zero from this hook aborts the commit ...

This perfectly matches our use case:

**Before** we commit stuff we want to ensure that our YAMLs start with `---`. If `---` is missing we want to add it to the beginning of the file and abort the commit to be able to stash the mad changes.

{{< alert >}}
YAML directives must be written before `---` and are not considered in this use case. Please enhance the script if you have to deal with such YAML files.
{{< /alert>}}

## Automate it!

We don't want to think about if each of our YAML files contain the three dashes. We want an automation that checks and corrects our YAMLs before we commit them. Here is how.

### Python

A rather trivial implementation for checking and inserting `---`. Improve or adjust to your needs.

- `checkDocumentStart` checks each given file if it starts with `---\n`. If not it calls `insertDocumentStart`
- `insertDocumentStart` inserts `---\n` before the file's first line

If `insertDocumentStart` is called the script returns an exit code 1 that tells Git to abort the current commit. This allows you to add the changes made by the script to your previous commit.

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


# Iterate over all yaml/yml files in the current directory
# Exclude all paths containing "special"
directory_name = "."
for subdir, dirs, filenames in os.walk(directory_name):
    # do not touch special folder
    if "special" in dirs:
        dirs.remove("special")
    for filename in filenames:
        path = subdir + os.sep + filename
        if not path.lower().endswith((".yaml", ".yml")):
            continue
        checkDocumentStart(path)

if found:
    print("Please add the changes to your commit")
    # Make pre commit hook fail
    os._exit(1)
```

### Pre-commit

Git hooks are stored in `.git/hooks/`. A default Git repo contains a couple of hooks. To "enable" one of the default hooks just delete the `.sample` extension.

Because we want our team to profit from our pre-commit hook as well we need to distribute it. For security reasons, Git will not push changes in a local `.git/hooks/` directory to the remote repo [^1].

In order to distribute our pre-commit script(s) we put them in our repo just as normal code, e.g. in a folder called `scripts`. Additionally, we add our `pre-commit` script which will be symlinked to `.git/hooks`.

```
.
├── scripts
│   ├── pre-commit
│   └── yaml-doc-start.py
```

The `pre-commit` script just calls all our pre-commit scripts. In this case just the python script but you can add as many scripts as you like.

`❯ cat scripts/pre-commit`

```sh
#!/usr/bin/env bash

python3 scripts/yaml-doc-start.py
```

Now, we can add our `scripts` folder to Git and push it. A colleague of us can "install" the pre-commit hook in his local repo by symlinking it to `.git/hooks`. For convenience, you can also add a Makefile with the following target.

```makefile
hooks: ## Install Git hooks
	@ln -s -f ../../scripts/pre-commit .git/hooks
	@echo "Hooks installed"
```

When running `make hooks` the pre-commit hook will be symlinked to the local Git repo and therefore will be "active".

{{< figure src=precommit.png caption="A symlinked pre-commit hook" >}}

To test your hook you can call `bash .git/hooks/pre-commit`.

Each time when running `git commit` the python script is called and all your repo's YAML files will be processed. If you want to skip the hook you can run `git commit --no-verify`.

[^1]: imagine pushing malicious scripts that are automatically executed 💥
