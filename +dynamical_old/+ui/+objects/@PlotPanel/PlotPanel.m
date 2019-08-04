classdef PlotPanel < uix.BoxPanel
    % PLOTPANEL
    %
    % Syntax:
    % obj = PLOTPANEL
    % obj = PLOTPANEL(options)
    % 
    % PLOTPANEL Properties:
    %
    % PLOTPANEL Methods:
    % updatePlotHandler - 'UpdateAMDPlot' notification handler.
    %
    % See also uix.BoxPanel dynamical.ui.events.Notifier
    
    % Internal Variables
    properties (Access = protected)
        % Internal handles to the various widgets.
        PlotAxes
        
        % Handle for the Dynamical notifier object.  This is used to listen
        % to broadcasted events and to possibly trigger notifications of
        % relevance to other parts of the program.
        Notifier
    end
    
    properties (Access = private)
        % The axes container is used get around an issue where if the
        % PlotAxes are placed directly in the PlotPanel, adding a colorbar
        % will cause the axes to disappear.
        AxesContainer
    end
    
    % Public Methods
    methods
        function obj = PlotPanel(varargin)
            obj = obj@uix.BoxPanel(varargin{:});
            
            initialize(obj);
            
            obj.Notifier = dynamical.ui.events.Notifier.getHandle;
            addlistener(obj.Notifier, 'UpdateAMDPlot', @obj.updatePlotHandler);
            addlistener(obj.Notifier, 'PopoutPlot', @obj.popoutPlot);
        end
        
        % Notification Handlers
        updatePlotHandler(obj, source, eventData)
        popoutPlot(obj, source, eventData)
    end
    
    % Private Static methods
    methods (Access = private, Static = true)
        plotStabilityData(axesObj, stabilityData, stabilityTimes)
    end
end
