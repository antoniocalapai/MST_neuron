 function ghandles = MW_nonlinearOptPlot(STCdata,refreshPlot,optionalProperties)
% STCdata = MW_stcPlot_CQ(STCdata,refreshPlot,optionalProperties)
%
% this function plots a staircase data structure. REFRESHPLOT specifies
% whether the axes should be cleared before plotting (default: 0). the user
% can give their own specification of graphics properties in the
% OPTIONALPROPERTIES input structure. 

% default plot properties. these must be defined separately for each call
% to MW_plotterPlot
% defaultProperties.POINT.LineStyle = 'none';
% defaultProperties.POINT.Marker = '.';
% defaultProperties.POINT.MarkerEdgeColor = 'k';
% defaultProperties.POINT.MarkerSize = 10;

defaultProperties.STAIR.LineStyle = '-';
defaultProperties.STAIR.Color = 'k';
defaultProperties.STAIR.Marker = 'none';

if nargin>2
    % parse optional graphics properties input, replacing defaults if necessary
    properties = MW_plotterPropertyParser(defaultProperties,optionalProperties);
else
    properties = defaultProperties;
end
if ~exist('refreshPlot','var')
    refreshPlot = 0;
end
'STCdata.trialNum'
STCdata.trialNum
'STCdata.yValue'
STCdata.yValue
% if user requested axes to be cleared, do it in the first plotting step
% core call to plotter function. final input indicates whether graphics should be cleared before plotting:
% ghandles.POINT = MW_plotterPlot(STCdata.axesHandle,STCdata.trialNum,STCdata.yValue,'point',properties.POINT,refreshPlot); % first plot the points

for i = 1:size(STCdata.yValue, 1)
ghandles.STAIR = MW_plotterPlot(STCdata.axesHandle,STCdata.trialNum,STCdata.yValue(i,:),'stair',properties.STAIR,0); % then plot the staircase lines
end