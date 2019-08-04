function intervalTable = getintervaltimes(input1, intervalName, isCaseSensitive)
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

narginchk(2, 3);

% SPIKE2 doesn't have intervals, so I put here a dummy one.

% Open the SPIKE2 file.
[fh, wasOpened] = openfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() closefile(fh));
end

interval.Start    = 0
interval.End      = CEDS64TicksToSecs(fh, CEDS64MaxTime(fh))
interval.Duration = interval.End

intervalTable = struct2table(interval)