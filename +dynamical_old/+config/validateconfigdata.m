function validateconfigdata(configData)
% VALIDATECONFIGDATA  Validates dynamical config data.
%
% Syntax:
% VALIDATECONFIGDATA(configData)
%
% Description:
% Uses the default dynamical config template to make sure user generated or
% specified config data contains the data required for dynamical to
% function and use.  An error is thrown in the event there is data
% inconstistency.  There is no return value from this function, but
% exceptions are thrown in the event of an error.
%
% Input:
% configData (struct) - Dynamical configuration data.
%
% Throws:
% 'validateconfigdata:fieldnameMismatch' - Top level fieldname mismatch
%     between the config data and the template.
% 'validateconfigdata:subfieldMismatch' - Fields of the top level variables
%     in the config data do not match those of the template.

narginchk(1, 1);

validateattributes(configData, {'struct'}, {'scalar', 'nonempty'}, ...
    mfilename, 'configData', 1);

% Read the default template config data.
templateData = dynamical.config.readtemplate;

% Get a list of the fieldnames from the template data and the config data.
% Sort the fieldnames alphabetically for easy comparison.
tFieldNames = sort(fieldnames(templateData));
cFieldNames = sort(fieldnames(configData));

% Compare the primary fieldnames to make sure they are the same.
assert(isequal(tFieldNames, cFieldNames), ...
    'validateconfigdata:fieldnameMismatch', ...
    'Fieldnames differ from template.');

% Use this callback to compare the subfieldnamess of the top level
% fieldnames.
    function i = fieldCompare(configField, templateField)
        c = sort(fieldnames(configData.(configField)));
        t = sort(fieldnames(templateData.(templateField)));
        i = isequal(c, t);
    end

% For each top level fieldname, look to see if the subfieldnames are the
% same.  We only look 1 level down.  By design the config will only be 2
% levels deep to make things simple.
assert(all(cellfun(@fieldCompare, cFieldNames, tFieldNames)), ...
    'validateconfigdata:subfieldMismatch', ...
    'Subfieldnames differ from template.');
end
