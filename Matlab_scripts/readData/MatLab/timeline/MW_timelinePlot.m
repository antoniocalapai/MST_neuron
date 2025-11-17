function TIMEdata = MW_timelinePlot(TIMEdata, varargin)%,optionalProperties)
% Timeline = MW_PlotTimeline_Online(Timeline, optionalProperties)
%
% this function plots a Timeline data structure. The user can
% give their own specification of graphics properties in the
% OPTIONALPROPERTIES input structure.

%XC
markList = {};
eyeLine = 0;
eyeSwitch = false;

allesOk = true;
for i = 1 : int16(size(varargin,2)/2)
    switch varargin{2*(i-1)+1}
        case 'eyeSwitch'
            eyeSwitch = varargin{i*2};
        case 'mark'
            mlCX = size(markList,1)+1;
            for j=1:5
                markList{mlCX,j} = varargin{i*2}{j};
            end
            markList{mlCX,6} = 0;
         case 'line'
            mlCX = size(markList,1)+1;
            for j=1:5
                markList{mlCX,j} = varargin{i*2}{j};
            end
            markList{mlCX,6} = 1;
        case 'eye'
            eyeLine = varargin{i*2};
            eyeSwitch = true;
        otherwise
            disp('Timeline_addSample: WARNING: Unknown input argument!');
    end
end

%disp(markList)


% Wenn eyeLine > 0 dann Verschieben aller Einträge < 1 und ändern der
% YTick-Liste!
for cx = 1:size(TIMEdata.onOffList,1)
    if TIMEdata.onOffList{cx,1} < 1
        TIMEdata.onOffList{cx,1} = TIMEdata.onOffList{cx,1}-eyeLine;
    end
end
for cx = 1:size(TIMEdata.eventList,1)
    if TIMEdata.eventList{cx,1} < 1
        TIMEdata.eventList{cx,1} = TIMEdata.eventList{cx,1}-eyeLine;
    end
end



%eyeSwitch determines whether the eye data will be shown. 0 = OFF
%end XC

%StimNames_New = TIMEdata.StimNames
%Str = TIMEdata.Properties
%Events = TIMEdata.Events
%M = TIMEdata.OnSet_OffSet
%%%%Create the figure%%%
%Y_Height = 1:size(StimNames_New,2);
%disp(Y_Height);

% figure_handle=figure;



%dashed lines for the beginning and end of a trial
properties.ssLine.Color = [0 0 0];
properties.ssLine.LineWidth = 1;
properties.ssLine.LineStyle = '--';
MW_plotterPlot(TIMEdata.axesHandle,[0 0], [min([TIMEdata.onOffList{:,1}])-0.5 max([TIMEdata.onOffList{:,1}])+0.5],'line',properties.ssLine,1);
MW_plotterPlot(TIMEdata.axesHandle,[TIMEdata.trialEnd TIMEdata.trialEnd], [min([TIMEdata.onOffList{:,1}])-0.5 max([TIMEdata.onOffList{:,1}])+0.5],'line',properties.ssLine,0);



if eyeSwitch && (size(TIMEdata.fixateList,1) > 0)
    % Print the EYE-background (TRIAL_fixate)
    properties.LINE.LineWidth = eyeLine*9; properties.LINE.Color = [0.95 0.95 0.95];
    MW_plotterPlot(TIMEdata.axesHandle,[0 TIMEdata.trialEnd], [(eyeLine-1)/(-2) (eyeLine-1)/(-2)],'line',properties.LINE,0);

    properties.LINE.LineWidth = eyeLine*9;
    for cx = 1:size(TIMEdata.fixateList,1)
        if TIMEdata.fixateList(cx,1) == 1
            properties.LINE.Color = [0.95 1 0.95];
        else
            properties.LINE.Color = [1 0.95 0.95];
        end
        MW_plotterPlot(TIMEdata.axesHandle,[TIMEdata.fixateList(cx,2) TIMEdata.fixateList(cx,3)], [(eyeLine-1)/(-2) (eyeLine-1)/(-2)],'line',properties.LINE,0);
    end
    
    MW_plotterPlot(TIMEdata.axesHandle,[0 TIMEdata.trialEnd], [(eyeLine-1)/(-2) (eyeLine-1)/(-2)],'line',properties.ssLine,0);
    
    properties.LINE.LineWidth = 1; properties.LINE.Color = [0 0 0];
    MW_plotterPlot(TIMEdata.axesHandle,[0 TIMEdata.trialEnd], [0 0],'line',properties.LINE,0);
    MW_plotterPlot(TIMEdata.axesHandle,[0 TIMEdata.trialEnd], [(eyeLine-1)*(-1) (eyeLine-1)*(-1)],'line',properties.LINE,0);
    
    MW_plotterPlot(TIMEdata.axesHandle,TIMEdata.eye.time, TIMEdata.eye.x/((5-(-5))/eyeLine)+(eyeLine-1)/(-2),'line',properties.LINE,0);
    MW_plotterPlot(TIMEdata.axesHandle,TIMEdata.eye.time, TIMEdata.eye.y/((5-(-5))/eyeLine)+(eyeLine-1)/(-2),'line',properties.LINE,0);
