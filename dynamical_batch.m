function dynamical_batch(folderName, varargin)
% DYNAMICAL_BATCH  Batch version of the Dynamical CLI.
%
% Syntax:
% DYNAMICAL_BATCH(folderName)
% DYNAMICAL_BATCH(folderName, options)
%
% Description:
% Batch variant of Dynamical.  Allows the user to specify a set of analysis
% options (the same as in the CLI) and apply that to an entire folder of
% .nex files.  Output is the same as the CLI.
%
% Example:
% % Have the program prompt for a directory and process the first hour of
% % data.
% DYNAMICAL_BATCH([], 'EndTime', 3600);
%
% % Prompt for a folder and only process WAKE intervals.
% DYNAMICAL_BATCH([], 'Intervals', {'WAKE'});
%
% % Specify a folder and process only WAKE with a minimum persistence of 50%.
% DYNAMICAL_BATCH('C:\path\to\nex\folder', 'Intervals, {'WAKE'}, 'MinPersistence', 0.5);

narginchk(0, Inf);

% Stores the last process directory and is used as the starting location
% for the uigetdir function below if a folder isn't specified as a function
% argument.
persistent lastDir

% % Get current state of the diary.  We will modify the diary in this
% % function and want to set it back when we're done.
% diaryState = get(0, 'Diary');
% diaryFile = get(0, 'DiaryFile');
% 
% cleanupObj = onCleanup(@() cleanup(diaryState, diaryFile));

% % Make sure our prefs directory is setup.  We'll store the diary logs in
% % here.
% prefsDir = dynamical.config.initprefsdir;

% % Create the log directory if neeeded.
% logDir = fullfile(prefsDir, 'logs');
% if ~exist(logDir, 'dir')
%     mkdirStatus = mkdir(logDir);
%     assert(mkdirStatus == 1, 'mkdir failed with error: %d', mkdirStatus);
% end
% 
% % Setup the diary to save a log of this run.
% dateSuffix = datestr(now, '.mm-dd-yyyy.HH-MM-SS');
% logFilename = fullfile(logDir, ['batch' dateSuffix '.log']);
% diary('on');
% diary(logFilename);

% Make sure that some prerequisites exist before we run anything.
dynamical.util.assertprereqs;

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

% Get a list of the .nex files found in the selected folder.  On Windows
% this should work fine, but Mac and Linux have may have an issue due to
% case sensitivity (needs to be tested).
nexFileList = dir(fullfile(folderName, '*.nex'));
nFiles = length(nexFileList);
assert(nFiles > 0, 'dynamical_batch:inputError', ...
    'No .nex files found in the directory: %s', folderName);

batchLog = dynamical.BatchErrorLog();

% Loop over all files and process them.
for i = 1:nFiles
    fileName = fullfile(nexFileList(i).folder, nexFileList(i).name);
    dynamical.dprintf(1, '%% Processing file: %s\n', fileName);
    
    try
        dynamical_cli(fileName, varargin{:});
    catch err
        batchLog.log(fileName, err);
    end
end

if batchLog.loggedErrors
    % warn user errors were encountered
    summary = batchLog.summarize();
    warning(summary);
    
    % write log to disk
    batchLog.save(folderName);
end

% function cleanup(diaryState, diaryFile)
% diary('off');
% %diary(diaryFile);
% %diary(diaryState);
