% %% Flip by 180 all the direction labels for all far stimuli (disparity > 0)
% %This runs only once AND before the R code is run
DATA_dir = '/Users/acalapai/Dropbox/MST_manuscript/Cells_matfiles/';
Rpath = '/Users/acalapai/Dropbox/MST_manuscript/R_scripts/INPUT/';
CELLS = dir([DATA_dir '*GAM*']);

for i = 1:length(CELLS)    
    load([DATA_dir CELLS(i).name])
    SPIKETABLE.direction_flip = zeros(size(SPIKETABLE,1),1);
    
    V = SPIKETABLE.direction;
    for j = 1:size(SPIKETABLE,1)
        if SPIKETABLE.disparity(j) > 0
            V(j) = mod(V(j) + 180, 360);            
        end
    end
    
    SPIKETABLE.direction_flip = V;
    writetable(SPIKETABLE,[Rpath CELLS(i).name(1:end-8) '-flip' '.csv'],'Delimiter',',')
        
end

%% BEFORE the next step, the R code has to be run 

%% Extract GAM results from each cell csv to the main cell database
% clear all
% 
% database_path = '/Users/acalapai/Dropbox/MST_manuscript/Databases/';
% fig_path = '/Users/acalapai/Dropbox/MST_manuscript/Figures/';
% R_path = '/Users/acalapai/Dropbox/MST_manuscript/R_scripts/OUTPUT_flip/';
% 
% load([database_path 'Cells.mat'])
% cells_list = dir([R_path '*.csv']);
% 
% for i = 1:length(cells_list)    
%     T = readtable([R_path cells_list(i).name]);
%     idx = CELLS.ID == cells_list(i).name(3:end-9);
%     
%     % Load AIC results
%     CELLS.GAM_aic_5(idx) = T.AIC(4);
%     %CELLS.GAM_aic_6(idx) = T.AIC(5);
%     
%     % Load absolute deviance explained
%     CELLS.GAM_dev_5(idx) = T.dev_expl(4);
%     %CELLS.GAM_dev_6(idx) = T.dev_expl(5);
% end
% 
% % dave the database  
% save([database_path 'Cells'],'CELLS');

%% PLOT Flip Models
fig = figure;
set(fig,'units','centimeters','position',[160   318   13.16*2   7.55*2])

database_path = '/Users/acalapai/Dropbox/MST_manuscript/Databases/';
fig_path = '/Users/acalapai/Dropbox/MST_manuscript/Figures/';
load([database_path 'Cells.mat'])

% AIC Bar plot
aic = [CELLS.GAM_aic_0(CELLS.include) ...
    CELLS.GAM_aic_1(CELLS.include) ...
    CELLS.GAM_aic_2(CELLS.include) ...
    CELLS.GAM_aic_3(CELLS.include) ...
    CELLS.GAM_aic_4(CELLS.include) ...
    CELLS.GAM_aic_5(CELLS.include)];

[~,idx] = min(aic,[],2);

DATA = ([sum(idx == 1) sum(idx == 2) sum(idx == 3) ...
    sum(idx == 4) sum(idx == 5) sum(idx == 6)])./length(idx);

h = barh(1:numel(DATA), diag(DATA), 'stacked');
set(gca,'YDir','reverse');
title('Percentage of lowest AIC value')
set(gca,'FontSize',20)
xlabel('%')
ylabel('models')
ax = gca;
ax.YTickLabel = [0 1 2 3 4 5];
grid on
set(gca,'FontSize',20)

% Histograms of Deviance
%% Model histograms
% normalize deviance explained:

dev = [CELLS.GAM_dev_0(CELLS.include) ...
    CELLS.GAM_dev_1(CELLS.include) ...
    CELLS.GAM_dev_2(CELLS.include) ...
    CELLS.GAM_dev_3(CELLS.include) ...
    CELLS.GAM_dev_4(CELLS.include) ...
    CELLS.GAM_dev_5(CELLS.include)];

