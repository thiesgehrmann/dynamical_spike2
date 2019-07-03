function intervalNames = listintervalnames(input1)
% LISTINTERVALNAMES  Lists the interval names found in the NEX data or file.
%
% Syntax:
% intervalTypes = LISTINTERVALNAMES(nexFileName)
% intervalTypes = LISTINTERVALNAMES(fileID)
%
% Description:
% Gets a list of the interval names found in the nex data/file.
%
% Input:
% nexFileName (1xN char) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Output:
% intervalNames (string array) - String array where each element is the
%     name of an interval.

%% Setup
% Check our input and prepare the NEX file.

narginchk(1, 1);

% Open the NEX file.
[fid, wasOpened] = nex.opennexfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() nex.closenexfile(fid));
end

%% Extract Interval Names

% Get the header data for the intervals.
intervalHeaders = nex.readvariableheaders(fid, ...
    'VariableTypes', nex.NexVariableTypes.Interval);

% Get the list of interval names from the interval header data
% extracted above.
if isempty(intervalHeaders)
    intervalNames = {};
else
    intervalNames = string(intervalHeaders.name);
    
    if ~verLessThan('matlab', '9.1')
        intervalNames = string(intervalNames);
    end
end
