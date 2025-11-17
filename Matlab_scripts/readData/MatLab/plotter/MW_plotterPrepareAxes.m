function success = MW_plotterPrepareAxes(axeshandles, axespropertystruct)
% function success = MW_plotterPrepareAxes(axeshandles, axespropertystruct)
%
% This function prepares a single or multiple axes for later plotting. Returns SUCCESS
% of 1 if requested properties could be applied to input axes; 0 otherwise.
% 
% Inputs: AXESHANDLES is a vector of graphics handles (can also contain a
% single handle). AXESPROPERTYSTRUCT is an optional input that can contain values
% for axes properties. This is a structure with fieldnames corresponding to
% valid property names, and their values corresponding to property
% values, e.g. axespropertystruct.FontUnits = 'Points'
%              axespropertystruct.FontSize = 12
% [Note: be careful to also assign FontUnits if assigning FontSize -
% failure to do so may lead to unpredictible behaviour!
%
% To see a full list of property names and possible values, simply type
% set(gca) at the command line in Matlab. Take care of uppercase and
% lowercase letters, as Matlab is case sensitive
%
% cquigley@dpz.eu, Nov 2013. 

% default values for any axes plotted by MWorks:
MW_default_propertylist.FontUnits = 'Normalized';
MW_default_propertylist.FontSize = 0.08; % proportion of the height of the parent axes

% initialise output
success = 0;

% check that all axeshandles are valid:
if ~all(ishghandle(axeshandles))
    invalid = find(~ishghandle(axeshandles));
    disp(['The following axes handle indices are invalid: ' num2str(invalid)]);
    disp('Cannot prepare axes, terminating.');
    return
end

% check that all user-defined axes properties are valid:
tmp = get(axeshandles(1)); % a structure containing current values of axes properties
pnames = fieldnames(axespropertystruct);
if ~all(isfield(tmp,pnames)) % if the propertynames are not all valid
    disp(['Some of your input property names are invalid: ' pnames{~isfield(tmp,fieldnames(axespropertystruct))}]);
    disp('Take care with upper and lower case letters; Matlab is case-sensitive!');
    disp('Cannot prepare axes, terminating.');
    return
end
% parse user-defined properties, overwriting defaults if necessary
propertylist = MW_default_propertylist;
for p = 1:length(pnames)
    propertylist.(pnames{p}) = axespropertystruct.(pnames{p});
end

pnames = fieldnames(propertylist); % complete list of property names
for h = 1:length(axeshandles)
    for p = 1:length(pnames)
        % assign value directly if possible:
        if ~ishghandle(get(axeshandles(h),pnames{p}))
            set(axeshandles(h),pnames{p},propertylist.(pnames{p}));
        else    % if value is a handle itself, deal with that here:
            switch lower(pnames{p})
                case {'title','xlabel','ylabel','zlabel'} % the value in the axis object for these properties is itself a graphics handle
                    % the easiest way to deal with this is to use the correct
                    % function to change their value. to do this, we convert
                    % the name of the property into the name of the function we
                    % need, then we execute the function:
                    tmpfunc = str2func(lower(pnames{p}));
                    tmpfunc(axeshandles(h),propertylist.(pnames{p}));
                otherwise
                    fprintf('MW_plotterPrepareAxes: unexpected problem with axes property %s; if it should theoretically work, please report to clio!', pnames{p});
                    return
            end
        end
    end
end

% if we got this far, everything worked fine:
success = 1; 