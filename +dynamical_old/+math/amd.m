function amdWindows = amd(input1, varargin)
% AMD  Calculates the AMD, Zscores, and basic stats for a set of time windows.
%
% Syntax:
% amdWindows = AMD(fileName)
% ___ = AMD(fileID)
% ___ = AMD(___, options)
%
% Description:
%
% Input:
% nexFileName (string) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Options (key,value):
% 'EndTime' (scalar) - End time of the analysis.  Set to Inf if you
%     want to analyze to the end of the file. (s)  Default: Inf
% 'Intervals' (string array) - List of intervals to analyze.  If this
%     is specified, then the analysis only looks at spikes found within
%     these intervals.  Leave empty to analyze all spikes found in the
%     time windows.  Default: []
% 'MinPersistence' (scalar) - Percentage [0,1] of time windows that a
%     neuron with a spike count >= than 'MinSpikeCount' must 
% 'MinSpikeCount' (scalar) - Minimum number of spikes required for a
%     neuron to be considered for analysis in a given time window.
%     Default: 6
% 'MinValidNeurons' (scalar) - Minimum number of valid neurons in a
%     time window for it to be considered for analysis.  Default: 3
% 'Parallel' (logical) - If true, then MATLAB's parallel toolbox will be
%     used to process the data.  Default: true
% 'StartTime' (scalar) - Start time of the analysis. (s)  Default: 0
% 'WindowSize' (scalar) - The size of a single analysis window. (s)
%     Default: 60
% 'WindowStep' (scalar) - The amount to increment the analysis from the
%     start of one time window to the next. (s) Default: 60
%
% Output:
% amdWindows (dynamical.math.AMDWindow array) - The results for each
%     window of data.
%
% Examples:
% % Process a file and pass some options.
% amdWindows = AMD('C:\datafile.nex', 'MinPersistence', 0.2, 'EndTime', 360);
%
% See Also: dynamical.math.AMDWindow

%% Imports
import dynamical.enums.ParserAttribute
import dynamical.util.validateattributes

%% Input Parsing

narginchk(1, Inf);

p = inputParser;

% Defaults for all parser parameters.
defaults.minSpikeCount = 6;
defaults.minPersistence = 0;
defaults.minValidNeurons = 3;
defaults.outputFormat = 'array';
defaults.parallel = true;
defaults.showWaitbar = false;
defaults.windowSize = 60;
defaults.windowStep = 60;
defaults.startTime = 0;
defaults.endTime = Inf;
defaults.intervals = [];

% Filename/FileID
validator = @(x) validateattributes(x, {'char' 'string' 'numeric'}, ...
    {'vector', 'nonempty'}, mfilename, 'nexFileName/fileID', 1);
addRequired(p, 'input1', validator);

% Start Time
validator = @(x) validateattributes(x, {'numeric'}, ParserAttribute.ScalarNotEmpty.toCell);
addParameter(p, 'StartTime', defaults.startTime, validator);

% End Time
validator = @(x) validateattributes(x, {'numeric'}, ParserAttribute.ScalarNotEmpty.toCell);
addParameter(p, 'EndTime', defaults.endTime, validator);

% Window Size
validator = @(x) validateattributes(x, {'numeric'}, ParserAttribute.ScalarNotEmpty.toCell);
addParameter(p, 'WindowSize', defaults.windowSize, validator);

% Window Step
validator = @(x) validateattributes(x, {'numeric'}, ParserAttribute.ScalarNotEmpty.toCell);
addParameter(p, 'WindowStep', defaults.windowStep, validator);

% Intervals
validator = @(x) validateattributes(x, {'string' 'numeric' 'cell'}, {'2d'});
addParameter(p, 'Intervals', defaults.intervals, validator);

% Minimum number of spikes required to do the analysis for a given neuron.
validator = @(x) validateattributes(x, {'numeric'}, ...
    ParserAttribute.ScalarNotEmpty.toCell('>=', 2));
addParameter(p, 'MinSpikeCount', defaults.minSpikeCount, validator);

% Minimum percentage of AMD windows that a neuron must persist across for
% it to be considered valid.
validator = @(x) validateattributes(x, {'numeric'}, ...
    ParserAttribute.ScalarNotEmpty.toCell('>=', 0, '<=', 1));
