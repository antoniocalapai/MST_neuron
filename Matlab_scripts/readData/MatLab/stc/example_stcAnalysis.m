function [retval] = example_stcAnalysis(data, values)              % #
% Example for performance window                                        % #
if nargin == 1                                                          % #
    allpath = genpath([strrep(userpath,'MATLAB:','') 'MWorks/MatLab/']);% #
    addpath(allpath);                                                   % #
    addpath('/Library/Application Support/MWorks/Scripting/Matlab');    % #
    values.endOfExperiment = false;                                     % #
% ----------------------------------------------------------------------- #
% ##### Initialize the figure (window) and the analysis ###################



    axesHandles = MW_plotterCreateFigure([2, 1], {1, 2},'NumberTitle','off','Position',[677 665 1152 200]);
    values.TIMEdata = MW_timelineCreate(axesHandles(1),'Title','Timeline','XLabel','Time ms','YLabel','');
    values.STCdataSLOW = MW_stcCreate(axesHandles(2),'slow','Title','Staircase difference','XLabel','trials','YLabel','difficulty (%)');
    values.STCdataFAST = MW_stcCreate(axesHandles(2),'fast','Title','Staircase difference','XLabel','trials','YLabel','difficulty (%)');


    
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
    if (trial.stcSelector.data(1) == 0)
        values.STCdataSLOW = MW_stcAddSample(values.STCdataSLOW, 'trialNum', trial.ML_trialStart.data(1), 'value',trial.STC_slow_out.data(1));
    else
        values.STCdataFAST = MW_stcAddSample(values.STCdataFAST, 'trialNum', trial.ML_trialStart.data(1), 'value',trial.STC_fast_out.data(1));
    end

    % Normally wie add every sample here. But the timeline-plot is special.
    % We create after every trial everything completely new.
    % Once again. This is verry special for the timeline plot!
    

% #########################################################################
% ----------------------------------------------------------------------- #
if values.endOfExperiment == true                                       % #
% ----------------------------------------------------------------------- #
% ##### Calculate and plot the date after every trial/the last trial ######

    
    stc1props.STAIR.Color = 'b';
    stc2props.STAIR.Color = 'b';
    MW_stcPlot(values.STCdataSLOW,1,stc1props);                                                              % plot the STC, refreshing content of axes
    MW_stcPlot(values.STCdataFAST,0,stc2props);

    % This is special! The addSample makes no sense after every trial, if
    % it is not plotted...
    values.TIMEdata = MW_timelineAddSample(values.TIMEdata, trial);
    values.TIMEdata = MW_timelineCalculate(values.TIMEdata);
    
    
    % Define some different marker/line styles
    mark1.Marker = '>'; mark1.MarkerEdgeColor = [0 0 0]; mark1.MarkerSize = 9; mark1.MarkerFaceColor = [1 1 0];
    mark2 = mark1; mark2.MarkerFaceColor = [1 0 0];
    mark3 = mark1; mark3.MarkerFaceColor = [0 0 1];
    mark4 = mark1; mark4.MarkerFaceColor = [0 0.9 0];
    line1.Color = [0 0.5 1]; line1.LineWidth = 1; line1.LineStyle = '--';
    line2 = line1; line2.Color = [0.5 0 0]; line2.LineStyle = '-';

    values.TIMEdata = MW_timelinePlot(values.TIMEdata, ...
        ...%'mark', {'direction', 'RDP', {'>=0' '<=90'}, mark3, 0}, ...
        'mark', {'color', '', '', mark3, 0}, ...
        'mark', {'speed', '', '', mark1, 0}, ...
        'mark', {'on', '', '', mark4, 0}, ...
        'mark', {'off', '', '', mark2, 0}, ...
        'line', {'off', 'dot', '', line1, 0}, ...
        'line', {'off', 'dot', '', line2, 250}, ...
        'line', {'on', 'leftStimulus', '', line1, 0}, 'line', {'off', 'leftStimulus', '', line2, 0}, ...
        'hurz');
  
    
    
% #########################################################################    
% ----------------------------------------------------------------------- #
    fprintf(' trial %d *done*\n', trial.ML_trialStart.data);            % #
end                                                                     % #
retval = values;                                                        % #
end                                                                     % #