function out = anc_Figure_3_v2(~)
%% Figure 3 - models performance
addpath(genpath(('/Users/acalapai/Dropbox/MST_manuscript/Matlab_scripts/')))
CELLS_dir = '/Users/acalapai/Dropbox/MST_manuscript/Cells_matfiles/';
database_path = '/Users/acalapai/Dropbox/MST_manuscript/Databases/';
plot_path = '/Users/acalapai/Dropbox/MST_manuscript/Plots/Models/';

% Null model
m{1} = 'gam(count ~ 1, data = d_motion_2, family = "nb")';

% Disparity only models
m{2} = 'gam(count ~ zdis, data = d_motion_2, family = "nb")';
m{3} = 'gam(count ~ s(dis, k = 8), data = d_motion_2, family = "nb")';
m{4} = 'gam(count ~ ordered(dis), data = d_motion_2, family = "nb")';

% Direction only models
m{5} = 'gam(count ~ zvmdir, data = d_motion_2, family = "nb")';
m{6} = 'gam(count ~ s(dir, bs = "cp"), data = d_motion_2, family = "nb")';

% Additive Models
m{7} = 'gam(count ~ zdis + zvmdir, data = d_motion_2, family = "nb")';
m{8} = 'gam(count ~ s(dis, k = 8) + s(dir, bs = "cp"), data = d_motion_2, family = "nb")';

% Multiplicative Models
m{9} = 'gam(count ~ zdis*zvmdir, data = d_motion_2, family = "nb")';
m{10} = 'gam(count ~ ordered(dis) + s(dir, bs = "cp", by = ordered(dis)), data = d_motion_2, family = "nb")';

% Flip Models
m{11} = 'gam(count ~ s(dis, k = 8) + s(dir_flip, bs = "cp"), data = d_motion_2, family = "nb")';
m{12} = 'gam(count ~ zdis + s(dir_flip, bs = "cp"), data = d_motion_2, family = "nb")';

% Load the data table
CELLS = anc_storeGAMresults;
CELLS = CELLS(CELLS.include == 1,:);

%%
out = [];
close all
fig = figure;
set(fig,'units','centimeters','position',[160   318   12*8   9*4])

% AIC Bar plot
aic = [CELLS.GAM_aic_0(CELLS.include) ...
    CELLS.GAM_aic_1(CELLS.include) ...
    CELLS.GAM_aic_2(CELLS.include) ...
    CELLS.GAM_aic_3(CELLS.include) ...
    CELLS.GAM_aic_4(CELLS.include) ...
    CELLS.GAM_aic_5(CELLS.include) ...
    CELLS.GAM_aic_6(CELLS.include) ...
    CELLS.GAM_aic_7(CELLS.include) ...
    CELLS.GAM_aic_8(CELLS.include) ...
    CELLS.GAM_aic_9(CELLS.include) ...
    CELLS.GAM_aic_10(CELLS.include) ...
    CELLS.GAM_aic_11(CELLS.include)];

[~,idx] = min(aic,[],2);
CELLS.bestGAM = idx;

DATA = ([sum(idx == 1) sum(idx == 2) sum(idx == 3) ...
    sum(idx == 4) sum(idx == 5) sum(idx == 6) sum(idx == 7) ...
    sum(idx == 8) sum(idx == 9) sum(idx == 10) ...
    sum(idx == 11) sum(idx == 12)])./length(idx);

subtightplot(12,4,2:4:48)
h = barh(1:numel(DATA), diag(DATA), 'stacked');

ax = gca;
ax.YTick = 1:length(m);
ax.YTickLabel = m;
set(gca,'TickLabelInterpreter','none')

set(gca,'YDir','reverse');
title('Percentage of lowest AIC value')
xlabel('%')
ylabel('')
ylim([0.5 12.5])
%xlim([0 0.5])
ax = gca;
% ax.YTickLabel = [0 1 2 3 4 5 6 7 8 9 10];
grid on
set(gca,'FontSize',12)

model_colors = [0.8 0.8 0.8; ...
    0.6 0.6 0.4; ...
    0.6 0.6 0.4; ...
    0.6 0.6 0.4; ...
    0.8 0.5 0.4; ...
    0.8 0.5 0.4; ...
    0.6 0.6 0.8; ...
    0.6 0.6 0.8; ...
    0.6 0.5 0.5; ...
    0.6 0.5 0.5; ...
    0.3 0.8 0.8; ...
    0.3 0.8 0.8];


for f = 1:length(h)
    h(f).FaceColor = model_colors(f,:);
