%% Function -- MW_psfAddSample(PSFdata, varargin) --
%
%
%   This function adds a data point to PSFdata. It needs the following input:
%
%   -- PSFdata
%
%   -- 'xValue', [x-value]
%
%   -- 'xInput', [answer of your subject; usually 0 or 1]
%

%% ----------------------------------------------------------------------------------------------------

function PSFdata = MW_psfAddSample(PSFdata, varargin)

xValue=[];
xInput=[];

for i = 1:2:int16(size(varargin,2))
    switch varargin{i}
        case 'xValue'
            xValue = varargin{i+1};
        case 'xInput'
            xInput = varargin{i+1};
        otherwise
            disp('psf_addSample: WARNING: Unknown input argument!');
    end
end


if (~isempty(xValue) && ~isempty(xInput) && xInput>=0 && xInput<=1)

    % first data point
    if (isempty(PSFdata.xAxis))
        rowNumber = 1;
        PSFdata.xAxis = xValue;
        PSFdata.answers = double(xInput); % deleted int16() JH 140214 % added double() RAB 110314
        PSFdata.samples = 1; % deleted int16() JH 240214
        
    % not the first data point
    else
        rowNumber = find(PSFdata.xAxis == xValue);
        % xValue already occured in experiment
        if (rowNumber > 0)
            if (xInput == 1)
                PSFdata.answers(rowNumber) =  PSFdata.answers(rowNumber) + 1;
            elseif 0<xInput && xInput<1
            % if (0<xInput<1) % added JH 140214
                PSFdata.answers(rowNumber) =  PSFdata.answers(rowNumber) + xInput;
                disp('psf_addSample: WARNING: xInput equals neither 0 nor 1. Are you sure that you want that?')
            end
            PSFdata.samples(rowNumber) =  PSFdata.samples(rowNumber) + 1;
        
        % xValue occured for the first time    
        else
            rowNumber = length(PSFdata.xAxis) + 1;
            PSFdata.xAxis(rowNumber) = xValue;
            PSFdata.answers(rowNumber) = xInput;
            if 0<xInput && xInput<1
               disp('psf_addSample: WARNING: xInput equals neither 0 nor 1. Are you sure that you want that?')
            end     
            
            PSFdata.samples(rowNumber) = 1;      
        end
    end
    
    PSFdata.percentageTrue(rowNumber) = double(PSFdata.answers(rowNumber)) / double(PSFdata.samples(rowNumber));
    
    % sort data
    [~, idx] = sort(PSFdata.xAxis);
    PSFdata.xAxis = PSFdata.xAxis(idx);
    PSFdata.answers = PSFdata.answers(idx);
    PSFdata.samples = PSFdata.samples(idx);
    PSFdata.percentageTrue = PSFdata.percentageTrue(idx);  
   
    PSFdata.calculated = false; 
    PSFdata.nSamplesAddedSinceCalculate = PSFdata.nSamplesAddedSinceCalculate+1;
    PSFdata.nSamplesAddedSinceGoF = PSFdata.nSamplesAddedSinceGoF+1;

    PSFdata.plotted = false;
    PSFdata.fitted = false;
                                                                               
else
    disp('psf_addSample: WARNING: Not enough or inappropriate input.')
end

