%% Figure S1 for the MST manuscript plotting an example fitted receptive
% field from the population.
% the figure is saved manually
cells_path = '/Users/acalapai/Dropbox/MST_manuscript/Cells_matfiles/';
video_path = '/Users/acalapai/Dropbox/MST_manuscript/Videos/';
fig_path = '/Users/acalapai/Dropbox/MST_manuscript/Figures/';
example_cell = 'igg-062-02+01-133.1-RFmapp.mat';
load([cells_path example_cell])

fig = figure('rend','painters','pos',[893 1 867 583]);
colormap gray; colormap(1 - colormap)

vector = [-15 -5 -2 0 8 16];
for i = 1:length(vector)
    subtightplot(2,3,i,[0 0])
    
    bestdelay = find(MAPPING.info.delay == MAPPING.info.bestdelay);
    F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
    
    Z = conv2(MAPPING.cell.relative(:,:,bestdelay+vector(i)),F,'same');
    
    imagesc(Z,[0 1]); hold on
    colormap gray; colormap(1 - colormap)
    
    text(1,2,[num2str(-MAPPING.info.delay(bestdelay+vector(i))/1000) ' ms'],...
        'Color', 'r', 'FontSize',12,'BackgroundColor','white')
    
    try
        if ~isempty(find(MAPPING.info.x_list == 0, 1))
            h = plot(find(MAPPING.info.x_list == 0),...
                find(MAPPING.info.y_list == 0),'+r');
            set(h,{'markers'},{15})
        end
    end
    
    set(gca,'Ytick',1:4:length(MAPPING.info.y_list),'YTickLabel',...
        {sort(MAPPING.info.y_list(1):4:MAPPING.info.y_list(end),'descend')},'FontSize',14);
    set(gca,'Xtick',1:4:length(MAPPING.info.x_list),'XTickLabel',...
        {MAPPING.info.x_list(1):4:MAPPING.info.x_list(end)},'FontSize',14);
    
    if i ~= 4
        set(gca,'xticklabel',[])
        set(gca,'xlabel',[])
        set(gca,'xtick',[])
        set(gca,'yticklabel',[])
        set(gca,'ylabel',[])
        set(gca,'ytick',[])
        hold off
    end
    
    switch i
        case{2}
            title(example_cell(1:end-11))
        case{4}
            xCenter = sum(MAPPING.info.x_list <= int16(mode([MAPPING.info.FitRes.cx])));
            yCenter = sum(MAPPING.info.y_list <= int16(mode([MAPPING.info.FitRes.cy])));
            gf = mode([MAPPING.info.FitRes.gf]);
            h = ellipse(mode([MAPPING.info.FitRes.s1]),mode([MAPPING.info.FitRes.s2]),...
                mode([MAPPING.info.FitRes.angl]),xCenter,yCenter,'r');
            
            ylim = get(gca,'ylim');
            
            set(h,'linewidth',5)
            set(h,'linestyle','--')
            text(1, ylim(2)-2, ['area = ' num2str(mode([MAPPING.info.FitRes.area]),'%4.1f')]...
                ,'FontSize',12,'FontWeight','bold','BackgroundColor','white');
            text(1, ylim(2)-5, ['ecce = ' num2str(mode([MAPPING.info.FitRes.ecce]),'%4.1f')]...
                ,'FontSize',12,'FontWeight','bold','BackgroundColor','white');
            text(1, ylim(2)-8, ['R^2 = ' num2str(gf,'%4.2f')],...
                'FontSize',12,'FontWeight','bold','BackgroundColor','white');
            set(gca,'FontName', 'Palatino');
    end
    set(gca,'FontSize',12)
end

name = ([fig_path 'Figure_S1']);
print(fig,name,'-depsc')
close all

%% Produce a video for the same example cell
aviobj = VideoWriter([video_path example_cell(1:end-4) '.avi'],'Uncompressed AVI');
aviobj.FrameRate = 5;
open(aviobj)

F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
MAT = flip(MAPPING.cell.relative,3);
DEL = flip(MAPPING.info.delay);
Z = []; V = [];
for i = 1:length(MAPPING.info.delay)
    Z(:,:,i) = conv2(MAT(:,:,(i)),F,'same');
    V(i) = var(reshape(Z(:,:,i)',1,numel(Z(:,:,i))));
end

for i = 35:71
    frame = imagesc(Z(:,:,i),[0 max(max(max(Z)))]);
    hold on
    colormap gray
    colormap(1-colormap)
    
    text(36, 5, num2str(-DEL(i)/1000),'FontSize',20,'FontWeight','bold','BackgroundColor','white');
    %legend(num2str(MAPPING.info.delay(MAPPING.info.delay_rev(d))/1000));
    
    set(gca, 'Ytick', 1:4:length(MAPPING.info.y_list), 'YTickLabel', {sort(MAPPING.info.y_list(1):4:MAPPING.info.y_list(end), 'descend')},'FontSize',13);
    set(gca, 'Xtick', 1:4:length(MAPPING.info.x_list), 'xTickLabel', {MAPPING.info.x_list(1):4:MAPPING.info.x_list(end)},'FontSize',13);
    xlabel('X coordinates')
    ylabel('Y coordinates')
    
    plot(find(MAPPING.info.x_list == 0),find(MAPPING.info.y_list == 0),'r+', 'MarkerSize',15);
    
    M = getframe;
    writeVideo(aviobj,M);    
end

close(aviobj)
close all
