function STCdata = MW_stcAddSample(STCdata,varargin)
% function STCdata = MW_stcAddSample(STCdata,varargin)
%
% This function...
%
% Required INPUT:
%   value    - 
%
% Optional INPUT:
%   trialNum - 
%
%
% Things to do:
%   Documentation!
%
%
% rbrockhausen@dpz.eu, 2015-07-16

ndatapoints = length(STCdata.trialNum);
tempTrialNum = ndatapoints+1;
tempValue = []
% parse inputs and add to correct field:

for in = 1:(length(varargin)/2)
    switch varargin{2*(in-1)+1}
        case 'trialNum'
            tempTrialNum = varargin{2*in};
        case 'value'
            tempValue = varargin{2*in};
        otherwise
            disp(['MW_stcAddSample: WARNING: Unknown input argument ' varargin{2*(in-1)+1} ' !']);
    end
end

if ~isempty(tempValue)
    STCdata.yValue(ndatapoints+1) = tempValue;
    STCdata.trialNum(ndatapoints+1) = tempTrialNum;
    
    % Threshold berechnen
    tempMark = 0;
    if (ndatapoints > 0)
        if (STCdata.yValue(ndatapoints) < tempValue) && (STCdata.currentDirection ~= -1)
            if STCdata.currentDirection ~= 0
                tempMark = 1;
            end
            STCdata.currentDirection = -1;
        elseif (STCdata.yValue(ndatapoints) > tempValue) && (STCdata.currentDirection ~= 1)
            if STCdata.currentDirection ~= 0
                tempMark = 1;
            end
            STCdata.currentDirection = 1;
        end
        if tempMark
            STCdata.turningPoints(length(STCdata.turningPoints)+1) = STCdata.yValue(ndatapoints);
            STCdata.threshold(length(STCdata.threshold)+1) = mean(STCdata.turningPoints);
            STCdata.turningPointsX(length(STCdata.turningPointsX)+1) = tempTrialNum-1;
        end 
    end    
else
    disp(['MW_stcAddSample: WARNING: no input value @ trialNum ' num2str(tempTrialNum)])
end
