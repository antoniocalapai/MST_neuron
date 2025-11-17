

function flagList = MW_checkTrial(filename)
% Ganz allgemein muss man unterscheiden zwischen Afragen die nach jeden
% Trial durchgeführt werden müssen und solchen, die nur nach dem ersten
% Trial stattfinden
% Die Vorabprüfung muss über die Codecs des Experiments laufen nicht über
% die Daten. Über die Daten selbst muss bei jedem Trial eine Konsistenz-
% prüfung stattfinden
%
% Get the codecs...
% filename = '/Volumes/cnl/mWorks/MatLab/_examples/sampleData.mwk';
% filename = '/Users/tito/Desktop/weco_20140127.mwk';
% filename = '/Users/tito/Desktop/Datenfiles/ABo_20130808_spiral_button_cue_both_task.mwk';

% CHECK IF FILE EXIST!!!

addpath('/Library/Application Support/MWorks/Scripting/Matlab')
fprintf('\n\n##### %s\n', filename);
fprintf('# If the datafile is not indexed yet... this could take a while :-(\n');
codecs=getCodecs(filename);
trialCodec = {codecs.codec.tagname};
clear codecs;

fprintf('\n---------------------------------------------------------------\n');
fprintf('##### CHECKING THE VARIABLE DEFINITIONS OF THE EXPERIMENT #####\n\n');

fatalError = false;

% Testen ob trialCodec leer ist...
if (isempty(trialCodec))
    fprintf('### FATAL ERROR! No variable definitions in the data!\n');
    error('Please check your experiment file for the errors above!');
else
    trialCodec = regexprep(trialCodec, '#', 'ML_');
end



% Überprüfen ob Pflichtfelder vorliegen
checkList = {'ML_trialStart', 'ML_trialEnd', 'ML_stimDisplayUpdate', 'ML_announceMessage'};

for i=1:length(checkList)
    flagList.(checkList{i}) = false;
    fprintf('%s... ', checkList{i});
    if find(ismember(trialCodec, checkList{i}))
        fprintf('ok\n');
        flagList.(checkList{i}) = true;
    else
        fprintf('failed\n##### FATAL ERROR! Variable does not exist!\n');
        error('Please check your experiment file for the errors above!');
    end
end

clear i checkList;



% ML_sync, ML_trialOutcome & EXP_version -Hinweis
checkList = {'TRIAL_outcome', 'ML_sync', 'EXP_version'};
for i=1:length(checkList)
    flagList.(checkList{i}) = false;
    fprintf('%s... ', checkList{i});
    if find(ismember(trialCodec, checkList{i}))
        fprintf('ok\n');
        flagList.(checkList{i}) = true;
    else
        fprintf('failed! Please add this variable to your experiment.\n');
        flagList.(checkList{i}) = false;
    end
end
clear i checkList;



% EXP_variables (Anzahl)
fprintf('\n# Other EXP_variables...\n');
expCounter = length(cell2mat(strfind(trialCodec, 'EXP_')));
fprintf('%d EXP_variables are defined.\n', expCounter);
if expCounter > 16
    fprintf('##### ERROR! Please read *The use of EXP_variables* in the WIKI.\n##### Do not collect any data with this experiment file!\n');
elseif (expCounter > 11)
    fprintf('Warning: Are you sure, you need so many EXP_variables? Please read the WIKI...\n');
end



