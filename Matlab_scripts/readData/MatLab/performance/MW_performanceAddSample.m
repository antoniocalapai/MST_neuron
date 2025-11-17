function PERFdata = MW_performanceAddSample(PERFdata, varargin)
% function PERFdata = MW_performanceAddSample(PERFdata, varargin)
%
% Parameter: 'outcome' -> the TRIAL_outcome variable (wo data...) of the trial, like "hit", etc. 
%
% Version 1 by : acalapai@gwdg.de 20131018 CNL
% This function add to PERFdata structure the outcome information from a new given trial
outcome = 'unknown';
timeStamp = 0;

for i = 1 : size(varargin,2)/2 			
    switch varargin{2*(i-1)+1}
        case 'outcome'						% in the calling function this should reflect the variable TRIAL_outcome
            if (~isempty(varargin{i*2}))
               outcome = varargin{i*2};
            end
        case 'trialType'
            trialType = varargin{i*2};
        case 'time'
            timeStamp = varargin{i*2};
        otherwise
            disp('MW_performanceAddSample: WARNING: Unknown input argument!\n');
    end
end


% sort the inconing data
ttCX = find(ismember(PERFdata.trialTypeDef,trialType), 1);
if ~isempty(ttCX)
    outCX = find(ismember(PERFdata.outcomeDef,outcome), 1);
    if isempty(outCX)
        outCX = size(PERFdata.outcomeDef,2);
    end
    if (timeStamp ~= 0) && ~isempty(PERFdata.interval)
        if isempty(PERFdata.intervalTime)
            PERFdata.intervalTime = timeStamp-1 + (PERFdata.interval*60000000);
            %keine neuen Zeilen einfügen!
            %disp('HUSSAH-EINS!');
        end
        %RALF: HIER BEGINNT DER UNFUG!
        if timeStamp > PERFdata.intervalTime
            % Check if there was a break (more then one empty "block"
            while timeStamp > PERFdata.intervalTime
                PERFdata.intervalTime = PERFdata.intervalTime + (PERFdata.interval*60000000);
            end
            
            % Einfügen 0er Zeile
            PERFdata.cxMatrix = [PERFdata.cxMatrix; zeros(size(PERFdata.trialTypeDef,2)+1,size(PERFdata.cxMatrix,2))];
            % [ones_row; A] 
            
            % Einfügen 0er Zeilen für alle trialTypen
            
            %disp('HUSSAH-ZWEI!');
            %PERFdata.intervalTime = PERFdata.intervalTime + (PERFdata.interval*60000000);
            PERFdata.intervalCX = PERFdata.intervalCX+size(PERFdata.trialTypeDef,2)+1;
            PERFdata.outXAxis{length(PERFdata.outXAxis)+1} = ' ';
            for outXCX = 1:length(PERFdata.trialTypeDef)
                PERFdata.outXAxis{length(PERFdata.outXAxis)+1} = PERFdata.trialTypeDef{outXCX};
            end
        end
        PERFdata.cxMatrix(ttCX + PERFdata.intervalCX,outCX) = PERFdata.cxMatrix(ttCX + PERFdata.intervalCX,outCX) + 1;
    elseif isempty(PERFdata.interval)
        PERFdata.cxMatrix(ttCX,outCX) = PERFdata.cxMatrix(ttCX,outCX) + 1;
    end
    %disp(PERFdata.cxMatrix);
    
    % Collect the raw data for later use
    rCX = size(PERFdata.rawData,2)+1;  
    PERFdata.rawData(1,rCX) = ttCX;
    PERFdata.rawData(2,rCX) = outCX;
    PERFdata.rawData(3,rCX) = timeStamp;
    
    % check for intervall
    
end


end