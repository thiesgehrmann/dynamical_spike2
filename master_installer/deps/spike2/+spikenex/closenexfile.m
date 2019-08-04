function closenexfile(fileID)
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

narginchk(1, 1);

validateattributes(fileID, {'numeric'}, {'nonempty' 'scalar'}, ...
    mfilename, 'fileID', 1);

% Close the file.
status = fclose(fileID);

% If we got an error closing the NEX file, throw an error.
assert(status == 0, 'nex:closenexfile:FileCloseError', ...
    'Unable to close filed ID: %g', fileID);
