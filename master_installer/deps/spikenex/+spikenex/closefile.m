function closefile(fileID)
% CLOSENEXFILE  Closes a NEX file and performs any cleanup.
%
% Syntax:
% CLOSENEXFILE(fileID)
%
% Description:
% Closes a NEX file and performs any cleanup operations required.
%
% Input:
% fileID (integer) - A file ID to a previously opened NEX file via
%     fopen.
%
% Throws:
% nex:closenexfile:FileCloseError - Failure to close the specified NEX file.

if spikenex.isnex(fileID)
	spikenex.nex.closenexfile(fileID);
else
	spikenex.spike2.closefile(fileID);
end
