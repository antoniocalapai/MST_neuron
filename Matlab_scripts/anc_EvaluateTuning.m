function anc_EvaluateTuning
% This function plots the tuning joint matrix at the best delay
addpath(genpath(('/Users/acalapai/Dropbox/MST_manuscript/Matlab_scripts/')))
plot_path = '/Users/acalapai/Dropbox/MST_manuscript/Plots/MultiTuning_evaluated/';
cells_path = '/Users/acalapai/Dropbox/MST_manuscript/Cells_matfiles/';

cells_list = dir([cells_path '*tun*']);

for i = 1:length(cells_list)
%     load([cells_path cells_list(i).name])
    
    load([cells_path cells_list{2}])
    F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
    figure('rend','painters','pos',[2635 422 816 780])
    A1 = subplot(3,3,[5 6 8 9]);
    latency = find(TUNING.lists.delay == TUNING.info.bestdelay, 1);
    S = TUNING.multi.linear(:,:,latency);
    Z = conv2(TUNING.multi.linear(:,:,latency),F,'same');
%     Zs = (S-mu)/ga;
    
    mu = mean(mean(S));
    ga = std(std(S));
    W = S./mu;    
%    W = binocdf(S,sum(sum(S)),1/64);
    A1 = imagesc(Z',[min(min(Z)), max(max(Z))]); hold on
    colormap gray; colormap(1 - colormap)
    
%    corrected_threshold = 0.05 / 64;
%    spy(sparse(W > 0.05)','g*'),
%    spy(sparse(W > corrected_threshold)','r*'),
    
    ax = gca;
    ax.YAxisLocation = 'right';
    ax.XTick = 1:length([TUNING.lists.direction]);
    ax.YTick = 1:length([TUNING.lists.disparity]);
    ax.XTickLabel = TUNING.lists.direction;
    ax.YTickLabel = TUNING.lists.disparity;
    xlabel('Direction');
    ylabel('Disparity');
    xlim([0.5 8.5])
    ylim([0.5 8.5])
    set(gca,'FontSize',15)
    
    A0 = subplot(3,3,1);
    ax = gca;
%     text(0,0.2,'p < 0.0008','Color', 'r', 'FontSize',20)
%     text(0,0.4,'p < 0.05','Color', 'g', 'FontSize',20)
    text(0,0.8,['number of spikes: ' num2str([TUNING.info.nspikes])],'Color', 'k', 'FontSize',20)
    text(0,0.6,['best delay (ms): ' num2str([TUNING.info.bestdelay]/1000)],'Color', 'k', 'FontSize',20)
    ax.Visible = 'off';
    
    
    A2 = subplot(3,3,[2 3]);
    A2 = plot(Z./sum(sum(Z)),'LineWidth',3);
    yline(1/(8*8),'LineStyle',':','Color','k','LineWidth',2);
    xlim([0.5 8.5])
    ylim([0 0.0625])
    ax = gca;
    ax.YAxisLocation = 'right';
    ax.XTick = 1:length([TUNING.lists.direction]);
    ax.XTickLabel =  TUNING.lists.direction;
    ax.YTick = 0:0.0156:0.0625;
    ax.YTickLabel = {'0','c','c*2','c*3','c*4'};
    grid on
    title(cells_list(i).name(1:end-11))
    set(gca,'FontSize',15)
    
    
    A3 = subplot(3,3,[4 7]);
    A3 = plot(Z'./sum(sum(Z)),'LineWidth',3);
    yline(1/(8*8),'LineStyle',':','Color','k','LineWidth',2);
    camroll(-90)
    xlim([0.5 8.5])
    ylim([0 0.0625])
    set(gca,'YDir','reverse');
    ax = gca;
    ax.YAxisLocation = 'right';
    ax.XAxisLocation = 'top';
    ax.XTick = 1:length([TUNING.lists.direction]);
    ax.XTickLabel =  TUNING.lists.disparity;
    ax.YTick = 0:0.0156:0.0625;
    ax.YTickLabel = {'0','c','c*2','c*3','c*4'};
    grid on
    set(gca,'FontSize',15)
    
    % TUNING.valid = sum(sum(W > 0.05));
    
    name = ([plot_path cells_list(i).name(1:end-4) '_eval']);
    export_fig(name,'-png','-transparent')
    
    name = ([cells_path cells_list(i).name]);
    save(name,'TUNING');
    close all
end
end
