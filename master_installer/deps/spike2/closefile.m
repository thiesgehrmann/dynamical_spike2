function closefile(fileID)
% CLOSEFILE  Closes a SPIKE2 file and performs any cleanup.
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
% spike2:closefile:FileCloseError - Failure to close the specified SPIKE2 file.

loadCEDS64()

narginchk(1, 1);

validateattributes(fileID, {'numeric'}, {'nonempty' 'scalar'}, ...
    mfilename, 'fileID', 1);

% Close the file.
status = fclose(fileID);

% If we got an error closing the NEX file, throw an error.
assert(status == 0, 'spike2:closefile:FileCloseError', ...
    'Unable to close file descriptor ID: %g', fileID);
