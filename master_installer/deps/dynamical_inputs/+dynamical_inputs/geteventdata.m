function eventTable = geteventdata(input1)
% GETEVENTDATA  Gets event data from a NEX file.
%
% Syntax:
% eventData = GETEVENTDATA(nexFileName)
% eventData = GETEVENTDATA(fileID)
%
% Description:
% Reads the event data from a NEX file.  Each element of the event data
% contains the event's name and its timestamps.
%
% Input:
% nexFileName (string) - The name of the NEX file to read.
% fileID (integer) - A file ID to a previously opened NEX file via fopen.
%
% Output:
% eventData (table) - The event data where each row contains an individual
%     event's data.

%% Setup
% Check our input and prepare the NEX file.
switch dynamical_inputs.determine_input_type(input1)
    case 'NEX'
        eventTable = dynamical_inputs.nex.geteventdata(input1);
    case 'SPIKE'
        eventTable = dynamical_inputs.spike2.geteventdata(input1);
    case 'MAT'
        eventTable = dynamical_inputs.mat.geteventdata(input1);
    otherwise
        assert(false, 'dynamical_inputs:geteventdata:InvalidFileType', "You must specify a NEX, SPIKE2 or MAT file as input.")
end