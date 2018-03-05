function [  ] = countup(n)
%countup - demo for showing how to execute timed events (e.g. movies)
%
%      usage: [  ] = countup(  )
%         by: lpzds1
%       date: Oct 09, 2013
%        $Id$
%     inputs: [ n ] times a function will execute (default 10)
%    outputs: 
%
%    purpose: example code for making a simple timer object that executes a
%    function every second. Could be used to animate slices. 
%
%        e.g: countup(10)

if nargin < 1
    n = 10; % default number of times function will run
end

% construct a timer object
% doc timer 
% for more help

t = timer(  'TimerFcn',@mycallback, ...
            'TasksToExecute', n, ...
            'ExecutionMode','fixedRate', ...
            'Period', 1.0,...
            'StartFcn', @startTimerFcn, ...
            'StopFcn', @stopTimerFcn, ...
            'UserData', rand(1,3));  % a row vector of length 3 
        
        
% and start it 
start(t)

end
  
function mycallback(h,~)
% gets called every time the timer "ticks"
handleCount = get(h, 'TasksExecuted');
disp(['option 1: h.TaskExecuted = ' num2str(handleCount)])

% option 1 - get info about timer from h (via the handle)

% option 2 - count locally, but make sure to keep numbers around!
% you can make the values in a variable STICKY 
% (usually help it doesn't get reset
persistent localCount % empty matrix the first time function runs

if isempty(localCount)
    % then it was the first run of the function
    localCount = 0;
end

% increase and display
localCount = localCount + 1;
disp(['option 2: ran ' num2str(localCount) ])

end

function startTimerFcn(h,evnt,string_arg)
disp('+ started the timer')
end

function stopTimerFcn(h,evnt,string_arg)
disp('-stopped the timer')
end



