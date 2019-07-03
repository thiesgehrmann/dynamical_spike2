function [fid, wasOpened] = openfile(input1)
% OPENNFILE  Opens a SPIKE2 file and/or preps it for access.
%
% Syntax:
% [fid, wasOpened] = OPENFILE(spike2FileName)
% [fid, wasOpened] = OPENFILE(fileID)
%
% Description:
% Opens a SPIKE2 file and/or preps it for access.  If a filename is specified,
% the file is opened and a file descriptor is returned.  If a file
% descriptor is passed, the file position indicator is set to the beginning
% of the file via frewind.
%
% Input:
% nexFileName (string) - The name of the SPIKE2 file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened SPIKE2 file via fopen.
%
% Output:
% fileID (integer) - A file descriptor pointing to the beginning of the SPIKE2
%     file.
% wasOpened (logical) - True if the file was opened and a new file
%     descriptor was created, i.e. a string was passed to this function.
%
% Throws:
% nex:opennexfile:FileOpenError - Failure to open/initialize the specified
%     NEX file.

%% Validate Input
narginchk(1, 1);

% 'input1' - Must be a string or numeric value(s) was specified.
validateattributes(input1, ...          % File ID or File Name
    {'char' 'string' 'numeric'}, ...    % Valid data classes
    {'vector' 'nonempty'}, ...          % Required data attributes
    mfilename, ...                      % Name of calling function
    'nexFileName/fileID', ...           % Argument name
    1);                                 % Argument position


%% Setup File Access
% Open the NEX file if we were passed a filename.  If passed a file ID,
% rewind the file position indicator to the beginning of the NEX file where
% the file header data is located.

if ischar(input1) || isstring(input1)
    % Open the NEX file.
    [fid, errorMessage] = fopen(input1, 'r', 'l', 'US-ASCII');
    assert(fid ~= -1, 'nex:opennexfile:FileOpenError', errorMessage);
    wasOpened = true;
else
    % Copy the file ID to a more descriptive label matching the 'fid' from
    % the code above.
    fid = input1;
    
    % Rewind the file descriptor to the beginning of the NEX file.
    frewind(fid);
    
    wasOpened = false;
end
