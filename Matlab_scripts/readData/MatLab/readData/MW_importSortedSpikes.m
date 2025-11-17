function [answer] = MW_importSortedSpikes(mwkFileName, plxFileName)
% function [answer] = MW_importSortedSpikes(mwkFileName, plxFileName)
% FIRST BETA-VERSION! Be aware! The last (strobeVariableName)  parameter
% will not be used in the very very near future!

% RALF: parameter f?r PERCENTOF_CONNECTED_VALUES angeben
% RALF: parameter f?r Namen des IO_16bitOut angeben
% RALF: erste Parameter -> mwkFileName, plxFileName, MW_STROBE_NAME

eventdata = [];


% Als erstes ?berpr?fen ob beide Dateien vorhanden sind
% EINF?GEN

% Pfade f?r die wichtigen Tollboxen/Skripte
addpath(genpath('~/Documents/MWorks/MatLab/readData/helperFunctions/plexonOfflineSDK/'));
addpath(genpath('/Library/Application Support/MWorks/Scripting/Matlab/'));

PERCENT_ASSIGNABLE_VALUES = 50;

% AMR
% MW_STROBE_NAME = 'IO_16bitOut'; 
% mwkFileName = '20150522_sun_u1.mwk';
% plxFileName = 'SORTED-20150522-sun-u1-02.plx';

% CLIO
% MW_STROBE_NAME = 'IO_16bitOut'; 
% mwk = 'clq-ftest-sun-001-01+1.mwk';
% plx = 'clq-ftest-sun-001-01+1.plx';
% MW_STROBE_NAME = 'IO_16bitOut'; 
% mwk = 'sun_test_150407.mwk';
% plx = 'sun_test_150407.plx';

% ANTONIO
% MW_STROBE_NAME = 'SPIKE_plexon_word';
% mwk = 'igg_20150401_1708_physio1_MTS_9_1_task.mwk';
% plx = 'igg_20150401_1708_physio1_MTS_9_1_task_sorted.plx';
% MW_STROBE_NAME = 'SPIKE_plexon_word';
% mwk = 'igg_20150504_1625_physio1_MTS_9_4_task.mwk';
% plx = 'igg_20150504_1630_physio1_MTS_9_4_task_sorted.plx';

% PHIL
% MW_STROBE_NAME = 'SPIKE_plexon_word';
% mwk = 'edg_20150604_u1.mwk';
% plx = 'edg_20150604_u1-resorted.plx';



disp('##### Open the plexon file... #####');
[OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreThresh, SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, DateTime] = plx_information(plxFileName);

disp(['Opened File Name: ' OpenedFileName]);
disp(['Version: ' num2str(Version)]);
disp(['Frequency : ' num2str(Freq)]);
disp(['Comment : ' Comment]);
disp(['Date/Time : ' DateTime]);
disp(['Duration : ' num2str(Duration)]);
disp(['Num Pts Per Wave : ' num2str(NPW)]);
disp(['Num Pts Pre-Threshold : ' num2str(PreThresh)]);
% some of the information is only filled if the plx file version is >102
if ( Version > 102 )
    if ( Trodalness < 2 )
        disp('Data type : Single Electrode');
    elseif ( Trodalness == 2 )
        disp('Data type : Stereotrode');
    elseif ( Trodalness == 4 )
        disp('Data type : Tetrode');
    else
        disp('Data type : Unknown');
    end
        
    disp(['Spike Peak Voltage (mV) : ' num2str(SpikePeakV)]);
    disp(['Spike A/D Resolution (bits) : ' num2str(SpikeADResBits)]);
    disp(['Slow A/D Peak Voltage (mV) : ' num2str(SlowPeakV)]);
    disp(['Slow A/D Resolution (bits) : ' num2str(SlowADResBits)]);
end   



% get some counts
[tscounts, ~, ~, ~] = plx_info(OpenedFileName,1);


% read the strobes
% STROBE CHANNEL KANN SICH U.U. ?NDERN BEIm OFFLINESORTEN? NACHPR?FEN!
STROBE_CHANNEL = 257;                       % strobe channel
[~, ts_trialstart, val_trialstart] = plx_event_ts(OpenedFileName, STROBE_CHANNEL);


% Sometimes the plexon strobes are negativ.. we must check why.
for (cx = 1:length(val_trialstart))
    if (val_trialstart(cx) < 0)
        val_trialstart(cx) =  val_trialstart(cx) + bin2dec('1000000000000000');
    end
end



% ########### READ AND CHECK THE MWK-FILE
disp('##### Reading MWK and sorting strobes, this might take a while #####')
codecs = getCodecs(mwkFileName);
codecs=codecs(1);
try
    MW_STROBE_NAME = 'IO_16bitOut';
    mw_trialstarts = getEvents(mwkFileName,codec_tag2code(codecs.codec,MW_STROBE_NAME));
