function [  ] = interact( fignum )
%interact - demonstrate how to link up button press
%
%      usage: [  ] = interact( [fignum] )
%         by: lpzds1
%       date: Oct 09, 2013
%        $Id$
%     inputs: [fignum] - optional figure number
%    outputs:
%
%    purpose: simple m-file that shows the plumbing 
%             hooks up keypress such that 
%               - the space-bar changes color
%               - q quits
%               - every other key juts spits out some text
%
%        e.g: interact(1)
%             interact()


% check input arguments, make a figure and keep the "handle"
if nargin < 1
    h = figure(); % call figure like this, then matlab makes a new window
else
    h = figure(fignum); % provide a number
end

% display some info for the user
disp('making a figure window')


% to access (read) all properties of h
get(h)
% or only specifics
figurePosition = get(h, 'position')

% to change some property use 'set'
% e.g. the background color of the window is controlled by:
set(h,'color',[0   0   0])

% hook up a key press function
% the '@' symbol means that "keypress" is expected to be a function
% now every time a key is pressed when this window is active,
% the functon 'keypress' gets called
set(h, 'WindowKeyPressFcn', @keypress);

end


function keypress(h, evnt)
% the function takes two inputs and runs specific code depending
% on which button was pressed
%
% -- the HANDLE to the figure
% -- and specifics about what happened

disp(h)
disp(evnt)

% now you can do specific things according to which button was pressed
% convert the field "Key" to lower case and choose what to do
% 
% could use IF statements, but the SWITCH/CASE version is neater

  switch lower(evnt.Key)
    case {'space'}
        disp('space bar : change color')
        set(h,'color', rand(1,3));
    case {'q','escape'}
        disp('quit')
        close(h); % close the window 
        return;   % and return; nothing else to do, so this means we're done
    case {'up'}
        disp('--up--')
    otherwise
        disp('-- some other key')
  end



end