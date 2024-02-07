## Scanner - actual numbers from the day (2018/19).

2. **inplane anatomy** - T1w, 2D MPRAGE. 24 slices, inplane voxel size: 1.5 mm, slice thickness 3 mm (same prescription as fMRI data). Matrix size 128 x 128.
4. **fMRI data** (and all fMRI scans) 2D gradient-echo EPI, TR 1.5s, TE 40ms, FA: 72º, *scene localiser scan*: 294 (288+4) dynamics, retinotopy scan: 160 dynamics. Voxel size 3mm isotropic (acquired). Matrix size 64 x 64. **Note: the scanner reconstruction may have changed the "reconstructed voxel size" to something else, for mathematical expediency.** (Check the dimensions in the actual data with ``fslinfo`` or ``fslhd``.)
6. **whole head anatomy** - T1w 3D MPRAGE. Matrix size 256 x 256, 160 slices. Reconstructed as sagittal images. voxel size 1 mm isotropic. TE 3.7 ms, TR 8.13 ms, FA 8°, TI 960 ms, and linear phase encoding order.
7. across the subjects we also acquired various other data sets (including **diffusion weighted**, a **T2 weighted** anatomy scan (using multiple echoes), ... but we didn't find time to analyze these in class.

