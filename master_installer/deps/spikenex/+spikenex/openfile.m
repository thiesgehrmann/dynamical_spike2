function [fid, wasOpened] = opennexfile(input1)
% OPENNEXFILE  Opens a nex file and/or preps it for access.
%
% Syntax:
% [fid, wasOpened] = OPENNEXFILE(nexFileName)
% [fid, wasOpened] = OPENNEXFILE(fileID)
%
% Description:
% Opens a nex file and/or preps it for access.  If a filename is specified,
% the file is opened and a file descriptor is returned.  If a file
% descriptor is passed, the file position indicator is set to the beginning
% of the file via frewind.
%
% Input:
% nexFileName (string) - The name of the NEX file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Output:
% fileID (integer) - A file descriptor pointing to the beginning of the NEX
%     file.
% wasOpened (logical) - True if the file was opened and a new file
%     descriptor was created, i.e. a string was passed to this function.
%
% Throws:
% nex:opennexfile:FileOpenError - Failure to open/initialize the specified
%     NEX file.

if spikenex.isnex(input1)
    [fid, wasOpened ] = spikenex.nex.opennexfile(input1);
else
    [fid, wasOpened ] = spikenex.spike2.openfile(input1);
end