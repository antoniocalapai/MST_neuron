%% Figure 3 version 3 - models performance
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

% Null model
m{1} = 'count~1';
modelName{1} = 'Null';

% Disparity only models
m{2} = 'count~1+depth';
m{3} = 'count~1+depth+depth2';
modelName{2} = 'Disparity only';

% Direction only models
m{4} = 'count~1+sin(angle)+cos(angle)';
modelName{3} = 'Direction only';

% Additive interaction models
m{5} = 'count~1+depth+sin(angle)+cos(angle)';
m{6} = 'count~1+depth+depth2+sin(angle)+cos(angle)';
modelName{4} = 'Disparity + Direction';

% Multiplicative interaction models
m{7} = 'count~1+depth*(sin(angle)+cos(angle))';
m{8} = 'count~1+depth2+depth*(sin(angle)+cos(angle))';
m{9} = 'count~1+(depth+depth2)*(sin(angle)+cos(angle))';
modelName{5} = 'Disparity * Direction';

% Load the data table
CELLS = anc_storeGLMresults;

% Selects cells which 
% 1) belong to a sessions with valid RF information,
% 2) with significant visual response, 
% 3) and with positive best delay

% CELLS = CELLS(CELLS.VisualResponse > 0,:);

CELLS = CELLS(CELLS.VisualResponse > 0 ...% 1)
        & CELLS.tuning_bestdelay > 0 ... % 2)
        & CELLS.mapping_valid > 0,:); % 3)

%%
out = [];
% close all
fig = figure;
set(fig,'units','centimeters','position',[10   10   18*sizeMult   9*sizeMult])

% AIC Bar plot
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
%          sum(idx == 2 | idx == 3) ...           % Disparity only models
%          sum(idx == 4) ...                      % Direction only model
%          sum(idx == 5 | idx == 6) ...           % Additive interaction models
%          sum(idx == 7 | idx == 8 | idx == 9)... % Multiplicative interaction models 
%          ])./length(idx);
% names = modelName;

DATA = ([sum(idx == 1) ...                      % Null modul
         sum(idx == 2) ... 
         sum(idx == 3) ...           % Disparity only models
         sum(idx == 4) ...                      % Direction only model
         sum(idx == 5) ...
         sum(idx == 6) ...           % Additive interaction models
         sum(idx == 7) ...
         sum(idx == 8) ...
         sum(idx == 9)... % Multiplicative interaction models 
         ]);

names = m; 
     
subplot(1,2,1)
h = barh(1:numel(DATA), diag(DATA), 'stacked');

ax = gca;
ax.YTick = 1:length(names);
ax.YTickLabel = 1:length(names);
set(gca,'TickLabelInterpreter','none')

set(gca,'YDir','reverse');
title('Number of highest BIC weight')
xlabel('')
ylabel('Models')
ylim([0.5 9.5])
%xlim([0 0.5])
ax = gca;
% ax.YTickLabel = [0 1 2 3 4 5 6 7 8 9 10];
grid on
set(gca,'FontSize',12)

model_colors = [0.8 0.8 0.8; ...
                0.6 0.6 0.4; ...
                
                0.6 0.6 0.4; ...
                0.8 0.3 0.4; ...
                
                0.6 0.6 0.4; ...
                0.8 0.3 0.4; ...
                
                0.6 0.6 0.8; ...
                0.6 0.6 0.8; ...
                0.6 0.6 0.8]; 

for f = 1:length(h)
    h(f).FaceColor = model_colors(f,:);
end

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
boxplot(dev * 100,categorical(1:9),'orientation', 'horizontal');
set(gca,'YDir','reverse');
ax = gca;
ax.YTickLabel = '';
xlabel('%')
grid on
set(gca,'FontSize',12)
title('Variance explained across cells')

%%

% %%
% colNames = {'model', 'BIC_w', 'R2', 'RF_area', 'RF_ecce'};
% T = cell2table(cell(0,length(colNames)), 'VariableNames', colNames);
% 
% for i = 1:9
%    nRow = cell2table(cell(1,length(colNames)), 'VariableNames', colNames);
%    nRow.model = i;
%    nRow.BIC_w = idx';
%    nRow.R2 = dev(:,i)';
%    nRow.RF_area = CELLS.RF_area';
%    nRow.RF_ecce = CELLS.RF_eccentricity';   
%    
%    T = vertcat(T,nRow);
% end
% 
% %%
% x = groupsummary(CELLS,{'bestGAM'});
% figure('units','centimeters','position',[0,0,18*sizeMult,9*sizeMult]);
% clear g
% 
% g(1,1) = gramm('x',10-x.bestGAM, 'y',x.GroupCount);
% g(1,1).geom_bar('width',0.9);
% g(1,1).coord_flip();
% 
% g(1,2) = gramm('x',T.model, 'y',T.R2);
% g(1,2).stat_boxplot();
% g(1,2).coord_flip();
% 
% g.draw();
