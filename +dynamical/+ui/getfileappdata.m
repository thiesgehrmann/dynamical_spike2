function fileData = getfileappdata
% GETFILEAPPDATA  Returns the app data associated with file information.
%
% Syntax:
% fileData = GETFILEAPPDATA
%
% Description:
% Dynamical stores any file information in an app data variable called
% 'file'.  This function extracts that information and returns it.
%
% Output:
% fileData (struct) - File information.

mainWindow = dynamical.ui.getmainwindow();
fileData = getappdata(mainWindow, 'file');
