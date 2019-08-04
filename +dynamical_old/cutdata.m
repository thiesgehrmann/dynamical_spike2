function cutdata(input1, interval, duration, outputFileName, state, cellList)
% CUTDATA  Cuts the data every into chunks at the specified interval.
%
% Syntax:
% CUTDATA(nexFileName, interval, duration, outputFileName, state, cellList)
% CUTDATA(fileID, interval, duration, outputFileName, state, cellList)
%
% Description:
%
% Input:
% nexFileName (string) - The name of the NEX file from which to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Output:

%% Validate the Input
narginchk(1, Inf);

% Make sure that input1 is a filename (char) or a file ID (scalar).
validateattributes(input1, {'char', 'numeric'}, {'vector'}, 1);

% *** Need to add checking for the other inputs here. ***

%% Create the Phase File
% *** What does the phase file do? ***

% Open/prepare the NEX file for access.
fid = nex.opennexfile(input1);

% Get a list of the interval names.  The only interval name we want to
% ignore is 'AllFile' as it seems to be functionaly useless in all the Aton
% data files.
intervalNames = nex.listintervalnames(fid);
intervalNames = intervalNames(~strcmpi('AllFile', intervalNames));
nIntervals = length(intervalNames);

% Create an empty table to hold the phase table.  The phase table will be a
% concatenation of several interval tables, as returned by
% nex.getintervaltimes, with the addition of a PhaseType column containing
% the associated enumeration value.
phaseTable = table([], [], [], [], 'VariableNames', ...
    {'Start', 'End', 'Duration', 'PhaseType'});

% Get a list of the phase types we expect to find in the nex file.  Each
% phase type has an associated code value that we'll extract later to
% associate with a set of phase times.
phaseTypes = enumeration('dynamical.enums.PhaseType');
phaseTypesChar = arrayfun(@(x) {char(x)}, phaseTypes);

% Loop over all the interval names and pull out their times and associate
% those times with a phase type.
for iName = 1:nIntervals
    % PhaseType enumeration values are all uppercase.  To make string
    % comparing easier, make the current interval name uppercase.
    pType = upper(intervalNames{iName});
    
    % If the interval type does not exist in the list of know phase types,
    % don't pull out the interval times.
    if ~ismember(pType, phaseTypesChar)
        warning('dynamical:cutdata:invalidIntervalName', ...
        'Interval name (%s) not found in PhaseType enumeration.', pType);
        continue;
    end
    
    % Extract the interval times associated with the current interval type.
    intervalTable = nex.getintervaltimes(fid, pType);
    
    % Create a table column that has the interval type code (drawn from the
    % dynamical.PhaseType enumeration) duplicated across each row.
    codeColumn = repmat(dynamical.enums.PhaseType.(pType), height(intervalTable), 1);
    intervalTable = [intervalTable, table(codeColumn, 'VariableNames', {'PhaseType'})]; %#ok<AGROW>
    
    % Append the interval table to the master phase table.
    phaseTable = [phaseTable ; intervalTable]; %#ok<AGROW>
end

% Sort the rows of the phase table by the interval start time.
phaseTable = sortrows(phaseTable, 'Start');

%% Create/Update the Cell ID List

%% Create the Map

%% Cut the Data

%% Cleanup
% Close the file ID if we created it within this function.
if ischar(input1)
    fclose(fid);
end
