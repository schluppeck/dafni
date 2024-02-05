# Getting Data

## What's the plan?

| Unit     | Topic                                            |
|:---------|:-------------------------------------------------|
| 2 :star: | Data acquisition (**scanning on 3T**)            |

## Data acquisition in the scanner

fMRI data will be acquired in ~30min sessions (in small groups) on one of our 3T scanners. Have a look at
[the webpage for the 3T scanners on campus](https://www.nottingham.ac.uk/research/groups/spmic/facilities/facilities.aspx) to learn a bit more about the machines.  Up until last year we ran our experiments on the 3t Achieva, but the SPMIC has now decommisioned that machine to make space for the [new, national 11.7T facility](https://www.nottingham.ac.uk/research/groups/spmic/research/national-facility-for-ultra-high-field-11.7t-human-mri-scanning/index.aspx) which is currently being planned in detail.

Two important sets of things to consider:

- what are the parameters / settings on the MRI scanner?
- what is the subject doing in the scanner (stimuli & task)?

## Scanner - Protocol

The protocol will be pretty standard for a cognitive neuroscience scanning sessions. The plan for the time in the scanner is as follows

1. Quick survey scan to allow "planning" on console **(< 10s)**
2. A test EPI to make sure that the slice positioning for the fMRI experiment is ok.
3. fMRI experiment (block): gradient-echo EPI, TR 1.5s **(~4min)**
4. T1w-MPRAGE: to illustrate detailed (1mm isotropic) anatomy **(~5min)**
5. T2w-anatomy: higher resolution inplane, but thicker slices
6. fMRI experiment (block): gradient-echo EPI, TR 1.5s **(~4min)** (a finger-tapping experiment as opposed to a visual experiment)

## Scanner - actual numbers from the day (2023/24).

*details to be updated*


## Scanner - actual numbers from the day (2022/23).

For each of four subjects (``sub-01`` .. ``sub-02``) we collected most of those scans. Look at the `Readme.md` file in each folder for any notes (eg `sub-02` has one scan with TR=2s, because of the sample protocol I had picked.) 

Data shared via `OneDrive` link on a moodle message to the participants on the module.

### A note on the block-design parameters.

- the visual scan (faces versus objects) used a `rest-A-rest-B-...` pattern.
- the finger tapping scan follwed the same timing. `rest-LEFT-rest-RIGHT...`

Each `rest-stimulus` block took 24s (so 16 TRs at 1.5s... or 12 TRs for the one scan with a 2s TR).

The code for these experiments is in the `stimulusCode` folder (`FFAlocaliser()` and `M1localiser()`). Ask DS for details on how this works, if you are interested in generating stimuli.

## Scanner - actual numbers from the day (2019/20).

For each of three subjects (``subject-A``, ``subject-B`` and ``subject-C``) we collected 5 scans. The "series" numbers may be slightly different across individuals. but the scans (in order) were the same:

1. **fMRI data** - 2D gradient-echo EPI, TR 2.0s, TE 30ms, multiband factor 2, FA: 80º, ``scene_localiser()`` scan: 192 dynamics. (Check the dimensions in the actual data with ``fslinfo`` or ``fslhd``.)

2. **fMRI data** - acquisition details as in 1, but only 120 dynamics. Pseudorandomly ordered blocks on "normal", "inverted" and "caricatured" faces (at different levels).

3. same as 2 (a repeat)

4. **whole head anatomy** - T1w 3D MPRAGE. Matrix size 256 x 256, 160 slices. Reconstructed as sagittal images. voxel size 1 mm isotropic. TE 3.7 ms, TR 8.13 ms, FA 8°, TI 960 ms, and linear phase encoding order.

5. **T2 weighted** anatomy scan. TE 89ms, TR 3.38s, FA, 90º (Check the dimensions in the actual data with ``fslinfo`` or ``fslhd``.)

## Scanner - actual numbers from the day (2018/19).

2. **inplane anatomy** - T1w, 2D MPRAGE. 24 slices, inplane voxel size: 1.5 mm, slice thickness 3 mm (same prescription as fMRI data). Matrix size 128 x 128.
4. **fMRI data** (and all fMRI scans) 2D gradient-echo EPI, TR 1.5s, TE 40ms, FA: 72º, *scene localiser scan*: 294 (288+4) dynamics, retinotopy scan: 160 dynamics. Voxel size 3mm isotropic (acquired). Matrix size 64 x 64. **Note: the scanner reconstruction may have changed the "reconstructed voxel size" to something else, for mathematical expediency.** (Check the dimensions in the actual data with ``fslinfo`` or ``fslhd``.)
6. **whole head anatomy** - T1w 3D MPRAGE. Matrix size 256 x 256, 160 slices. Reconstructed as sagittal images. voxel size 1 mm isotropic. TE 3.7 ms, TR 8.13 ms, FA 8°, TI 960 ms, and linear phase encoding order.
7. across the subjects we also acquired various other data sets (including **diffusion weighted**, a **T2 weighted** anatomy scan (using multiple echoes), ... but we didn't find time to analyze these in class.

## Scanner - actual numbers from the day (2017/18)

2. **inplane anatomy** - T1w, 2D MPRAGE. 24 slices, inplane voxel size: 1.5 mm, slice thickness 3 mm (same prescription as fMRI data). Matrix size 128 x 128.
4. **fMRI data** (and all fMRI scans) 2D gradient-echo EPI, TR 1.5s, TE 40ms, FA: 72º, 160 dynamics. Voxel size 3mm isotropic. Matrix size 64 x 64.
6. **whole head anatomy** - T1w 3D MPRAGE. Matrix size 256 x 256, 160 slices. Reconstructed as sagittal images. voxel size 1 mm isotropic. TE 3.7 ms, TR 8.13 ms, FA 8°, TI 960 ms, and linear phase encoding order.

## Stimulus set-up

- stimuli were presented on a BOLDscreen (CRS Ltd, Rochester, UK) - https://www.crsltd.com/tools-for-functional-imaging/mr-safe-displays/boldscreen-32-lcd-for-fmri/
- **2018/19 stimulus code:** inspect ``scene_localiser()`` in the ``stimulusCode`` directory. If you can't run the code and get errors, have a lootk at [this clip on youtube](https://www.youtube.com/watch?v=5kSvEO4-HVc) to get an impression.
- other details have remained the same since the 2017/18 version.


## Stimulus code (2017/18)

+ stimulus code: inspect ``FFAlocaliser`` and ``jazLocaliser`` for lots of details. You should be able to run the code, too.
+ **timing: block design** 12s rest, 12s images (faces, objects), so 24s cycles. 10 repeats per scan - 240s or 160 dynamics (@ 1.5s). Stimuli were images from face and object image database (details below).
+ **timing: event-related design** 1.5s stimuli followed be a randomly chosen ITI between 9s and and 18s (in 1.5s increments). Stimuli were white, moving, random dots on a black background. 100% coherence, speed 4 deg/s. Scans lasted 240s or 160 dynamics (@ 1.5s).

The code is written in ``matlab/mgl`` using the ``task`` library that comes with ``mgl``. Written by Alex Beckett and DS based on a version of a working code from Justin Gardner :smile:

There are a couple of short youtube videos explaining <a href="https://youtu.be/wcA_h-rrVeM" target="_blank">the FFA localiser</a> and the <a href="https://youtu.be/exqNc7q8zSs" target="_blank">fixation dimming task</a> to control attention. This should give you  a sense of what the subject is doing inside the scanner.

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

### Notes

- [x] working code with face and object images
- [x] parameters to set cycle length, TR, number of block
- [x] youtube clip explaining the fixation task and experiment
- [X] write out text file in correct format for ``fsl/feat`` analysis.
- [X] test with actual scanning parameters

### Materials for stimuli:

We will provide the stimulus code (written in Matlab / MGL) in line with what happened in - [Learning Matlab / C84NIM](https://github.com/schluppeck/learningMatlab) - a pre-requisite for this course.

We'll run a "Faces versus houses / scenes localiser, as this works well and is a very robust experiment.

- Faces download:
https://wiki.cnbc.cmu.edu/images/multiracial.zip

>Stimulus images courtesy of Michael J. Tarr, Center for the Neural Basis of Cognition and Department of Psychology, Carnegie Mellon University, https://www.tarrlab.org/. Funding provided by NSF award 0339122.

- Objects download:
https://bradylab.ucsd.edu/stimuli/Exemplar.zip

>Object stimuli from: Brady, T. F., Konkle, T., Alvarez, G. A. and Oliva, A. (2008). Visual long-term memory has a massive storage capacity for object details. Proceedings of the National Academy of Sciences, USA, 105 (38), 14325-14329.

- Scenes download: https://timbrady.org/stimuli/Scenes.zip

>Scene stimuli from: Konkle, T.*, Brady, T. F.*, Alvarez, G.A. and Oliva, A. (2010). Scene memory is more detailed than you think: the role of categories in visual long-term memory. Psychological Science, 21(11), 1551-1556.
