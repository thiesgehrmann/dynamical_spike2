function fileOpenedHandler(obj, ~, eventData)

dynamical.dprintf(2, '# FileInfoPanel:FileOpened\n');

% Load all the widgets with file data.
fileHeader = nex.readfileheader(eventData.FileID);
obj.FileName = eventData.FilePath;
obj.StartTime = fileHeader.tbeg;
obj.EndTime = fileHeader.tend;
obj.Frequency = fileHeader.freq;
