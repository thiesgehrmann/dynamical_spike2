function  savedata(fileName)
% SAVEDATA  Saves app data to a file.
%
% Syntax:
% SAVEDATA(fileName)
%
% Description:
% Saves data attached to the open Dynamical main window to a .mat file.
%
% Input:
% fileName (string) - Name of the file to save to.  If not specified or is
%     empty, a file selection UI will be presented.

narginchk(1, 1);

% Make sure a nonempty string was passed.
validateattributes(fileName, {'string' 'char'}, {'vector' 'nonempty'}, ...
    mfilename, 'fileName', 1);

% Also ensure the file name is a .mat file by checking the file extension.
[~, ~, suffix] = fileparts(fileName);
assert(strcmpi(suffix, '.mat'), ...
    'savedata:inputError', ...
    'File name must have the .mat suffix.');

% Exract the app data ssociated with the currently running Dynamical.
mainWindow = dynamical.ui.getmainwindow;
appData = getappdata(mainWindow);

% Keep only fields we care about, which is currently only the analysis
% output.s
fieldsToSave = {'AMDwindows' 'stability'};
f = fieldnames(appData);
i = ~ismember(f, fieldsToSave);
appDataToSave = rmfield(appData, f(i));

% Don't bother saving the app data if it doesn't contain anything.
if isempty(appDataToSave)
    warning('savedata:valueError', ...
        'App data is empty, not saving: %s', fileName);
else
    save(fileName, '-struct', 'appDataToSave');
end
