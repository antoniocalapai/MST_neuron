function [retval] = nonlinearOpt(data, values)           % #
% Example for performance window                                        % #
if nargin == 1                                                          % #
    allpath = genpath([strrep(userpath,'MATLAB:','') 'MWorks/MatLab/']);% #
    addpath(allpath);                                                   % #
    addpath('/Library/Application Support/MWorks/Scripting/Matlab');    % #
    values.endOfExperiment = false;                                     % #
% ----------------------------------------------------------------------- #
% ##### Initialize the figure (window) and the analysis ###################

    axesList = MW_plotterCreateFigure([2,2], {[3 4], 1, 2},'Name','NOMT','NumberTitle','off','Position',[677 665 1152 600]);     
    values.Locationdata = MW_nonlinearOptCreate(axesList(1), 'Location');
    values.firingRate = MW_nonlinearOptCreate(axesList(2), 'Firing Rate');
    t = 0;

% #########################################################################    
% ----------------------------------------------------------------------- #
end                                                                     % #
try                                                                     % #
    trial = MW_readTrial(data);                                         % #
    values.endOfExperiment = true;                                      % #
catch                                                                   % #
    trial = data;                                                       % #
end                                                                     % #
% ----------------------------------------------------------------------- #
% ##### Collect the data from one trial ###################################
t =  1;

[direction, ~] = MW_getStimData('nDim RDP', 'used_direction', trial)
disp((str2num(direction{1}))')

[firing_rate, ~] = MW_getStimData('nDim RDP', 'firing_rate', trial)
% disp(firing_rate{1})

% values.firingRate  = MW_nonlinearOptAddSample(values.firingRate ,'trialNum', trial.ML_trialStart.data(1), 'value',firing_rate{1})
disp('HURZ!')
% (str2num(direction{1}))'
if isempty(values.Locationdata.yValue) == 0
    values.Locationdata  = MW_nonlinearOptAddSample(values.Locationdata ,'trialNum', trial.ML_trialStart.data(1), 'value',(str2num(direction{1}))' - values.Locationdata.yValue(:,1));
else
    values.Locationdata  = MW_nonlinearOptAddSample(values.Locationdata ,'trialNum', trial.ML_trialStart.data(1), 'value',(str2num(direction{1}))');
end
% disp(values.Locationdata.yValue)
% disp(values.Locationdata.trialNum)
disp('HURZ!')
% h1 = MW_nonlinearOptPlot(values.firingRate)
h2 = MW_nonlinearOptPlot(values.Locationdata);
disp('HURZ!')
% #########################################################################
% ----------------------------------------------------------------------- #
if values.endOfExperiment == true                                       % #
% ----------------------------------------------------------------------- #
 
% #########################################################################    
% ----------------------------------------------------------------------- #
    fprintf(' trial %d *done*\n', trial.ML_trialStart.data);            % #
end                                                                     % #
retval = values;                                                        % #
end                                                                     % #
                                                                   