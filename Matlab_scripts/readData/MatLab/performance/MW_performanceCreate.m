function PERFdata = MW_performanceCreate(axesHandle, varargin)
% function PERFdata = MW_performanceCreate(axesHandle, varargin)
%
% Create a performance analysis "plugIn". Optional paramter are:
%   'interval'
%       Description will follow...
%

PERFdata.debug = false;
PERFdata.outcomeDef = {};
PERFdata.colorDef = {};
PERFdata.trialTypeDef = {};
PERFdata.rawData = [];
PERFdata.interval = [];
PERFdata.intervalTime = [];
PERFdata.intervalCX = 0;
PERFdata.axesHandleRightY = [];

for i = 1 : size(varargin,2)/2 			
    switch varargin{2*(i-1)+1}
%         case 'ttNames'						% in the calling function this should reflect the variable TRIAL_outcome
%             if (~isempty(varargin{i*2}))
%                 PERFdata.ttNames = varargin{i*2};
%             end
        case 'outcomes'
            if (~isempty(varargin{i*2}))
                PERFdata.outcomeDef = varargin{i*2};
                %disp(PERFdata.outcomeDef)
            else
                fprintf('MW_performanceCreate: No outcomes are defined!\n');
            end
        case 'color'
            if (~isempty(varargin{i*2}))
                PERFdata.colorDef = varargin{i*2};
                %disp(PERFdata.colorDef)
            else
                fprintf('MW_performanceCreate: No colors are defined!\n');
            end
        case 'trialType'
            if (~isempty(varargin{i*2}))
                PERFdata.trialTypeDef = varargin{i*2};
                %disp(PERFdata.trialTypeDef)
            else
                fprintf('MW_performanceCreate: No trial types are defined!\n');
            end
        case 'interval'
            if (~isempty(varargin{i*2}))
                PERFdata.interval = varargin{i*2};
            end
        otherwise
            disp('MW_performanceCreate: WARNING: Unknown input argument!\n');
    end
end


PERFdata.figHandle = axesHandle;	% will contain the handle ID for the subplot

propertylist.Title = 'Performance';
propertylist.YLabel = 'Number of Trials';
PERFdata.axesHandle = axesHandle;

success = MW_plotterPrepareAxes(axesHandle,propertylist);

% Prepeare the data structure
PERFdata.outcomeDef{size(PERFdata.outcomeDef,2)+1} = 'unknown';
PERFdata.cxMatrix = zeros(size(PERFdata.trialTypeDef,2), size(PERFdata.outcomeDef,2));

PERFdata.dummy = 1;



PERFdata.outXAxis = PERFdata.trialTypeDef;
    
    
end
   
