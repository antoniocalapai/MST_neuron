%%  Function -- MW_psfCreate(axesHandle,varargin) --
%
%
%   This function creates the structure of your PSF data and sets some
%   basic parameters of your plot.
%
%
%   The following example shows how you can use it:
%
%   PSFdata = MW_psfCreate(axesHandle,'Title','Psychometric function', 'fixXLim', [-30 30], ...
%           'XLabel','Direction [deg]','YLabel','Performance [%]');
%
%
%   axesHandle is the only essential input and you get it by using the
%   function MW_plotterCreateFigure (for further details have a look into the function): 
%
%   'axesHandle = MW_plotterCreateFigure(...)' 
%   
%
%   You can specify the title and labeling of the x-, y- and z-axis of
%   your plot ('XLabel', 'YLabel', 'ZLabel') and the limits of the x-axis
%   ('fixXLim') as demonstrated in the example.
%
%
%
%
%   This function creates the following parameters:
%
%
%   -- PSFdata.xAxis
%
%   -- PSFdata.answers
%
%   -- PSFdata.samples
%
%   -- PSFdata.percentageTrue
%
%   -- PSFdata.fittedValuesX
%
%   -- PSFdata.fittedValuesY
%
%   -- PSFdata.pse
%
%   -- PSFdata.slope
%
%   -- PSFdata.goodnessOfFit
%
%   -- PSFdata.slopeCalculated
%
%   -- PSFdata.calculates
%
%   -- PSFdata.fitted
%
%   -- PSFdata.plotted
%
%   -- PSFdata.axesHandle
%
%   -- PSFdata.nSamplesAddedSinceCalculated
%
%   -- PSFdata.nSamplesAddedSinceGoF
%
%   -- PSFdata.paramsValues
%
%   -- PSFdata.fixXLim
%
%   -- PSFdata.xLim
%

% 'Color','none'

%% ----------------------------------------------------------------------------------------------------

function PSFdata = MW_psfCreate(axesHandle,varargin)

% PSFdata variables 
% PSFdata = struct('xAxis', [], 'answers', [], 'samples', [], 'percentageTrue', [], 'fittedValuesX', [], 'fittedValuesY', [],  ...
%         'pse', 0, 'slope', 0, 'goodnessOfFit', 0, 'slopeCalculated', false, 'calculated', true, 'fitted', false, 'plotted', ...
%         true,'axesHandle', axesHandle,'nSamplesAddedSinceCalculate',0, 'paramsValues', [], 'logLikelihood', [], 'output', [], ...
%         'dev', [], 'DevSim', [], 'goodnessOfFit_converged', [], 'SD', [], 'paramsSim', [], 'LLSim', [], 'bootstrap_converged', [], ...
%         'fixXLim',[], 'xLim',[]); 
    
PSFdata = struct('xAxis', [], 'answers', [], 'samples', [], 'percentageTrue', [], 'fittedValuesX', [], 'fittedValuesY', [],  ...
        'pse', 0, 'slope', 0, 'goodnessOfFit', [], 'slopeCalculated', false, 'calculated', true, 'fitted', false, 'plotted', ...
        true,'axesHandle', axesHandle, 'nSamplesAddedSinceCalculate',0, 'nSamplesAddedSinceGoF',0,'paramsValues', [], 'fixXLim',[], 'xLim',[]); 

% default values for plot    
propertylist.XLabel = 'Stimulus value';
propertylist.YLabel = 'Performance';
%propertylist.Box = 'off';               % CQ 140310: trying to get rid of redundant tickmarks on y axis. JH 140311: does not work. I put it into psfPlot.

% check if user specified any of the plot values 
if nargin>1
    pl = varargin;
    for p = 1:2:length(pl)
        if strcmpi(pl{p},'fixXLim')
            PSFdata.fixXLim=pl{p+1};   
        else
            propertylist.(pl{p}) = pl{p+1};
        end
    end

end

% prepare axes
success = MW_plotterPrepareAxes(axesHandle,propertylist);

PSFdata.axesHandleRightY = MW_plotterCreateSecondYAxes(axesHandle);

propertylistRight.YLabel = 'Repetitions';
%propertylistRight.Box = 'off';               % CQ 140310: trying to get
%rid of redundant tickmarks on y axis. JH 140311: does not work. I put it into psfPlot.

success2 = MW_plotterPrepareAxes(PSFdata.axesHandleRightY,propertylistRight);

end