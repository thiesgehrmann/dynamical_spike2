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

if spikenex.isnex(input1)
    eventTable = spikenex.nex.geteventdata(input1);
else
    eventTable = 0;
end