function retData = MW_getEventData(trial, varargin)
% function retData = MW_getEventData(trial, varargin)
%
% THIS IS AN EARLY BETAVERSION!
%
% Use the parameter 'eventList' for the following format:
% Struct:
%   timeMS - Matrix of the evntTime in milliseconds till ML_trialStart
%   name - Name of the Stimulus, IO-device or Trial_fixate
%   featureName - name of the feature wich changed or 'on', 'off'
%   featureValue - new Value of the feature
%   queLayer - Queorder of the stimuli, io-devices get negative numbers...
%
% The default function return a cell array with three lists inside:
% 1. OnOff List (On and Offsets of all stimuli & IOs (fixation will add
%    later)
% 2. EventList (All Stimulus and IO Events)
% 3. FixateList
% => THIS WILL CHANGE In THE FUTURE!
%
% rbrockhausen@dpz.eu, June 2015


% KNOWN BUGS
%   ? No entry in the list, when an IO-variable change a value from x to y (with x & y != 0)


outputType = 'default';

for i = 1 : int16(size(varargin,2))
    switch varargin{i}
        case 'eventList'
            outputType = 'eventList';
        case 'ioList'
            outputType = 'ioList';
        otherwise
            disp('MW_getEventData: WARNING: Unknown input argument!');
    end
end



% Internal structures:

onOffList = {};
eventList = {};
fixateList = [];



trialEnd = (double(trial.ML_trialEnd.time - trial.ML_trialStart.time)/1e3);
trialNum = trial.ML_trialStart.data(1);
trialNumber = trial.ML_trialStart.data(1);



%---- get fixation on/off ------
if isfield(trial, 'TRIAL_fixate')
    %fprintf('TRIAL_fixate-Daten sind vorhanden!\n');
    if isfield(trial.TRIAL_fixate, 'data')
        for cx = 1:size(trial.TRIAL_fixate.data,2)
            %fprintf('TRIAL_fixate\n');
            fixateList(cx,1) = trial.TRIAL_fixate.data(cx);
            fixateList(cx,2) = (trial.TRIAL_fixate.time(cx)-trial.ML_trialStart.time)/1000;
            fixateList(cx,3) = -1;
            if cx > 1
                fixateList(cx-1,3) = fixateList(cx,2);
            end
        end
        fixateList(cx,3) = (trial.ML_trialEnd.time-trial.ML_trialStart.time)/1000;
    end
    if isfield(trial, 'EYE_calib_x') && isfield(trial, 'EYE_calib_x')
        if ~isempty(trial.EYE_calib_x)
            eye.x = trial.EYE_calib_x.data;
            eye.y = trial.EYE_calib_y.data;
            eye.time = (trial.EYE_calib_y.time-trial.ML_trialStart.time)/1000;
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
    if ~isempty(onOffList)
        for onOffCX = 1:size(onOffList,1)
            if onOffList{onOffCX,4} < 0
                stimCX = length(trial.stimDisplayUpdate.data{1,frameCX});
                stimActive = false;
                while (stimCX > 0) && ~stimActive
                    if strcmp(onOffList{onOffCX,2}, trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name)
                        stimActive = true;
                    else
                        stimCX = stimCX-1;
                    end
                end
                if ~stimActive
                    onOffList{onOffCX,4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                    % Und off-Event in die eventListe schreiben
                    eventListCX = size(eventList,1) + 1;
                    eventList{eventListCX, 1} = onOffList{onOffCX,1};
                    eventList{eventListCX, 2} = 'off';
                    eventList{eventListCX, 3} = 1;
                    eventList{eventListCX, 4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                    eventList{eventListCX, 5} = onOffList{onOffCX,2};
                end
            end
        end
    end
    
    
    lastQueNumber = 0;
    aktQueNumber = -1;
    for stimCX = 1:length(trial.stimDisplayUpdate.data{1,frameCX})
        %fprintf('#ON  %s\n', trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name);
        if isempty(onOffList)
            onOffList{1,1} = 1;
            onOffList{1,2} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name;
            onOffList{1,3} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
            onOffList{1,4} = -1;
            lastQueNumber = 1;
        else
            % check the onOffSetList for the best entry
            %fprintf('- Check for the best entry...\n')
            createNewEntryFlag = false;
            onOffCX = 1;
            stopFlag = false;
            while (onOffCX <= size(onOffList,1)) && ~stopFlag
                if strcmp(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name, onOffList{onOffCX,2})
                    % found the name in the onOffList
                    % suche nach der kleinsten queNummer...
                    
                    % sichere die akt ooQueNumber
                    aktQueNumber = onOffList{onOffCX,1};
                    %fprintf('- aktQueNo %d :: lastQueNo %d\n', aktQueNumber, lastQueNumber);
                    
                    % Möglicherweise hat sich die Reihenfolge auf dem Que
                    % geändert. Das muss unbedingt berücksichtigt werden!
                    if (aktQueNumber < lastQueNumber) && (onOffList{onOffCX,4} < 0)
                        onOffList{onOffCX,4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                        onOffCX = onOffCX+1;
                        %fprintf('- Fiese Möglichkeit, falls die Reihenfolge des Que geändert wird!\n')
                    else
                        % checke alle folgenden ooEinträge
                        %fprintf('Checke alle späteren Einträge...\n');
                        checkOnOffCX = onOffCX+1;
                        leaveCheckLoop = false;
                        while (checkOnOffCX <= size(onOffList,1)) && ~leaveCheckLoop
                            %fprintf('Checke Eintrag für %s...\n', onOffList{checkOnOffCX,2});
                            if strcmp(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name, onOffList{checkOnOffCX,2})
                                % Same name later in the list -> abbruch
                                
                                %fprintf('- Habe späteren Eintrag für den Stimulus gefunden...\n');
                                % der wird aber nur dann interessant, wenn
                                % er nicht! abgeschlossen ist!
                                % Andernfalls ist das hier der richtige!
                                
                                if onOffList{checkOnOffCX,4} < 0
                                    aktQueNumber = onOffList{checkOnOffCX,1};
                                    stopFlag = true;
                                    leaveCheckLoop = true;
                                else
                                    stopFlag = true;
                                    leaveCheckLoop = true;
                                    createNewEntryFlag = true;
                                end
                                
                            elseif (onOffList{checkOnOffCX,4} < 0) && (aktQueNumber < lastQueNumber)
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
                            if (onOffList{onOffCX,4} > 0)
                                % fprintf('Neuen Eintrag in OnOffListe erzeugen!\n');
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
                onOffCX = size(onOffList,1)+1;
                if ~createNewEntryFlag
                    %fprintf('#RES Nehme QueNo %d\n', max([onOffList{:,1}])+1);
                    onOffList{onOffCX,1} = max([onOffList{:,1}])+1;
                else
                    %fprintf('#RES Nehme QueNo %d\n', aktQueNumber);
                    onOffList{onOffCX,1} = aktQueNumber;
                end
                onOffList{onOffCX,2} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name;
                onOffList{onOffCX,3} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                onOffList{onOffCX,4} = -1;
                lastQueNumber = onOffList{onOffCX,1};
                %fprintf('#ON-EVENT?!?\n')
                eventListCX = size(eventList,1) + 1;
                eventList{eventListCX, 1} = onOffList{onOffCX,1};
                eventList{eventListCX, 2} = 'on';
                eventList{eventListCX, 3} = 1;
                eventList{eventListCX, 4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                eventList{eventListCX, 5} = onOffList{onOffCX,2};
            end
            
        end
    end
    %onOffList
end
% turn off every Stimulus, which is still on (up to ML_trialEnd)
if ~isempty(onOffList)
    for onOffCX = 1:size(onOffList,1)
        if onOffList{onOffCX,4} < 0
            onOffList{onOffCX,4} = (trial.ML_trialEnd.time - trial.ML_trialStart.time)/1000;
        end
    end
end
%onOffList



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
                    eventListCX = size(eventList,1)+1;
                    for onOffCX = 1:size(onOffList,1)
                        if strcmp(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name, onOffList{onOffCX,2})
                            if ((trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000) >= onOffList{onOffCX,3}
                                if ((trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000) <= onOffList{onOffCX,4}
                                    eventList{eventListCX, 1} = onOffList{onOffCX,1};
                                end
                            end
                        end
                    end
                    %eventList{eventListCX, 1} = selStimCX;
                    eventList{eventListCX, 2} = featureName{featureCX};
                    eventList{eventListCX, 3} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.(featureName{featureCX});
                    eventList{eventListCX, 4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                    eventList{eventListCX, 5} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name;
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
                        eventListCX = size(eventList,1)+1;
                        for onOffCX = 1:size(onOffList,1)
                            if strcmp(trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name, onOffList{onOffCX,2})
                                if ((trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000) >= onOffList{onOffCX,3}
                                    if ((trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000) <= onOffList{onOffCX,4}
                                        eventList{eventListCX, 1} = onOffList{onOffCX,1};
                                    end
                                end
                            end
                        end
                        %eventList{eventListCX, 1} = selStimCX;
                        eventList{eventListCX, 2} = featureName{featureCX};
                        eventList{eventListCX, 3} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.(featureName{featureCX});
                        eventList{eventListCX, 4} = (trial.stimDisplayUpdate.time(frameCX)-trial.ML_trialStart.time)/1000;
                        eventList{eventListCX, 5} = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX}.name;
                    end
                end
                
            end
            stimData_minus_1 = trial.stimDisplayUpdate.data{1,frameCX}{1,stimCX};
        end
    end
end
% yNames = {onOffList{[unique([onOffList{:,1}])],2}};
% yLim = [1 length(yNames)];


%---- get the IO_data --------
trialFieldNames = fieldnames(trial);
ioFieldNames = trialFieldNames(strncmp(fieldnames(trial), 'IO_', 3));
aktOnOffLine = 1;


%Bug gefunden. Manchmal ist der data Eintrag eine matrix sondern ein
%Cell-Array, was das ganze etwas komplizierter macht und am Zeile 354 zum
%Programmabbruch führt...
if ~isempty(ioFieldNames)
    for ioCX = 1:length(ioFieldNames)
        
        %fprintf('#IO: Check %s\n', ioFieldNames{ioCX});
        if ~isempty(trial.(ioFieldNames{ioCX}))
            %fprintf('#IO: Found data... %d Einträge\n', length(trial.(ioFieldNames{ioCX}).time));
            aktOnOffLine = aktOnOffLine-1;
            for eventCX = 1:length(trial.(ioFieldNames{ioCX}).time)
                %fprintf('#IO: Add Datenpunkte... value: %d\n', trial.(ioFieldNames{ioCX}).data(eventCX));
                if (trial.(ioFieldNames{ioCX}).data(eventCX) ~= 0)
                    % HIER MUSS GETESTET WERDEN OB EIN VORHERGEHENDER
                    % EINTRAG EXISTIERT, DAMIT DER AKTUELL LAUFENDE NOCH
                    % GESCHLOSSEN WERDEN KANN!
                    %fprintf('#IO: Erzeuge Eintrag...\n');
                    ioOnOffCX = size(onOffList,1)+1;
                    onOffList{ioOnOffCX,1} = aktOnOffLine;
                    onOffList{ioOnOffCX,2} = ioFieldNames{ioCX};
                    onOffList{ioOnOffCX,3} = (trial.(ioFieldNames{ioCX}).time(eventCX)-trial.ML_trialStart.time)/1000;
                    onOffList{ioOnOffCX,4} = -1;
                    %fprintf('#IO: Event hinzufügen!\n')
                    % Und on-Event in die eventListe schreiben
                    eventListCX = size(eventList,1) +1;
                    eventList{eventListCX, 1} = onOffList{size(onOffList,1),1};
                    eventList{eventListCX, 2} = 'on';
                    eventList{eventListCX, 3} = trial.(ioFieldNames{ioCX}).data(eventCX);
                    eventList{eventListCX, 4} = (trial.(ioFieldNames{ioCX}).time(eventCX)-trial.ML_trialStart.time)/1000;
                    eventList{eventListCX, 5} = ioFieldNames{ioCX};
                else
                    %fprintf('#IO: Schliesse Eintrag...\n');
                    if onOffList{size(onOffList,1),4} ~= -1
                        %fprintf('#IO: Hier findet ein Eventwechsel statt!\n')
                        % Es gibt keinen vorgehenden 'on'-Event, dann läuft es von trialStart/0 ab.
                        % Das passiert genau dann wenn eventCX==1 ist
                        if eventCX == 1
                            %fprintf('#IO: Erzeuge Eintrag start->off...\n');
                            ioOnOffCX = size(onOffList,1)+1;
                            onOffList{ioOnOffCX,1} = aktOnOffLine;
                            onOffList{ioOnOffCX,2} = ioFieldNames{ioCX};
                            onOffList{ioOnOffCX,3} = 0;
                            onOffList{ioOnOffCX,4} = (trial.(ioFieldNames{ioCX}).time(eventCX)-trial.ML_trialStart.time)/1000;
                            
                            % Und off-Event in die eventListe schreiben
                            eventListCX = size(eventList,1) +1;
                            eventList{eventListCX, 1} = onOffList{size(onOffList,1),1};
                            eventList{eventListCX, 2} = 'off';
                            eventList{eventListCX, 3} = 0;
                            eventList{eventListCX, 4} = (trial.(ioFieldNames{ioCX}).time(eventCX)-trial.ML_trialStart.time)/1000;
                            eventList{eventListCX, 5} = ioFieldNames{ioCX};
                        end
                    else
                        %fprintf('#IO: Hier muss ein Eintrag geschlossen werden...\n');
                        onOffList{size(onOffList,1),4} = (trial.(ioFieldNames{ioCX}).time(eventCX)-trial.ML_trialStart.time)/1000;
                        % Und off-Event in die eventListe schreiben
                        eventListCX = size(eventList,1) +1;
                        eventList{eventListCX, 1} = onOffList{size(onOffList,1),1};
                        eventList{eventListCX, 2} = 'off';
                        eventList{eventListCX, 3} = 0;
                        eventList{eventListCX, 4} = (trial.(ioFieldNames{ioCX}).time(eventCX)-trial.ML_trialStart.time)/1000;
                        eventList{eventListCX, 5} = ioFieldNames{ioCX};
                    end
                end
            end
        end
    end
end
% turn off every IO, which is still on (up to ML_trialEnd)
if ~isempty(onOffList)
    for onOffCX = 1:size(onOffList,1)
        if onOffList{onOffCX,4} < 0
            onOffList{onOffCX,4} = (trial.ML_trialEnd.time - trial.ML_trialStart.time)/1000;
        end
    end
end


% ----- EVENTLIST OUTPUT TYPE -----
if strcmp(outputType, 'eventList')
    outList = [];
    for cx = 1:size(eventList,1)
        outList.timeMS(cx) = eventList{cx,4};
        outList.name{cx} = eventList{cx,5};
        outList.featureName{cx} = eventList{cx,2};
        outList.featureValue{cx} = eventList{cx,3};
        outList.queLayer(cx) = eventList{cx,1};
    end
    for cx = 1:size(fixateList,1)
        dx = length(outList.timeMS)+1;
        outList.timeMS(dx) = fixateList(cx,2);
        outList.name{dx} = 'TRIAL_fixate';
        if fixateList(cx,1) == 1
            outList.featureName{dx} = 'on';
        else
            outList.featureName{dx} = 'off';
        end
        outList.featureValue{dx} = fixateList(cx,1);
        outList.queLayer(dx) = 0;
    end
    retData = outList;
    


% ----- DEFAULT OUTPUT TYPE -----
else
    retData = {onOffList eventList fixateList};
end


end
