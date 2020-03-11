function myscreen = caricature_localiser(subject, screenNum, varargin)
% caricature_localiser - standard face/caricature localiser protocol
%
%     runs a pseudorandomised block design (order given in 
%     blocklist.txt). 
%
%     @DS, make sure to adjust TR, cyclelength in script if 
%     fMRI protocol changes. # of dynamics needs to be correct for
%     number of blocks (see rality check messages at start of script).
%
%     Arguments
%     ---------
%     subject - Subject ID (default = 'test')
%     screenNum - Screen number (0 = small on main monitor, 2 = fullscreen
%       on second monitor) (default = 2)
%     stimSet - 1 = face localiser, 2 = caricature stim (default = 1)
%     bigFix - Whether to make fixation big or small (default = true)
%     TR - default, 1.5s
%     colourCorrect, default 'dehaze'
%
%     e.g.:
%           caricature_localiser('1002', 0) % for debug:
%           caricature_localiser('1002', 2) % to send to 2nd monitor
%
%
%           caricature_localiser('1002', 0, 'colourCorrect=increaseall') 
%           
%           % use a clipped gaussian to blend into gray 
%           caricature_localiser('1002', 0, 'maskBackground=true') 
%
% 
%           caricature_localiser('1002', 0, 'maskBackground=1', 'phScrambleControl=1') 
%

% 2019-02     david watson wrote this
% 2019-12-09  ds, mods to run from OneDrive / for Ryan Elson's thesis
% 2020-01-22  ds, add some evalargs() magic to improve default params setting

%% set arguments using evalargs() magic

