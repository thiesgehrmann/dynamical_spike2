classdef OpenFileEventData < event.EventData
    properties
        FileID
        FilePath
    end
    
    methods
        function obj = OpenFileEventData(fileID, filePath)
            obj.FileID = fileID;
            obj.FilePath = filePath;
        end
    end
end
