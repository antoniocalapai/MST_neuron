function [output, output2] = MW_getStimData(stimName, featureName, theTrial)
% function output = MW_getStimData(stimName, featureName, theTrial)
%
% Known Bugs...
%  ..... nur Background, nur ein Frame?!?
%
% 12.02.2013 - rbrockhausen - Version 1.0 finished (dance)

stimShownBefore = 0;
oldFeatureValue = [];
output = [];
output2 = [];
outputCounter = 0;


for frameNo = 1:length(theTrial.stimDisplayUpdate.data)
    tempStimShownBefore  = 0;
    stimShownThisFrame = 0;
    for stimNo = 1:length(theTrial.stimDisplayUpdate.data{1,frameNo})
        
        if not(isempty(theTrial.stimDisplayUpdate.data{1,frameNo}{1,stimNo})) && strcmp(theTrial.stimDisplayUpdate.data{1,frameNo}{1,stimNo}.name, stimName)
            stimShownThisFrame = 1;
            doIt = 0;
            if ischar(theTrial.stimDisplayUpdate.data{1,frameNo}{1,stimNo}.(featureName))
                if not(strcmp(oldFeatureValue, theTrial.stimDisplayUpdate.data{1,frameNo}{1,stimNo}.(featureName)))
                    doIt = 1;
                end
            elseif oldFeatureValue ~= theTrial.stimDisplayUpdate.data{1,frameNo}{1,stimNo}.(featureName)
                doIt = 1;
            end
            if not(stimShownBefore) || doIt
                outputCounter = outputCounter + 1;
                output{1, outputCounter} = theTrial.stimDisplayUpdate.data{1,frameNo}{1,stimNo}.(featureName);
                output2(1, outputCounter) = theTrial.stimDisplayUpdate.time(1,frameNo);
                oldFeatureValue = theTrial.stimDisplayUpdate.data{1,frameNo}{1,stimNo}.(featureName);
            end
            tempStimShownBefore = 1;
        end
    end
    stimShownBefore = tempStimShownBefore;
    if not(stimShownThisFrame) && not(isempty(oldFeatureValue))
        outputCounter = outputCounter + 1;
        output{1, outputCounter} = [];
        output2(1, outputCounter) = theTrial.stimDisplayUpdate.time(1,frameNo);
        oldFeatureValue = [];
    end
end

end