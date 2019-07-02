function cdf_batch(folderName)
% CDF_BATCH  Processes a folder of AMD analysis files and caculates the ECDF for each file.
%
% Syntax:
% CDF_BATCH
% CDF_BATCH(folderName)
%
% Input:
% folderName (string) - Name of the folder to process.  If left blank, a
%     folder selection UI is presented.

% Stores the last process directory and is used as the starting location
% for the uigetdir function below if a folder isn't specified as a function
% argument.
persistent lastDir

narginchk(0, 1);

% Until I have a delete sheet bit of code for Mac and Linux, this function
% will remain PC specific.
assert(ispc, 'This function is PC only (no Linux or Mac).');

% Make sure that some prerequisites exist before we run anything.
dynamical.util.assertprereqs;

% Windows has built-in Excel writing functionality, while Mac and Linux do
% not.  For Mac and Linux machines, we use an open source library called
% 'xlwrite' from the MATLAB community.  The syntax of the two functions (as
% we use them) are the same.
if ispc
    excelFcn = 'xlswrite';
    addSheetWarningID = 'MATLAB:xlswrite:AddSheet';
else
    excelFcn = 'xlwrite';
    addSheetWarningID = 'xlwrite:AddSheet';
end

% When the function ends or if there is an error, reset the warning setting
% for adding an Excel sheet to what it was prior to calling this function.
warningSetting = warning('query', addSheetWarningID);
warning('off', addSheetWarningID);
cleanupObj = onCleanup(@() warning(warningSetting.state, addSheetWarningID));

% Read the global config data.
config = dynamical.config.readconfig(false);

% Go ahead and write the config file now in the event one doesn't exist in
% the user's local config directory.
dynamical.config.writeconfig(config);

% If the last directory used isn't available, we'll use the current working
% directory as the start directory for the uigetdir function.
if isempty(lastDir)
    lastDir = pwd;
end

if nargin == 0
    folderName = [];
end

% If no folder is specified, we'll prompt the user for one.
if isempty(folderName)
    folderName = uigetdir(lastDir, 'Select NEX Directory');
    
    if isequal(folderName, 0)
        error('No directory selected');
    else
        lastDir = folderName;
    end
end

% Get a list of the .mat files found in the selected folder.  On Windows
% this should work fine, but Mac and Linux have may have an issue due to
% case sensitivity (needs to be tested).
matFileList = dir(fullfile(folderName, '*.mat'));
nFiles = length(matFileList);
assert(nFiles > 0, 'cdf_batch:inputError', ...
    'No .mat files found in the directory: %s', folderName);

% Loop over all the .mat files we found in the directory and run the amdcdf
% function on the data.  Store the raw per file aggregate AMD data, which
% we'll later turn into one big array so we can run an ECDF on the
% cumulative data.
rawData = cell(1, nFiles);
for i = 1:nFiles
    dynamical.dprintf(1, '** File %d/%d\n', i, nFiles);
    
    % Construct the .mat filename we want to load.
    matFileName = fullfile(matFileList(i).folder, matFileList(i).name);
    dynamical.dprintf(1, '%% Processing MAT file: %s\n', matFileName);
    
    % Now construct the associated Excel filename.
    [p, n] = fileparts(matFileName);
    xlsFilename = fullfile(p, [n '.xlsx']);
    dynamical.dprintf(1, '%% Writing to Excel file: %s\n', xlsFilename);
    
    % Run the ECDF on the AMD data in the .mat file.
    [~, ~, rawData{i}] = dynamical.math.amdcdf(matFileName, xlsFilename, false);
end

% Create one big array out of the collected raw flattened data.
nDataSets = length(rawData{1});
bigData = cell(1, nDataSets);
rawData = [rawData{:}];
nDataCells = length(rawData);
for i = 1:nDataSets
    bigData{i} = cell2mat(rawData(i:nDataSets:nDataCells));
end

% Run the ECDF on the big data set.  Give it a unique name with a timestamp
% so that we can run this multiple times without overwriting prior results.
dateSuffix = datestr(now, '.mm-dd-yyyy.HH-MM-SS');
cumulativeFilename = fullfile(folderName, sprintf('CDF%s.xlsx', dateSuffix));
assert(~exist(cumulativeFilename, 'file'), 'Duplicate file found: %s', cumulativeFilename);
targetSheet = 'CDF';
dynamical.dprintf(1, '%% Writing Cumulative CDF file: %s\n', cumulativeFilename);
feval(excelFcn, cumulativeFilename, {'AMD_X' 'AMD_Y' 'ZScore_X' 'ZScore_Y'}, targetSheet, 'A1:D1');

for i = 1:nDataSets
    [F, X] = ecdf(bigData{i});
    
    rowEnd = length(F) + 1;
    cols = ExcelCol((1:2) + (i-1)*2);
    
    feval(excelFcn, cumulativeFilename, [X F], targetSheet, ...
        sprintf('%s2:%s%d', cols{1}, cols{2}, rowEnd));
end

xls_delete_sheets(cumulativeFilename, 'Sheet1');

dynamical.dprintf(1, '*** DONE ***\n');
