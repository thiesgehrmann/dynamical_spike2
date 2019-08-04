function [ channels ] = listChannels(input1)
% LISTCHANNELS  List the channel indexes in the SPIKE2 file
%
% Syntax:
% channels = LISTCHANNELS(fileName)
% fileHeader = LISTCHANNELS(fileID)
%
% Description:
% Extracts the top level header file information from a NEX file.
%
% Input:
% fileName (string) - The name of the SPIKE2 file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened SPIKE2 file via fopen.
%
% Output:
% channels (array) Array of channel identifiers


%% Setup
% Check our input and prepare the SPIKE2 file.
narginchk(1, 1);

% Open the SPIKE2 file.
[fh, wasOpened] = openfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() closefile(fh));
end

channels = find(arrayfun( @(cid) CEDS64ChanType(fh, cid), 1:CEDS64MaxChan(fh)) > 0)
