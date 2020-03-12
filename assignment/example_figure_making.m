%% example figure making in matlab
%
% assuming you have run a FSL/Feat analysis on one of the datasets from the
% 2019/20 Data analysis for Neuroimaging lab

datadir = '~/data/subject-C/CogNeuro03-301-WIP_MB2_TASKfMRI_singleechoTR2.feat/';

% also: add the location of code we want to (re)use to the path... for me
% this is at ~/matlab/dafni.  the "genpath()" part does "with subfolders"
addpath(genpath('~/matlab/dafni'))

% get current working directory (so we can return back at the end of
% script)
cwd = pwd();

% go to the place where data are stored.
cd(datadir)

%% inside the FEAT directory there is a whole set of  

%% panel A - how to do an anatomical slice
anatomy = niftiread('reg/highres.nii.gz'); % the person's anatomy file
exampleAnatomySlice = returnSlice(anatomy, 80, 1);

subplot(2,2,1)
imagesc(exampleAnatomySlice)
view(-90,90) % turns view to azimuth -90 (and from above for 2d image)
colormap(gca, gray())
axis('image')
axis('off')
title('(A) anatomical image', 'HorizontalAlignment', 'right')

%% panel B - how to show e.g. a histogram of values in anatomy in robust range

subplot(2,2,2)

% there are many zeros around the brain (just empty space)
nonZeroIdx = anatomy(:) > 0;

% for those that are non-zero... look at the range between 1 and 99th
% centile
robustRange = prctile(anatomy(nonZeroIdx), [1 99]);

histogram( anatomy, 'BinLimits', robustRange, 'NumBins', 40, 'FaceColor', 'r', 'EdgeColor' ,'w')

title('(B) histogram of intensities', 'HorizontalAlignment', 'right')

%% panel C - a timecourse plot

ts = load('tsplot/tsplot_zstat1.txt');

subplot(2,2,[3 4])
plot(ts(:, [1,2]))
legend('data (highest Z)', 'partial model')
xlabel('Time (volumes)')
ylabel({'fMRI response','(image intensity)'})

title('(C) GLM fit', 'HorizontalAlignment', 'right')

%% save it out to PDF format (try others?)

% return back to where we started
cd(cwd);

fig = gcf;

% find all text elements and change their fontsize
% h/t https://uk.mathworks.com/matlabcentral/answers/223344-changing-font-size-in-all-the-elements-of-figures
set(findall(gcf,'-property','FontSize'),'FontSize',8)

fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 15 10];
fig.PaperSize = [15 10];
print('figureWithReasonableSize','-dpdf')
