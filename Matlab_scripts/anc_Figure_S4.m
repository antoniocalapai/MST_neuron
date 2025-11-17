function out = anc_Figure_S4(makefigure)
%% Figure 4 - models performance
% model 0 = null model
% model 1 = disparity only
% model 2 = direction only
% model 3 = disparity + direction
% model 4 = disparity * direction
% model 5 = disparity + flip(direction)

% gam(count ~ 1, data = d_motion_2, family = "nb")
% gam(count ~ zdis, data = d_motion_2, family = "nb")
% gam(count ~ zvmdir, data = d_motion_2, family = "nb")
% gam(count ~ zdis + zvmdir, data = d_motion_2, family = "nb")
% gam(count ~ zdis + zvmdir + (zdis*zvmdir), data = d_motion_2, family = "nb")
% gam(count ~ zdis + flip(zvmdir), data = d_motion_2, family = "nb")

addpath(genpath(('/Users/acalapai/Dropbox/MST_manuscript/Matlab_scripts/')))

out = [];
close all

database_path = '/Users/acalapai/Dropbox/MST_manuscript/Databases/';
load([database_path 'Cells.mat'])

CELLS = CELLS(CELLS.include,:);

color = [0.8 0.8 0.8];

% AIC Bar plot
aic = [CELLS.GAM_aic_0(CELLS.include) ...
    CELLS.GAM_aic_1(CELLS.include) ...
    CELLS.GAM_aic_2(CELLS.include) ...
    CELLS.GAM_aic_3(CELLS.include) ...
    CELLS.GAM_aic_4(CELLS.include) ...
    CELLS.GAM_aic_5(CELLS.include)];

[~,idx] = min(aic,[],2);

DATA = ([sum(idx == 1) sum(idx == 2) sum(idx == 3) ...
    sum(idx == 4) sum(idx == 5) sum(idx == 6)])./length(idx);

h = barh(1:numel(DATA), diag(DATA), 'stacked');
for f = 1:length(h)
    h(f).FaceColor = color;
end

set(gca,'YDir','reverse');
title('Percentage of lowest AIC value')
xlabel('%')
ylabel('Models')
ylim([0.5 6.5])
xlim([0 0.5])
ax = gca;
ax.YTickLabel = [0 1 2 3 4 5];
grid on
set(gca,'FontSize',15)

%% Model histograms
% normalize deviance explained:
figure
dev = [CELLS.GAM_dev_0(CELLS.include) ...
    CELLS.GAM_dev_1(CELLS.include) ...
    CELLS.GAM_dev_2(CELLS.include) ...
    CELLS.GAM_dev_3(CELLS.include) ...
    CELLS.GAM_dev_4(CELLS.include) ...
    CELLS.GAM_dev_5(CELLS.include)];

quants = [];
n_dev = [];
for i = 1:size(dev,2)
    quants(:,i) = quantile(dev(:,i),[0:0.01:1]);
end
for i = 1:size(dev,1)
    n_dev(i,:) = rescale(dev(i,:));
end

for i = 1:size(dev,2)
    subplot(size(dev,2),1,i)
    h = histogram([n_dev(:,i)],30);
    h.FaceColor = [.7 .7 .7];
    set(gca,'FontSize',10)
    xlabel('Proportion')
    %xline(median(n_dev(:,i)),'LineStyle',':','Color','r','LineWidth',2)
    ylim([0 100])
    xlim([0 1.02])
    grid on
    if i == 1
        title('Rescaled Deviance across models')
    end    
    if i ~= size(dev,2)
        set(gca,'xticklabel',[])
        set(gca,'xlabel',[])
        set(gca,'yticklabel',[])
        set(gca,'ylabel',[])
    end    
    set(gca,'FontSize',15)
end

out.rel_expl_dev = [median(n_dev)];

% Plot individual heatmaps for model6 cells
% model5 = CELLS.ID(idx == 6);
% for i = 1:length(model5)
%     subplot(3,6,i)
%     load([CELLS_dir model5{i} '-tuning.mat'])
%     latency = find(TUNING.lists.delay == TUNING.info.bestdelay, 1);
%     F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
%     Z = conv2(TUNING.multi.linear(:,:,latency),F,'same');
%     imagesc(Z'); hold on
%     colormap gray; colormap(1 - colormap)
%     ax = gca;
%     title(model5{i});
%     set(gca,'FontSize',10)
%     ax.XTickLabel = [];
%     ax.YTickLabel = [];
% end

%% Supplementary Figures Matrix of quantiles
close all
fig = figure;
set(fig,'units','centimeters','position',[160   318   12*2   9*2])
x = [0:0.01:1];
lh = plot(x, quants * 100,'LineStyle','-.','LineWidth',3);
set(lh(1), 'Linestyle', ':');
set(lh(2), 'Linestyle', ':');
set(lh(3), 'Linestyle', ':');
set(lh(4), 'Linestyle', '-');
set(lh(5), 'Linestyle', '--');
ax = gca;
%ax.XTick = 1:5;
ax.YAxisLocation = 'right';
lg = {'model 0','model 1','model 2','model 3','model 4', 'model 5'};
legend(lg, 'Location','NorthWest')
xlabel('Population quantiles');
ylabel('%');
set(gca,'FontSize',15)
title({'Absolute deviance explained'})
xlim([0 1])
ylim([-0.5 35])
grid on

out.abs_expl_dev_50 = [median(dev)];
out.abs_expl_dev_70 = [quants(71,:)];
out.abs_expl_dev_90 = [quants(91,:)];
out.abs_expl_dev_max = [quants(101,:)];

tt3vs4 = [];
[tt3vs4.H,tt3vs4.P,tt3vs4.CI,tt3vs4.STATS] = ttest2(quants(:,3),quants(:,4));
out.tt3vs4 = tt3vs4;

if ~makefigure
    close all
end
end

