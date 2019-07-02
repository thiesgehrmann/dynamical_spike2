function e = make
% MAKE
%
% Syntax:
%
% Description:

%% Read Repository Data
% Get the mercurial information for the project and save it to a file in
% the main dynamical folder.  This allows the packaged app to be able to
% access this info as the .hg folder isn't included.

% Get the working copy info.
topDir = fileparts(which('dynamical.m'));
workingCopyData = hg.identifyworkingcopy(topDir);

% Throw an error if the working directory is dirty.
assert(workingCopyData.localRevisionNumber(end) ~= '+', ...
    'dynamical:make:systemError', ...
    'Working copy has uncommitted changes.');

% Save the build data.
matFileName = fullfile(topDir, 'builddata.mat');
save(matFileName, 'workingCopyData');


%% Modify Project File

% Append a '.0' to the end of the revision string that we'll use for build
% version.  MATLAB project syntax requires the version string to look
% something like "x.x.x".
projectVersion = sprintf('%s.0', workingCopyData.localRevisionNumber);

% Overwrite the app version number to have it match the mercurial revision.
projectFileName = 'Dynamical.prj';
xDoc = xmlread(fullfile('.', projectFileName));
e = xDoc.getElementsByTagName('param.version');
e.item(0).getFirstChild.setTextContent(projectVersion)
xmlwrite('out.prj', xDoc);


