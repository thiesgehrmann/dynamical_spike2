function configDir = getconfigdirectory
% GETCONFIGDIRECTORY  Returns the Dynamical UI config directory.
%
% Syntax:
% configDir = GETCONFIGDIRECTORY
%
% Description:
% Helper function to return the location of the config directory for the
% dynamical.ui package.  This config folder will contain any configuration
% files needed for the GUI, such as the menu configuration file.

% Find the folder this function sits in.
baseDir = fileparts(which(sprintf('dynamical.ui.%s', mfilename)));

% The config folder should exist in the same folder as this function.
% Construct the config directory path.
configDir = fullfile(baseDir, 'config');

assert(exist(configDir, 'dir') > 0, ...
    'dynamical:ui:dirNotFound', ...
    'Could not find config directory: %s', configDir);
