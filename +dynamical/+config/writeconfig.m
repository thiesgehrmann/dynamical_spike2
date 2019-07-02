function writeconfig(configData)
% WRITECONFIG  Writes the config file for dynamical.
%
% Syntax:
% WRITECONFIG(configData)
%
% Description:
% Writes the config file used by dynamical to store global persistent
% parameters.  A filename may be specified, but by default it will store
% the config in the +dynamical package directory as "dynamical.yaml".
%
% Input:
% configData (struct) - The configuration data to save.

narginchk(1, 1);

validateattributes(configData, {'struct'}, {'scalar'}, mfilename, ...
    'configData', 1);

% Construct the config filename.
pDir = char(dynamical.config.initprefsdir);
configFileName = fullfile(pDir, 'dynamical.yaml');

yaml.WriteYaml(configFileName, configData);

% Clear the readconfig function from memory.  This will reset its
% persistent variables that keep a cache of the last known config data.
readConfigName = fullfile(dynamical.config.locatefolder, 'readconfig.m');
clear(readConfigName);
