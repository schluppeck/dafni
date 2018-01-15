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
function myscreen = FFAlocaliser( varargin )

% evaluate the input arguments
eval(evalargs(varargin));

% setup default arguments
if ieNotDefined('debug'), debug=1; end

% scanning params
if ieNotDefined('TR'), TR=2.0; end
if ieNotDefined('cycleLength'), cycleLength = 10; end
if ieNotDefined('numBlocks'), numBlocks = 12; end

% report what the parameters lead to:
fprintf('---------\nTiming:\n')
fprintf('TR=%.2f, l=%.1f, #blocks=%d\n', TR, cycleLength, numBlocks)
totalTime = TR .* cycleLength .* numBlocks;
fprintf('runtime: %.2fs\n', TR .* cycleLength .* numBlocks)
fprintf('%s (mm:ss)\n', duration(0,0,totalTime, 'format', 'mm:ss'))

if ieNotDefined('subject')
  subject = 'xx'; % default
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% other screen parameters
myscreen.autoCloseScreen = 1;
myscreen.saveData = 1;
myscreen.datadir = './';
myscreen.allowpause = 0;
myscreen.eatkeys = 1;
myscreen.displayname = 'projector';
myscreen.background = 'black';
myscreen.TR = TR;
myscreen.cycleLength = cycleLength; % in TRs
myscreen.subject = subject;

if debug
  % gethostname and then display the stimulus on the corresponding screen
  myscreen.screenParams{1} = {gethostname(),[],0,800,600,57,[31 23],60,1,1,1.4,[],[0 0]};
else
  % running at 3T for experiment
  defaultMonitorGamma = 1.8;
  myscreen.screenParams{1} = {gethostname(),'',2,1024,768,231,[83 3*83/4],60,1,1,defaultMonitorGamma,'',[0 0]}; % 3T nottingham
end

% and init myscreen
myscreen = initScreen(myscreen);

myscreen.keyboard.backtick = mglCharToKeycode({'5'}); % that's the backtick
myscreen.keyboard.nums = mglCharToKeycode({'1' '2' '3' '4'    '6' '7' '8' '9' '0'});

% set up parameters for fixation cross.
global fixStimulus
fixStimulus.diskSize = 0.5;

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

task{2}{2}.parameter.category = [1 2 3]; % 1=face, 2=house, 3=scrambled face
task{2}{2}.random = 1;

% initialize our task
for phaseNum = 1:length(task{2})
  [task{2}{phaseNum} myscreen] = initTask(task{2}{phaseNum},myscreen,@startSegmentCallback,@updateScreenCallback,[],[],[],[]);
end

% init the stimulus
global stimulus;
myscreen = initStimulus('stimulus',myscreen);
% stimulus = initDots(stimulus,myscreen);
stimulus = initFaces(stimulus,myscreen);

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

if (task.thistrial.thisseg <= myscreen.blockDesign(1) ) && myscreen.currentCategory > 0
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
disp('initFaces')

% stim directories are hard-coded. Could do better here.
imdir{1} = './stims/multiracial/frontal/';
files{1} = dir([imdir{1} '*.jpg']);
nFiles{1} = length(files{1});

imdir{2} = './stims/objects/';
files{2} = dir([imdir{2} '*.jpg']);
nFiles{2} = length(files{2});

imdir{3} = './stims/houses/';
files{3} = dir([imdir{3} '*.jpg']);
nFiles{3} = length(files{3});

% stimulusImages = cell(nFiles);

for iCat = 1:3
    for iFile = 1:nFiles{iCat}
      fprintf('loading file #%d, name:%s\n',iFile,files{iCat}(iFile).name);
      im = []; im2 = []; % must be a faster way to do this.
      im = imread(fullfile(imdir{iCat}, files{iCat}(iFile).name));
      im2 = permute(...
          cat(3,im, 255.*ones([size(im,1), size(im,2)])),...
            [3,1,2]);
      %NB! jpeg image is read in as RGB triplet
      % might need to change sizes, etc.

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

%disp('updateFaces')

if stimulus.faces.display
  mglBltTexture(stimulus.faces.tex{ myscreen.currentCategory }(stimulus.faces.exemplar),[0 0], 0, 0, 0)
end

end
