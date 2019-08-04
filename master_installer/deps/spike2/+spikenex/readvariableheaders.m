function [variableHeaders, fileHeader] = readvariableheaders(input1, varargin)
% READVARIABLEHEADERS  Reads the variable header information from a NEX file.
%
% Syntax:
% [variableHeaders, fileHeader] = READVARIABLEHEADERS(nexFileName, options);
% [variableHeaders, fileHeader] = READVARIABLEHEADERS(fileID, options);
%
% Description:
% Extracts the header information for each variable contained in a NEX
% file.
%
% Input:
% nexFileName (string) - The name of the NEX file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Options:
% 'VariableTypes' (nex.NexVariableTypes vector) - List of variable types to
%     return.  Allows the user to filter out undesired variable types from
%     the returned table.
%
%     Examplew:
%     % List only continuous variables headers.
%     h = nex.readvariableheaders(fileName, 'VariableTypes', nex.NexVariableTypes.Continuous);
%
%     % List only continuous and marker headers.
%     h = nex.readvariableheaders(fileName, 'VariableTypes', [nex.NexVariableTypes.Continuous, nex.NexVariableTypes.Marker]);
%
% Output:
% variableHeaders (table) - Raw list of variable headers in table form.
%     Each row of the table is a unique variable.
%     Columns:
%         type
%         varVersion
%         name
%         offset
%         count
%         wireNumber
%         unitNumber
%         gain
%         filter
%         xPos
%         yPos
%         WFrequency
%         ADtoMV
%         NPointsWave
%         NMarkers
%         MarkerLength
%         MVOffset
%         PrethresholdTimeInSeconds
% fileHeader (struct) - The header information from the NEX file.
%     Fields:
%         version (scalar) - NEX file version
%         comment (string) - File comment
%         freq (scalar) - Timestamp frequency (Hz)
%         tbeg (scalar) - Minimum timestamp (ticks), 1 tick = 1/freq
%         tend (scalar) - Maximum timestamp + 1 (ticks)
%         numvars (scalar) - The number of variables in the file.

%% Setup
% Check our input and prepare the NEX file.

narginchk(1, Inf);

p = inputParser;

% Make sure a string or numeric value(s) was specified.
addRequired(p, 'input1');

% If variable types are specified, make sure they are a simple array of 
% nex.NexVariableTypes.
validator = @(x) validateattributes(x, {'nex.NexVariableTypes'}, ...
    {'vector', 'nonempty'});
addParameter(p, 'VariableTypes', enumeration('nex.NexVariableTypes'), ...
     validator);
 
% Parse the input.
parse(p, input1, varargin{:});

% Open the NEX file.
[fid, wasOpened] = nex.opennexfile(p.Results.input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() nex.closenexfile(fid));
end

%% Extract Header Data

% Read the file header information so we can see how many variables there
% are.
fileHeader = nex.readfileheader(fid);

% Move the file descriptor to just past the file header and padding.
fseek(fid, 544, 'bof');

% Pre-allocate the memory to hold the variable header data.
variableHeaders = repmat(struct('type', -1, ...
       'varVersion', -1, ...
       'name', '', ...
       'offset', -1, ...
       'count', -1, ...
       'wireNumber', -1, ...
       'unitNumber', -1, ...
       'gain', -1, ...
       'filter', -1, ...
       'xPos', -1, ...
       'yPos', -1, ...
       'WFrequency', -1, ...
       'ADtoMV', -1, ...
       'NPointsWave', -1, ...
       'NMarkers', -1, ...
       'MarkerLength', -1, ...
       'MVOffset', -1, ...
       'PrethresholdTimeInSeconds', -1), fileHeader.numvars, 1);
  
% Get a list of variable types we expect.  We'll use this enumeration to
% convert the raw variable type (just an integer) to something more
% readable.
variableTypes = enumeration('nex.NexVariableTypes');

