function windowArray = table2array(windowTable)
% TABLE2ARRAY  Converts an AMD window table into an array.
%
% Syntax:
% windowArray = TABLE2ARRAY(windowTable)
%
% Description:
% Converts a table of AMDWindows into an array.
%
% Input:
% windowTable (table) - Table of AMDWindows.
%
% Output:
% windowArray (AMDWindow array) - Array of AMDWindows where windowArray(i)
%     corresponds to windowTable(i,:).
%
% See also AMDWINDOW TABLE ARRAY2TABLE

narginchk(1, 1);

% Validate the AMDWindow table.
validateattributes(windowTable, {'table'}, {'nonempty'}, mfilename, ...
    'windowTable', 1);

% Convert the table into a struct array and pull out its fieldnames.  We'll
% use the fieldnames as parameter names passed to the AMDWindow
% constructor.
windowStruct = table2struct(windowTable);
fields = fieldnames(windowStruct);

nWindows = height(windowTable);
for i = 1:nWindows
    c = [fields, struct2cell(windowStruct(i))]';
    windowArray(i) = dynamical.math.AMDWindow(c{:}); %#ok<AGROW>
end
