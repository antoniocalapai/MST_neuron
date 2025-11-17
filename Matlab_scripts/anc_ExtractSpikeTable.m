function anc_ExtractSpikeTable(DATA_dir, ses, CELLS_dir)
%% This code PRE process any new session data file contained in the data folder
% acalapai@dpz.eu 2020 MST manuscript
user = char(java.lang.System.getProperty('user.name'));
warning('OFF', 'MATLAB:table:RowsAddedExistingVars')

% add paths with analysis scripts
addpath(genpath((['/Users/' user '/Dropbox/MST_manuscript/Matlab_scripts'])))

Rpath = ['/Users/' user '/Dropbox/MST_manuscript/Cells_csv/'];
PLOT_path = ['/Users/' user '/Dropbox/MST_manuscript/Plots/RCvsTable/'];
cells_path = CELLS_dir;

bin_size = 5000;

files_mwk = dir([[DATA_dir, ses, '/'] '*uning*']);

%% Extract the combined Probability Map for linear direction and disparity
if ~isempty(files_mwk)
    cd([DATA_dir, ses,'/', files_mwk.name])
    
    if strcmp(ses(1:3),'anc')
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
    
    for c = 1:length(cu)
        cell_ID = [files_mwk.name(12:end-4) '-' num2str(cu(c))];
        if isfile([CELLS_dir cell_ID '-tuning.mat'])
            load([CELLS_dir cell_ID '-tuning.mat']);
            disp(cell_ID)
            
            bestdelay = TUNING.info.bestdelay;
            
            SPIKETABLE = struct('ID',[],'motion',[],'direction',[], 'direction_flip',[],'disparity',[],'speed',[],'delay',[],'trial',[],'count',[],'FR',[]);
            spike_times = SPIKES_plexon.time_us(SPIKES_plexon.data==cu(c));
            
            % Calculate the duration of the probes
            probe_length = [];
            for aaa = 1:length(trialParam)
                % if trial was rewarded = valid
                if ~isempty(trialParam(aaa).IO_bkohg1_reward)
                    [~, length_temp] = MW_getStimData('PROBE', 'field_center_z', trialParam(aaa));
                    % extract the length of the first probe for
                    length_temp = length_temp(2) - length_temp(1);
                    probe_length = [probe_length length_temp];
                end
            end
            % save
            probe_length = mode(probe_length);
            
            %spike_times = spike_times - bestdelay;
            %loop through trials
            for t = 1:length(trialParam)
                idx_sample = 0;
                %disp(num2str(length(trialParam) - t))
                if ~isempty(trialParam(t).IO_bkohg1_reward)
                    % extract probe position for the current trial
                    stimulus = struct('time',[],'disparity',[],'motion',[],'speed',[]);
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
                        
                        % For each stimulus loop through probes
                        for st = 1:2:length(probe_time)
                            idx_sample = idx_sample + 1;
                            stimulus_delay = probe_time(st) + bestdelay;
                            
                            SPIKETABLE(end+1).count   = sum(spike_times >= stimulus_delay & spike_times <= stimulus_delay+probe_length);
                            SPIKETABLE(end).FR        = sum(spike_times >= stimulus_delay & spike_times <= stimulus_delay+probe_length)*(1000000/probe_length);
                            SPIKETABLE(end).delay     = bestdelay;
                            SPIKETABLE(end).ID        = [files_mwk.name(12:end-4) '-' num2str(cu(c))];
                            SPIKETABLE(end).motion    = motion{st};
                            SPIKETABLE(end).direction = direction{st};
                            SPIKETABLE(end).disparity = disparity{st};
                            SPIKETABLE(end).speed     = speed{st};
                            SPIKETABLE(end).order     = idx_sample;
                            SPIKETABLE(end).trial     = t;
                            
                            % Flip the direction label for far stimuli (old GAM M5)
                            if disparity{st} > 0
                                SPIKETABLE(end).direction_flip = mod(direction{st} + 180, 360);
                            else
                                SPIKETABLE(end).direction_flip = direction{st};
                            end
                            
                        end
                    end
                end
            end
            
            % remove first row if empty and convert to table
            if isempty(SPIKETABLE(1).ID); SPIKETABLE(1) = []; end
            SPIKETABLE = struct2table(SPIKETABLE);
            
            % plot joint matrix to check
            v = [];
            for i = 1:8
                for j = 1:8
                    
                    m = unique(SPIKETABLE.direction);
                    d = unique(SPIKETABLE.disparity);
                    
                    v(i,j) = sum(SPIKETABLE{SPIKETABLE.motion == 2 & ...
                        SPIKETABLE.direction == m(i) & ...
                        SPIKETABLE.disparity == d(j), 'count'});
                    
                end
            end
            
            % save plot with comparison between reverse correlation heatmap
            % and spike count heatmap from the table
            fig = figure('rend','painters','pos',[1978 692 1155 493]);
            
            F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
            A1 = subplot(1,2,1);
            latency = find(TUNING.lists.delay == TUNING.info.bestdelay, 1);
            S = TUNING.multi.linear(:,:,latency);
            Z1 = conv2(TUNING.multi.linear(:,:,latency),F,'same');
            A1 = imagesc(Z1'); hold on
            colormap gray; colormap(1 - colormap)
            % spy(sparse(W>0.95)','r*', 1)
            ax = gca;
            ax.XTick = 1:length([TUNING.lists.direction]);
            ax.YTick = 1:length([TUNING.lists.disparity]);
            ax.XTickLabel = TUNING.lists.direction;
            ax.YTickLabel = TUNING.lists.disparity;
            title(ax, 'Reverse Correlation');
            set(gca,'FontSize',12)
            axis square
            
            A2 = subplot(1,2,2);
            Z2 = conv2(v,F,'same');
            A2 = imagesc(Z2'); hold on
            colormap gray; colormap(1 - colormap)
            ax = gca;
            ax.XTick = 1:length([TUNING.lists.direction]);
            ax.YTick = 1:length([TUNING.lists.disparity]);
            ax.XTickLabel = TUNING.lists.direction;
            ax.YTickLabel = TUNING.lists.disparity;
            title(ax, 'Spike Count');
            set(gca,'FontSize',12)
            axis square
            
            name = ([PLOT_path cell_ID '_RCvsTable.png']);
            saveas(fig,name)
            close all
            
            % Save the SPIKETABLE matrix if the procedure worked properly for the cell
            name = ([cells_path files_mwk.name(12:end-4) '-' num2str(cu(c)) '-forGLM.mat']);
            save(name,'SPIKETABLE');            
        end
    end
end
end
