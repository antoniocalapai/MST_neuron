%% Extract and save the spike count table for the GAMs
% ================= Set the destination directories ======================
user = char(java.lang.System.getProperty('user.name'));
warning('OFF', 'MATLAB:table:RowsAddedExistingVars')

addpath(genpath((['/Users/' user '/Dropbox/MST_manuscript/Matlab_scripts'])))
database_path = ['/Users/' user '/Dropbox/MST_manuscript/Databases/'];

DATA_dir = ['/Users/' user '/Dropbox/MST_manuscript/Cells_matfiles/'];
Rpath = ['/Users/' user '/Dropbox/MST_manuscript/CellsValid_csv/'];

load([database_path 'Cells.mat'])

for i = 1:size(CELLS,1)
    if CELLS.VisualResponse(i)
        disp(['Exporting csv for cell ' + CELLS.ID(i)]);
        load([DATA_dir + CELLS.ID(i) + '-forGLM.mat'])
        writetable(SPIKETABLE,[Rpath + CELLS.ID(i) + '.csv'],'Delimiter',',')
    end
end



% 
% % only include cells with visual response significanlty different from baseline 
% valid_sessions = CELLS.session(CELLS.VisualResponse > 0);
% for j = 1:length(valid_sessions)
%     ses = valid_sessions{j};
%     
%     CELLS.include(CELLS.mapping_valid >= 0 & ...
%                   CELLS.VisualResponse == 1) = 1;
% end
% 
% save([database_path 'Cells'],'CELLS');
% disp(['Number of valid cells for GLM: ' + string(sum(CELLS.include))])
% 
% % Extract a csv file for each valid cell
% valid_cells_idx = CELLS.ID(CELLS.include);
% for i = 1:length(valid_cells_idx)
%     disp(['Exporting csv for cell ' + valid_cells_idx(i) + ...
%         ' mapping_valid = ' + CELLS.mapping_valid(CELLS.ID == valid_cells_idx(i)) + ...
%         '; visual response = ' + CELLS.VisualResponse(CELLS.ID == valid_cells_idx(i))]);
%         
%     load([DATA_dir + valid_cells_idx(i) + '-forGLM.mat'])
%     writetable(SPIKETABLE,[Rpath + valid_cells_idx(i) + '.csv'],'Delimiter',',')
% end

           