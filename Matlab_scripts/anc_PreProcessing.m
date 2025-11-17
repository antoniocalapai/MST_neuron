function anc_PreProcessing
%% Pre processing raw data files for MST D&D manuscript
% acalapai@dpz.eu 2021
% ================= Set the destination directories ======================
user = char(java.lang.System.getProperty('user.name'));
warning('OFF', 'MATLAB:table:RowsAddedExistingVars')

% add paths with analysis scripts
addpath(genpath((['/Users/' user '/Dropbox/MST_manuscript/Matlab_scripts'])))

DATA_dir = '/Volumes/DPZ/KognitiveNeurowissenschaften/CNL/DATA/anc/ElectroPhysiology/MultiFeature/';
CELLS_dir = ['/Users/' user '/Dropbox/MST_manuscript/Cells_matfiles/'];

session = dir([DATA_dir '*MERGED*']);

% ================= Main loop ====================
for j = 1:length(session)
    
    % store session name
    ses = session(j).name;
    
    % move to session's folder
    cd([DATA_dir ses])
    
    % create a list of all MWorks (mwk) and Plexon (plx) sorted files
    files_mwk = dir('*.mwk');
    files_plx = dir('*.plx');
    
    %% cycle through each file
%     for fl = 1:length(files_mwk)
%         % extract raw data: spikes and experiment
%         MW_readExperiment(files_mwk(fl).name);
%         MW_importSortedSpikes(files_mwk(fl).name, files_plx.name);
% 
%         % check if tetrode was used and correct for multiple units
%         anc_TetrodeCheck(files_mwk(fl).name);
%     end
%     
%     %% extract probablity maps for receptive field
%     anc_ExtractReceptiveField(DATA_dir, ses, CELLS_dir);
    
    %% extract probablity maps for direction and disparity tuning
    anc_ExtractMultiTuning(DATA_dir, ses, CELLS_dir);
    anc_CheckVisualResponse(DATA_dir, ses, CELLS_dir, 1);
    anc_ExtractSpikeTable(DATA_dir, ses, CELLS_dir)
    
end
end