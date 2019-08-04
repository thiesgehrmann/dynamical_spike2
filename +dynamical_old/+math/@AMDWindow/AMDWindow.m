classdef AMDWindow
    % AMDWINDOW  AMDWindow class
    %
    % Syntax:
    % obj = AMDWINDOW
    % obj = AMDWINDOW(options)
    %
    % Description:
    % Simple class to encapsulate AMD analysis data and time window
    % information.  
    %
    % AMDWINDOW Properties:
    % TimeMin - Smallest spike timestamp found within the window. (s)
    % TimeMax - Largest spike timestamp found within the window. (s)
    % TimeDiff - Time difference between TimeMin and TimeMax. (s)
    % WindowStart - Start time of the window. (s)
    % WindowEnd - End Time of the window. (s)
    % ZScore - Calculated AMD z-scores.
    % AMD - Calculated AMD table.
    %
    % AMDWINDOW Methods:
    % array2table - Converts an AMDWindow array to a table.
    % table2array - Converts a AMDWindow table into an array.
    
    %% Public Properties
    properties
        % Minimum number of spikes required for a given neuron.
        MinSpikeCount = 0;
        
        % Smallest spike timestamp found within the window. (s)
        TimeMin = 0
        
        % Largest spike timestamp found within the window. (s)
        TimeMax = 0
        
        % Time difference between TimeMin and TimeMax. (s)
        TimeDiff = 0
        
        % Start time of the window. (s) 
        WindowStart = 0
        
        % End Time of the window. (s)
        WindowEnd = 0     
        
        % Calculated AMD z-scores.
        ZScore = []
        
        % This is kind of a catch all table to put statistics calculated by
        % the various bits of the program without cluttering up the visual
        % representation of the data when dumped to the console.
        Stats = []
        
        % Calculated AMD table.
        AMD = []        
    end
    
    properties (Dependent = true)
        NeuronNames
    end
    
    %% Public Methods
    methods
        function obj = AMDWindow(varargin)
            % Get a list of publically settable properties of an AMDWindow
            % object.  These values we'll allow to be set as options passed
            % to the constructor.
            mObj = metaclass(obj);
            iProp = arrayfun(@(x) strcmp(x.SetAccess, 'public'), mObj.PropertyList);
            assert(any(iProp));
            publicProperties = mObj.PropertyList(iProp);
            nProps = length(publicProperties);
            
            p = inputParser;
            
            % Automagically add all the properties to the input parser.
            % Right now, this bit o' code doesn't add any validators and
            % sets the default value to NaN.
            for i = 1:nProps
                propName = publicProperties(i).Name;
                defaultValue = NaN;
                addParameter(p, propName, defaultValue);
            end
            
            % Parse any inputs passed to the constructor.
            parse(p, varargin{:});
            
            % Get the argument names that may have been specified to the
            % constructor.
            argNames = setdiff(p.Parameters, p.UsingDefaults);
            nArgs = length(argNames);
            
            % For each argument to the constructor, set the corresponding
            % property of the object.
            for i = 1:nArgs
                propName = argNames{i};
                obj.(propName) = p.Results.(propName);
            end
        end
        
        function n = get.NeuronNames(obj)
            if istable(obj.Stats)
                n = obj.Stats.Row;
            else
                n = [];
            end
        end
    end
    
    %% Static Methods
    methods (Static = true)
        windowTable = array2table(windowArray)
        windowArray = table2array(windowTable)
    end
end
