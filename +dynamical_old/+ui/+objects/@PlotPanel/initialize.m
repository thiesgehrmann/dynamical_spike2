function initialize(obj)
% INITIALIZE  Initializes the PlotPanel objects.
%
% Syntax:
% INITIALIZE(obj)
%
% Description:
% Called from the object's constructor, this function does all the basic
% initialization of widgets and internal variables.
%
% Input:
% obj (dynamical.ui.objects.PlotPanel) - The PlotPanel object to
%     initialize.

narginchk(1, 1);

obj.Title = '';
if ismac
    obj.FontSize = 14;
else
    obj.FontSize = 12;
end

% Read the global config file.
configData = dynamical.config.readconfig;

if configData.debugLevel >= 3
    obj.BackgroundColor = ones(1,3) * 0.8;
end

obj.AxesContainer = uicontainer('Parent', obj);
obj.PlotAxes = axes('Parent', obj.AxesContainer);
obj.PlotAxes.XTick = [];
obj.PlotAxes.YTick = [];
