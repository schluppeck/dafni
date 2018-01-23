# First analysis (FSL, UNIX, ...)

The aim of this session is to analyze the data we acquired with 3T functional MRI in our simple cognitive neuroscience experiment.

In outline, the first steps will be very similar to what you may remember from another course (C84FIM), where we had a demonstration & walk-through of a simple data sets

[Have a look at the PDF](c84fim-workshop-01.pdf) to refresh your memory.

The **plan for here is**

1. organise data into folders
2. start up ``feat``
3. provide all the necessary info in the GUI interface
4. hit ``Go!`` and watch for progress in web browser
5. dig around in the resulting folders and files


## Organise the data into folders

Do this "by hand" - using mouse clicks in the macOS operative system for now. We'll see how to use command line calls in the Terminal soon. Think about which files are:

- functional data
- anatomical images
- "metadata" - [wikipedia entry on this idea](https://en.wikipedia.org/wiki/Metadata)

## Set up the analysis using the GUI

Start up ``feat`` either via the ``fsl`` menu or directly.

```bash
# navigate into data directory
cd ~/data/S001/

# then pick FEAT FMRI analysis
fsl &
# - OR -
Feat_gui &
```
