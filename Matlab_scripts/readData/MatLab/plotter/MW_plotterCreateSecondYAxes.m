function axeshandleOUT = MW_plotterCreateSecondYAxes(axeshandleIN,backgroundAxesIndex)
% function axeshandleOUT = MW_plotterCreateSecondYAxes(axeshandlesIN,backgroundAxesIndex)
%
% This function creates a second axes object at the same position as the
% first, and links both x axes. The yaxis label will be plotted on the
% right of the axes.
% 
% Input: AXESHANDLEIN is a graphics handle to an existing axes;
%        optional BACKGROUNDAXESINDEX specifies which axes has white
%        background, i.e. will be drawn at the bottom of the UI stack.
%        default is 2 (right axes), used e.g. in PSF plotting.
% Output: AXESHANDLEOUT is a graphics handle to the newly created axes
%
% cquigley@dpz.eu, Nov 2013. Status: finished, tested by Janina

% check that axeshandle is valid:
if ~ishghandle(axeshandleIN)
    disp('The input axes handle is invalid');
    disp('Cannot prepare axes, terminating.');
    return
end

if nargin<2
    backgroundAxesIndex = 2;
end

% create second axes with same position as input
axeshandleOUT = axes('Position',get(axeshandleIN,'Position'),'YAxisLocation','right');

% link the x-axis of both axes so that they always span the same limits
linkaxes([axeshandleIN axeshandleOUT],'x');
% delete the ticks on the new x axis:
set(axeshandleOUT,'XTickLabel',[],'XTick',[]);

% Now we might have to adjust the backgrounds: 
% By default the left axis (axes(1)) has a white background and the right
% axis (axes(2)) has a transparent background.
if backgroundAxesIndex == 2;
    % reorder so that right-hand axes is plotted at the bottom
    uistack(axeshandleOUT,'bottom');
    set(axeshandleIN, 'Color', 'none');
    set(axeshandleOUT, 'Color', 'w');
else
    uistack(axeshandleIN,'bottom');
    set(axeshandleOUT, 'Color', 'none');
    set(axeshandleIN, 'Color', 'w');
end