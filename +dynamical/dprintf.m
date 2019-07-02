function dprintf(debugLevelMin, varargin)
% DPRINTF  Debug printf for Dynamical.
%
% Syntax:
% DPRINTF(debugLevelMin, printString)
% DPRINTF(debugLevelMin, printString, printArgs)
%
% Description:
% This function is basically a wrapper around printf that allows the user
% to specify a minimum debug level before the printf executes.  The debug
% level is read from Dynamical's main config file.
%
% Input:
% debugLevelMin (integer) - The minimum debug level required for the printf
%     to execute.
% printString (string) - The string to print including any formatters.
% printArgs - Variables matching the string formatters.

narginchk(2, Inf);

% Get the default config data.
configData = dynamical.config.readconfig;

if configData.debugLevel >= debugLevelMin
    fprintf(varargin{:});
end
