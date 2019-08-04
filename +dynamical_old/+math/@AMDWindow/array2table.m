function windowTable = array2table(windowArray)
% ARRAY2TABLE  Transforms an AMDWindow array into a table.
%
% Syntax:
% windowTable = ARRAY2TABLE(windowArray)
%
% Description:
% Converts an array of AMDWindows to an easy to read table where each row
% is the data for one window ordered by start time.
%
% Input:
% windowList (AMDWindow array) - Array of AMDWindows.
%
% Output:
% windowTable (table) - Table containing all the window data where each row
%     is the data for a single window.
%
% See also AMDWINDOW TABLE TABLE2ARRAY

narginchk(1, 1);

% Validate the AMDWindow array.
validateattributes(windowArray, {'dynamical.math.AMDWindow'}, ...
    {'nonempty' 'vector'}, mfilename, 'windowList', 1);

% Sort the windows by their start time.
startTimes = [windowArray.WindowStart];
[~, i] = sort(startTimes);
windowArray = windowArray(i);
nWindows = length(windowArray);

% List of AMDWindow variables we want to stick in the table.
variableList = {'WindowStart', 'WindowEnd', 'TimeMin', 'TimeMax', ...
    'TimeDiff', 'Stats', 'ZScore', 'AMD'};
nVariables = length(variableList);

% For every variable we listed above, create a column for all windows in
% our list and add it to the window table.
for i = 1:nVariables
    variableName = variableList{i};
    
    for j = 1:nWindows
        windowStruct(j).(variableName) = windowArray(j).(variableName); %#ok<AGROW>
    end
end

% For easier reading, label each row with "Window X", where X represents
% the row number/window ID.
rowNames = arrayfun(@(x) {sprintf('Window %d', x)}, 1:nWindows)';

windowTable = struct2table(windowStruct, 'AsArray', true, 'RowNames', rowNames);
