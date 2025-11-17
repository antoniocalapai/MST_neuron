function [expParam, trialParam] = MW_readExperiment(filename, varargin)
% function [expParam, trialParam] = MW_readExperiment(fileName, varargin)
%
% FILENAME: path and filename of mwk file.
%
% VARARGIN are only for debugging. Please use them only if Philipp or I
% told you so:
%	'~EYE': no eye positions
%	'~PHASE': no phase data
%	'~IO' : no IOs
%   '~SPIKE': no spikes
%   '~SC' : no staircases
%   '~SHRINKPHASE' : Phasedata stay untouched
%   'ALL' : read all data/variables
%   'trials' : [firstTrial lastTrial] <= Not implemented yet!
%
% This function read a mWork data file and sort & save the data in a MatLab
% structure. A description of the MatLab structure will be added to the
% WIKI in the near future.
%
% When you use any of the VARARGINs the data will not be stored in the data
% folder. That mean, that the next time when you open the data file, it
% must be sorted and imported again (which could take some minutes(*10)).
% Please use VARARGINs only, when Philipp or I told you so!
%
% The function also find broken trials and do not import them into the 
% MatLab structure. The definition of a broken trial is
%	- ML_trialStart.data ~= ML_trialEnd.data
%	- The length ot the trial is less then 10ms
%	- ML_trialStart.data == 0
%
% In the case of two (or more) ML_trialStart in a row, the function uses
% the last one. In case of two (or more) ML_trialEnd it uses the first one.
%
% The function only import the data of the aproved parameter, defined in
% http://wiki.dpz.lokal/doku.php?id=mworks:xml:parameter_names
%
%
% Known bugs in this version:
%	- If the type of VAR_name.data is a string, the data is not usable.
%	- In some rare cases, (when you copy the data file with a windows
%     computer) the date in EXP_date could be wrong.
%	- The error checking function (which tells you, if the variable
%     definitions of the experiment and the use of the variables is
%     correct) is not implemented in this version.
%	- '~' in the path is not supported.
%   - No check of MatLab version (must be >= 2011a)
%
% Changes in this version
%   - Parallel pool will only start wenn we "import" the raw data file, not
%     when we only read the MatLab-structure
%   - Import of offline sorted spikes
%
% rbrockhausen@dpz.eu, June 2015





tic
% ----- Check if the datafile is not in a folder with the same name -------
% Create the full path
if (filename(1) ~= '/')
    filename = [pwd '/' filename];
end

% Extract path & filename
[~,f_name,f_ext] = fileparts(filename);

