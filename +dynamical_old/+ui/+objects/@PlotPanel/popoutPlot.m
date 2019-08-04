function popoutPlot(obj, source, eventData)
% POPOUTPLOT  'PopoutPLot' notification handler.
%
% Description:
% Notification callback to handle 'PopoutPlot' UI notifications.

mainWindow = dynamical.ui.getmainwindow;
stability = getappdata(mainWindow, 'stability');

if isempty(stability)
    dynamical.dprintf(1, '# No data available to plot.\n');
    return;
end

% Pop out a new figure and axes.
f = figure;
a = axes;
    
% Plot into the new figure/axes.
obj.plotStabilityData(a, stability.data, stability.times);
   
% Make the new axes to have the same ratio as the ones on the UI.
a.PlotBoxAspectRatio = obj.PlotAxes.PlotBoxAspectRatio;
    
% Resize the figure window to be a bit bigger.
f.Position = [f.Position(1:2)/2, f.Position(3:4)*2];
        
% Move the figure so that it fits on the screen.
movegui(f, 'onscreen');

drawnow;
