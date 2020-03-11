function out = phaseScrambleColourImage(im)
% phaseScrambleColourImage - phase scramble colour images.
%
% eg:
%
%    in = imread('Caricatures/FacespaceFemale1CaricLevel1.png');
%    in = imadjust(in, [.1 .1 .1; .5 .5 .5],[]);
%    out = phaseScrambleColourImage(in);
%    figure, montage({out,in})
%
%
% for gray scale images have a look at this:
% h/t:
% https://www.st-andrews.ac.uk/~jma23/code/phaseScrambleImage.m
%
% ds 2020-02-06



imSize = size(im);

% one fixed, but random phase
randPhase = getPhase(randn(imSize(1), imSize(2)));

% take FFT2
if numel(imSize) < 3
    disp('gray scale image')
    out = ifft2(getPower(im) .* exp(1i .* randPhase), 'symmetric');
    return
elseif numel(imSize) == 3
    % disp('colour image, assuming RGB')
    % disp('converting to LAB')
    inLAB = rgb2lab(im);
    for iChannel = 1:3
        imPower = getPower(inLAB(:,:,iChannel));
        outLAB(:,:,iChannel) = ifft2( imPower .* exp(1i .* randPhase) , ...
       'symmetric');
    end
    out = lab2rgb( outLAB );
else
    error('problem with input image / colorspace?')
end
    

end

% helper function for getting power spectrum
function p = getPower(im)
    p = abs(fft2(im));
end

function ph = getPhase(im)
    ph = angle(fft2(im));
end


% in = imadjust(in); % see help for this. robust 1% -> 0 255
