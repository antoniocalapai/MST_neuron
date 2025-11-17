function data = anc_storeGAMresults
%% Extract GAM results from each cell csv to the main cell database  
user = char(java.lang.System.getProperty('user.name'));
warning('OFF', 'MATLAB:table:RowsAddedExistingVars')

% add tpaths with analysis scripts
addpath(genpath((['/Users/' user '/Dropbox/MST_manuscript/Matlab_scripts'])))
database_path = ['/Users/' user '/Dropbox/MST_manuscript/Databases/'];
fig_path = ['/Users/' user '/Dropbox/MST_manuscript/Figures/'];
R_path = ['/Users/' user '/Dropbox/MST_manuscript/R_models_RogerMundry/'];

load([database_path 'Cells.mat'])
cells_list = dir([R_path '*.csv']);

for i = 1:length(cells_list)    
    T = readtable([R_path cells_list(i).name]);
    idx = CELLS.ID == cells_list(i).name(3:end-4);
    
    % Load AIC results
    CELLS.GAM_aic_0(idx) = T.AIC(1);
    CELLS.GAM_aic_1(idx) = T.AIC(2);
    CELLS.GAM_aic_2(idx) = T.AIC(3);
    CELLS.GAM_aic_3(idx) = T.AIC(4);
    CELLS.GAM_aic_4(idx) = T.AIC(5);
    CELLS.GAM_aic_5(idx) = T.AIC(6);
    CELLS.GAM_aic_6(idx) = T.AIC(7);
    CELLS.GAM_aic_7(idx) = T.AIC(8);
    CELLS.GAM_aic_8(idx) = T.AIC(9);
    CELLS.GAM_aic_9(idx) = T.AIC(10);
    CELLS.GAM_aic_10(idx) = T.AIC(11);
    CELLS.GAM_aic_11(idx) = T.AIC(12);
    
    
    % Load absolute deviance explained
    CELLS.GAM_dev_0(idx) = T.dev_expl(1);
    CELLS.GAM_dev_1(idx) = T.dev_expl(2);
    CELLS.GAM_dev_2(idx) = T.dev_expl(3);
    CELLS.GAM_dev_3(idx) = T.dev_expl(4);
    CELLS.GAM_dev_4(idx) = T.dev_expl(5);
    CELLS.GAM_dev_5(idx) = T.dev_expl(6);
    CELLS.GAM_dev_6(idx) = T.dev_expl(7);
    CELLS.GAM_dev_7(idx) = T.dev_expl(8);
    CELLS.GAM_dev_8(idx) = T.dev_expl(9);
    CELLS.GAM_dev_9(idx) = T.dev_expl(10);
    CELLS.GAM_dev_10(idx) = T.dev_expl(11);
    CELLS.GAM_dev_11(idx) = T.dev_expl(12);
    
end

data = CELLS;

% dave the database  
% save([database_path 'Cells'],'CELLS');
