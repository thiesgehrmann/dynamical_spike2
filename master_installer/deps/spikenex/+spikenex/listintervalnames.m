function intervalNames = listintervalnames(input1)
% LISTINTERVALNAMES  Lists the interval names found in the NEX data or file.
%
% Syntax:
% intervalTypes = LISTINTERVALNAMES(nexFileName)
% intervalTypes = LISTINTERVALNAMES(fileID)
%
% Description:
% Gets a list of the interval names found in the nex data/file.
%
% Input:
% nexFileName (1xN char) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Output:
% intervalNames (string array) - String array where each element is the
%     name of an interval.

%% Setup
% Check our input and prepare the NEX file.
if spikenex.isnex(input1)
    intervalNames = spikenex.nex.listintervalnames(input1);
else
    intervalNames = spikenex.spike2.listintervalnames(input1);
end