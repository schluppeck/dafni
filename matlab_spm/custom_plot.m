%% a matlab file for doing some plotting with SPM data
%
% ds 2025-03-03
% ds 2026-03-03

%% 0 consider where data are / where code is
%
% SPM analysis folder contains the data files, but the code needs to be
% on Matlab path. 
%
% a convenient place for generically useful functions would be where matlab
% looks by default

userpath()


%% 1 read in an anatomy file and use
% standard matlab functions to inspect
% m (Bias-Corrected): intensity non-uniformity corrected structural image produced during segmentation (e.g., ms01_T1.nii).
% c (Tissue Segmentation): Tissue-specific segments produced during segmentation.
% c1...: Gray Matter (GM)
% c2...: White Matter (WM)
% c3...: Cerebrospinal Fluid (CSF)
% c4, c5, c6...: Skull, Soft Tissue, Air/Other
% y_ (Deformation Field): A deformation field file created during segmentation
% w (Warped/Normalized): The structural image transformed (normalized) into standard MNI space.
% wm (Warped & Bias-Corrected): Often, the structural image is both bias-corrected and then warped, resulting in a wm prefix, or sometimes m followed by w depending on the pipeline order. 


% Load the header information of the fMRI file
% in your folders this might be in the anat folder...
% e.g.

anatomy_file = 'mMSC_COG_NEURO_03_WIP_MPRAGE_CS3_5_20250206110123_201.nii';

% does this file exist?? One way to check:
% ASSERT() is a useful way to "ensure" something is the case, or break!
assert(isfile(anatomy_file))

Vfile = spm_vol(anatomy_file);

% Read the image data
V = spm_read_vols(Vfile);

% or could use a vanilla matlab function to do the same
% which is what I did in class
% niftiread()

mySlice = returnSlice(V, 100);
figure
imagesc(mySlice)
axis('image')
colormap(gray())

% Design matrix
% load SPM.mat
% Load the SPM.mat file
load('results/SPM.mat');

% Access the design matrix
X = SPM.xX.X;

figure
imagesc(X)
pbaspect([1,5,1]) % this changes the aspect ratio of the plot window
colormap(gray())
title('Design matrix')

%% navigating files
% r: Realigned
% u: Unwarped
% m: Mean image
% s: Smoothed
% w: Normalized (warped)
% a: Slice-timed

fmri_file = 'swrMSC_COG_NEURO_03_WIP_visual_fmri_20250206110123_401.nii';

% load this in... using niftiread()
F = niftiread(fmri_file);
% slicing through the data image slice...
% here timecourse slice...


% let time run from 1:160 dynamics or (0:159) * 1.5 in s
t = (0:159) * 1.5;
tc1 = returnTimecourse(F, 40,15,24);
% tc2 = returnTimecourse(F, 17, 19, 27);
tc2 = returnTimecourse(F, 15+1, 20+1, 26+1);

figure

subplot(2,1,1)
plot(t,tc1,'r')

subplot(2,1,2)
plot(t,tc2,'k')
xlabel('Time (s)')
ylabel('fMRI reponse (image intensity)')

