function graphicsHandle = MW_plotterPlot(axeshandle,x,y,plottype,propertyListStructure,refreshPlot)
% graphicsHandle = MW_plotterPlot(axeshandle,x,y,plottype,propertyListStructure)
%
% This function creates a plot element given destination axes AXESHANDLE,
% x-values X, y-values Y, type of plot PLOTTYPE. PROPERTYLISTSTRUCUTRE
% contains property names (fieldnames) and values for the plotted graphics
% element in the form propertyListStructure.propertyname = propertyvalue.
% Please see help function for the appropriate matlab plotting function to
% choose property names and values. REFRESHPLOT, when = 1, indicates
% that the contents of the axes defined by AXESHANDLE should be cleared
% before this plotting step occurs (default value is 0, i.e. no refresh)
%
% Output: GRAPHICSHANDLE allows you to later set further properties of the
% plotted graphics object(s). GRAPHICSHANDLE is set to 0 if the plotting
% action failed.
%
% PLOTTYPES:
%   'point': single set of x,y points e.g. data points for psf plot
%   'line': single line e.g. fitted psf
%   'bar': e.g. background bars for psf plot
%   'stacked': stacked barplot, e.g. for performance plot
%   'stair': e.g. staircase results
%   'surface': e.g. parts of timeline           TO-DO!
% [note: for adding text to your plot, use the function MW_plotterWriteText
%
% cquigley@dpz.eu, november 2013

% initalise output:
graphicsHandle = 0;

% check whether axes should be refreshed, must be done whether or not data can be plotted:
if ~exist('refreshPlot','var') % if user has not specified that this plotting action should clear axes contents, don't do it
    refreshPlot = 0;
end
if refreshPlot
    set(axeshandle,'NextPlot','replaceChildren'); % allows next plotting call to replace all existing graphics elements but keep title etc.
else
    set(axeshandle,'NextPlot','add'); % ensures that subsequent plotting calls no longer replace but instead iteratively adds graphics
end

% check inputs:
% confirm that axeshandle is a valid handle to an axes
if ~ishghandle(axeshandle)
    disp('invalid axes handle; cannot plot');
    return
end
% x and y must contain data
if isempty(x)
    disp('no values in x data, cannot plot')
    return
end
if isempty(y)
    disp('no values in y data, cannot plot')
    return
end

% plottype must be specified, otherwise we can't do anything
if nargin<4
    disp('please specify a plottype!')
    return
end

% check x and y dimensions
switch plottype
    case 'stacked'  % x is vector, y must have length(x) rows
        if ~isequal(length(x),size(y,1))
            disp('x and number of rows in y are unequal, cannot plot');
        end
    otherwise % require x and y to have the same size
        if ~isequal(size(x),size(y))
            disp('x and y have unequal sizes, cannot plot');
            return
        end
end

% parse propertylist
propertyList = {}; % if no properties are specified, prevent error being thrown
if nargin>4
    fnames = fieldnames(propertyListStructure);
    for p = 1:length(fnames)
        propertyList{2*p-1} = fnames{p}; % parse into varargin for plot functions
        propertyList{2*p} = propertyListStructure.(fnames{p});
    end
end

% and plot, depending on plottype.
switch plottype
    case 'bar'
        graphicsHandle = bar(axeshandle,x,y);
    case 'stair'
        graphicsHandle = stairs(axeshandle,x,y);
    case 'line'
        graphicsHandle = plot(axeshandle,x,y);
    case 'point'
        graphicsHandle = plot(axeshandle,x,y);
        % if linestyle is not specified, set it to 'none'
        if ~any(strcmp('LineStyle',propertyList))
            set(graphicsHandle,'LineStyle','none');
        end
    case 'stacked'
        if length(x)==1 % not sure why, but matlab can't do a single stacked bar!
            graphicsHandle = bar(axeshandle,[x x+1],[y; nan(size(y))],'stacked');
        else
            graphicsHandle = bar(axeshandle,x,y,'stacked');
        end
    case 'histc'
        graphicsHandle = bar(axeshandle,x,y,'histc');
    otherwise
        disp('unknown plot type! cannot plot');
        return
end
% finally, set properties specified in input:
if ~isempty(propertyList)
    try
        set(graphicsHandle,propertyList{:});
    catch
        disp('could not set requested properties')
        return
    end
end