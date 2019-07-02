function editCallback(obj, source, ~)
% EDITCALLBACK
%
% Syntax:
%
% Description:
%
% Input:
%
% Output:
%

try
    % Set the class property that is associated with the source object.
    val = str2double(source.String);
    propName = sprintf('%s', source.UserData);
    
    obj.(propName) = val;
    
    % Reset the background color of the edit control to the default.  This
    % is a visual indicator that the value was saved.
    source.BackgroundColor = get(0, 'DefaultUicontrolBackgroundColor');
catch e
    ignoreList = {'MATLAB:notGreaterEqual'};
    
    if ismember(e.identifier, ignoreList)
        warning(e.identifier, e.message);
    else
        rethrow(e);
    end
end
