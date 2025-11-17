%% Function -- MW_psfReadInput --
%
%
%
%
%% ----------------------------------------------------------------------------------------------------


function [PSFdata,PF,fitOptionals] = MW_psfReadInput(PSFdata,tool,varargin)

    if strcmp(tool,'Palamedes')

         PSFdata.fitNumValues=1000;                   
         PSFdata.gofNumIter=0;                         
         PSFdata.bootstrap='';                            
         PSFdata.bootstrapNumIter=0;
         fitOptionals=struct;
         
         for j = 1:2:(size(varargin,2)-1)    

             switch varargin{j} 
                 case 'PAL_functionType'     
                     PF = str2func(strcat('@PAL_',varargin{j+1}));         
                     PSFdata.psf_function = varargin{j+1};          
                 case 'PAL_paramsValues'     
                     PSFdata.searchGrid = varargin{j+1};       
                 case 'PAL_searchGrid.alpha'      
                     PSFdata.searchGrid.alpha = varargin{j+1};          
                 case 'PAL_searchGrid.beta'     
                     PSFdata.searchGrid.beta = varargin{j+1};           
                 case 'PAL_searchGrid.gamma'       
                     PSFdata.searchGrid.gamma = varargin{j+1};          
                 case 'PAL_searchGrid.lambda'   
                     PSFdata.searchGrid.lambda = varargin{j+1};        
                 case 'PAL_paramsFree'     
                     PSFdata.paramsFree = varargin{j+1};         
                 case 'PAL_fitNumValues'       
                     PSFdata.fitNumValues = varargin{j+1};          
                 case 'PAL_fittingMethod'        
                     PSFdata.fittingMethod = varargin{j+1};        
                 case 'PAL_gofNumIter'     
                     PSFdata.gofNumIter = varargin{j+1};          
                 case 'PAL_bootstrap'
                     PSFdata.bootstrap = varargin{j+1};
                 case 'PAL_bootstrapNumIter'
                     PSFdata.bootstrapNumIter = varargin{j+1};
                 case 'PAL_lapseLimits'    
                     fitOptionals.lapseLimits=varargin{j+1};  
                 case 'PAL_guessLimits'
                     fitOptionals.guessLimits=varargin{j+1};
             end
         end
    end
end