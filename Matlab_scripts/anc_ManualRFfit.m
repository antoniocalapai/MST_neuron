function anc_ManualRFfit(fittype)
% This function is designed to be run manually, step by step, cell by cell,
% after the function anc_FitReceptiveField has been already run. 

% For every unit with MAPPING.valid = 0, the routine asks the user to 
% specify the receptive field center and size manually, before plotting the
% receptive field and respective ellipse and save plot and information

addpath(genpath(('/Users/acalapai/Dropbox/MST_manuscript/Matlab_scripts/')))

plot_path = '/Users/acalapai/Dropbox/MST_manuscript/Plots/RF_evaluated/';
cells_path = '/Users/acalapai/Dropbox/MST_manuscript/Cells_matfiles/';

cells_list = dir([cells_path '*RF*']);

idx = [];

% make an index of all the cells with mapping visibile but failed fit
for i = 1:length(cells_list)
    load([cells_path cells_list(i).name])
    if MAPPING.valid == fittype
        idx(end+1) = i;
    end
end

for i = 1:length(idx)
    %close all
    load([cells_path cells_list(idx(i)).name])
    
    F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
    Z = conv2(MAPPING.cell.relative(:,:,MAPPING.info.delay == MAPPING.info.bestdelay),F,'same');
    
    figure('rend','painters','pos',[1407 1 1028/2 1104/3])
    imagesc(Z); hold on
    colormap gray; colormap(1 - colormap)
    
    try
        if ~isempty(find(MAPPING.info.x_list == 0, 1))
            h = plot(find(MAPPING.info.x_list == 0),...
                find(MAPPING.info.y_list == 0),'+r');
            set(h,{'markers'},{30})
        end
    end
    
    % Find the highest value in the matrix and use it as RF center 
    [~,I] = max(Z(:));
    [I_row, I_col] = ind2sub(size(Z),I); 
    
    % The following values are manually modified 
    sigma1 = 14;
    sigma2 = 12;
    theta = 0;
    x_c0 = I_col;
    y_c0 = I_row;
    
    % Plot the ellipse
    c = plot(x_c0, y_c0,'+r');
    h = ellipse(sigma1, sigma2, theta, x_c0, y_c0,'g');
    
    %% Accept manual fit, polish plot and save results
    try
        xCenter = MAPPING.info.x_list(x_c0);
    catch
        xCenter = MAPPING.info.x_list(1) + x_c0;
    end
    
    try
        yCenter = MAPPING.info.y_list(y_c0);
    catch
        yCenter = MAPPING.info.y_list(1) + y_c0;
    end
    
    FitRes.area = real((sqrt(pi*(sigma1)*(sigma2))));
    FitRes.ecce = real((sqrt(xCenter^2 + yCenter^2)));
    FitRes.angl = theta;
    FitRes.s1 = (sigma1);
    FitRes.s2 = (sigma2);
    FitRes.cx = xCenter;
    FitRes.cy = yCenter;
    
    try
        if ~isempty(find(MAPPING.info.x_list == 0, 1))
            f = plot(find(MAPPING.info.x_list == 0),...
                find(MAPPING.info.y_list == 0),'+r');
            set(f,{'markers'},{30})
        end
    end
    
    set(gca,'Ytick',1:4:length(MAPPING.info.y_list),'YTickLabel',...
        {sort(MAPPING.info.y_list(1):4:MAPPING.info.y_list(end),'descend')},'FontSize',14);
    set(gca,'Xtick',1:4:length(MAPPING.info.x_list),'XTickLabel',...
        {MAPPING.info.x_list(1):4:MAPPING.info.x_list(end)},'FontSize',14);
    
    title(cells_list(i).name(1:end-4))
    
    ylim = get(gca,'ylim');
    xlim = get(gca,'xlim');
    
    set(h,'linewidth',5)
    set(h,'linestyle','--')
    text(xlim(1)+1, ylim(2)-2, ['area = ' num2str(FitRes.area,'%4.1f')]...
        ,'FontSize',15,'FontWeight','bold');
    text(xlim(1)+10, ylim(2)-2, ['ecce = ' num2str(FitRes.ecce,'%4.1f')]...
        ,'FontSize',15,'FontWeight','bold');
    text(xlim(2)-11, ylim(2)-2, ['Manual'],...
        'FontSize',15,'FontWeight','bold','BackgroundColor','green');
    
    
    MAPPING.valid = 5;
    MAPPING.info.FitRes = FitRes;
    
    name = ([plot_path cells_list(idx(i)).name(1:end-7) '_eval']);
    export_fig(name,'-png','-transparent')
    
    name = ([cells_path cells_list(idx(i)).name]);
    save(name,'MAPPING');
    
end
%% advance manually
i = i + 1;
disp(i)

end
