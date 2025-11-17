function anc_TetrodeCheck(mwk)
%% This function checks if units are counted multiple times in the raw data
% it is mainly used for tetrode and it is based on the total number of
% spikes of any given cell.

% store path of the current directory and go inside the raw directory
current_dir = pwd; cd(mwk)

% Load the Spikes for this session
load('ml_spikes_v1.mat') 

% get original spikes data and times
spikes.data = [osSpikes.data];
spikes.time = [osSpikes.time];

% get unique cells' channel info
spikes.units = unique(spikes.data);

% remove channel 1.1 
spikes.units(spikes.units == 1.1) = [];

UNIT = [];
for i = 1:length(spikes.units)

    % cycle trough the cells and count the number of spikes. 
    temp(i) = sum(spikes.data == spikes.units(i));
    
    % if this is the first time this cells is counted, store it
    if sum(temp == sum(spikes.data == spikes.units(i))) == 1; % new cell
        UNIT(end+1).time = spikes.time(spikes.data == spikes.units(i));
        UNIT(end).data = spikes.data(spikes.data == spikes.units(i));
    end
    % otherwise go on and ignore the current cell
end

% delete the raw spikes and replace it with the new structure
osSpikes = [];
osSpikes.data = [UNIT.data];
osSpikes.time = [UNIT.time];

% save the mat structure
save('anc_SPIKES.mat','osSpikes')

% go back to the starting folder
cd(current_dir)
end