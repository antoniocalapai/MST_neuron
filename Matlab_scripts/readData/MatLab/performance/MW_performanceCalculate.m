function PERFdata = MW_performanceCalculate(PERFdata, varargin)
% Version 1 by : acalapai@gwdg.de 20131018 CNL
% This function extracts every possible outcome and calculate its proportion to the total amount of trials 

% for ttCx = 1:length(PERFdata.ttNames)
%     for i=1:size(PERFdata.outcome,2)
%         PERFdata.outcomePercentage(ttCx,i) = (PERFdata.outcome(ttCx,i)./sum(PERFdata.outcome(ttCx,:)))*100;
%     end
% end


PERFdata.lastTrials = 0;


for i = 1 : size(varargin,2)/2 			
    switch varargin{2*(i-1)+1}
        case 'lastTrials'						
            if (~isempty(varargin{i*2}))
                PERFdata.lastTrials = varargin{i*2};
            end
        otherwise
            disp('MW_performanceCreate: WARNING: Unknown input argument!\n');
    end
end



% ----- Create OutMatrix und xAxis names -----
PERFdata.outMatrix = PERFdata.cxMatrix;
PERFdata.plotOutXAxis = PERFdata.outXAxis;
PERFdata.outPercMatrix = zeros(size(PERFdata.cxMatrix,1)+2,size(PERFdata.cxMatrix,2));
if PERFdata.debug
    disp('----------');
    disp(PERFdata.outPercMatrix);
end

if (PERFdata.lastTrials > 0)
    tempCX = length(PERFdata.plotOutXAxis);
    PERFdata.plotOutXAxis{tempCX+1} = '';
    PERFdata.plotOutXAxis{tempCX+2} = sprintf('last %d', PERFdata.lastTrials);
    rowNum = size(PERFdata.cxMatrix,1);
    for tempCX = 1:size(PERFdata.cxMatrix,2)
        PERFdata.outPercMatrix(rowNum+1,tempCX) = 0;
        if PERFdata.lastTrials > size(PERFdata.rawData,2)
            PERFdata.lastTrials = size(PERFdata.rawData,2);
        end
        PERFdata.outPercMatrix(rowNum+2,tempCX) = sum(PERFdata.rawData(2,size(PERFdata.rawData,2)-(PERFdata.lastTrials-1):size(PERFdata.rawData,2)) == tempCX) * 100/PERFdata.lastTrials;
    end
end


if PERFdata.debug
    disp(PERFdata.outPercMatrix);
    disp(PERFdata.plotOutXAxis);
end


if isempty(PERFdata.axesHandleRightY)&& ~isempty(PERFdata.outPercMatrix)
    PERFdata.axesHandleRightY = MW_plotterCreateSecondYAxes(PERFdata.axesHandle);
    propertylistRight.YTick = 1:100;
    success2 = MW_plotterPrepareAxes(PERFdata.axesHandleRightY,propertylistRight);
end

end
