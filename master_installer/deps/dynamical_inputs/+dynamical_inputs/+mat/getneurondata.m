function neuronTable = getneurondata(input1, channels)
% GETNEURONDATA  Extracts the data for neurons from a MAT data/file.
%
% Syntax:
% % Get all neuron data from all channels.
% neuronTable = GETNEURONDATACHANNEL(spikeFileName)
% ___ = GETNEURONDATACHANNEL(fileID)
% % Get only neurons from the specified channels
% neuronTable = GETNEURONDATACHANNEL(spikeFileName, channels)
% ___ = GETNEURONDATACHANNEL(fileID, channels)
%
% Description:
% Extracts all the data for neurons in channels from a MAT file.
%  All available information about the neurons is returned in
%  a table format.
%
% Input:
% spikeFileName (string) - The name of the MAT file to read.
% fileID (number) - A file ID to a previously opened MAT file via fopen.
% channel (int) - Numeric indices of specific neurons to read.
%
% Output:
% neuronTable (table) - Table of extracted neuron data.  Each column
%     corresponds to a field found in the raw neuron data.
%
%     Variables:
%     * name (categorical)
%     * varVersion (scalar) NOTE: This variable means NOTHING in SPIKE2
%     * wireNumber (scalar) NOTE: This variable means NOTHING in SPIKE2
%     * unitNumber (scalar) NOTE: This variable means NOTHING in SPIKE2
%     * xPos (scalar)       NOTE: This variable means NOTHING in SPIKE2
%     * yPos (scalar)       NOTE: This variable means NOTHING in SPIKE2
%     * timestamps (cell) - Contains a Mx1 array of the timestamp data.

%% Setup
% Check our input and prepare the NEX file.

narginchk(1, 2);

[S, wasOpened] = dynamical_inputs.mat.openfile(input1);

neuronTable = S.neurondata;
