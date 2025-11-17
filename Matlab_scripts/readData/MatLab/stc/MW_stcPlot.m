 function ghandles = MW_stcPlot(STCdata, refreshPlot, optionalProperties)
% STCdata = MW_stcPlot_CQ(STCdata, refreshPlot, optionalProperties)
%
% This function plots a staircase data structure. REFRESHPLOT specifies
% whether the axes should be cleared before plotting (default: 0). The user
% can give their own specification of graphics properties in the
% OPTIONALPROPERTIES input structure. 
%
% Default plot properties. These must be defined separately for each call
% to MW_plotterPlot
%
% The threshold/turningpoints are invisible py default. To show both set
% optionalProperties.TURNINGPOINTS.Marker = 'x' and
% optionalProperties.THRESHOLD.LineStyle = '-' (or to values you want)
%
% To print the threshold in the plot use
% optionalProperties.TEXT.Color = 'k'
% optionalProperties.TEXT.yPosition = yPosition
%
%
% cquigley@dpz.eu, rbrockhausen@dpz.eu, 2015-07-16

defaultProperties.POINT.LineStyle = 'none';
defaultProperties.POINT.Marker = '.';
defaultProperties.POINT.MarkerEdgeColor = 'k';
defaultProperties.POINT.MarkerSize = 10;

defaultProperties.STAIR.LineStyle = '-';
defaultProperties.STAIR.Color = 'k';
defaultProperties.STAIR.Marker = 'none';

defaultProperties.THRESHOLD.LineStyle = 'none';
defaultProperties.THRESHOLD.Color = 'r';
defaultProperties.THRESHOLD.Marker = 'none';

defaultProperties.TURNINGPOINTS.LineStyle = 'none';
defaultProperties.TURNINGPOINTS.Color = 'k';
defaultProperties.TURNINGPOINTS.Marker = 'none';

defaultProperties.TEXT.Color = 'none';
defaultProperties.TEXT.FontUnits = 'Normalized';
defaultProperties.TEXT.FontSize = 0.06;
defaultProperties.TEXT.VerticalAlignment = 'middle';
defaultProperties.TEXT.HorizontalAlignment = 'right';
defaultProperties.TEXT.yPosition = 0;

if nargin>2
    % parse optional graphics properties input, replacing defaults if necessary
    properties = MW_plotterPropertyParser(defaultProperties,optionalProperties);
else
    properties = defaultProperties;
end
if ~exist('refreshPlot','var')
    refreshPlot = 0;
end

% if user requested axes to be cleared, do it in the first plotting step
% core call to plotter function. final input indicates whether graphics should be cleared before plotting:
if ~isempty(STCdata.threshold)
    ghandles.THRESHOLD = MW_plotterPlot(STCdata.axesHandle,STCdata.turningPointsX,STCdata.threshold,'line',properties.THRESHOLD,refreshPlot); % then plot the staircase lines
    ghandles.THRESHOLD = MW_plotterPlot(STCdata.axesHandle,STCdata.turningPointsX,STCdata.threshold,'point',properties.TURNINGPOINTS,0); % then plot the staircase lines

    ghandles.POINT = MW_plotterPlot(STCdata.axesHandle,STCdata.trialNum,STCdata.yValue,'point',properties.POINT,0); % first plot the points
    ghandles.STAIR = MW_plotterPlot(STCdata.axesHandle,STCdata.trialNum,STCdata.yValue,'stair',properties.STAIR,0); % then plot the staircase lines

    tempXLim = get(STCdata.axesHandle, 'XLim');
    tempYPos = properties.TEXT.yPosition;
    properties.TEXT = rmfield(properties.TEXT, 'yPosition');
    ghandles.TEXT = MW_plotterWriteText(STCdata.axesHandle,{['THRESHOLD: ' num2str(mean(STCdata.turningPoints))]},tempXLim(2)-1,tempYPos,properties.TEXT,0);
else
    ghandles.POINT = MW_plotterPlot(STCdata.axesHandle,STCdata.trialNum,STCdata.yValue,'point',properties.POINT,refreshPlot); % first plot the points
    ghandles.STAIR = MW_plotterPlot(STCdata.axesHandle,STCdata.trialNum,STCdata.yValue,'stair',properties.STAIR,0); % then plot the staircase lines
end