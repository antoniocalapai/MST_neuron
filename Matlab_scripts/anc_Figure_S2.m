%% Figure S2, plot receptive fields size and eccentricity of valid cells
addpath(genpath(('/Users/antoninocalapai/Dropbox/MST_manuscript/Matlab_scripts/')))

database_path = '/Users/antoninocalapai/Dropbox/MST_manuscript/Databases/';
fig_path = '/Users/antoninocalapai/Dropbox/MST_manuscript/Figures/';
load([database_path 'Cells.mat'])

N = [length(CELLS.RF_eccentricity(CELLS.mapping_valid > 0 & CELLS.monkey == 'igg')) ...
     length(CELLS.RF_eccentricity(CELLS.mapping_valid > 0 & CELLS.monkey == 'nic'))];

data(:,1) = CELLS.RF_eccentricity(CELLS.mapping_valid > 0);
data(:,2) = CELLS.RF_area(CELLS.mapping_valid > 0);
monkey = cellstr(CELLS.monkey(CELLS.mapping_valid > 0));

clear g
fig = figure('Position',[100 100 550 550]);

%Create x data histogram on top
g(1,1)=gramm('x',data(:,1),'color',monkey);
g(1,1).set_layout_options('Position',[0 0.8 0.8 0.2],... 
    'legend',false,... 
    'margin_height',[0.02 0.05],... 
    'margin_width',[0.1 0.02],...
    'redraw',false); 
g(1,1).set_names('x','');
g(1,1).stat_bin('geom','stacked_bar','fill','transparent','nbins',15); 
g(1,1).axe_property('XTickLabel',''); 
%g(1,1).axe_property('Xlim',[0 45]); 

%Create a scatter plot
g(2,1)=gramm('x',data(:,1),'y',data(:,2),'color',monkey);
g(2,1).set_names('x','Eccentricity','y','sqrt(are)','color',['N = ' num2str(sum(N))]);
g(2,1).set_point_options('base_size',10);
g(2,1).geom_point('alpha', 0.5); 
g(2,1).set_layout_options('Position',[0 0 0.8 0.8],...
    'legend_pos',[0.83 0.75 0.2 0.2],... %We detach the legend from the plot and move it to the top right
    'margin_height',[0.1 0.02],...
    'margin_width',[0.1 0.02],...
    'redraw',false);
g(2,1).axe_property('Ygrid','on')
g(2,1).axe_property('Xlim',[0 45]); 
%g(2,1).axe_property('Ylim',[0 30]); 

%Create y data histogram on the right
g(3,1)=gramm('x',data(:,2),'color',monkey);
g(3,1).set_layout_options('Position',[0.8 0 0.2 0.8],...
    'legend',false,...
    'margin_height',[0.1 0.02],...
    'margin_width',[0.02 0.05],...
    'redraw',false);
g(3,1).set_names('x','');
g(3,1).stat_bin('geom','stacked_bar','fill','transparent','nbins',15); %histogram
g(3,1).coord_flip();
g(3,1).axe_property('XTickLabel','');
%g(3,1).axe_property('Ylim',[0 30]); 

%Set global axe properties
g.set_text_options('font','Arial',...
    'base_size',12,...
    'label_scaling',1,...
    'legend_scaling',1,...
    'legend_title_scaling',1,...
    'facet_scaling',1,...
    'title_scaling',1);
g.axe_property('TickDir','out','XGrid','on','GridColor',[0.5 0.5 0.5]);
g.set_title('Receptive fields size and distance from fovea');
g.set_color_options('map','d3_10');
g.draw();

% name = ([fig_path 'Figure_S2']);
% print(fig,name,'-depsc')
% close all
