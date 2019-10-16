function intervalNames = listintervalnames(input1)
% LISTINTERVALNAMES  Lists the interval names found in the SPIKE2 data or file.
%
% Syntax:
% intervalTypes = LISTINTERVALNAMES(spike2FileName)
% intervalTypes = LISTINTERVALNAMES(fileID)
%
% Description:
% Gets a list of the interval names found in the nex data/file.
%
% Input:
% nexFileName (1xN char) - The name of the SPIKE2 file to read.
% fileID (integer) - A file ID to a previously opened SPIKE2 file via fopen.
%
% Output:
% intervalNames (string array) - String array where each element is the
%     name of an interval.

%% Setup
% Check our input and prepare the SPIKE2 file.

narginchk(1, 1);

% SPIKE2 doesn't have support for intervals, so I will just return a dummy list

[S, wasOpened] = dynamical_inputs.mat.openfile(input1);

intervalNames = S.intervalnames;
