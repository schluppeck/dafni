# Permuting dimensions

## Problem

Our images are stored in a 3d cube and the order is not quite what we want. The reason for this is that we acquired images in the sagittal direction. One way to think about this is that the "slowest" changing direction in the data collection was in that slice plane. In that way of thinking about image acquisition, the fastest and second fastest directions end up as X and Y respectively.

### by default

In our anatomical images, the dimensions are like this. **Note that even though we might be tempted to make the first image dimension X** that's not the case. The pixel display is arranged in the same way as you'd see the matrix display in text.

| data dimension | plotting axis | anatomical          |
|:-------------- |:------------- |:------------------- |
| 1              | y (!) not x   | anterior->posterior |
| 2              | x             | inferior->superior  |
| 3              | z             | right-left          |


<center>
<img src="mprage-default.png" alt="" width="50%">
</center>

```matlab
% load data
d = niftiread('dafni_01_FSL_7_1.nii');

% display a slice (which has 1st and 2nd dims)
figure, imagesc(d(:,:, 80));
ylabel('first dimension of array (Y)');
colormap(gray)
axis image
```

<center>
<img src="figure_imageorientation.png" alt="" width="50%">
</center>

<hr>

To prove to yourself that this is the case, you can chop some of the data out along the first dimension (say half)... the effect on the image will reveal how Matlab plots data (and how your "intuitions" about x and y axes might be off :wink:).

```matlab
% display a slice (which has 1st and 2nd dims)
figure, imagesc(d(1:128,:, 80));
ylabel('first dimension of array (Y)');
title('first data dimension cut down to half')
colormap(gray)
axis image
```

<center>
<img src="figure_imageorientation-half.png" alt="" width="50%">
</center>

<hr>

The third / final direction in the original image is *right-left*.

```matlab
% display a slice (which has 1st and 3rd dims)
 figure, imagesc(squeeze(d(:, 128, :)));
 ylabel('first dimension of array')
 xlabel('third dimension')
 colormap(gray)
 axis image
 ```

<center>
<img src="figure_imageorientation-thirdD.png" alt="" width="50%">
</center>

### the desired orientations


| data dimension | plotting axis | anatomical          |
|:-------------- |:------------- |:------------------- |
| 1              | y (!) not x   | anterior->posterior |
| 2              | x             | ~~inferior->superior~~  **right-left** |
| 3              | z             | ~~right-left~~    **inferior-superior**      |


<center>
<img src="mprage-rearranged.png" alt="" width="50%">
</center>
