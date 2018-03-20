# Manipulating text, notes and other data in Matlab

## Session aims

The aims of this lesson are:

  - use ``curl`` to download some data from a website  (no browser, terminal)
  - (check out the ``matlab`` equivalent(s): ``webread()`` and ``websave()`` )
  - inspect file in ``bash/terminal`` and then load into ``matlab``

## Mystery / puzzle

>Given a ``nifti`` data set (4d FMRI data), and a mystery timecourse (1d), find the spatial location of the signal [x,y,z] coordinates

### Info

**Overall aim**: Given a timeseries (1D vector) from a larger (4D) dataset, find the ``[x,y,z]`` coordinates from which the 1D signal was taken.

- 1D data is available at this address:
https://raw.githubusercontent.com/schluppeck/dafni/master/matlab_text/mystery-timecourse.txt

- 4D data from which the signal was taken is ``dafni_01_FSL_4_1.nii``


**Sub-aims**:

- **in groups of 3-5 (10min)**, make a list of things you need to achieve to solve this problem.
  + data?
  + meta-data?
  + what *idea* / *approach* might give you the answer?
  + what ``matlab`` constructs will help you?
  + there are more than one way to do this... can you see alternatives?
  + what's tells you that you have found the correct location?

- now that we have a plan, let's outline the steps we'll take as ``comments`` in a matlab script.

- ... and then **let's do it**.

- to see how to load content / data directly from a web address / remote, without saving an intermediate file, look [at this page](loading-from-the-web.md).

- **(bonus)** can you see how to adapt the code for ``sliceview()`` so it can accept 3D and 4D data stored in a variable in ``matlab`` (rather than loading from a file). You could use this to visualise various results from your mystery / puzzle solving?!

## Reflection

In the last few minutes of today's class - let's think about a few things that you have met in this lab class.

- What do you think was really useful?
- What was hard?
- What will you want to follow up and develop further?
