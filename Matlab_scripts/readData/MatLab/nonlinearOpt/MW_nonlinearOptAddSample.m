function STCdata = MW_nonlinearOptAddSample(STCdata,varargin)



ndatapoints = length(STCdata.trialNum);
% parse inputs and add to correct field:
for in = 1:(length(varargin)/2)
    switch varargin{2*(in-1)+1}
        case 'trialNum'
            STCdata.trialNum(ndatapoints+1) = varargin{2*in};
        case 'value'
            STCdata.yValue = [STCdata.yValue varargin{2*in}];
        otherwise
            disp(['MW_stcAddSample_CQ: WARNING: Unknown input argument ' varargin{2*(in-1)+1} ' !']);
    end
end