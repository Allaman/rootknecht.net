---
title: Git
summary: Some notes on working with Git
---

## Git operators

- `HEAD^` is one commit before HEAD
- `HEAD~4` is four commits before HEAD

## Change remote of an existing repo

Check current urls:

```bash
git remote -v
```

Switch urls:

```bash
git remote set-url origin NEWURL
```

Compare change

```bash
git remote -v
```

Push to new remote

```bash
git push -u origin master
```

## Run git command over all subdirectories

```bash
find . -maxdepth 1 -type d -exec git --git-dir={}/.git --work-tree=$PWD/{} pull \;
```

## Proxy settings

```bash
git config --global http.proxy http://proxy.company.com:3128
```

or in .git/config

```ini
[http]
	proxy = http://proxy.company.com:3128
```

or temporarily as command line argument

```bash
-c http.proxy http://proxy.company.com:3128
```

## Disable certificate validation

```bash
git config --global http.sslVerify=false
```

or in .git/config

```ini
[http]
sslVerify = false
```

or temporarily as command line argument

```bash
-c http.sslVerify=false
```

## Show the current branch

```bash
git rev-parse --abbrev-ref HEAD
```

## Use Github and Gitlab

### Use multiple remotes named differently

```bash
git remote add github https://github.com/USER/repo.git
git push/pull origin
git push/pull github
```

When the origin is at github vice versa.

### Single remote with multiple targets

```bash
git remote set-url –add origin https://github.com/USER/repo.git
git push/pull origin
```

When the origin is at Github vice versa. Now, origin will target Gitlab as well as Github remotes

## Edit git config with editor

```bash
git config [--global] --edit
```

## Set git file endings to LF (msysgit)

```sh
git config --global core.autocrlf false
git config --global core.eol lf
```

## Debug git command

```sh
GIT_CURL_VERBOSE=1 GIT_TRACE=1 git pull
```

even more output:

```sh
set -x; GIT_TRACE=2 GIT_CURL_VERBOSE=2 GIT_TRACE_PERFORMANCE=2 GIT_TRACE_PACK_ACCESS=2 GIT_TRACE_PACKET=2 GIT_TRACE_PACKFILE=2 GIT_TRACE_SETUP=2 GIT_TRACE_SHALLOW=2 git pull origin master -v -v; set +x
```

## List all repos a Github user is allowed to access

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Small CLI script to list basic overview of our Github repositories

- Access and repositories are based upon the user's permissions
- Default output is a SingleTable (fancier) but ASCII Table is supported as well
- Show last commit only since a defined period of time to limit required API calls

