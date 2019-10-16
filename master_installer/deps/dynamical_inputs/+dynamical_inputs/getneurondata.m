function neuronTable = getneurondata(input1, varargin)
% GETNEURONDATA  Extracts the data for specified neurons from NEX data/file.
%
% Syntax:
% % Get all neuron data.
% neuronTable = GETNEURONDATA(nexFileName)
% ___ = GETNEURONDATA(fileID)
% ___ = GETNEURONDATA(___, indices)
%
% Description:
% Extracts all the data for specified neurons from a NEX file or a NEX
% data struct.  All available information about the neurons is returned in
% a table format.
%
% Input:
% nexFileName (string) - The name of the NEX file to read.
% fileID (number) - A file ID to a previously opened NEX file via fopen.
% indices (vector) - Numeric indices of specific neurons to read.
%
% Output:
% neuronTable (table) - Table of extracted neuron data.  Each column
%     corresponds to a field found in the raw neuron data.
%
%     Variables:
%     * name (categorical)
%     * varVersion (scalar)
%     * wireNumber (scalar)
%     * unitNumber (scalar)
%     * xPos (scalar)
%     * yPos (scalar)
%     * timestamps (cell) - Contains a Mx1 array of the timestamp data.

%% Setup
% Check our input and prepare the NEX file.


switch dynamical_inputs.determine_input_type(input1)
    case 'NEX'
        neuronTable = dynamical_inputs.nex.getneurondata(input1, varargin{:});
    case 'SPIKE'
        neuronTable = dynamical_inputs.spike2.getneurondata(input1, varargin{:});
    case 'MAT'
        neuronTable = dynamical_inputs.mat.getneurondata(input1, varargin{:});
    otherwise
        assert(false, 'dynamical_inputs:neuronTable:InvalidFileType', "You must specify a NEX, SPIKE2 or MAT file as input.")
end
    