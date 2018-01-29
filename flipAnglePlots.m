% flipAnglePlots - show optimal flip angle for GE=EPI at 3T
%
% [flipangles] = flipAnglePlots(TR, T1)
%
% calculates the flipangles according to:  
%
%       acos(exp(-TR/T1))*180/pi 
%
% The input argument TR (in ms, 250<x<3000) can be a vector 
% of TRs that will be overplotted as red dots on the graph. 
% If no T1 given, it is now assumed to be 1300ms. 
%
% ds - updated nov-29-2004, default T1 changed to 1300ms
function [flipangles] = flipAnglePlots(TR, T1)


% the measured T1 at NYU-CBI is ~1000 
% the reported value for T1 in the literature is ~1300
if nargin < 2
    T1 = 1300;
end

% TRs in ms.
if nargin < 1
    TR = [500 1000 1250 1500 2000 2500 3000];
end

% flipangles
flipangles = calculateFlipAngle(TR, T1);

% give a range of TRs for the curve
x0 = 250;
fineTR = x0:50:3000;
fineFA = calculateFlipAngle(fineTR, T1);

plot(fineTR, fineFA, 'color', 'k', 'linewidth',2);

hold on
p_ = plot(TR, flipangles, 'ro');
set(p_, 'markerfacecolor','r')
hold off


% set(gca,'xtick',TR,'ytick',[flipangles], 'yticklabel', num2str([flipangles],'%2.2f'));
% use newer matlab functions
xticks(TR);
yticks(round(flipangles,1));  % not much point in going beyond 1 decimal point

axis([x0 3000 0.9*min(flipangles) 90]);
xlabel('TR [ms]')
ylabel('flipangle (deg)')

xline = [zeros(size(TR)); TR];
yline = [flipangles; flipangles];

xline2 = [TR; TR];
yline2 = [zeros(size(flipangles)); flipangles];


l_ = line(xline, yline);
l2_ = line(xline2, yline2);
set([l_, l2_],'color',[1 1 1]*0.5);

title(['optimal flipangle vs TR; [T1=' num2str(T1) ']'] )

% print them out:
disp(sprintf('\n\nTR\tflip angle\n'))
disp(sprintf('%2.0f\t%d\n',[TR; round(flipangles)]))

end

% calculateFlipAngle - optimal flip angle from Ernst equation
%
% 	calculates the optimal flipangle for EPI. Inputs can be vectors. The
% 	equation for the optimal flip angle is 
% 	
%               acos(exp(-TR/T1))*180/pi 
% 	
% 	where TR is the (R)epitition time, and T1 the measured gray matter T1.
% 	In June 2003, the measure T1 at the NYU-CBI was around 1000. 
% 	
% 	This function based on a lab note from miki@cns.nyu.edu
% 	
%   e.g.:   TR = [500, 1000, 1500]; T1 = 1300
%           flipangles = calculateFlipAngle(TR, T1)
%
%   see: https://mriquestions.com/optimal-flip-angle.html
%  
% 	2006-03-25 ds written
function flipangles = calculateFlipAngle(TR, T1)

% if wanting to calculate for many values... 
[allTR, allT1] = meshgrid(TR, T1);

% now calculate flipangles
flipangles = acos(exp(-allTR./allT1))*180/pi; 

end