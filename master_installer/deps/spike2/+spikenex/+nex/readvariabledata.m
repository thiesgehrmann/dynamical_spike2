function variableData = readvariabledata(input1, variableType, varargin)
% READVARIABLE  Read variable data from a NEX file.
%
% Syntax:
% % Read all variable elements.
% variableData = readvariable(nexFileName, variableType)
% variableData = readvariable(fileID, variableType)
%
% % Read specified variable elements.
% variableData = readvariable(nexFileName, variableType, 'Indices', indices)
% variableData = readvariable(fileID, variableType, 'Indices', indices)
%
% Description:
% Reads the specified variable data from a NEX file.  By default, all
% variable elements of the specified type are read, but individual or
% groups of elements can be selected.  Indices for the different variable
% types can mean different things.  For instance, the indices for
% continuous variables will be analagous to the different channels, while
% the indices for marker variables will specify unique marker values.
%
% Input:
% nexFileName (string) - The name of the NEX file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
% variableType (nex.NexVariableTypes) - The variable type to read in.  This
%     must be a scalar value.
% indices (integer vector) - List of channels/elements to read in.  Each 
%     index must be in the range [1, number of variable elements].
%
% Output:
% variableData (cell vector) - Cell vector/array containing the variable
%     elements read.  The contents of each cell will vary depending on the
%     variable type.  If no data of the specified variable type is found,
%     this will be empty.

%% Setup
% Check our input and prepare the NEX file.

narginchk(2, Inf);

% Create the input parser we'll use to do some basic checks on our input.
p = inputParser;

% input1
addRequired(p, 'input1');

% 'variableType' - Must be a scalar value of type
% nex.NexVariableTypes.
validator = @(x) validateattributes(x, {'nex.NexVariableTypes'}, ...
    {'scalar', 'nonempty'});
addRequired(p, 'variableType', validator);

% 'indices' - Must be a vector.  We'll later check that all its values are
% within range of the variable type.  Right now we just want to make sure
% it's not something ridiculous.
validator = @(x) validateattributes(x, {'numeric'}, {'vector'});
addParameter(p, 'Indices', [], validator);

% Parse the input.
parse(p, input1, variableType, varargin{:});

% Open the NEX file.
[fid, wasOpened] = nex.opennexfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() nex.closenexfile(fid));
end
    
%% Read in the Data

% First we get a table of the variable headers.  We use the table to
% retrieve the file offsets into the data.
[variableHeaders, fileHeader] = nex.readvariableheaders(fid, ...
    'VariableTypes', p.Results.variableType);
nVariables = height(variableHeaders);

% If something was specified for the Indices argument, make sure that all
% indices are within the allowable range, which is [1,nVariables].
if isempty(p.Results.Indices)
    variableIndices = 1:nVariables;
else
    i = ismember(p.Results.Indices, 1:nVariables);
    assert(all(i), 'nex:readvariabledata:invalidIndices', ...
        'Invalid variable indices specified, all values must be in the range [%d,%d]', ...
        1, nVariables);
    variableIndices = p.Results.Indices;
end
nIndices = length(variableIndices);

% Initialize our return cell array.  If no variables of the specified
% variable type are found, 'variableData' will be empty.
variableData = cell(nIndices, 1);

