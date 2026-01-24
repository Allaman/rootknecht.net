---
title: "I Tried to Replace Obsidian — and Ended Up Appreciating It Even More"
summary: I tested AFFiNE, Anytype, and Appflowy as self-hosted alternatives to Obsidian. The result surprised me — and changed how I see Obsidian.
description: Comparing AFFiNE, Anytype, and Appflowy as self-hosted Obsidian alternatives for personal knowledge management (PKM).
date: 2026-01-24
tags:
  - productivity
  - self-hosted
  - my experience
---

## Overview of my system

Just to give you some context. This is what I currently use:

1. Notes/memos on the go or if I have no time to type: [Plaud Note Pro](https://www.plaud.ai/) (no sensitive notes).
2. Creative work, sketching ideas, meeting notes, shopping list: [Supernote](https://supernote.eu/) (in conjunction with Supernote's [private cloud](https://rootknecht.net/blog/supernote-private-cloud/)).
3. My task management: [donetick](https://github.com/donetick/donetick) (self-hosted)
4. My long term PKM: Right now [Obsidian](https://obsidian.md/) - what this post is all about.

I really just look for a place for everything, mostly text-based, that I want to keep and remember. I have dedicated apps for notes, sketching, and project/task management.

## Why even leave Obsidian

- The separation of editing and view mode is annoying.
- Obsidian can be everything, but I don't need that much power and customizability.
- (larger) Markdown tables are cumbersome to edit, especially when you want to write "rich" content (links, emojis, images).
- This is just my brain, but I always hesitate to add files other than Markdown to my vault because I am afraid of mess or wasted space 🤦‍♂️
- The interface and options can be overwhelming which prevents me from using it sometimes.[^2]
- I always find [Notion](https://www.notion.com/) so fancy and shiny 🫣, but Notion is no option for me [^3]

## What am I looking for

- Self-hosted
- A good mobile experience, at least for reading. My main use case on the go is usually only reading or searching my notes
- Good image and file handling
- Easy to use and intuitive
- Runs on macOS, Linux, Android, iOS
- Pleasant to look at

Nice to have:

- Collaboration features
- Web app

## Approach

I made a selection of three tools[^1] that, in my opinion, are worth trying out and do some practical tests.

- [AFFiNE](https://affine.pro/)
- [Anytype](https://anytype.io/)
- [Appflowy](https://appflowy.com/)

My testing approach was to write my opinion and results for each tool within the tool itself. Obsidian is used to write the actual blog post.

This approach is by no means comprehensive and your mileage might vary depending on your workflow. For instance, I do not give a f\*ck about AI and calendar integration.

## High-level overview

| Feature        | Obsidian 1.11.5                                                                    | AFFiNE 0.25.7 | anytype 0.53.1 | Appflowy 0.10.8 |
| -------------- | ---------------------------------------------------------------------------------- | ------------- | -------------- | --------------- |
| Self-hosted    | I don't, but it is possible                                                        | Yes           | Yes            | Yes             |
| Mobile         | Good ([1.11.](https://obsidian.md/changelog/2026-01-12-mobile-v1.11.4/))           | Good          | OK             | Good            |
| Emojis         | [Plugin](https://github.com/oliveryh/obsidian-emoji-toolbar)                       | No            | No             | Yes             |
| Tables         | OK                                                                                 | Good          | Good           | Good            |
| Image handling | Bad                                                                                | Good          | Good           | Bad             |
| Columns        | [Plugin](https://github.com/efemkay/obsidian-modular-css-layout)                   | No            | Yes            | Yes             |
| Collab         | [Limited](https://help.obsidian.md/sync/collaborate)                               | Yes           | Yes            | Yes             |
| Web app        | [Extra work](https://github.com/sytone/obsidian-remote)                            | Yes           | local-mode     | Yes             |

## AFFiNE

### Self-hosting

- [Docker compose](https://docs.affine.pro/self-host-affine/install/docker-compose-recommend) with Nginx reverse proxy and TLS took me about 20 minutes
- Deployment consists of only three containers which should make operation and maintenance easier

### Main organization entities

1. Workspace
2. Document
    1. Page mode
    2. Edgeless Canvas (not my use case so no opinion on that)
3. Journals (not my use case so no opinion on that)

### What I like

- Very clean and intuitive interface
- Tabs
- Split view
- Link handling (cards and inline)
- Image handling
- Collab feature might be good for families and teams but not my use case
- Right sidebar (toggle-bar) similar to Obsidian (ToC, properties, and more)
- Property handling similar to Obsidian
- Export (PNG, MD, HTML, Snapshot)

### What I don't like

- Keyboard shortcuts are not configurable
- No cover
- No search and replace
- No emojis
- Self-hosted version is not unlimited

## Anytype

### Self-hosting

- Didn't get self-hosting to work
  - [any-sync-dockercompose](https://github.com/anyproto/any-sync-dockercompose)
  - Time-boxed for ca. 45 minutes
  - Highly complex (compose consists of 14 services and dozens of env vars)
  - Deploying is one thing, maintenance, and upgrades another
- "Local-only mode" works on my macOS 15.7 and iOS 26.1

### Main organization entities

1. Channels
2. Objects
    1. Pages
    2. Notes
    3. Bookmarks
    4. Projects
    5. Images
    6. and more
    7. Custom objects

### What I like

- Objects seem to be quite powerful
- Obsidian import possible but needs quite some cleanup
- Reference other pages (objects) via `/` and autocompletion
- Dedicated Notes, Bookmarks, Images, and more objects
- Keyboard shortcuts are configurable
- Image alignment and handling
- The (right) sidebar is not as sophisticated and only shows the table of contents
- Supports Mermaid, LaTeX, Drawio, and Excalidraw
- Marking and moving multiple objects (e.g. bullet points) is very intuitive
- Columns (intuitive if you [know how to](https://www.reddit.com/r/Anytype/comments/192omvq/how_to_create_columns_like_in_the_anytype_demo/) 😅)

### What I don't like

- Web link handling is awkward coming from years of writing [foo](www.bar.com)
- Collapsing/Folding not possible via mouse and not working via shortcut
- No search and replace
- No emojis
- Code block is not configurable (line numbers, caption) and not foldable
- No tabs and no split view
- Dark mode is **very** dark
- Self-hosting is complex

## Appflowy

### Self-hosting

- Docker compose with Nginx as reverse proxy and TLS in ~1 hour
- High complexity (10 services in compose file) but less than Anytype. AFFiNE has the lead.

### Main organization entities

1. Workspace(s)
2. Space(s)
3. Document, Grid, Board, Calendar

### What I like

- Built-in emoji picker
- Very simple and clean interface (my preference: AFFiNE -> Appflowy -> Anytype)
- Tabs
- Many fonts available
- Columns
- Tables have header rows, colors, and alignment

### What I don't like

- No search and replace
- No split view
- AI focused
- Image handling. A pasted image is inserted in full size and no options to change anything
- Foldable headers are a dedicated type in contrast to normal headers
- Only headers 1-3
- Can't add a photo from the camera on mobile
- No export to PDF, etc
- Disconnecting issues

## Verdict or why Obsidian is superior

During my tests and writing this blog post, I realized (again) how versatile Obsidian is and not all is about shiny things. Here are seven reasons to keep Obsidian:

1. It is very calming knowing that all data **is easily accessible as text files**. Additionally, this gives me the possibility to query or edit my files with powerful command-line tools like [yq](https://github.com/mikefarah/yq) (for parsing the front matter), [ripgrep](https://github.com/BurntSushi/ripgrep), [Neovim](https://neovim.io/), and more. I don't need to bother how to extract data from any database, no matter if "just" SQLite or PostgreSQL.
2. Backup is easy. I just need to copy all files somewhere. That's it. No need to pay attention to database dump consistency and verifying if backups actually work.
3. **No maintenance** for Obsidian. Though this is a bad comparison because I should run Obsidian as self-hosted server to be able to compare it. However, I do trust Obsidian's E2E encryption enough to use their [Sync](https://obsidian.md/sync).
4. Obsidian is so **hackable** and has a large community (of plugin developers). Obsidian can almost be everything you want it to be.
5. None of the above tools offer a **search and replace** or a global search. Especially the latter one is useful for searching all your notes for specific keywords.
6. While all three tested alternatives look fancy and Notion-like, I appreciated the **raw efficiency of Markdown** again.
7. The **mobile app is powerful** and not a trimmed down version of Obsidian.

[^1]: I swear, I did some research and did *not* just pick the first three sorted by the name 😅

[^2]: If you own a [Boox](https://www.boox.com/) device you may feel the same. Though much more powerful I like [Remarkable](https://remarkable.com/) and [Supernote](https://supernote.eu/) devices more because they are not so cluttered.

[^3]: Privacy concerns, bad mobile App, "Enshittification" is close (just my opinion based on nothing more than my stomach)
