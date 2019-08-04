function prefsDir = initprefsdir
% INITPREFSDIR  Initializes the preferences directory used by dynamical.
%
% Syntax:
% prefsDir = INITPREFSDIR
%
% Description:
% Dynamical makes use of the MATLAB preferences folder to store config
% files or any other persistent data between sessions.  This function makes
% sure the folder exists and creates it if it doesn't.
%
% Output:
% prefsDir (string) - The preferences folder.

narginchk(0, 0);

persistent isInitialized

if isempty(isInitialized)
    % Create the preferences directory if it doesn't exist yet.
    if exist(prefdir, 'dir') == 0
        prefdir(1);
        
        warning('initprefsdir:prefdir', ...
            'Creating new MATLAB user preferences directory: %s', ...
            prefdir);
    end
    
    % This is the location of where we'll store any dynamical
    % preference/config files or any persistent data.
    prefsDir = fullfile(prefdir, 'Dynamical');
    
    % If the prefs folder doesn't exist, create it now.
    if exist(prefsDir, 'dir') == 0
        warning('dynamical:config:readconfig', ...
            'Creating new Dynamical preferences directory: %s', ...
            prefsDir);
        
        [status, message, messageID] = mkdir(prefsDir);
        assert(status, messageID, message);
    end
    
    isInitialized = true;
else
    % This is the location of where we'll store any dynamical
    % preference/config files or any persistent data.
    prefsDir = fullfile(prefdir, 'Dynamical');
end
