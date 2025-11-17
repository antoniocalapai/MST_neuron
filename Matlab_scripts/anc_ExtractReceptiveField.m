function anc_ExtractReceptiveField(DATA_dir, ses, CELLS_dir)
%% This function extract receptive field information from each session
% acalapai@dpz.eu 2020 MST manuscript
user = char(java.lang.System.getProperty('user.name'));
warning('OFF', 'MATLAB:table:RowsAddedExistingVars')

% add paths with analysis scripts
addpath(genpath((['/Users/' user '/Dropbox/MST_manuscript/Matlab_scripts'])))
PLOT_path = ['/Users/' user '/Users/acalapai/Dropbox/MST_manuscript/Plots/RF/'];

EXP_minimum_spikes_requirred = 1000;
bin_size = 5000;
delay = (-500000:bin_size:200000)*-1; 

% find all files with "map" in the filename
files_mwk = dir([[DATA_dir, ses, '/'] '*map*']);

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
    end
    
    cu = SPIKES_plexon.data;
    cu = unique(cu);
    
    % extract all the probe positions shown in the experiment
    x_list = []; y_list = []; z_list = []; rad = []; spe = []; dsize = [];
    succ = 0; ndots = [];
    
    % cicle through all the trials
    for i = 1:length(trialParam)
        if ~isempty(trialParam(i).IO_bkohg1_reward)
            succ = succ + 1;
            x_list = [x_list MW_getStimData('PROBE', 'field_center_x', trialParam(i))];
            y_list = [y_list MW_getStimData('PROBE', 'field_center_y', trialParam(i))];
            z_list = [z_list MW_getStimData('PROBE', 'field_center_z', trialParam(i))];
            rad = [rad MW_getStimData('PROBE', 'field_radius', trialParam(i))];
            spe = [spe MW_getStimData('PROBE', 'speed', trialParam(i))];
            dsize = [dsize MW_getStimData('PROBE', 'dot_size', trialParam(i))];
            ndots = [ndots MW_getStimData('PROBE', 'num_dots', trialParam(i))];
        end
    end
    
    succ = succ / length(trialParam);
    
    x_values = cell2mat(x_list);
    y_values = cell2mat(y_list);
    z_values = cell2mat(z_list);
    rad = unique(cell2mat(rad));
    spe = unique(cell2mat(spe));
    
    x_list = unique(x_values);
    y_list = unique(y_values);
    z_list = unique(z_values);
    
    
    %% Perform the Reverse Correlation for each spikes of each trial of each cell
    for c = 1:length(cu)
        disp(['cell-' ses(12:end) '-' num2str(cu(c)) ' extracting RF'])
        
        MAPPING.cell = struct('absolute',zeros(length(x_list),length(y_list),length(delay)),'relative',zeros(length(x_list),length(y_list),length(delay)),...
            'binomialCDF',zeros(length(x_list),length(y_list),length(delay)));
        
        MAPPING.info.radius = rad;
        MAPPING.info.speed = spe;
        MAPPING.info.hitrate = succ;
        MAPPING.info.dsize = dsize;
        MAPPING.info.x_list = x_list;
        MAPPING.info.y_list = y_list;
        MAPPING.info.z_list = z_list;
        MAPPING.info.ndots = ndots{1};
        MAPPING.info.delay = delay;
        MAPPING.info.nspikes = 0;
        
        gioggiu = zeros(length(x_list),length(y_list),length(delay));
        
        
        for i = 1:length(trialParam)
            if ~isempty(trialParam(i).IO_bkohg1_reward)
                
                disp(num2str(length(trialParam)-i))
                
                biagio = zeros(length(x_list),length(y_list),length(delay));
                stimulus = struct('time',[],'x',[],'y',[]);
                
                % initialise the matrix with all the frames that will be extracted
                
                
                % extract probe position for the current trial
                [Xcor, Xcor_time]  = MW_getStimData('PROBE', 'field_center_x', trialParam(i));
                [Ycor, ~]  = MW_getStimData('PROBE', 'field_center_y', trialParam(i));
                
                stimulus.time = Xcor_time(1:2:length(Xcor_time));
                stimulus.x = cell2mat(Xcor);
                stimulus.y = cell2mat(Ycor);
                
                if stimulus.time > 0
                    % extract spike times for the current trial
                    spike_times = SPIKES_plexon.time_us(SPIKES_plexon.data==cu(c));
                    spike_times = spike_times(spike_times > stimulus.time(1) & spike_times < (stimulus.time(end)));
                    
                    MAPPING.info.nspikes = MAPPING.info.nspikes + length(spike_times);
                    
                    for ts = 1:length(spike_times)
                        for d = 1:length(delay)
                            frame = zeros(length(x_list),length(y_list),length(delay));
                            spike_delay = spike_times(ts)-delay(d);
                            
                            if sum(stimulus.time < spike_delay) > 0
                                
                                frame(x_list == stimulus.x(sum(stimulus.time < spike_delay)),...
                                    y_list == stimulus.y(sum(stimulus.time < spike_delay)),d) = 1;
                                
                                biagio = biagio + frame;
                                
                            end
                        end
                    end
                end
                gioggiu = gioggiu + biagio;
            end
        end
        
        % Store the temporary matrix gioggiu into a permanent one
        MAPPING.cell.absolute = gioggiu;
        MAPPING.info.stim_duration = stimulus.time(2) - stimulus.time(1);
        
        disp([files_mwk.name(11:end-4) '-' num2str(cu(c)) ' : ' num2str(MAPPING.info.nspikes) ' spikes total'])
        
        %% Calculate, store and save the information about the Receptive field
        if MAPPING.info.nspikes > EXP_minimum_spikes_requirred
            
            low_range = 200000;
            hig_range = -20000;
            steps = 20000 / bin_size;
            
            latencies = find(MAPPING.info.delay == low_range):steps:find(MAPPING.info.delay == hig_range);
            alldelays = [];
            
            for kl = find(MAPPING.info.delay == low_range):steps:find(MAPPING.info.delay == hig_range)
                alldelays(end+1) = std2(MAPPING.cell.absolute(:,:,kl));
            end
            
            bestdelay_idx = latencies(alldelays == max(alldelays));
            MAPPING.info.bestdelay = MAPPING.info.delay(bestdelay_idx);
            [x,y] = find(MAPPING.cell.absolute(:,:,bestdelay_idx) == max(max(MAPPING.cell.absolute(:,:,bestdelay_idx))));
            MAPPING.info.RF_x = x_list(x(1));
            MAPPING.info.RF_y = y_list(y(1));
            
            % Transform everything in probability by dividing the number of spikes
            % of each position by the total number of spikes for that delay
            MAPPING.cell.relative = MAPPING.cell.absolute./...
                MAPPING.cell.absolute(x(1),y(1),bestdelay_idx);
            
            % Plot
            cell_ID = [files_mwk.name(11:end-4) '-' num2str(cu(c))];
            anc_PlotReceptiveField(cell_ID, MAPPING, PLOT_path,1,[]);
            MAPPING.valid = 0; 
            
            % Save the structure with the mapping information
            name = ([CELLS_dir files_mwk.name(11:end-4) '-' num2str(cu(c)) '-RFmapp.mat']);
            save(name,'MAPPING');
                        
        end
    end
end
end
