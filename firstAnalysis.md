# First analysis (FSL, UNIX, ...)

Summary

## Organise the data into folders

Do this "by hand" - using mouse clicks in the macOS operative system for now. We'll see how to use command line calls in the Terminal soon. Think about which files are:

- functional data
- anatomical images
- "metadata" - [wikipedia entry on this idea](https://en.wikipedia.org/wiki/Metadata)

## Set up the analysis using the GUI

Start up ``feat`` either from via the ``fsl`` menu or directly.

```bash
# navigate into data directory
cd ~/data/S001/

# then pick FEAT FMRI firstAnalysis
fsl &
# - OR -
Feat_gui &
```