% Loop over all variables the header table.
for iVar = 1:nIndices
    % This is the row of the table from which we'll extract the data given
    % this iteration's variable index.
    iRow = variableIndices(iVar);
    
    % Each variable type needs to be handled differently.
    switch p.Results.variableType
        case nex.NexVariableTypes.Continuous
            %% Read Continuous Variable            
            
            % Read out the variable meta data.
            variableData{iVar}.name = char(variableHeaders.name(iRow));
            variableData{iVar}.varVersion = variableHeaders.varVersion(iRow);
            variableData{iVar}.ADtoMV = variableHeaders.ADtoMV(iRow);
            if fileHeader.version > 104
                variableData{iVar}.MVOffset = variableHeaders.MVOffset(iRow);
            else
                variableData{iVar}.MVOffset = 0;
            end
            variableData{iVar}.ADFrequency = variableHeaders.WFrequency(iRow);
            
            % Jump to the file position containing the variable data.
            fseek(fid, variableHeaders.offset(iRow), 'bof');
            
            % Read in the data.
            variableData{iVar}.timestamps = fread(fid, ...
                [variableHeaders.count(iRow) 1], 'int32') ./ fileHeader.freq;
            variableData{iVar}.fragmentStarts = fread(fid, ...
                [variableHeaders.count(iRow) 1], 'int32') + 1;
            variableData{iVar}.data = fread(fid, ...
                [variableHeaders.NPointsWave(iRow) 1], 'int16') .* ...
                variableHeaders.ADtoMV(iRow) + variableData{iVar}.MVOffset;
            
        case nex.NexVariableTypes.Event
            %% Read Event Variable
            
            % Read the variable meta data.
            variableData{iVar}.name = char(variableHeaders.name(iRow));
            variableData{iVar}.varVersion = variableHeaders.varVersion(iRow);
            
            % Jump to the file position containing the variable data.
            fseek(fid, variableHeaders.offset(iRow), 'bof');
            
            % Read the event data.
            variableData{iVar}.timestamps = fread(fid, ...
                [variableHeaders.count(iRow) 1], 'int32') ./ fileHeader.freq;
            
        case nex.NexVariableTypes.Interval
            %% Read Interval Variable
            
            % Read the variable meta data.
            variableData{iVar}.name = char(variableHeaders.name(iRow));
            variableData{iVar}.varVersion = variableHeaders.varVersion(iRow);
            
            % Jump to the file position containing the variable data.
            fseek(fid, variableHeaders.offset(iRow), 'bof');
            
            % Read the interval data.
            variableData{iVar}.intStarts = fread(fid, ...
                [variableHeaders.count(iRow) 1], 'int32') ./ fileHeader.freq;
            variableData{iVar}.intEnds = fread(fid, ...
                [variableHeaders.count(iRow) 1], 'int32') ./ fileHeader.freq;
            
        case nex.NexVariableTypes.Marker
            %% Read Marker Variable
            
            % Read the variable meta data.
            variableData{iVar}.name = char(variableHeaders.name(iRow));
            variableData{iVar}.varVersion = variableHeaders.varVersion(iRow);
            
            % Jump to the file position containing the variable data.
            fseek(fid, variableHeaders.offset(iRow), 'bof');
            
            % Read the timestamp data.
            variableData{iVar}.timestamps = fread(fid, ...
                [variableHeaders.count(iRow) 1], 'int32') ./ fileHeader.freq;
          
            % Read the marker data.  This loop is copied pretty much
            % verbatim from Neuroexplorer's readNexFile.m.
            for markerFieldIndex = 1:variableHeaders.NMarkers(iRow)
                markerName = fread(fid, 64, '*char')';
                
                % Remove first zero and all characters after the first
                % zero.
                markerName(end+1) = 0; %#ok<AGROW>
                markerName = markerName(1:min(find(markerName==0))-1); %#ok<MXFND>
                variableData{iVar}.values{markerFieldIndex,1}.name = markerName;
                for markerValueIndex = 1:variableHeaders.count(iRow)
                    markerValue = fread(fid, variableHeaders.MarkerLength(iRow), '*char')';
                    
                    % Remove first zero and all characters after the first zero
                    markerValue(end+1) = 0; %#ok<AGROW>
                    markerValue = markerValue(1:min(find(markerValue==0))-1); %#ok<MXFND>
                    variableData{iVar}.values{markerFieldIndex,1}.strings{markerValueIndex, 1} = markerValue;
                end
            end
            
        case nex.NexVariableTypes.Neuron
            %% Read Neuron Variable
            
            % Read the variable meta data.
            variableData{iVar}.name = char(variableHeaders.name(iRow));
            variableData{iVar}.varVersion = variableHeaders.varVersion(iRow);
            if variableData{iVar}.varVersion > 100
                variableData{iVar}.wireNumber = variableHeaders.wireNumber(iRow);
                variableData{iVar}.unitNumber = variableHeaders.unitNumber(iRow);
            else
                variableData{iVar}.wireNumber = 0;
                variableData{iVar}.unitNumber = 0;
            end
            variableData{iVar}.xPos = variableHeaders.xPos(iRow);
            variableData{iVar}.yPos = variableHeaders.yPos(iRow);
            
            % Jump to the file position containing the variable data.
            fseek(fid, variableHeaders.offset(iRow), 'bof');
            
            % Read the timestamp data.
            variableData{iVar}.timestamps = fread(fid, ...
                [variableHeaders.count(iRow) 1], 'int32') ./ fileHeader.freq;
            
        case nex.NexVariableTypes.Population
            %% Read Population Variable
            
            % Read the variable meta data.
            variableData{iVar}.name = char(variableHeaders.name(iRow));
            variableData{iVar}.varVersion = variableHeaders.varVersion(iRow);
            
            % Jump to the file position containing the variable data.
            fseek(fid, variableHeaders.offset(iRow), 'bof');
            
            % Read the data.
            variableData{iVar}.weights = fread(fid, ...
                [variableHeaders.count(iRow) 1], 'double');
            
        case nex.NexVariableTypes.Waveform
            %% Read Waveform Variable
            
            % Read the variable meta data.
            variableData{iVar}.name = char(variableHeaders.name(iRow));
            variableData{iVar}.varVersion = variableHeaders.varVersion(iRow);
            variableData{iVar}.NPointsWave = variableHeaders.NPointsWave(iRow);
            variableData{iVar}.WFrequency = variableHeaders.WFrequency(iRow);
            if variableData{iVar}.varVersion > 100
                variableData{iVar}.wireNumber = variableHeaders.wireNumber(iRow);
                variableData{iVar}.unitNumber = variableHeaders.unitNumber(iRow);
            else
                variableData{iVar}.wireNumber = 0;
                variableData{iVar}.unitNumber = 0;
            end
            variableData{iVar}.ADtoMV = variableHeaders.ADtoMV(iRow);
            if fileHeader.version > 104
                variableData{iVar}.MVOffset = variableHeaders.MVOffset(iRow);
            else
                variableData{iVar}.MVOffset = 0;
            end
            
            % Jump to the file position containing the variable data.
            fseek(fid, variableHeaders.offset(iRow), 'bof');
            
            % Read the data.
            variableData{iVar}.timestamps = fread(fid, ...
                [variableHeaders.count(iRow) 1], 'int32') ./ fileHeader.freq;
            wf = fread(fid, [variableData{iVar}.NPointsWave ...
                variableHeaders.count(iRow)], 'int16');
            variableData{iVar}.waveforms = wf .* variableData{iVar}.ADtoMV + ...
                variableData{iVar}.MVOffset;
            
        otherwise
            % This should never be reached if the Input Validation section
            % is working.
            error('nex:readvariabledata:systemError', ...
                'Invalid variable type: %d', p.Results.variableType);
    end
    
    % Convert the variable name to a MATLAB string if we're using 2016b or
    % greater.
    if ~verLessThan('matlab', '9.1') && isfield(variableData{iVar}, 'name')
        variableData{iVar}.name = string(variableData{iVar}.name);
    end
end
