classdef FileInfoPanel < uix.BoxPanel
    properties (Dependent = true)
        StartTime
        EndTime
        Frequency
        FileName
    end
    
    % Internal Variables
    properties (Access = protected)
        % Handle to the main uix.VBox layout.  All widgets are children of
        % this object.
        MainVBox
        
        % Filename
        FileNameHBox
        FileNameLabel
        FileNameEdit
        FileName_
        
        % Start Time
        FileStartHBox
        FileStartEdit
        StartTime_
        
        % End Time
        FileEndHBox
        FileEndEdit
        EndTime_
        
        % Frequency
        FileFreqHBox
        FileFreqEdit
        Frequency_
        
        % Handle for the Dynamical notifier object.  This is used to listen
        % to broadcasted events and to possibly trigger notifications of
        % relevance to other parts of the program.
        Notifier
    end
    
    % Public Methods
    methods
        % Constructor
        function obj = FileInfoPanel(varargin)
            obj = obj@uix.BoxPanel(varargin{:});
            
            initialize(obj);
            
            obj.Notifier = dynamical.ui.events.Notifier.getHandle;
            addlistener(obj.Notifier, 'FileOpened', @obj.fileOpenedHandler);
        end
        
        fileOpenedHandler(obj, source, eventData)
    end
    
    % Get/Set Methods - These have to be created inline to the class.
    methods
        % Filename
        function set.FileName(obj, fileName)
            obj.FileName_ = fileName;
            [~, obj.FileNameEdit.String] = fileparts(fileName);
            obj.FileNameLabel.TooltipString = fileName;
        end
        
        function fileName = get.FileName(obj)
            fileName = obj.FileName_;
        end
        
        % Frequency
        function set.Frequency(obj, frequency)
            obj.Frequency_ = frequency;
            obj.FileFreqEdit.String = frequency;
        end
        
        function frequency = get.Frequency(obj)
            frequency = obj.Frequency_;
        end
        
        % Start Time
        function set.StartTime(obj, startTime)
            obj.StartTime_ = startTime;
            obj.FileStartEdit.String = startTime;
        end
   
        function startTime = get.StartTime(obj)
            startTime = obj.StartTime_;
        end
        
        % End Time
        function set.EndTime(obj, endTime)
            obj.EndTime_ = endTime;
            obj.FileEndEdit.String = endTime;
        end
        
        function endTime = get.EndTime(obj)
            endTime = obj.EndTime_;
        end
    end
end
