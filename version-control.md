---
marp: true
---

# Version control with ``git``
<!-- page_number: true -->

![25%](Git-Logo-2Color.png)

##### Denis Schluppeck, 2019-03-01

---
## Why version control?

Lots of good reasons - but the main ones<sup>[1](#myfootnote1)</sup> are:

- a complete **history of changes** (which means you can *undo*)
- **branches** (you can try new stuff out without breaking things)
- you can trace who did what when, **tag** versions of your manuscript / code
	- submitted, published
	- v1.0, feature-release

<br>

<hr>

<a name="myfootnote1"><sup>1</sup></a> see e.g. ["What is version control"](https://www.atlassian.com/git/tutorials/what-is-version-control#benefits-of-version-control)

---
## Imagine a typical project (code / notes)

<center>
  <figure>
    <img src="https://git-scm.com/book/en/v2/images/deltas.png" alt="my alt text" />
    <hr>
    <figcaption>How material changes over time... </figcaption>
  </figure>
</center>

---
## Why ``git``?

There are many *version control systems* (VCS). But ``git`` comes with some advantages:

- it's **distributed** (full version history in your local copy)
- corollary: you can work with it anywhere :airplane: or :train: (no need for network connection)
- it's widely used<sup>1</sup>

<br>

<hr>

<a name="myfootnote1"><sup>1</sup></a> see e.g. ["Wikipedia / git"](https://en.wikipedia.org/wiki/Git)


---
## ``git`` does snapshots

- think of this as snapshots
- what's the state of each file now?

<br>

<center>
  <figure>
    <img src="https://git-scm.com/book/en/v2/images/snapshots.png" alt="my alt text"/>
  </figure>
</center>

---

## How are things tagged?

<center>
  <figure>
    <img src="Fingerprint_picture.svg" alt="fingerprint" height="400p"/>
  </figure>
</center>

<hr>

<tiny>
	<a name="myfootnote1"><sup>2</sup></a> [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0)

</tiny>


---
## How are things tagged?


- each **file** has a unique *fingerprint* (``shasum``)
- if the file changes, the *fingerprint* changes, too!
- ``sha`` = secure hash algorithm
- ``sha`` turns text/data into a 40 digit hexadecimal number

<br>

<hr>

hexadecimal numbers?

<pre>
0...9  10 11 12 13 14   15  # decimal
0...9   a  b  c  d  e    f  # hexadecimal

0 1 10 11 100 101 ...  111  # binary
</pre>
---

## ``shasum`` of a file

```bash
shasum Introduction.md
# b5acbb35abd2511a4c05e48ef58f8990f139793a  Introduction.md
```

<br>

**tiny change, e.g. add a space?!** and calculate SHA again:

<br>


```bash
shasum Introduction.md
# 502bbcb5ab4f0d8127396675dd7d17d7d8b55b0a  Introduction.md
```

... completely different.


---

## How are things tagged (2)?

A similar trick works for a list of directory contents (the "tree")

:arrow_right: **tree hash**

<br>

```code
.
├── analysis
├── stimulusCode
│   └── stims
│       ├── houses
│       ├── normal
│       ├── objects
│       └── scrambled
└── unix-intro
```

---

## How are things tagged (3)? - ``commit``

- information about files (aka **blobs**), their relationship to each other (the **tree**), the previous state (**parent**) and a message make up a ``commit``

<br>

<small>

```bash
$ git cat-file -p HEAD

tree 80fc45cae348efbdbbb652642cf4c22e1ddaaf80
parent b2b3a018fa2569bc5aa54b0b744145f6758bcba7
author Denis Schluppeck <denis.schluppeck@gmail.com> 1517238320 +0000
committer Denis Schluppeck <denis.schluppeck@gmail.com> 1517238320 +0000

fixes http to https
```

</small>

---

## Workflow


<center>
  <figure>
    <img src="https://git-scm.com/images/about/index1@2x.png" alt="my alt text"/>
    <figcaption>Files </figcaption>
  </figure>
</center>


---





---

## Let's try it

- make a directory, ``cd`` into it
- initialize repo

```bash
mkdir test && cd test
git init
```
- make a text file  ``test.txt``
- write something into it and save it

---

## Let's try it (2)

- add to staging area
- ... and try to commit with a message (``-m``)

```bash
git add test.txt
git commit -m 'my first commit'
```
---

## Warnings?

- you'll see some warning messages
- for (only this first time), set up your ``user.name`` and ``user.email``

```bash
git config --global user.name "First Last"    # your name
git config --global user.email "me@gmail.com" #  your email
```

- This info is stored on your machine in a little file, which you can inspect

```
more ~/.gitconfig
```

---

## Now complete the commit

```bash
git status # read what's there

git commit -m 'my first commit'

git status # read what's there NOW
```

---

## If you want this on github

Currently the repository is local to the machine you are working on, if you want to share with your friends and colleagues on ``github.com``, follow instructions at:

https://help.github.com/en/articles/adding-an-existing-project-to-github-using-the-command-line



---
## Notes

- Illustrations linked from https://git-scm.com/book/en/v2/ - Creative Commons license [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/)

- Details on ``shasum`` (available as a UNIX command):
```bash
man shasum  # or
info shasum
```
