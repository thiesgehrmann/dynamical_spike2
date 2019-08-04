function neuronTable = getneurondata(input1, channels)
% GETNEURONDATA  Extracts the data for neurons from a SPIKE2 data/file.
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
% Extracts all the data for neurons in channels from a SPIKE2 file.
%  All available information about the neurons is returned in
%  a table format.
%
% Input:
% spikeFileName (string) - The name of the SPIKE2 file to read.
% fileID (number) - A file ID to a previously opened SPIKE2 file via fopen.
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

[fh, wasOpened] = spikenex.spike2.openfile(input1);


if wasOpened
  cleanupObj = onCleanup(@() spikenex.spike2.closefile(fh));
end

valid_channels = spikenex.spike2.getChannelsOfType(fh, [5,6]);

if nargin == 2
	% If channels are specified, then 
  useIndices = true;
  validateattributes(channels, {'numeric'}, {'vector'}, mfilename, 'indices', 2);
  channels = arrayfun(@(x) ismember(x, valid_channels), channels);
  assert(size(channels) > 0, 'spike2:getneurondata:NoValidChannels', 'You did not specify any valid chanels. They must be Marker|WaveMark types.');
else
	channels = valid_channels;
end

neuronData = arrayfun(@(cid) spikenex.spike2.getneurondatachannel(input1, cid), channels);


% There MUST be a better way to do this :S
nd.name       = cat(1, neuronData.name);
nd.varVersion = cat(1, neuronData.varVersion);
nd.wireNumber = cat(1, neuronData.wireNumber);
nd.unitNumber = cat(1, neuronData.unitNumber);
nd.xPos       = cat(1, neuronData.xPos      );
nd.yPos       = cat(1, neuronData.yPos      );
nd.timestamps = cat(1, neuronData.timestamps);

% Throw it all into a table
neuronTable = struct2table(nd);
