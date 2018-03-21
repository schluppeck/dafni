%% outline of a solution to the mystery-timecourse problem
%
% ds 2018-03-16

%% make sure we are in the right place

if ~exist('dafni_01_FSL_4_1.nii', 'file')
    error('(uhoh) need to make sure the data are available... are you in the right directory??')
end

%% read 4d data

[data hdr ] = mlrImageReadNifti('dafni_01_FSL_4_1.nii');

%% load local mystery timecourse, but should also try the remote version

% make sure matlab uses the right tool to read NUMBERS
options = weboptions('ContentReader', @importdata);

try
    % download into a variable, m:
    m = webread('https://raw.githubusercontent.com/schluppeck/dafni/master/matlab_text/mystery-timecourse.txt',...
        options);
catch
    error('(uhoh) could not load file via http.')
end
disp('loaded mystery timecoure from web')

% if we wanted the local copy, we could also have done this:
% m = load('mystery-timecourse.txt');
% m = m(:);  % make sure it's a column vector.

% pre-allocate some space - we don't want to grow variables in a loop
% that's slow

% what size is the data array [nx,ny,ns,nt]
sz_data = size(data);

% make a variable / placeholder of the same size as the spatial dimensions
T = nan(sz_data(1:3)); 

%% IDEA: how to look for the "needle" in the haystack

% could look for
% -- MINIMAL mismatch between current timecourse and the TARGET, m
% mismatch = @(x,y) sum( (x(:) - y(:) ).^2 ); % sum of squared errors

% -- MAXIMAL correlation (I like this version. Nice and simple.
% corr(x,y)   % will be close to 1 (not ==1, numerical errors!) when we
% have found the solution...

%% run through all the data
%
% IDEA: traverse all possible values of x-index, y-index, s-index
%       by using 3 nested loops.

% don't be impatient - this will take a few seconds (10s, when I tried on
% my machine)

tic % and keep time
for si = 1:sz_data(3)    
    for yi = 1:sz_data(2)    %
        for xi = 1:sz_data(1)   
                % T(xi,yi) = mismatch(m, data(xi,yi,s));
                t = squeeze( data(xi,yi,si,:) );  % current timecourse
                
                % now calculate that number and store...
                T(xi,yi,si) = corr(m, t);
        end
    end
end
toc

% now find where correlation was (close to) 1
% find where corr == 1

% careful with rounding
idx = find( T > 0.9)

% but > 0.9 is a bit arbitrary... there could be a voxel with, say a
% correlation of 0.93, which might not be the correct one...

% maybe better:
[max_corr, idx] = max( T(:) );  % need to make sure it's T(:) not T... can you figure out why??

[x,y,s] = ind2sub(size(T), idx);

% now we know which slice to look in!

%% display the result

% image in gray scale
cmap = gray(256); 

f_ = figure 
imagesc(T(:,:,s), [-1 1])
set(gca, 'FontSize',14)
colormap(cmap)
axis image
h_ = colorbar();
ylabel(h_, 'correlation with mystery signal');

hold on

% images and plots, confusingly don't follow the same x/y convention
% because images are stored rows (down the columns)  first
plot(y,x, 'ro', 'markersize',15, 'markerfacecolor', 'w', 'markeredgecolor', 'r', 'linewidth',4)
xticks([1,32,64]);
yticks([1,32,64]);
xlabel('space (voxels)')
ylabel('space (voxels)')
title(sprintf('Eureka! [x,y,s] = %d, %d, %d',x,y,s))

% add the timeseries as a floating plot
tc_ = axes('position', [0.2, 0.55 0.5, 0.35])
p_ = plot(m);
set(p_, 'linewidth',2, 'color', 'w')

axis off % make the axis "invisible"

    
%% another figures, I made in the run-up to class

M = mean(data,4); figure, 
subplot(2,3,1)
imagesc(M(:,:,3))
colormap(gray), axis image, axis off

subplot(2,3,2)
imagesc(M(:,:,5))
colormap(gray), axis image, axis off

subplot(2,3,3)
imagesc(M(:,:,7))
colormap(gray), axis image, axis off


subplot(2,1,2)
p_ = plot(m);
set(p_, 'linewidth',2)
xlabel('Time (volumes)')
ylabel('fMRI response (intensity)')
suptitle('1d needle in a 4d haystack')


