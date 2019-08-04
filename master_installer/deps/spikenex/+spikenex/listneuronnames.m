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

if spikenex.isnex(input1)
    neuronNames = spikenex.nex.listneuronnames(input1);
else
    neuronNames = 0;
end