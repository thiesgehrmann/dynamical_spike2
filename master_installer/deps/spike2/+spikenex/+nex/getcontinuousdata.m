function continuousTable = getcontinuousdata(input1, indices)
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

narginchk(1, 2);

% If not specified, make the indices argument empty.  This flags that we
% want all channels returned.
if nargin < 2
    indices = [];
else
    % Make sure that the indices argument is a cell/numeric vector.
    validateattributes(indices, {'cell', 'numeric'}, {'vector'}, 2);
end

% Open the nex file and get a file descriptor.
[fid, wasOpened] = nex.opennexfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() nex.closenexfile(fid));
end

% Pull out the continuous variable headers.  We'll use this to populate the
% meta data and do any filtering via indices or channel names.
varHeaders = nex.readvariableheaders(fid, 'VariableTypes', nex.NexVariableTypes.Continuous);

% Make a list of allowed indices that we'll use to validate input.
allowedIndices = 1:height(varHeaders);

% If no indices were specified, then we'll specify to extract all channels.
% If indices is a cell array of strings, then we'll find the index for each
% channel specified by name.
if isempty(indices)
    indices = allowedIndices;
elseif iscell(indices)
    error('Cell channel specification not implemented yet.');
end

% Check to make sure that all the specified indices are valid.
assert(all(ismember(indices, allowedIndices)), ...
    sprintf('%s:invalidIndices', mfilename), ...
    'Invalid channel indices specified, but be in the range [1,%d]', ...
    height(varHeaders));

%% Data Extraction

% Extract the variable data including meta data.
continuousData = nex.readvariabledata(fid, nex.NexVariableTypes.Continuous, ...
    'Indices', indices);

continuousTable = struct2table([continuousData{:}], 'AsArray', true);
