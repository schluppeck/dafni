% M1localiser.m
%
%         by: denis schluppeck
%
%       date: C84DAN/PSGY4043 by ds
%    purpose: code for doing a simple left/right finger tapping
%
%       e.g.:
%             M1localiser()
%
function myscreen = M1localiser( varargin )

% evaluate the input arguments
eval(evalargs(varargin));

% setup default arguments
if ieNotDefined('debug'), debug=0; end
if ieNotDefined('displayname'), displayname = ''; end

% scanning params
if ieNotDefined('TR'), TR=1.5; end
if ieNotDefined('flipHV'), flipHV = [0 0]; end

if ieNotDefined('cycleLength'), cycleLength = 16; end
if ieNotDefined('numBlocks'), numBlocks = 10; end
if ieNotDefined('trainingMode'), trainingMode=0; end

% report what the parameters lead to:
fprintf('---------\nTiming:\n')
fprintf('TR=%.2f, l=%.1f, #blocks=%d\n', TR, cycleLength, numBlocks)
totalTime = TR .* cycleLength .* numBlocks;
fprintf('runtime: %.2fs\n', TR .* cycleLength .* numBlocks)
fprintf('%s (mm:ss)\n', duration(0,0,totalTime, 'format', 'mm:ss'))
fprintf('one ON/OFF block = %ds\n', TR .* cycleLength);


if ieNotDefined('subject')
  subject = 'xx'; % default
end

assert(iseven(cycleLength), 'an ODD cycle length will be problematic - please fix')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% other screen parameters
myscreen.autoCloseScreen = 1;
myscreen.saveData = 1;
myscreen.datadir = './';
myscreen.allowpause = 0;
myscreen.eatkeys = 1;
myscreen.displayname = displayname;
myscreen.background = 'gray';
myscreen.TR = TR;
myscreen.cycleLength = cycleLength; % in TRs
myscreen.subject = subject;
myscreen.collectEyeData = 0;


% set up parameters for fixation cross.
global fixStimulus
fixStimulus.fixLineWidth = 0.2; % big line, device units with mglMetal (!)
fixStimulus.trainingMode = trainingMode;
fixStimulus.diskSize = 0.0; % no disk (just superimpose on stim)
fixStimulus.fixWidth = 1;
if debug == 1
  % gethostname and then display the stimulus on the corresponding screen
  % myscreen.screenParams{1} = {gethostname(),[],0,1024,768,80,[31 23],60,1,1,1.4,[],flipHV};
  
  myscreen.screenParams{1} = struct('computerName', gethostname(),...
            'displayName',[], 'screenNumber', 0, ...
		    'screenWidth', 1024, 'screenHeight', 768, 'displayDistance', 80,...
		    'displaySize',[31 23], 'framesPerSecond', 60, 'autoCloseScreen', 1, ...
		    'saveData', 1, 'calibType', 1, 'monitorGamma', 1.4, 'calibFilename',[], ...
		    'flipHV', flipHV, 'digin',[],  'hideCursor', 1, 'displayPos', [],  'backtickChar', '5');

  fixStimulus.fixWidth = 1; 
  fixStimulus.diskSize = 0; 
  
elseif debug == 2
  % not really needed anymore (as mglEditScreenParams takes over!)
  % running at 3T for experiment
  defaultMonitorGamma = 1.8;
  % myscreen.screenParams{1} = {gethostname(),'',2,1280,960,231,[83 3*83/4],60,1,1,defaultMonitorGamma,'',flipHV}; % 3T nottingham
    % myscreen.screenParams{1} = struct('computerName', gethostname(),...
    %         'displayName',[], 'screenNumber', 2, ...
    %         'screenWidth', 1280, 'screenHeight', 960, 'displayDistance', 231,...
    %         'displaySize',[83 3*83/4], 'framesPerSecond', 60, 'autoCloseScreen', 1, ...
    %         'saveData', 1, 'calibType', 1, 'monitorGamma', defaultMonitorGamma, 'calibFilename',[], ...
    %         'flipHV', flipHV, 'digin',[],  'hideCursor', 1, 'displayPos', [],  'backtickChar', '5');
end

% and init myscreen
myscreen = initScreen(myscreen);

% fix keys for our scanner setup.
myscreen.keyboard.backtick = mglCharToKeycode({'5'}); % that's the backtick
myscreen.keyboard.nums = mglCharToKeycode({'1' '2' '3' '4'    '6' '7' '8' '9' '0'});

% set the first task to be the fixation staircase task
[task{1} myscreen] = fixStairInitTask(myscreen);

