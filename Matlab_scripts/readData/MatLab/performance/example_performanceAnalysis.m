function [retval] = example_performanceAnalysis(data, values)           % #
% Example for performance window                                        % #
if nargin == 1                                                          % #
    allpath = genpath([strrep(userpath,'MATLAB:','') 'MWorks/MatLab/']);% #
    addpath(allpath);                                                   % #
    addpath('/Library/Application Support/MWorks/Scripting/Matlab');    % #
    values.endOfExperiment = false;                                     % #
% ----------------------------------------------------------------------- #
% ##### Initialize the figure (window) and the analysis ###################

disp('INIT')

    values.nameOutcome = {'hit', 'brokeFixation', 'wrong', 'ignored'};
    values.nameTTypes = {'attIn', 'attOut'};
    
    axesList = MW_plotterCreateFigure([1], {[1]},'Name','My amaaaaaazing experiment!','NumberTitle','off','Position',[0 1000 500 300]);
    values.PERFdata = MW_performanceCreate(axesList(1),...
        'outcomes', values.nameOutcome,...
        'color', [0 0.8 0; 1 0.75 0; 1 0 0; 0.6 0.6 0.6; 0.5 0.5 0.5],...
        'trialType', values.nameTTypes,...
        'interval', 1);

    
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

    %values.PERFdata.debug = false;

    % Which type of trial?
%     [feature, ~] = MW_getStimData('dot', 'pos_x', trial);
%     if (feature{1} < 0) tType = 'attIn';
%     else tType = 'attOut';
%     end
%test
    tType = values.nameTTypes{trial.IO_trialType.data};

    % Which outcome?
%     [feature, ~] = MW_getStimData('RDP', 'direction', trial);
%     %disp(feature(1));
%     if feature{1} < 180 outcome = 'hit';
%     elseif feature{1} < 240 outcome = 'brokeFixation';
%     elseif feature{1} < 280 outcome = 'wrong';
%     elseif feature{1} < 320 outcome = 'ignored';
%     else outcome = 'unknown';
%     end
%     %disp(outcome);
    
 

    outcome = values.nameOutcome{trial.IO_result.data};
    
    %disp(trial.TRIAL_outcome)
    values.PERFdata = MW_performanceAddSample(values.PERFdata, 'outcome', outcome, 'trialType', tType, 'time', trial.ML_trialEnd.time(1));
    


% #########################################################################
% ----------------------------------------------------------------------- #
if values.endOfExperiment == true                                       % #
% ----------------------------------------------------------------------- #
% ##### Calculate and plot the date after every trial/the last trial ######



    values.PERFdata = MW_performanceCalculate(values.PERFdata,'lastTrials', 15); %, 'lastTrials', 10
    MW_performancePlot(values.PERFdata, 1);
    
    
    
% #########################################################################    
% ----------------------------------------------------------------------- #
    fprintf(' trial %d *done*\n', trial.ML_trialStart.data);            % #
end                                                                     % #
retval = values;                                                        % #
end                                                                     % #