% this script tests the import routines
% IT IS NOT USEFUL IN GENERAL, as it makes assumptions about what data is
% in the plx file.
disp('This sample .m script requires customization to work properly!');

% Open a plx file
% this will bring up the file-open dialog
StartingFileName = './../PlexonTest101.plx';
%StartingFileName = 'C:\PlexonData\CM_Quickstart.plx';
[OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreThresh, SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, DateTime] = plx_information(StartingFileName);

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
[tscounts, wfcounts, evcounts, slowcounts] = plx_info(OpenedFileName,1);

% tscounts, wfcounts are indexed by (channel+1,unit+1)
% tscounts(:,ch+1) is the per-unit counts for channel ch
% sum( tscounts(:,ch+1) ) is the total wfs for channel ch (all units)
% [nunits, nchannels+1] = size( tscounts )
% To get number of nonzero units/channels, use nnz() function

% get some strobed timestamps
[nev, evts, evsv] = plx_event_ts(OpenedFileName, 257);
if nev > 0 
    [nCoords, nDim, nVTMode, c] = plx_vt_interpret(evts, evsv);
    disp('VT data is interpreted.');
end

% get some timestamps for channel 1 unit a
[nts, ts] = plx_ts(OpenedFileName, 1, 1);
[nwf, npw, tswf, waves] = plx_waves(OpenedFileName, 1, 1);
if nwf > 0
    plot( waves(1,1:NPW));
end

% get some other info about the spike channels
[nspkfilters,spk_filters] = plx_chan_filters(OpenedFileName);
[nspkgains,spk_gains] = plx_chan_gains(OpenedFileName);
[nspkthresh,spk_threshs] = plx_chan_thresholds(OpenedFileName);

% get some strobed timestamps
%[nev, evts, evsv] = plx_event_ts(OpenedFileName, 257);
% get some non-strobed timestamps
% [nev, evts, evsv] = plx_event_ts(OpenedFileName, 2);
% 
% % get some a/d data
% [adfreq, nad, tsad, fnad, ad] = plx_ad(OpenedFileName, 1);
% if nad > 0
%     plot( ad );
% end
% 
% % get just a span of a/d data
% [adfreq, nadspan, adspan] = plx_ad_span(OpenedFileName, 1, 10,100);
% 
% [nadfreqs,adfreqs] = plx_adchan_freqs(OpenedFileName);
% [nadgains,adgains] = plx_adchan_gains(OpenedFileName);
close all

evsv = evsv(1:2000);
evts = evts(1:2000);
figure(1)
hold on
figure(2)
hold on
intrial = false;
trialnum = 0;
i=0;
while trialnum < 100
    i=i+1;
    if bitshift(bitand(evsv(i),uint16(15360)),-10) == 1 && bitand(evsv(i),uint16(1023)) > 1
        intrial = true;
        trialnum = bitand(evsv(i),uint16(1023));
    end
    if intrial && bitshift(bitand(evsv(i),uint16(15360)),-10) == 2
        align_time = evts(i);
    end
    if intrial && bitshift(bitand(evsv(i),uint16(15360)),-10) == 14
        start_time = evts(i);
    end
    if intrial && bitshift(bitand(evsv(i),uint16(15360)),-10) == 15
        end_time = evts(i);
    end
    if intrial && bitshift(bitand(evsv(i),uint16(15360)),-10) == 3
        intrial = false;
        spikes = find(ts>start_time & ts<end_time);
        figure(1)
        plot(repmat(trialnum,length(spikes),1),ts(spikes)-align_time,'.b')
        plot(trialnum,start_time-align_time,'*g')
        plot(trialnum,end_time-align_time,'*k')
        disp(['Trial ' int2str(trialnum) ' : ' num2str(length(spikes)/(end_time-start_time)) ' sp/s'])
        figure(2)
        plot(trialnum,length(spikes)/(end_time-start_time),'*r')
    end
end
figure(1)
xlabel('Trial')
ylabel('Spike Times [s]')


addpath('/Library/Application Support/MWorks/Scripting/Matlab')
codecs=getCodecs('./../PlexonTest101.mwk');

trialstarts = getEvents('./../PlexonTest101.mwk',codec_tag2code(codecs.codec, 'ML_trialStart'));
trialends = getEvents('./../PlexonTest101.mwk',codec_tag2code(codecs.codec, 'ML_trialEnd'));
spikes_per_second = getEvents('./../PlexonTest101.mwk',codec_tag2code(codecs.codec, 'SPIKE_spikes_per_second'));

intrial = false;
trialnum = 0;
i=0;
while trialnum < 99
    i=i+1;
    if trialstarts(i).data > 1
        intrial = true;
        trialnum = trialstarts(i).data;
        starttime = trialstarts(i).time_us;
    end
    if intrial && trialends(i).time_us > starttime
        intrial = false;
        endtime = trialends(i).time_us;
        sps = spikes_per_second(find([spikes_per_second.time_us]>starttime & [spikes_per_second.time_us]<endtime)).data;
        figure(2)
        plot(trialnum,sps,'db')
    end
end

xlabel('Trial')
ylabel('sp/s')
title('sp/s within time-frame; red: Plexon; blue: MWorks')

