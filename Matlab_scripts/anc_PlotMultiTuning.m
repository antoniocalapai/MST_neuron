function anc_PlotMultiTuning(cell_ID, TUNING, destination, saving)
% This function plots the response to disparity and direction at different
% latencies.

% parameters are the cell id (cell_ID), the entire mapping matrix (TUNING),
% the destination folder where the plot will be saved (destination), and a
% boolean field (saving) if the plot will be saved before being closed.

fig = figure('rend','painters','pos',[1094 1 827 1104]);
colormap gray; colormap(1 - colormap)
vector = flip(0:40000:440000);

for i = 1:length(vector)
    subtightplot(4,3,i,[0 0])
    
    % the matrix is plotted after being smoothed with convolution kernel
    F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
    latency = TUNING.lists.delay == vector(i);
    
    Z = conv2(TUNING.relative.linear(:,:,latency)',F,'same');
    imagesc(Z,[0 1]); hold on
    
    colormap gray; colormap(1 - colormap)
    
    text(1,8,[num2str(vector(i)/1000) ' ms'],...
        'Color', 'k', 'FontSize',12,'BackgroundColor','white')
    
    if i == find(vector > TUNING.info.bestdelay & vector < TUNING.info.bestdelay + 40000)
        text(1,8,[num2str(vector(i)/1000) ' ms'],...
            'Color', 'r', 'FontSize',12,'BackgroundColor','white')
    end
    
    set(gca,'YDir','normal')
    
    ax = gca;
    
    ax.XTick = 1:length([TUNING.lists.direction]);
    ax.YTick = 1:length([TUNING.lists.disparity]);
    ax.XTickLabel = TUNING.lists.direction;
    ax.YTickLabel = TUNING.lists.disparity;
    
    xlabel('Direction')
    ylabel('Disparity')
    
    if i ~= 10
        set(gca,'xticklabel',[])
        set(gca,'xlabel',[])
        set(gca,'xtick',[])
        set(gca,'yticklabel',[])
        set(gca,'ylabel',[])
        set(gca,'ytick',[])
        hold off
    end
    
    set(gca,'FontSize',12)
    
    if i == 2
        title(cell_ID,'FontSize',15)
    end
    
end

if saving
    name = ([destination cell_ID '_multi.png']);
    saveas(fig,name)
    close all
end

end