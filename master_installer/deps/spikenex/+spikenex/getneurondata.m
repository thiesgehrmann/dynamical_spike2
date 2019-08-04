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
if spikenex.isnex(input1)
    neuronTable = spikenex.nex.getneurondata(input1, varargin{:});
else
    neuronTable = spikenex.spike2.getneurondata(input1, varargin{:});
end