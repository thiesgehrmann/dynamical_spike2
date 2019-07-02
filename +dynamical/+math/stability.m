function [stabilityValues, stabilityTimes] = stability(amdWindows, varargin)
% STABILITY  Calculates AMD stability across windows.
%
% Syntax:
% [S, T] = STABILITY(amdWindows)
% ___ = STABILITY(___, options)
%
% Description:
%
% Input:
% amdWindows (dynamical.math.AMDWindow array) - Array of AMDWindows to
%     process.  The AMDWindows should have already been processed by the
%     dynamical.math.amd function.
%
% Output:
% S
% T

%% Setup
narginchk(1, Inf);

p = inputParser;

methodList = {'neighbor' 'all'};
defaults.Method = methodList{1};
defaults.showWaitbar = false;
defaults.parallel = false;

% Stability Method
validator = @(x) validateattributes(x, {'string' 'char'}, ...
    {'nonempty' 'scalartext'});
addParameter(p, 'Method', defaults.Method, validator);

% Waitbar Toggle
validator = @(x) validateattributes(x, {'logical' 'matlab.ui.Figure'}, ...
    {'scalar' 'nonempty'});
addParameter(p, 'ShowWaitbar', defaults.showWaitbar, validator);

% Parallel Toggle
validator = @(x) validateattributes(x, {'logical'}, {'scalar' 'nonempty'});
addParameter(p, 'Parallel', defaults.parallel, validator);

parse(p, varargin{:});

% Make sure the stability method is found in the list of allowable
% stability methods.
[~, s] = enumeration('dynamical.enums.StabilityMethod');
validatestring(p.Results.Method, s);

assert(~istable(amdWindows));

if islogical(p.Results.ShowWaitbar)
    showWaitbar = p.Results.ShowWaitbar;
    hWaitbar = [];
elseif isa(p.Results.ShowWaitbar, 'matlab.ui.Figure')
    showWaitbar = true;
    hWaitbar = p.Results.ShowWaitbar;
else
    error('amd:invalidInput', 'ShowWaitbar must be a logical or handle to a waitbar.');
end

% Get the number of AMDWindows and ensure that we have at least 2 windows,
% otherwise the analysis can't run.
nWindows = length(amdWindows);
assert(nWindows >= 2, 'stability:inputError', ...
    'At least 2 AMDWindows must be specified.');

% If toggled, setup the waitbar to display the analysis progress.
if showWaitbar
    s = 'Stability - ';
    
    if isempty(hWaitbar)
        hWaitbar = waitbar(0, s);
        
        % Register a cleanup function for the waitbar.
        waitbarCleanupObj = onCleanup(@() close(hWaitbar));
    else
       waitbar(0, hWaitbar, s);
    end
end

%% Stability
% Calculate the stability using the specified method.  Currently, there are
% two options: 'Neighbor' and 'All'.  All analysis methods have an optional
% parallel mode to speed up calculations.