addParameter(p, 'MinPersistence', defaults.minPersistence, validator);

% Minimum number of valid neurons required for the analysis to run.
validator = @(x) validateattributes(x, {'numeric'}, ...
    ParserAttribute.ScalarNotEmpty.toCell('>=', 2));
addParameter(p, 'MinValidNeurons', defaults.minValidNeurons, validator);

% Output format
validator = @(x) validateattributes(x, {'string' 'char'}, ...
    {'scalartext' 'nonempty'});
addParameter(p, 'OutputFormat', defaults.outputFormat, validator);

% Parallel processing toggle
validator = @(x) validateattributes(x, {'logical'}, {'scalar' 'nonempty'});
addParameter(p, 'Parallel', defaults.parallel, validator);

% Waitbar toggle
validator = @(x) validateattributes(x, {'logical' 'matlab.ui.Figure'}, ...
    ParserAttribute.ScalarNotEmpty.toCell);
addParameter(p, 'ShowWaitbar', defaults.showWaitbar, validator);

parse(p, input1, varargin{:});

assert(ismember(lower(p.Results.OutputFormat), {'array' 'table'}), ...
    'amd:inputError', 'Invalid output format: %s', p.Results.OutputFormat);

%% Setup

if islogical(p.Results.ShowWaitbar)
    showWaitbar = p.Results.ShowWaitbar;
    hWaitbar = [];
elseif isa(p.Results.ShowWaitbar, 'matlab.ui.Figure')
    showWaitbar = true;
    hWaitbar = p.Results.ShowWaitbar;
else
    error('amd:invalidInput', 'ShowWaitbar must be a logical or handle to a waitbar.');
end

% Open the nex file and get a file descriptor.
[fid, wasOpened] = nex.opennexfile(input1);

% Register a cleanup object that will close the file ID, but only if a
% filename was specified.
if wasOpened
    fileCleanupObj = onCleanup(@() nex.closenexfile(fid));
end

% If an end time wasn't specified, then we'll set it to be the maximum file
% duration found in the NEX file's file header.
if p.Results.EndTime == Inf
    fileHeader = nex.readfileheader(fid);
    endTime = fileHeader.tend;
else
    endTime = p.Results.EndTime;
end

% Read all the neuron data from the NEX file.  The neuron data contains the
% spike times of interest.
neuronData = nex.getneurondata(fid);
nNeurons = height(neuronData);

% Create a set of start/end times for each time window we're going to
% analyze.
startTimes = p.Results.StartTime:p.Results.WindowStep:(endTime - p.Results.WindowSize);
endTimes = startTimes + p.Results.WindowSize;
nWindows = length(endTimes);

if isempty(p.Results.Intervals)
    intervalTimes = [];
else
    % Get the time boundaries for all intervals specified.
    intervalTimes = cellfun(@(x) {nex.getintervaltimes(fid, x, true)}, ...
        cellstr(p.Results.Intervals));
    
    % Concatenate all the returned interval times and sort them by the
    % interval start time.
    intervalTimes = vertcat(intervalTimes{:});
    intervalTimes = sortrows(intervalTimes, 'Start');
end

% Pull out some variables so we're not using broadcast variables within the
% parfor loop in the AMD section.
timestamps = neuronData.timestamps;
minSpikeCount = p.Results.MinSpikeCount;

%% Filter Neurons
% Filter our neurons we don't want to analyze.  We only want neurons that
% meet our minimum spike count threshold and exist across all windows.

% Loop over all windows and create a running list of spike counts for each
% neuron in each window.
spikeCounts = zeros(nNeurons, nWindows);
for iWindow = 1:nWindows
    % Create a logical index of valid spike times for each neuron given the
    % time window.
    iValid = cellfun(@(x) filterspikes(x, intervalTimes, startTimes(iWindow), endTimes(iWindow)), ...
         timestamps, 'UniformOutput', false);
    assert(length(iValid) == nNeurons);
    
    % Calculate the spike counts for each neuron and add it to our running
    % list of spike counts.
    spikeCounts(:, iWindow) = cellfun(@sum, iValid);
