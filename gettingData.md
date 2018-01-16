# Getting Data

## Data acquisition in the scanner

1. T1w-MPRAGE: to illustrate detailed (1mm isotropic) anatomy
2. field map: to show that B0 can be measured
3. fMRI experiment (block): TR 2s, TE 40ms, 240s
4. fMRI experiment (event-related): same scanning parameters.
5. [additional, if time permits] EPI data (test): 5 echoes at different TEs to illustrate T2* decay

## Stimulus code

In ``matlab/mgl`` using the ``task`` library that comes with ``mgl``. Written by Alex Beckett and DS based on a version of a working code from Justin Gardner :smile:

The experiment runs as a simple block design in the following order:

>[faces, rest] , [objects, rest] - ...

The length of each ``[stimulus, rest]`` cycle is determined by the ``cycleLength`` (in TRs).

To run, make sure the ``stimulusCode`` folder is on the path and then simply run the following command. the ``Escape`` key can be used to stop the experiment at any point:

```Matlab
FFAlocaliser % quick test to see what's going on
```

To run at the MR centre, we also want to specify TR, not to run in a small window, etc. So probably worth setting a few parameters in the call like this:

```Matlab
FFAlocaliser('TR=1.5', 'debug=0', 'numBlocks=10', 'cycleLength=12')
```

- [x] working code with face and object images
- [x] parameters to set cycle length, TR, number of block
- [ ] write out text file in correct format for ``fsl/feat`` analysis.
- [ ] test with actual scanning parameters

## Materials for stimuli:

We will provide the stimulus code (written in Matlab / MGL) in line with what happened in - [Learning Matlab / C84NIM](https://github.com/schluppeck/learningMatlab) - a pre-requisite for this course.

We'll run a "Faces versus houses / scenes localiser, as this works well and is a very robust experiment.

- Faces download:
http://wiki.cnbc.cmu.edu/images/multiracial.zip

>Stimulus images courtesy of Michael J. Tarr, Center for the Neural Basis of Cognition and Department of Psychology, Carnegie Mellon University, http://www.tarrlab.org/. Funding provided by NSF award 0339122.

- Objects download:
https://bradylab.ucsd.edu/stimuli/Exemplar.zip

>Object stimuli from: Brady, T. F., Konkle, T., Alvarez, G. A. and Oliva, A. (2008). Visual long-term memory has a massive storage capacity for object details. Proceedings of the National Academy of Sciences, USA, 105 (38), 14325-14329.

- Scenes download: http://timbrady.org/stimuli/Scenes.zip

>Scene stimuli from: Konkle, T.*, Brady, T. F.*, Alvarez, G.A. and Oliva, A. (2010). Scene memory is more detailed than you think: the role of categories in visual long-term memory. Psychological Science, 21(11), 1551-1556.
