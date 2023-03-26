---
title: "How is this page built (and why)"
type: posts
date: 2019-09-15
tags:
  - web
  - opinion
---

{{< hint alert >}}
I switched from Hugo to Grav. A follow up will come shortly
{{< /hint >}}

In this article I explain why I have chosen [Grav CMS](https://getgrav.org/), maybe a rather unknown solution, for [knowledge.rootknecht.net](#).

<!--more-->

## Classic CMS

The main players in the area of heavy duty CMSs are [Wordpress](https://wordpress.org/), [Joomla](https://www.joomla.com/), [Drupal](http://www.drupal.org/) and [Typo3](https://typo3.org/). I have tried Wordpress and I run a hosted Joomla instance. All of these are an overkill for my use case of a relatively simple and small webpage considering the complexity in operation and usage. This always reminds me of my early beginnings in computer science when I started Visual Studio for a Hello World :-)

## Static site generators

I like static site generators quite well. They are simple, hackable and secure. Hackable by me of course and secure because there is no database and no _insert-dynamic-web-language-server_ involved, just plain HTML and some CSS and JavaScript. Unfortunately, they are limited in some way. There is no web gui, everything needs to be done in files through an editor. This is somehow limiting as I want to edit my page also when I am not at my privat workstation.
Some major static site generators are

- [Hugo](https://gohugo.io/) &#8594; written in Go (very fast), powerful shortcodes
- [Jekyll](https://jekyllrb.com/) &#8594; written in Ruby, powers Github pages
- [Nikola](https://getnikola.com/) &#8594; written in Python, works well with orgmode
- and many more

## "New" CMS

There are quite a few new CMS systems which try to fill the gap between the full fledged classic CMSs and the minimalistic static site generators.

### Commercial systems

Commercial systems like [Kirby](https://getkirby.com/) or [statamic](https://statamic.com/) were from the beginning no option. First, I want to focus on public, community driven tools and second I don't know if I will work on my homepage enough to justify the money (although both are payable) ;-)

### DB driven

I don't like databases :-D Furthermore, I am a huge fan of plain text files as they are so easy to handle. No worry for backups, just zip the whole folder, no pain after database/schema upgrades and no SQL injections ;-)

### Flat file driven

Unlike static site generators which are also flat file driven the major benefit of flat file driven CMSs is the combination of both, the classic CMSs and the static site generators, worlds.
First of all let me summarize my requirements:

1. No database
2. Just markdown - not much struggle with HTML,JavaScript, ...
3. A web user interface

I looked at four systems:

1. [OctoberCMS](https://octobercms.com/) &#8594; Looks quite promising for someone with no fear to start from the almost scratch but for me it is too much HTML and JavaScript struggle
2. [Bludit](https://www.bludit.com/) &#8594; Nice web ui but sadly stores data as json which are not intended to be directly edited
3. [Pico](http://picocms.org/) &#8594; Does not provide a web ui
4. [Grav](https://getgrav.org/) &#8594; Has everything I needed (and more a even didn't know I would need :-D )

## Improve Grav Performance

An overview of techniques to improve Grav page speed to increase the rank in various kinds of web performance raks

- Enable compression
- Minify CSS, HTML, and JavaScript
- Optimize images
- Browser cache control
- Activate cache in grav (here Redis)
- Enable HTTP/2
