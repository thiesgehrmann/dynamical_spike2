function setfileappdata(fileData)
% SETFILEAPPDATA  Sets the app data associated with NEX file information.
%
% Syntax:
% SETFILEAPPDATA(fileData)
%
% Description:
% Dynamical stores any file information in an app data variable called
% 'file'. This function overwrites that information with the data passed to
% this function.
%
% Input:
% fileData (struct) - File information data.

mainWindow = dynamical.ui.getmainwindow();
setappdata(mainWindow, 'file', fileData);