validArgs = {'subject', 'screenNum', 'stimSet', ...
    'colourCorrect', 'bigFix', 'TR', ...
    'maskBackground', ... %
    'clearCache', ... % avoid re-computing textures (not working yet)
    'infoOnly', ...  % report timing in console window (useful at scanner
    'phScrambleControl' ... % use phase scrambled images as controls (default, yes)
    };

eval(evalargs(varargin));

% named arg
if ieNotDefined('subject'), subject = 'test'; end
if ieNotDefined('screenNum'), screenNum = 0; end

% these may or may not come in in varargin
if ieNotDefined('stimSet'), stimSet = 2; end
if ieNotDefined('bigFix'), bigFix = false; end
if ieNotDefined('TR'), TR = 2; end
if ieNotDefined('colourCorrect'), colourCorrect = 'imadjusthsv'; end
if ieNotDefined('maskBackground'), maskBackground = false; end
if ieNotDefined('clearCache'), clearCache = false; end
if ieNotDefined('infoOnly'), infoOnly = false; end
if ieNotDefined('phScrambleControl'), phScrambleControl = false; end


%% Key vars - update as needed

datadir = './data';
screenSize = [1920, 1080];  % [width, height] in pixels
displayDistance = 108; % BOLDscreen<->eye measured on 2019-02-05
displaySize = [69.7 39.2]; % from mglDescribeDisplays
fps = 120;
hvFlip = [false false];  % no mirror - mgl presents lr flipped already

cycleLength = 10;  % Full OFF/ON cycle in TRs
% global imdir; imdir = './images'; % @DS images now on github, too!
% global stimfile; stimfile = './blocklist.csv';

assert(mod(cycleLength, 2) == 0, 'an ODD cycle length will be problematic')


%% Initialise

% Initialise mgl (paths)
init_mgl();

% Check args / replaced by defaults through evalargs() and related code

% Set image path
switch stimSet
    case 1
        imdir = './images'; % Localiser images on github
        stimfile = './blocklist.csv';
    case 2
        imdir = './Caricatures'; % Caricatures need uploading to github
        stimfile = './caricature_blocklist.csv';
        % caricature = true; % determined by stimSet
end

% keep info about stimlist, imdir, etc. for use elsewhere
% try to wrap everything into myscreen or these stimulus variables (making
% this global avoid re-computing on second run)
global imStimulus
global fixStimulus

imStimulus.imdir = imdir;
imStimulus.stimfile = stimfile;

% make debugging work on smaller laptop screen:
if screenNum == 0
    screenSize = [1920, 1080]./2;
end

% Make outdir
% @david_m_watson (small / annoying change because I have to stick to
% R2016a for boring reasons and |isfolder()| is a newer addition.
% if ~isfolder(datadir), mkdir(datadir); end
if exist(datadir,'dir') ~= 7, mkdir(datadir); end

% Read stimfile (avoid global by making it part of imStimulus)
stimlist = readtable(stimfile, 'ReadVariableNames', false, ...
    'ReadRowNames', false);
imStimulus.stimlist = stimlist;

numBlocks = size(stimlist, 1);

% report what the parameters lead to:
fprintf('---------\nTiming:\n')
fprintf('TR=%.2f, l=%.1f, #blocks=%d\n', TR, cycleLength, numBlocks)
fprintf('#dynamics=%d+%d = %d (total)   \n', cycleLength .* numBlocks, cycleLength/2, ...
    cycleLength .* numBlocks + cycleLength/2)
totalTime = TR .* cycleLength .* numBlocks;
fprintf('runtime: %.2fs\n', TR .* cycleLength .* numBlocks)
fprintf('%s (mm:ss)\n', duration(0,0,totalTime, 'format', 'mm:ss'))
fprintf('one ON/OFF block = %ds\n', TR .* cycleLength);

if infoOnly
    disp('infoOnly flag set - returning')
    fprintf('---------\n')
    return
end

%% set up screen
myscreen.screenParams{1} = {[], ... % computer name
                            '', ... % display name
                            screenNum, ... % screen number
                            screenSize(1), ... % screen width
                            screenSize(2), ... % screen height
                            displayDistance, ... % display distance TODO
                            displaySize, ... % display size TODO
                            fps, ... % FPS
                            false, ... % auto-close screen
                            true, ...  % save data
                            1.8, ... % gamma correction
                            '', ... % calibration file
                            hvFlip  % [horiz vert] flip
                            };
myscreen.datadir = datadir;
myscreen.allowpause = false;
myscreen.eatkeys = true;
myscreen.background = 127;
myscreen.TR = TR;
myscreen.cycleLength = cycleLength; % in TRs
myscreen.subject = subject;
myscreen.collectEyeData = false;

myscreen = initScreen(myscreen);


%% Set up stimuli and stuff

% Fixation stimulus
myscreen = initStimulus('fixStimulus', myscreen);

fixStimulus = struct();
fixStimulus.fixLineWidth = 4;
if bigFix
    fixStimulus.fixWidth = 2;
else
    fixStimulus.fixWidth = 1;
end
fixStimulus.stimColor = [0, 0, 0];
fixStimulus.pos = [0, 0];

% Image stimulus
myscreen = initStimulus('imStimulus', myscreen);

% add info that you want to be passed around between functions
imStimulus.stimSet = stimSet;
imStimulus.colourCorrect = colourCorrect;
imStimulus.maskBackground = maskBackground;
imStimulus.clearCache = clearCache; % enable reuse of stimuli...
imStimulus.phScrambleControl = phScrambleControl; 
imStimulus.showControl = false; % semaphore that switches back and forth

% fix keys for our scanner setup.
myscreen.keyboard.backtick = mglCharToKeycode({'5'}); % that's the backtick
myscreen.keyboard.nums = mglCharToKeycode({'1' '2' '3' '4'    '6' '7' '8' '9' '0'});

% Some extra params about block cycles
myscreen.blockInSecs =  myscreen.TR * [myscreen.cycleLength/2, myscreen.cycleLength/2];

% load in images and prep textures
initImages();


%% Set task - image display

% Phase1 - do nothing, wait for backtick from scanner
task{1}{1}.waitForBacktick = 1;
task{1}{1}.seglen = 0;
task{1}{1}.numBlocks = 1;
task{1}{1}.parameter.showimage = 0;
task{1}{1}.randVars.invert = 0; % compute pseudorandom sequence for inversion

% Phase 2 - display images in OFF/ON cycle
task{1}{2}.numTrials = numBlocks;  % "trials" = blocks in this context
task{1}{2}.seglen = [ones(1, myscreen.blockInSecs(1)), ...
                     ones(1, myscreen.blockInSecs(2))];  % split block into 1s segments
% accept keyboard responses during the second half / when images are shown.
task{1}{2}.getResponse = [zeros(1, myscreen.blockInSecs(1)), ...
                          ones(1, myscreen.blockInSecs(2))];
task{1}{2}.parameter.showimage = 1; 
task{1}{2}.randVars.invert = load('invert.txt'); % not computed by MGL, but from text file (a bit unusual)

% initialize task
for phaseNum = 1:length(task{1})
    [task{1}{phaseNum}, myscreen] = ...
        initTask(task{1}{phaseNum}, myscreen, @startSegmentCallback, ...
        @updateScreenCallback, @trialResponseCallback, [], [], []);
end


%% Main display loop
phaseNum = 1;
while (phaseNum <= length(task{1})) && ~myscreen.userHitEsc
    % update the image
    [task{1}, myscreen, phaseNum] = updateTask(task{1},myscreen,phaseNum);
    % flip screen
    myscreen = tickScreen(myscreen,task);
end

% if we got here, we are at the end of the experiment. Wait one more
% OFF period then close.
mglClearScreen();
mglFlush();
mglWaitSecs(sum(myscreen.blockInSecs(1)));
fprintf(1, '\nDone\n');
myscreen = endTask(myscreen,task);

end



%% function reads all images in stimlist and converts to MGL textures
function initImages()

global imStimulus 

% caching not quite working (even though textures seem to be stored
% correctly? not quite sure what's going on... @DS
%
% if isfield(imStimulus, 'cached') && imStimulus.cached == true
%     disp('reusing cached images...')
%     return
% end

fprintf(1,'Loading images...\n');

% Extract n blocks and trials
numBlocks = size(imStimulus.stimlist, 1);
trialsPerBlock = size(imStimulus.stimlist, 2);
nImages = numBlocks .* trialsPerBlock;

% Choose random trial (not 1st one) in each block to show gray im
imStimulus.grayTrials = randi([2, trialsPerBlock], [1, numBlocks]);

% Loop stimlist
t = tic();
for i = 1:numBlocks
    for j = 1:trialsPerBlock
        
        thisFile = char(imStimulus.stimlist{i,j});
        % At a guess this takes the first set of characters in the
        % filename, so when hits 
        key = matlab.lang.makeValidName(thisFile);
        
        % Read image
        im = imread(fullfile(imStimulus.imdir, thisFile));
        
        % Increase size of caricature images
        % @DS: make this "caricature" a field in stimulus struct to reduce
        % global variables
        if imStimulus.stimSet == 2
            im = imresize(im, 4);
        end
        

        
        % RE colour correct images here colourCorrectImage currently found
        % in 'stimulus_generation/' - consider move to 'stimulus_code'
        if ~isempty(imStimulus.colourCorrect) && ~strcmp(imStimulus.colourCorrect, 'none')
            im = colourCorrectImage(im, imStimulus.colourCorrect);
            % convert to 0-255 (8bit) to make compatible with alpha channel
            % values
            im = uint8(im .* 255); % im on RHS is on interval [0...1]
        end
        
        % MGL presents images wrong way up, so flip array upside-down
        % (also presents them l/r flipped, but this is fine as scanner
        % mirror optically flips images again)
        %
        % DS: this is actually a transpose (images are in COL, ROW rather
        % than ROW, COL... so
        im = flipud(im);
        
        % Convert to grayscale for specific trials. MGL still requires in
        % colour format, so we set all RGB channels to gray im.
        if j == imStimulus.grayTrials(i)
            gim = rgb2gray(im);
            im(:,:,1) = gim;
            im(:,:,2) = gim;
            im(:,:,3) = gim;
        end
        
        % BG removal if asked for (works better on uncorrected images
        % does not work with distorted images, so use mask instead?
        if imStimulus.maskBackground
            alphaChannel = 255 .* getMask([size(im,1), size(im,2)]); % use and display for debug
        else
            % all 255 (fully non-transparent)
            alphaChannel = 255 .* ones([size(im, 1), size(im, 2)]);
        end
        
        % MGL requires images in RGBA format, and with dimension order
        % CxWxH. Append an alpha channel, then reverse dim order.
       
        % alphaChannel = 255 .* ones([size(im, 1), size(im, 2)]);
        imRGBA = cat(3, im, alphaChannel);
        im = permute(imRGBA, [3,2,1]);
        
        
        % Convert to texture, append to struct
        imStimulus.images.tex.(key) = mglCreateTexture(im);

        if imStimulus.phScrambleControl
            
            % get phaseScrambled control (but only if we need it)
            imControl = phaseScrambleColourImage(imRGBA(:,:, [1:3]));
            
            % imControlForTex = permute( cat(3, imControl, alphaChannel), ...
            %                                        [3,2,1]);
            imControlForTex = permute( cat(3, uint8(imControl .* 100), alphaChannel), ...
                [3,2,1]);
            % keyboard
            
            % stash away (convert and swap dims first)
            imStimulus.controls.tex.(key) = mglCreateTexture(imControlForTex);
        end
    end
end
fprintf('%i images done.\n', nImages);
toc(t);


imStimulus.cached = true; % currently not used!

end


%% function that gets called at the start of each segment
function [task, myscreen] = startSegmentCallback(task, myscreen)

global imStimulus;

% If we are in 2nd part of block (stimulus presentation) and during ON period,
% update image keyname and toggle image display ON
inControlBlock = (task.thistrial.thisseg <= myscreen.blockInSecs(1) && task.thistrial.showimage && imStimulus.phScrambleControl);
if (task.thistrial.thisseg > myscreen.blockInSecs(1) && task.thistrial.showimage) 
    % or we are in first bit (control) and phScrambleControl is true
    blockIdx = task.trialnum;
    trialIdx = task.thistrial.thisseg - myscreen.blockInSecs(1);
    imStimulus.currentImage = ...
        matlab.lang.makeValidName(char(imStimulus.stimlist{blockIdx, trialIdx}));
    imStimulus.display = true;
    
    % also set whether we want to display image or controlTex
    imStimulus.showControl = false; % true if IN conrol, false if in STIMULUS block.
elseif inControlBlock
    
    blockIdx = task.trialnum;
    trialIdx = task.thistrial.thisseg;%  - myscreen.blockInSecs(1);
    imStimulus.currentImage = ...
        matlab.lang.makeValidName(char(imStimulus.stimlist{blockIdx, trialIdx}));
    imStimulus.display = true;
    
    imStimulus.showControl = true;
else  % either in 1st phase or OFF period - toggle image display OFF
    imStimulus.display = false;
end

end


%% function that gets called to draw the stimulus each frame
function [task, myscreen] = updateScreenCallback(task, myscreen)
global fixStimulus imStimulus
mglClearScreen();

% Update image 
if imStimulus.display
    % the task.thistrial.invert value gets updated dynamically on each
    % trial
    updateImage( task.thistrial.invert );
end

% Draw fixation
mglFixationCross(fixStimulus.fixWidth, fixStimulus.fixLineWidth, ...
    fixStimulus.stimColor, fixStimulus.pos)
    
end


%% function to update image texture
function updateImage(invert)
global imStimulus

% RE 2020-02-04 - only want to invert for caricature set
if nargin < 1 || imStimulus.stimSet == 1
    % set default to make backwards compatoible
    invert = 0;
end

% Quick fix, if using premade inverted stimuli then de-comment this so that
% no stimuli are inverted within this script.
invert = 0;

if imStimulus.display
    
    if imStimulus.showControl
        % pick the appropriate texture for this display
        tex = imStimulus.controls.tex.(imStimulus.currentImage);
    else
        tex = imStimulus.images.tex.(imStimulus.currentImage);
    end

    % blt textures (if invert == 1, then rotate 180º)
    mglBltTexture(tex, [0, 0], 0, 0, invert .* 180);
end
end

%% function that gets executed on each keyboard response
function [task, myscreen] = trialResponseCallback(task, myscreen)

global fixStimulus imStimulus

% the following variable contains information about which trial is "gray":
% imStimulus.grayTrials = randi([2, trialsPerBlock], [1, numBlocks]);

fprintf('participant responded\ntrial/seg: [%d, %d]\n', task.trialnum, task.thistrial.thisseg);

% can add logic here to check if we are +1 segment along? edge case: last
% image in block, but would be ok to live with this.

end

%% colour correction of stimuli...

function retIm = colourCorrectImage(im, correctionType)
% colourCorrectImage - take caricature images and make the fMRI friendly
% 
%
% %  eg:
%       face_test_normal = imread('Facespace_Male1_1.png');
%       cIm = colourCorrectImage(face_test_normal, 'adapthisteq');
%       cHaze = colourCorrectImage(face_test_normal, 'dehaze');
%       cIncreaseAll = colourCorrectImage(face_test_normal, 'increaseall')
%       cReplaceLow = colourCorrectImage(face_test_normal, 'replacelow')
%        % stich together in dim 4
%       combined = cat(4, face_test_normal, cHaze);
%       montage(combined)
%
% ds 2020-01-14 exploring some options

switch correctionType
    case 'adapthisteq'  
        % see CLAHE
        LAB = rgb2lab(im);
        L = LAB(:,:,1)/100;
        L = adapthisteq(L,'NumTiles',[8 8],'ClipLimit',0.005);
        LAB(:,:,1) = L*100;
        retIm = lab2rgb(LAB);
    case 'dehaze'
        % help low light enhancement
        retIm = imcomplement( imreducehaze( imcomplement(im) ));
    case 'increaseall'
        % Increase the values of all pixels
        retIm = im + 60;
    case 'replacelow'
        % Increase the value of low pixels to set value.
        retIm = im;
        retIm(retIm < 60) = 60;
    case 'imadjusthsv'
        % Convert to HSV, change range of V using imadjust, then convert back to RGB
        hsvIm = rgb2hsv(im);
        hsvIm = imadjust(hsvIm, [0 0 0; 1 1 0.6],[]); % 0.6 somewhat arbitrary, tried scale based on max value in image but this had drastically different effects for normals faces vs caricatures.
        retIm = hsv2rgb(hsvIm);
    otherwise
        warning('no correctionType specified - just returing original')
        retIm = im;
end

end


function mask = getImageBackground(img, display)
% getBackground - try to automatically label image bg
%
%    eg:
%     faceim = imread('Facespace_Male1_1.png');
%     bg = getImageBackground(faceim, true); % use and display for debug
%     faceimDehaze = colourCorrectImage(faceim, 'dehaze');
%
%     fig_ = imshow(faceimDehaze, 'InitialMagnification', 'fit');
%     alpha(gca, double(bg))
%
%
% ds 2020-01-22 (based on matlab blog post (see below)

if nargin < 2
    display = false
end

%@TODO - check out magic numbers / params in here
gray = rgb2gray(img);
SE  = strel('Disk',1,4);
morphologicalGradient = imsubtract(imdilate(gray, SE),imerode(gray, SE));
mask = im2bw(morphologicalGradient,0.03);
SE  = strel('Disk',3,4);
mask = imclose(mask, SE);
mask = imfill(mask,'holes');
mask = bwareafilt(mask,1);
notMask = ~mask;
mask = mask | bwpropfilt(notMask,'Area',[-Inf, 5000 - eps(5000)]);

if display
    imshow(img, 'InitialMagnification', 'fit'); 
    showMaskAsOverlay(0.5,mask,'r'); %file exchange helper function
end

end


