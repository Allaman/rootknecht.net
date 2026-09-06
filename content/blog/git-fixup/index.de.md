---
title: Halte deine Git-Historie ordentlich und sauber
description: "git, fixup, rebase, autosquash, workflow, Versionskontrolle, saubere Historie, Entwicklerproduktivität"
summary: 'Eine praktische Demo von Fixup-Commits mit dem du eine vergessene Änderung an einen früheren Commit anhängen kannst, anstatt „Ups"-Commits anzuhäufen.'
draft: false
date: 2026-09-06
tags:
  - workflow
  - tools
  - git
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/git-fixup/)
{{< /alert >}}

## Warum überhaupt?

Ich mag meine Git-Historie schlicht und sauber. Das heißt, ich möchte weder Merge-Commits noch dutzende Commits der Sorte „fix/typo/xxx vergessen". Ein Werkzeug, um das zu erreichen, sind sogenannte `fixup`-Commits.

{{< figure src=clean-log.png alt="saubere Historie" caption="Was ich für ein perfektes Beispiel einer sauberen Historie halte. Wiederholte Nachrichten zeigen Änderungen pro Umgebung an.">}}

> [!INFO]
> Das neueste Git 2.55 hat den Befehl [git history fixup](https://github.blog/open-source/git/highlights-from-git-2-55/#h-fixing-up-earlier-commits-with-git-history) eingeführt, der einfacher zu handhaben, aber noch [experimentell](https://git-scm.com/docs/git-history/2.55.0) ist, daher bevorzuge ich den erprobten Weg.

## Demo

Ich denke, am besten zeigt sich mit einer kleinen Demo zum Nachmachen, was ein `fixup`-Commit bewirkt.

Wir erstellen ein Git-Repo:

> [!NOTE]
> Die Demo arbeitet auf dem Standard-Branch (main). Normalerweise willst du auf einem Feature-Branch arbeiten, da der `fixup`-Ablauf ein Push mit `--force-with-lease` erfordert.

```sh
git init fixup
```

Wir erstellen ein paar Commits:

```sh
echo "initial commit" > text
git add text && git commit -m "feat: Add initial commit"
echo "second commit" >> text
git add text && git commit -m "feat: Add second commit"
echo "third commit" >> text
git add text && git commit -m "feat: Add third commit"
```

Nun vergessen wir etwas im zweiten Commit, zum Beispiel eine neue Datei:

```sh
echo fixup is nice > second
```

Wenn wir die Änderung einfach zum letzten (dritten) Commit hinzufügen wollten, könnten wir `--amend` verwenden und weitermachen. Das ist aber nicht immer die beste Stelle, wenn du etwas korrigierst, das technisch gesehen zu einem früheren Commit gehört, in diesem Fall zum „second commit".

Mit `--fixup` können wir dieses Problem lösen.

Zuerst brauchen wir den Commit-Hash des Commits, zu dem wir die Änderung „hinzufügen" wollen; wie erwähnt wollen wir den „second commit" als Ziel für unsere Änderung.

```sh
❯ git log --oneline | grep second | awk '{print $1}'
07dcf1b
```

Dann fügen wir die Änderung hinzu und machen einen Fixup-Commit:

```sh
❯ git add second && git commit --fixup 07dcf1b
```

Unser Git-Log sieht jetzt so aus:

```sh
❯ git log --oneline
d6458a0 (HEAD -> main) fixup! feat: Add second commit
8081389 feat: Add third commit
07dcf1b feat: Add second commit
e32ff98 feat: Add initial commit
```

Jetzt müssen wir rebasen und `autosquash` verwenden. Wichtig ist, dass du den Commit-Hash des Commits direkt vor deinem Ziel-Commit („second commit") angibst, hier ist das der „initial commit":

```sh
❯ git rebase -i --autosquash 07dcf1b^ # das Caret bezeichnet den Parent
```

So sieht der Rebase aus:

```sh
pick 07dcf1b feat: Add second commit
fixup d6458a0 fixup! feat: Add second commit
pick 8081389 feat: Add third commit

# Rebase e32ff98..d6458a0 onto e32ff98 (3 commands)
...
```

Unser `fixup`-Commit wurde erkannt und gesquasht, wir können also bestätigen.

Unser Log enthält jetzt nur noch unsere drei Commits:

```sh
❯ git log --oneline
741955c (HEAD -> main) feat: Add third commit
89ff7a0 feat: Add second commit
e32ff98 feat: Add initial commit
```

Und wir sehen, dass unser zweiter Commit beide Änderungen enthält: die hinzugefügte Zeile in der Datei und die neue Datei. (Teile der Ausgabe weggelassen)

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

## Fazit

Dieses Feature existiert seit einer Ewigkeit [^1] und ich habe es erst vor etwa einem Jahr entdeckt ... ich schätze, über (längst existierende) Features zu stolpern ist ein typisches Git-Phänomen.😄 Das hat es so viel einfacher gemacht, meine Git-Historie so zu halten, wie ich sie mag. Was ist eigentlich [jujutsu](https://github.com/jj-vcs/jj) 😉

[^1]: Zumindest seit Git [1.7.0](https://github.com/git/git/blob/master/Documentation/RelNotes/1.7.0.adoc)
