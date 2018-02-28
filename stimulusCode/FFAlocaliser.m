% FFAlocaliser.m
%
%         by: alex beckett and denis schluppeck
%
%       date: 09/07/06; mods for C84DAN by ds
%    purpose: code for doing face and object area localiser.
%             images courtesy of Tim Andrews (York) and others.
%
%       e.g.:
%             FFAlocaliser()
%
% make sure to also look at jazLocaliser.m for event-related expt
function myscreen = FFAlocaliser( varargin )

% evaluate the input arguments
eval(evalargs(varargin));

% setup default arguments
if ieNotDefined('debug'), debug=0; end

% scanning params
if ieNotDefined('TR'), TR=1.5; end
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
myscreen.displayname = '';
myscreen.background = 'white';
myscreen.TR = TR;
myscreen.cycleLength = cycleLength; % in TRs
myscreen.subject = subject;
myscreen.collectEyeData = 0;

% set up parameters for fixation cross.
global fixStimulus
fixStimulus.fixLineWidth = 7; % big line
fixStimulus.trainingMode = trainingMode;
fixStimulus.diskSize = 0.0; % no disk (just superimpose on stim)
fixStimulus.fixWidth = 1;
if debug == 1
  % gethostname and then display the stimulus on the corresponding screen
  myscreen.screenParams{1} = {gethostname(),[],0,1024,768,80,[31 23],60,1,1,1.4,[],[0 0]};
  fixStimulus.fixWidth = 1; 
  fixStimulus.diskSize = 0; 

elseif debug == 2
  % running at laptop on full screen
  defaultMonitorGamma = 1.8;
  myscreen.screenParams{1} = {gethostname(),'',1,1440, 900,57,[331.0045, 206.8778],60,1,1,defaultMonitorGamma,'',[0 0]}; 
  fixStimulus.fixWidth = 5; % make cross large
  fixStimulus.diskSize = 5; % allow text to be shifted
  
else    
  % running at 3T for experiment
  defaultMonitorGamma = 1.8;
  myscreen.screenParams{1} = {gethostname(),'',2,1280,960,231,[83 3*83/4],60,1,1,defaultMonitorGamma,'',[0 0]}; % 3T nottingham
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

task{2}{2}.parameter.category = [1 2]; % 1=faces, 2=objects
task{2}{2}.random = 0; % face , object, face, object, ...

% initialize our task
for phaseNum = 1:length(task{2})
  [task{2}{phaseNum} myscreen] = initTask(task{2}{phaseNum},myscreen,@startSegmentCallback,@updateScreenCallback,[],[],[],[]);
end

% init the stimulus
global stimulus;
myscreen = initStimulus('stimulus',myscreen);
% load in images and prep textures
stimulus = initFaces(stimulus,myscreen);
stimulus.displayWidth = 10; % decide how WIDE the stimuli should be

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run the eye calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myscreen = eyeCalibDisp(myscreen);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main display loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
phaseNum = 1;
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

% save out some text files for this experiment
makeFSLfiles(myscreen, task)

end

function [] = makeFSLfiles(myscreen, task)
% makeFSLfiles - save out files of stimulus descriptions...
%

% faces:
d = datestr(now, 30);

% objects:


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
if (task.thistrial.thisseg > (oneCycle/2) ) && myscreen.currentCategory > 0
  myscreen.t0 = mglGetSecs();
  fprintf('timestamp: %.2f\n', myscreen.t0);
  % if currentCategory == 0, then we are in the pre-phase of expt.
  stimulus.faces.display = 1;
  % at the beginning of each trial, pick a random image from our set of N
  stimulus.faces.exemplar = randsample(stimulus.faces.n{ myscreen.currentCategory },1);
else
  stimulus.faces.display = 0;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function that gets called to draw the stimulus each frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [task myscreen] = updateScreenCallback(task, myscreen)

global stimulus
mglClearScreen(1); % white

if stimulus.faces.display
  stimulus = updateFaces(stimulus,myscreen);
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
fprintf('trial #: %d, seg: %d SHOW: %d, ... CATEGORY: %d\n', task.trialnum,task.thistrial.thisseg, task.thistrial.showimage, task.thistrial.category)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to init the image stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stimulus = initFaces(stimulus,myscreen)

nCateogories = 2;
disp('initFaces')


% stim directories are hard-coded. Could do better here.
imdir{1} = './stims/multiracial/frontal/';
files{1} = dir([imdir{1} '*.jpg']);
nFiles{1} = length(files{1});

imdir{2} = './stims/objects/';
files{2} = dir([imdir{2} '*.jpg']);
nFiles{2} = length(files{2});

% imdir{3} = './stims/houses/';
% files{3} = dir([imdir{3} '*.jpg']);
% nFiles{3} = length(files{3});

% stimulusImages = cell(nFiles);

for iCat = 1:numel(imdir)
    for iFile = 1:nFiles{iCat}
      fprintf('loading file #%d, name:%s\n',iFile,files{iCat}(iFile).name);
      im = []; im2 = []; % must be a faster way to do this.
      im = imread(fullfile(imdir{iCat}, files{iCat}(iFile).name));
      im2 = permute(...
          cat(3,im, 255.*ones([size(im,1), size(im,2)])),...
            [3,2,1]);
        
      %NB! jpeg image is read in as RGB triplet
      
      % grayscale option:
      %im = double(rgb2gray(imread(fullfile(imdir{iCat}, files{iCat}(iFile).name))));
      %im = flipud(im);

      mglClearScreen(1); % white bg
      stimulus.faces.tex{iCat}(iFile) = mglCreateTexture(im2);
    end
    stimulus.faces.n{iCat} = nFiles{iCat};
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to update dot positions and draw them to screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stimulus = updateFaces(stimulus,myscreen)

if stimulus.faces.display
  % pick the appropriate texture for this display
  tex = stimulus.faces.tex{ myscreen.currentCategory }(stimulus.faces.exemplar);
  aspectRatio = tex.imageWidth ./ tex.imageHeight;
  % blt textures. 180º / upside down as images are read in that way.
  mglBltTexture(tex,...
      [0, 0, stimulus.displayWidth, stimulus.displayWidth/aspectRatio], ...
       0, 0, 180);
end

end
