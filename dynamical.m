function dynamical
% DYNAMICAL  
%
% Syntax:
% DYNAMICAL
%
% Description:
% Analysis program for the Aton/Zochowski AMD project.

% Make sure that some prerequisites exist before we run anything.
dynamical.util.assertprereqs;

% Read the global config data.
config = dynamical.config.readconfig(false);

% Go ahead and write the config file now in the event one doesn't exist in
% the user's local config directory.
dynamical.config.writeconfig(config);

%% Here load the CEDMAT library
addpath(getenv('CEDS64ML'))
CEDS64LoadLib(getenv('CEDS64ML'))
    
% Look for the main dynamical window.  If it already exists, we will bring
% it to the front.
h = findobj('Tag', config.mainWindow.tag);
if isempty(h)
    % Create the main window for the program, but don't show it just yet.
    % We want to add all the figure components, callbacks, and do
    % initialization before we show it.
    mainWindow = figure('CloseRequestFcn', @closeme, ...
        'MenuBar', 'none', ...
        'Name', config.mainWindow.name, ...
        'NumberTitle', config.mainWindow.numberTitle, ...
        'Position', [1 1 [config.mainWindow.size{1:2}]], ...
        'Tag', config.mainWindow.tag, ...
        'Visible', 'off');

    % Move the main window to the center of the display.
    movegui(mainWindow, 'center');
    
    % Create the GUI handles object and attach it to the main figure.
    handles = guihandles(mainWindow);
    guidata(mainWindow, handles);
    
    % Create the main Notifier object which we'll use more or less as a
    % singleton by attaching it to the main Dynamical window's app data.
    % The notifier needs to be constructed before adding all the widgets so
    % that the widgets can use a valid Notifier handle when adding
    % listeners.
    notifier = dynamical.ui.events.Notifier;
    setappdata(mainWindow, 'notifier', notifier);
    
    % Create the menu system for dynamical.
    menuConfigFile = fullfile(dynamical.ui.getconfigdirectory, 'menuconfig.yaml');
    dynamical.ui.rendermenu(mainWindow, menuConfigFile);
    
    % The 'file' app variable stores data related to the .nex file.
    setappdata(mainWindow, 'file', []);
    
    % AMD window calculations.
    setappdata(mainWindow, 'amdWindowTable', []);
    setappdata(mainWindow, 'stability', []);
    
    % Create our layout grid to which we'll add all widgets and UI
    % elements.
    gridLayout = uix.Grid('Parent', mainWindow);
    
    % Add the UI componenets.
    handles = guidata(mainWindow);
    v = uix.VBox('Parent', gridLayout);
    handles.amd_params_panel = dynamical.ui.objects.AMDParamsPanel('Parent', v, ...
        'Tag', 'amd_params_panel');
    handles.file_info_panel = dynamical.ui.objects.FileInfoPanel('Parent', v, ...
        'Tag', 'file_info_panel');
    handles.plot_panel = dynamical.ui.objects.PlotPanel('Parent', gridLayout, ...
        'Tag', 'plot_panel');
    guidata(mainWindow, handles);
    
    v.Heights = [-1, 250];
    gridLayout.Widths = [250, -1];
    gridLayout.Heights = -1;
    
    % Show the main window now that everything is ready.
    mainWindow.Visible = 'on';
else
    % Bring the extant dynamical window to the front.
    figure(h);
end


function closeme(src, callbackData) %#ok<INUSD>
% CLOSEME  Close callback for the main Dynamical window.
%
% Syntax:
% CLOSEME(src, callbackData)

fprintf('# Closing Dynamical\n');

fileData = dynamical.ui.getfileappdata;
if ~isempty(fileData)
    fclose(fileData.fid);
end

closereq;
