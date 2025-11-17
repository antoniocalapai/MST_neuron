function EYEdata = MW_eyePlot(EYEdata, varargin)



% 'Title', 'My psychometric function', 'xAxisTitle', 'direction (degree)', ...
%    'yAxisTitle', 'answer right direction (percent)');
%includeEYE = 1; includePHASE = 1; includeIO = 1; includeSPIKE = 1; includeSC = 1; includeALL = 0; noparallel = 1; dontclose = 0;

for i = 1 : int16(size(varargin,2)/2)
    switch varargin{2*(i-1)+1}
        case 'Title'
            stcTitle = varargin{i*2};
        case 'xAxisTitle'
            stcXAxisTitle = varargin{i*2};
        case 'yAxisTitle'
            stcYAxisTitle = varargin{i*2};
        otherwise
            disp('psf_plot: WARNING: Unknown input argument!');
    end
end

% 
% subplot(STCdata(1).figHandle);
% 
% % Optionaler plotparameter (smoothfactor - für Posterdruckgrafiken)
% 
%  
% %screensize(0.2,0.06, 0.6,0.8);
% %[PSE_L_valid, slope_L_valid, fittedValues_L_valid, output_L_valid, SD_L_valid] =  makePsychoMetricFunction1( PSFdata(1,:), PSFdata(2,:), PSFdata(3,:));
% %subplot (2,2,1);
% 
% cla;
% 
% 
% 
% %----staircase left valid-----
% %figure
% %screensize(0.2,0.06,0.6,0.8);
% %subplot (2,2,1);
% if ~isempty(STCdata(1).name)
% plot (STCdata(1).trialNum, STCdata(1).yValue, 'k.','MarkerSize',10);
% hold on;
% stairs (STCdata(1).trialNum, STCdata(1).yValue, 'k');
% 
% end
% 
% 
% if length(STCdata) > 1
% plot   (STCdata(2).trialNum, STCdata(2).yValue, 'k.','MarkerSize',10);
% hold on;
% stairs (STCdata(2).trialNum, STCdata(2).yValue, 'k');
% end

subplot(1,2,1);plot(EYEdata.Pupil_Right,'MarkerSize',10);
hold on;plot(EYEdata.Pupil_Left,'r','MarkerSize',10);
legend('Right pupil size','Left pupil size');

xlabel('Trial number','Units','normalized', 'FontUnits', 'normalized', 'fontsize', .07);
vec_pos = get(get(gca, 'XLabel'), 'Position');
%set(get(gca, 'XLabel'), 'Position', vec_pos + [0 0.2 0]);
ylabel('Pupil size','Units','normalized', 'FontUnits', 'normalized', 'fontsize', .07);
vec_pos = get(get(gca, 'YLabel'), 'Position');
%set(get(gca, 'YLabel'), 'Position', vec_pos + [0.08 0 0]);
title('Pupil size change over trials','Units','normalized', 'FontUnits', 'normalized', 'fontsize', .07);

subplot(1,2,2);plot(EYEdata.Eye_X,EYEdata.Eye_Y,'k*','MarkerSize',10);
axis equal;
xlabel('X position (\circ visual angle)','Units','normalized', 'FontUnits', 'normalized', 'fontsize', .07);
vec_pos = get(get(gca, 'XLabel'), 'Position');
%set(get(gca, 'XLabel'), 'Position', vec_pos + [0 0.2 0]);
ylabel('Y position (\circ visual angle)','Units','normalized', 'FontUnits', 'normalized', 'fontsize', .07);
vec_pos = get(get(gca, 'YLabel'), 'Position');
%set(get(gca, 'YLabel'), 'Position', vec_pos + [0.08 0 0]);
title('Mean eye positions for all trials','Units','normalized', 'FontUnits', 'normalized', 'fontsize', .07);






%xlabel(psfXAxisTitle,'Units','normalized', 'FontUnits', 'normalized', 'fontsize', .04);
%ylabel(psfYAxisTitle,'Units','normalized', 'FontUnits', 'normalized', 'fontsize', .04);
%title(psfTitle,'Units','normalized', 'FontUnits', 'normalized', 'fontsize', .06); 



end