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


if spikenex.isnex(input1)
    [variableHeaders, fileHeader] = spikenex.nex.readvariableheaders(input1, varargin{:});
else
    variableHeaders = 0;
    fileHeader = 0;
end