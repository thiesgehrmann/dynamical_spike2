classdef AMDParamsPanel < uix.BoxPanel
    properties (Dependent = true)
        IntervalNames       string
        StartTime           double
        StopTime            double
        WindowSize          double
        WindowStep          double
        MinPersistence      double
        MinSpikeCount       double
        MinValidNeurons     double
        Parallel            logical
        StabilityMethod     string
    end
    
    % Internal Variables
    properties (Access = protected)
        % Handle to the main uix.VBox layout.  All widgets are children of
        % this object.
        MainVBox
        
        % Internal handles to the various widgets.
        IntervalListBox
        IntervalHBox
        IntervalNames_
        
        ProcessButton
        
        StartTimeHBox
        StartTimeEdit
        StartTime_
        
        StopTimeHBox
        StopTimeEdit
        StopTime_
        
        WindowHBox
        WindowEdit
        WindowSize_
        
        WindowStepHBox
        WindowStepEdit
        WindowStep_
        
        MinPersistenceHBox
        MinPersistenceEdit
        MinPersistence_
        
        MinSpikeCountHBox
        MinSpikeCountEdit
        MinSpikeCount_
        
        MinValidNeuronsHBox
        MinValidNeuronsEdit
        MinValidNeurons_
        
        ParallelHBox
        ParallelCheckBox
        Parallel_
        
        StabilityMethodBGroup
        StabilityMethod_
      
        % Handle for the Dynamical notifier object.  This is used to listen
        % to broadcasted events and to possibly trigger notifications of
        % relevance to other parts of the program.
        Notifier
    end
    
    % Public Methods
    methods
        function obj = AMDParamsPanel(varargin)
            obj = obj@uix.BoxPanel(varargin{:});
            
            initialize(obj);
            
            obj.Notifier = dynamical.ui.events.Notifier.getHandle;
            addlistener(obj.Notifier, 'FileOpened', @obj.fileOpenedHandler);
        end
        
        % Notification Handlers
        fileOpenedHandler(obj, source, eventData)
                
        % Widget Callbacks
        processButtonCallback(obj, source, eventData)
        processButtonGroupCallback(obj, source, eventData)
        editKeyPressFcn(obj, source, eventData)
        editCallback(obj, source, eventData)
        checkboxCallback(obj, source, eventData)
        
        selectedIntervals = getSelectedIntervals(obj)
    end
    
    % Protected Methods
    methods (Access = protected)
        
    end
    
    % Get/Set Methods
    methods
        % Interval Names
        function set.IntervalNames(obj, intervalNames)
            obj.IntervalNames_ = intervalNames;
            
            % Set the object string field to display the intervals and make
            % sure nothing is selected.
            obj.IntervalListBox.String = obj.IntervalNames_;
            obj.IntervalListBox.Value = [];
        end
        
        function intervalNames = get.IntervalNames(obj)
            intervalNames = obj.IntervalNames_;
        end
        
        % Start Time
        function set.StartTime(obj, startTime)
            validateattributes(startTime, {'double'}, {'scalar' '>=' 0});
            
            obj.StartTime_ = startTime;
            obj.StartTimeEdit.String = startTime;
        end
        
        function startTime = get.StartTime(obj)
            startTime = obj.StartTime_;
        end
        
        % Stop Time
        function set.StopTime(obj, stopTime)
            validateattributes(stopTime, {'double'}, {'scalar' '>=' 0});
            
            obj.StopTime_ = stopTime;
            obj.StopTimeEdit.String = stopTime;
        end
        
        function stopTime = get.StopTime(obj)
            stopTime = obj.StopTime_;
        end
        
        % Window Size
        function set.WindowSize(obj, windowSize)
            validateattributes(windowSize, {'double'}, {'scalar' '>=' 0});
            
            obj.WindowSize_ = windowSize;
            obj.WindowEdit.String = windowSize;
        end
        
        function windowSize = get.WindowSize(obj)
            windowSize = obj.WindowSize_;
        end
        
        % Window Step
        function set.WindowStep(obj, windowStep)
            validateattributes(windowStep, {'double'}, {'scalar' '>=' 0});
            
            obj.WindowStep_ = windowStep;
            obj.WindowStepEdit.String = windowStep;
        end
        
        function windowStep = get.WindowStep(obj)
            windowStep = obj.WindowStep_;
        end
        
        % Minimum Persistence
        function set.MinPersistence(obj, minPersistence)
            validateattributes(minPersistence, {'double'}, ...
                {'scalar', '>=', 0, '<=', 1});
            
            obj.MinPersistence_ = minPersistence;
            obj.MinPersistenceEdit.String = minPersistence;
        end
        
        function minPersistence = get.MinPersistence(obj)
            minPersistence = obj.MinPersistence_;
        end
        
        % Minimum spike count
        function set.MinSpikeCount(obj, minSpikeCount)
            validateattributes(minSpikeCount, {'numeric'}, {'scalar', '>=' 2});
            
            obj.MinSpikeCount_ = minSpikeCount;
            obj.MinSpikeCountEdit.String = minSpikeCount;
        end
        
        function minSpikeCount = get.MinSpikeCount(obj)
            minSpikeCount = obj.MinSpikeCount_;
        end
        
        % Minimum number of valid neurons.
        function set.MinValidNeurons(obj, minValidNeurons)
            validateattributes(minValidNeurons, {'numeric'}, ...
                {'scalar', '>=', 2});
            
            obj.MinValidNeurons_ = minValidNeurons;
            obj.MinValidNeuronsEdit.String = minValidNeurons;
        end
        
        function minValidNeurons = get.MinValidNeurons(obj)
            minValidNeurons = obj.MinValidNeurons_;
        end
        
        % Parallel processing mode.
        function set.Parallel(obj, isParallel)
            validateattributes(isParallel, {'logical'}, {'scalar' 'nonempty'});
            
            obj.Parallel_ = isParallel;
            obj.ParallelCheckBox.Value = isParallel;
        end
        
        function isParallel = get.Parallel(obj)
            isParallel = obj.Parallel_;
        end
        
        % Stability method
        function set.StabilityMethod(obj, stabilityMethod)
            % Input must be a scalar, non-empty string.
            validateattributes(stabilityMethod, {'string'}, {'scalar' 'nonempty'});
            
            % Make sure the string input matches an available stability
            % method.
            [~, s] = enumeration('dynamical.enums.StabilityMethod');
            stabilityMethod = validatestring(stabilityMethod, s);
            
            obj.StabilityMethod_ = stabilityMethod;
        end
        
        function stabilityMethod = get.StabilityMethod(obj)
            stabilityMethod = obj.StabilityMethod_;
        end
    end
    
    % Static Methods
    methods (Static = true)
        minimizePanel(source, event, panelObj)
    end
end
