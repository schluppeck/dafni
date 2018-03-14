% some ideas for sub2ind and ind2sub
%
% ds 2018-03-14 in class.

% to avoid loops to index into n-d arrays, we can use the following trick
%
% - take coordinates in 3d and convert to linear index in 3D
% - take 4D array and turn into a 2d array, where dimension 1 = first 3
% dims "unrolled".  so rather than having [nx, ny, nz, nt] (4 dims) we have 
% [nx*ny*nz, nt] (2 dims, where space is all in dim1 and time in dim 2

% assuming you have data loaded in with mlrImageReadNifti...

% coords in 3d - say:
coord   = [19,13,4;
            20,13, 4;
            20,12, 5];

sz_data = size(data);

% convert to linear index
coord_linidx = sub2ind(sz_data(1:3), coord(:,1), coord(:,2), coord(:,3) );

nVoxels = prod(sz_data(1:3));
nTimePoints = sz_data(4);

% reshape into 2d format
data_reshaped = reshape(data, nVoxels, nTimePoints);

% can use linear index
ts_multiple = data_reshaped(coord_linidx,:);

% if you provide x and y.. then you don't have to worry about matching up
% dimensions
plot(1:nTimePoints, ts_multiple)



