function EYEdata = MW_eyeAddSample(EYEdata, varargin)

for i = 1 : int16(size(varargin,2)/2)
    switch varargin{2*(i-1)+1}
        case 'trialNum'
            trialNum = varargin{i*2};
        case 'Pupil_Right'
            mpsr = varargin{i*2};
        case 'Pupil_Left'
            mpsl = varargin{i*2};
        case 'Eye_X'
            mepx = varargin{i*2};
        case 'Eye_Y'
            mepy = varargin{i*2};
        otherwise
            disp('MW_stcAddSample: WARNING: Unknown input argument!');
    end
end

EYEdata.Pupil_Right=[EYEdata.Pupil_Right mpsr];
EYEdata.Pupil_Left=[EYEdata.Pupil_Left mpsl];
EYEdata.Eye_X=[EYEdata.Eye_X mepx];
EYEdata.Eye_Y=[EYEdata.Eye_Y mepy];
% if (isempty(STCdata(1).name))
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