function textHandles = MW_plotterWriteText(axeshandle,textCellArray,xCoordinates,yCoordinates,propertyListStructure,refreshPlot)
% graphicsHandle = MW_plotterWriteText(axesHandle,textCellArray,xCoordinates,yCoordinates,propertyListStructure,refreshPlot)
%
% This function adds text to the specified destination axes AXESHANDLE. The
% text is contained in the cell array TEXTCELLARRAY (one entry per text
% object) and will appear at the corresponding XCOORDINATES, YCOORDINATES
% location. Note that these coordinates are assumed to be in normalized
% units. If you require non-normalized units, this must be specified in
% PROPERTYLISTSTRUCTURE. PROPERTYLISTSTRUCUTRE contains property names
% (fieldnames) and values for the text elements in the form
% propertyListStructure.propertyname = propertyvalue. 
% Please see help for the matlab text function to find valid property names
% and values. REFRESHPLOT, when =1, indicates that the contents of the axes
% defined by AXESHANDLE should be cleared before this plotting step occurs
% (default value is 0, i.e. no refresh) 
%
% Output: TEXTHANDLES allows you to later set further properties of the
% plotted text object(s). 
%
% cquigley@dpz.eu, november 2013

% initalise output:
textHandles = zeros(size(textCellArray));

% check inputs:
% confirm that axeshandle is a valid handle to an axes
if ~ishghandle(axeshandle)
    disp('invalid axes handle; cannot plot');
    return
end
% x and y must be the same size
if ~isequal(size(xCoordinates),size(yCoordinates))
    disp('x and y have unequal sizes, cannot place text');
    return
end
% text must be specified
if isempty(textCellArray)
    disp('no text provided, cannot plot')
    return
end
% parse propertylist
if nargin>4
    fnames = fieldnames(propertyListStructure);
    for p = 1:length(fnames)
        propertyList{2*p-1} = fnames{p}; % parse into varargin for plot functions
        propertyList{2*p} = propertyListStructure.(fnames{p});
    end
end
% if no Units property is specified, force it to Normalized
if ~any(strcmp('Units',propertyList))
    units = 'Normalized';
else
    % extract units
    units_ind = strcmp('Units',propertyList);
    units = propertyList{units_ind+1};
    % delete their mention from property list
    pLtmp = propertyList([setdiff(1:length(propertyList),[units_ind units_ind+1])]);
    propertyList = pLtmp;
end

if ~exist('refreshPlot','var') % if user has not specified that this plotting action should clear axes contents, don't do it
    refreshPlot = 0;
end

% check whether axes should be refreshed:
if refreshPlot
    set(axeshandle,'NextPlot','replaceChildren'); % allows next plotting call to replace all existing graphics elements but keep title etc.
else
    set(axeshandle,'NextPlot','add'); % ensures that subsequent plotting calls no longer replace but instead iteratively adds graphics
end

% and plot text. 
subplot(axeshandle); % make requested axes current focus
for t = 1:length(textCellArray)
    textHandles(t) = text(xCoordinates(t),yCoordinates(t),textCellArray{t}); % need to specify units here in order to guarantee correct position
    
    % % ADD UNITS HERE
    
    % finally, set properties specified in input:
    try
        set(textHandles(t),propertyList{:});
    catch
        disp('could not set requested text properties')
    end
end