function neuronTable = getneurondata(input1, indices)
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

narginchk(1, 2);

% Set the flag that indicates if we're using indices when reading the
% variable data.
if nargin == 2
    useIndices = true;
    validateattributes(indices, {'numeric'}, {'vector'}, mfilename, 'indices', 2);
else
    useIndices = false;
end

% Open the nex file and get a file descriptor.
[fid, wasOpened] = nex.opennexfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() nex.closenexfile(fid));
end

%% Data Extraction
% Pull the neuron data out of the NEX data file.  If indices were
% specified, we'll extract only a subset.

if useIndices   
    % Extract the raw neuron data.
    neuronData = nex.readvariabledata(fid, nex.NexVariableTypes.Neuron, ...
        'Indices', indices);
else
    neuronData = nex.readvariabledata(fid, nex.NexVariableTypes.Neuron);
end

% Stick everything into a table.
neuronTable = struct2table([neuronData{:}], 'AsArray', true);
