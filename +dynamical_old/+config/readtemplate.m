function templateData = readtemplate
% READTEMPLATE  Reads the template config file for Dynamical.
%
% Syntax:
% templateData = READTEMPLATE
%
% Description:
% All config files for Dynamical need to follow a specific format.  The
% template is the gold standard on what goes into a particular config file.
% This template will be used to validate config files read and config files
% written.

% Construct the path to the template, which should exist in the +config
% package folder.
templateFileName = fullfile(dynamical.config.locatefolder, ...
    'dynamical.yaml.template');

% Verify that this file exists just in case someone removed it.
assert(exist(templateFileName, 'file') > 0, ...
    'readtemplate:templateNotFound', ...
    'Cannot find template file: %s', templateFileName);

% Read the template.
templateData = yaml.ReadYaml(templateFileName);
