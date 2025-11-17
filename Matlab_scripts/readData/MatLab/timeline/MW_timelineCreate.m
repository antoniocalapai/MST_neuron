function Timeline = MW_timelineCreate(axesHandle,varargin)


% Timeline = MW_CreateTimeline(axesHandle,axesPropertyList)
%
% This function initialises a Timeline data structure and associates it with the axes
% indicated by axesHandle. AXESPROPERTYLIST is an optional input that can
% contain pairs of axes properties and values. These properties will be
% assigned to each one of the input axeshandles. To see a list of possible
% properties and default values, type get(gca).

% % %
% default values for plotting PSF data:
MW_default_Timeline_propertylist.Title = 'Timeline';
MW_default_Timeline_propertylist.XLabel = 'Time';
MW_default_Timeline_propertylist.YLabel = 'Stim_names';
% % %

% % %
% initialisation of PSF data structure
%
% 1: initialise structure
Timeline = struct('axesHandle', axesHandle);
% 2: prepare for later data plotting
% parse propertylist, overwriting defaults if
% user specified their value:
propertylist = MW_default_Timeline_propertylist;
if nargin>1
    pl = varargin;
    for p = 1:2:length(pl)
        propertylist.(pl{p}) = pl{p+1};
    end
end
success = MW_plotterPrepareAxes(axesHandle,propertylist);
if ~success % if the call to the plotter function returned evidence of failure:
    disp('Could not prepare PSF axes for plotting, default values used');
end