% Überprüfen der definierten Staircaseparameter
if (cell2mat(strfind(trialCodec, 'SC_')))
    fprintf('\n# SC_variables defined.\n');
    usedVars = trialCodec(find(strncmp([trialCodec], 'SC_', 3)));
    for i=1:length(usedVars)
        % Remove SC_ from the name
        usedVars = strrep(usedVars, 'SC_', '');
        
        % FOLGENDER TEIL UMSCHREIBEN -> NASTY CODE!
        if((cell2mat(strfind(usedVars(i), '_in')) + 2) == length(cell2mat(usedVars(i))))
            fprintf('SC_%s... ', cell2mat(usedVars(i)));
            % get the name of the staircase
            scName = strrep(usedVars(i), '_in', '');
            scCorrect = true;
            scOutput = 'Please check the following variable(s): ';
            % check _out
            if isempty(cell2mat(strfind(usedVars, [cell2mat(scName), '_out'])))
                scCorrect = false;
                scOutput = [scOutput, ' SC_', cell2mat(scName), '_out'];
            end
            % check _index
            if isempty(cell2mat(strfind(usedVars, [cell2mat(scName), '_index'])))
                scCorrect = false;
                scOutput = [scOutput, ' SC_', cell2mat(scName), '_index']; 
            end
            % output
            if scCorrect
                fprintf('ok\n');
            else
                fprintf('failed! %s\n', scOutput);
            end
            flagList.(['SC_', cell2mat(usedVars(i))]) = scCorrect;
            
        elseif((cell2mat(strfind(usedVars(i), '_out')) + 3) == length(cell2mat(usedVars(i))))
            fprintf('SC_%s... ', cell2mat(usedVars(i)));
            % get the name of the staircase
            scName = strrep(usedVars(i), '_out', '');
            scCorrect = true;
            scOutput = 'Please check the following variable(s): ';
            % check _out
            if isempty(cell2mat(strfind(usedVars, [cell2mat(scName), '_in'])))
                scCorrect = false;
                scOutput = [scOutput, ' SC_', cell2mat(scName), '_in'];
            end
            % check _index
            if isempty(cell2mat(strfind(usedVars, [cell2mat(scName), '_index'])))
                scCorrect = false;
                scOutput = [scOutput, ' SC_', cell2mat(scName), '_index']; 
            end
            % output
            if scCorrect
                fprintf('ok\n');
            else
                fprintf('failed! %s\n', scOutput);
            end
            flagList.(['SC_', cell2mat(usedVars(i))]) = scCorrect;
            
        elseif((cell2mat(strfind(usedVars(i), '_index')) + 5) == length(cell2mat(usedVars(i))))
            fprintf('SC_%s... ', cell2mat(usedVars(i)));
            % get the name of the staircase
            scName = strrep(usedVars(i), '_index', '');
            scCorrect = true;
            scOutput = 'Please check the following variable(s): ';
            % check _out
            if isempty(cell2mat(strfind(usedVars, [cell2mat(scName), '_in'])))
                scCorrect = false;
                scOutput = [scOutput, ' SC_', cell2mat(scName), '_in'];
            end
            % check _index
            if isempty(cell2mat(strfind(usedVars, [cell2mat(scName), '_out'])))
                scCorrect = false;
                scOutput = [scOutput, ' SC_', cell2mat(scName), '_out']; 
            end
            % output
            if scCorrect
                fprintf('ok\n');
            else
                fprintf('failed! %s\n', scOutput);
            end
            flagList.(['SC_', cell2mat(usedVars(i))]) = scCorrect;
        else
            fprintf('SC_%s... failed!\n##### ERROR! Please use only SC_<scname>_in, SC_<scname>_out and SC_<scname>_index\n', cell2mat(usedVars(i)));
            %disp(usedVars(i));
            flagList.(['SC_', cell2mat(usedVars(i))]) = false;
        end
        
    end
else
    fprintf('\n# No SC_variables defined.\n');
end



% Überprüfen der definierten Augenpositionsparamter
if (cell2mat(strfind(trialCodec, 'EYE_')))
    fprintf('\n# EYE_variables defined.\n');
    if find(ismember(trialCodec, 'EYE_sample_time'))
        flagList = LOCAL_checkDefinitionBlock(flagList, trialCodec, '/Volumes/cnl/mWorks/MatLab/readData/variable_definitions/EYEdefinitions.txt');
    else
        fprintf('EYE_sample_time... failed!\n##### FATAL ERROR! You collect eyepositions without saving the sampe time!\n');
        error('Please check your experiment file for the errors above!');
    end
