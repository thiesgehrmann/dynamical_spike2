function nex = isnex(input1)
% ISNEX  Checks if a filename or file handle is NEX or SPIKE2
%
% Syntax:
% ISNEX(filename)
% ISNEX(fileID)
%
% Description:
% Checks if a filename or file handle is NEX or SPIKE2
%
% Input:
% filename (string) - A file path
% fileID (integer) - A file ID to a previously opened file
%
% Output:
% nex (logical) - True if file/file handle is NEX, False if it is SPIKE2
%
% Throws:
% spikenex:isnex:Neither - File/file handle is neither NEX or SPIKE2

	if ischar(input1) || isstring(input1)
	    [filepath, name, ext] = fileparts(input1);
	    ext = lower(ext);
	    if ismember(ext, ['.nex'])
	    	nex = true;
	    elseif ismember(ext, ['.smrx', '.smr'])
	    	nex = false;
	    else
	    	throw(MException("spikenex:isnex:Neither", "Specified file is neither NEX nor SPIKE2"));
	    end
	else
	    spikenex.spike2.loadCEDS64
	    if CEDS64IsOpen(input1)
	    	nex = false;
	    else
	    	nex = true;
	    end
	end
