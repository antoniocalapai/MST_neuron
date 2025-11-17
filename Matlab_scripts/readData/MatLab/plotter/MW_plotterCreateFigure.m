function axesHandles = MW_plotterCreateFigure(layoutSize, layoutElements, varargin)
% function axesHandles = MW_plotterCreateFigure(layoutSize, layoutElements, propertylist)
%
% This function creates a single new figure containing axes that can later be
% plotted into using MW_plotterPlot. The output AXESHANDLES is a vector of
% graphics handles that should be used later as inputs to the MW_*Plot
% functions. The order in which AXESHANDLES corresponds to the axes of the
% figure is either determined by the input LAYOUTSIZE or is (by default)
% the order used by the function subplot, i.e. row-wise.
%
% Required input is LAYOUTSIZE, a matrix specifying the dimensions of the
% possible matrix of axes (subplots). The default behaviour is to fill the
% figure with as many axes as specified by LAYOUTSIZE, e.g. 2x2 for
% LAYOUTSIZE = [2,2]. For a single axes, use LAYOUTSIZE = 1.  
% Optional inputs are:
% - LAYOUTELEMENTS, a cell array specifying the position and size of the
%   axes in the figure. See examples below. Please read the documentation
%   for the function SUBPLOT if you are not already familiar with it.
% - PROPERTYLIST allows you to input pairs of property names and property
%   values to define properties of this figure. Execute get(gcf) to 
%   see a list of figure properties and their default values.
%
% Example 1: create a figure containing 2 axes, one above the other:
%       axesHandles = MW_xyCreateFigure([2 1])
% Example 2: create a figure containing 3 axes, one stretched above and two
%       smaller axes below:  
%       axesHandles = MW_xyCreateFigure([2 2],{1:2 3 4})
% Examples 3: create a figure containing 4 axes, default layout, with the
%       name of the figure specified and no number in the figure label.
%       Here, the property labels are Name and NumberTitle, and their
%       values are psf_allConds and off, respectively. You must provide
%       label then value, label then value, etc.:   
%   	axesHandles = MW_xyCreateFigure([2 2],{},'Name','psfs_allConds','NumberTitle','off')
%
% cquigley@dpz.eu, 03.12.13. Status: tested, works as documented

% parse inputs:
if nargin<2
    layoutElements = {};
end
if isempty(layoutElements) % default layout:
    layoutElements = num2cell(1:prod(layoutSize));
end

% create figure, save handle for later assignment of optional input
% properties:
f = figure;
% create requested axes, saving the graphics handles
if isequal(layoutSize,1) % only 1 axes required in this figure
    axesHandles = gca;
else                     % >1 axes
    axesHandles = zeros(size(layoutElements));
    for sp = 1:length(layoutElements)
        axesHandles(sp) = subplot(layoutSize(1),layoutSize(2),layoutElements{sp});
    end
end

% deal with figure properties if necessary:
if nargin>2
    try
        set(f,varargin{:});
    catch %#ok<CTCH>
        disp('WARNING: requested figure properties are not recognised by Matlab');
        disp('and could not be set.');
        disp('Please read help documentation for figure function and try again');
        return
    end
end