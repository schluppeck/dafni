function [ tInS ] = extractEventTimes(stimfile, tasknum, phasenum, TR)
%extractEventTimes - get information out of stim files
%
%      usage: [ tInS ] = extractEventTimes( stimfile )
%         by: lpzds1, Denis Schluppeck
%       date: Feb 07, 2018
%     inputs: stimfile [tasknum], [phasenum], [TR / for duration]
%    outputs: tInS (in FSL / feat 3 column format)
%
%    purpose: unpack information out of stimfiles for DAFNI analysis
%
%        e.g: 
%             t =  extractEventTimes('180207_stim04.mat')
%             dlmwrite('times.dlm', t, 'delimiter', '\t')

if ieNotDefined('tasknum') tasknum=2; end
if ieNotDefined('phasenum') phasenum=2; end
if ieNotDefined('TR') TR = 1.5; end

try
    load(stimfile);
    e = getTaskParameters(myscreen, task);
catch
    fprintf(' there is a problem w/ file: %s', stimfile)
    return
end

t = [ e{tasknum}(phasenum).trialTime ];

% FSL/feat expects in 3-column format: time, duration, level
% hard code 1TR = 1.5s
tInS = [t(:), ones(numel(t),1)* [TR 1] ];

end