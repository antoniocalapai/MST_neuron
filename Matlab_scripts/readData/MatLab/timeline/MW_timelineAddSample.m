function TIMEdata = MW_timelineAddSample(TIMEdata, trial, varargin)
% function [Timeline] = MW_Timeline_addSample(trial, Event_Type)
% Timeline New trial will replace the old Timeline
% Event_Type  Indicates the type of the event you want to show in the
% Timeline

TIMEdata.trialEnd = (double(trial.ML_trialEnd.time - trial.ML_trialStart.time)/1e3);
TIMEdata.trialNum = trial.ML_trialStart.data(1);
TIMEdata.trialNumber = trial.ML_trialStart.data(1);

TIMEdata.onOffList = {};
TIMEdata.eventList = {};
TIMEdata.fixateList = [];


for i = 1 : int16(size(varargin,2)/2)
    switch varargin{2*(i-1)+1}
        case 'Event_Type'
            Event_Type = varargin{i*2};
        otherwise
            disp('Timeline_addSample: WARNING: Unknown input argument!');
    end
end


%---- get fixation on/off ------
if isfield(trial, 'TRIAL_fixate')
    %fprintf('TRIAL_fixate-Daten sind vorhanden!\n');
    if isfield(trial.TRIAL_fixate, 'data')
        for cx = 1:size(trial.TRIAL_fixate.data,2)
            %fprintf('TRIAL_fixate\n');
            TIMEdata.fixateList(cx,1) = trial.TRIAL_fixate.data(cx);
            TIMEdata.fixateList(cx,2) = (trial.TRIAL_fixate.time(cx)-trial.ML_trialStart.time)/1000;
            TIMEdata.fixateList(cx,3) = -1;
            if cx > 1
                TIMEdata.fixateList(cx-1,3) = TIMEdata.fixateList(cx,2);
            end
        end
        TIMEdata.fixateList(cx,3) = (trial.ML_trialEnd.time-trial.ML_trialStart.time)/1000;
    end
    if isfield(trial, 'EYE_calib_x') && isfield(trial, 'EYE_calib_x')
        if ~isempty(trial.EYE_calib_x)
            TIMEdata.eye.x = trial.EYE_calib_x.data;
            TIMEdata.eye.y = trial.EYE_calib_y.data;
            TIMEdata.eye.time = (trial.EYE_calib_y.time-trial.ML_trialStart.time)/1000;
        end
    end
else
    %fprintf('No TRIAL_fixate in the experiment/trial.\n');
end



%---- get the stimNames --------
names = {};

for M = 1:size((trial.stimDisplayUpdate.data),2);
    for J = 1:size((trial.stimDisplayUpdate.data{M}),2);
        names = [names trial.stimDisplayUpdate.data{M}{J}.name];
    end
end

stimNames = unique(names);
%----------------

