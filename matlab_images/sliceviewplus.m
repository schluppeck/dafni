function [ h ] = sliceviewplus( filename )
%sliceviewplus - simple slice viewer for 3d (mean 4d) data
%
%      usage: [ h ] = sliceviewplus( filename )
%         by: ds1
%       date: 2018 - Data Analysis For Neuroimaging class
%     inputs: fname - required (path to NIFTI file
%    outputs: h - handle to figure
%
%    purpose: a simple window/function that loads in a 3d data set and
%    allows you to flip through slices (+ orientations) 
%
%             for a 4d dataset, the mean across time is shown.
%
%        e.g: sliceviewplus('dafni_01_FSL_7_1.nii')
%             sliceviewplus()  % pops up dialog


% if no filename given, ask for one
if nargin == 0
    [theFile, thePath] = uigetfile({'*.nii', '*.hdr'}, 'Pick a NIFTI file');
    if isequal(theFile,0) || isequal(thePath,0)
       disp('User pressed cancel - wants to quit')
       return
    else
       filename = fullfile(thePath, theFile);
       disp(['User selected ', filename])
    end
end


% print some information on the command line
% that helps the user

disp('==============================================')
fprintf('\tPress the following buttons to:\n')
fprintf('up/down\tchange slice\n')
fprintf('o/O\t\tchange orientation\n')
fprintf('c/C\t\tchange cursor\n')
fprintf('q/Esc\t\tquit\n')
disp('==============================================')

% load a data file
try
    [array hdr] = mlrImageReadNifti( filename );
catch
    error(['Problem loading ', filename])
end

% hdr contains information, the HEADER
% array contains the actual image data to be passed to the Figure / owner.


% need to check if data is 3d or 4d
if ndims(array) == 3  
    disp('3d image')
elseif ndims(array) == 4 
   warning('4d image, taking the mean across dim 4 - check you are ok with this')
   array = mean(array, 4);
else
    error('(sliceviewplus) requires 3d or 4d data!')
end

% how to extend this + do this properly:
% - NINJA skill: reading in NIFTI files (actual neuroimaging data format)
% - check that the file/path exists, return gracefully if not
% - check the dimensions of the image in hdr and array

h = figure(); % call figure like this, then matlab makes a new window

% change the name of the figure to reflect the image we are looking at
set(h,'Name', hdr.img_name);

% the following hooks up several other functions that get triggered/executed
% when different events happen: e.g. a keypress, mouse click, scroll, etc

set(h,'KeyPressFcn',@keypress);
set(h,'toolbar','none');

% have a function that returns a slice in a particular orientation?
% start with "it would be really great to have a function that does X"
% and then just do/implement it

% decide which dimension we want to keep fixed. we'll call this the
% "orientation" of the image.
orientation = 1; % could be 1, 2, or 3
sliceNum = round(size(array, orientation)./2); % half way through the stack in particular orientation
s = returnSlice(array, sliceNum, orientation); % now grab a slice

% keep everything that we want to pass round neatly wrapped up in a
% STRUCTURE called "data"

data = struct('array', array, 'hdr', hdr, 'currentSliceNum', sliceNum, ...
    'currentOrientation', orientation, 'currentSlice', s);

% fix the colormap and the range of values
data.cmap = gray(256);
data.dataLimits = prctile(array(:),[5 95]);

% attach the wrapped up "data" to the window (handle)
set(h,'UserData',data);

% now for the first time, draw the slice now:
drawSlice(h);

end


% function returnSlice -- has to be completed!


function keypress(h,evnt)
% keypress - gets called every time a key is pressed

% get hold of the data for use in this function...
data=get(h,'UserData');

% disp('Pressed a key')
switch evnt.Key
    case 'uparrow'
        data.currentSliceNum = data.currentSliceNum + 1;
    case 'downarrow'
        data.currentSliceNum = data.currentSliceNum - 1;
    case {'c','C'}
        % NINJA skill
        % toggle between crosshair / arrow (if it's not already in that
        % state
        if ~strcmp(get(h,'Pointer'),'crosshair')
            set(h,'Pointer','crosshair');
        else
            set(h,'Pointer','arrow');
        end
    case {'o','O'}  
        % NINJA skill
        % change orientation... 
        % mod(currentOrientation,3) is the remainder after division with 3,
        % so this means that we never get bigger than 3. One thing to keep
        % in mind here is that mod(x,3) returns 0, 1, 2, 0, 1, 2... so we
        % need to add 1 to make is consistent with our way of counting
        % orientation.
        %
        % help mod     
        data.currentOrientation = mod(data.currentOrientation + 1,3) + 1;
    case {'Q','q','escape'}
        disp('Byebye!')
        close(h); 
        return;
end

% check that we don't go under 0 or over the max
if data.currentSliceNum < 1
    % warn the user
    disp('(keypress) UHOH! trying to go below 0!')
    data.currentSliceNum = 1;
end
% also need to check about the max values don't go over the maximum extent
% in that orientation. my solution: set it to the max (and stop going
% higher)

if data.currentSliceNum > size(data.array, data.currentOrientation)
    data.currentSliceNum = size(data.array, data.currentOrientation);
    disp('(uhoh) had to reset slicenumber when switching orientation')
end

% now also need to put the new slice image into its place
data.currentSlice = returnSlice(data.array, ...
    data.currentSliceNum, ...
    data.currentOrientation);

% pack it up for return by the function
set(h,'UserData',data);

% and draw the new slice
drawSlice(h);

end


function drawSlice(h)
% drawSlice - draws the current slice in the window

figure(h)
% get a local copy of the data 
data = get(h,'UserData');
img = data.currentSlice;

% display (with a particular range, to make sure the colors don't "jump"
% around
imagesc(img, data.dataLimits);
colormap(data.cmap)
colorbar
axis image
axis ij

% add a text label:
t_ = text(0,0,['Slice: ' num2str(data.currentSliceNum, '%d') ] );
set(t_, 'color','w','fontsize',14, 'verticalalignment','top');

end




