classdef Notifier < handle
    % NOTIFIER Notifier class for Dynamical.
    
    events
        FileOpened
        UpdateAMDPlot
        PopoutPlot
    end
    
    methods (Static = true)
        function handle = getHandle
            mainWindow = dynamical.ui.getmainwindow;            
            handle = getappdata(mainWindow, 'notifier');
        end
    end
end
