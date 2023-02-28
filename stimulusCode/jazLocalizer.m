% jazLocalizer - localiser run for Jazayeri and Movshon expt (fMRI version)
%
%         by: ds and ez
%       date: 2015 / february
%       mods: 2018 for DAFNI class
%     inputs: subjectID, stimtype
%
%
%    purpose: event-related motion localiser,
%      
%       e.g.: jazLocalizer('debug=1')


function [  ]=jazLocalizer( varargin )

eval(evalargs(varargin))

% check arguments

if ieNotDefined('stimtype')
  % random walk dots
  stimtype = 0;
  % stimtype = 1: % movshon noise
end

if ieNotDefined('debugflag'), debugflag = 1; end
if ieNotDefined('TR'), TR = 1.5; end

fprintf('debugflag: %s\n', debugflag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

myscreen.screenNumber = 0;
myscreen.autoCloseScreen = 1;
% myscreen.saveData = 1;
myscreen.allowpause = 0;
myscreen.eatKeys = 1;
myscreen.displayname = 'BOLDscreen';
myscreen.background = 'black'; 
% fix the TR here
myscreen.TR = TR; % s


% just for making sure that display looks correct on different machines
% (even if mglScreenParams.mat isn't set up correctly), provide some info
% here 

if debugflag
    % debugging on laptop
    myscreen.screenParams{1} = {gethostname(),[],0,1024,768,231, [83 3*83/4],60,1,1,1.4,[],[0 0]};
    disp(['running on: ' gethostname()])  
else
    % running at 3T for experiment
    defaultMonitorGamma = 1.8;
    myscreen.screenParams{1} = {gethostname(),'',2,1280,960,231,[83 3*83/4],60,1,1,defaultMonitorGamma,'',[0 0]}; % 3T nottingham
end

myscreen = initScreen(myscreen);
myscreen.keyboard.backtick = mglCharToKeycode({'5'}); 
myscreen.keyboard.nums = mglCharToKeycode({'1' '2' '3' '4'    '6' '7' '8' '9' '0'});

global stimulus

% linear dots on the LEFT
stimulus.dotsL.type = 'randomwalk_linear2';
stimulus.dotsL.movshonNoise = stimtype;
stimulus.dotsL.rmin = 0.25; %degrees
stimulus.dotsL.rmax = 6; %degrees
stimulus.dotsL.dotsize = 4; %0.12 deg in diameter (71cm view distance) ?? 4 pixels
stimulus.dotsL.speed = 4;
stimulus.dotsL.density = 150; 
stimulus.dotsL.dir = 0;
stimulus.dotsL.epoch = 2; %each second is divided into 2 epochs
if stimulus.dotsL.epoch ~= 2
    error('feature not implemented')
end

% linear dots on the RIGHT
stimulus.dotsR.type = 'randomwalk_linear2';
stimulus.dotsR.movshonNoise = stimtype;
stimulus.dotsR.rmin = 0.25; %degrees
stimulus.dotsR.rmax = 6; %degrees
stimulus.dotsR.dotsize = 4; %0.12 deg in diameter (71cm view distance) ?? 4 pixels
stimulus.dotsR.speed = 4;
stimulus.dotsR.density = 150; 
stimulus.dotsR.dir = 0;
stimulus.dotsR.epoch = 2; %each second is divided into 2 epochs
if stimulus.dotsR.epoch ~= 2
    error('feature not implemented')
end

% parameters for positioning patches on screen
stimulus.horizontalOffset = 4.63 ./ 2; %from Scolari et al. 2012
stimulus.verticalOffset = 0;%2.73 ./ 2; %from Scolari et al. 2012 

stimulus.fixation.xCoord = 0;
stimulus.fixation.yCoord = 0;

myscreen = initStimulus('stimulus',myscreen);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up baseline task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the first task to be the fixation staircase task
clear global fixStimulus;
global fixStimulus
fixStimulus.fixWidth = 1;
fixStimulus.pos = [0 0];
[task{1} myscreen] = fixStairInitTask(myscreen);

% set our task to have two phases. 
task{2}{1}.waitForBacktick = 1;
task{2}{1}.seglen = 0;
task{2}{1}.numBlocks = 1;
task{2}{1}.parameter.coherence = 0;
task{2}{1}.parameter.direction = 0;
task{2}{1}.private.onsegs = 0;

% task setup starts here

% coherences should be only 1 number for this localizer scan
task{2}{2}.parameter.coherence = 1;
task{2}{2}.parameter.direction = [0:45:315]; 
task{2}{2}.random = 1;

% make event related localizer experiment
task{2}{2}.segmin =      [1 6].*myscreen.TR;  
task{2}{2}.segmax =      [1 12].*myscreen.TR; 
task{2}{2}.segquant =    [1 1].*myscreen.TR;
task{2}{2}.getResponse = [0 0]; % for this task
task{2}{2}.private.onsegs = [1];
task{2}{2}.numTrials = 20; % need to fix this??


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialze tasks and stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimulus = myInitStimulus(stimulus,task,myscreen);

% initialze tasks
for tasknum = 1:length(task{2})
  [task{2}{tasknum} myscreen] = initTask(task{2}{tasknum},myscreen,@startSegmentCallback,@updateScreenCallback, @trialResponseCallback);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run the eye calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% myscreen = eyeCalibDisp(myscreen);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run the tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set which phase is active
tnum = 1;

while (tnum <= length(task{2})) && ~myscreen.userHitEsc
  % updatethe task
  [task{2} myscreen tnum] = updateTask(task{2},myscreen,tnum);
  % display fixation cross
  [task{1} myscreen] = updateTask(task{1},myscreen,1);
  % flip screen
  myscreen = tickScreen(myscreen,task);
end

% if we got here, we are at the end of the experiment
myscreen = endTask(myscreen,task);

% save an entry in the "subjName.txt" summary file for this...
% saveStimFileInfo(myscreen.subject)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     STIMULUS initdots_linear2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stimulus = initdots_linear2(stimulus,myscreen,task)
stimulus.dotsL.n = round(    pi*[(stimulus.dotsL.rmax./2)^2-(stimulus.dotsL.rmin./2)^2].*stimulus.dotsL.density ./ (myscreen.framesPerSecond/stimulus.dotsL.epoch) );  % need to divide by frame type (even / odd?)
stimulus.dotsR.n = round(    pi*[(stimulus.dotsR.rmax./2)^2-(stimulus.dotsR.rmin./2)^2].*stimulus.dotsR.density ./ (myscreen.framesPerSecond/stimulus.dotsR.epoch) );  % need to divide by frame type (even / odd?)

% disp(sprintf('stimulus.dots.n %i, from density: %i per deg^2 per second',stimulus.dotsL.n,stimulus.dotsL.density));


% get max and min points for dots
stimulus.dotsL.xmin = -stimulus.dotsL.rmax - stimulus.horizontalOffset;
stimulus.dotsL.xmax = -stimulus.horizontalOffset;%stimulus.dotsL.rmax ;

stimulus.dotsL.ymin = -stimulus.dotsL.rmax ./2 + stimulus.verticalOffset;
stimulus.dotsL.ymax = stimulus.dotsL.rmax ./2 + stimulus.verticalOffset;

stimulus.dotsR.xmin = stimulus.horizontalOffset + stimulus.dotsR.rmax ;
stimulus.dotsR.xmax = stimulus.dotsR.rmax *2 + stimulus.horizontalOffset;

stimulus.dotsR.ymin = -stimulus.dotsR.rmax ./2 + stimulus.verticalOffset;
stimulus.dotsR.ymax = stimulus.dotsR.rmax ./2 + stimulus.verticalOffset;

% set direction of dots
stimulus.dotsL.dir = stimulus.dotsL.dir;
stimulus.dotsR.dir = stimulus.dotsR.dir;
  
% get initial position
stimulus.dotsL.x = stimulus.dotsL.xmin+rand(1,stimulus.dotsL.n)*2*stimulus.dotsL.rmax;
stimulus.dotsL.y = stimulus.dotsL.ymin+rand(1,stimulus.dotsL.n)*2*stimulus.dotsL.rmax;

stimulus.dotsR.x = stimulus.dotsR.xmin+rand(1,stimulus.dotsR.n)*2*stimulus.dotsR.rmax;
stimulus.dotsR.y = stimulus.dotsR.ymin+rand(1,stimulus.dotsR.n)*2*stimulus.dotsR.rmax;

% get the step size
% make them go in equal and opposite directions +/-
stimulus.dotsL.stepsize = + stimulus.dotsL.speed/(myscreen.framesPerSecond/stimulus.dotsL.epoch);
stimulus.dotsR.stepsize = - stimulus.dotsR.speed/(myscreen.framesPerSecond/stimulus.dotsR.epoch);

stimulus.dotsL.xstep = cos(stimulus.dotsL.dir)*stimulus.dotsL.stepsize;
stimulus.dotsL.ystep = sin(stimulus.dotsL.dir)*stimulus.dotsL.stepsize;

stimulus.dotsR.xstep = cos(stimulus.dotsR.dir)*stimulus.dotsR.stepsize;
stimulus.dotsR.ystep = sin(stimulus.dotsR.dir)*stimulus.dotsR.stepsize;

% create stencil
mglStencilCreateBegin(1);
% get position of first cutout
xposL = -(stimulus.horizontalOffset .* 2); 
yposL = stimulus.fixation.yCoord + (stimulus.verticalOffset .* 2); 
xposR = (stimulus.horizontalOffset .* 2);
yposR = stimulus.fixation.yCoord + (stimulus.verticalOffset .* 2);
% and draw that rmax oval
mglFillOval(xposL,yposL,[stimulus.dotsL.rmax stimulus.dotsL.rmax]);
mglFillOval(xposR,yposR,[stimulus.dotsR.rmax stimulus.dotsR.rmax]);
mglStencilCreateEnd;
mglClearScreen;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step dots randomwalk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stimulus = update_randomwalk_linear2(stimulus,myscreen)

% pick a random set of dots
stimulus.dotsL.nStim = ceil(stimulus.dotsL.n*stimulus.dotsL.coherence);
stimulus.dotsL.nNoise = stimulus.dotsL.n-stimulus.dotsL.nStim;
stimulus.dotsL.logical = [true(1,stimulus.dotsL.nStim),false(1,stimulus.dotsL.nNoise)];
stimulus.dotsL.coherent = stimulus.dotsL.logical(randperm(stimulus.dotsL.n));

stimulus.dotsR.nStim = ceil(stimulus.dotsR.n*stimulus.dotsR.coherence);
stimulus.dotsR.nNoise = stimulus.dotsR.n-stimulus.dotsR.nStim;
stimulus.dotsR.logical = [true(1,stimulus.dotsR.nStim),false(1,stimulus.dotsR.nNoise)];
stimulus.dotsR.coherent = stimulus.dotsR.logical(randperm(stimulus.dotsR.n));

% now move those dots in the right direction
stimulus.dotsL.x(stimulus.dotsL.coherent) = stimulus.dotsL.x(stimulus.dotsL.coherent)+stimulus.dotsL.xstep;
stimulus.dotsL.y(stimulus.dotsL.coherent) = stimulus.dotsL.y(stimulus.dotsL.coherent)+stimulus.dotsL.ystep;

stimulus.dotsR.x(stimulus.dotsR.coherent) = stimulus.dotsR.x(stimulus.dotsR.coherent)+stimulus.dotsR.xstep;
stimulus.dotsR.y(stimulus.dotsR.coherent) = stimulus.dotsR.y(stimulus.dotsR.coherent)+stimulus.dotsR.ystep;

%if stimulus.dots.movshonNoise
  % movshon noise
stimulus.dotsL.x(~stimulus.dotsL.coherent) = stimulus.dotsL.xmin+rand(1,sum(~stimulus.dotsL.coherent))*2*stimulus.dotsL.rmax;
stimulus.dotsL.y(~stimulus.dotsL.coherent) = rand(1,sum(~stimulus.dotsL.coherent))*2*stimulus.dotsL.rmax;

stimulus.dotsR.x(~stimulus.dotsR.coherent) = stimulus.dotsR.xmin+rand(1,sum(~stimulus.dotsR.coherent))*2*stimulus.dotsR.rmax;
stimulus.dotsR.y(~stimulus.dotsR.coherent) = rand(1,sum(~stimulus.dotsR.coherent))*2*stimulus.dotsR.rmax;

% make sure we haven't gone off the patch
stimulus.dotsL.x((stimulus.dotsL.x < stimulus.dotsL.xmin)) = stimulus.dotsL.x((stimulus.dotsL.x < stimulus.dotsL.xmin))+2*stimulus.dotsL.rmax;
stimulus.dotsL.x((stimulus.dotsL.x > stimulus.dotsL.xmax)) = stimulus.dotsL.x((stimulus.dotsL.x > stimulus.dotsL.xmax))-2*stimulus.dotsL.rmax;
stimulus.dotsL.y(stimulus.dotsL.y > stimulus.dotsL.ymax) = stimulus.dotsL.y(stimulus.dotsL.y > stimulus.dotsL.ymax)-2*stimulus.dotsL.rmax;
stimulus.dotsL.y(stimulus.dotsL.y < stimulus.dotsL.ymin) = stimulus.dotsL.y(stimulus.dotsL.y < stimulus.dotsL.ymin)+2*stimulus.dotsL.rmax;

stimulus.dotsR.x((stimulus.dotsR.x < stimulus.dotsR.xmin)) = stimulus.dotsR.x((stimulus.dotsR.x < stimulus.dotsR.xmin))+2*stimulus.dotsR.rmax;
stimulus.dotsR.x((stimulus.dotsR.x > stimulus.dotsR.xmax)) = stimulus.dotsR.x((stimulus.dotsR.x > stimulus.dotsR.xmax))-2*stimulus.dotsR.rmax;
stimulus.dotsR.y(stimulus.dotsR.y > stimulus.dotsR.ymax) = stimulus.dotsR.y(stimulus.dotsR.y > stimulus.dotsR.ymax)-2*stimulus.dotsR.rmax;
stimulus.dotsR.y(stimulus.dotsR.y < stimulus.dotsR.ymin) = stimulus.dotsR.y(stimulus.dotsR.y < stimulus.dotsR.ymin)+2*stimulus.dotsR.rmax;

% draw the dots
mglStencilSelect(1);
mglPoints2(stimulus.dotsL.x,stimulus.dotsL.y,stimulus.dotsL.dotsize,[1 1 1]);
mglPoints2(stimulus.dotsR.x,stimulus.dotsR.y,stimulus.dotsR.dotsize,[1 1 1]);
mglStencilSelect(0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the dots stimuli
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function stimulus = initdots_linear2(stimulus,myscreen,task)
% 
% % convert the passed in parameters to real units
% % if ~isfield(stimulus.dots,'dotsize'), stimulus.dots.dotsize = 3;end
% 
% % get the number of dots
% 
% % area of annulus is pi*(r_o^2-r_i^2)
% % this is density in nDots / deg^2
% % stimulus.dots.n = round(    pi*[stimulus.dots.rmax^2-stimulus.dots.rmin^2].*stimulus.dots.density  );
% % disp(sprintf('stimulus.dots.n %i, from density: %i per deg^2',stimulus.dots.n,stimulus.dots.density));
% 
% % but we need to take into account that Nature paper reports as 
% % nDots / ( deg^2 / s )
% %
% % if we divide by framerate, then the # of dots gets scaled down in such a
% % way that plotting on each frame integrates to the correct number over 1s.
% 
% stimulus.dots.n = round(    pi*[(stimulus.dots.rmax./2)^2-(stimulus.dots.rmin./2)^2].*stimulus.dots.density ./ (myscreen.framesPerSecond) );  % need to divide by frame type (even / odd?)
% disp(sprintf('stimulus.dots.n %i, from density: %i per deg^2 per second',stimulus.dots.n,stimulus.dots.density));
% 
% 
% % get max and min points for dots
% stimulus.dots.xmin = -stimulus.dots.rmax .*2 - stimulus.horizontalOffset;
% stimulus.dots.xmax = stimulus.dots.rmax .*2 + stimulus.horizontalOffset;
% 
% stimulus.dots.ymin = -stimulus.dots.rmax .*2 + stimulus.verticalOffset;
% stimulus.dots.ymax = stimulus.dots.rmax .*2 + stimulus.verticalOffset;
% 
% % set direction of dots
% stimulus.dots.dir = stimulus.dots.dir;
%   
% % get initial position
% stimulus.dots.x = stimulus.dots.xmin+rand(1,stimulus.dots.n)*2*stimulus.dots.rmax;
% stimulus.dots.y = stimulus.dots.ymin+rand(1,stimulus.dots.n)*2*stimulus.dots.rmax;
% 
% % get the step size
% stimulus.dots.stepsize = stimulus.dots.speed/(myscreen.framesPerSecond);
% stimulus.dots.xstep = cos(stimulus.dots.dir)*stimulus.dots.stepsize;
% stimulus.dots.ystep = sin(stimulus.dots.dir)*stimulus.dots.stepsize;
% 
% % % create stencil
% % mglStencilCreateBegin(1);
% % % get position of first cutout
% % xpos = 0;
% % ypos = 0;
% % % and draw that rmax oval
% % mglFillOval(xpos,ypos,[stimulus.dots.rmax stimulus.dots.rmax]);
% % mglStencilCreateEnd;
% % mglClearScreen;
% 
% % create stencil
% mglStencilCreateBegin(1);
% % get position of first cutout
% xposL = -(stimulus.horizontalOffset .* 2); 
% yposL = stimulus.fixation.yCoord + (stimulus.verticalOffset .* 2); 
% xposR = (stimulus.horizontalOffset .* 2);
% yposR = stimulus.fixation.yCoord + (stimulus.verticalOffset .* 2);
% % and draw that rmax oval
% mglFillOval(xposL,yposL,[stimulus.dots.rmax stimulus.dots.rmax]);
% mglFillOval(xposR,yposR,[stimulus.dots.rmax stimulus.dots.rmax]);
% mglStencilCreateEnd;
% mglClearScreen;
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % step dots randomwalk
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function stimulus = update_randomwalk_linear2(stimulus,myscreen)
% 
% % pick a random set of dots
% stimulus.dots.nStim = ceil(stimulus.dots.n*stimulus.dots.coherence);
% stimulus.dots.nNoise = stimulus.dots.n-stimulus.dots.nStim;
% stimulus.dots.logical = [true(1,stimulus.dots.nStim),false(1,stimulus.dots.nNoise)];
% stimulus.dots.coherent = stimulus.dots.logical(randperm(stimulus.dots.n));
% 
% % now move those dots in the right direction
% stimulus.dots.x(stimulus.dots.coherent) = stimulus.dots.x(stimulus.dots.coherent)+stimulus.dots.xstep;
% stimulus.dots.y(stimulus.dots.coherent) = stimulus.dots.y(stimulus.dots.coherent)+stimulus.dots.ystep;
% 
% %if stimulus.dots.movshonNoise
%   % movshon noise
%  stimulus.dots.x(~stimulus.dots.coherent) = stimulus.dots.xmin+rand(1,sum(~stimulus.dots.coherent))*2*stimulus.dots.rmax;
%  stimulus.dots.y(~stimulus.dots.coherent) = rand(1,sum(~stimulus.dots.coherent))*2*stimulus.dots.rmax;
% 
% % make sure we haven't gone off the patch
% stimulus.dots.x((stimulus.dots.x < stimulus.dots.xmin)) = stimulus.dots.x((stimulus.dots.x < stimulus.dots.xmin))+2*stimulus.dots.rmax;
% stimulus.dots.x((stimulus.dots.x > stimulus.dots.xmax)) = stimulus.dots.x((stimulus.dots.x > stimulus.dots.xmax))-2*stimulus.dots.rmax;
% stimulus.dots.y(stimulus.dots.y > stimulus.dots.ymax) = stimulus.dots.y(stimulus.dots.y > stimulus.dots.ymax)-2*stimulus.dots.rmax;
% stimulus.dots.y(stimulus.dots.y < stimulus.dots.ymin) = stimulus.dots.y(stimulus.dots.y < stimulus.dots.ymin)+2*stimulus.dots.rmax;
% 
% % draw the dots
% mglStencilSelect(1);
% mglPoints2(stimulus.dots.x,stimulus.dots.y,stimulus.dots.dotsize,[1 1 1]);
% mglStencilSelect(0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to set stimulus parameters at
% the beginning of each segment for the fMRI experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [task myscreen] = startSegmentCallback(task,myscreen)

global stimulus;

% set the stimulus parameters


% set the coherence (0 for segments that are NOT ON) / for segment 1 only
if any(task.thistrial.thisseg == task.private.onsegs)
%     set coherence and direction when segs have stimuli
  stimulus.linevisible = 0;
  stimulus.dotsvisible = 1;
  stimulus.dotsL.coherence = task.thistrial.coherence;
  stimulus.dotsR.coherence = task.thistrial.coherence;
  stimulus.boundary.dir = task.thistrial.direction;
  stimulus.dotsL.dir = d2r(task.thistrial.direction);
  stimulus.dotsR.dir = d2r(task.thistrial.direction);
%   stimulus.fixation.color = [1 1 1]; 
  
else % segement 2
%     no stimuli on screen
  stimulus.dotsL.coherence = 0;
  stimulus.dotsR.coherence = 0;
  stimulus.dotsR.dir = 0;
  stimulus.dotsL.dir = 0;
  stimulus.boundary.dir = 0;
  stimulus.linevisible = 0;
  stimulus.dotsvisible = 0;
%   stimulus.fixation.color = [1 1 0]; 
end

% get the step size
% get the step size
stimulus.dotsL.xstep = cos(stimulus.dotsL.dir)*stimulus.dotsL.stepsize;
stimulus.dotsL.ystep = sin(stimulus.dotsL.dir)*stimulus.dotsL.stepsize;

stimulus.dotsR.xstep = cos(stimulus.dotsR.dir)*stimulus.dotsR.stepsize;
stimulus.dotsR.ystep = sin(stimulus.dotsR.dir)*stimulus.dotsR.stepsize;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to display stimulus - gets called to draw stimuli each frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [task myscreen] = updateScreenCallback(task,myscreen)

global stimulus;
global fixStimulus;
mglClearScreen;


if stimulus.dotsvisible ==1  % && iseven(myscreen.tick)
%     fprintf('frame number %d\n', myscreen.tick)
    stimulus = update_randomwalk_linear2(stimulus,myscreen); 
end


mglFillOval(fixStimulus.pos(1),fixStimulus.pos(2),[1 1]*stimulus.dotsL.rmin, [0 0 0]);

% mglGluDisk(stimulus.fixation.xCoord,stimulus.fixation.yCoord,d2r(5), stimulus.fixation.color);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [stimulus task myscreen] = myInitStimulus(stimulus,task,myscreen)

% disp('using _random walk_ linear 2 dots...')
stimulus = initdots_linear2(stimulus, myscreen, task);
stimulus.updateFunction = @update_randomwalk_linear2;
disp('ran myInitStimulus')
% disp('using _random walk_ linear 2 dots...')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [task myscreen] = trialResponseCallback(task,myscreen)

% global stimulus;
% 
% % mouse button pressed can't be dealt with here...
% 
% if  (task.thistrial.deltaDir <= 0) && (task.thistrial.whichButton == 2)
%     response = 1;
% elseif (task.thistrial.deltaDir >= 0) && (task.thistrial.whichButton == 1)
%     response = 1;
% else
%     response = 0;
% end
% if (task.thistrial.RandTrial > 0.3*task.numTrials)
%     if response == 1
%         stimulus.fixation.color = [0 1 0];
%     else
%         stimulus.fixation.color = [1 0 0];
%     end
% else
%     stimulus.fixation.color = [1 1 1];
% end