function [ channels ] = listChannels(input1)
% LISTCHANNELS  List the channel indexes in the MAT file
%
% Syntax:
% channels = LISTCHANNELS(fileName)
% fileHeader = LISTCHANNELS(fileID)
%
% Description:
% Extracts the top level header file information from a NEX file.
%
% Input:
% fileName (string) - The name of the SPIKE2 file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened SPIKE2 file via fopen.
%
% Output:
% channels (array) Array of channel identifiers


%% Setup
% Check our input and prepare the SPIKE2 file.
narginchk(1, 1);

% Open the MAT file.
[S, wasOpened] = dynamical_inputs.mat.openfile(input1);

channels = S.neurondata.name;
