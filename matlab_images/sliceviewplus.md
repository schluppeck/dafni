## Data (version 2.0) - solution

### Fixing up ``sliceview()`` to load NIFTI files

- You nearly have all the code you need already. Just some tweaks, extra bits needed in strategic places:

> load up ``sliceview.m`` and save it as ``sliceviewplus.m``

- use the library from ``mrTools`` to read NIFTI files

> ``mlrImageReadNifti()`` will return the data and header in the right format for this viewer - so not much work is required.

- ``sliceviewplus`` needs to accept an input argument

> I made this input argument ``filename``. As an added bonus, if user doesn't provide this, we can use ``uigetfile()`` which you met in the first Matlab course to ping user for a file via the GUI.

- Do you need to worry about whether the data is 3d or 4d? For starters, assume that the user is doing something reasonable... but next, what if not?

>My solution here was to check if the ``ndims()`` are 4, 3 or something else:
> if 4: take the average across the 4th dimension (usually time)
> if 3: take the data ai is
> if anything else: raise an error and stop function


**Have a look at** [sliceviewplus.m](sliceviewplus.m) to see the changes in context.