% Check if the file is a folder (with the same name and fix it
while isdir([filename '/' f_name f_ext])
    copyfile([filename '/' f_name f_ext '/' f_name f_ext], [filename '/temp.mwk']);
    rmdir([filename '/' f_name f_ext], 's');
    movefile([filename '/temp.mwk'], [filename '/' f_name f_ext]);
    if exist([filename '/' f_name f_ext '.idx'], 'file')
        delete([filename '/' f_name f_ext '.idx']);
        delete([filename '/' 'ml_data_v*.mat']);
    end
    fprintf('WARNING: Fixed an error in the directory structure of the datafile (file in folder in folder).\n');
end



% ----- Check if the datafile is already imported -------------------------
try
    % Wenn parameter angelesen immmer importen!!!!
    if size(varargin,2) > 0
        load([filename '/' 'nodata']);
    else
        load([filename '/' 'ml_data_v2']);
    end
catch   

% ----- Start the parallel toolbox, if possible ---------------------------
% The first call of a function of the parallel toolbox normally causes an
% error and the script stops. This is an easy method to prevent this
% unloved crash of the script.
    try
        parfor i=1:2
        end
        % RAB HIER EINBAUEN OB MEHR ALS EIN PROC BENUTZT WIRD UND HINWEIS AUSGEBEN
        fprintf('(Please note that displaying of dots does not work when working on multiple processors, just hang on..) \n');
    end

    
versionStr = 'MW_readExperiment 2.2 (2015-06-22)'; %RAB HIER AENDERUNG EINFUEGEN DIREKT VOR DEM UPLOAD!



% ##### Ceck for optional parameters
% Default values
includeEYE = 1;
includePHASE = 1;
includeIO = 1;
includeSPIKE = 1;
includeSC = 1;
includeTOUCH = 1;
removeDoublePhaseData = 1;
includeALL = 0;
printWarning = true;

for i= 1 : size(varargin,2)
    if (ischar(varargin{i}))
        %fprintf('     %s\n', varargin{i});
        switch varargin{i}
            case '~EYE'
                includeEYE = 0;
                fprintf('no eye positions; ');
            case '~PHASE'
                includePHASE = 0;
                fprintf('no phase data; ');
            case '~IO'
                includeIO = 0;
                fprintf('no IOs; ');
            case '~SPIKE'
                includeSPIKE = 0;
                fprintf('no spikes; ');
            case '~SC'
                includeSC = 0;
                fprintf('no staircases; ');
            case 'ALL'
                includeALL = 1;
            case '~SHRINKPHASE'
                removeDoublePhaseData = 0;
                fprintf('no shrink phase data; ');
            case 'trials'
                printWarning = false;
                % LESE trial und vargin +1 als daten
            otherwise
                if printWarning
                    disp('WARNING: Unknown input argument *', varargin{i}, '*!');
                end
                printWarning = true;
        end
    elseif(isnumeric(varargin{i}))
        fprintf('     %d\n', varargin{i});
    end
end



%% ----- read the codecs --------------------------------------------------

addpath('/Library/Application Support/MWorks/Scripting/Matlab')

fprintf('\n\n##### %s\n', filename);
fprintf('# Indexing the datafile... this could take a while :-(\n');
% Get Codecs and clear private stuff...
codecs=getCodecs(filename);
codecs=codecs(1);
fprintf('# Check codecs\n');

% RAB HERE INSERT CLEANING AND WARNINGS

idi = false(1,length(codecs.codec));
idi = or(idi,cellfun(@(x)strcmp(x,'ML_trialStart'),{codecs.codec.tagname}));
idi = or(idi,cellfun(@(x)strcmp(x,'ML_trialEnd'),{codecs.codec.tagname}));
idi = or(idi,cellfun(@(x)strcmp(x,'TRIAL_fixate'),{codecs.codec.tagname}));
idi = or(idi,cellfun(@(x)strcmp(x,'TRIAL_outcome'),{codecs.codec.tagname}));


ido = false(1,length(codecs.codec));
if includeEYE 
    idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'EYE_','start','once')));
else
    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'EYE_','start','once')));
end    
if includeIO
    idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'IO_','start','once')));
else
    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'IO_','start','once')));
end
if includeSC
    idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'SC_','start','once')));
else
    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'SC_','start','once')));
end
if includeSPIKE
    idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'SPIKE_','start','once')));
else
    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'SPIKE_','start','once')));
end
if includeTOUCH
    idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'TOUCH_','start','once')));
else
    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'TOUCH_','start','once')));
end
if includePHASE
    idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'#stimDisplayUpdate','start','once')));
else
    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'#stimDisplayUpdate','start','once')));
end

ide = cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'EXP_','start','once'));

if includeALL
    idi = or(idi,xor(~ido,ide));
end

trialCodec = codecs.codec(idi);
expCodec = codecs.codec(ide);

clear includeEYE includeIO includeSPIKE includeSC idi ido ide;

%%

% Start with reading the 'EXP_' variables of the data file
expParam = [];
if ~isempty(expCodec)
events = getEvents(filename, [expCodec(:).code]);
[~, order] = sort([events(:).time_us],'ascend');
events = events(order);
fprintf('# Read & sort %d EXP_events of the datafile...\n', length(events));
for i = 1:length(expCodec)
    indices = find([events(:).event_code] == expCodec(i).code);
    if indices
        expParam.(expCodec(i).tagname) = [{events(indices).data};{events(indices).time_us}];
    else
        expParam.(expCodec(i).tagname) = [];
    end
