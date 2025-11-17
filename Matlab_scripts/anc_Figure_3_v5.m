%% Figure 3 version 5 (2024) - models performance
user = char(java.lang.System.getProperty('user.name'));
warning('OFF', 'MATLAB:table:RowsAddedExistingVars')
saveplot = 0;
sizeMult = 2;

% add paths with analysis scripts
addpath(genpath((['/Users/' user '/Dropbox/MST_manuscript/Matlab_scripts'])))
database_path = ['/Users/' user '/Dropbox/MST_manuscript/Databases/'];

% add paths of cells and plots
CELLS_dir = ['/Users/' user '/Dropbox/MST_manuscript/Cells_matfiles/'];
plot_path = ['/Users/' user '/Dropbox/MST_manuscript/Plots/Models/'];

% Load the data table
CELLS = anc_storeGLMresults;
CELLS = CELLS(CELLS.VisualResponse > 0,:);

% CELLS = CELLS(CELLS.VisualResponse > 0 ...% 1)
%         & CELLS.tuning_bestdelay > 0 ... % 2)
%         & CELLS.mapping_valid > 0,:); % 3)

%%
out = [];
close all
fig = figure;
set(fig,'units','centimeters','position',[10   10   12*sizeMult   6*sizeMult])

% AIC Bar plot Resorted!
bic = [CELLS.GLM_bic_weigths_1 ...
    CELLS.GLM_bic_weigths_2 ...
    CELLS.GLM_bic_weigths_3 ...
    CELLS.GLM_bic_weigths_4 ...
    CELLS.GLM_bic_weigths_5 ...
    CELLS.GLM_bic_weigths_6 ...
    CELLS.GLM_bic_weigths_7 ...
    CELLS.GLM_bic_weigths_8 ...
    CELLS.GLM_bic_weigths_9];

% For each cell, find the highest BIC_weight model
[~,idx] = max(bic,[],2);
CELLS.bestGAM = idx;

% % group models based on type
% DATA = ([sum(idx == 1) ...                      % Null modul
%          sum(idx == 2) ...                      % Direction only model
%          sum(idx == 3 | idx == 5) ...           % Disparity only models
%          sum(idx == 4 | idx == 6) ...           % Additive interaction models
%          sum(idx == 7 | idx == 8 | idx == 9)... % Multiplicative interaction models
%          ]);

% group models based on type
DATA = ([sum(idx == 1) ...
    sum(idx == 2) ...
    sum(idx == 3) ...
    sum(idx == 5) ... % RESORTED for visualization
    sum(idx == 4) ... % RESORTED for visualization
    sum(idx == 6) ...
    sum(idx == 7) ...
    sum(idx == 8) ...
    sum(idx == 9) ...
    ]);

% ===== NOTE THAT THE MODELS' ORDER IS RESORTED (the plotted order is  ..,3,5,4,6,..)
% null (model 1)
models{1} = 'count~1';
family{1} = 'Null';

% direction (model 2)
models{2} = 'count~1 + direction';
family{2} = 'Motion';

% disparity (models 3 and 5)
models{3} = 'count~1 + disparity';
models{4} = 'count~1 + disparity + disparity^2';
family{3} = 'Depth';

% additive models (models 4, 6)
models{5} = 'count~1 + direction + disparity';
models{6} = 'count~1 + direction + disparity + disparity^2';
family{4} = 'Additive';

% multiplicative models (models 7, 8, 9)
models{7} = 'count~1 + direction + disparity + (direction * disparity)';
models{8} = 'count~1 + direction + disparity + disparity^2 + (direction * disparity)';
models{9} = 'count~1 + direction + disparity + disparity^2 + (direction * disparity) + (direction * disparity^2)';
family{5} = 'Multiplicative';

subplot(1,2,1)
h = barh(1:numel(DATA), diag(DATA), 'stacked');
for f = 1:length(h)
    h(f).FaceColor = [0.8 0.8 0.8];
end

ax = gca;
ax.YTick = 1:length(models);
ax.YTickLabel = [];
ax.YLabel = [];
ax.XLabel = [];
ax.YDir = 'reverse';
ylim([0.5 9.5])

