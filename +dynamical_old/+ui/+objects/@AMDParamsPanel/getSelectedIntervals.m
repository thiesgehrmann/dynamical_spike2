function selectedIntervals = getSelectedIntervals(obj)
% GETSELECTEDINTERVALS  Returns the selected interval names.
%
% Syntax:
% selectedIntervals = GETSELECTEDINTERVALS(obj)
%
% Description:
% Returns the currently selected intervals found in the interval list box.
%
% Input:
% obj (dynamical.ui.objects.AMDParamsPanel) - AMDParamsPanel source object.
%
% Output:
% selectedIntervals (string array|empty) - List of selected interval names.

narginchk(1, 1);

% Get the list of selected values.  Convert to a cell array because if only
% one value is selected the "String" property is a character array.
i = obj.IntervalListBox.Value;
s = cellstr(obj.IntervalListBox.String);
v = s(i);

% Converting an empty string into a MATLAB string results in a non-empty
% value even if the string is actually empty.  Make sure the return value
% is truly empty if nothing was selected.
if isempty(v)
    selectedIntervals = [];
else
    selectedIntervals = string(v);
end
