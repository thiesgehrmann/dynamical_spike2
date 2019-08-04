function popoutplot(~, ~)
% POPOUTPLOT  Pops out the current plot into its own window.
%
% Syntax:
% POPOUTPLOT(src, event)
%
% Description:
% Callback for the Tools->Popout Plot menu item.

narginchk(2, 2);

% See dynamical.ui.PlotPanel for the handler for this notification.
notify(dynamical.ui.events.Notifier.getHandle, 'PopoutPlot')