catch
    try
        MW_STROBE_NAME = 'SPIKE_plexon_word';
        mw_trialstarts = getEvents(mwkFileName,codec_tag2code(codecs.codec,MW_STROBE_NAME));
    catch
        disp('Your variable in which you use in the Omniplex-PlugIn has an unknown name :-o');
    end
end

% ----------- CHECK THE MWK STROBE EVENTS AND DELETE NON-STROBES
% RALF: ATTENTION - we must also check for the RSTART-bit here!!
temp = [];
strobedFlag = 0;
for cx = 1:length(mw_trialstarts)
	if (bitand(mw_trialstarts(cx).data, bin2dec('1000000000000000'))) && ~(strobedFlag)
        strobedFlag = 1;
        temp(cx) = 1;
        mw_trialstarts(cx).data = bitand(mw_trialstarts(cx).data, bin2dec('11111111111111'));
    elseif ~(bitand(mw_trialstarts(cx).data, bin2dec('1000000000000000')))
        strobedFlag = 0;
    else
        disp(['found stupid strobe @ ' num2str(cx)]);
    end
end
mw_trialstarts = mw_trialstarts(temp==1);
% ----------- END
clear MW_STROBE_NAME temp;
% ########### END




% ########## SEARCH FOR THE BEST ASSIGNMENT MWK <=> PLX
goodValList = struct('mwkCX', 0, 'plxCX', 0, 'quality', 0);
gvlCX = 1;
exitFlag = false;
%dispPercentage = 0;
disp('##### Checking permutations #####');
fprintf('Calculating...   0%');
for mwkDX = 1:length(mw_trialstarts)
    if ~exitFlag
        for plxDX= 1:length(val_trialstart)
            
            if (val_trialstart(plxDX) == mw_trialstarts(mwkDX).data) && ~exitFlag
                
                goodValList(gvlCX).mwkCX = mwkDX;
                goodValList(gvlCX).plxCX = plxDX;
                
                % -------- ERSTELLEN VON ZWEI TIMEPERIODLISTEN F?R PLX UND MWK
                mwkList = struct('val', 0, 'per', 1.1);
                plxList = struct('val', 0, 'per', 1.1);
                
                temp=[];
                cx = length(mw_trialstarts);
                while cx > mwkDX
                    mwkList(cx).val = mw_trialstarts(cx).data;
                    mwkList(cx).per = double(mw_trialstarts(cx).time_us - mw_trialstarts(cx-1).time_us)/10^5;
                    if cx >= mwkDX
                        temp(cx) = 1;
                    end
                    cx = cx-1;
                end
                mwkList(cx).val = mw_trialstarts(cx).data;
                temp(cx) = 1;
                mwkList = mwkList(temp==1);
                mwkList(1).per = 0;
                
                temp = [];
                cx = length(val_trialstart);
                while cx > plxDX
                    plxList(cx).val = val_trialstart(cx);
                    plxList(cx).per = (ts_trialstart(cx) - ts_trialstart(cx-1))*10^1;
                    if cx >= plxDX
                        temp(cx) = 1;
                    end
                    cx = cx-1;
                end
                plxList(cx).val = val_trialstart(cx);
                temp(cx) = 1;
                plxList = plxList(temp==1);
                plxList(1).per = 0;
                % ---------- END
                
                
                % ---------- COUNT POSSIBLE ASSIGNMENTS
                assignCX = 1;
                exitFlag = false;  % if the fit is good enough we jump out of the loop
                mwkCX = 2;         % We start with the second values in the list - the first ones already fit
                plxCX = 2;
                
                while (mwkCX < length(mwkList)) && (plxCX < length(plxList))  
                    % time ok?
                    if abs(mwkList(mwkCX).per - plxList(plxCX).per) < 1
                        % value ok?
                        if mwkList(mwkCX).val == plxList(plxCX).val
                            % both ok, perfect. Increment counter and jump the next two values
                            mwkCX = mwkCX+1;
                            plxCX = plxCX+1;
                            assignCX = assignCX+1;
                        else
                            %  value is wrong. We should now go the smallest time step forward.
                            if (mwkList(mwkCX).per + mwkList(mwkCX+1).per) <= (plxList(plxCX).per + plxList(plxCX+1).per)
                                mwkList(mwkCX+1).per = mwkList(mwkCX).per + mwkList(mwkCX+1).per;
                                mwkCX = mwkCX+1;
                            else
                                plxList(plxCX+1).per = plxList(plxCX).per + plxList(plxCX+1).per;
                                plxCX = plxCX+1;
                            end
                        end
                    else
                        % time dos not fit. We should now go the smallest time step forward.
                        if (mwkList(mwkCX).per + mwkList(mwkCX+1).per) <= (plxList(plxCX).per + plxList(plxCX+1).per)
                            mwkList(mwkCX+1).per = mwkList(mwkCX).per + mwkList(mwkCX+1).per;
                            mwkCX = mwkCX+1;
                        else
                            plxList(plxCX+1).per = plxList(plxCX).per + plxList(plxCX+1).per;
                            plxCX = plxCX+1;
                        end
                    end
                end
                % ---------- END
                
                % ---------- ADD THE PARAMETERS (CX: MWK, PLX, ASSIGN) TO THE GOODVALUELIST AND CHECK LEAVE THE LOOP
                goodValList(gvlCX).quality = assignCX;
                percentOK = assignCX*100/min(length(mwkList), length(plxList));
                if (percentOK > PERCENT_ASSIGNABLE_VALUES) && (min(length(mwkList), length(plxList)) > 200)
                    exitFlag = true;
                    fprintf('\n');
                    disp(['Found more (' num2str(percentOK) '%) then ' num2str(PERCENT_ASSIGNABLE_VALUES) '% assignable values. Stop searching...']);
                end
                gvlCX = gvlCX+1;
                % ---------- END
                
            end
        end
        if ~exitFlag
            fprintf('%c%c%c%c%3d%%', 8, 8, 8, 8, floor(((length(mw_trialstarts)-(mwkDX/2))*mwkDX*100)/(length(mw_trialstarts)^2/2)));
        end
    end
