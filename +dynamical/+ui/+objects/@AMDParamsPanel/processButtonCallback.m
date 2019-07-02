function processButtonCallback(obj, ~, ~)
% PROCESSBUTTONCALLBACK  Callback for the Process button.
%
% Syntax:
% PROCESSBUTTONCALLBACK(obj, source, eventData)
%
% Description:
% Process button callback for the AMDParamsPanel class.  This function sets
% up the waitbar to show processing progress, runs the actual analysis,
% then fires off an even to indicate to the rest of the program that the
% data is read to be plotted.  Analysis data is saved to a .mat file of the
% same name as the input file and also exported partly to an Excel file
% also with the same name but with the date appended.

%% Setup

fileData = dynamical.ui.getfileappdata;

buttonString = obj.ProcessButton.String;
cleanupObj = onCleanup(@() cleanup(obj.ProcessButton, buttonString));

% Get the list of the selected intervals.
intervals = obj.getSelectedIntervals;
if isrow(intervals)
    intervals = intervals';
end

hWaitbar = waitbar(0, 'Processing Data', 'WindowStyle', 'normal');
waitbarCleanupObj = onCleanup(@() close(hWaitbar));

% Make the waitbar text bigger on the Mac.
if ismac
    hWaitbar.CurrentAxes.FontSize = 12;
end

% Setup the parameter for the analysis.  
amdParams = {'StartTime', obj.StartTime, ...
             'EndTime', obj.StopTime, ...
             'WindowSize', obj.WindowSize, ...
             'WindowStep', obj.WindowStep, ...
             'Intervals', intervals, ...
             'MinSpikeCount', obj.MinSpikeCount, ...
             'MinPersistence', obj.MinPersistence, ...
             'MinValidNeurons', obj.MinValidNeurons, ...
             'Parallel', obj.Parallel, ...
             'OutputFormat', string('array'), ...
             'ShowWaitbar', hWaitbar};
         
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

if amdStruct.Parallel
    waitbar(0, hWaitbar, 'Starting up parallel pool...');
    
    % Set the parallel pool's timeout to 8 hours.  This prevents the
    % parallel pool from timeing out in a typical workday and introducing
    % huge delays when running the analysis.
    parallelObj = gcp;
    parallelObj.IdleTimeout = 60*8;
    
    % Starting the pool usually causes the dynamical window to lose focus,
    % so we force focus back to the main window.
    figure(dynamical.ui.getmainwindow);
    figure(hWaitbar);
end

%% AMD

dynamical.dprintf(1, '%% AMD - Processing Data...\n');
obj.ProcessButton.String = '*** Calculating AMD ***';
obj.ProcessButton.Enable = 'off';
drawnow;
t0 = tic;
amdWindows = dynamical.math.amd(fileData.fid, amdParams{:});
t = toc(t0);
dynamical.dprintf(1, '%% AMD - Processing Finished: %g (s)\n', t);

% Store the AMD analysis.
setappdata(dynamical.ui.getmainwindow, 'amdWindows', amdWindows);

% Bring the main window and processing bar back to the front if they've
% been hidden.
figure(dynamical.ui.getmainwindow);
figure(hWaitbar);

%% Stability

obj.ProcessButton.String = '*** Calculating Stability ***';

t0 = tic;
[S, T] = dynamical.math.stability(amdWindows, 'Method', obj.StabilityMethod, ...
    'ShowWaitBar', hWaitbar, 'Parallel', obj.Parallel);
t = toc(t0);
dynamical.dprintf(1, '%% Stability - Processing Finished: %g (s)\n', t);
stability.data = S;
stability.times = T;
setappdata(dynamical.ui.getmainwindow, 'stability', stability);
drawnow;

% Bring the main window and processing bar back to the front if they've
% been hidden.
figure(dynamical.ui.getmainwindow);
figure(hWaitbar);

%% Save Data

% Append this to the filenames so that we have a unique .mat and .xls file
% for every analysis.
dateSuffix = datestr(now, '.mm-dd-yyyy.HH-MM-SS');

% Save the analysis to a .mat file.  Do this before we bother with Excel
% as Excel can be finicky and worst case scenario we can "resave" the data
% if we still have the raw .mat data.
amdStruct2 = amdStruct;
amdStruct2.ShowWaitbar = true;
[p, f] = fileparts(fileData.path);
matFileName = fullfile(p, [f dateSuffix '.mat']);
metaData = struct('date', datestr(now), 'params', amdStruct2); %#ok<NASGU>
save(matFileName, 'metaData', 'amdWindows', 'stability');

% Excel output only implemented for the 'neighbor' stability method right
% now.
switch lower(obj.StabilityMethod)
    case {'neighbor', 'all'}
        % Export the data to an Excel file.
        waitbar(0, hWaitbar, 'Excel - Exporting Data');
        dynamical.util.save2excel(fileData.path, stability, amdStruct, hWaitbar, ...
            obj.StabilityMethod, dateSuffix);
        
    otherwise
        warning('Excel export for method "%s" not implemented yet', ...
            obj.StabilityMethod);
end

%% Cleanup

obj.ProcessButton.Enable = 'on';

figure(dynamical.ui.getmainwindow);
figure(hWaitbar);

% Notify the program that the AMD plots are ready to be redrawn.
notify(obj.Notifier, 'UpdateAMDPlot');


function cleanup(h, s)
h.String = s;
h.Enable = 'on';
