function location = locatefolder
% LOCATEFOLDER  Locates the +config package folder.
%
% Syntax:
% location = LOCATEFOLDER
%
% Description:
% Locates the +config package folder and returns the full path.
%
% Output:
% location (string) - The path to (and including) the +config package
%     folder.

location = fileparts(mfilename('fullpath'));