end

if length(goodValList) > 1
    goodValList = goodValList([goodValList.quality] == max([goodValList.quality]));
end
% At the first position of the goodValList ist the best combination
fprintf('\n');
disp(['Best match (' num2str(goodValList.quality) ' values) @' num2str(goodValList.mwkCX) ':' num2str(goodValList.plxCX) ' (mwk:plx)']);
clear glvCX temp;
% ########## END



% ########### GRAB THE BEST COMBINATION AND MODIFY THE MWK - AND PLX-STROBELIST
mwkDX = goodValList.mwkCX;
plxDX = goodValList.plxCX;
            
% -------- ERSTELLEN VON ZWEI TIMEPERIODLISTEN F?R PLX UND MWK
mwkList = struct('val', 0, 'per', 1.1);
plxList = struct('val', 0, 'per', 1.1);

temp = [];
cx = length(mw_trialstarts);
while cx > mwkDX
    mwkList(cx).val = mw_trialstarts(cx).data;
    mwkList(cx).per = double(mw_trialstarts(cx).time_us - mw_trialstarts(cx-1).time_us)/10^5;
    if cx >= mwkDX
        temp(cx) = 1;
    end
    cx = cx-1;
end
mwkList(cx).val = mw_trialstarts(cx).data;
temp(cx) = 1;
mwkList = mwkList(temp==1);
mwkList(1).per = 0;

temp = [];
cx = length(val_trialstart);
while cx > plxDX
    plxList(cx).val = val_trialstart(cx);
    plxList(cx).per = (ts_trialstart(cx) - ts_trialstart(cx-1))*10^1;
    if cx >= plxDX
        temp(cx) = 1;
    end
    cx = cx-1;
end
plxList(cx).val = val_trialstart(cx);
temp(cx) = 1;
plxList = plxList(temp==1);
plxList(1).per = 0;
% ---------- END


% ---------- CREATE DELETE-LISTS
mwkDelList(goodValList.mwkCX) = 1;
plxDelList(goodValList.plxCX) = 1;
mwkCX = 2;         % We start with the second values in the list - the first ones already fit
plxCX = 2;


while (mwkCX <= length(mwkList)) && (plxCX <= length(plxList))
    % time ok?
    if abs(mwkList(mwkCX).per - plxList(plxCX).per) < 1
        % value ok?
        if mwkList(mwkCX).val == plxList(plxCX).val
            % both ok, perfect. Increment counter and jump the next two values
            mwkDelList(mwkDX+mwkCX-1) = 1;
            plxDelList(plxDX+plxCX-1) = 1;
            mwkCX = mwkCX+1;
            plxCX = plxCX+1;
        else
            %  value is wrong. We should now go the smallest time step forward.
            if ~((mwkCX == length(mwkList)) || (plxCX == length(plxList)))
                if (mwkList(mwkCX).per + mwkList(mwkCX+1).per) <= (plxList(plxCX).per + plxList(plxCX+1).per)
                    mwkList(mwkCX+1).per = mwkList(mwkCX).per + mwkList(mwkCX+1).per;
                    mwkCX = mwkCX+1;
                else
                    plxList(plxCX+1).per = plxList(plxCX).per + plxList(plxCX+1).per;
                    plxCX = plxCX+1;
                end
            else
                % increase for exit the loop
                plxCX = plxCX+1;
                mwkCX = mwkCX+1;
            end
        end
    else
        % time dos not fit. We should now go the smallest time step forward.
        if ~((mwkCX == length(mwkList)) || (plxCX == length(plxList)))
            if (mwkList(mwkCX).per + mwkList(mwkCX+1).per) <= (plxList(plxCX).per + plxList(plxCX+1).per)
                mwkList(mwkCX+1).per = mwkList(mwkCX).per + mwkList(mwkCX+1).per;
                mwkCX = mwkCX+1;
            else
                plxList(plxCX+1).per = plxList(plxCX).per + plxList(plxCX+1).per;
                plxCX = plxCX+1;
            end
        else
            mwkCX = mwkCX+1;
            plxCX = plxCX+1;
        end
    end