end

out.AIC = DATA;

% Model histograms
% normalize deviance explained:
dev = [CELLS.GAM_dev_0(CELLS.include) ...
    CELLS.GAM_dev_1(CELLS.include) ...
    CELLS.GAM_dev_2(CELLS.include) ...
    CELLS.GAM_dev_3(CELLS.include) ...
    CELLS.GAM_dev_4(CELLS.include) ...
    CELLS.GAM_dev_5(CELLS.include) ...
    CELLS.GAM_dev_6(CELLS.include) ...
    CELLS.GAM_dev_7(CELLS.include) ...
    CELLS.GAM_dev_8(CELLS.include) ...
    CELLS.GAM_dev_9(CELLS.include) ...
    CELLS.GAM_dev_10(CELLS.include) ...
    CELLS.GAM_dev_11(CELLS.include)];

% Absolute deviance
subloc = 3:4:48;
for i = 2:length(m)
    subtightplot(12,4,subloc(i))
    h = histogram([dev(:,i)],100);
    h.FaceColor = [.7 .7 .7];
    set(gca,'FontSize',10)
    set(gca,'yticklabel',[])
    set(gca,'ylabel',[])
    xlabel('Absolute deviance')
    xline(median(dev(:,i)),'LineStyle',':','Color','r','LineWidth',2)
    ylim([0 100])
    xlim([0 0.05])
    grid on
    if i ~= size(dev,2)
        set(gca,'xticklabel',[])
        set(gca,'xlabel',[])
    end
    set(gca,'FontSize',12)
end


n_dev = [];
for i = 1:size(dev,1)
    n_dev(i,:) = rescale(dev(i,:));
end

subloc = 4:4:48;
for i = 2:size(dev,2)
    subtightplot(size(dev,2),4,subloc(i))
    h = histogram([n_dev(:,i)],30);
    h.FaceColor = [.7 .7 .7];
    set(gca,'FontSize',10)
    set(gca,'yticklabel',[])
    set(gca,'ylabel',[])
    xlabel('Rescaled deviance')
    xline(median(n_dev(:,i)),'LineStyle',':','Color','r','LineWidth',2)
    ylim([0 100])
    xlim([0 1.02])
    grid on
    if i ~= size(dev,2)
        set(gca,'xticklabel',[])
        set(gca,'xlabel',[])
    end
    set(gca,'FontSize',12)
end

name = ([plot_path 'Figure_3_Supp']);
print(fig,name,'-depsc')
close all


%% Plot individual heatmaps for model6 cells
for j = 1:length(m)
    model = CELLS.ID(idx == j);
    n = length(model);
    nrows = floor(sqrt(n));
    ncols = ceil(n/nrows);
    
    fig = figure;
    set(fig,'units','centimeters','position',[160   318   8*ncols   7*nrows])
    
    for i = 1:length(model)
        subplot(nrows, ncols,i)
        load([CELLS_dir model{i} '-tuning.mat'])
        latency = find(TUNING.lists.delay == TUNING.info.bestdelay, 1);
        
        A = TUNING.multi.linear(:,:,latency);
        
        maximum = max(max(A));
        [x,y] = find(A == maximum, 1, 'first');
        B = circshift(A,-[x-4 y-4]);
        
        F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
        Z = conv2(B,F,'same');
        
        imagesc(Z'); hold on
        colormap gray; colormap(1 - colormap)
        ax = gca;
        ax.XTick = 1:length([CELLS.stimulus_directions{1}]);
        ax.YTick = 1:length([CELLS.stimulus_disparities{1}]);
        ax.XTickLabel = circshift(CELLS.stimulus_directions{1},-[x-4]);
        ax.YTickLabel = circshift(CELLS.stimulus_disparities{1},-[y-4]);
        
        labels = string(ax.XAxis.TickLabels);
        labels(2:2:end) = nan;
        ax.XAxis.TickLabels = labels;
        
        labels = string(ax.YAxis.TickLabels);
        labels(2:2:end) = nan;
        ax.YAxis.TickLabels = labels;
        
        set(gca,'FontSize',12)
        title(model{i},'FontSize',10, 'Color','r');
        
        if i == 1
            xlabel('Direction')
            ylabel('Disparity')
        end
        
    end
    sgtitle(['model ' + string(j-1) + '-' + m{j}],'FontSize',12, 'Interpreter', 'none')
    
    name = ([plot_path 'AllCellsModel']);
    name = name + string(j-1);
    print(fig,name,'-depsc')
    close all
    
end

end