grid on
set(gca,'FontSize',12)


model_colors = [0.8 0.8 0.8; ...
    
0.99 0.76 0.04; ...

0.05 0.48 0.86; ...
0.05 0.48 0.86; ...

0.90 0.38 0; ...
0.90 0.38 0; ...

0.36 0.23 0.61; ...
0.36 0.23 0.61; ...
0.36 0.23 0.61];

for f = 1:length(h)
    h(f).FaceColor = model_colors(f,:);
    h(f).FaceAlpha = 0.75;
end

% Plot grouped pseudo R2
subplot(1,2,2)

dir = [CELLS.GLM_pseudoR2_2'];
dis = [CELLS.GLM_pseudoR2_3' CELLS.GLM_pseudoR2_5'];
dirdis = [CELLS.GLM_pseudoR2_4' CELLS.GLM_pseudoR2_6'];
dirXdis = [CELLS.GLM_pseudoR2_7' CELLS.GLM_pseudoR2_8' CELLS.GLM_pseudoR2_9'];

x = [dir dis dirdis dirXdis];
g = [zeros(length(dir), 1)' ones(length(dis), 1)' 2*ones(length(dirdis), 1)' 3*ones(length(dirXdis), 1)'];
boxplot(x * 100, g, 'symbol', '')

colors = flip(unique(model_colors, 'rows', 'stable'));
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors(j,:),'FaceAlpha',.75);
end

ylim([-0.5 12])
ylabel('')
grid on
set(gca,'FontSize',12)

% %% Plot individual heatmaps for multiplicative cells
% for j = 1:length(models)
%     model = CELLS.ID(idx == j);
%     n = length(model);
%     nrows = floor(sqrt(n));
%     ncols = ceil(n/nrows);
%     
%     if ~isempty(model)
%         fig = figure;
%         set(fig,'units','centimeters','position',[1   1   8*ncols   7*nrows])
%         for i = 1:length(model)
%             subplot(nrows, ncols,i)
%             load([CELLS_dir model{i} '-tuning.mat'])
%             latency = find(TUNING.lists.delay == TUNING.info.bestdelay, 1);
%             
%             A = TUNING.multi.linear(:,:,latency);
%             
%             %             maximum = max(max(A));
%             %             [x,y] = find(A == maximum, 1, 'first');
%             %             B = circshift(A,-[x-4 y-4]);
%             %
%             F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
%             Z = conv2(A,F,'same');
%             
%             imagesc(Z'); hold on
%             colormap gray; colormap(1 - colormap)
%             %             ax = gca;
%             %             ax.XTick = 1:length([CELLS.stimulus_directions{1}]);
%             %             ax.YTick = 1:length([CELLS.stimulus_disparities{1}]);
%             %             ax.XTickLabel = circshift(CELLS.stimulus_directions{1},-[x-4]);
%             %             ax.YTickLabel = circshift(CELLS.stimulus_disparities{1},-[y-4]);
%             %
%             %             labels = string(ax.XAxis.TickLabels);
%             %             labels(2:2:end) = nan;
%             %             ax.XAxis.TickLabels = labels;
%             %
%             %             labels = string(ax.YAxis.TickLabels);
%             %             labels(2:2:end) = nan;
%             %             ax.YAxis.TickLabels = labels;
%             
%             set(gca,'FontSize',12)
%             title(model{i},'FontSize',10, 'Color','r');
%             
%             if i == 1
%                 xlabel('Direction')
%                 ylabel('Disparity')
%             end
%             
%             ax = gca;
%             ax.YTickLabel = [];
%             ax.XTickLabel = [];
%             ax.YLabel = [];
%             ax.XLabel = [];
%             
%         end
%         sgtitle(['model ' + string(j-1) + '-' + models{j}],'FontSize',12, 'Interpreter', 'none')
%         
%         name = ([plot_path 'AllCellsModel']);
%         name = name + string(j-1);
%         %     print(fig,name,'-depsc')
%         %     close all
%         %
%     end
% end

