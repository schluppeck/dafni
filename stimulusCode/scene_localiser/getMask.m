function m = getMask(imSize, p)
% getMask - get a mask
%
%        created raisedCosine (circular) aperture
%
%        calculations in pixel space
%
%  eg:   % p = [w, pos]
%        % default values are [maxR./10, minR./2.1];
%        
%        m = getMask([100,120]);
%        figure, imagesc(m), axis image
%
%
% 2020-01-28

% pixel space! images are not stored the same as matrices!
[X, Y] = meshgrid(1:imSize(1), 1:imSize(2));

% find max dimension
maxR = max(imSize(:));
minR = min(imSize(:));

if nargin < 2
    p = [maxR./10, minR./2.1]; % defaults
end

% lookup table
w = p(1);  % make a param
pos = p(2); % pos of rcosFn ramp

[Xc, Yc] = rcosFn(w, pos); %w, pos

r = sqrt((X-imSize(1)./2).^2 + (Y-imSize(2)/2).^2); % centered
m = interp1(Xc, 1-Yc, r);
m(r<=pos) = 1.0; % fill 

m = m'; % flip xy
end




%% JG's helper function for making gaussians... not actually used here

% Gaussian
%
% usage: gauss(p,X,Y);
%   p is an array of parameters:
%     p(1) = height of Gaussian
%     p(2) = center x
%     p(3) = center y
%     p(4) = SD in x dimension
%     p(5) = SD in y dimension
%     p(6) = offset
%     p(7) = rotation in radians
%   X and Y are the position on which to evaluate the gaussian
%     to evaluate at a matrix of points use,
%     e.g. [X,Y] = meshgrid(-1:.1:1,-1:.1:1);
%
%  the function can also be called as follows for 1D
%  usage: gauss(p,X);
%
%     p(1) = height of Gaussian
%     p(2) = center
%     p(3) = SD
%     p(4) = offset
% 
%   by: justin gardner
% date: 6/6/97
function G=gauss(p,X,Y)

% 2D Gaussian 
if nargin == 3

  % rotate coordinates
  % note that the negative sign is because
  % we are rotating the coordinates and not the function
  X1 = cos(-p(7)).*X - sin(-p(7)).*Y;
  Y1 = sin(-p(7)).*X + cos(-p(7)).*Y;

  % calculate the Gaussian
  G = p(1) * exp(-((((X1-p(2)).^2)/(2*p(4)^2))+(((Y1-p(3)).^2)/(2*p(5)^2))))+p(6);
  
% 1D Gaussian
elseif nargin == 2

  % calculate the Gaussian
  G = p(1) * exp(-(((X-p(2)).^2)/(2*p(3)^2)))+p(4);
  
else 
   % usage error
   disp('USAGE: gauss(parameters, X, Y)');
end

end