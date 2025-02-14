# UNIX & version control

>In this unit, you get a chance to familiarise yourself a bit more with two bits of key technology that are really helpful for data analysis in general, and for neuroimaging in particular.
>
>The first is the UNIX command line, which is a way to interact with your computer that is text-based. If you continue in research, you'll find that this is a really powerful way to interact with your data and your computer and a bit of time spent now will pay off in the future (bigly!).
>
> The second is the idea of version control - keeping track of changes in a set of files in a project - often used for code, but also for writing, data analysis, etc. We'll use the ``git`` version control system, which is widely used in the open source community and beyond.
>
> Because this unit fall into University of Nottingham's reading week, these exercises are made ot be self-paced. They will help you with your coursework and also research placement and project - but they are not assessed.

## 1. UNIX, the "shell" or "Terminal"

<img src="BASH_logo-transparent-bg-bw.png" width="40%">

### TASK - background tutorial

Complete the interactive tutorial at <https://www.terminaltutor.com/> and take a screenshot of the completion screen.

The website says it takes around 30min to complete the first bit, but you might find that you are much faster - it's definitely time well spent.

### TASK - three scenarios

Think about the following 3 scenearios and write down some ideas of how you might solve them. These are all situations you will often encounter in real (academic /research) life. Knowing how to solve them might save you hours of work down the line... there are many ways to solve these problems, but the UNIX command line is a really powerful tool for this.

You are allowed to talk to each other, use *google* / *stackoverflow* search or even get a large language model (*chatGPT?*) to help you out. **But make sure you understand the solution, in enough detail that you could explain it to someone else!**

1. You have a folder with about 1000 files in it. They are labelled by participant id ('A', 'B', etc.) and a timestamp in the following way: ``A_2022-10-01.dat``, ``B_2022-10-01.dat``, ... etc. **Can you come up with a quick way to count exactly how many files there are for each participant?**

2. You have a folder that contains a bunch of files, some of which are text files (ending in `.txt`), some of which are images (`*.png`), and some of which are data files (`.json`). **Can you make 3 sub-folders called `text`, `images`, and `data` and move the correct files to the corresponding folders?**

3. (**a bit more tricky**). There is a large text file on the web (the url is "https://schluppeck.github.io/dafni/richard_iii.txt"). 
   - Make a folder called `textAnalysis` in your home directory, download the file to that folder (hints: `curl`, redirect to file). 
   - How many lines does this file contain? How many words? (hint: `wc`)
   - How many times does the word "horse" or "Horse" appear in the text? (hint: `grep` ... look at flags for case-insensitive search)
   - on which line(s) does the phrase "A Horse, a Horse, my Kingdome for a Horse" appear? (hint: `grep` with line numbers)

### FEEDBACK - post any comments ideas, questions

<div class="padlet-embed" style="border:1px solid rgba(0,0,0,0.1);border-radius:2px;box-sizing:border-box;overflow:hidden;position:relative;width:100%;background:#F4F4F4"><p style="padding:0;margin:0"><iframe src="https://padlet.com/embed/x678uali6b3ou27w" frameborder="0" allow="camera;microphone;geolocation" style="width:100%;height:400px;display:block;padding:0;margin:0"></iframe></p><div style="display:flex;align-items:center;justify-content:end;margin:0;height:28px"><a href="https://padlet.com?ref=embed" style="display:block;flex-grow:0;margin:0;border:none;padding:0;text-decoration:none" target="_blank"><div style="display:flex;align-items:center;"><img src="https://padlet.net/embeds/made_with_padlet_2022.png" width="114" height="28" style="padding:0;margin:0;background:0 0;border:none;box-shadow:none" alt="Made with Padlet"></div></a></div></div>

Some more details on how to use features of UNIX/bash that are particularly helpful for organising and processing data in the resources just below

### Resources

The people who make ``fsl`` have produced [a collection of short videos](https://www.youtube.com/playlist?list=PLvgasosJnUVnnFifxecbyEno7jnqrl8fQ) that introduce some UNIX commands that are particularly helpful for running an FMRI data analysis with their tools.

For background, there is [a really good online tutorial](https://www.ee.surrey.ac.uk/Teaching/Unix/) hosted at EE at University of Surrey. The terminal / shell. This is a bit more of a deep dive.

You can also have a look at the brief online course at [Software Carpentry](https://swcarpentry.github.io/shell-novice/reference), which looks really good.

### Some basics

- only basics are needed for running FSL analysis
- lots of functionality is available through point-and-click
- **but** command line is helpful for organising (any) research data
- more complex analysis, e.g. ``freesurfer``, require some working knowledge

## 2. Version control, ``git``

<img src="Git-Logo-2Color.png" width="40%">

My (very brief) presentation on version control with git [as a markdown file](./version-control.md) or <a href="./version-control.html" target=_new>[as an HTML presentation]</a>, or [PDF](./version-control.pdf).  

Some really useful background is available in some brief videos produced by https://github.com

### What is version control?

:film_strip: A really clear video explaing this in simple terms [What is version control?](https://git-scm.com/video/what-is-version-control)

### What is ``git``

:film_strip: Have a look at the video on [What is ``git``](https://git-scm.com/video/what-is-git)

### Get going with ``git``

:film_strip: Finally, you can actually [Get going with ``git``](https://git-scm.com/video/get-going), in particular check out  
  ``1:13min`` for configuring ``user.name`` and ``user.email`` - keeping in mind you'll probably want to use a value for ``user.email`` that is your generic / non-university e-mail.

We don't actually need to install this in the computer labs - but on your personal machines you might have to do this. You can use ``which git`` in the Terminal. If you get a valid path back, then you know it's installed. You could also try ``git --version`` to find out which version you have installed on your machine.

### Git basics

:film_strip: A slightly deeper look at ``git`` in the video about [quick wins with ``git``](https://git-scm.com/video/quick-wins)

### a minimal example of making a git repo

```bash
cd ~  # go to home directory
ls -l # list files in long format
mkdir myFirstRepo # make a directory called myFirstRepo
cd myFirstRepo # go into that directory
nano Readme.md  # open a text editor called nano and create a file called Readme.md - 
# Ctrl-O to save, Ctrl-X to exit
ls
ls -l
more Readme.md
ls
git init
git status
git add Readme.md
git status
git commit
git status
git commit -m "this is the first commit. yay"
git status
git log
```
