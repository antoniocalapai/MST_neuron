function anc_PlotReceptiveField(id, MAPPING, destination,saving,FitRes)
% this function runs one of two modalities, depending on the last argument
% provided FitRes. If FitRes is not provided, the plot will contain a
% generic set of latencies that do not take into account the best latency,
% but if FitRes is provided (containing therefore the best latency), then
% the set of latency plotted will depend on the best latency value. Other
% parameters are the cell id (id), the entire mapping matrix (MAPPING),
% the destination folder where the plot will be saved, and a boolean field
% (saving) if the plot will be saved before being closed.

if isempty(FitRes)
    figure('rend','painters','pos',[893 1 1028 1104])
    colormap gray; colormap(1 - colormap)
    
    % flip the latency vector to plot -t first and t=0 after
    vector = flip(-20000:20000:200000);
    for i = 1:length(vector)
        subtightplot(4,3,i,[0 0])
        
        % smooth the matrix with a convolution kernel
        F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
        latency = MAPPING.info.delay == vector(i);
        
        Z = conv2(MAPPING.cell.relative(:,:,latency),F,'same');
        imagesc(Z,[0 1]); hold on
        colormap gray; colormap(1 - colormap)
        
        % annotate the latency in milliseconds for reference 
        text(1,2,[num2str(-vector(i)/1000) ' ms'],...
            'Color', 'r', 'FontSize',12,'BackgroundColor','white')
        % if available, add the fixation poin into the plot
        try
            if ~isempty(find(MAPPING.info.x_list == 0, 1))
                h = plot(find(MAPPING.info.x_list == 0),find(MAPPING.info.y_list == 0),'+r');
                set(h,{'markers'},{30})
            end
        end
        
        set(gca,'Ytick',1:4:length(MAPPING.info.y_list),'YTickLabel',...
            {sort(MAPPING.info.y_list(1):4:MAPPING.info.y_list(end),'descend')},'FontSize',14);
        set(gca,'Xtick',1:4:length(MAPPING.info.x_list),'XTickLabel',...
            {MAPPING.info.x_list(1):4:MAPPING.info.x_list(end)},'FontSize',14);
        set(gca,'YAxisLocation','right');
        
        if i ~= length(vector)
            set(gca,'xticklabel',[])
            set(gca,'xlabel',[])
            set(gca,'xtick',[])
            set(gca,'yticklabel',[])
            set(gca,'ylabel',[])
            set(gca,'ytick',[])
            hold off
        end
        
        if i == 2
            title(id)
        end
        
        set(gca,'FontSize',15)
    end
    
elseif ~isempty(FitRes)
    figure('rend','painters','pos',[893 1 1028 1104/2])
    colormap gray; colormap(1 - colormap)
    vector = [-13 -5 -2 0 5 10];
    for i = 1:length(vector)
        subtightplot(2,3,i,[0 0])
        
        bestdelay = find(MAPPING.info.delay == MAPPING.info.bestdelay);
        F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
        
        % set the matrix to plot at i=0 according to the best delay
        Z = conv2(MAPPING.cell.relative(:,:,bestdelay+vector(i)),F,'same');
        
        imagesc(Z,[0 1]); hold on
        colormap gray; colormap(1 - colormap)
        
        text(1,2,[num2str(-MAPPING.info.delay(bestdelay+vector(i))/1000) ' ms'],...
            'Color', 'r', 'FontSize',12,'BackgroundColor','white')
        
        try
            if ~isempty(find(MAPPING.info.x_list == 0, 1))
                h = plot(find(MAPPING.info.x_list == 0),...
                    find(MAPPING.info.y_list == 0),'+r');
                set(h,{'markers'},{30})
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
                title(id)
            case{4}
                xCenter = sum(MAPPING.info.x_list <= int16(mode([FitRes.cx])));
                yCenter = sum(MAPPING.info.y_list <= int16(mode([FitRes.cy])));
                gf = mode([FitRes.gf]);
                h = ellipse(mode([FitRes.s1]),mode([FitRes.s2]),...
                    mode([FitRes.angl]),xCenter,yCenter,'r');
                
                ylim = get(gca,'ylim');
                                
                set(h,'linewidth',5)
                set(h,'linestyle','--')
                text(1, ylim(2)-2, ['area = ' num2str(mode([FitRes.area]),'%4.1f')]...
                    ,'FontSize',15,'FontWeight','bold','BackgroundColor','white');
                text(1, ylim(2)-6, ['ecce = ' num2str(mode([FitRes.ecce]),'%4.1f')]...
                    ,'FontSize',15,'FontWeight','bold','BackgroundColor','white');
                text(1, ylim(2)-10, ['R^2 = ' num2str(gf,'%4.2f')],...
                    'FontSize',15,'FontWeight','bold','BackgroundColor','white');
                set(gca,'FontName', 'Palatino');
        end
        set(gca,'FontSize',15)
    end
end

% save the plot at the desired location (destination)
if saving
    name = ([destination id '_RFmap']);
    export_fig(name,'-png','-transparent')
    close all
end

end
