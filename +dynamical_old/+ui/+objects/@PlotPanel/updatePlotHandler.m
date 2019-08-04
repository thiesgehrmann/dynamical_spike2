function updatePlotHandler(obj, source, eventData)
% UPDDATEPLOTHANDLER  'UpdateAMDPlot' notification handler.
%
% Description:
% Notification callback to handle 'UpdateAMDPlot' UI notifications.

mainWindow = dynamical.ui.getmainwindow;
stability = getappdata(mainWindow, 'stability');

obj.plotStabilityData(obj.PlotAxes, stability.data, stability.times);

drawnow;
