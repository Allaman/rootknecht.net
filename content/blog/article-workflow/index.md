---
title: Reading/storing articles with Obisidan and Remarkable2
type: posts
draft: false
date: 2022-08-02
tags:
  - workflow
resources:
  - name: rm2
    src: rm2.jpg
    title: This article on my RM2
---

My workflow for reading and storing articles from the web with reMarkable2 and Obsidian.

<!--more-->

---

Whenever I stumble over an interesting article in the web I want to "archive" this article so that I can access it anytime even when the original blog/webpage is shut down. For years I paid for [Pocket](https://getpocket.com/en/) Premium plan that does not only save the URLs but the whole page, keeping the content accessible.

After discovering Obsidian I was shocked how it covers all my plain text wishes while keeping the data under my hood in my file system. Needless to say that I wanted to store my articles in Obsidian! More on that later on.

Fast forward I found a new tool to improve my workflow: The [reMarkable 2](https://remarkable.com/) (RM2). Well new is relative, let's just say I resisted the temptation a long time! Silly me ;) The RM2 is a great piece of technology and not for everyone but I does what it promises and for what I bought it. A distraction free paperlike experience with a touch of digitalisation and a hackable Linux based operation system. But this might be another blog post.

On the one hand, storing my data as text files and working with them through Obsidian is awesome. On the other hand, reading (technical) articles on a ten inch (roughly) E ink device with the portability of the RM2 would be great as well.

This blog post describes my workflow to download, read an store interesting articles.

## Getting the webpage

In the beginning there is a webpage that needs to be downloaded. Traditionally, one would "print" a page as pdf or use a screenshot tool / browser add-on to save an image of the webpage. Obviously, both methods do not fit my plain text workflow. Luckily, there is [MarkDownload](https://addons.mozilla.org/en-US/firefox/addon/markdownload/) a Firefox add-on that takes the webpage and converts/saves it to a markdown file which is the native format of Obsidian! Check!

## Reading the webpage on the RM2

Now things get a little tricky. Markdown is not a supported format for the RM2. We need a pdf file for the RM2. Of course, you might say just print a pdf from your browser! But I will tell you first this is too easy and secondly, and even more important, I am only interested in the text and images of an article and not the stuff around it. MarkDownload will not download/visualize shiny JS or ads.

Let me introduce you [Pandoc](https://github.com/jgm/pandoc). If your are working with text in any form you must know this tool. For me, it's the Swiss army knife for text based files. With Pandoc we can convert a markdown file to pdf like as follows:

```bash
pandoc my-article.md --pdf-engine=tectonic -o my-article.pdf
```

This command will create `my-article.pdf`from `my-article.md`. In my case I set [tectonic](https://github.com/tectonic-typesetting/tectonic) as pdf-engine. Other popular engines are `pdflatex` and `xelatex`. Refer to tutorials how to install [Latex](https://www.latex-project.org/) on your system.

We are getting closer! Now we need to move the pdf to our RM2! As I said, the RM2 is a hackable device so we will stick to good old [SSH](https://en.wikipedia.org/wiki/Secure_Shell) and ditch all cloud solutions!

At first you should get familiar with [SSH access on the RM2](https://remarkablewiki.com/tech/ssh). Keep attention to the stated warnings! When you can connect to your RM2 you must configure `Passwordless Login with SSH Keys`.

After you can connect to your RM2 without a password we are ready for the final step! As RM2 stores files in its own format we **can't** just copy our pdf via `scp` and are done. There are various scripts that create and copy the RM2's internal file structure from a pdf. My choice is [pdf2remarkable.sh](https://github.com/adaerr/reMarkableScripts/blob/master/pdf2remarkable.sh) (read the comments in the file for explanation).

Copying a pdf is as simple as calling the script with the file as argument:

```bash
./pdf2remarkable.sh my-article.pdf
```

The script will create the internal representation of the pdf an copy it over SSH via scp to the RM2 (xochitl needs to be restarted by the script via ENV variable or by you via systemctl restart xochitl).

{{< img name=rm2 lazy=true size=small >}}

[Here](https://github.com/Allaman/dotfiles/blob/master/local/bin/article-to-rm.sh) you can find my complete script integrating all parts.

The script iterates over my Inbox folder and takes every markdown file in it and pushes a generated pdf file to the RM2. Then it moves the markdown files to my Reading folder indicating that I am currently reading them on my RM2. The generated pdfs are deleted at the end.

After reading the article(s) on my RM2 I can decide if they are worth keeping and how to tag them. Afterwards, I move the markdown file out of my reading folder in my vault and enjoy my plain text only database.
