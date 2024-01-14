---
title: Revealjs
summary: Revealjs is my preferred way of making presentations
---

[Revealjs](https://github.com/hakimel/reveal.js/) is a framework for producing nice looking HTML presentations.

<iframe width="100%" height="600" marginheight="0" marginwidth="0" frameborder="0" allowfullscreen src="https://allaman.github.io/reveal-js-intro/">
 [Direct Link to Slides](https://allaman.github.io/reveal-js-intro/)
</iframe>

[Here](https://github.com/Allaman/reveal-js-intro) you can find the source code and [here](https://allaman.github.io/reveal-js-intro/) the direct link to the presentation to illustrate Revealjs.

## Frontmatter

```toml
---
title: Revealjs Introduction
theme : "moon"
transition: "zoom"
highlightTheme: "darkula"
slidenumber: true
separator: ^---
verticalSeparator: ^--
showNotes: true ## Export notes in pdf
## showNotes: "separate-page" for longer notes
---
```

## Image formatting

for `reveal-md`

```
![](bad.jpg) <!-- .element height="65%" width="65%" -->
```

for `pandoc`

```
![](image.png){#id .class width=65% height=65%}
```

## Slide background

for `reveal-md`

```html
<!-- .slide: data-background="./background.png" -->
<!-- .slide: style="color:yellow" -->
```

for `pandoc`

```html
# {data-background-image="background.jpg"}
```

## Bulletpoints animation

```markdown
- Emacs, VS Code, Vim <!-- .element: class="fragment" -->
- R Studio, Jupyter <!-- .element: class="fragment" -->
- reveal-md Pandoc <!-- .element: class="fragment" -->
```

## Generate static HTML files

with `reveal-md`

```sh
reveal-md -css custom.css presentation.md --static public
```

with `pandoc`

```sh
pandoc -t revealjs -s -o public/index.html presentation.md -V revealjs-url=reveal.js --css=custom.css --slide-level=2 [--self-contained]
```
