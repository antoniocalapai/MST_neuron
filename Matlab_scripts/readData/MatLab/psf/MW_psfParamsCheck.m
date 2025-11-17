%% Function -- MW_psfParamsCheck --
%
%
%
%
%% ----------------------------------------------------------------------------------------------------

function [PSFdata,paramsFound]= MW_psfParamsCheck(PSFdata,tool,varargin)

    if strcmp(tool,'Palamedes')
        
        paramsFound=0;
        
        if isempty(find(strcmp(varargin,'PAL_paramsValues'),1))
            if ~isempty(find(strcmp(varargin,'PAL_searchGrid.alpha'),1))
               if ~isempty(find(strcmp(varargin,'PAL_searchGrid.beta'),1))
                    if ~isempty(find(strcmp(varargin,'PAL_searchGrid.gamma'),1))
                        if ~isempty(find(strcmp(varargin,'PAL_searchGrid.lambda'),1))
                            paramsFound=1;  
                        else disp('#   - PAL_searchGrid.lambda: missing'); 
                        end
                    else disp('#   - PAL_searchGrid.gamma: missing');
                    end
               else disp('#   - PAL_searchGrid.beta: missing');
               end
            else disp('#   - PAL_searchGrid.alpha: missing');
            end
        else disp('#   - PAL_paramsValues: missing');  
        end   
        if isempty(find(strcmp(varargin,'PAL_fittingMethod'),1)) 
            disp('#   - fittingMethod: missing');                           
            paramsFound=0;
        end
        if isempty(find(strcmp(varargin,'PAL_paramsFree'),1))
            disp('#   - paramsFree: missing');                             
            paramsFound=0;   
        end
        if isempty(find(strcmp(varargin,'PAL_functionType'),1))
            disp('#   - functionType: missing');                              
            paramsFound=0;                         
        end

        
    end
