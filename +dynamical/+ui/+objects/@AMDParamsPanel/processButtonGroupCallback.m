function processButtonGroupCallback(obj, ~, event)
% PROCESSBUTTONGROUPCALLBACK  Stabilty method button group callback.
%
% Syntax:
% PROCESSBUTTONGROUPCALLBACK(obj, source, event)
%
% Description:
% Callback for the AMDParamsPanel StabilityMethod button group.  Sets the
% object property 'StabilityMethod' to the currently selected option.

obj.StabilityMethod = event.NewValue.String;
