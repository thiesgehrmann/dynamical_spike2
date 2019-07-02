function plotStabilityData(axesObj, stabilityData, stabilityTimes)
% PLOTSTABILITYDATA  Plots stability data.
%
% Syntax:
% PLOTSTABILITYDATA(axesObj, stabilityData, stabilityTimes)
%
% Description:
% Core function to render stability data in the PlotPanel, but can also be
% used to render the stability data in any given axes.
%
% axesObj (Axes) - MATLAB Axes object to plot into.
% stabilityData
% stabilityTimes

narginchk(3, 3);

axes(axesObj);

if isvector(stabilityData)
    t = timeseries(stabilityData, stabilityTimes);
    
    % Make the time series units to be seconds in case it isn't already.
    t.TimeInfo.Units = 'seconds';
    t.Name = 'Stability over Time';
    
    plot(t, 'MarkerSize', 5, 'Marker', '.', 'Parent', axesObj);
    ylabel('Stability');
    axis tight;
    zoom on;
else
    imagesc(stabilityData);
    colorbar('eastoutside');
    ylabel('Window #');
    xlabel('Window #');
    title('All x All Heatmap');
    zoom on;
end