end



% Print the Timelines for the stimuli
properties.LINE.LineWidth = 3;
properties.LINE.Color = [0.5 0.5 0.5];
for i = 1:size(TIMEdata.onOffList,1);
    if TIMEdata.onOffList{i,1} > 0
        properties.LINE.Color = [0.5 0.5 0.5];
    else
        properties.LINE.Color = [0 0 0];
    end
	MW_plotterPlot(TIMEdata.axesHandle,[TIMEdata.onOffList{i,3} TIMEdata.onOffList{i,4}], [TIMEdata.onOffList{i,1} TIMEdata.onOffList{i,1}],'line',properties.LINE,0);
end

%%%Eye position data%% XC
% if eyeSwitch == ~eyeSwitch
%     hold on;
%     EYE_h=trial.EYE_calib_x.data/max(abs(trial.EYE_calib_x.data))-1;
%     EYE_v=trial.EYE_calib_y.data/max(abs(trial.EYE_calib_y.data))-3;
%     % EYE_pup=theTrial.EYE_calib_x.data/max(abs(theTrial.EYE_calib_x.data))-1;
%     % EYE_pup=theTrial.EYE_calib_y.data/max(abs(theTrial.EYE_calib_y.data))-3;
%     plot(double(trial.EYE_calib_x.time-trial.EYE_calib_x.time(1)*int64(ones(size(trial.EYE_calib_x.time))))/1e3,EYE_h);
%     plot(double(trial.EYE_calib_x.time-trial.EYE_calib_x.time(1)*int64(ones(size(trial.EYE_calib_x.time))))/1e3,EYE_v);
% end
%end XC



% %%Add text and lines marking the speed events
% disp(Events);
% for i = 1:size(M,1)
%     if (strcmp(MW_getStimData(StimNames_New{i}, 'type', trial), {'dynamic_random_dots'}) == 1) & (strcmp(Events{i}{1}, {0}) == 0);
%       if i <= size(Events,2);
%           for k = 2:2:size(Events{i}{1}, 2);
%               line([(double(Events{i}{2}(k)-trial.ML_trialStart.time)/1e3) (double(Events{i}{2}(k)-trial.ML_trialStart.time)/1e3)], [size(M,1)-i-0.1 size(M,1)-i+0.1], 'linewidth', 2 ,'color', 'r')
%               line([(double(Events{i}{2}(k+1)-trial.ML_trialStart.time)/1e3) (double(Events{i}{2}(k+1)-trial.ML_trialStart.time)/1e3)], [size(M,1)-i-0.1 size(M,1)-i+0.1], 'linewidth', 2 ,'color', 'r')
%               
%               hold on;
%           end
%         for k = 2:size(Events{i}{1}, 2);
%             A = strcat('Event: ', '(', num2str((double(Events{i}{2}(k)-trial.ML_trialStart.time)/1e3)), ')','.', ' (', num2str(cell2mat(Events{i}{1}(k-1))), ':', num2str(cell2mat(Events{i}{1}(k))),')');
%             text((double(Events{i}{2}(k)-trial.ML_trialStart.time)/1e3), (size(M,1)-i+(((rem(k,2))*(-0.4))+0.2)),A);
%        
%         end
%       end
%     end
%     % we here insert the coordination information and color into the graph%%
%     %RABtext(-500,size(M,1)-i,Str{i});
%     Temp = M(i,:);
%     Temp(find(Temp == 0))=[];
%     %%we here insert the timing of each appearence and disappearence%%
%     for j= 1:length(Temp);
%         A = num2str(Temp(j));
%         %figure = text(Temp(j),size(M,1)-i+0.1,A);
%     end
% end


