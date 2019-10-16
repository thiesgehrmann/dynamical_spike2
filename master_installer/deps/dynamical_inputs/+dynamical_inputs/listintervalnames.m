function intervalNames = listintervalnames(input1)
% LISTINTERVALNAMES  Lists the interval names found in the NEX data or file.
%
% Syntax:
% intervalTypes = LISTINTERVALNAMES(nexFileName)
% intervalTypes = LISTINTERVALNAMES(fileID)
%
% Description:
% Gets a list of the interval names found in the nex data/file.
%
% Input:
% nexFileName (1xN char) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Output:
% intervalNames (string array) - String array where each element is the
%     name of an interval.

%% Setup
% Check our input and prepare the NEX file.
switch dynamical_inputs.determine_input_type(input1)
    case 'NEX'
        intervalNames = dynamical_inputs.nex.listintervalnames(input1);
    case 'SPIKE'
        intervalNames = dynamical_inputs.spike2.listintervalnames(input1);
    case 'MAT'
        intervalNames = dynamical_inputs.mat.listintervalnames(input1);
    otherwise
        assert(false, 'dynamical_inputs:listintervalnames:InvalidFileType', "You must specify a NEX, SPIKE2 or MAT file as input.")
end