end
clear order events indices;
end
% set EXP_fileName and dateTime
dirInfo = dir(filename);
if (size(dirInfo,1) > 1)
    dirInfo = dir(strcat(filename, '/*.mwk'));
end


expParam = setfield(expParam, 'EXP_fileName', dirInfo.name);
expParam = setfield(expParam, 'EXP_dateTime', dirInfo.date); %RAB SORGT UNTER BESTIMMTEN UMST?NDEN F?R FALSCHE DATEN :-(


% write version of readMWdata into the expParam struct
try 
    expParam.EXP_version{1,size(expParam.EXP_version,2)+1} = versionStr;
    expParam.EXP_version{2,size(expParam.EXP_version,2)} = 0;
catch
    expParam = setfield(expParam, 'EXP_version', [{versionStr};{0}]);
end

% remove redundant data from the EXP_version parameter
% Delete Initvalues
i = length(expParam.EXP_version(2,:));
while i > 0
    if expParam.EXP_version{1,i} == 0
        expParam.EXP_version(:, i) = [];
    end
    i = i-1;
end
% Doppelte Eintr?ge l?schen
if length(expParam.EXP_version(2,:)) > 1
    i = 0;
    while i < length(expParam.EXP_version(2,:))
        i = i+1;
        j = length(expParam.EXP_version(2,:));
        while j > i
            if strcmp(expParam.EXP_version{1,i}, expParam.EXP_version{1,j})
                expParam.EXP_version(:, j) = [];
            end
            j = j-1;
        end
    end
end



clear dirInfo expCodec versionStr;


% Create trial structure
trialParam = [];
for i = 1:length(trialCodec)
    tagname = trialCodec(i).tagname;
    if tagname(1) == '#'
        tagname = tagname(2:length(tagname));
    end
    trialParam = setfield(trialParam, tagname, []);
end
clear tagname;


fprintf('# Read & sort all the ML_trial events of the datafile...  this could take a while, too :-(\n');
% Get ML_trialStart & ML_trialEnd Events
events = getEvents(filename, [codec_tag2code(trialCodec, 'ML_trialStart') codec_tag2code(trialCodec, 'ML_trialEnd')]);
[~, order] = sort([events(:).time_us],'ascend');
events = events(order);
clear order;


fprintf('# Check for broken trials\n');
% Check start & stops and minimal trial length (> 20)
trialCounter = 0;
insideTrial = false;
lastTrialNumber = 0;
trialStartNumber = 0;

for i = 1:length(events)
    % ----- ML_trialStart -----
    if events(i).event_code == codec_tag2code(trialCodec, 'ML_trialStart')
        %debug fprintf('# %d trialStartValue\n', events(i).data);
        if (events(i).data > 0)
            if insideTrial
                fprintf('WARNING: Two trialStart in a row. Ignore the first one...\n');
            end
            startTime = events(i).time_us;
            trialStartNumber = events(i).data;
            insideTrial = true;
        else
            %debugfprintf('--- ignore trialStart: value ZERO\n');
            insideTrial = false;
        end
        
    % ----- ML_trialEnd -----
    else
        if (insideTrial)
            %debugfprintf('# %d trialEndValue\n', events(i).data);
            if (trialStartNumber ~= events(i).data)
                fprintf('WARNING: trialStart(%d) != trialEnd(%d)! Ignore trial...\n', trialStartNumber, events(i).data);
            else
                if (lastTrialNumber >= trialStartNumber)
                    fprintf('WARNING: trialNumber(n)=%d is less then trialNumber(n-1)=%d in trial %d!\n', trialStartNumber, lastTrialNumber, trialCounter+1);
                end
                % This trial is ok. Save the data...
                trialCounter = trialCounter + 1;
                borders(trialCounter, 1) = startTime;
                borders(trialCounter, 2) = events(i).time_us;
                lastTrialNumber = trialStartNumber;
            end
            insideTrial = false;
        end 
    end
end

clear trialCounter trialStartFlag startTime;

i = 1;
while i <= length(borders(:,2))
    if (borders(i,2) - borders(i,1) <= 10)
        fprintf('Found invalid trial... possible during variable initalisation in the mWorks server (or when you press the stop button).\n', i);
        borders(i,:) = [];
    else 
        i = i + 1;
    end
end


% cx = 0;
fprintf('# Find and copy data to trialStruct (one dot is 10 trials)\n');

% Now we can read all the nice data per trial
parfor trialCounter = 1:length(borders(:,2))
    if mod(trialCounter,10)==0
        fprintf('.');
    end
    events = getEvents(filename, [trialCodec(:).code], borders(trialCounter,1), borders(trialCounter,2));
    [~, order] = sort([events(:).time_us],'ascend');
    events = events(order);
    for i = 1:length(trialCodec)
        indices = find([events(:).event_code] == trialCodec(i).code);
        if indices
            tagname = trialCodec(i).tagname;
            if tagname(1) == '#'
                tagname = tagname(2:length(tagname));
            end
            
            %trialParam(trialCounter).(tagname) = [{events(indices).data}; {events(indices).time_us}];
            try
                trialParam(trialCounter).(tagname).data = cell2mat({events(indices).data});
            catch
                trialParam(trialCounter).(tagname).data = {events(indices).data};
            end
            trialParam(trialCounter).(tagname).time = [events(indices).time_us];
        end
    end
end

clear trialcounter i indices tagname events codecs trialCodec borders cx order;



%% Shrink phase data and delete trials without valid phase data
if includePHASE && removeDoublePhaseData
    fprintf('\n# Shrink the phase data (stimDisplayUpdate) (one dot is 10 trials)\n');
    delIdx = [];
    for trialCX = 1 : length(trialParam)
        if mod(trialCX,10)==0
            fprintf('.');
        end
%rab        fprintf('\n### dataset: %d\n', trialCX);
        trialParam(trialCX).stimDisplayUpdate = MW_shrinkPHASEdata(trialParam(trialCX));
        
        if ~isfield(trialParam(trialCX).stimDisplayUpdate, 'data')
            delIdx = [delIdx trialCX];
        end
        
    end
    trialParam(delIdx) = [];
    fprintf('\n\n');
end




clear includePHASE removeDoublePhaseData includeALL;

if size(varargin, 2) == 0
    save([filename '/' 'ml_data_v2'], 'trialParam', 'expParam','-v7.3');
end

toc
fprintf('\n# Done!\n');

end

% Check for offline sorted spikes...

if isfield(trialParam, 'SPIKE_spikes')
    try
        load([filename '/' 'ml_spikes_v1']);
        disp('ATTENTION: The following code is crapy slow.. I am working on a better solution :-(');
        disp('Read the offline sorted spikes and send them to the single trials...  0%');
        for cx = 1:length(trialParam)
            
            % V?llig schlecht... mir f?llt aber grade die simple L?sung
            % nicht ein - wird sp?ter nachgereicht. Sorry f?r diesen
            % Spagetticode. Wahrscheinlich ist es besser die trialStruct
            % ein zweites mal zu speichern, anstatt die einzeln noch mal
            % einzulesen?

            temp = []; temp2 = [];
            temp = osSpikes([osSpikes(:).time] >= trialParam(cx).ML_trialStart.time(1));
            temp = temp([temp(:).time] <=  trialParam(cx).ML_trialEnd.time(1));
            temp2.time = ([temp(:).time]')';
            temp2.data = ([temp(:).data]')';
            trialParam(cx).SPIKE_spikes = temp2';
                
            fprintf('%c%c%c%c%3d%%', 8, 8, 8, 8, floor((cx*100)/length(trialParam)));

        end
    catch
        disp('WARNING: Do you wanne really use the online sorted spikes?!?');
    end
       
    fprintf('\n*** done ***\n');

end
