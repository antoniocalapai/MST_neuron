%% Function -- MW_psfCalculate(PSFdata,varargin) --
%
%   Version 1.0 -- 30th April 2014 -- jhueer@dpz.eu
%
%   Version 1.1 -- 19th June 2015 -- jhueer@dpz.eu
%
%   +++CHANGES:
%        +++ Calculation of standard error and 95% confidence interval of
%            pse and slope +++
%        +++ Upper and lower limit of lapse and guess rate can be
%            determined +++
%
% !!####################################################################!!
% !!## To use this function you need Palamedes version 1.2.0 or later ##!!
% !!####################################################################!!
%
%
% This function calculates a psychometric function. To use it you need to
% specify the following parameters:
%
%   1) 'fittingTool': 'Palamedes'
%
%   2) 'PAL_fittingMethod': 'ML' (maximum likelihood criterion)
%
%   3) 'PAL_functionType': all functions provided by Palamedes
%
%   4) 'PAL_searchGrid' (This has previously been called 'paramsValues' and
%       was a matrix consisting of four single values [alpha beta gamma
%       lamba]. The Palamedes toolbox accepts now a 0 to 4D matrix (i.e.
%       for each parameter you can give several values and the Palamedes
%       routine will use the one that fits best as start value for the
%       fitting). You need to specifiy the four parameters
%
%       - 'PAL_searchGrid.alpha'
%       - 'PAL_searchGrid.beta'
%       - 'PAL_searchGrid.gamma'
%       - 'PAL_searchGrid.lambda'
%
%       separately, and provide one or more values for each of them.
%
%   5) 'PAL_paramsFree': 1x4 vector that specifies whether the parameters
%       in PAL_searchGrid are free (=1) or fixed (=0) parameters.
%
%
% The following parameters are optional:
%
%   6) 'PAL_fitNumValues': number of values provided in
%       PSFdata.fittedValuesX and corresponding values in
%       PSFdata.fittedValuesY. [default: 1000]
%
%   7) 'PAL_gofNumIter': If you want to determine the goodness of your fit
%       you need to specifiy the number of iterations.
%
%   8) 'PAL_bootstrap': 'p' (parametric), 'np' (non-parametric)
%
%   9) 'PAL_bootstrapNumIter': number of bootstrap iterations [default: 0]
%
%   NEW:
%
%  10) 'PAL_lapseLimits': [min max]
%
%  11) 'PAL_guessLimits': [min max]
%
%
% In addition you can calculate different parameters of the PSF:
%
% 1) x- and y-values
%
%   a) PAL_getYValue
%
%       If you use the command
%           [PSFdata] = MW_psfCalculate(PSFdata,'PAL_getYValue',x-values)
%       and specify the x-values you will get the corresponding y-values.
%       x-values can either be a single value or a row vector of several
%       values.
%
%   b)  PAL_getXValue
%
%       If you want to get the x-values of specified y-values you can use
%       the command
%           [PSFdata] = MW_psfCalculate(PSFdata,'PAL_getXValue',y-values)
%       in the same way as PAL_getYValue.
%
%
% 2) Slope
%
%   a)  PAL_slope [you will find this value in PSFdata.slope]
%
%       PAL_slope calculates the spread on the x-axis in which the graph
%       of your psychometric function changes from a specified minimum to a
%       specified maximum.
%
%       [PSFdata] = MW_psfCalculate(PSFdata,'PAL_slope',[minimum maximum])
%
%   b)  PAL_slopeSpread
%
%       PAL_slopeSpread uses the Palamedes command PAL_spreadPF and
%       calculates the spread on the x-axis in which the graph of the
%       pschychometric function goes from  [guess-rate + delta] to
%       [lapse-rate - delta].
%
%       [PSFdata] = MW_psfCalculate(PSFdata,'PAL_spreadLim',delta)
%
%   Example:
%
%   [PSFdata] = MW_psfCalculate(PSFdata,'fittingTool','Palamedes', ...
%   'PAL_fittingMethod', 'ML','PAL_functionType','CumulativeNormal', ...
%   'PAL_searchGrid.alpha', [0 0.5 1 2],'PAL_searchGrid.beta',[1 2], ...
%   'PAL_searchGrid.gamma',0, 'PAL_searchGrid.lambda',0,'PAL_paramsFree', ...
%   [1 1 0 0],'PAL_bootstrap', 'p','PAL_bootstrapNumIter',400)
%
%
%   Depending on what you do this function can create the following
%   parameters:
%
%
%   -- PSFdata.logLikelihood
%
%   -- PSFdata.output
%
%   -- PSFdata.dev
%
%   -- PSFdata.DevSim
%
%   -- PSFdata.goodnessOfFit_converged
%
%   -- PSFdata.SD
%
%   -- PSFdata.paramsSim
%
%   -- PSFdata.LLSim
%
%   -- PSFdata.bootstrap_converged
%
%   -- PSFdata.slopeSpread
%
%   -- PSFdata.xValue
%
%   -- PSFdata.yValue
%
%   NEW:
%
%   -- PSFdata.pseSE
%
%   -- PSFdata.pseCI
%
%   -- PSFdata.slopeSE
%
%   -- PSFdata.slopeCI
%

