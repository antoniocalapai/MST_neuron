function anc_ExtractMultiTuning(directory, mwk, destination)
%% This code PRE process any new session data file contained in the data folder
% acalapai@dpz.eu 2020 MST manuscript
EXP_minimum_spikes_requirred = 1000;
bin_size = 5000;

user = char(java.lang.System.getProperty('user.name'));
warning('OFF', 'MATLAB:table:RowsAddedExistingVars')

% add paths with analysis scripts
addpath(genpath((['/Users/' user '/Dropbox/MST_manuscript/Matlab_scripts'])))
PLOT_path = ['/Users/' user '/Dropbox/MST_manuscript/Plots/MultiTuning/'];
cells_path = destination;

files_mwk = dir([[directory, mwk, '/'] '*uning*']);

%% Extract the combined Probability Map for linear direction and disparity
if ~isempty(files_mwk)
    cd([directory, mwk,'/', files_mwk.name])
    
    if strcmp(mwk(1:3),'anc')
        load('anc_SPIKES.mat')
        % Load units and discard units isolated online
        SPIKES_plexon  = struct('data',[osSpikes.data],'time_us',[osSpikes.time]);
        SPIKES_plexon.time_us(SPIKES_plexon.data < 129) = [];
        SPIKES_plexon.data(SPIKES_plexon.data < 129) = [];
    else
        load('ml_spikes_v1.mat')
        SPIKES_plexon  = struct('data',[osSpikes.data],'time_us',[osSpikes.time]);
    end
    
    load('ml_data_v2.mat') % Load the Experiment parameters for this session
    
    try
        [trialParam.IO_bkohg1_reward] = trialParam.IO_rewardA;
        [trialParam.IO_bkohg1_left]   = trialParam.IO_teensy_reward1;
    end
    
    % Create an index of all the valid units found
    cu = SPIKES_plexon.data;
    cu = unique(cu);
    
    % extract all the probe properties shown in the experiment
    direction_list = []; disparity_list = []; speed_spiral_list = []; speed_linear_list = []; motion_list = [];
    
    % cicle through all the trials and extract relevant information about motion directions
    ntrials = length(trialParam);
    rewarded = [];
    for b = 1:ntrials
        % Use Ralf routine "MW_getStimData"
        motion_list      = [motion_list MW_getStimData('PROBE', 'RDP_type', trialParam(b))];
        direction_list   = [direction_list MW_getStimData('PROBE', 'direction', trialParam(b))];
        disparity_list   = [disparity_list MW_getStimData('PROBE', 'field_center_z', trialParam(b))];
        
        speed_temp = MW_getStimData('PROBE', 'speed', trialParam(b));
        motion_temp = MW_getStimData('PROBE', 'RDP_type', trialParam(b));
        
        
        % build an index of rewarded vs non rewarded trials
        try
            if ~isempty(trialParam(b).IO_bkohg1_reward) || ~isempty(trialParam(b).IO_rewardA)
                rewarded(b) = 1;
            else
                rewarded(b) = 0;
            end
        end
        
        
        % build an index for the speed vs motion (linear or spiral)
        for fk = 1:length(motion_temp)
            if strcmp(motion_temp{fk},'3Dspiral') || strcmp(motion_temp{fk},'3DspiralMask')
                speed_spiral_list = [speed_spiral_list speed_temp(fk)];
            elseif strcmp(motion_temp{fk},'3Dlinear') || strcmp(motion_temp{fk},'3DlinearMask')
                speed_linear_list = [speed_linear_list speed_temp(fk)];
            end
        end
    end
    
    % build an index for motion type (linear or spiral)
    for b = 1:length(motion_list)
        if strcmp(motion_list{b},'3Dspiral') || strcmp(motion_list{b},'3DspiralMask')
            motion_list{b} = 1;
        elseif strcmp(motion_list{b},'3Dlinear') || strcmp(motion_temp{fk},'3DlinearMask')
            motion_list{b} = 2;
        end
    end
    
    % Convert to matrix for logical indexing
    direction_values    = cell2mat(direction_list);
    disparity_values    = cell2mat(disparity_list);
    motion_values       = cell2mat(motion_list);
    speed_spiral_values = cell2mat(speed_spiral_list);
    speed_linear_values = cell2mat(speed_linear_list);
    
    % Build indeces with unique values mapped in the experiment
    direction_list    = unique(cell2mat(direction_list));
    disparity_list    = unique(cell2mat(disparity_list));
    speed_spiral_list = unique(cell2mat(speed_spiral_list));
    speed_linear_list = unique(cell2mat(speed_linear_list));
    motion_list       = unique(cell2mat(motion_list));
    
    % Create the range of delays used in the reverse correlation
    delay = (-500000:bin_size:200000) * -1;
    
    for c = 1:length(cu)
        if length(direction_list) == 8 && length(disparity_list) == 8
            
            TUNING = [];
            
            %disp(['cell' mwk(11:end) '-' num2str(cu(c)) ' extracting Tuning'])
            TUNING.info.nspikes = 0;
            
            TUNING.lists.delay = delay;
            TUNING.lists.motion = motion_list;
            TUNING.lists.direction = direction_list;
            TUNING.lists.disparity = disparity_list;
            TUNING.lists.speed.linear = speed_linear_list;
            TUNING.lists.speed.spiral = speed_spiral_list;
            
            TUNING.multi.linear = [];
            gioggiu_multi_linear = zeros(length(direction_list),length(disparity_list),length(delay));
            
            probe_length = []; x_list = []; y_list = [];
            rad = []; dsize = []; ndots = []; RT = [];
            for i = 1:length(trialParam)
                if ~isempty(trialParam(i).IO_bkohg1_reward)
                    rad = MW_getStimData('PROBE', 'field_radius', trialParam(i));
                    dsize = MW_getStimData('PROBE', 'dot_size', trialParam(i));
                    ndots = MW_getStimData('PROBE', 'num_dots', trialParam(i));
                    x_list = MW_getStimData('PROBE', 'field_center_x', trialParam(i));
                    y_list = MW_getStimData('PROBE', 'field_center_y', trialParam(i));
                    [~ , stimoff] = MW_getStimData('fix_point_red','alpha_multiplier',trialParam(i));
                    stimoff = stimoff(end);
                    buttoff = trialParam(i).IO_bkohg1_left.time(end);
                    RT = [RT double(buttoff-stimoff)/1000];
                end
            end
            
            TUNING.info.hitrate = sum(rewarded) / ntrials;
            TUNING.info.stim_radius = rad{end};
            TUNING.info.dots_size = dsize{end};
            TUNING.info.ndots = ndots{end};
            TUNING.info.stim_x = x_list{end};
            TUNING.info.stim_y = y_list{end};
            TUNING.info.RT = RT;
            
            for t = 1:ntrials
                
                %disp([num2str(c) ' ' num2str(ntrials - t)]);
                
                biagio_multi_linear = zeros(length(direction_list),length(disparity_list),length(delay));
                
                stimulus = struct('time',[],'disparity',[],'motion',[],'speed',[]);
                
                % initialise the matrix with all the frames that will be extracted
                % if strcmp(trialParam(t).TRIAL_outcome.data,'success')
                
                % extract probe position for the current trial
                [disparity, probe_time] = MW_getStimData('PROBE', 'field_center_z', trialParam(t));
                [motion, ~]             = MW_getStimData('PROBE', 'RDP_type', trialParam(t));
                [direction,~]           = MW_getStimData('PROBE', 'direction', trialParam(t));
                [speed, ~]              = MW_getStimData('PROBE', 'speed', trialParam(t));
                
                
                if isempty(probe_time) == 0
                    for b = 1:length(motion)
                        if strcmp(motion{b},'3Dspiral') || strcmp(motion{b},'3DspiralMask')
                            motion{b} = 1;  % SPIRAL is 1
                        elseif strcmp(motion{b},'3Dlinear') || strcmp(motion{b},'3DlinearMask')
                            motion{b} = 2;  % LINEAR is 2
                        end
                    end
                    
                    stimulus.time = probe_time(1:2:length(probe_time));
                    stimulus.disparity = cell2mat(disparity);
                    stimulus.direction = cell2mat(direction);
                    stimulus.motion = cell2mat(motion);
                    stimulus.speed = cell2mat(speed);
                    
                    % if trial was rewarded = valid
                    if rewarded
                        % extract the length of the first probe for
                        length_temp = probe_time(2) - probe_time(1);
                        probe_length = [probe_length length_temp];
                    end
                    
                    % extract spike times for the current trial
                    spike_times = SPIKES_plexon.time_us(SPIKES_plexon.data==cu(c));
                    spike_times = spike_times(spike_times > stimulus.time(1) & spike_times < (stimulus.time(end)));
                    
                    TUNING.info.nspikes = TUNING.info.nspikes + length(spike_times);
                    
                    try
                        TUNING.info.stim_duration = stimulus.time(2) - stimulus.time(1);
                    end
                    
                    
                    % For each spike
                    for ts = 1:length(spike_times)
                        % For each delay
                        for d = 1:length(delay)
                            
                            % Initialize two empty matrices (frames) for disparity
                            % and for directions
                            frame_multi_linear = zeros(length(direction_list),length(disparity_list),length(delay));
                            
                            % Add the current delay to the spike
                            spike_delay = spike_times(ts)-delay(d);
                            
                            % If there are stimuli for the given spike delay
                            if sum(stimulus.time < spike_delay) > 0
                                
                                % Fill Multidimensional Tuning
                                % dimension 1 = direction,
                                % dimension 2 = delay,
                                % dimension 3 = disparity,
                                
                                if stimulus.motion(sum(stimulus.time < spike_delay)) == 2
                                    frame_multi_linear(direction_list == stimulus.direction(sum(stimulus.time < spike_delay)),...
                                        disparity_list == stimulus.disparity(sum(stimulus.time < spike_delay)),d) = 1;
                                end
                                
                                % Sum the frame with the previous frames
                                biagio_multi_linear = biagio_multi_linear + frame_multi_linear;
                            end
                        end
                    end
                end
                % Sum the frame with the previous trials
                gioggiu_multi_linear = gioggiu_multi_linear + biagio_multi_linear;
            end
            
            % Store the absolute spikes count
            TUNING.multi.linear = gioggiu_multi_linear;
            
            if TUNING.info.nspikes > EXP_minimum_spikes_requirred
                % Identify the delay at the highest variance
                low_range = 500000;
                hig_range = 0;
                steps = 1;
                
                latencies = find(TUNING.lists.delay == low_range):steps:find(TUNING.lists.delay == hig_range);
                alldelays = [];
                
                for kl = latencies
                    alldelays(end+1) = std2(TUNING.multi.linear(:,:,kl));
                end
                
                bestdelay_idx = latencies(alldelays == max(alldelays));
                disp([files_mwk.name(12:end-4) '-' num2str(cu(c)) ' delay ' num2str(TUNING.lists.delay(bestdelay_idx(1)))])
                
                TUNING.info.bestdelay = TUNING.lists.delay(bestdelay_idx(1));
                % Transform everything in probability by dividing the number of spikes
                % of each position by the total number of spikes for that delay
                [x,y] = find(TUNING.multi.linear(:,:,bestdelay_idx(1)) == max(max(TUNING.multi.linear(:,:,bestdelay_idx(1)))),1);
                TUNING.relative.linear = TUNING.multi.linear./TUNING.multi.linear(x,y,bestdelay_idx(1));

                % Save the TUNING matrix if the procedure worked properly for the cell
                name = ([cells_path files_mwk.name(12:end-4) '-' num2str(cu(c)) '-tuning.mat']);
                save(name,'TUNING');

                % Plot
                cell_ID = [files_mwk.name(12:end-4) '-' num2str(cu(c))];
                anc_PlotMultiTuning(cell_ID, TUNING, PLOT_path, 1)
                
            end
        end
    end
end
end