% Loop over all variables and read their metadata.
for iVar = 1:fileHeader.numvars
    % Variable Type
    type = fread(fid, 1, 'int32');
    variableHeaders(iVar).type = variableTypes(variableTypes == type);
    assert(length(variableHeaders(iVar).type) == 1, ...
        'nex:getvariableheaders:VarTypeError', ...
        'Integer to variable type enumeration conversion error.');
    
    % Variable Version
    variableHeaders(iVar).varVersion = fread(fid, 1, 'int32');
    
    % Variable Name - Remove first zero and all characters after the first
    % zero.
    name = fread(fid, 64, '*char')';
    name(end+1) = 0; %#ok<AGROW>
    n = name(1:min(find(name==0, 1, 'first'))-1);
    if ~verLessThan('matlab', '9.1')
        n = string(n);
    end
    variableHeaders(iVar).name = n;
    
    % The location of the variable data in the file.  Use with fseek to go
    % to the data location.
    variableHeaders(iVar).offset = fread(fid, 1, 'int32');
    
    % Variable Count - neuron variable: number of timestamps
    %                  event variable: number of timestamps
    %                  interval variable: number of intervals
    %                  waveform variable: number of waveforms
    %                  continuous variable: number of fragments
    %                  population vector: number of weights
    variableHeaders(iVar).count = fread(fid, 1, 'int32');
    
    % Wire Number - Neurons and waveforms only; for data from PLX files,
    %               channel number from the record header.
    variableHeaders(iVar).wireNumber = fread(fid, 1, 'int32');
    
    % Unit Number - Neurons and waveforms only; for data from PLX files,
    %               unit number from the record header.
    variableHeaders(iVar).unitNumber = fread(fid, 1, 'int32');
    
    % Gain - Neurons only
    variableHeaders(iVar).gain = fread(fid, 1, 'int32');
    
    % Filter - Neurons only
    variableHeaders(iVar).filter = fread(fid, 1, 'int32');
    
    % X Position - Neurons only, X axis electrode position in (0,100)
    %              range, used in 3D display.
    variableHeaders(iVar).xPos = fread(fid, 1, 'double');
    
    % Y Position - Neurons only, Y axis electrode position in (0,100)
    %              range, used in 3D display.
    variableHeaders(iVar).yPos = fread(fid, 1, 'double');
    
    % Waveforms and continuous variables only, w/f or cont. sampling
    % frequency in Hz.
    variableHeaders(iVar).WFrequency = fread(fid, 1, 'double');
    
    % Waveforms and continuous variables only, coeff. to convert from A/D
    % values to Millivolts.
    variableHeaders(iVar).ADtoMV  = fread(fid, 1, 'double');
    
    % Waveform variable: number of points in each wave continuous variable:
    % number of data points.
    variableHeaders(iVar).NPointsWave = fread(fid, 1, 'int32');
    
    % Marker events only, how many values are associated with each marker.
    variableHeaders(iVar).NMarkers = fread(fid, 1, 'int32');
    
    % Marker events only, how many characters are in each marker value.
    variableHeaders(iVar).MarkerLength = fread(fid, 1, 'int32');
    
    % Waveforms and continuous variables only, this offset is used to
    % convert A/D values in Millivolts:
    % mv = raw * ADtoMV + MVOffset
    variableHeaders(iVar).MVOffset = fread(fid, 1, 'double');
    
    % Waveforms: pre-threshold time in seconds if waveform timestamp in
    % seconds is t, then the timestamp of the first point of waveform is
    % t - PrethresholdTimeInSeconds
    variableHeaders(iVar).PrethresholdTimeInSeconds = fread(fid, 1, 'double');
    
    % Read the padding bytes that are currently unused.
    fread(fid, 52, 'char');
end

% Convert the header struct into a table.
variableHeaders = struct2table(variableHeaders);

% Filter out unwanted variable types.
i = ismember(variableHeaders.type, p.Results.VariableTypes);
variableHeaders = variableHeaders(i,:);
