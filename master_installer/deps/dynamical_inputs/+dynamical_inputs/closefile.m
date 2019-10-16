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

switch dynamical_inputs.determine_input_type(fileID)
    case 'NEX'
        [fid, wasOpened ] = dynamical_inputs.nex.closenexfile(fileID);
    case 'SPIKE'
        [fid, wasOpened ] = dynamical_inputs.spike2.closefile(input1);
    case 'MAT'
        [fid, wasOpened] = dynamical_inputs.mat.closefile(input1);
    otherwise
        assert(false, 'dynamical_inputs:closefile:InvalidFileType', "You must specify a NEX, SPIKE2 or MAT file as input.")
end