quants = [];
for i = 1:size(dev,2)
    quants(:,i) = quantile(dev(:,i),[0:0.01:1]);
end

% n_dev = [CELLS.GAM_n_dev_0(CELLS.include) ...
%     CELLS.GAM_n_dev_1(CELLS.include) ...
%     CELLS.GAM_n_dev_2(CELLS.include) ...
%     CELLS.GAM_n_dev_3(CELLS.include) ...
%     CELLS.GAM_n_dev_4(CELLS.include) ...
%     CELLS.GAM_n_dev_5(CELLS.include)];

fig = figure;
title('Deviance explained')   
for i = 1:size(dev,2)
    subplot(6,1,i)
    h = histogram([dev(:,i)],100);
%     set(gca,'xticklabel',[])
%     set(gca,'xlabel',[])
%     set(gca,'yticklabel',[])
%     set(gca,'ylabel',[])
%     set(gca,'FontSize',10)
    title(['model ' num2str(i-1)])
    xline(median(dev(:,i)),'LineStyle',':','Color','r','LineWidth',2)
%     ylim([0 100])
    xlim([0 0.05])
    set(gca,'FontSize',15)
    grid on
end


%% Matrix of quantiles
fig = figure;
set(fig,'units','centimeters','position',[160   318   20   15])
imagesc(quants')
colorbar
colormap(1-gray)
ax = gca;
ax.YTickLabel = [0 1 2 3 4 5];
ax.XTickLabel = [flip(0:20:100)];
xlabel('Percentage of Neurons');
ylabel('Models');
zlabel('%');
set(gca,'FontSize',15)
title('Deviance explained')

%% Heat Maps of Neurons with best model = 5
aic = [CELLS.GAM_aic_0(CELLS.include & CELLS.mapping) ...
    CELLS.GAM_aic_1(CELLS.include & CELLS.mapping) ...
    CELLS.GAM_aic_2(CELLS.include & CELLS.mapping) ...
    CELLS.GAM_aic_3(CELLS.include & CELLS.mapping) ...
    CELLS.GAM_aic_4(CELLS.include & CELLS.mapping) ...
    CELLS.GAM_aic_5(CELLS.include & CELLS.mapping)];

[~,idx] = min(aic,[],2);

ids = CELLS.ID(CELLS.include & CELLS.mapping);

mFive = ids(idx==6);
for i=1:length(mFive)
    subplot(ceil(sqrt(length(mFive))),floor(sqrt(length(mFive))),i)
    image(imread(strcat...
        ('/Users/acalapai/Dropbox/MST_manuscript/Plots/MultiTuning_evaluated/',...
        mFive(i),'-tuning_eval.png')))
end

mFour = ids(idx==5);
for i=1:length(mFour)
    subplot(ceil(sqrt(length(mFour))),floor(sqrt(length(mFour))),i)
    image(imread(strcat...
        ('/Users/acalapai/Dropbox/MST_manuscript/Plots/MultiTuning_evaluated/',...
        mFour(i),'-tuning_eval.png')))
end


%% Model 5
% m5 = [];
% for j = 1:length(mFive)    
%     m5(j,:) = [CELLS.GAM_aic_0(CELLS.ID == mFive(j)) ...
%         CELLS.GAM_aic_1(CELLS.ID == mFive(j)) ...
%         CELLS.GAM_aic_2(CELLS.ID == mFive(j)) ...
%         CELLS.GAM_aic_3(CELLS.ID == mFive(j)) ...
%         CELLS.GAM_aic_4(CELLS.ID == mFive(j))];
% end
% 
% I = [];
% for j = 1:length(mFive)
%     [~,I(j)] = max(m5(j,:));
% end
% 
% figure
% histogram(I,'Orientation', 'horizontal');
% set(gca,'YDir','reverse');
% set(gca,'FontSize',20)
% ylabel('models')
% ax = gca;
% ax.YTickLabel = [0 1 2 3 4];
% grid on