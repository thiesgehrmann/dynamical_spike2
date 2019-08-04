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

narginchk(1, 1);

% Open the nex file and get a file descriptor.
[fid, wasOpened] = nex.opennexfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() nex.closenexfile(fid));
end

%% Extract Neuron Names

% Get the header data for the intervals.
neuronHeaders = nex.readvariableheaders(fid, ...
    'VariableTypes', nex.NexVariableTypes.Neuron);

% Get the list of neuron names from the header data extracted above.
if isempty(neuronHeaders)
    neuronNames = string([]);
else
    neuronNames = neuronHeaders.name;
    
    if ~verLessThan('matlab', '9.1')
        neuronNames = string(neuronNames);
    end
end
