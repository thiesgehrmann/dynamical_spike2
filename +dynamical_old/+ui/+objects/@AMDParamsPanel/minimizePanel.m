function minimizePanel(source, event, panelObj)
% MINIMIZEPANEL  Minimize AMD panel callback.
%
% Syntax:
% MINIMIZEPANEL(source, event)
%
% Description:
% Callback function for the AMD panel to minimize the panel.
%
% Input:
% source (UIControl) - Source UI object.
% event (ActionData) - The event data.
% panelObj (AMDParamsPanel) - The AMDParamsPanel from which this event is
%     generated.

% Get the current minimized status.
isMinimized = panelObj.Minimized;

% % A panel has been maximized/minimized
%         s = get( box, 'Heights' );
%         pos = get( fig, 'Position' );
%         panel{whichpanel}.Minimized = ~panel{whichpanel}.Minimized;
%         if panel{whichpanel}.Minimized
%             s(whichpanel) = pheightmin;
%         else
%             s(whichpanel) = pheightmax;
%         end 
%         set( box, 'Heights', s );
%         
%         % Resize the figure, keeping the top stationary
%         delta_height = pos(1,4) - sum( box.Heights );
%         set( fig, 'Position', pos(1,:) + [0 delta_height 0 -delta_height] );
