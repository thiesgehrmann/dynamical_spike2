function dynamical_cli(input1, varargin)
% DYNAMICAL_CLI  Command line version of Dynamical.
%
% Syntax:
% DYNAMICAL_CLI(nexFileName)
% DYNAMICAL_CLI(nexFileName, options)
% DYNAMICAL_CLI(fileID)
% DYNAMICAL_CLI(fileID, options)
%
% Description:
% Command line interface (CLI) for Dynamical.  Has all the processing
% options as the GUI, though not graphs are generated.  The same data files
% are saved.
%
% Input:
% nexFileName (string) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Options (key,value):
% 'StartTime' (scalar) - Start time of the analysis. (s)  Default: 0
% 'EndTime' (scalar) - End time of the analysis.  Set to Inf if you
%     want to analyze to the end of the file. (s)  Default: Inf
% 'WindowSize' (scalar) - The size of a single analysis window. (s)
%     Default: 60
% 'WindowStep' (scalar) - The amount to increment the analysis from the
%     start of one time window to the next. (s) Default: 60
% 'Intervals' (string array) - List of intervals to analyze.  If this
%     is specified, then the analysis only looks at spikes found within
%     these intervals.  Leave empty to analyze all spikes found in the
%     time windows.  Default: []
% 'MinSpikeCount' (scalar) - Minimum number of spikes required for a
%     neuron to be considered for analysis in a given time window.
%     Default: 6
% 'MinPersistence' (scalar) - Percentage [0,1] of time windows that a
%     neuron with a spike count >= than 'MinSpikeCount' must persist across
%     all windows meeting the minimum spike count to be considered valid.
% 'MinValidNeurons' (scalar) - Minimum number of valid neurons in a
%     time window for it to be considered for analysis.  Default: 3

%% Imports
import dynamical.util.validateattributes

%% Input Parsing

narginchk(1, Inf);

ip = inputParser;

defaults.minSpikeCount = 6;
defaults.minPersistence = 0;
defaults.minValidNeurons = 3;
defaults.outputFormat = 'array';
defaults.parallel = true;
methodList = {'neighbor' 'all'};
defaults.Method = methodList{1};

% Filename/FileID
validator = @(x) validateattributes(x, {'char' 'string' 'numeric'}, ...
    {'vector', 'nonempty'}, mfilename, 'nexFileName/fileID', 1);
addRequired(ip, 'input1', validator);

% Start Time
validator = @(x) validateattributes(x, {'numeric'}, {'scalar' 'nonempty'});
addParameter(ip, 'StartTime', 0, validator);

% End Time
validator = @(x) validateattributes(x, {'numeric'}, {'scalar' 'nonempty'});
addParameter(ip, 'EndTime', Inf, validator);

% Window Size
validator = @(x) validateattributes(x, {'numeric'}, {'scalar' 'nonempty'});
addParameter(ip, 'WindowSize', 60, validator);

% Window Step
validator = @(x) validateattributes(x, {'numeric'}, {'scalar' 'nonempty'});
addParameter(ip, 'WindowStep', 60, validator);

% Intervals
validator = @(x) validateattributes(x, {'string' 'numeric' 'cell'}, {'2d'});
addParameter(ip, 'Intervals', [], validator);

% Minimum number of spikes required to do the analysis for a given neuron.
validator = @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty' 'scalar' '>=' 2});
addParameter(ip, 'MinSpikeCount', defaults.minSpikeCount, validator);

% Minimum percentage of AMD windows that a neuron must persist across for
% it to be considered valid.
validator = @(x) validateattributes(x, {'numeric'}, ...
    {'scalar' 'nonempty' '>=' 0 '<=' 1});
addParameter(ip, 'MinPersistence', defaults.minPersistence, validator);

% Minimum number of valid neurons required for the analysis to run.
validator = @(x) validateattributes(x, {'numeric'}, ...
    {'scalar' 'nonempty' '>=' 2});
addParameter(ip, 'MinValidNeurons', defaults.minValidNeurons, validator);

% Parallel processing toggle
validator = @(x) validateattributes(x, {'logical'}, {'scalar' 'nonempty'});
addParameter(ip, 'Parallel', defaults.parallel, validator);

% Stability Method
validator = @(x) validateattributes(x, {'string' 'char'}, ...
    {'nonempty' 'scalartext'});