end

% Each row of our running list contains the number of spikes for each
% window.  Find the rows that meet our minimum spike count and persistence.
iSpikes = spikeCounts >= minSpikeCount;
fValidNeurons = find(sum(iSpikes, 2) / nWindows >= p.Results.MinPersistence);

% Now find all windows where the minimum number of valid neurons within the
% window meets the specified threshold.  We enforce that all time windows
% must have the minimum number of valid neurons for the calculations to run.
fValidWindows = find(sum(iSpikes(fValidNeurons,:), 1) >= p.Results.MinValidNeurons);
nValidWindows = length(fValidWindows);
assert(nValidWindows > 0, ...
    'amd:valueError', ...
    'No valid AMD windows found using the minimum number of valid neurons: %g', ...
    p.Results.MinValidNeurons);

% Using our newly minted list of valid neurons, pull out the respective
% neuron names.
validNeuronNames = cellstr(neuronData.name(fValidNeurons));

%% AMD

dynamical.dprintf(1, '%% AMD - Allocating memory for %d windows...', nValidWindows);

% If toggled, setup the waitbar to display the analysis progress.
if showWaitbar
    s = 'AMD - Allocating Memory';
    
    if isempty(hWaitbar)
        hWaitbar = waitbar(0, s);
        
        % Register a cleanup function for the waitbar.
        waitbarCleanupObj = onCleanup(@() close(hWaitbar));
    else
       waitbar(0, hWaitbar, s);
    end
end

t0 = tic;

% Preallocate the maximum memory we'll need to store the AMD results.
amdWindows = repmat(dynamical.math.AMDWindow, 1, nValidWindows);
for iWindow = 1:nValidWindows
    % Get the actual window index of interest.
    i = fValidWindows(iWindow);
    
    % Double check that we're getting at least the specified minimum
    % number of valid windows
    iN = iSpikes(fValidNeurons,i);
    nValidNeurons = sum(iN);
    assert(nValidNeurons >= p.Results.MinValidNeurons, ...
        'amd:minValidNeurons', ...
        'Window does not have the minimum number of valid neurons: %g/%g', ...
        nValidNeurons, p.Results.MinValidNeurons);
    
    w = dynamical.math.AMDWindow;
    w.Stats = array2table([fValidNeurons(iN) zeros(nValidNeurons, 4)], ...
        'VariableNames', {'CellID' 'nSpikes' 'ISImean' 'ISIstd' 'Poisson'}, ...
        'RowNames', validNeuronNames(iN));
    w.AMD = array2table(zeros(nValidNeurons), ...
      'VariableNames', validNeuronNames(iN), ...
      'RowNames', validNeuronNames(iN));
    w.ZScore = w.AMD;
    
    % Calculate the spike counts for each neuron.
    w.Stats.nSpikes = spikeCounts(fValidNeurons(iN),i);
    
    w.WindowStart = startTimes(i);
    w.WindowEnd = endTimes(i);
    
    amdWindows(iWindow) = w;
    
    if showWaitbar
        waitbar(iWindow/nValidWindows, hWaitbar);
    end
end

t = toc(t0);

% Make sure the AMD windows are monotonically increasing in start time.
assert(issorted([amdWindows.WindowStart]));

dynamical.dprintf(1, 'Done: %g (s)\n', t);

dynamical.dprintf(1, '%% AMD - Calculating AMDs...\n'); 
t0AMD = tic;

