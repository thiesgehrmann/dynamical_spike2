function checkboxCallback(obj, source, ~)
try
    % Set the AMDParamsPanel class property that is associated with the
    % source object.
    val = logical(source.Value);
    propName = sprintf('%s', source.UserData);
    obj.(propName) = val;
catch e
    ignoreList = {'MATLAB:notGreaterEqual'};
    
    if ismember(e.identifier, ignoreList)
        warning(e.identifier, e.message);
    else
        rethrow(e);
    end
end