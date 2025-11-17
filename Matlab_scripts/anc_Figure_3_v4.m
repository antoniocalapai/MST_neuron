%% Figure 3 version 4 - models performance
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

% Selects cells with significant visual response, 
CELLS = CELLS(CELLS.VisualResponse > 0 ...% 1)
        & CELLS.tuning_bestdelay > 0 ... % 2)
        & CELLS.mapping_valid > 0,:); % 3)


%
out = [];
% close all
fig = figure;
set(fig,'units','centimeters','position',[10   10   6*sizeMult   9*sizeMult])

% AIC Bar plot Resorted!
bic = [CELLS.GLM_bic_weigths_1 ...    
    CELLS.GLM_bic_weigths_2 ...
    CELLS.GLM_bic_weigths_3 ...
    CELLS.GLM_bic_weigths_5 ... % <------- RESORTED!!    
    CELLS.GLM_bic_weigths_4 ... % <------- RESORTED!!
    CELLS.GLM_bic_weigths_6 ...    
    CELLS.GLM_bic_weigths_7 ...
    CELLS.GLM_bic_weigths_8 ...
    CELLS.GLM_bic_weigths_9];

% For each cell, find the highest BIC_weight model
[~,idx] = max(bic,[],2); 
CELLS.bestGAM = idx;

% group models based on type
DATA = ([sum(idx == 1) ...                      % Null modul
         sum(idx == 2 | idx == 3) ...           % Disparity only models
         sum(idx == 4) ...                      % Direction only model
         sum(idx == 5 | idx == 6) ...           % Additive interaction models
         sum(idx == 7 | idx == 8 | idx == 9)... % Multiplicative interaction models 
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
models{9} = 'count~1 + direction + disparity + disparity^2 + (direction * disparity) + (direction^2 * disparity)'; 
family{5} = 'Multiplicative';
     
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
ylim([0.5 5.5])
grid on
set(gca,'FontSize',12)

%%
out.BIC = DATA;

% Model histograms
% normalize deviance explained:
dev = [zeros(1,size(CELLS,1))' ...
       CELLS.GLM_pseudoR2_2 ...
       CELLS.GLM_pseudoR2_3 ...
       CELLS.GLM_pseudoR2_4 ...
       CELLS.GLM_pseudoR2_5 ...
       CELLS.GLM_pseudoR2_6 ...
       CELLS.GLM_pseudoR2_7 ...
       CELLS.GLM_pseudoR2_8 ...
       CELLS.GLM_pseudoR2_9];

dev(any(isnan(dev), 2), :) = [];

subplot(1,2,2)
boxplot(dev * 100,categorical(1:9),'orientation', 'horizontal','PlotStyle','compact');
% histogr(dev * 100,categorical(1:9),'orientation', 'horizontal');

set(gca,'YDir','reverse');
ax = gca;
ax.YTickLabel = '';
xlabel('%')
ylim([0.5 9.5])
grid on
set(gca,'FontSize',12)
title('Variance explained across cells')
