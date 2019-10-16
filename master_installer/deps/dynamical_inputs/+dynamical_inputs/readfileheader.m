function fileHeader = readfileheader(input1)
% READFILEHEADER  Reads the file header information from a NEX file.
%
% Syntax:
% fileHeader = READFILEHEADER(nexFileName)
% fileHeader = READFILEHEADER(fileID);
%
% Description:
% Extracts the top level header file information from a NEX file.
%
% Input:
% nexFileName (string) - The name of the NEX file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Output:
% fileHeader (struct) - The header information from the NEX file.
%     Fields:
%     version (scalar) - NEX file version
%     comment (string) - File comment
%     freq (scalar) - Timestamp frequency (Hz)
%     tbeg (scalar) - Minimum timestamp (s)
%     tend (scalar) - Maximum timestamp (s)
%     numvars (scalar) - The number of variables in the file.
%
% Throws:
% nex:getfileheader:InvalidNEXFile - File specified is not a NEX file.
%
% Examples:
% % Read header data by specifiying the file name.
% fileHeader = getfileheader('myfilename.nex');
%
% % Read header data by specifying a file ID.
% fid = fopen('myfilename.nex', 'r', 'l', 'US-ASCII');
% fileHeader = getfileheader('myfilename.nex');

switch dynamical_inputs.determine_input_type(input1)
    case 'NEX'
        fileHeader = dynamical_inputs.nex.readfileheader(input1);
    case 'SPIKE'
        fileHeader = dynamical_inputs.spike2.readfileheader(input1);
    case 'MAT'
        fileHeader = dynamical_inputs.mat.readfileheader(input1);
    otherwise
        assert(false, 'dynamical_inputs:openfile:InvalidFileType', "You must specify a NEX, SPIKE2 or MAT file as input.")
end
