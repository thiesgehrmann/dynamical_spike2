function intervalTable = getintervaltimes(input1, intervalName, isCaseSensitive)
% GETINTERVALTIMES  Gets interval data from a NEX file.
%
% Syntax:
% intervalTable = GETINTERVALTIMES(nexFileName, intervalName)
% ___ = GETINTERVALTIMES(fileID, intervalName)
% ___ = GETINTERVALTIMES(___, isCaseSensitive)
%
% Description:
% Read the interval table (start/stop times) from a nex file for a
% specified interval.
%
% Input:
% nexFileName (string) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
% intervalName (string) - The name of the interval to extract.
% isCaseSensitive (logical) - If true, we do a case sensitive search for
%     the interval name.  Default: false
%
% Output:
% intervalTable (table) - A table of the start and end times for all
%     intervals matching the interval type.  As a convenience, the duration
%     of each interval (row) is added as a 3rd column to the table.
%
% Examples:
% % Get REM interval times (case insensitive).
% intervalTable = GETINTERVALTIMES('C:\datafile.nex', 'REM')
%
% % Get REM interval times (case sensitive).
% intervalTable = GETINTERVALTIMES('C:\datafile.nex', 'Rem', true);

%% Setup
% Check our input and prepare the NEX file.

narginchk(2, 3);

if nargin < 3
    isCaseSensitive = false;
end

% The interval name must be a non-empty string.
validateattributes(intervalName, {'char', 'string'}, {'vector', 'nonempty'}, ...
    mfilename, 'intervalName', 2);

validateattributes(isCaseSensitive, {'logical'}, {'scalar' 'nonempty'}, ...
    mfilename, 'isCaseSensitive', 3);

% Open the nex file and get a file descriptor.
[fid, wasOpened] = nex.opennexfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() nex.closenexfile(fid));
end

%% Extract Interval Times

% Get a list of interval names found in the nex data.  Make the list upper
% case for easy string matching.
allIntervalNames = nex.listintervalnames(fid);

% Make sure the desired interval type exists in the list of available
% interval types.
if isCaseSensitive
    assert(ismember(intervalName, allIntervalNames), ...
        'nex:getintervaltimes:invalidIntervalName', ...
        'Interval name "%s" does not exist in the NEX data.', intervalName);
else
    assert(ismember(upper(intervalName), upper(allIntervalNames)), ...
        'nex:getintervaltimes:invalidIntervalName', ...
        'Interval name "%s" does not exist in the NEX data.', intervalName);
end

% Pull out the variable data which contains the interval times.
intervalData = nex.readvariabledata(fid, nex.NexVariableTypes.Interval);

% Find the index of the desired interval.
if isCaseSensitive
    iInterval = cellfun(@(x) strcmp(intervalName, x.name), intervalData);
else
    iInterval = cellfun(@(x) strcmpi(intervalName, x.name), intervalData);
end

% If all the checks above worked we shouldn't find nothing, but we're
% paranoid...
assert(sum(iInterval) > 0, 'Unexpected Error: Did not find "%s" in the interval data.', ...
    intervalName);

% We also don't want more than 1 match for the specified interval name.
assert(sum(iInterval) == 1, 'Too many intervals found when searching for: %s', ...
    intervalName);

% Create the table.
intervalTable = table(intervalData{iInterval}.intStarts, ...
    intervalData{iInterval}.intEnds, ...
    intervalData{iInterval}.intEnds - intervalData{iInterval}.intStarts, ...
    'VariableNames', {'Start' 'End', 'Duration'});
