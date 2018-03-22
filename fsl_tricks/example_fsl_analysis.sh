# example analysis using FSL command line tools
# assumes you have dafni_01_FSL_4_1.nii  as an example data file
# ds - 2018-03-22

fname=dafni_01_FSL_4_1

# getting a timeseries from a coordinate
fslmeants -i ${fname} -c 19 13 4

# the ${fname} is the BASH way of using a variable...

# redirect into a text file
fslmeants -i ${fname} -c 19 13 4 > sometimecourse.txt

# using bet / brain extraction tool
bet2 ${fname} scan4 -m
# this will strip the skull from the image and also make a MASK that tells
# you where the skull is

fslview scan4_mask &

# now we can make use of this mask / and also show some maths!
fslmaths    # without input arguments: help:

fslmaths ${fname} -Tmean scan4_mean
fslmaths ${fname} -sub scan4_mean -div scan4_mean    scan4_percent

fslview scan4_percent &

# because we are dividing by very small numbers in areas around the outside of the head
# we want to mask these out... so use the masking option in fslmaths

fslmaths scan4_percent -mas scan4_mask scan4_final

fslview scan4_final &


