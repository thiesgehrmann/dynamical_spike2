function closefile(fileID)
% CLOSEFILE  Closes a NEX file and performs any cleanup.
%
% Syntax:
% CLOSEFILE(fileID)
%
% Description:
% Closes a SPIKE2 file and performs any cleanup operations required.
%
% Input:
% fileID (integer) - A file ID to a previously opened SPIKE2 file via
%     fopen.
%
% Throws:
% nex:closenexfile:FileCloseError - Failure to close the specified SPIKE2 file.

narginchk(1, 1);

validateattributes(fileID, {'numeric'}, {'nonempty' 'scalar'}, ...
    mfilename, 'fileID', 1);

% Close the file.
status = fclose(fileID);

% If we got an error closing the NEX file, throw an error.
assert(status == 0, 'nex:closenexfile:FileCloseError', ...
    'Unable to close filed ID: %g', fileID);