end
% ---------- END

% Modify the three "real" strobe lists...
mw_trialstarts = mw_trialstarts(mwkDelList == 1);
ts_trialstart = ts_trialstart(plxDelList == 1);
val_trialstart = val_trialstart(plxDelList == 1);

clear mwkDelList plxDelList mwkCX plxCX mwkDX plxDX plxList mwkList goodValList temp;
% ########### END




% now calculate the syncronization using a fit
% ########### CALCULATING GAIN & OFFSET
PF = fittype('syncPLXoverMWtoPLX(x,xval,yval,a,b)','problem',{'xval' 'yval'});
paramsGuess = [1000000 mw_trialstarts(1).time_us]; % WAR paramsGuess = [1000000 mw_trialstarts(1).time_us];
foptions = fitoptions('Method','NonLinearLeastSquares','StartPoint',paramsGuess,'MaxIter',5000,'Robust','on');

disp('###### Calculating Syncronization (gain & offset) #####');
fit_res = fit(ts_trialstart,ts_trialstart,PF,foptions,'problem',{val_trialstart mw_trialstarts});
plxTime_to_mwTime = coeffvalues(fit_res);


if 1==1
% GRAFIK OUTPUT
temp = []; % contains diffs in micro seconds;
for cx = 1:length(ts_trialstart)
    temp(cx) = (plxTime_to_mwTime(1) * ts_trialstart(cx) + plxTime_to_mwTime(2)) - mw_trialstarts(cx).time_us;
end
plot(temp);
clear temp;
% ########## END
end


% ########## READ AND RESORT THE SPIKES
disp('###### Getting spikes from plx file ######')
[nunits1, nchannels1] = size( tscounts );   

% get some other info about the spike channels
[~,~] = plx_chan_filters(OpenedFileName);
[~,spk_gains] = plx_chan_gains(OpenedFileName);
[~,spk_threshs] = plx_chan_thresholds(OpenedFileName);
[~,spk_names] = plx_chan_names(OpenedFileName);
allts = cell(nunits1-1, nchannels1);
units = [];
for iunit = 1:nunits1-1   % ignore unsorted
    for ich = 1:nchannels1-1
        if ( tscounts( iunit+1 , ich+1 ) > 0 )
            % get the timestamps for this channel and unit 
            [nts, allts{iunit,ich}] = plx_ts(OpenedFileName, ich , iunit );
            fprintf('Found a unit with number %d on channel %s:\n',iunit,spk_names(ich,:))
            fprintf('%d spikes with gain of %d and threshold %d\n',nts,spk_gains(ich),spk_threshs(ich))
            units(:,size(units,2)+1)=[iunit ich];
         end
    end
end


% HIER FOLGT DANN DIE EINSORTIERUNG
% finally, make the MW Struct
% event_code = codec_tag2code(codecs.codec,'SPIKE_spikes');
% 
% eventdata = struct([]);
% for i=1:size(units,2)
%     eventdata = [eventdata ; ...
%         struct('event_code',{event_code},...
%             'time_us',num2cell(plxTime_to_mwTime(1).*allts{units(1,i),units(2,i)}+plxTime_to_mwTime(2)),...
%             'data',{units(2,i)+units(1,i)/10}) ];
% end


osSpikes = struct('time', 0, 'data', 1.1);
for i=1:size(units,2)
    osSpikes = [osSpikes ; struct('time',  num2cell(int64(plxTime_to_mwTime(1) * allts{units(1,i),units(2,i)}+plxTime_to_mwTime(2))),...
        'data',{units(2,i)+units(1,i)/10}) ];
end

    
[~, order] = sort([osSpikes(:).time],'ascend');
% if any(diff(order) ~= 1)
%     disp('Event sorting was necessary .. Done. <<')
% else
%     disp('Event sorting was not necessary. <<')
% end
osSpikes = osSpikes(order);

disp('###### Save the spikes ######');
save(sprintf('%s/ml_spikes_v1.mat', mwkFileName), 'osSpikes');
% ########## END

answer = 0;
disp('***** Done *****');