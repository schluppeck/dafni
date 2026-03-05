function theTimeseries = returnTimecourse(input4D, x,y,z)
% returnTimecourse - take in a 4d dataset and return a timecourse
%
% this function takes in a 4d volume, eg fmri and returns
% a 1d timeseries at the chosen x,y,z locations
%
% ds, 2025-03-06, during dafni class to demo functions
%
% see also: imagesc, image, index


theTimeseries = input4D(x,y,z,:);

theTimeseries = squeeze(theTimeseries);

end