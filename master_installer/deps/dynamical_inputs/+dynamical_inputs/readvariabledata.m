function variableData = readvariabledata(input1, varargin)
% READVARIABLE  Read variable data from a NEX file.
%
% Syntax:
% % Read all variable elements.
% variableData = readvariable(nexFileName, variableType)
% variableData = readvariable(fileID, variableType)
%
% % Read specified variable elements.
% variableData = readvariable(nexFileName, variableType, 'Indices', indices)
% variableData = readvariable(fileID, variableType, 'Indices', indices)
%
% Description:
% Reads the specified variable data from a NEX file.  By default, all
% variable elements of the specified type are read, but individual or
% groups of elements can be selected.  Indices for the different variable
% types can mean different things.  For instance, the indices for
% continuous variables will be analagous to the different channels, while
% the indices for marker variables will specify unique marker values.
%
% Input:
% nexFileName (string) - The name of the NEX file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
% variableType (nex.NexVariableTypes) - The variable type to read in.  This
%     must be a scalar value.
% indices (integer vector) - List of channels/elements to read in.  Each 
%     index must be in the range [1, number of variable elements].
%
% Output:
% variableData (cell vector) - Cell vector/array containing the variable
%     elements read.  The contents of each cell will vary depending on the
%     variable type.  If no data of the specified variable type is found,
%     this will be empty.

%% Setup
% Check our input and prepare the NEX file.
switch dynamical_inputs.determine_input_type(input1)
    case 'NEX'
        variableData = dynamical_inputs.nex.readvariabledata(input1, varargin{:});
    case 'SPIKE'
        variableData = 0
    case 'MAT'
        variableData = 0
    otherwise
        assert(false, 'dynamical_inputs:openfile:InvalidFileType', "You must specify a NEX, SPIKE2 or MAT file as input.")
end