switch lower(p.Results.Method)
    case 'neighbor'
        % AMDWindows next to each other in time are compared.  For example,
        % window 1 is compared to window 2, window 3 vs window 4, etc.
        % This will produce a stability over time vector.
        
        % Create the set of window index pairs.  This is a Mx2 matrix where
        % each row contains the indices of windows to compare.
        w = arrayfun(@(x) [x x+1], 1:(nWindows-1), 'UniformOutput', false);
        windowPairs = cell2mat(w');
        nPairs = size(windowPairs, 1);
        
        % Preallocate memory to hold the stability values and times.
        stabilityValues = zeros(1, nPairs);
        stabilityTimes = zeros(1, nPairs);
        
    case 'all'
        % Create the set of window index pairs.  This is a Mx2 matrix where
        % each row contains the indices of windows to compare.
        windowPairs = nchoosek(1:nWindows, 2);
        nPairs = size(windowPairs, 1);
        
        % Preallocate memory for the calculated stability values.  In the
        % all by all case, this will be a matrix of MxM values with the
        % diagonal fixed at zero because windows are never compared to
        % themselves.
        stabilityValues = zeros(nWindows);
        
        % Stability times aren't used in the all by all analysis so we set
        % it to empty.
        stabilityTimes = [];
        
    otherwise
        error('Unknown stability method: %s', p.Results.Method);
end

 dynamical.dprintf(1, '%% Stability - Num Window Pairs: %d\n', nPairs);

if p.Results.Parallel
    %% Parallel Processing
    
    % Determine how many window pairs we want to analyze per parallel job.
    % We keep it constrained to in the range [5,50].
    windowChunkSize = round(nPairs/10 * 5);
    if windowChunkSize < 5
        windowChunkSize = 5;
    elseif windowChunkSize > 25
        windowChunkSize = 25;
    end
    
    dynamical.dprintf(1, '%% Stability - Window Chunk: %d\n', windowChunkSize);
    
    % Figure out which of our pairs belong to which window chunk.
    iWindowGroups = discretize(1:nPairs, unique([1:windowChunkSize:nPairs nPairs+1]));
    assert(~any(isnan(iWindowGroups)));
    windowGroups = unique(iWindowGroups);
    nWindowGroups = length(windowGroups);
    
    % Preallocate the array which will hold our parallel.FevalFuture
    % objects.           
    futures = repmat(parallel.FevalFuture, 1, nWindowGroups);
    nFutures = length(futures);
    
    try
        % Launch all of our analysis workers and store its associated
        % parallel.FevalFuture object. Each worker will process one AMD
        % window.
        for i = 1:nFutures
            if showWaitbar
                s = sprintf('Stability - Creating Parallel Job %d of %d', i, nFutures);
                waitbarValue = (i-1) / nFutures;
                waitbar(waitbarValue, hWaitbar, s);
            end
            
            w = windowGroups(i);
            iw = iWindowGroups == w;
            
            % Get the window indices for the two AMDWindows that
            % will be compared.
            a = windowPairs(iw,1);
            b = windowPairs(iw,2);
            
            switch lower(p.Results.Method)
                case 'neighbor'
                    % For each stability value, we associate a time value.  The
                    % time value is the mean between the end of one window and
                    % the start of the other.  This is somewhat arbitrary, but
                    % make the stability values easy to plot.
                    stabilityTimes(iw) = mean([[amdWindows(a).WindowEnd]' ...
                                               [amdWindows(b).WindowStart]'], 2);
                    
                case 'all'
                    % Do nothing for now
                    
                otherwise
                    error('Unknown stability method: %s', p.Results.Method);
            end
            
            futures(i) = parfeval(@dynamical.math.similarity, 1, ...
                amdWindows(a), amdWindows(b));
           
           if showWaitbar
               waitbarValue = i / nFutures;
               waitbar(waitbarValue, hWaitbar);
           end
        end
    catch e
        cancel(futures);
        rethrow(e);
    end
    
    % In case of error, we'll register a cleanup object that will
    % cancel all the parallel jobs that are running.
    futuresCleanupObj = onCleanup(@() cancel(futures));
    
    % Wait for all the workers to finish and collect the results.
    % The timeout(seconds) is the maximum amount of time
    % 'fetchNext' will wait for a result from a worker to become
    % available.
    fetchTimeout = Inf;
    for i = 1:nFutures
        if showWaitbar
            s = sprintf('Stability - Processing Set %d of %d', i, nFutures);
            waitbarValue = (i-1) / nFutures;
            waitbar(waitbarValue, hWaitbar, s);
        end
        
        % Get the next available stability result.
        [iS, S] = fetchNext(futures, fetchTimeout);
        
        % Map window chunk into actual indices of the output data, which
        % will be an array.
        w = windowGroups(iS);
        iw = iWindowGroups == w;
        
        switch lower(p.Results.Method)
            case 'neighbor'
                stabilityValues(iw) = S;
                
            case 'all'
                a = windowPairs(iw,1);
                b = windowPairs(iw,2);
                
                for j = 1:length(a)
                    stabilityValues(a(j),b(j)) = S(j);
                    stabilityValues(b(j),a(j)) = S(j);
                end
                
            otherwise
                error('Unknown stability method: %s', p.Results.Method);
        end
        
        if showWaitbar
            waitbarValue = i / nFutures;
            waitbar(waitbarValue, hWaitbar);
        end
    end
else
    %% Serial Processing
    
    for i = 1:nPairs
        % Update the waitbar to indicate which window pair we're analyzing.
        if showWaitbar
            s = sprintf('Stability - Window Pair %d of %d', i, nPairs);
            waitbarValue = (i-1) / nPairs;
            waitbar(waitbarValue, hWaitbar, s);
        end
        
        % Get the window indices for the two AMDWindows that will be
        % compared.
        a = windowPairs(i,1);
        b = windowPairs(i,2);
        
        t0 = tic;
        dynamical.dprintf(2, '# Stability - Window Pair (%d,%d)...', a, b);
        
        % Calculate the stability between the two AMDWindows.
        S = dynamical.math.similarity(amdWindows(a), amdWindows(b));
        
        switch lower(p.Results.Method)
            case 'neighbor'
                % For each stability value, we associate a time value.  The
                % time value is the mean between the end of one window and the
                % start of the other.  This is somewhat arbitrary, but make the
                % stability values easy to plot.
                stabilityTimes(i) = mean([amdWindows(a).WindowEnd amdWindows(b).WindowStart]);
                
                stabilityValues(i) = S;
                
            case 'all'
                stabilityValues(a,b) = S;
                stabilityValues(b,a) = S;
                
            otherwise
                error('Unknown stability method: %s', p.Results.Method);
        end
        
        dynamical.dprintf(2, '%g (s)\n', toc(t0));
        
        % Update the waitbar when the window pair completes.
        if showWaitbar
            waitbarValue = i / nPairs;
            waitbar(waitbarValue, hWaitbar);
        end
    end
end

