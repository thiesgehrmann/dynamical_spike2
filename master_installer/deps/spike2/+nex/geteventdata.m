function eventTable = geteventdata(input1)
% GETEVENTDATA  Gets event data from a NEX file.
%
% Syntax:
% eventData = GETEVENTDATA(nexFileName)
% eventData = GETEVENTDATA(fileID)
%
% Description:
% Reads the event data from a NEX file.  Each element of the event data
% contains the event's name and its timestamps.
%
% Input:
% nexFileName (string) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Output:
% eventData (table) - The event data where each row contains an individual
%     event's data.

%% Setup
% Check our input and prepare the NEX file.

narginchk(1, 1);

% Open the nex file and get a file descriptor.
[fid, wasOpened] = nex.opennexfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() nex.closenexfile(fid));
end

%% Extract Event Data

% Read the event data.  It will be returned as a cell array which we'll
% want to reformat into a table.
eventData = nex.readvariabledata(fid, nex.NexVariableTypes.Event);
nEvents = numel(eventData);

% Initialize the event table as empty.  We'll add on event rows in the loop
% below.
eventTable = [];

for iEvent = 1:nEvents
    t = table({eventData{iEvent}.name}, {eventData{iEvent}.timestamps}, ...
        'VariableNames', {'Name', 'Timestamps'});
    
    eventTable = [eventTable ; t]; %#ok<AGROW>
end
