function s = returnSlice(array, sliceNum, orientation)
% returnSlice - return a single slice from a 3d image
 
% if orientation is not given, keep the last (3rd?) index fixed
if nargin < 3, orientation = 3; end
 
% pick data, keeping dimension=?orientation? fixed 
switch orientation
    case 1
        s = array(sliceNum,:,:);
    case 2
        s = array(:,sliceNum,:);
    case 3
        s = array(:,:,sliceNum);
end
 
% now also make sure that s doesn't have 
% some weird extraneous dimensions - GOTCHA
s = squeeze(s);
 
end