else
    fprintf('\n# No EYE_variables defined.\n');
    if find(ismember(trialCodec, 'TRIAL_fixate'))
        fprintf('TRIAL_fixate... failed! Please remove TRIAL_fixate from your experiment.\n');
        flagList.TRIAL_fixate = false;
    end
end



% Überprüfen der definierten Touchscreenparameter
if (cell2mat(strfind(trialCodec, 'TOUCH_')))
    fprintf('\n# TOUCH_variables defined.\n');
    flagList = LOCAL_checkDefinitionBlock(flagList, trialCodec, '/Volumes/cnl/mWorks/MatLab/readData/variable_definitions/TOUCHdefinitions.txt');
else
    fprintf('\n# No TOUCH_variables defined.\n');
end




% Überprüfen der definierten IOparameter
if (cell2mat(strfind(trialCodec, 'IO_')))
    fprintf('\n# IO_variables defined.\n');
    flagList = LOCAL_checkDefinitionBlock(flagList, trialCodec, '/Volumes/cnl/mWorks/MatLab/readData/variable_definitions/IOdefinitions.txt');
else
    fprintf('\n# No IO_variables defined... serious?\n');
end



end

% CHECK AUF UNDEFINIERTE VARIABLEN!!!




% Check the variable definition of the the codecs using a defintionfile...
function flagList = LOCAL_checkDefinitionBlock(flagList, trialCodec, definitionsfile)
if exist(definitionsfile, 'file')
    eyeDefintions = importdata(definitionsfile);
    
    % Create a list of all used XXX_vars
    usedVars = trialCodec(find(strncmp([trialCodec], cell2mat(eyeDefintions(1)), length(cell2mat(eyeDefintions(1))))));
    % Create a list of all defined XXX_vars
    defVars = {};
    for i=1:size(eyeDefintions,1)
        if (mod(i,2) == 0) defVars{(i/2)} = cell2mat(eyeDefintions(i)); end
    end

    % Check for used undefined variables
    for (i=1:length(usedVars))
        if ~(ismember(usedVars(i),defVars))
            fprintf('Warning: %s is not an official variable!\n', cell2mat(usedVars(i)));
            flagList.(cell2mat(usedVars(i))) = false;
        end
    end 
    
    i = 1;
    while (size(eyeDefintions,1) > (i+1));
        i = i+2;
        
        checkCodec = cell2mat(eyeDefintions(i-1));
        
        if (cell2mat(strfind(trialCodec, checkCodec)))
            fprintf('%s... ', checkCodec);
            exprString = cell2mat(eyeDefintions(i));
            logicCodecs = textscan(regexprep(exprString, '([ ( ) & | ~ > < ])', ' '), '%s');
            
            % Create & fill the "logical" codecs
            for j=1:size(logicCodecs{1},1)
                exprString = strrep(exprString, logicCodecs{1}{j}, num2str(ismember(logicCodecs{1}{j}, trialCodec)));
            end
            clear j;
            
            try
                tempResult = eval(exprString);
            catch
                fprintf('failed\n##### FATAL ERROR! Please check this entry in the definition-check-file: (%s)\n', cell2mat(eyeDefintions(i)));
                error('Please check your experiment file for the errors above!');
            end
            if tempResult
                fprintf('ok\n');
                if ~(any(strcmp(checkCodec, fieldnames(flagList))))
                    flagList.(checkCodec) = true;
                end
            else
                fprintf('failed! Please check: ');
                % Generate informative output
                j = size(logicCodecs{1},1);
                while j > 0
                    if (length(find(strcmp(logicCodecs{1}, logicCodecs{1}(j)))) > 1)
                        logicCodecs{1}(j) = [];
                    end
                    j = j-1;
                end
                for j=1:size(logicCodecs{1},1)
                    fprintf('%s ', cell2mat(logicCodecs{1}(j)));
                end
                fprintf('\n');
                flagList.(checkCodec) = false;
                clear j;
            end
            clear tempResult exprString logicCodecs;
        end
    end
    clear i checkCodec eyeDefintions;
    
else
    error('Can not find the variables definition file: %s!', definitionsfile);
end

end
