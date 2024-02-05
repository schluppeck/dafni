function makeMontage(data, nSlices)
% makeMontage - make a simple image montage from 3d data
%
%     data: input data (3d)
%     nSlices: number of slices to display    
%
%
%  see also: montage, imagesc, prctile
%
% ds 2019-03-14 (for dafni class)
% ds 2023-02-28, scrubbed up for posting online

if nargin < 2
    % if person doesn't provide 2nd input argument
    % display help
    help makeMontage
end

% here you could also deal with 4d data, by eg. picking only 
% the first timepoint or by taking the mean across time...
if ndims(data) ~= 3
    error('at the moment, we can only handle 3d data')
    return
end

% use montage() function in matlab to do the grunt work
% doc montage for more detail.

% image brightness / contrast
% idea: use 5 and 95 prctile values to restrict that display range
robustRange = prctile(data(:), [5 95]);


% which slices should we display
% how many slices are there?
actualNslices = size(data, 3);

% e.g. user ask for 25 slices... we need to go from 
% 1... actualNslices in 25 steps.... but make sure they are integers!
% round( linspace(1,256, 25) )

whichSlices = round( linspace(1, actualNslices, nSlices));

% permuted data set is in the correction orientation for us.
montage(data, 'DisplayRange', robustRange, 'Indices', whichSlices)

end