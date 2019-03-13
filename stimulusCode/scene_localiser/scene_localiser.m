function myscreen = IWishThisWasPython(subject, screenNum, bigFix)
% scene_localiser - standard scene localiser protocol
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
%     bigFix - Whether to make fixation big or small (default = true)
%
%     e.g.:
%           scene_localiser('1002', 0) % for debug:
%           scene_localiser('1002', 2) % to send to 2nd monitor
% 
% 2019-02 david watson wrote this

%% Key vars - update as needed

defaults.subject = 'test';
defaults.screenNum = 2;
defaults.bigFix = true;

datadir = './data';
screenSize = [1920, 1080];  % [width, height] in pixels
displayDistance = 108; % BOLDscreen<->eye measured on 2019-02-05
displaySize = [69.7 39.2]; % from mglDescribeDisplays
fps = 120;
hvFlip = [false false];  % no mirror - mgl presents lr flipped already


TR = 1.5;  % in secs
cycleLength = 12;  % Full OFF/ON cycle in TRs
global imdir; imdir = './images';
global stimfile; stimfile = './blocklist.csv';

assert(mod(cycleLength, 2) == 0, 'an ODD cycle length will be problematic')


%% Initialise

% Initialise mgl
init_mgl();

% Check args
if nargin == 0
    subject = defaults.subject;
    screenNum = defaults.screenNum;
    bigFix = defaults.bigFix;
elseif nargin == 1
    screenNum = defaults.screenNum;
    bigFix = defaults.bigFix;
elseif nargin == 2
    bigFix = defaults.bigFix;
end

% make debugging work on smaller laptop screen:

if screenNum == 0
    screenSize = [1920, 1080]./2;
end

% Make outdir
% @david_m_watson (small / annoying change because I have to stick to
% R2016a for boring reasons and |isfolder()| is a newer addition.
% if ~isfolder(datadir), mkdir(datadir); end
if exist(datadir,'dir') ~= 7, mkdir(datadir); end

% Read stimfile (declare contents global too)
global stimlist
stimlist = readtable(stimfile, 'ReadVariableNames', false, ...
    'ReadRowNames', false);
numBlocks = size(stimlist, 1);

% report what the parameters lead to:
fprintf('---------\nTiming:\n')
fprintf('TR=%.2f, l=%.1f, #blocks=%d\n', TR, cycleLength, numBlocks)
fprintf('#dynamics=%d+%d\n', cycleLength .* numBlocks, cycleLength/2)
totalTime = TR .* cycleLength .* numBlocks;
fprintf('runtime: %.2fs\n', TR .* cycleLength .* numBlocks)
fprintf('%s (mm:ss)\n', duration(0,0,totalTime, 'format', 'mm:ss'))
fprintf('one ON/OFF block = %ds\n', TR .* cycleLength);


%% set up screen
myscreen.screenParams{1} = {[], ... % computer name
                            '', ... % display name
                            screenNum, ... % screen number
                            screenSize(1), ... % screen width
                            screenSize(2), ... % screen height
                            displayDistance, ... % display distance TODO
                            displaySize, ... % display size TODO
                            fps, ... % FPS
                            true, ... % auto-close screen
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
global fixStimulus
myscreen = initStimulus('fixStimulus', myscreen);
fixStimulus = struct();
fixStimulus.fixLineWidth = 5;
if bigFix
    fixStimulus.fixWidth = 2;
else
    fixStimulus.fixWidth = 1;
end
fixStimulus.stimColor = [0, 1, 1];
fixStimulus.pos = [0, 0];

% Image stimulus
global imStimulus
imStimulus = struct();
myscreen = initStimulus('imStimulus', myscreen);

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

% Phase 2 - display images in OFF/ON cycle
task{1}{2}.numTrials = numBlocks;  % "trials" = blocks in this context
task{1}{2}.seglen = [ones(1, myscreen.blockInSecs(1)), ...
                     ones(1, myscreen.blockInSecs(2))];  % split block into 1s segments
% accept keyboard responses during the second half / when images are shown.
task{1}{2}.getResponse = [zeros(1, myscreen.blockInSecs(1)), ones(1, myscreen.blockInSecs(2))];
task{1}{2}.parameter.showimage = 1;

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

global imdir stimlist imStimulus

fprintf(1, 'Loading images...\n');

% Extract n blocks and trials
numBlocks = size(stimlist, 1);
trialsPerBlock = size(stimlist, 2);

% Choose random trial (not 1st one) in each block to show gray im
imStimulus.grayTrials = randi([2, trialsPerBlock], [1, numBlocks]);

% Loop stimlist
for i = 1:numBlocks
    for j = 1:trialsPerBlock
        thisFile = char(stimlist{i,j});
        key = matlab.lang.makeValidName(thisFile);
        
        % Read image
        im = imread(fullfile(imdir, thisFile));
        
        % MGL presents images wrong way up, so flip array upside-down
        % (also presents them l/r flipped, but this is fine as scanner
        % mirror optically flips images again)
        im = flipud(im);
        
        % Convert to grayscale for specific trials. MGL still requires in
        % colour format, so we set all RGB channels to gray im.
        if j == imStimulus.grayTrials(i)
            gim = rgb2gray(im);
            im(:,:,1) = gim;
            im(:,:,2) = gim;
            im(:,:,3) = gim;
        end
        
        % MGL requires images in RGBA format, and with dimension order
        % CxWxH. Append an alpha channel, then reverse dim order.
        im = cat(3, im, 255 .* ones([size(im, 1), size(im, 2)]));
        im = permute(im, [3,2,1]);
        
        % Convert to texture, append to struct
        imStimulus.images.tex.(key) = mglCreateTexture(im);
    end
end

end


%% function that gets called at the start of each segment
function [task, myscreen] = startSegmentCallback(task, myscreen)

global imStimulus stimlist;

% If we are in 2nd phase (stimulus presentation) and during ON period,
% update image keyname and toggle image display ON
if task.thistrial.thisseg > myscreen.blockInSecs(1) && task.thistrial.showimage
    blockIdx = task.trialnum;
    trialIdx = task.thistrial.thisseg - myscreen.blockInSecs(1);
    imStimulus.currentImage = ...
        matlab.lang.makeValidName(char(stimlist{blockIdx, trialIdx}));
    imStimulus.display = true;
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
    updateImage();
end

% Draw fixation
mglFixationCross(fixStimulus.fixWidth, fixStimulus.fixLineWidth, ...
    fixStimulus.stimColor, fixStimulus.pos)
    
end


%% function to update image texture
function updateImage()

global imStimulus
if imStimulus.display
    % pick the appropriate texture for this display
    tex = imStimulus.images.tex.(imStimulus.currentImage);
        
    % blt textures
    mglBltTexture(tex, [0, 0]);
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
