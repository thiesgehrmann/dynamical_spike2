# Dynamical

cloned from https://gitlab.umich.edu/lsa-ts-rsp/dynamical

## TO DO

From what I can tell, the large part of the import/parsing process is in the +dynamical/+math/amd.m file, in which the nex file is read and measurements are extracted.
I need to modify this to determine whether a nex file or a spike file is being used.

### Core dynamical functionality
 - [X] dynamical.enums.ParameterAttributes isn't working
   - Fixed by changing ScalarNonEmpty to ScalarNotEmpty, and NonEmpty to NotEmpty
 - [ ] Excel export doesn't work
   - ```Error using xlswrite (line 192)
An error occurred on data export in CSV format.

Error in dynamical.util.save2excel (line 60)
        feval(excelFcn, xlsFileName, [seqTimeRanges, seqAverages], 'Stability', r);

Error in dynamical.ui.objects.AMDParamsPanel/processButtonCallback (line 135)
        dynamical.util.save2excel(fileData.path, stability, amdStruct, hWaitbar, ...

Error in dynamical.ui.objects.AMDParamsPanel/initialize>@(varargin)obj.processButtonCallback(varargin{:}) (line 225)
    'Callback', @obj.processButtonCallback, ...

Caused by:
    Error using dlmwrite (line 104)
    The input cell array cannot be converted to a matrix.```

### Functions I need to make SPIKE2 ports for

These already work fine!
 - [X] opennexfile -> openfile
 - [X] closenexfile -> closefile
 - [ ] readfileheader
 - [ ] listintervalnames
 - [ ] getneurondata
 - [ ] getintervaltimes

 

