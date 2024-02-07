## Scanner - actual numbers from the day (2019/20).

For each of three subjects (``subject-A``, ``subject-B`` and ``subject-C``) we collected 5 scans. The "series" numbers may be slightly different across individuals. but the scans (in order) were the same:

1. **fMRI data** - 2D gradient-echo EPI, TR 2.0s, TE 30ms, multiband factor 2, FA: 80º, ``scene_localiser()`` scan: 192 dynamics. (Check the dimensions in the actual data with ``fslinfo`` or ``fslhd``.)

2. **fMRI data** - acquisition details as in 1, but only 120 dynamics. Pseudorandomly ordered blocks on "normal", "inverted" and "caricatured" faces (at different levels).

3. same as 2 (a repeat)

4. **whole head anatomy** - T1w 3D MPRAGE. Matrix size 256 x 256, 160 slices. Reconstructed as sagittal images. voxel size 1 mm isotropic. TE 3.7 ms, TR 8.13 ms, FA 8°, TI 960 ms, and linear phase encoding order.

5. **T2 weighted** anatomy scan. TE 89ms, TR 3.38s, FA, 90º (Check the dimensions in the actual data with ``fslinfo`` or ``fslhd``.)
