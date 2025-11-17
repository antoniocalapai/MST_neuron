function data = anc_storeGLMresults
%% Store GLM results of each neuron into the main cell database
user = char(java.lang.System.getProperty('user.name'));
warning('OFF', 'MATLAB:table:RowsAddedExistingVars')

% add tpaths with analysis scripts
addpath(genpath((['/Users/' user '/Dropbox/MST_manuscript/Matlab_scripts'])))
database_path = ['/Users/' user '/Dropbox/MST_manuscript/Databases/'];
fig_path = ['/Users/' user '/Dropbox/MST_manuscript/Figures/'];
R_path = ['/Users/' user '/Dropbox/MST_manuscript/R_models_RogerMundry/2024/'];

% load cell database into CELLS
load([database_path 'Cells.mat'])

% load BIC
% BIC = readtable([R_path 'bic.csv']);

% load BIC's weights
BIC_weights = readtable([R_path 'bic_weights_modified_exp.csv'], 'PreserveVariableNames',true);
% load pseudoR2 
R2 = readtable([R_path 'pseudoR2_modified_exp.csv'], 'PreserveVariableNames',true);

for i = 1:size(BIC_weights, 1)
    idx = CELLS.ID == string(BIC_weights{i, 'file'});
    
    if ~sum(idx)
        disp([string(BIC_weights{i, 'file'}) ' not found!'])
    end

    % Load BIC weigths
    CELLS.GLM_bic_weigths_1(idx) = BIC_weights{i, 2};
    CELLS.GLM_bic_weigths_2(idx) = BIC_weights{i, 3};
    CELLS.GLM_bic_weigths_3(idx) = BIC_weights{i, 4};
    CELLS.GLM_bic_weigths_4(idx) = BIC_weights{i, 5};
    CELLS.GLM_bic_weigths_5(idx) = BIC_weights{i, 6};
    CELLS.GLM_bic_weigths_6(idx) = BIC_weights{i, 7};
    CELLS.GLM_bic_weigths_7(idx) = BIC_weights{i, 8};
    CELLS.GLM_bic_weigths_8(idx) = BIC_weights{i, 9};
    CELLS.GLM_bic_weigths_9(idx) = BIC_weights{i, 10};
    
    % Load pseudo R2
    
    CELLS.GLM_pseudoR2_2(idx) = R2{i, 2};
    CELLS.GLM_pseudoR2_3(idx) = R2{i, 3};
    CELLS.GLM_pseudoR2_4(idx) = R2{i, 4};
    CELLS.GLM_pseudoR2_5(idx) = R2{i, 5};
    CELLS.GLM_pseudoR2_6(idx) = R2{i, 6};
    CELLS.GLM_pseudoR2_7(idx) = R2{i, 7};
    CELLS.GLM_pseudoR2_8(idx) = R2{i, 8};
    CELLS.GLM_pseudoR2_9(idx) = R2{i, 9};
    
end

% save the database
save([database_path 'Cells'],'CELLS');
writetable(CELLS, [database_path 'Cells.csv'],'Delimiter',',')

data = CELLS;
end
