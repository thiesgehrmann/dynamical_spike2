function fileHeader = readfileheader(input1)
% READFILEHEADER  Reads the file header information from a NEX file.
%
% Syntax:
% fileHeader = READFILEHEADER(nexFileName)
% fileHeader = READFILEHEADER(fileID);
%
% Description:
% Extracts the top level header file information from a NEX file.
%
% Input:
% nexFileName (string) - The name of the NEX file from which to
%     extract the header.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Output:
% fileHeader (struct) - The header information from the NEX file.
%     Fields:
%     version (scalar) - NEX file version
%     comment (string) - File comment
%     freq (scalar) - Timestamp frequency (Hz)
%     tbeg (scalar) - Minimum timestamp (s)
%     tend (scalar) - Maximum timestamp (s)
%     numvars (scalar) - The number of variables in the file.
%
% Throws:
% nex:getfileheader:InvalidNEXFile - File specified is not a NEX file.
%
% Examples:
% % Read header data by specifiying the file name.
% fileHeader = getfileheader('myfilename.nex');
%
% % Read header data by specifying a file ID.
% fid = fopen('myfilename.nex', 'r', 'l', 'US-ASCII');
% fileHeader = getfileheader('myfilename.nex');

%% Setup
% Check our input and prepare the NEX file.

narginchk(1, 1);

% Open the NEX file.
[fid, wasOpened] = nex.opennexfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    cleanupObj = onCleanup(@() nex.closenexfile(fid));
end

%% Extract Header Data
% Extract the header data from the NEX file and store it in a struct.

% Read in the magic number.  This value indicates if we have a valid NEX
% file.
magic = fread(fid, 1, 'int32');
assert(magic == 827868494, 'nex:getfileheader:InvalidNEXFile', ...
    'Not a valid .NEX file.');

% File Version
% The rules for the version number are as follows (according to the company)
% 
% When reading existing .nex files, use the following rules:
% Versions 102 and 103: beta versions; should not be used
% Versions 100, 101 and 104: use standard .nex data read algorithm as described,
% except that NexVarHeader::MVOffset and NexVarHeader::PrethresholdTimeInSeconds are not used and are always zero
% Version 105: indicates that NexVarHeader::MVOffset can be non-zero
% Version 106: indicates that NexVarHeader::PrethresholdTimeInSeconds can be non-zero
fileHeader.version = fread(fid, 1, 'int32');

% File Comment - Remove first zero and all characters after the first zero.
comment = fread(fid, 256, '*char')';
comment(end+1) = 0;
fileHeader.comment = comment(1:min(find(comment == 0, 1, 'first'))-1);

if ~verLessThan('matlab', '9.1')
    fileHeader.comment = string(fileHeader.comment);
end

% Timestamps frequency (Hz) - Timestamp values are stored in ticks,
% where tick = 1/frequency.
fileHeader.freq = fread(fid, 1, 'double');

% Min/Max Timestamp
fileHeader.tbeg = fread(fid, 1, 'int32') ./ fileHeader.freq;
fileHeader.tend = fread(fid, 1, 'int32') ./ fileHeader.freq;

% Number of variables in the file, e.g. continuous, event, markers.
fileHeader.numvars = fread(fid, 1, 'int32');
