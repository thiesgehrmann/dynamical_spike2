function open(~, ~)
% OPEN  Opens a .nex file.
%
% Syntax:
% OPEN(src, event)
%
% Description:
% Callback for the File->Open menu item.

narginchk(2, 2);

% Show a file dialog that let's the user select a .nex file.
[fileName, pathName] = uigetfile('*.nex', 'Select a NEX file');

% If the user didn't cancel the dialog box, store some of the file info in
% the main window's app data.
if ~isequal(fileName, 0)    
    % Store some basic NEX file information in the appdata so that we have
    % easy access to the file identifier.  The file identifier lets us
    % access the NEX data using the NEX toolbox functions.
    fileData.path = fullfile(pathName, fileName);
    fileData.fid = nex.opennexfile(fileData.path);
    dynamical.ui.setfileappdata(fileData);
    
    dynamical.dprintf(2, '# Open File: %s\n', fileData.path);

    % Broadcast to the rest of the UI that we've opened a new file.  Attach
    % the file information to the notification so any registered listeners
    % have basic file info without having to couple them to the main
    % window.
    eventData = dynamical.ui.events.OpenFileEventData(fileData.fid, fileData.path);
    notify(dynamical.ui.events.Notifier.getHandle, 'FileOpened', eventData);
else
    dynamical.dprintf(2, '# Open File: dialog closed\n');
end
