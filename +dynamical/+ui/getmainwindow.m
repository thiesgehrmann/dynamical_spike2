function mainWindow = getmainwindow
% GETMAINWINDOW  Gets the handle to the main window of the program.
%
% Syntax:
% mainWindow = GETMAINWINDOW
%
% Description:
% Finds the handle associated with the main window and returns it.
%
% Output:
% mainWindow (matlab.ui.Figure) - Handle to the main window/figure.

% Read the config file to get the main window's tag.
config = dynamical.config.readconfig;

% Find the main window.
mainWindow = findobj('Tag', config.mainWindow.tag);

% Make sure we found something...
assert(~isempty(mainWindow), ...
    'getmainwindow:systemError', ...
    'Could not find the main Dynamical window.');

% There should only be 1 object found with the 'dynamical' tag.
assert(length(mainWindow) == 1, ...
    'getmainwindow:systemError', ...
    'Found too many windows associated with the tag: %s', config.mainWindow.tag);

% The main window must be a figure.  I suppose there's a chance someone
% made an object tagged with 'dynamical' that isn't a figure window.
assert(isa(mainWindow, 'matlab.ui.Figure'), ...
    'getmainwindow:systemError', ...
    'Handle with tag "%s" is not a figure window.', config.mainWindow.tag);
