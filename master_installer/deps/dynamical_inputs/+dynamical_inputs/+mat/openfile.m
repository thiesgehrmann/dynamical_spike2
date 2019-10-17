function [data, wasOpened] = openfile(input1)
% OPENFILE  Opens a MAT file and/or preps it for access.
%
% Syntax:
% [fid, wasOpened] = OPENFILE(matFileName)
% [fid, wasOpened] = OPENFILE(table)
%
% Description:
% Opens a matlab file and/or preps it for access.  If a filename is specified,
% the file is opened and a file descriptor is returned.  If a file
% descriptor is passed, the file position indicator is set to the beginning
% of the file via frewind.
%
% Input:
% matFileName (string) - The name of the MAT file from which to
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
% mat:openfile:FileOpenError - Failure to open/initialize the specified
%     mat file.

%% Validate Input
narginchk(1, 1);

% 'input1' - Must be a string or numeric value(s) was specified.
validateattributes(input1, ...          % File ID or File Name
    {'char' 'string' 'struct'}, ...    % Valid data classes
    { 'nonempty'}, ...          % Required data attributes
    mfilename, ...                      % Name of calling function
    'matFileName/table', ...           % Argument name
    1);                                 % Argument position


%% Setup File Access
% Open the MAT file & extract the table if we were passed a filename.
% If it is not a string, check that it is a table.

if ischar(input1) || isstring(input1)
    % Open the NEX file.
    data = dynamical_inputs.mat.load_struct(input1);
    wasOpened = true;
else
    data = input1;
    wasOpened = false;
end

assert(isstruct(data), "dynamical_inputs:mat:verify_struct:NotStruct", "The data is not a struct")
assert(any(strcmp(fieldnames(data), 'neurondata')), "dynamical_inputs:mat:verify_struct:MissingData", "There was no table with neurondata available.")
assert(istable(data.neurondata), "dynamical_inputs:mat:verify_struct:Invalid", "The structure is invalid.")

assert(dynamical_inputs.mat.verify_struct(data), "dynamical_inputs:mat:openfile:NotValid", "The input file does not contain a valid structure!");