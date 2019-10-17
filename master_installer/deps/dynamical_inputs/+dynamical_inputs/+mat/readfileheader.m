function fileHeader = readfileheader(input1)
% READFILEHEADER  Reads the file header information from a MAT file.
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

% Open the MAT file.
[S, wasOpened] = dynamical_inputs.mat.openfile(input1);

%% Extract Header Data
% Extract the header data from the SPIKE2 file and store it in a struct.


% File Version
fileHeader.version = 0;

% File Comment - Remove first zero and all characters after the first zero.
comment = {};


% Timestamps frequency (Hz) - Timestamp values are stored in ticks,
% where tick = 1/frequency.
fileHeader.freq = 100; % UNKNOWN in MAT files

% Min/Max Timestamp in SECONDS
fileHeader.tbeg = min(cellfun(@min, S.neurondata.timestamps)) / fileHeader.freq ;
fileHeader.tend = max(cellfun(@max, S.neurondata.timestamps)) / fileHeader.freq ;

% Number of variables in the file, e.g. continuous, event, markers.
fileHeader.numvars = 0;
fileHeader.numchannels = length(dynamical_inputs.mat.listchannels(S));

