%% anc_AnalysisOutput
addpath(genpath(('/Users/acalapai/Dropbox/MST_manuscript/Matlab_scripts')))
database_path = '/Users/acalapai/Dropbox/MST_manuscript/Databases/';
destination = '/Users/acalapai/Dropbox/MST_manuscript/';

load([database_path 'Cells.mat'])
out = [];

% Descriptive Statistics on cell population
out{end+1} = ['Total number of cells: ' ...
              num2str(size(CELLS,1))];
          
out{end+1} = ['Total number of cells for igg: ' ...
              num2str(sum(CELLS.monkey == 'igg'))]; 
          
out{end+1} = ['Total number of cells for nic: ' ...
              num2str(sum(CELLS.monkey == 'nic'))]; 
          
out{end+1} = ['Total number of cells with mapping and tuning: ' ...
              num2str(sum(CELLS.mapping & CELLS.tuning))];                
          
out{end+1} = ['Total number of cells with mapping but no tuning: ' ...
              num2str(sum(CELLS.mapping & ~CELLS.tuning))];          

out{end+1} = ['Total number of cells with tuning but no mapping: ' ...
              num2str(sum(~CELLS.mapping & CELLS.tuning))];   
          
out{end+1} = ['Total number of cells with available mapping: ' ...
              num2str(sum(CELLS.mapping))];
                   
out{end+1} = ['Total number of cells with available tuning: ' ...
              num2str(sum(CELLS.tuning))];   
          
out{end+1} = ['Number of cells with valid mapping: ' ...
              num2str(sum(CELLS.mapping_valid > 0))];
                           
out{end+1} = ['Total number of cells with valid mapping (igg): ' ...
              num2str(sum(CELLS.mapping_valid > 0 & CELLS.monkey == 'igg'))];
          
out{end+1} = ['Total number of cells with valid mapping (nic): ' ...
              num2str(sum(CELLS.mapping_valid > 0 & CELLS.monkey == 'nic'))];
          
out{end+1} = ['Number of cells with valid mapping and available tuning: ' ...
              num2str(sum(CELLS.tuning & CELLS.mapping_valid > 0))];

out{end+1} = ['Number of cells with significant visual response, belonging to a penetration with a valid mapped cell: ' ...
              num2str(sum(CELLS.include))];

out{end+1} = ['Number of cells with significant visual response, belonging to a penetration with a valid mapped cell (igg): ' ...
              num2str(sum(CELLS.include & CELLS.monkey == 'igg'))];          

out{end+1} = ['Number of cells with significant visual response, belonging to a penetration with a valid mapped cell (nic): ' ...
              num2str(sum(CELLS.include & CELLS.monkey == 'nic'))];              

% Statistics of RF:
out{end+1} = ['Number of units manually fit: ' ...
              num2str(sum(CELLS.mapping_valid == 5))]; 

out{end+1} = ['Mean R2 of receptive field fit for of valid cells (non manual): ' ...
              num2str(mean(CELLS.RF_goodnessOfFit(CELLS.mapping_valid > 0 & CELLS.mapping_valid < 5)))]; 
          
out{end+1} = ['Standard deviation of receptive field fit for of valid cells (non manual): ' ...
              num2str(std(CELLS.RF_goodnessOfFit(CELLS.mapping_valid > 0 & CELLS.mapping_valid < 5)))];   
          
out{end+1} = ['Mean area of receptive field of valid cells: ' ...
              num2str(mean(CELLS.RF_area(CELLS.mapping_valid > 0)))]; 
          
out{end+1} = ['Standard deviation of receptive area field of valid cells: ' ...
              num2str(std(CELLS.RF_area(CELLS.mapping_valid > 0)))]; 
          
out{end+1} = ['Mean eccentricity of receptive field of valid cells: ' ...
              num2str(mean(CELLS.RF_eccentricity(CELLS.mapping_valid > 0)))]; 
          
out{end+1} = ['Standard deviation of eccentricity receptive area field of valid cells: ' ...
              num2str(std(CELLS.RF_eccentricity(CELLS.mapping_valid > 0)))]; 
          
% Statistics from GAM models
GAM = anc_Figure_3(0);

out{end+1} = ['Figure 3, Number of cells included in GAM models: ' ...
              num2str(sum(CELLS.include))];   

out{end+1} = ['Figure 3, Occurrences of lowest AIC by model: ' ...
              num2str(GAM.AIC)];

out{end+1} = ['Figure 3, Relative deviance explained by model: ' ...
              num2str(GAM.rel_expl_dev)];
          
out{end+1} = ['Figure 3, Average (50th quantile) deviance explained by model: ' ...
              num2str(GAM.abs_expl_dev_50)];    
          
out{end+1} = ['Figure 3, 70th quantile deviance explained by model: ' ...
              num2str(GAM.abs_expl_dev_70)];  

out{end+1} = ['Figure 3, 90th quantile deviance explained by model: ' ...
              num2str(GAM.abs_expl_dev_90)];  

out{end+1} = ['Figure 3, Max deviance explained by model: ' ...
              num2str(GAM.abs_expl_dev_max)];       
          
out{end+1} = ['Figure 3, ttest between absolute deviance 3 and 4 (quantiles): ' ...
              ['t(' num2str(GAM.tt3vs4.STATS.df) ') = ' num2str(GAM.tt3vs4.STATS.tstat) ', p = ' num2str(GAM.tt3vs4.P)]];            
          
fileName = 'Analysis_Output.txt';
fid = fopen([destination fileName],'w');
fprintf(fid, [['MST D&D manuscript analysis output; acalapai@dpz.eu; '...
                num2str(date)]  '\n']);

for i = 1:size(out,2)
    fprintf(fid, [['- ' out{i}]  '\n']);
end

fclose(fid);
