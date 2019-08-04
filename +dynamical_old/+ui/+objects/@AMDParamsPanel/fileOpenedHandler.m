function fileOpenedHandler(obj, ~, eventData)
% FILEOPENEDHANDER
%
% Syntax:
%
% Description:
%
% Input:
%
% Output:
%

dynamical.dprintf(2, '# AMDParamsPanel:fileOpenedHandler\n');

% Get a list of the interval names found in the NEX file and set the UI.
% Exclude intervals that are listed in the config to be ignored.
config = dynamical.config.readconfig;
ignoredIntervals = string(config.analysis.ignoredIntervalTypes)';
allIntervals = nex.listintervalnames(eventData.FileID);
obj.IntervalNames = setdiff(allIntervals, ignoredIntervals);

% Get the file meta info.
fileHeader = nex.readfileheader(eventData.FileID);
obj.StartTime = fileHeader.tbeg;
obj.StopTime = fileHeader.tend;

% Enable the process button.  It's disabled whenever the program starts up.
obj.ProcessButton.Enable = 'on';
