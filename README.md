# Dynamical

cloned from https://gitlab.umich.edu/lsa-ts-rsp/dynamical

## TO DO

From what I can tell, the large part of the import/parsing process is in the +dynamical/+math/amd.m file, in which the nex file is read and measurements are extracted.
I need to modify this to determine whether a nex file or a spike file is being used.

### Core dynamical functionality
 - [X] dynamical.enums.ParameterAttributes isn't working
   - Fixed by changing ScalarNonEmpty to ScalarNotEmpty, and NonEmpty to NotEmpty
 - [ ] Excel export doesn't work (see error below)
     ```Error using xlswrite (line 192)
    An error occurred on data export in CSV format.
    
    Error in dynamical.util.save2excel (line 60)
            feval(excelFcn, xlsFileName, [seqTimeRanges, seqAverages], 'Stability', r);
    
    Error in dynamical.ui.objects.AMDParamsPanel/processButtonCallback (line 135)
            dynamical.util.save2excel(fileData.path, stability, amdStruct, hWaitbar, ...
    
    Error in dynamical.ui.objects.AMDParamsPanel/initialize>@(varargin)obj.processButtonCallback(varargin{:}) (line 225)
        'Callback', @obj.processButtonCallback, ...
    
    Caused by:
        Error using dlmwrite (line 104)
        The input cell array cannot be converted to a matrix.
    ```

### Functions I need to make SPIKE2 ports for

These already work fine!
 - [X] opennexfile -> openfile
 - [X] closenexfile -> closefile
 - [ ] readfileheader
  - Used in:
    - +dynamical\+math\amd.m
    - +dynamical\+ui\+objects\@AMDParamsPanel\fileOpenedHandler.m
    - +dynamical\+ui\+objects\@FileInfoPanel\fileOpenedHandler.m
  - Attributes in structure:
    - [X] fileheader.tbeg -> The starting timepoint of recording
    - [X] fileheader.tend -> The ending timepoint of recording
    - [X] fileheader.freq -> The frequency of recording
    - [ ] fileheader.numvars -> The number of variables defined in the SPIKE2 file
  - Still to figure out:
    - How to identify the number of variables. OR EVEN HOW TO GET THE VARIABLES!!!! :S
 - [ ] listintervalnames. **NOTE: SPIKE2 files don't support intervals. This function will return just a single interval.**
   - Used in:
     - +dynamical\+ui\+objects\@AMDParamsPanel\fileOpenedHandler.m
     - +dynamical\cutdata.m
 - [ ] getintervaltimes. **NOTE: SPIKE2 files don't support intervals. This function will return just a single interval.**
   - Used in:
     - +dynamical\+math\amd.m
     - +dynamical\cutdata.m
 - [ ] getneurondata. This is the core of the challenge.
   - Used in:
     - +dynamical\+math\amd.m
   - Steps
     - [X] Figure out how data is stored.
       - Data is stored in WaveMark channels.
       - For a given channel, you can request a certain number of events using the ```CEDS64ReadExtMarks```, or ```CEDS64ReadMarkers``` function
       - This returns a list of events, in which
         - ```m_Time``` variable represents the time at which the event took place, and
         - ```m_Code1``` variable represents the ID of the neuron in this channel that spiked at that point
     - [X] Figure out how data should be represented afterwards




 

