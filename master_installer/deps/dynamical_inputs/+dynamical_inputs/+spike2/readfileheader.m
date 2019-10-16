function fileHeader = readfileheader(input1)
% READFILEHEADER  Reads the file header information from a SPIKE2 file.
%
% Syntax:
% fileHeader = READFILEHEADER(spike2FileName)
% fileHeader = READFILEHEADER(fileID);
%
% Description:
% Extracts the top level header file information from a SPIKE2 file.
%
% Input:
% spike2FileName (string) - The name of the SPIKE2 file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened SPIKE2 file via fopen.
%
% Output:
% fileHeader (struct) - The header information from the SPIKE2 file.
%     Fields:
%     version (scalar) - SPIKE2 file version
%     comment (string) - File comment
%     freq (scalar) - Timestamp frequency (Hz)
%     tbeg (scalar) - Minimum timestamp (s)
%     tend (scalar) - Maximum timestamp (s)
%     numvars (scalar) - The number of variables in the file.
%
% Throws:
% SPIKE2:getfileheader:InvalidSPIKE2File - File specified is not a SPIKE2 file.
%
% Examples:
% % Read header data by specifiying the file name.
% fileHeader = getfileheader('myfilename.SMRX');
%
% % Read header data by specifying a file ID.
% fid = openfile('myfilename.SMRX');
% fileHeader = getfileheader(fid);

%% Setup
% Check our input and prepare the SPIKE2 file.

narginchk(1, 1);

% Open the SPIKE2 file.
[fh, wasOpened] = dynamical_inputs.spike2.openfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() spikenex.spike2.closefile(fh));
end

%% Extract Header Data
% Extract the header data from the SPIKE2 file and store it in a struct.


% File Version
fileHeader.version = CEDS64Version(fh);

% File Comment - Remove first zero and all characters after the first zero.
comment = {};
for i=1:8
	[iok, com ] = CEDS64FileComment(fh, i);
	comment{i} = com;
end
fileHeader.comment = comment;

% Timestamps frequency (Hz) - Timestamp values are stored in ticks,
% where tick = 1/frequency.
fileHeader.freq = CEDS64SecsToTicks(fh, 1);

% Min/Max Timestamp in SECONDS
fileHeader.tbeg = CEDS64TicksToSecs(fh, 0);
fileHeader.tend = CEDS64TicksToSecs(fh, CEDS64ChanMaxTime(fh, 34));

% Number of variables in the file, e.g. continuous, event, markers.
fileHeader.numvars = 0;
fileHeader.numchannels = length(spikenex.spike2.listchannels(fh));

