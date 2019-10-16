function intervalTable = getintervaltimes(input1, varargin)
% GETINTERVALTIMES  Gets interval data from a NEX file.
%
% Syntax:
% intervalTable = GETINTERVALTIMES(nexFileName, intervalName)
% ___ = GETINTERVALTIMES(fileID, intervalName)
% ___ = GETINTERVALTIMES(___, isCaseSensitive)
%
% Description:
% Read the interval table (start/stop times) from a nex file for a
% specified interval.
%
% Input:
% nexFileName (string) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
% intervalName (string) - The name of the interval to extract.
% isCaseSensitive (logical) - If true, we do a case sensitive search for
%     the interval name.  Default: false
%
% Output:
% intervalTable (table) - A table of the start and end times for all
%     intervals matching the interval type.  As a convenience, the duration
%     of each interval (row) is added as a 3rd column to the table.
%
% Examples:
% % Get REM interval times (case insensitive).
% intervalTable = GETINTERVALTIMES('C:\datafile.nex', 'REM')
%
% % Get REM interval times (case sensitive).
% intervalTable = GETINTERVALTIMES('C:\datafile.nex', 'Rem', true);

%% Setup
% Check our input and prepare the NEX file.

switch dynamical_inputs.determine_input_type(input1)
    case 'NEX'
        intervalTable = dynamical_inputs.nex.getintervaltimes(input1, varargin{:});
    case 'SPIKE'
        intervalTable = dynamical_inputs.spike2.getintervaltimes(input1, varargin{:});
    case 'MAT'
        intervalTable = dynamical_inputs.mat.getintervaltimes(input1, varargin{:});
    otherwise
        assert(false, 'dynamical_inputs:getintervaltimes:InvalidFileType', "You must specify a NEX, SPIKE2 or MAT file as input.")
end
