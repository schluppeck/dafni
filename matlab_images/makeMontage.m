function makeMontage(filename, nSlices)
% makeMontage - make a simple image montage from 3d data
%
%     input: filename (valid nifti file)
%     nSlices: number of slices to display    
%
% ds 2019-03-14 (for dafni class)

if nargin < 2
    % if person doesn't provide 2nd input argument
    % display help
    help makeMontage
end


% load in nifti file
data = niftiread(filename);

if ndims(data) ~= 3
    error('at the moment, we can only handle 3d data')
end

% use montage() function in matlab to do the grunt work
% doc montage for more detail.

% image brightness / contrast
% idea: use 5 and 95 prctile values to restrict that display range
robustRange = prctile(data(:), [5 95]);

% reorient the cube of data... to get axial slices.
% NB! this works for "sagittal" anatomical images, for other 
% image acquisitions, we'd have to do some more work to figure out 
% what to do
dataP = permute(data, [ 1, 3, 2 ] );

% which slices should we display
% how many slices are there?
actualNslices = size(dataP, 3);

% e.g. user ask for 25 slices... we need to go from 
% 1... actualNslices in 25 steps.... but make sure they are integers!
% round( linspace(1,256, 25) )

whichSlices = round( linspace(1, actualNslices, nSlices));

% permuted data set is in the correction orientation for us.
montage(dataP, 'DisplayRange', robustRange, 'Indices', whichSlices)

end