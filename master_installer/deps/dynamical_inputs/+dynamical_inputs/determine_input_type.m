function dtype = determine_input_type(input1)
% determine_input_type  Checks if a filename or file handle is NEX or SPIKE2 or MAT
%
% Syntax:
% determine_input_type(filename)
% determine_input_type(fileID)
% determine_input_type(table)

%
% Description:
% Checks if a filename or file handle is NEX or SPIKE2
%
% Input:
% filename (string) - A file path
% fileID (integer) - A file ID to a previously opened file
% table (table) - a table data structure from a MATLAB file.
%
% Output:
% dtype (string) - [MAT|SPIKE|NEX]
%
% Throws:
% spikenex:isnex:None - File/file handle is neither NEX, SPIKE2, nor MAT

	if ischar(input1) || isstring(input1)
	    [filepath, name, ext] = fileparts(input1);
	    ext = lower(ext);
	    if ismember(ext, ['.mat'])
	    	dtype = 'MAT';
	    elseif ismember(ext, ['.nex'])
	    	dtype = 'NEX';
	    elseif ismember(ext, ['.smrx', '.smr'])
	    	dtype = 'SPIKE';
	    else
	    	throw(MException("spikenex:isnex:None", "Specified file is neither NEX nor SPIKE2"));
	    end
	elseif dynamical_inputs.mat.verify_struct(input1)
		dtype = 'MAT';
	else
	    spikenex.spike2.loadCEDS64
	    if CEDS64IsOpen(input1)
	    	dtype = 'SPIKE';
	    else
	    	dtype = 'NEX';
	    end
	end
