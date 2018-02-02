# Data analysis for Neuroimaging - C84DAN
===
<!-- some directives for making things look a certain way -->
<!-- page_number: true -->

##### Denis Schluppeck

---

## What's the plan?

1. Acquire some functional MRI data in a simple, but real experiment
2. Analyze the data with ``fsl`` [(FMRIB webpage)](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki)
3. Learn a bit about ``UNIX`` and version control, in particular ``git`` and ``github``
4. Use ``Matlab`` to inspect and visualise some data

---

## Setting up computers, logins

1. Need to run in Mac mode
2. Each user (at a particular machine) needs to make sure that ``Terminal/shell`` is set up correctly by copying a set-up file the first time they use that computer.
```bash
# copy across new version of .bash_profile
cd ~ # make sure we are in ${HOMEDIR}
cp /Volumes/practicals/ds1/.bash_profile   ~/
# restart shell
```
3. Quick reality check. Look at some existing data (anatomy, fMRI) with ``fslview``
4. Everyone should sign up for a free ``github`` account, so we can work together on this from session 4 onwards: https://github.com/join

### Todo

- [x] set up https://classroom.github.com/
- [x] ``.bash_profile`` basic (local)
- [x] add in ``.git-completion`` script (and document)
- [ ] add info about how to change ``user.name`` and ``user.email`` in ``.gitconfig``
- [ ] test in A5 lab on Macs.

---

## FSL analysis

- get data from sessions ``S001``to ``S004`` into a common folder ``data``
- make folders, copy files by "drag & drop"
- point & click version (like some of you have already done)
- digging into the details of how this is implemented
- inspecting analysis output, intermediate files, ...
-
```bash
cd ~/data/S001/  # for example
```

---

## Some UNIX

- only basics are needed for running FSL analysis
- lots of functionality is available through point-and-click
- **but** command line is helpful for organising (any) research data
- more complex analysis, e.g. ``freesurfer``, require some working knowledge

```bash
# navigate file system
# cd, ls, pwd, which, ...

# some powerful commands for organising your data
# cp, rm, touch, mkdir, rmdir

# some stuff to show of how powerful
# grep, "lists", "wildcards (*, ., ?)"
# "regular expressions"
```

---

## Version control ``git``

- 30min lecture on principles of using version control (``git``)
- start using your (free) ``github.com`` id by working on a simple project
- make your first modifications to a local copy of code and get it into a repo.

```bash
mkdir test && cd test # what does this do?
git init
# [[ create, edit a file, say my_first.md ]]
git add my_first.md  # add it to "staging area"
git commit # enter commit message
# - OR -
git commit -m 'adds first version of file'
git log
```

---


## ``matlab`` - reading images



---


## ``matlab`` - timeseries and subplots


---


## ``matlab`` - text/csv/data & wrap-up