if p.Results.Parallel
    %% AMD Parallel
    
    % Preallocate the array which will hold our parallel.FevalFuture
    % objects.
    futures = repmat(parallel.FevalFuture, 1, nValidWindows);
    nFutures = length(futures);
    
    % Launch all of our analysis workers and store its associated
    % parallel.FevalFuture object. Each worker will process one AMD
    % window.
    try
        for i = 1:nValidWindows
            futures(i) = parfeval(@amdtask, 1, ...
                amdWindows(i), intervalTimes, timestamps, i, ...
                nValidWindows, minSpikeCount);
        end
    catch e
        cancel(futures);
        rethrow(e);
    end
    
    % In case of error, we'll register a cleanup object that will cancel
    % all the parallel jobs that are running.
    futuresCleanupObj = onCleanup(@() cancel(futures));
    
    % Wait for all the workers to finish and collect the results.  The
    % timeout(seconds) is the maximum amount of time 'fetchNext' will wait
    % for a result from a worker to become available.
    fetchTimeout = Inf;
    for i = 1:nFutures
        if showWaitbar
            s = sprintf('AMD - Processing Window %d of %d', i, nValidWindows);
            waitbarValue = (i-1) / nValidWindows;
            waitbar(waitbarValue, hWaitbar, s);
        end
        
        [iWindow, amdWindow] = fetchNext(futures, fetchTimeout);
        amdWindows(iWindow) = amdWindow;
        
        if showWaitbar
            waitbarValue = i / nValidWindows;
            waitbar(waitbarValue, hWaitbar);
        end
    end
else
    %% AMD Sequential
    for i = 1:nValidWindows
        if showWaitbar
            s = sprintf('AMD - Processing Window %d of %d', i, nValidWindows);
            waitbarValue = (i-1) / nValidWindows;
            waitbar(waitbarValue, hWaitbar, s);
        end
        
        amdWindows(i) = amdtask(amdWindows(i), intervalTimes, timestamps, ...
            i, nValidWindows, minSpikeCount);
        
        % Update the waitbar if toggled.
        if showWaitbar
            waitbarValue = i / nValidWindows;
            waitbar(waitbarValue, hWaitbar);
        end
    end
end

tAMD = toc(t0AMD);
dynamical.dprintf(1, '%% AMD - Calculating AMDs Finished: %g (s)\n', tAMD); 

% Convert the array of AMDwindow into a table for easier viewing.
if strcmpi(p.Results.OutputFormat, 'table')
    amdWindows = dynamical.math.AMDWindow.array2table(amdWindows);
end


function amdWindow = amdtask(amdWindow, intervalTimes, timestamps, iWindow, nValidWindows, minSpikeCount)
dynamical.dprintf(2, '%% AMD Window - %d of %d...', iWindow, nValidWindows);

t0 = tic;

iCurrentNeurons = amdWindow.Stats.CellID;
nCurrentNeurons = length(iCurrentNeurons);

% Get a list of indices of spikes that fit within the time window
% [startTime, endTime).
s = amdWindow.WindowStart;
e = amdWindow.WindowEnd;
%dynamical.dprintf(2, '%% AMD Window - Time Bounds: (%g,%g)\n', s, e);
fValid = cellfun(@(x) find(filterspikes(x, intervalTimes, s, e)), ...
    timestamps(iCurrentNeurons), 'UniformOutput', false);