Install dependencies with 'pip3 install --user PyGithub, terminaltables' or appropriate command
"""
__version__ = "1.0.0"

from datetime import datetime, timedelta
import argparse
from github import Github
from terminaltables import AsciiTable, SingleTable

def main(args):
    """ entry point """
    g = Github(args.token)

    data = [['Name', 'URL', 'Tags', 'Branches', 'Last Commit']]

    since = datetime.now() - timedelta(days=args.days)

    for repo in g.get_user().get_repos():
        # to see all the available attributes and methods
        # print(dir(repo))
        commits = repo.get_commits(since=since)
        date = 'unknown'
        author = 'unknown'
        try:
            if commits.totalCount > 0:
                last_commit = commits[0]
                date = last_commit.last_modified
                author = last_commit.author.login
        except:
            pass # empty repo found ^^
        name = repo.name
        url = repo.clone_url
        tags = []
        for tag in repo.get_tags():
            tags.append(tag.name)
        branches = []
        for branch in repo.get_branches():
            branches.append(branch.name)
        data.append([name, url, '\n'.join(tags), '\n'.join(branches), f"{date} by {author}"])

    if (args.a):
        table = AsciiTable(data)
    else:
        table = SingleTable(data)
    table.inner_row_border = True
    print(table.table)

if __name__ == "__main__":
    """ Executed from the commandline"""
    parser = argparse.ArgumentParser(description='Terminal Github Overview for Innio')
    parser.add_argument('-t', '--token', action='store', required=True, help='your Github API token')
    parser.add_argument('-d', '--days', action='store', type=int, default=1, help='list commits since x days')
    parser.add_argument('-a', action='store_true', default=False, help='use simple ASCII table as output')
    parser.add_argument('-v', action='version',version='%(prog)s (version {version})'.format(version=__version__))
    args = parser.parse_args()
    main(args)

```

## Remove submodule

How to remove a submodule from a git repository[^1]

1. Remove the relevant `.gitmodules` section
2. `git add .gitmodules`
3. Remove the relevant `.git/config` section
4. `git rm --cached /path/to/submodule` (no trailing slash)
5. `git commit -m "Remove submodule"`
6. `rm -rf /path/to/submodule`

## old mode 100755 new mode 100644

```
git config core.filemode false
```

## Integrating branches

### With merge

```sh
git checkout feature
git merge master
```

This results in a merge commit and may pollute the commit log but it **preserves history** in contrast to `rebase`

### With rebase

**Don't do that on public branches where multiple devs are working on as this will rewrite the commit history according to your local branch!**

```sh
git checkout feature
git rebase master
```

## Delete branches

```sh
git push -d <remote_name> <branch_name>
git branch -d <branch_name> # only delete a local branch
```

`-D` forces the deletion when the branch is not merged in

```sh
# Delete local branches that do not exist on remote anymore
git remote prune origin
```

## Delete tags

```sh
# alternative approach
git push --delete origin <tag>
git tag -d <tag> # only delete local tag
```

## Undo

### Undo public change

**Use case**: After a `git push` you realize a commit is wrong

**Undo**: `git revert <SHA>`

This will create a new commit that reverts the specified commit

### Fix commit message

**Use case**: Typo in commit message "before" `git push`

**Undo**: `git commit --amend -m "Fixed commit message"`

This will update and replace the most recent commit. Be aware that staged changes will be included as well so in order to just fix the commit message ensure that there are no staged changes.

### Undo local change

**Use case**: After editing local files nothing is working and you want to undo everything you have done.

**Undo**: `git checkout -- <filename>`

This will modify the file to a state known to git. Be aware that you cannot recover this as nothing was ever committed!

### Reset local change

**Use case**: You made local commits (not yet pushed) and you want to undo the last four commits without any leftovers.

**Undo**: `git reset [--hard] <last good SHA>`

This will rewind the history of your repo back to the specified SHA as if the commits never happened. By default, `git reset` only removes the commits but not the content on disk. `--hard` option will also remove the changes on disk.

### Redo after undo local change

**Use case**: After `git reset --hard` you changed your mind and want the changes back

**Undo**: `git reflog`

This will show a list of times **Use case** `HEAD` changed.

### Wrong branch

**Use case**: You made some commits accidenttally on master instead a feature branch.

**Undo**: `git branch feature`, `git reset --hard origin/master`, `git checkout feature`

This will

1. create a branch named "feature" pointing to the most recent commit while still in master
2. Rewinds master back to origin/master before your new commits while they still exist on "feature" branch
3. Switch to the new "feature" branch with all the recent work

### Branch in

**Use case**: Branch named "feature" branch started from master but you realized that after syncing master with origin/master that master was far behind. Now commits on "feature" should start now instead of being behind.

**Undo**: `git checkout feature`, `git rebase master` (compare [Integrate branches](#integrate-branches))

This will

1. locate the common ancestor between "feature" and master
2. reset "feature" to that ancestor while holding all commits in a temporary area
3. advance "feature" to the end of master and replay all commits from the temporary area after master's last commit

### Mass undo/redo

**Use case**: You have a dozen commits but only want some of them and the rest should disappear

**Undo**: `git rebase -i <earlier SHA>`

This will start rebase in interactive mode like above but before replaying any commits you have the chance to modify each commit.

- `pick` is the default action meaning the commit will be applied
- to delete commits just delete the line
- `reword` to preserve the content of the commit and rewrite the commit message. Be aware that you cannot edit the message here as rebase ignores everything after the SHA column. After finishing rebasing you will be prompted for new messages.
- `fixup` or `sqash` to combine commits "upwards". squash will create a new commit and ask for a new commit message. fixup will use the message from the first commit in the list.
- reorder commits by changing the order before saving

### Fix an earlier commit

**Use case**: You forgot to include a file in an earlier commit. You haven't pushed yet but it also is not the most recent commit (--amend won't work)

**Undo**: `git commit --sqash <SHA of the earlier commit>`, `git rebae --autosqash -i <even earlier SHA>`

This will

1. create a new commit with a message like "squash! Earlier commit"
2. launch an interactive rebase with any squash! (and fixup!) commits already paired to the commit target

### Stop tracking a tracked file

**Use case**: Accidenttaly, you added a wrong file to the repo

**Undo**: `git rm --cached <filename>`

This will remove the file from git but preserves the content on disk

### Modify past commits

Start the rebase at the last "good" commit

```bash
git rebase -i -p COMMITHASH
```

or start from the initial commit with

```bash
git rebase -i --root $tip
```

After this command a text editor will open. Edit the keywords at the beginning of the line, in this case `edit` allows us to modify the commits. After saving the file the first commit to be edited will be selected. Now you can run e.g.

```bash
git commit --amend --author="Michael <allaman@rootknecht.net>" --no-edit
```

to modify the author. Then run

```bash
git rebase --continue
```

to go to the next marked commit. After rebasing run

```bash
git push --force-with-lease
```

to push your modifications.

[^1]: [origin](https://gist.github.com/myusuf3/7f645819ded92bda6677)
