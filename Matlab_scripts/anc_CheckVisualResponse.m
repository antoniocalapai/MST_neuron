function anc_CheckVisualResponse(DATA_dir, ses, CELLS_dir, saveit)
%% This code checks if a given is visually responsive in the tuning phase
% acalapai@dpz.eu 2020 MST manuscript

user = char(java.lang.System.getProperty('user.name'));
warning('OFF', 'MATLAB:table:RowsAddedExistingVars')

% add paths with analysis scripts
addpath(genpath((['/Users/' user '/Dropbox/MST_manuscript/Matlab_scripts'])))
PLOT_path = ['/Users/' user '/Dropbox/MST_manuscript/Plots/VisualResponse/'];

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
    
    cu = SPIKES_plexon.data;
    cu = unique(cu);
    
    % Create an index of all the valid units found
    for c = 1:length(cu)
        sptimes = [];
        cell_ID = [files_mwk.name(12:end-4) '-' num2str(cu(c))];
        if isfile([CELLS_dir cell_ID '-tuning.mat'])
            disp(cell_ID)
            pre_stim = [];
            post_stim = [];
            interval = 300000;
            delay = 200000;
            for i = 1:length(trialParam)
                disp(i)
                if ~isempty(trialParam(i).IO_bkohg1_reward)
                    
                    [~ , probe_on] = ...
                        MW_getStimData('PROBE', 'action', trialParam(i));
                    
                    [~ , fix_on] = ...
                        MW_getStimData('fix_point_red', 'action', trialParam(i));
                    
                    spike_times = SPIKES_plexon.time_us(SPIKES_plexon.data==cu(c));
                    
                    if strcmp(ses(1:3),'anc')
                        sptimes{i} = transpose(double(spike_times(spike_times > fix_on(1) + ...
                            delay & spike_times < probe_on(1) + interval + delay) - probe_on(1))/1000000);
                    else
                        sptimes{i} = transpose(double(spike_times(spike_times > (fix_on(1) - interval) & ...
                            spike_times < probe_on(1) + interval + delay)) - probe_on(1))/1000000;
                    end
                    
                    pre_stim(end+1) = sum(sptimes{i} < 0 & sptimes{i} > -0.3);
                    post_stim(end+1) = sum(sptimes{i} > 0 & sptimes{i} < 0.3);
                end
            end
            
            % Plot visual response to stimulus onset
            % Raster Plot
            fig = figure('rend','painters','pos',[1094 1 840 840]);
            ax = subplot(2,1,1); hold on
            title([cell_ID])
            for l = 1:length(sptimes)
                
                spks = sptimes{l}';
                xspk = repmat(spks,3,1);
                yspk = nan(size(xspk));
                
                if ~isempty(yspk)
                    yspk(1,:) = l - 1;
                    yspk(2,:) = l;
                end
                
                plot(xspk, yspk, 'k')
            end
            
            xline(0,'r--');
            ax.XLim             = [-.5 .5];
            ax.YLim             = [0 length(sptimes)];
            ax.XLabel.String  	= 'Time [s]';
            ax.YLabel.String  	= 'Trials';
            set(gca,'FontSize',12)
            
            % Spike density function
            sdf = [];
            tstep = .001;                     % Resolution for SDF [s]
            sigma = .005;                     % Width of gaussian/window [s]
            time  = tstep-.5:tstep:.5;        % Time vector
            for iTrial = 1:length(sptimes)
                spks = [];
                gauss = [];
                spks = sptimes{iTrial}';          % Get all spikes of respective trial
                
                if isempty(spks)
                    out	= zeros(1,length(time));    % Add zero vector if no spikes
                else
                    
                    % For every spike
                    for iSpk = 1:length(spks)
                        
                        % Center gaussian at spike time
                        mu = spks(iSpk);
                        
                        % Calculate gaussian
                        p1 = -.5 * ((time - mu)/sigma) .^ 2;
                        p2 = (sigma * sqrt(2*pi));
                        gauss(iSpk,:) = exp(p1) ./ p2;
                        
                    end
                    % Sum over all distributions to get spike density function
                    sdf(iTrial,:) = sum(gauss,1);
                end
            end
            
            % Average response
            ax = subplot(2,1,2);
            plot(time, mean(sdf), 'Color', 'k', 'LineWidth', 1.5)
            title('Spike Density Function')
            mVal = max(mean(sdf)) + round(max(mean(sdf))*.1);
            
            xline(0,'r--','Stimulus Onset');
            ax.XLim             = [-.5 .5];
            ax.YLim             = [0 mVal];
            %ax.XTick            = [200 400];
            %ax.XTickLabel       = {'0', '0.2'};
            ax.XLabel.String  	= 'Time [s]';
            ax.YLabel.String  	= 'Firing Rate [Hz]';
            hold on
            
            x = [-0.3 0.3];
            y = [0 0];
            line(x,y,'Color','blue','LineWidth', 2)
            
            % Wilcoxon test on distributions of number of spikes before
            % and after stimulus onset
            
            [P,H,STATS] = signrank(pre_stim, post_stim);
            str = ['wilcoxon p = ' num2str(P)];
            loc = [0.13 0.45 0 0];
            if P < 0.05
                annotation('textbox', loc,'BackgroundColor','w', ...
                    'FontSize', 12, 'String', str,...
                    'EdgeColor','b','FitBoxToText','on');
            else
                annotation('textbox', loc,'BackgroundColor','w', ...
                    'FontSize', 12, 'String', 'n.s.',...
                    'EdgeColor','b','FitBoxToText','on');
            end
            
            set(gca,'FontSize',12)
            
            % Save plot
            if saveit
                name = ([PLOT_path cell_ID '_visualResponse.png']);
                saveas(fig,name)
                close all
                
                % Store information in the cell's mat file
                name = [CELLS_dir cell_ID '-tuning.mat'];
                load(name)
                TUNING.VisualResponse.sptimes = sptimes;
                TUNING.VisualResponse.p = P;
                TUNING.VisualResponse.test.H = H;
                TUNING.VisualResponse.test.stats = STATS;
                TUNING.VisualResponse.valid = sum(pre_stim) < sum(post_stim);
                save(name, 'TUNING')
            end
        end
    end
end