% Make sure things look properly formatted in the analysis tables.
assert(isequal(amdWindow.Stats.Row, ...
    amdWindow.AMD.Row, ...
    amdWindow.AMD.Properties.VariableNames'), ...
    'amd:internalError', 'Rows/Columns of the Stats and AMD tables are not the same.');

% Find the min and max spike times across the valid neurons for this
% time window.
minMax = nan(nCurrentNeurons, 2);
for i = 1:nCurrentNeurons
    ic = iCurrentNeurons(i);
    n = timestamps{ic}(fValid{i});
    minMax(i,:) = [min(n) max(n)];
end
timeMin = min(minMax(:,1));
timeMax = max(minMax(:,2));
timeDiff = timeMax - timeMin;
assert(timeDiff > 0 || isnan(timeDiff), 'amd:poissonError', 'Invalid time diff: %g', timeDiff);

% Calculate the Poisson value for each neuron.  Any Inf values are
% reset to 0.
amdWindow.Stats.Poisson = 0.5 * timeDiff ./ amdWindow.Stats.nSpikes;

% Calculate the ISIs.  I'm blindly following the method implemented by
% Dan in the AMDv4 function.  This has been looked over by the PI
% (Michal Zochowski) and confirmed to be correct.
ISImean = nan(nCurrentNeurons, 1);
ISIwidth = nan(nCurrentNeurons, 1);
for i = 1:nCurrentNeurons
    I = iCurrentNeurons(i);
    ISI = timestamps{I}(fValid{i});
    c1 = ISI(1) - timeMin;
    c2 = timeMax - ISI(end);
    dISI = diff(ISI);
    ISImean(i) = 1/2/timeDiff * (c1^2 + c2^2) + sum(1/4/timeDiff*dISI.^2);
    ISIwidth(i) = 1/3/timeDiff * (c1^3 + c2^3) + sum(1/12/timeDiff*dISI.^3);
end
amdWindow.Stats.ISImean = ISImean;
amdWindow.Stats.ISIstd = sqrt(ISIwidth - ISImean.^2);

% Store some of the parameters used in the data calculations.
amdWindow.MinSpikeCount = minSpikeCount;
amdWindow.TimeMin = timeMin;
amdWindow.TimeMax = timeMax;
amdWindow.TimeDiff = timeDiff;

% For any zero spike neurons we'll set their ISIs and Poisson values to
% zero.
iJunk = amdWindow.Stats.nSpikes <= 0;
amdWindow.Stats.ISImean(iJunk) = 0;
amdWindow.Stats.ISIstd(iJunk) = 0;
amdWindow.Stats.Poisson(iJunk) = 0;

% Create a set of all unique neuron pair combinations.  If we have 3
% available neurons we'll get a set of pairs that look like
% 1,2
% 1,3
% 2,3
% We use these pairs as indices into the iValidNeurons variable we
% calculated above that represents the reduced set of neurons we are
% analyzing after we've excluded neurons that don't meet our minimum
% qualifications.
neuronCombos = nchoosek(1:nCurrentNeurons, 2);
nCombos = size(neuronCombos, 1);

% For each combination we want to calculate the average minimum
% distance (AMD) in both directions.  For instance, if we're are
% looking at the combination (1,3), we also calculate the the
% combinations (3,1) as the calculation isn't symetric.
for iCombo = 1:nCombos
    % For convenience pull out the indices for our combo.
    i1 = neuronCombos(iCombo, 1);
    i2 = neuronCombos(iCombo, 2);

    % Now get the neuron indices.
    iS1 = iCurrentNeurons(i1);
    iS2 = iCurrentNeurons(i2);

    % Pull out the two spike trains we are going to analyze.
    S1 = timestamps{iS1}(fValid{i1});
    S2 = timestamps{iS2}(fValid{i2});

    % Calculate the average minimum distance (AMD) in both directions.
    amdWindow.AMD{i1, i2} = finddistance(S1, S2);
    amdWindow.AMD{i2, i1} = finddistance(S2, S1);
end

% This could probably be put in its own function, but we'll go ahead
% and calculate the z-score here.  Please consult with the Zochowski
% lab to understand how this calculation works as I am just following
% their step by step directions.
C = repmat(sqrt(amdWindow.Stats.nSpikes), 1, nCurrentNeurons);
Im = repmat(amdWindow.Stats.ISImean', nCurrentNeurons, 1);
Iw = repmat(amdWindow.Stats.ISIstd', nCurrentNeurons, 1);
Ivals = (Im - amdWindow.AMD{:,:}) ./ Iw;
amdWindow.ZScore{:,:} = Ivals .* C;

t1 = toc(t0);
dynamical.dprintf(2, '%g (s)\n', t1);


function iFilter = filterspikes(x, intervalTimes, startTime, endTime)
% FILTERSPIKES
%
% Syntax:
% iFilter = FILTERSPIKES(x, intervalTimes, startTime, endTime)

iFilter = x >= startTime & x < endTime;

% Only run the interval time filter if it's been defined.
if ~isempty(intervalTimes)
    iMask = zeros(size(iFilter));
    
    iValidIntervals = find(intervalTimes.Start <= endTime & intervalTimes.End >= startTime);
    
    if ~isempty(iValidIntervals)
        for i = iValidIntervals'
            iMask = iMask | (x >= intervalTimes.Start(i) & x <= intervalTimes.End(i));
        end
    end
    
    iFilter = iFilter & iMask;
end


function meanDist = finddistance(S1, S2)
% FINDDISTANCE
%
%

edges = [-Inf ; S2(1:end-1) + diff(S2)/2 ; Inf];
i = discretize(S1, edges);
meanDist = mean(abs(S1-S2(i)));
