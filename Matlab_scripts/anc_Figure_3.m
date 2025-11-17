function out = anc_Figure_3(makefigure)
%% Figure 3 - models performance
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

CELLS_dir = '/Users/acalapai/Dropbox/MST_manuscript/Cells_matfiles/';
addpath(genpath(('/Users/acalapai/Dropbox/MST_manuscript/Matlab_scripts/')))

out = [];
close all
fig = figure;
set(fig,'units','centimeters','position',[160   318   12*2   9*2])

database_path = '/Users/acalapai/Dropbox/MST_manuscript/Databases/';
fig_path = '/Users/acalapai/Dropbox/MST_manuscript/Figures/';
load([database_path 'Cells.mat'])

CELLS = CELLS(CELLS.include,:);

m1_color = [0.6 0.6 0.6];
m2_color = [0.4 0.4 0.4];
m3_color = [0.2 0.2 0.2];
m5_color = [0.8 0.8 0.8];

% AIC Bar plot
aic = [CELLS.GAM_aic_0(CELLS.include) ...
    CELLS.GAM_aic_1(CELLS.include) ...
    CELLS.GAM_aic_2(CELLS.include) ...
    CELLS.GAM_aic_3(CELLS.include) ...
    CELLS.GAM_aic_4(CELLS.include)];

[~,idx] = min(aic,[],2);

DATA = ([sum(idx == 1) sum(idx == 2) sum(idx == 3) ...
    sum(idx == 4) sum(idx == 5)])./length(idx);

subtightplot(5,2,1:2:9)
h = barh(1:numel(DATA), diag(DATA), 'stacked');
h(1).FaceColor = [0.8 0.8 0.8];
h(2).FaceColor = [0.8 0.8 0.8];
h(3).FaceColor = [0.2 0.2 0.2];
h(4).FaceColor = [0.2 0.2 0.2];
h(5).FaceColor = [0.2 0.2 0.2];
set(gca,'YDir','reverse');
title('Percentage of lowest AIC value')
xlabel('%')
ylabel('')
ylim([0.5 5.5])
xlim([0 0.5])
ax = gca;
ax.YTickLabel = [0 1 2 3 4];
grid on
set(gca,'FontSize',12)

out.AIC = DATA;

% Model histograms
% normalize deviance explained:
dev = [CELLS.GAM_dev_0(CELLS.include) ...
    CELLS.GAM_dev_1(CELLS.include) ...
    CELLS.GAM_dev_2(CELLS.include) ...
    CELLS.GAM_dev_3(CELLS.include) ...
    CELLS.GAM_dev_4(CELLS.include)];

quants = [];
n_dev = [];
for i = 1:size(dev,2)
    quants(:,i) = quantile(dev(:,i),[0:0.01:1]);
end
for i = 1:size(dev,1)
    n_dev(i,:) = rescale(dev(i,:));
end

subloc = 2:2:10;
for i = 2:size(dev,2)
    subtightplot(5,2,subloc(i))
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

out.rel_expl_dev = [median(n_dev)];

% Plot individual heatmaps for model6 cells
model5 = CELLS.ID(idx == 6);
for i = 1:length(model5)
    subplot(3,6,i)
    load([CELLS_dir model5{i} '-tuning.mat'])
    latency = find(TUNING.lists.delay == TUNING.info.bestdelay, 1);
    F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
    Z = conv2(TUNING.multi.linear(:,:,latency),F,'same');
    imagesc(Z'); hold on
    colormap gray; colormap(1 - colormap)
    ax = gca;
    title(model5{i});
    set(gca,'FontSize',10)
    ax.XTickLabel = [];
    ax.YTickLabel = [];
end

end

