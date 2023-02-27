# Brain images + timecourses in Matlab

The aims of this lesson are:

  - refresh your memory about ``matlab``
  - see how to load ``nifti`` images (pre-2017b we need a toolbox, [now support is native](https://uk.mathworks.com/help/images/ref/niftiread.html)). See the first exercise below.

## Matlab, two ways...

### `makeMontage()`

For the first part of the session, I will do a coding walk-through with some narrated advice on problem solving, etc. In the second part of the session, you will then apply the ideas from the first part of make your own function for extracting timecourses from data.

  - we build a simple ``makeMontage()`` function for displaying 3d imaging data. **Plan out / design / write** ``makeMontage()``
  - thinking about putting your code under version control!
  
![example of a montage](./im-01-montage.png)

If you want, you can also have a more detailed look at the files and exercises in the [matlab_images folder](./matlab_images/Readme.md).

### `getTimecourse()`

In the second part of the session, we want you to make use of the ideas we introduced in the first part to:

- think about, draft, and write a function called `returnTimecourse()`
- it should take 4 input arguments `data`, `xcoord`, `ycoord` and `zcoord` (the coordinates should be in the format that `fsl` uses... in particular, start counting at 0, not 1 like matlab...!!)
- your function help / documentation should explain this behaviour to make sure your users don't get confused with it.
- and should return 1 ouput (call it `tcourse` inside the function)

```matlab
%  tcourse = returnTimecourse(data, xcoord, ycoord, zcoord);
% so you can use it with 
cd('fmri.feat') % go into the folder
data = niftiread('filtered_func_data.nii.gz');

% use it like this...
t = returnTimecourse(data, 30, 5, 2);
plot(t, 'linewidth',2)
xlabel('Time'); 
ylabel('fMRI response')
``` 

![correct version](./matlab_images/tcourse.png)

## if you get the following...

- then you haven't done quite the right thing.
- think about your indexing... what do you need to do to make sure 0-indexing (in `fsl`) gets translated into `1-indexing` in matlab use...

![not quite version](./matlab_images/tcourse-not-quite-right.png)

### `plot()` throws errors

- if you get weird errors from `plot()` then check whether you are doing the right thing to get a 1-d vector for plotting (maybe check with `size()`?!)