function returnValue = MW_performanceGetData(PERFdata, varargin)
% function PERFdata = MW_performanceCreate(axesHandle, varargin)
%
% Possible parameter:
%   - 'perfMatrix': returnValue is the "pure" performance matrix
%
%
% rbrockhausen@dpz.eu, May 2014

returnValue = [];

for i = 1 : size(varargin,2) 			
    switch varargin{i}
        case 'perfMatrix'
            returnValue = PERFdata.cxMatrix;
        otherwise
            disp('MW_performanceGetData: WARNING: Unknown input argument!');
    end
end


end