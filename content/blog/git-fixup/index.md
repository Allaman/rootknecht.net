---
title: Keep your Git history tidy and clean
description: "git, fixup, rebase, autosquash, workflow, version control, clean history, developer productivity"
summary: 'A hands-on demo of fixup commits that lets you attach a forgotten change to an earlier commit instead of piling up "oops" commits.'
draft: false
date: 2026-09-06
tags:
  - workflow
  - tools
  - git
---

## Why Even Bother?

I like my Git history plain and clean. That means I don't want to have merge commits nor dozens of "fix/typo/forgot xxx" type commits. One tool to achieve this are so called `fixup` commits.

{{< figure src=clean-log.png alt="clean history" caption="What I consider a perfect example for a clean history. Repeated messages indicate changes per environment.">}}

> [!INFO]
> The latest Git 2.55 introduced the [git history fixup](https://github.blog/open-source/git/highlights-from-git-2-55/#h-fixing-up-earlier-commits-with-git-history) command, which is easier to handle but still [experimental](https://git-scm.com/docs/git-history/2.55.0), so I prefer the battle tested way.

## Demo

I think it is best to show what a `fixup` commit does with a little demo you can follow.

We create a Git repo:

> [!NOTE]
> The demo targets the default (main) branch. You usually want to work on a feature branch because the `fixup` flow requires push with `--force-with-lease`.

```sh
git init fixup
```

We create some commits:

```sh
echo "initial commit" > text
git add text && git commit -m "feat: Add initial commit"
echo "second commit" >> text
git add text && git commit -m "feat: Add second commit"
echo "third commit" >> text
git add text && git commit -m "feat: Add third commit"
```

Now we forget something in the second commit, for instance a new file:

```sh
echo fixup is nice > second
```

Now, if we just want to add the change to the latest (third) commit we could just use `--amend` and move on. However, this is not always the best place if you fix something that technically belongs to a former commit, in this case the "second commit".

With `--fixup` we can solve this problem.

First, we need the commit hash of the commit that we want to "add" the change, as mentioned, we want the "second commit" as "target" for our change

```sh
❯ git log --oneline | grep second | awk '{print $1}'
07dcf1b
```

Then we add the change and do a fix up commit:

```sh
❯ git add second && git commit --fixup 07dcf1b
```

Our git log now looks like this:

```sh
❯ git log --oneline
d6458a0 (HEAD -> main) fixup! feat: Add second commit
8081389 feat: Add third commit
07dcf1b feat: Add second commit
e32ff98 feat: Add initial commit
```

Now we need to rebase and `autosquash`. It is important that you provide the commit hash of the commit right before your target commit ("second commit"), here it is the "initial commit":

```sh
❯ git rebase -i --autosquash 07dcf1b^ # the caret indicates the parent
```

This is how the rebase looks like:

```sh
pick 07dcf1b feat: Add second commit
fixup d6458a0 fixup! feat: Add second commit
pick 8081389 feat: Add third commit

# Rebase e32ff98..d6458a0 onto e32ff98 (3 commands)
...
```

Our `fixup` commit was detected and squashed so we can accept.

Our log has now just our three commits:

```sh
❯ git log --oneline
741955c (HEAD -> main) feat: Add third commit
89ff7a0 feat: Add second commit
e32ff98 feat: Add initial commit
```

And we can see that our second commit contains both changes, the added line in the file and the new file. (some output omitted)

```sh
❯ git --no-pager show 89ff7a0
commit 89ff7a00fab852c01ad5c5588f85d05e86d3a322

new file mode 100644
index 0000000..8a63c6c
+++ b/second
@@ -0,0 +1 @@
+fixup is nice
diff --git a/text b/text
@@ -1 +1,2 @@
 initial commit
+second commit
```

## Verdict

This feature exists for an eternity [^1] and I only discovered it a year back or so ... I guess to stumble over (long existing) features is a typical Git phenomenon.😄 This made keeping a Git history how I like so much easier. What even is [jujutsu](https://github.com/jj-vcs/jj) 😉

[^1]: At least since Git [1.7.0](https://github.com/git/git/blob/master/Documentation/RelNotes/1.7.0.adoc)
