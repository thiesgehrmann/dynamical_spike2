function installdynamical

depsPath = fullfile(fileparts(which(mfilename)), 'deps');

% Get a list of the toolboxes found in the deps folder.
tbDir = dir(fullfile(depsPath, '*.mltbx'));
nToolboxes = length(tbDir);

% Loop over all the toolboxes found and run the installer.
for i = 1:nToolboxes
    fprintf('%% Installing: %s...', tbDir(i).name);
    tbFile = fullfile(depsPath, tbDir(i).name);
    matlab.addons.toolbox.installToolbox(tbFile, true);
    fprintf('Done\n');
end

fprintf('%% Installing: DynamicalToolboxSPIKENEX...');
%matlab.addons.toolbox.installToolbox(fullfile(fileparts(which(mfilename)), 'DynamicalToolboxSPIKENEX.mltbx'));
fprintf('Done\n');