%% run through some GLM ideas during class
%
%
% ds 2022-03-14

%% load in raw data and filter_func_data

% you should adjust file / path names accordingly to fit with your data
% folder / naming
foldername = '~/Desktop/msc-dafni/2019-cogneuro-scanning/subject-A';
cd(foldername)

% this first bit is just looking at the effect of filtering in FSL / FEAT

% raw data
fname_raw = 'CogNeuro01-301-WIP_MB2_TASKfMRI_singleechoTR2.nii';
h1 = niftiinfo(fname_raw)
t1 = niftiread(fname_raw);

% filtered_func data
fname_filtered = 'CogNeuro01-301-WIP_MB2_TASKfMRI_singleechoTR2.feat/filtered_func_data.nii.gz';
h2 = niftiinfo(fname_filtered);
t2 = niftiread(fname_filtered);

%% plot them

% NB! in FSL, zero-indexing. in Matlab 1-indexing

figure()

tPlot1 = squeeze(t1(36+1,12+1,14+1,:));
tPlot2 = squeeze(t2(36+1,12+1,14+1,:));

subplot(2,1,1)
plot(tPlot1)
subplot(2,1,2)
plot(tPlot2)


%% plot on the same plot using plotyy()

figure()
x = 1:numel(tPlot1);

plotyy(x, squeeze(t1(36+1,12+1,14+1,:)), ...
    x, squeeze(t2(36+1,12+1,14+1,:)))

%% load in some timing information (from text files / fsl created files)

% Vest2Text in bash shell

X = load('bla.txt'); % bad names for text file... don't do this ;)

% X is the design matrix... how many rows [ timepoints ]... columns
% (however many EVs explanatory variables you have)

% make sure you have another column in your design matrix that can
% create an offset / shift

%% augment design matrix with ones (to allow for offset / bias)
X = [X, ones(size(X,1),1)];

% X = [X, ones(size(X,1),1)];
%n X = [X, 0.5*ones(size(X,1),1)];

%% visualise what is going on during GLM

% look at that voxel location
y = squeeze(t2(30,30,4,:)) % tPlot2;

% y = X * beta
% X'y = X'X * beta
% (X'X)^(-1) X'y = beta

% BACKSLASH mldivive() is a powerful command
b = X\y

figure()

plot(x,X*b, 'r', 'linewidth',2)
hold
plot(x, y, 'k', 'linewidth',2)

title(sprintf('# cols in design matrix %d', size(X,2)))

% how good is the fit? it's all about the residuals

res = y - X*b;  % data - model

figure
plot(x, res, 'b-')


%% what if our model doesn't fit?

badModel = flipud(X*b) % eg. if timing is completely wrong, simulatedd here by flipping data upside down

figure

plot(x,badModel, 'r', 'linewidth',2)
hold
plot(x, y, 'k', 'linewidth',2)


%% think about stats


%% visualise what is going on during GLM

% how about all voxels:

% make space for all beta values at all voxel locations
allB = nan([size(t2, [1,2,3]), size(X,2)] );

tic
% look at that xvoxel location
for iX = 1:size(t2,1)
    for iY = 1:size(t2,2)
        for iZ = 1:size(t2,3)
            y = squeeze(t2(iX, iY, iZ,:)); % tPlot2;
            
            % y = X * beta
            % X'y = X'X * beta
            % (X'X)^(-1) X'y = beta
            b = X\y;
            allB(iX, iY, iZ,:) = b;
        end
    end
end
toc
% we will have a 4D data array .. images of beta values...

%% think about figure making for assessment .

%myBetaMap = allB(:,:,:,1);
myBetaMap = allB(:,:,:,1) - allB(:,:,:,3) ;

figure, montage(myBetaMap)
colorbar()
caxis([-100 100]) % pick reasonable values...
colormap(parula)