ymin=-0.5;
%XC
%if eyeSwitch == ~eyeSwitch
%     StimNames_New=[num2str(max(abs(trial.EYE_calib_x.data))/2)... 
%         'Eye position horizontal'... 
%         num2str(-max(abs(trial.EYE_calib_x.data))/2)... 
%         num2str(max(abs(trial.EYE_calib_y.data))/2)... 
%         'Eye position vertical'... 
%         num2str(-max(abs(trial.EYE_calib_y.data))/2)...
%         StimNames_New];
%     % % % % % set(gca, 'YTick',  [1:size(M,1) size(M,1)+0.5:0.5:size(M,1)+3]);
%     set(Timeline.axesHandle, 'YTick',  [ -3.5 -3 -2.5 -1.5 -1 -0.5 0:size(M,1)-1]);
%     ymin=-3.5;
%end
%end XC



set(TIMEdata.axesHandle, 'YTick', min([TIMEdata.onOffList{:,1}]):max([TIMEdata.onOffList{:,1}]));

yNames = {};
if min([TIMEdata.onOffList{:,1}]) < 1
    korrektur = (min([TIMEdata.onOffList{:,1}])*(-1))+1;
    for cx = 1:size(TIMEdata.onOffList,1)
        yNames{TIMEdata.onOffList{cx,1}+korrektur} = TIMEdata.onOffList{cx,2};
    end
else
    yNames = {TIMEdata.onOffList{[unique([TIMEdata.onOffList{:,1}])],2}};
end
set(TIMEdata.axesHandle, 'YTicklabel', yNames); % change the y axis tick to your name of the process


set(TIMEdata.axesHandle, 'xlim',[-(25.0) TIMEdata.trialEnd+25]);
set(TIMEdata.axesHandle, 'ylim',[min([TIMEdata.onOffList{:,1}])-0.5 max([TIMEdata.onOffList{:,1}])+0.5]);  %ymin-20 ... size(M,1)+0.25+20


properties.POINT.LineStyle = 'none';
properties.POINT.Marker = '>';
properties.POINT.MarkerEdgeColor = [0 0 0];
properties.POINT.MarkerFaceColor = [0.5 0.5 0.5];
properties.POINT.MarkerSize = 8;

MW_plotterPlot(TIMEdata.axesHandle,[TIMEdata.eventList{:,4}],[TIMEdata.eventList{:,1}],'point',properties.POINT,0); % first plot the points




% Mark the intresting data points...
for markCX = 1:size(markList,1)
    if isempty(markList{markCX,2})
        nameIdx = ones(1,size(TIMEdata.eventList,1));
    else
        nameIdx = strcmp(markList{markCX,2}, {TIMEdata.eventList{:,5}});
    end
    if isempty(markList{markCX,1})
        featureIdx = ones(1,size(TIMEdata.eventList,1));
    else
        featureIdx = strcmp(markList{markCX,1}, {TIMEdata.eventList{:,2}});
    end
    
    evalIdx = ones(1, size(TIMEdata.eventList,1));
    if ~isempty(markList{markCX,3})
        for j = 1:size(markList{markCX,3},2)
            for i = 1:size(TIMEdata.eventList,1)
                if isnumeric(TIMEdata.eventList{i,3})
                    evalIdx(i) = evalIdx(i) & eval(sprintf('%d %s', TIMEdata.eventList{i,3}, markList{markCX,3}{j}));
                else
                    evalIdx(i) = evalIdx(i) & 0;
                end
            end
        end
    end
    
    
    %disp(markList{markCX,4});
    
    if markList{markCX,6}
        tempLineX = [TIMEdata.eventList{featureIdx & nameIdx,4}];
        for i = 1:length(tempLineX)
        	MW_plotterPlot(TIMEdata.axesHandle,[tempLineX(i)+markList{markCX,5} tempLineX(i)+markList{markCX,5}], [min([TIMEdata.onOffList{:,1}])-0.5 max([TIMEdata.onOffList{:,1}])+0.5],'line',markList{markCX,4},0);
        end
    else
        MW_plotterPlot(TIMEdata.axesHandle,[TIMEdata.eventList{featureIdx & nameIdx & evalIdx,4}]+markList{markCX,5},[TIMEdata.eventList{featureIdx & nameIdx & evalIdx,1}],'point',markList{markCX,4},0); % first plot the points
    end
end

end
