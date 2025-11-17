function [exp, trial, values] = MW_analyzeExperiment(funcName, fileName)
% function [exp, trial, values] = MW_analyzeExperiment(funcName, fileName)
%
% FUNCNAME: The handle of your analysis function, for example @myAnalysis
% FILENAME: Full path and name to your data file or a cellArray with
%           fileNames (incl. full path), f.e. {"exp1.mwk", "exp2.mwk"}
%
% rbrockhausen@dpz.eu, July 2014

if iscell(fileName)
    fprintf('Process more than one file...\n');
else
    fileName = {fileName};
end



for fileCX = 1:length(fileName)

    [exp, trial] = MW_readExperiment(fileName{fileCX});
    
    fprintf('Got the data...\n');
    
    dx = 0;
    
    for cx = 1 : length(trial)
        if (cx == length(trial)) && (fileCX == length(fileName))
            values.endOfExperiment = true;
        end
        
        if (cx == 1) && (fileCX == 1)
            values = funcName(trial(cx));
        else
            values = funcName(trial(cx), values);
        end
        
        
        dx = dx + 1;
        if dx > 10
            fprintf('.');
            dx = 0;
        end
        
    end
    
end

end