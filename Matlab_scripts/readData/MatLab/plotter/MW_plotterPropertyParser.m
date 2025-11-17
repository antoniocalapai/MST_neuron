function properties = MW_plotterPropertyParser(defaultProperties,optionalProperties)
% properties = MW_plotterPropertyParser(defaultProperties,optionalProperties)
%
% parses graphical properties input by user to plotting functions. both are
% expected to be structures defining properties for different plotting
% types, e.g. defaultProperties.POINT and defaultProperties.STAIR for an
% stc data structure
%
% cquigley@dpz.eu, jan 2014

propClasses = fieldnames(defaultProperties);
for c = 1:length(propClasses)
    % assign defaults
    properties.(propClasses{c}) = defaultProperties.(propClasses{c});
    % now add/overwrite optionals if specified
    if isfield(optionalProperties,propClasses{c})
        pnames = fieldnames(optionalProperties.(propClasses{c}));
        for p = 1:length(pnames)
            properties.(propClasses{c}).(pnames{p}) = optionalProperties.(propClasses{c}).(pnames{p});
        end
    end
end