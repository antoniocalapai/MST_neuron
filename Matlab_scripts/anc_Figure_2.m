%% Create Figure 2 for the MST manuscript
% The plot is manually saved and post processed in affiniti designer
% acalapai@dpz.eu May 2020

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

cells_list = {'igg-071-02+01-137.2-tuning.mat',...
              'igg-061-01+01-137.4-tuning.mat',...
              'igg-073-01+01-137.1-tuning.mat',...
              'igg-074-01+01-137.2-tuning.mat'};

%figure('rend','painters','pos',[2635 422 1107 1070])
close all
fig = figure;
set(fig,'units','centimeters','position',[160   318   19   19])

%% ============================================================
F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
A1 = subplot(6,6,[8 9 14 15]);
load([CELLS_dir cells_list{1}])
latency = find(TUNING.lists.delay == TUNING.info.bestdelay, 1);
S = TUNING.multi.linear(:,:,latency);
Z = conv2(TUNING.multi.linear(:,:,latency),F,'same');
Zc = conv2(TUNING.relative.linear(:,:,latency),F,'same');
W = binocdf(S,sum(sum(S)),1/(size(S,1)*size(S,2)));
A1 = imagesc(Z'); hold on
colormap gray; colormap(1 - colormap)
% spy(sparse(W>0.95)','r*', 1)
ax = gca;
ax.YAxisLocation = 'right';
ax.XTick = 1:length([TUNING.lists.direction]);
ax.YTick = 1:length([TUNING.lists.disparity]);
ax.XTickLabel = TUNING.lists.direction;
ax.YTickLabel = TUNING.lists.disparity;
xlabel([]);
set(gca,'FontSize',10)
text(1.5,8,cells_list{1}(1:end-11))

A2 = subplot(6,6,[2 3]);
A2 = plot(Z./sum(sum(Z)),'LineWidth',1.5); 
yline(1/(8*8),'LineStyle',':','Color','k','LineWidth',2)
xlim([0.5 8.5])
ylim([0 0.0625])
ax = gca;
ax.YAxisLocation = 'right';
ax.XTick = 1:length([TUNING.lists.direction]);
ax.XTickLabel = [];
ax.YTick = 0:0.0156:0.0625;
ax.YTickLabel = {'0','c','2*c','3*c','4*c'}; % change this
grid on
set(gca,'FontSize',10)

A3 = subplot(6,6,[7 13]);
A3 = plot(Z'./sum(sum(Z)),'LineWidth',1.5);
yline(1/(8*8),'LineStyle',':','Color','k','LineWidth',2)
camroll(-90)
xlim([0.5 8.5])
ylim([0 0.0625])
set(gca,'YDir','reverse');
ax = gca;
ax.YAxisLocation = 'right';
ax.XTick = 1:length([TUNING.lists.direction]);
ax.XTickLabel = [];
ax.YTick = 0:0.0156:0.0625;
ax.YTickLabel = {'0','c','2*c','3*c','4*c'};
grid on
set(gca,'FontSize',10)


%% ============================================================
B1 = subplot(6,6,[10 11 16 17]);
load([CELLS_dir cells_list{2}])
latency = find(TUNING.lists.delay == TUNING.info.bestdelay, 1);
S = TUNING.multi.linear(:,:,latency);
Z = conv2(TUNING.multi.linear(:,:,latency),F,'same');
Zc = conv2(TUNING.relative.linear(:,:,latency),F,'same');
W = binocdf(S,sum(sum(S)),1/(size(S,1)*size(S,2)));
B1 = imagesc(S);hold on
colormap gray; colormap(1 - colormap)
% spy(sparse(W>0.95)','r*', 1)
ax = gca;
ax.XTick = 1:length([TUNING.lists.direction]);
ax.YTick = 1:length([TUNING.lists.disparity]);
ax.XTickLabel = TUNING.lists.direction;
ax.YTickLabel = [];
xlabel([]);
set(gca,'FontSize',10)
text(1.5,8,cells_list{2}(1:end-11))

B2 = subplot(6,6,[4 5]);
B2 = plot(Z./sum(sum(Z)),'LineWidth',1.5);
xlim([0.5 8.5])
yline(1/(8*8),'LineStyle',':','Color','k','LineWidth',2)
xlim([0.5 8.5])
ylim([0 0.0625])
ax = gca;
ax.XTick = 1:length([TUNING.lists.direction]);
ax.XTickLabel = [];
ax.YTick = 0:0.0156:0.0625;
ax.YTickLabel = [];
grid on
set(gca,'FontSize',10)

B3 = subplot(6,6,[12 18]);
B3 = plot(Z'./sum(sum(Z)),'LineWidth',1.5);
camroll(-90)
xlim([0.5 8.5])
yline(1/(8*8),'LineStyle',':','Color','k','LineWidth',2)
ylim([0 0.0625])
ax = gca;
ax.YAxisLocation = 'right';
ax.XTick = 1:length([TUNING.lists.direction]);
ax.XTickLabel = [];
ax.YTick = 0:0.0156:0.0625;
ax.YTickLabel = {'0','c','2*c','3*c','4*c'};
grid on
set(gca,'FontSize',10)

%% ============================================================
C1 = subplot(6,6,[20 21 26 27]);
load([CELLS_dir cells_list{3}])
latency = find(TUNING.lists.delay == TUNING.info.bestdelay, 1);
S = TUNING.multi.linear(:,:,latency);
Z = conv2(TUNING.multi.linear(:,:,latency),F,'same');
Zc = conv2(TUNING.relative.linear(:,:,latency),F,'same');
W = binocdf(S,sum(sum(S)),1/(size(S,1)*size(S,2)));
C1 = imagesc(Z');hold on
colormap gray; colormap(1 - colormap)
% spy(sparse(W>0.95)','r*', 1)
ax = gca;
ax.YAxisLocation = 'right';
ax.XTick = 1:length([TUNING.lists.direction]);
ax.YTick = 1:length([TUNING.lists.disparity]);
ax.XTickLabel = [];
ax.YTickLabel = TUNING.lists.disparity;
xlabel([]);
set(gca,'FontSize',10)
text(1.5,8,cells_list{3}(1:end-11))

C2 = subplot(6,6,[19 25]);
C2 = plot(Z'./sum(sum(Z)),'LineWidth',1.5);
camroll(-90)
set(gca,'YDir','reverse');
xlim([0.5 8.5])
yline(1/(8*8),'LineStyle',':','Color','k','LineWidth',2)
ylim([0 0.0625])
ax = gca;
ax.XTick = 1:length([TUNING.lists.direction]);
ax.XTickLabel = [];
ax.YTick = 0:0.0156:0.0625;
ax.YTickLabel = [];
grid on
set(gca,'FontSize',10)

C3 = subplot(6,6,[32 33]);
C3 = plot(Z./sum(sum(Z)),'LineWidth',1.5);
xlim([0.5 8.5])
set(gca,'YDir','reverse');
yline(1/(8*8),'LineStyle',':','Color','k','LineWidth',2)
ylim([0 0.0625])
ax = gca;
ax.YAxisLocation = 'right';
ax.XTick = 1:length([TUNING.lists.direction]);
ax.XTickLabel = [];
ax.YTick = 0:0.0156:0.0625;
ax.YTickLabel = {'0','c','2*c','3*c','4*c'};
grid on
set(gca,'FontSize',10)


%% ============================================================
D1 = subplot(6,6,[22 23 28 29]);
load([CELLS_dir cells_list{4}])
latency = find(TUNING.lists.delay == TUNING.info.bestdelay, 1);
S = TUNING.multi.linear(:,:,latency);
Z = conv2(TUNING.multi.linear(:,:,latency),F,'same');
Zc = conv2(TUNING.relative.linear(:,:,latency),F,'same');
W = binocdf(S,sum(sum(S)),1/(size(S,1)*size(S,2)));
D1 = imagesc(Z');hold on
colormap gray; colormap(1 - colormap)
% spy(sparse(W>0.95)','r*', 1)
ax = gca;
ax.XTick = 1:length([TUNING.lists.direction]);
ax.YTick = 1:length([TUNING.lists.disparity]);
ax.XTickLabel = [];
ax.YTickLabel = [];
xlabel([]);
set(gca,'FontSize',10)
text(1.5,8,cells_list{4}(1:end-11))

D2 = subplot(6,6,[34 35]);
D2 = plot(Z./sum(sum(Z)),'LineWidth',1.5);
xlim([0.5 8.5])
set(gca,'YDir','reverse');
yline(1/(8*8),'LineStyle',':','Color','k','LineWidth',2)
ylim([0 0.0625])
ax = gca;
ax.XTick = 1:length([TUNING.lists.direction]);
ax.XTickLabel = [];
ax.YTick = 0:0.0156:0.0625;
ax.YTickLabel = [];
grid on
set(gca,'FontSize',10)

D3 = subplot(6,6,[24 30]);
D3 = plot(Z'./sum(sum(Z)),'LineWidth',1.5);
camroll(-90)
xlim([0.5 8.5])
yline(1/(8*8),'LineStyle',':','Color','k','LineWidth',2)
ylim([0 0.0625])
ax = gca;
ax.YAxisLocation = 'right';
ax.XTick = 1:length([TUNING.lists.direction]);
ax.XTickLabel = [];
ax.YTick = 0:0.0156:0.0625;
ax.YTickLabel = [];
grid on
set(gca,'FontSize',10)
