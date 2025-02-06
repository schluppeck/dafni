## Scanner - actual numbers from the day (2023/24)

2024-02-07, Denis Schluppeck

4 volunteers (``sub-01`` .. ``sub-04``), scanned on the 3T GE scanner at the SPMIC QMC site. Scanner operator: AC. Start time 1400h.

(Data available via `moodle` link to a zip file on OneDrive). 

For each person we obtained several scans. See `json` sidecar copied along for some details.

- T1w MPRAGE (1mm isotropic)
- T2w FLAIR  (1mm isotropic)
- one or two repeats of an fMRI experiment (`FFAlocaliser.m`); 2.2mm isotropic, TR/TE 1500ms/35ms

## fMRI experiment and timing

- the original scan was 168 timepoints long, but the first 8TRs (12s) were cut to allow for steady state. 
- after removing these initial dummies, the time series is 160 timepoints long
- timing of the experiment is (Faces-rest-Obj-rest)*5)

```
12s ON (faces)
12s OFF (gray)

12s ON (objects)
12s OFF (gray)

... then each repeated for a total of 10 stimulus-rest blocks 
```