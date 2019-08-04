function continuousTable = getcontinuousdata(input1, varargin)
% GETCONTINUOUSDATA  Gets continuous data from a NEX file.
%
% Syntax:
% % Retrieve all continuous channels.
% intervalTable = GETCONTINUOUSDATA(nexFileName)
% ___ = GETCONTINUOUSDATA(fileID)
%
% % Retrieve specified channels via their index
% ___ = GETCONTINUOUSDATA(___, indices)
%
% % Retrieved specified channels based on their name.
% ___ = GETCONTINUOUSDATA(___, channelList)
%
% Description:
% Reads the specified channels and store the meta data for each channel and
% the associated raw continuous channels in a table where each row is a
% unique channel.
%
% Input:
% nexFileName (string) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
% indices (integer vector) - Vector of channel indices to extract.  Each 
%     element of the vector must be an integer in the range [1,nChannels],
%     where nChannels represents the total number of continuous variables
%     found in the NEX file.
% channelList (cell array of strings) - Each channel/continous variable has
%     a name associated with it.  Returned channels are filtered by the
%     contents of this list.
%
% Output:
% continuousTable (table) - Table where each row contains the data for a
%     unique channel.

%% Setup
% Check our input and prepare the NEX file.

if spikenex.isnex(input1)
    continuousTable = spikenex.nex.getcontinuousdata(input1, varargin{:});
else
    continuousTable = 0;
end