% set our task to have two phases.
% one starts out with nothing on the screen...
task{2}{1}.waitForBacktick = 1;
task{2}{1}.seglen = 0;
task{2}{1}.numBlocks = 1;
task{2}{1}.parameter.showimage = 0;
task{2}{1}.parameter.category = 0;

% block design timing, during the first chunk of segments we'll show some images
% blank during the second chunk
task{2}{2}.numTrials = numBlocks; %number of trials to go through / blocks of on/off
myscreen.blockDesign =  myscreen.TR*[myscreen.cycleLength myscreen.cycleLength]./2;
blockInS = myscreen.cycleLength * myscreen.TR;

% make it so that an image is shown every second, but for cycleLength/2 ON
task{2}{2}.seglen = ...
    [ones(1,blockInS/2) ones(1,blockInS/2)]

task{2}{2}.parameter.category = [1 2]; % 1=left, 2=right
task{2}{2}.random = 0; % left... rest, right... rest, left reest... 

% initialize our task
for phaseNum = 1:length(task{2})
  [task{2}{phaseNum} myscreen] = initTask(task{2}{phaseNum},myscreen,@startSegmentCallback,@updateScreenCallback,[],[],[],[]);
end

% init the stimulus
global stimulus;
myscreen = initStimulus('stimulus',myscreen);
% load in images and prep textures
stimulus.text.fontSize = 72;
stimulus = initText(stimulus,myscreen);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run the eye calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% myscreen = eyeCalibDisp(myscreen);
% skip this...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main display loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
phaseNum = 1;
myscreen.t0 = mglGetSecs();

while (phaseNum <= length(task{2})) && ~myscreen.userHitEsc
  % update the dots
  [task{2} myscreen phaseNum] = updateTask(task{2},myscreen,phaseNum);
  % update the fixation task
  [task{1} myscreen] = updateTask(task{1},myscreen,1);
  % flip screen
  myscreen = tickScreen(myscreen,task);
end

% if we got here, we are at the end of the experiment
myscreen = endTask(myscreen,task);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function that gets called at the start of each segment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [task myscreen] = startSegmentCallback(task, myscreen)

global stimulus;

myscreen.currentCategory = task.thistrial.category;
if task.thistrial.thisseg == 1
  % print info about category
  fprintf('current category: %d\n', myscreen.currentCategory);
end

% at this point we need to figure out if we are in the first half (REST) or
% second half (STIMULUS). each segment is 1s long by design:

oneCycle = myscreen.cycleLength * myscreen.TR;
if (task.thistrial.thisseg < (oneCycle/2) ) 
  stimulus.text.display = 1;
  myscreen.currentTex = 3; %rest
elseif (task.thistrial.thisseg > (oneCycle/2) ) && myscreen.currentCategory ~=3
  myscreen.t0 = mglGetSecs(myscreen.t0);
  fprintf('timestamp: %.2f\n', myscreen.t0);
  % if currentCategory == 0, then we are in the pre-phase of expt.
  stimulus.text.display = 1;
  myscreen.currentTex = myscreen.currentCategory;
else
  stimulus.text.display = 0;

  
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function that gets called to draw the stimulus each frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [task myscreen] = updateScreenCallback(task, myscreen)

global stimulus
mglClearScreen(0.5); % 

if stimulus.text.display
  stimulus = updateText(stimulus,myscreen);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function at the start or each block ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [task myscreen] = startBlockCallback(task, myscreen)

disp('startblock');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function at the start or each trial ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [task myscreen] = startTrialCallback(task, myscreen)

disp('starttrialcallback');
fprintf('trial #: %d, seg: %d SHOW: %d, ... SIDE: %d\n', task.trialnum,task.thistrial.thisseg, task.thistrial.showimage, task.thistrial.category)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to init the image stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stimulus = initText(stimulus,myscreen)

disp('initText')

fs = stimulus.text.fontSize;

mglClearScreen(0.5); % gray bg
mglTextSet('Helvetica',fs,[0 0 1],0,0,0);
stimulus.text.tex{1} =  mglText('Tap left - L');
mglClearScreen(0.5); % gray bg
mglTextSet('Helvetica',fs,[0.8 0.2 .2],0,0,0);
stimulus.text.tex{2} = mglText('Tap right - R');
mglClearScreen(0.5); % gray bg
mglTextSet('Helvetica',fs,[1 1 1],0,0,0);
stimulus.text.tex{3} = mglText('-- rest --');

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to update dot positions and draw them to screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stimulus = updateText(stimulus,myscreen)

if stimulus.text.display
  % pick the appropriate texture for this display
  tex = stimulus.text.tex{ myscreen.currentTex };
  mglBltTexture(tex,[0 4],'center','bottom');
end

end
