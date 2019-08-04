function assertprereqs
% ASSERTPREREQS  Makes sure Dynamical prerequisites are installed.
%
% Syntax:
% ASSERTPREREQS
%
% Description:
% Dynamical depends on several libraries and functions that are external to
% Dynamical and MATLAB.  This function makes sure they exist and produces
% an error if something is missing.

% Get the base config folder for Dynamical.
configDir = dynamical.config.locatefolder;

% Read the prereqs config file that lists all required toolboxes.
prereqs = yaml.ReadYaml(fullfile(configDir, 'prereqs.yaml'));
pNames = fieldnames(prereqs);
nPrereqs = length(pNames);

% Get a list of user installed toolboxes.
tbs = matlab.addons.toolbox.installedToolboxes;

% Get a string representation of the type of computer that this code is
% running on.  Each prerequisite has a list of required architectures that
% tell us if we should expect the toolbox to be installed.  For instance,
% Mac and Linux machines require a toolbox that writes Excel files while
% Windows machines do not since that functionality is baked in.
cStr = computer;

% Loop through the prereqs and make sure they exist in the list of
% installed toolboxes.
for i = 1:nPrereqs
    % If the prereq is required for this platform make sure it's installed.
    if ismember(cStr, prereqs.(pNames{i}).platform)
       prereqName = prereqs.(pNames{i}).name;
       [isMember, iLoc] = ismember(prereqName, {tbs.Name});
       assert(isMember, 'Toolbox not installed: %s', prereqName)
       
       % Convert the prerequisite min version into an array of numerical
       % values.  E.g. '1.2.3' becomes [1 2 3]
       [t, ~] = regexp(prereqs.(pNames{i}).minVersion, '(\d+)\.?', 'tokens', 'match');
       minTokens = cellfun(@str2double, t);
       nMinTokens = length(minTokens);
       
       % Do the same for installed toolbox.
       [t, ~] = regexp(tbs(iLoc).Version, '(\d+)\.?', 'tokens', 'match');
       tbTokens = cellfun(@str2double, t);
       nTbTokens = length(tbTokens);
       
       % Get the length of the longest version number.
       nMax = max([nMinTokens, nTbTokens]);
       
       % Pad the version tokens with zeros so that they are equal in
       % length.
       minTokens = [minTokens, zeros(1, nMax - nMinTokens)]; %#ok<AGROW>
       tbTokens = [tbTokens, zeros(1, nMax - nTbTokens)]; %#ok<AGROW>
       
       % Start from the major version number and proceed to the most minor
       % version.  Our process to figure out if the installed prereq is
       % greater than or equal to the required minimum is as follows:
       % 1. If the installed version > minimum version, installed
       %    version is valid.
       % 2. If installed version < minimum version, installed version is
       %    not valid.
       % 3. If installed version == minimum version, go to the next version
       %    number.
       isVersionOK = true;
       for j = 1:nMax
           if tbTokens(j) > minTokens(j)
               break;
           elseif tbTokens(j) < minTokens(j)
               isVersionOK = false;
               break;
           end  
       end
       assert(isVersionOK, 'Toolbox %s:%s does not meet the minimum version %s', ...
           prereqName, tbs(iLoc).Version, prereqs.(pNames{i}).minVersion);
    end
end