addParameter(ip, 'Method', defaults.Method, validator);

parse(ip, input1, varargin{:});

%% Setup

% Make sure that some prerequisites exist before we run anything.
dynamical.util.assertprereqs;

% Read the global config data.
config = dynamical.config.readconfig(false);

% Go ahead and write the config file now in the event one doesn't exist in
% the user's local config directory.
dynamical.config.writeconfig(config);

% Spin up the parallel pool if needed.
if ip.Results.Parallel
    dynamical.dprintf(1, '%% Starting up parallel pool...\n');
    
    % Set the parallel pool's timeout to 8 hours.  This prevents the
    % parallel pool from timeing out in a typical workday and introducing
    % huge delays when running the analysis.
    parallelObj = gcp;
    parallelObj.IdleTimeout = 60*8;
    
    dynamical.dprintf(1, '%% Parallel pool ready!\n');
end

%% AMD

dynamical.dprintf(1, '%% AMD - Processing Data...\n');
t0 = tic;
amdWindows = dynamical.math.amd(input1, 'StartTime', ip.Results.StartTime, ...
                           'EndTime', ip.Results.EndTime, ...
                           'WindowSize', ip.Results.WindowSize, ...
                           'WindowStep', ip.Results.WindowStep, ...
                           'Intervals', ip.Results.Intervals, ...
                           'MinSpikeCount', ip.Results.MinSpikeCount, ...
                           'MinPersistence', ip.Results.MinPersistence, ...
                           'MinValidNeurons', ip.Results.MinValidNeurons, ...
                           'Parallel', ip.Results.Parallel, ...
                           'ShowWaitbar', false);
t = toc(t0);
dynamical.dprintf(1, '%% AMD - Processing Finished: %g (s)\n', t);

%% Stability

dynamical.dprintf(1, '%% Stability - Processing Data...\n');

t0 = tic;
[S, T] = dynamical.math.stability(amdWindows, 'Method', ip.Results.Method, ...
    'ShowWaitBar', false, 'Parallel', ip.Results.Parallel);
t = toc(t0);
dynamical.dprintf(1, '%% Stability - Processing Finished: %g (s)\n', t);
stability.data = S;
stability.times = T;

%% Save Data

% Create a struct for use with saving data.  This lets us automate some
% aspects of preparing the data.
amdParams = {'StartTime', ip.Results.StartTime, ...
             'EndTime', ip.Results.EndTime, ...
             'WindowSize', ip.Results.WindowSize, ...
             'WindowStep', ip.Results.WindowStep, ...
             'Intervals', ip.Results.Intervals, ...
             'MinSpikeCount', ip.Results.MinSpikeCount, ...
             'MinPersistence', ip.Results.MinPersistence, ...
             'MinValidNeurons', ip.Results.MinValidNeurons, ...
             'Parallel', ip.Results.Parallel, ...
             'OutputFormat', 'array', ...
             'ShowWaitbar', false};
         
% Convert the params structure into a struct.  I'm doing this a weird way
% to get around an issue using the struct function.
f = amdParams(1:2:end);
v = amdParams(2:2:end);
amdStruct = amdParams;
amdStruct(2:2:end) = {0};
amdStruct = struct(amdStruct{:});
for i = 1:length(f)
    amdStruct.(f{i}) = v{i};
end

% Append this to the filenames so that we have a unique .mat and .xls file
% for every analysis.
dateSuffix = datestr(now, '.mm-dd-yyyy.HH-MM-SS');

% Save the analysis to a .mat file.  Do this before we bother with Excel
% as Excel can be finicky and worst case scenario we can "resave" the data
% if we still have the raw .mat data.
amdStruct2 = amdStruct;
amdStruct2.ShowWaitbar = false;
[p, f] = fileparts(input1);
matFileName = fullfile(p, [f dateSuffix '.mat']);
metaData = struct('date', datestr(now), 'params', amdStruct2);
save(matFileName, 'metaData', 'amdWindows', 'stability');

% Excel output only implemented for the 'neighbor' stability method right
% now.
switch lower(ip.Results.Method)
    case {'neighbor', 'all'}
        % Export the data to an Excel file.
        dynamical.util.save2excel(input1, stability, amdStruct, false, ...
            ip.Results.Method, dateSuffix);
        
    otherwise
        warning('Excel export for method "%s" not implemented yet', ...
            ip.Results.Method);
end
