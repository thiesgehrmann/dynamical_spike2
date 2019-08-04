function configData = readconfig(useCache)
% READCONFIG  Reads the Dynamical config file.
%
% Syntax:
% configData = READCONFIG
% configData = READCONFIG(useCache)
%
% Description:
% Reads/loads the config file for dynamical.  Config data is store in YAML
% format.  To prevent needless reads of the config file, the data is cached
% between calls unless either:
% a. The config filename is changed.
% b. The user specifies to NOT use the cache.
% c. The readconfig function is cleared from memory.
%
% Input:
% useCache (logical) - If true, the last known config data will be returned
%     instead of reading it from the file directly.  Default: true
%
% Output:
% configData (struct) - The data read from the config file.

% Notes:
% Make sure to not use the dynamical.dprintf function in here as it calls
% this function.  This will result in an infinite loop of readconfig
% calling dprintf and visa versa.

narginchk(0, 1);

persistent lastFileName cachedData

if nargin == 0
    useCache = true;
end

% Construct the config filename.
pDir = char(dynamical.config.initprefsdir);
configFileName = fullfile(pDir, 'dynamical.yaml');

% If the last used filename and the specified don't match, then we'll need
% a read the config file again despite what the user requests.
if ~strcmp(lastFileName, configFileName)
    useCache = false;
end

validateattributes(useCache, {'logical'}, {'scalar'}, mfilename, 'useCache', 2);

if useCache
    configData = cachedData;
else
    % If the config file already exists, load it, but if it doesn't, load
    % the template.
    if exist(configFileName, 'file') > 0
        configData = yaml.ReadYaml(configFileName);
    else
        warning('dynamical:config:readConfig:noConfigFound', ...
            'No config file found, loading template');
        
        configData = dynamical.config.readtemplate;
    end
    
    cachedData = configData;
end

lastFileName = configFileName;