% ===== EXTRACT EVERY ON/OFFSET HERE =====
for frameCX = 1:length(trial.stimDisplayUpdate.data)
    %fprintf('========= Frame %d (%d) =========\n', frameCX, (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000)
    % check if a stimulus disapeared from the que
    if ~isempty(TIMEdata.onOffList)
        for onOffCX = 1:size(TIMEdata.onOffList,1)
            if TIMEdata.onOffList{onOffCX,4} < 0
                stimCX = length(trial.stimDisplayUpdate.data{1,frameCX});
                stimActive = false;
                while (stimCX > 0) && ~stimActive
                    if strcmp(TIMEdata.onOffList{onOffCX,2}, trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name)
                        stimActive = true;
                    else
                        stimCX = stimCX-1;
                    end
                end
                if ~stimActive
                    TIMEdata.onOffList{onOffCX,4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                    % Und off-Event in die eventListe schreiben
                    eventListCX = size(TIMEdata.eventList,1) + 1;
                    TIMEdata.eventList{eventListCX, 1} = TIMEdata.onOffList{onOffCX,1};
                    TIMEdata.eventList{eventListCX, 2} = 'off';
                    TIMEdata.eventList{eventListCX, 3} = 1;
                    TIMEdata.eventList{eventListCX, 4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                    TIMEdata.eventList{eventListCX, 5} = TIMEdata.onOffList{onOffCX,2};
                end
            end
        end
    end
    
    
    lastQueNumber = 0;
    aktQueNumber = -1;
    for stimCX = 1:length(trial.stimDisplayUpdate.data{1,frameCX})
        %fprintf('#ON  %s\n', trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name);
        if isempty(TIMEdata.onOffList)
            TIMEdata.onOffList{1,1} = 1;
            TIMEdata.onOffList{1,2} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name;
            TIMEdata.onOffList{1,3} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
            TIMEdata.onOffList{1,4} = -1;
            lastQueNumber = 1;
        else
            % check the onOffSetList for the best entry
            %fprintf('- Check for the best entry...\n')
            createNewEntryFlag = false;
            onOffCX = 1;
            stopFlag = false;
            while (onOffCX <= size(TIMEdata.onOffList,1)) && ~stopFlag
                if strcmp(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name, TIMEdata.onOffList{onOffCX,2})
                    % found the name in the onOffList
                    % suche nach der kleinsten queNummer...
                    
                    % sichere die akt ooQueNumber
                    aktQueNumber = TIMEdata.onOffList{onOffCX,1};
                    %fprintf('- aktQueNo %d :: lastQueNo %d\n', aktQueNumber, lastQueNumber);
                    
                    % Möglicherweise hat sich die Reihenfolge auf dem Que
                    % geändert. Das muss unbedingt berücksichtigt werden!
                    if (aktQueNumber < lastQueNumber) && (TIMEdata.onOffList{onOffCX,4} < 0)
                        TIMEdata.onOffList{onOffCX,4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                        onOffCX = onOffCX+1;
                        %fprintf('- Fiese Möglichkeit, falls die Reihenfolge des Que geändert wird!\n')
                    else
                        % checke alle folgenden ooEinträge
                        %fprintf('Checke alle späteren Einträge...\n');
                        checkOnOffCX = onOffCX+1;
                        leaveCheckLoop = false;
                        while (checkOnOffCX <= size(TIMEdata.onOffList,1)) && ~leaveCheckLoop
                            %fprintf('Checke Eintrag für %s...\n', TIMEdata.onOffList{checkOnOffCX,2});
                            if strcmp(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name, TIMEdata.onOffList{checkOnOffCX,2})
                                % Same name later in the list -> abbruch
                                
                                %fprintf('- Habe späteren Eintrag für den Stimulus gefunden...\n');
                                % der wird aber nur dann interessant, wenn
                                % er nicht! abgeschlossen ist!
                                % Andernfalls ist das hier der richtige!

                                if TIMEdata.onOffList{checkOnOffCX,4} < 0
                                    aktQueNumber = TIMEdata.onOffList{checkOnOffCX,1};
                                    stopFlag = true;
                                    leaveCheckLoop = true;
                                else
                                    stopFlag = true;
                                    leaveCheckLoop = true;
                                    createNewEntryFlag = true;
                                end
                            
                            elseif (TIMEdata.onOffList{checkOnOffCX,4} < 0) && (aktQueNumber < lastQueNumber)
                                %fprintf('Different name but active stimulus...\n');
                                % Different name but active stimulus
                                leaveCheckLoop = true;
                            end
                            checkOnOffCX = checkOnOffCX+1;
                        end
                        %fprintf('Leave the loop...\n')
                        if ~leaveCheckLoop
                            %fprintf('Dürfen die existierende Quenumber %d weiter verwenden...\n', aktQueNumber);
                            stopFlag = true;
                            lastQueNumber = aktQueNumber;
                            if (TIMEdata.onOffList{onOffCX,4} > 0)
                                %fprintf('Neuen Eintrag in OnOffListe erzeugen!\n');
                                createNewEntryFlag = true;
                            end
                        else
                            onOffCX = onOffCX+1;
                        end
                    
                    end
                else           
                    onOffCX = onOffCX+1;
                end
            end
            %fprintf('stopFlag: %d, createNewEntryFlag: %d\n', stopFlag, createNewEntryFlag);
            if ~stopFlag || createNewEntryFlag
                % didn't found it in the onOffList -> Create an entry
                % with the highest  queNumber
                onOffCX = size(TIMEdata.onOffList,1)+1;
                if ~createNewEntryFlag
                    %fprintf('#RES Nehme QueNo %d\n', max([TIMEdata.onOffList{:,1}])+1);
                    TIMEdata.onOffList{onOffCX,1} = max([TIMEdata.onOffList{:,1}])+1;
                else
                    %fprintf('#RES Nehme QueNo %d\n', aktQueNumber);
                    TIMEdata.onOffList{onOffCX,1} = aktQueNumber;
                end
                TIMEdata.onOffList{onOffCX,2} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name;
                TIMEdata.onOffList{onOffCX,3} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                TIMEdata.onOffList{onOffCX,4} = -1;
                lastQueNumber = TIMEdata.onOffList{onOffCX,1};
                %fprintf('#ON-EVENT?!?\n')
                eventListCX = size(TIMEdata.eventList,1) + 1;
                TIMEdata.eventList{eventListCX, 1} = TIMEdata.onOffList{onOffCX,1};
                TIMEdata.eventList{eventListCX, 2} = 'on';
                TIMEdata.eventList{eventListCX, 3} = 1;
                TIMEdata.eventList{eventListCX, 4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                TIMEdata.eventList{eventListCX, 5} = TIMEdata.onOffList{onOffCX,2};
            end
                    
        end
    end
    %TIMEdata.onOffList
end
% turn off every Stimulus, which is still on (up to ML_trialEnd)
if ~isempty(TIMEdata.onOffList)
    for onOffCX = 1:size(TIMEdata.onOffList,1)
        if TIMEdata.onOffList{onOffCX,4} < 0
            TIMEdata.onOffList{onOffCX,4} = (trial.ML_trialEnd.time - trial.ML_trialStart.time)/1000;
        end
    end
end
%TIMEdata.onOffList



% ===== EXTRACT EVERY FEATURECHANGE =====
for selStimCX = 1:length(stimNames)
    stimName = stimNames{selStimCX};
    stimData_minus_1 = [];
    
    for frameCX = 1:length(trial.stimDisplayUpdate.data)
        %Suche den Stim in den Daten
        stimCX = 1; stopFlag = false;
        while (stimCX <= length(trial.stimDisplayUpdate.data{1,frameCX})) && ~stopFlag
            if strcmp(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name, stimName)
                stopFlag = true;
            else
                stimCX = stimCX + 1;
            end
        end
        if ~stopFlag
            % Stimulus nicht in diesem Frame gefunden
            stimData_minus_1 = [];
        elseif isempty(stimData_minus_1)
            % Auf Frame n-1 wurde Stimulus nicht gezeigt
            featureName = fieldnames(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX});
            for featureCX = 1:length(featureName)
                if ~strcmp(featureName{featureCX}, {'update_delta', 'mt19937_seed', 'start_time', 'type', 'lastDotPosition', 'name', 'reset', 'action'})
                    eventListCX = size(TIMEdata.eventList,1)+1;
                    for onOffCX = 1:size(TIMEdata.onOffList,1)
                        if strcmp(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name, TIMEdata.onOffList{onOffCX,2})
                            if ((trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000) >= TIMEdata.onOffList{onOffCX,3}
                                if ((trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000) < TIMEdata.onOffList{onOffCX,4}
                                    TIMEdata.eventList{eventListCX, 1} = TIMEdata.onOffList{onOffCX,1};
                                end
                            end
                        end
                    end
                    %TIMEdata.eventList{eventListCX, 1} = selStimCX;
                    TIMEdata.eventList{eventListCX, 2} = featureName{featureCX};
                    TIMEdata.eventList{eventListCX, 3} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.(featureName{featureCX});
                    TIMEdata.eventList{eventListCX, 4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                    TIMEdata.eventList{eventListCX, 5} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name;
                end
                
            end
            stimData_minus_1 = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX};
        else
            % Auf Frame n-1 wurde Stimulus gezeigt. Suche veränderte features...
            featureName = fieldnames(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX});
            for featureCX = 1:length(featureName)
                if ~strcmp(featureName{featureCX}, {'update_delta', 'mt19937_seed', 'start_time', 'type', 'lastDotPosition', 'name', 'reset', 'action'})
  
                    % check for strings and nonStrings
                    featureChangeFlag = false;
                    if isstr(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.(featureName{featureCX}))
                        if ~strcmp(stimData_minus_1.(featureName{featureCX}),trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.(featureName{featureCX}))
                            featureChangeFlag = true;
                        end
                    else
                        if (stimData_minus_1.(featureName{featureCX}) ~= trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.(featureName{featureCX}))
                            featureChangeFlag = true;
                        end
                    end
                    
                    if featureChangeFlag
                        eventListCX = size(TIMEdata.eventList,1)+1;
                        for onOffCX = 1:size(TIMEdata.onOffList,1)
                            if strcmp(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name, TIMEdata.onOffList{onOffCX,2})
                                if ((trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000) >= TIMEdata.onOffList{onOffCX,3}
                                    if ((trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000) < TIMEdata.onOffList{onOffCX,4}
                                        TIMEdata.eventList{eventListCX, 1} = TIMEdata.onOffList{onOffCX,1};
                                    end
                                end
                            end
                        end
                        %TIMEdata.eventList{eventListCX, 1} = selStimCX;
                        TIMEdata.eventList{eventListCX, 2} = featureName{featureCX};
                        TIMEdata.eventList{eventListCX, 3} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.(featureName{featureCX});
                        TIMEdata.eventList{eventListCX, 4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                        TIMEdata.eventList{eventListCX, 5} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name;
                    end
                end
                
            end
            stimData_minus_1 = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX};
        end
    end
end
% TIMEdata.yNames = {TIMEdata.onOffList{[unique([TIMEdata.onOffList{:,1}])],2}};
% TIMEdata.yLim = [1 length(TIMEdata.yNames)];


%---- get the IO_data --------
trialFieldNames = fieldnames(trial);
ioFieldNames = trialFieldNames(strncmp(fieldnames(trial), 'IO_', 3));
aktOnOffLine = 1;

if ~isempty(ioFieldNames)
    for ioCX = 1:length(ioFieldNames)
        
        %fprintf('#IO: Check %s\n', ioFieldNames{ioCX});
        if ~isempty(trial.(ioFieldNames{ioCX}))
            %fprintf('#IO: Found data... %d Einträge\n', length(trial.(ioFieldNames{ioCX}).time));
            aktOnOffLine = aktOnOffLine-1;
            for eventCX = 1:length(trial.(ioFieldNames{ioCX}).time)
                %fprintf('#IO: Add Datenpunkte...\n');
                if (trial.(ioFieldNames{ioCX}).data(eventCX) ~= 0)
                    %fprintf('#IO: Erzeuge Eintrag...\n');
                    ioOnOffCX = size(TIMEdata.onOffList,1)+1;
                    TIMEdata.onOffList{ioOnOffCX,1} = aktOnOffLine;
                    TIMEdata.onOffList{ioOnOffCX,2} = ioFieldNames{ioCX};
                    TIMEdata.onOffList{ioOnOffCX,3} = (trial.(ioFieldNames{ioCX}).time(eventCX)-trial.ML_trialStart.time)/1000;
                    TIMEdata.onOffList{ioOnOffCX,4} = -1;
                    %fprintf('#IO: Event hinzufügen!\n')
                    % Und on-Event in die eventListe schreiben
                    eventListCX = size(TIMEdata.eventList,1) +1;
                    TIMEdata.eventList{eventListCX, 1} = TIMEdata.onOffList{size(TIMEdata.onOffList,1),1};
                    TIMEdata.eventList{eventListCX, 2} = 'on';
                    TIMEdata.eventList{eventListCX, 3} = 1;
                    TIMEdata.eventList{eventListCX, 4} = (trial.(ioFieldNames{ioCX}).time(eventCX)-trial.ML_trialStart.time)/1000;
                    TIMEdata.eventList{eventListCX, 5} = ioFieldNames{ioCX};
                else
                    %fprintf('#IO: Schliesse Eintrag...\n');
                    if TIMEdata.onOffList{size(TIMEdata.onOffList,1),4} ~= -1
                        %fprintf('#IO: HIer findet ein Eventwechsel statt!\n')
                    else
                        %fprintf('#IO: Hier muss ein Eintrag geschlossen werden...\n');
                        TIMEdata.onOffList{size(TIMEdata.onOffList,1),4} = (trial.(ioFieldNames{ioCX}).time(eventCX)-trial.ML_trialStart.time)/1000;
                        % Und off-Event in die eventListe schreiben
                        eventListCX = size(TIMEdata.eventList,1) +1;
                        TIMEdata.eventList{eventListCX, 1} = TIMEdata.onOffList{size(TIMEdata.onOffList,1),1};
                        TIMEdata.eventList{eventListCX, 2} = 'off';
                        TIMEdata.eventList{eventListCX, 3} = 1;
                        TIMEdata.eventList{eventListCX, 4} = (trial.(ioFieldNames{ioCX}).time(eventCX)-trial.ML_trialStart.time)/1000;
                        TIMEdata.eventList{eventListCX, 5} = ioFieldNames{ioCX};
                    end
                end
            end
        end
    end
end
% turn off every IO, which is still on (up to ML_trialEnd)
if ~isempty(TIMEdata.onOffList)
    for onOffCX = 1:size(TIMEdata.onOffList,1)
        if TIMEdata.onOffList{onOffCX,4} < 0
            TIMEdata.onOffList{onOffCX,4} = (trial.ML_trialEnd.time - trial.ML_trialStart.time)/1000;
        end
    end
end

%-----------------------------


end