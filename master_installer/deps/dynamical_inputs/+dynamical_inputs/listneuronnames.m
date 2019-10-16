function neuronNames = listneuronnames(input1)
% LISTNEURONNAMES  Lists the neuron names found in the NEX data or file.
%
% Syntax:
% neuronNames = LISTNEURONNAMES(nexFileName)
% neuronNames = LISTNEURONNAMES(fileID)
%
% Description:
% Gets a list of the neuron names found in the nex data/file.
%
% Input:
% nexFileName (string) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Output:
% neuronNames (string array) - String array where each elements is the
%     name of a neuron.

%% Setup
% Check our input and prepare the NEX file.

switch dynamical_inputs.determine_input_type(input1)
    case 'NEX'
        neuronNames = dynamical_inputs.nex.listneuronnames(input1);
    case 'SPIKE'
        neuronNames = dynamical_inputs.spike2.listneuronnames(input1);
    case 'MAT'
        neuronNames = dynamical_inputs.mat.listneuronnames(input1);
    otherwise
        assert(false, 'dynamical_inputs:listneuronnames:InvalidFileType', "You must specify a NEX, SPIKE2 or MAT file as input.")
end
