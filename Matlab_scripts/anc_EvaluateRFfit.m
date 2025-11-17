function anc_EvaluateRFfit
% this function fits a 2d gaussian at the latency with highest variance in
% the MAPPING.mat data of each cell and ask the user to judge which of four
% different fit has worked best. Numbers 1 to 4 indicate that one of the
% four fits worked (if multiple fits work, the lowest one should be take,
% since it is assumed to be closer to raw data and more parsimonious);
% while 0 indicates a visibile receptive filed, but a non fitting
% prodecure, and -1 indicates that both the fitting and the eye inspection
% reveal that it is only noise and not really a receptive field. 

addpath(genpath(('/Users/acalapai/Dropbox/MST_manuscript/Matlab_scripts/')))

plot_path = '/Users/acalapai/Dropbox/MST_manuscript/Plots/RF_evaluated/';
cells_path = '/Users/acalapai/Dropbox/MST_manuscript/Cells_matfiles/';

cells_list = dir([cells_path '*RF*']);

for i = 1:length(cells_list)
    load([cells_path cells_list(i).name])
    %if MAPPING.valid == 0
    
    figure('rend','painters','pos',[1407 1 1028/2 1104])
    colormap gray; colormap(1 - colormap)
    
    M = [];
    for j = 1:4
        F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
        switch j
            case{1}
                Z = MAPPING.cell.absolute(:,:,MAPPING.info.delay == MAPPING.info.bestdelay);
                tl = 'no smooth, raw';
            case{2}
                Z = MAPPING.cell.relative(:,:,MAPPING.info.delay == MAPPING.info.bestdelay);
                tl = 'no smooth, norm';
            case{3}
                Z = conv2(MAPPING.cell.absolute(:,:,MAPPING.info.delay == MAPPING.info.bestdelay),F,'same');
                tl = 'smooth, abs';
            case{4}
                Z = conv2(MAPPING.cell.relative(:,:,MAPPING.info.delay == MAPPING.info.bestdelay),F,'same');
                tl = 'smooth, norm';
        end
        
        N = 1;
        M(j).FitRes = [];
        M(j).FitRes.N = N;
        M(j).FitRes.area = zeros(1,N);
        M(j).FitRes.ecce = zeros(1,N);
        M(j).FitRes.angl = zeros(1,N);
        M(j).FitRes.s1 = zeros(1,N);
        M(j).FitRes.s2 = zeros(1,N);
        M(j).FitRes.cx = zeros(1,N);
        M(j).FitRes.cy = zeros(1,N);
        M(j).FitRes.gf = zeros(1,N);
        
        for l = 1:N
            % Format the data accordingly and create smoothing vector
            [X,Y] = meshgrid(MAPPING.info.x_list,MAPPING.info.y_list);
            % FIT the 2 dimensional gaussian
            func = fittype('base + a*(exp(-( (((((x - x_c0)*cos(theta) - (y - y_c0)*sin(theta)))^2)/(2*(sigma1^2))) + (((((x - x_c0)*sin(theta) + (y - y_c0)*cos(theta)))^2)/(2*(sigma2^2)))   )) )',...
                'independent',{'x','y'},'dependent',{'Z'});
            options = fitoptions(func);
            
            [~,I] = max(Z(:));
            [I_row, I_col] = ind2sub(size(Z),I); % Find the center of the max
             
%             cx = MAPPING.info.x_list(I_col);
%             cy = MAPPING.info.y_list(I_row);
            
            try
                cx = MAPPING.info.x_list(I_col);
            catch
                cx = MAPPING.info.x_list(1) + I_col;
            end
            
            try
                cy = MAPPING.info.y_list(I_row);
            catch
                cy = MAPPING.info.y_list(1) + I_row;
            end
            
            %parameters are: (a,base,sigma1,sigma2,theta,x_c0,y_c0)
            set(options,'StartPoint',[0,0,20,20,0,cx,cy],...
                'Maxiter',1000, 'MaxFunEvals',1000)
            %                     'Lower',[0,0,0,0,-inf,-inf,-inf],...
            %                     'Upper',[inf,inf,40,40,inf,inf,inf],...
            
            
            %                 set(options,'StartPoint',[0.1044,0.118,1.925,2,2.221e-14,3.541,-6.404],...
            %                                       'Maxiter',1000, 'MaxFunEvals',1000)
            [results, goffit]  = fit([X(:),Y(:)],Z(:),func, options);
            deviation = 2;
            
            M(j).FitRes(l).area = real((sqrt(pi*(results.sigma1*deviation)*(results.sigma2*deviation))));
            M(j).FitRes(l).ecce = real((sqrt(results.x_c0^2 + results.y_c0^2)));
            M(j).FitRes(l).angl = results.theta;
            M(j).FitRes(l).s1 = results.sigma1*deviation;
            M(j).FitRes(l).s2 = results.sigma2*deviation;
            M(j).FitRes(l).cx = (results.x_c0);
            M(j).FitRes(l).cy = (results.y_c0);
            M(j).FitRes(l).gf = goffit.adjrsquare;
        end
        
        subtightplot(4,1,j,[0 0])
        
        imagesc(Z); hold on
        colormap gray; colormap(1 - colormap)
        c = plot(I_col, I_row,'*g');
        
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
        
        if j ~= 4
            set(gca,'xticklabel',[])
            set(gca,'xlabel',[])
            set(gca,'xtick',[])
            set(gca,'yticklabel',[])
            set(gca,'ylabel',[])
            set(gca,'ytick',[])
            hold off
        end
        
        if j == 1
            title(cells_list(i).name(1:end-4))
        end
        
        xCenter = sum(MAPPING.info.x_list <= int16(mode([M(j).FitRes.cx])));
        yCenter = sum(MAPPING.info.y_list <= int16(mode([M(j).FitRes.cy])));
        gf = mode([M(j).FitRes.gf]);
        h = ellipse(mode([M(j).FitRes.s1]),mode([M(j).FitRes.s2]),...
            mode([M(j).FitRes.angl]),xCenter,yCenter,'r');
        
        ylim = get(gca,'ylim');
        xlim = get(gca,'xlim');
        
        set(h,'linewidth',5)
        set(h,'linestyle','--')
        text(xlim(1)+1, ylim(2)-2, ['area = ' num2str(mode([M(j).FitRes.area]),'%4.1f')]...
            ,'FontSize',15,'FontWeight','bold');
        text(xlim(1)+10, ylim(2)-2, ['ecce = ' num2str(mode([M(j).FitRes.ecce]),'%4.1f')]...
            ,'FontSize',15,'FontWeight','bold');
        text(xlim(1)+20, ylim(2)-2.5, ['R^2 = ' num2str(gf,'%4.2f')],...
            'FontSize',15,'FontWeight','bold');
        text(xlim(2)-11, ylim(2)-2, tl,...
            'FontSize',15,'FontWeight','bold','BackgroundColor','white');
        
    end
    
    %% Evaluate what fit worked best
    sound(sin(1:1000)/4);
    EyeEvaluation = input('Which method worked best? not a cell(-1) none(0) number(1:4)?');
    
    MAPPING.valid = EyeEvaluation;
    MAPPING.info.FitRes = [];
    
    if EyeEvaluation > 0
        MAPPING.info.FitRes = M(EyeEvaluation).FitRes;
        name = ([plot_path cells_list(i).name(1:end-7) '_eval']);
        export_fig(name,'-png','-transparent')
    end
    
    name = ([cells_path cells_list(i).name]);
    save(name,'MAPPING');
    
    close all
    %end
end

% Manually fit an ellipse to the cells for which no procedure worked
anc_ManualRFfit(0)

end
