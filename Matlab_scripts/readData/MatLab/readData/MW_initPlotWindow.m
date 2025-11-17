function figHandles = MW_initPlotWindow(layoutMatrix, varargin)

% for i = 1 : int16(size(varargin,2)/2)
%     switch varargin{2*(i-1)+1}
%         case 'trialNum'
%             trialNum = varargin{i*2};
%         case 'stcName'
%             stcName = varargin{i*2};
%         case 'value'
%             yValue = varargin{i*2};
%         otherwise
%             disp('MW_MW_initPlotWindow: WARNING: Unknown input argument!');
%     end
% end

%disp(layoutMatrix);
figHandles = [];

for i = 1 : size(varargin,2)
    %disp(varargin{i});
    figHandles(length(figHandles)+1) = subplot(layoutMatrix(2), layoutMatrix(1), varargin{i});

end

%layoutMatrix = [1 2];


% 
% if (isempty(STCdata))
%     stcNum = 1;
%     STCdata(stcNum).name = stcName;
%     STCdata(stcNum).yValue = [];
%     STCdata(stcNum).trialNum = [];
% else
%     % find stcNum for stcName
%     stcNum = 0;
%     for i = 1:length(STCdata)
%         if (strcmp(STCdata(i).name, stcName))
%             stcNum = i;
%         end
%     end
%     if (stcNum == 0)
%         stcNum = length(STCdata)+1;
%         STCdata(stcNum).name = stcName;
%         STCdata(stcNum).yValue = [];
%         STCdata(stcNum).trialNum = [];
%     end
% end
% STCdata(stcNum).yValue = [STCdata(stcNum).yValue, double(yValue)];
% STCdata(stcNum).trialNum = [STCdata(stcNum).trialNum, double(trialNum)];

end