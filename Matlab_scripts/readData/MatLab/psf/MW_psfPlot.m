%% Function  -- MW_psfPlot(PSFdata,refreshPlot,optionalProperties) --
%
% This function plots a psychometric function data structure.
%
% Essential parameters:
%
%   -- PSFdata
%
%
% Optional parameters:
%
%   -- refreshPlot
%        specifies whether the axes should be cleared before plotting (default: 0)
%
%
%   -- optionalProperties
%        the users can give their own specification of graphics properties


%% ----------------------------------------------------------------------------------------------------

function PSFdata = MW_psfPlot(PSFdata,refreshPlot,optionalProperties)

if ~(PSFdata.plotted)
    
    
    %if (PSFdata.calculated) && ~(PSFdata.plotted)
    
    
    % default plot properties
    defaultProperties.BAR.FaceColor = [0.9 0.9 1];
    defaultProperties.BAR.EdgeColor = [1 1 1];
    defaultProperties.BAR.LineWidth = 0.1;
    defaultProperties.BAR.BarWidth = 1;
    
    defaultProperties.POINT.LineWidth = 2;
    defaultProperties.POINT.Color = 'k';
    defaultProperties.POINT.Marker = 'o';
    
    defaultProperties.LINE.LineWidth = 1.5;
    defaultProperties.LINE.Color = 'b';
    
    defaultProperties.TEXT_L.Units = 'Normalized';
    defaultProperties.TEXT_L.FontUnits = 'Normalized';
    defaultProperties.TEXT_L.FontSize = 0.06;
    defaultProperties.TEXT_L.VerticalAlignment = 'middle';
    defaultProperties.TEXT_L.HorizontalAlignment = 'right';
    
    defaultProperties.TEXT_R.Units = 'Normalized';
    defaultProperties.TEXT_R.FontUnits = 'Normalized';
    defaultProperties.TEXT_R.FontSize = 0.06;
    defaultProperties.TEXT_R.VerticalAlignment = 'middle';
    defaultProperties.TEXT_R.HorizontalAlignment = 'left';
    
    
    % parse optional graphics properties input, replacing defaults if necessary
    
    if nargin>2
        properties = MW_plotterPropertyParser(defaultProperties,optionalProperties);
    else
        properties = defaultProperties;
    end
    
    if ~exist('refreshPlot','var')
        refreshPlot = 0;
    end
    
    set(PSFdata.axesHandleRightY,'Position',get(PSFdata.axesHandle,'Position'));
    graphicsHandle_BAR = MW_plotterPlot(PSFdata.axesHandleRightY,PSFdata.xAxis,PSFdata.samples,'bar',properties.BAR,refreshPlot);
    
    % plot the data points
    
    graphicsHandle_POINT = MW_plotterPlot(PSFdata.axesHandle,PSFdata.xAxis,PSFdata.percentageTrue,'point',properties.POINT,refreshPlot);
    
    if ~isempty(PSFdata.fixXLim)
        set(PSFdata.axesHandle,'XLim',PSFdata.fixXLim);
    end
    
    % plot the fitted curve if existing
    
    if ~isempty(PSFdata.fittedValuesY) && PSFdata.fitted
        graphicsHandle_LINE = MW_plotterPlot(PSFdata.axesHandle,PSFdata.fittedValuesX, PSFdata.fittedValuesY,'line',properties.LINE,0);
        
        % text
        text_align=PSFdata.xLim(1,1)+0.4*(PSFdata.xLim(1,2)-PSFdata.xLim(1,1));
        text_L_1 = {'discr. theshold = ','PSE = '};
        text_L_2 = {'goodness of fit = '};
        x_L_1 = [text_align text_align];
        x_L_2 = text_align;
        y_L_1 = [0.9 0.8];
        y_L_2 = 0.7;
        
        if ~isempty(PSFdata.bootstrap)
            if sum(PSFdata.bootstrap_converged)==PSFdata.bootstrapNumIter
                text_R_1b = strcat(char(177),num2str(PSFdata.slopeCI,'%10.2f'));
                text_R_1c = strcat(char(177),num2str(PSFdata.pseCI,'%10.2f'));          
            elseif PSFdata.bootstrapW==1         
                text_R_1b = strcat(char(177),num2str(PSFdata.slopeCI,'%10.2f'),'(',num2str(PSFdata.numBoot),'/',num2str(PSFdata.bootstrapNumIter),')');
                text_R_1c = strcat(char(177),num2str(PSFdata.pseCI,'%10.2f'),'(',num2str(PSFdata.numBoot),'/',num2str(PSFdata.bootstrapNumIter),')');
            else      
                text_R_1b = '';
                text_R_1c = '';
            end
        else
            text_R_1b = '';
            text_R_1c = '';
        end
        text_R_1 = {strcat(num2str(PSFdata.slope,'%10.2f'),text_R_1b),strcat(num2str(PSFdata.pse,'%10.2f'),text_R_1c)};
        text_R_2 = {num2str(PSFdata.goodnessOfFit,'%10.2f')};
        x_R_1 = [text_align text_align];
        x_R_2 = text_align;
        y_R_1 = [0.9 0.8];
        y_R_2 = 0.7;
        
        if ~isempty(PSFdata.slope) || ~isempty(PSFdata.pse)
            graphicsHandle_TEXT_L_1 = MW_plotterWriteText(PSFdata.axesHandle,text_L_1,x_L_1,y_L_1,properties.TEXT_L,0);
            graphicsHandle_TEXT_R_1 = MW_plotterWriteText(PSFdata.axesHandle,text_R_1,x_R_1,y_R_1,properties.TEXT_R,0);
        end
        if ~isempty(PSFdata.goodnessOfFit) && sum(PSFdata.goodnessOfFit_converged)==PSFdata.gofNumIter
            graphicsHandle_TEXT_L_2 = MW_plotterWriteText(PSFdata.axesHandle,text_L_2,x_L_2,y_L_2,properties.TEXT_L,0);
            graphicsHandle_TEXT_R_2 = MW_plotterWriteText(PSFdata.axesHandle,text_R_2,x_R_2,y_R_2,properties.TEXT_R,0);
        end
    end
    
    set(PSFdata.axesHandle,'YLim',[0,1]);
    set(PSFdata.axesHandle,'box','off');
    set(PSFdata.axesHandleRightY,'box','off');
    set(PSFdata.axesHandleRightY,'YLim',[0,10*(ceil(max(PSFdata.samples)/10))]); % CQ 141003: set upper limit of repetitions hist to steps of 10. JH 141103 added division by 10.
    %    set(PSFdata.axesHandleRightY,'Position',get(PSFdata.axesHandle,'Position'));
    
    
    PSFdata.plotted = true;
    
end

