function STCdata = MW_nonlinearOptCreate(axesHandle,STCname,varargin)
% STCdata = MW_stcCreate_CQ(axesHandle,STCname,axesPropertyList)
%
% This function initialises a STC data structure and associates it with the axes
% indicated by axesHandle and the name given in STCNAME. AXESPROPERTYLIST
% is an optional input that can contain pairs of axes properties and
% values. These properties will be assigned to each one of the input
% axeshandles. To see a list of possible properties and default values,
% type get(gca). 

if nargin<2
    STCname = 'staircase';
end

% % %
% default values for plotting STC data:
MW_default_STC_propertylist.Title = STCname;
MW_default_STC_propertylist.XLabel = 'Trial number';
MW_default_STC_propertylist.YLabel = 'Stimulus value';
% % %

% % %
% initialisation of STC data structure
%
% 1: initialise structure
STCdata.axesHandle = axesHandle;
STCdata.name =  STCname;
STCdata.trialNum = [];
STCdata.yValue = [];
            
% 2: prepare for later data plotting
% parse propertylist, overwriting defaults if
% user specified their value:
propertylist = MW_default_STC_propertylist;
if nargin>2
    pl = varargin;
    for p = 1:2:length(pl)
        propertylist.(pl{p}) = pl{p+1};
    end
end
success = MW_plotterPrepareAxes(axesHandle,propertylist);
if ~success % if the call to the plotter function returned evidence of failure:
    disp('Could not prepare STC axes for plotting, default values used');
end