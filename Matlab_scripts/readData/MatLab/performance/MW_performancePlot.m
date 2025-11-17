function PERFdata = MW_perfPlot(PERFdata, refreshPlot, varargin)
% function PERFdata = MW_perfPlot(PERFdata, refreshPlot, varargin)
%
% This function create & update the performancePlot.
%
% Possible parameter:
%
%
%
% acalapai@gwdg.de & rbrockhausen@dpz.eu, May 2014




defaultProperties.BAR.EdgeColor = [0 0 0];
%defaultProperties.TEXT.Units = 'Normalized';
%defaultProperties.TEXT.FontUnits = 'Normalized';
%defaultProperties.TEXT.FontSize = 0.06;
% defaultProperties.TEXT.VerticalAlignment = 'middle';
% defaultProperties.TEXT.HorizontalAlignment = 'right';

if nargin > 2
    properties = MW_plotterPropertyParser(defaultProperties, optionalProperties);
else
    properties = defaultProperties;
end

% default value for refreshPlot @CLIO: Why is it set here AND in plotterPlot?
if ~exist('refreshPlot','var')
    refreshPlot = 0;
end


set(PERFdata.axesHandle, 'FontUnits', 'Normalized');
set(PERFdata.axesHandle, 'FontSize', 0.06);


graphicsHandle_BAR = MW_plotterPlot(PERFdata.axesHandle, [1:size(PERFdata.cxMatrix,1)], PERFdata.cxMatrix, 'stacked', properties.BAR, refreshPlot);%refreshPlot

set(PERFdata.axesHandle, 'XTick', 1:length(PERFdata.plotOutXAxis));
set(PERFdata.axesHandle, 'XTicklabel', PERFdata.plotOutXAxis);

colormap(PERFdata.axesHandle, PERFdata.colorDef)
%disp(PERFdata.outPercMatrix);

% if isempty(PERFdata.axesHandleRightY)&& ~isempty(PERFdata.outPercMatrix)
%     PERFdata.axesHandleRightY = MW_plotterCreateSecondYAxes(PERFdata.axesHandle);
%     propertylistRight.YTick = 1:100;
%     success2 = MW_plotterPrepareAxes(PERFdata.axesHandleRightY,propertylistRight);
% end
 
if ~isempty(PERFdata.outPercMatrix)
    set(PERFdata.axesHandleRightY,'Position',get(PERFdata.axesHandle,'Position'));
    set(PERFdata.axesHandleRightY, 'ylim', [0,100]);
    set(PERFdata.axesHandleRightY, 'ytick', [0,25,50,75,100]);
    set(PERFdata.axesHandleRightY, 'xlim', [0.5 length(PERFdata.plotOutXAxis)+0.5]);
    set(PERFdata.axesHandleRightY, 'FontUnits', 'Normalized');
    set(PERFdata.axesHandleRightY, 'FontSize', 0.06);
    colormap(PERFdata.axesHandleRightY, PERFdata.colorDef);
    graphicsHandle_BAR = MW_plotterPlot(PERFdata.axesHandleRightY, [1:size(PERFdata.outPercMatrix,1)], PERFdata.outPercMatrix, 'stacked', properties.BAR, refreshPlot);
end


end
