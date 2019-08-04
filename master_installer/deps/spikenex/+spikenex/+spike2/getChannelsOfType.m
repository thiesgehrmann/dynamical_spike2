function [ channels ] = getChannelsOfType(input1, type)
% LISTCHANNELS  List the channel indexes in the SPIKE2 file
%
% Syntax:
% channels = LISTCHANNELS(fileName, type)
% fileHeader = LISTCHANNELS(fileID, type)
%
% Description:
% Extracts the top level header file information from a NEX file.
%
% Input:
% fileName (string) - The name of the SPIKE2 file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened SPIKE2 file via fopen.
% type (integer | array of Integers) - The channel types you are interested in
%   0=channel unused,
%   1=Adc, 
%   2=EventFall, 
%   3=EventRise, 
%   4=EventBoth, 
%   5=Marker, 
%   6=WaveMark, 
%   7=RealMark, 
%   8=TextMark, 
%   9=RealWave.
%
% Output:
% channels (array) Array of channel identifiers which match your type
%
% Example:
%   Get all channels of Marker|WaveMark types
%   getChannelsOfType(fh, [5,6])
%
%  Get all channels of the ADC type
%  getChannelsOfType(fh, 1)


%% Setup
% Check our input and prepare the SPIKE2 file.
narginchk(2, 2);

% Open the SPIKE2 file.
[fh, wasOpened] = spikenex.spike2.openfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() spikenex.spike2.closefile(fh));
end

channels = find(ismember(arrayfun( @(cid) CEDS64ChanType(fh, cid), 1:CEDS64MaxChan(fh)), type));