%% ----------------------------------------------------------------------------------------------------

function [PSFdata] = MW_psfCalculate(PSFdata,varargin)


PSFdata.version_psfCalculate='1.1';

if isempty(PSFdata.fixXLim) && ~isempty(PSFdata.xAxis)
    set(PSFdata.axesHandle,'XLim',[min(PSFdata.xAxis)-0.5, max(PSFdata.xAxis)+0.5]);
    PSFdata.xLim=[min(PSFdata.xAxis)-0.5 max(PSFdata.xAxis)+0.5];
elseif ~isempty(PSFdata.fixXLim) && isempty(PSFdata.xLim) && ~isempty(PSFdata.xAxis)
    set(PSFdata.axesHandle,'XLim',PSFdata.fixXLim);
    PSFdata.xLim=PSFdata.fixXLim;
end

if (~isempty(PSFdata) && size(PSFdata.xAxis,2)>1)
    if ~(PSFdata.calculated)
        
        disp('##### MW_psfCalculate:');
        disp('# ');
        PF=[];
        PSFdata.fitted=0;
        
        if ~isempty(varargin)
            
            toolIDX=find(strcmp(varargin,'fittingTool'));
            
            if ~isempty(toolIDX)
                
                for i=1:size(toolIDX,2)
                    
                    % PALAMEDES -----------------------------------------------------------------------
                    if strcmp(varargin(toolIDX(1,i)+1),'Palamedes')
                        
                        tool='Palamedes';
                        disp('# Fitting tool: Palamedes');
                        
                        % ##check if required parameters specified:
                        [PSFdata,paramsFound]= MW_psfParamsCheck(PSFdata,tool,varargin{:});
                        
                        while (paramsFound==1 && PSFdata.fitted==0)
                            
                            
                            % ##read parameters:
                            [PSFdata,PF,fitOptionals] = MW_psfReadInput(PSFdata,tool,varargin{:});
                            
                            tempOpts1=reshape(fieldnames(fitOptionals),1,size(fieldnames(fitOptionals),1));
                            tempOpts2=reshape(struct2cell(fitOptionals),size(struct2cell(fitOptionals),2),size(struct2cell(fitOptionals),1));
                            fOpts=cell(2,size(tempOpts1,2));
                            fOpts(1:2:size(fOpts,2)*size(fOpts,1))=tempOpts1(1:size(tempOpts1,2));
                            fOpts(2:2:size(fOpts,2)*size(fOpts,1))=tempOpts2(1:size(tempOpts2,2));
                            
                            
                            % MAXIMUM-LIKELIHOOD ------------------------------------------------------
                            if strcmp(PSFdata.fittingMethod,'ML')
                                
                                [PSFdata.paramsValues PSFdata.logLikelihood PSFdata.fitted PSFdata.output] = PAL_PFML_Fit(PSFdata.xAxis, PSFdata.answers, PSFdata.samples, PSFdata.searchGrid, PSFdata.paramsFree, PF, fOpts{:});
                                
                                PSFdata.fittedValuesX = PSFdata.xLim(1,1):(max(PSFdata.xAxis-min(PSFdata.xAxis)))/(PSFdata.fitNumValues-1):PSFdata.xLim(1,2);
                                PSFdata.fittedValuesY = PF(PSFdata.paramsValues,PSFdata.fittedValuesX);
                                
                                if PSFdata.fitted
                                    disp('# Fitting done.');
                                    PSFdata.plotted = false;
                                else
                                    disp('# Fitting failed.');
                                    break
                                end
                                
                                % GOODNESS-OF-FIT -----------------------------------------------------
                                if (PSFdata.gofNumIter>0 && PSFdata.nSamplesAddedSinceGoF>10)
                                    PSFdata.nSamplesAddedSinceGoF=0;
                                    [PSFdata.dev, PSFdata.goodnessOfFit, PSFdata.DevSim, PSFdata.goodnessOfFit_converged] = PAL_PFML_GoodnessOfFit(PSFdata.xAxis, PSFdata.answers, PSFdata.samples, PSFdata.paramsValues, PSFdata.paramsFree, PSFdata.gofNumIter, PF, fOpts{:});
                                end
                                
                                
                                % BOOTSTRAP -----------------------------------------------------------
                                if (~isempty(PSFdata.bootstrap))
                                    
                                    % parametric
                                    if strcmp(PSFdata.bootstrap,'p') && PSFdata.bootstrapNumIter>0
                                        [PSFdata.SD PSFdata.paramsSim PSFdata.LLSim PSFdata.bootstrap_converged] = PAL_PFML_BootstrapParametric(PSFdata.xAxis, PSFdata.samples, PSFdata.paramsValues, PSFdata.paramsFree, PSFdata.bootstrapNumIter, PF, fOpts{:});
                                        
                                        
                                        % non-parametric
                                    elseif strcmp(PSFdata.bootstrap,'np') && PSFdata.bootstrapNumIter>0
                                        [PSFdata.SD PSFdata.paramsSim PSFdata.LLSim PSFdata.bootstrap_converged] = PAL_PFML_BootstrapNonParametric(PSFdata.xAxis, PSFdata.answers, PSFdata.samples, '', PSFdata.paramsFree, PSFdata.bootstrapNumIter, PF, 'searchGrid', PSFdata.searchGrid, fOpts{:});
                                        
                                    else
                                        disp('# Bootstrap method does not exist.');
                                    end
                                end
                                
                                % OTHER FITTING METHODS ---------------------------------------------------
                                
                            else
                                disp('# Fitting method not implemented.');
                            end
                            
                        end
                        disp('# ');
                        
                        
                        % OTHER FITTING TOOLS -------------------------------------------------------------
                        
                    else
                        disp('# Fitting tool not implemented.');
                        disp('# ');
                    end
                    
                end
                
            else
                disp('# You did not specify the fitting tool. Fitting failed.');
            end
            
        else
            disp('# No fitting parameters specified. Fitting failed.');
            disp('# ')
        end
        
        % PSE
        
        if PSFdata.fitted
            
            if (strcmp(PSFdata.psf_function,'CumulativeNormal') || strcmp(PSFdata.psf_function,'Logistic'))
                PSFdata.pse=PSFdata.paramsValues(1,1);
            end
            
            getY=0;
            getX=0;
            slopeDiff=0;
            slopeSpread=0;
            
            for i = 1:2:(size(varargin,2))
                switch varargin{i}
                    case 'PAL_getYValue'
                        yValue = varargin{i+1};
                        getY=1;
                    case 'PAL_getXValue'
                        xValue = varargin{i+1};
                        getX=1;
                    case 'PAL_slope'
                        diffLim = varargin{i+1};
                        slopeDiff=1;
                    case 'PAL_spreadLim'
                        spreadLim = varargin{i+1};
                        slopeSpread=1;
                end
            end
            
            if getY
                for i=1:size(yValue,2)
                    PSFdata.yValue(1,i)=PF(PSFdata.paramsValues, yValue(1,i));    % CQ 140303: removed PSFdata. from before PF, as PF is a variable and not a field of the data structure
                end
            end
            
            if getX
                for i=1:size(xValue,2)
                    PSFdata.xValue(1,i)=PF(PSFdata.paramsValues, xValue(1,i), 'inverse');    % CQ 140303: removed PSFdata. from before PF, as PF is a variable and not a field of the data structure
                end
            end
            
            
            % SLOPE
            
            if slopeSpread
                PSFdata.slopeSpread = PAL_spreadPF(PSFdata.paramsValues,spreadLim,PSFdata.psf_function);
                %fprintf('# slopeSpread: %f\n',PSFdata.slopeSpread);
                disp('');
            end
            
            if slopeDiff
                PSFdata.slope=abs(PF(PSFdata.paramsValues, max(diffLim),'inverse')-PF(PSFdata.paramsValues, min(diffLim),'inverse'));
                %fprintf('# slopeDiff: %f\n',PSFdata.slope)
                disp('')
                
                if strcmp(PSFdata.bootstrap,'p') && mean(PSFdata.bootstrap_converged)==1
                    
                    slopeBootstrap=zeros(PSFdata.bootstrapNumIter,1);
                    
                    for iii=1:PSFdata.bootstrapNumIter
                        slopeBootstrap(iii,1)=abs(PF(PSFdata.paramsSim(iii,:), max(diffLim),'inverse')-PF(PSFdata.paramsSim(iii,:), min(diffLim),'inverse'));
                        PSFdata.slopeSE=std(slopeBootstrap)/sqrt(PSFdata.bootstrapNumIter);
                        PSFdata.slopeCI=1.96*PSFdata.slopeSE;
                    end
                    
                    if (strcmp(PSFdata.psf_function,'CumulativeNormal') || strcmp(PSFdata.psf_function,'Logistic'))
                        PSFdata.pseSE=PSFdata.SD(1,1);
                        PSFdata.pseCI=1.96*PSFdata.SD(1,1);
                    end

                    PSFdata.bootstrapW=0;
                    
                elseif strcmp(PSFdata.bootstrap,'p') && mean(PSFdata.bootstrap_converged)~=1
                    
                    PSFdata.numBoot=sum(PSFdata.bootstrap_converged);   
                    bootstrapIDX=logical(PSFdata.bootstrap_converged);
                    new_paramsSim=PSFdata.paramsSim(bootstrapIDX',:);
                    slopeBootstrap=zeros(PSFdata.numBoot,1);
                    
                    for iii=1:PSFdata.numBoot
                        slopeBootstrap(iii,1)=abs(PF(new_paramsSim(iii,:), max(diffLim),'inverse')-PF(new_paramsSim(iii,:), min(diffLim),'inverse'));
                        PSFdata.slopeSE=std(slopeBootstrap)/sqrt(PSFdata.numBoot);
                        PSFdata.slopeCI=1.96*PSFdata.slopeSE;
                    end
                    
                    if (strcmp(PSFdata.psf_function,'CumulativeNormal') || strcmp(PSFdata.psf_function,'Logistic'))
                        PSFdata.pseSE=PSFdata.SD(1,1);
                        PSFdata.pseCI=1.96*PSFdata.SD(1,1);
                    end
                    
                    PSFdata.bootstrapW=1;
                    
                    fprintf('WARNING: Only %f bootstraps converged!',PSFdata.numBoot)
                    
                end
                
            end
            
            disp('#')
            
        end
    end
end

PSFdata.calculated = true;

end

