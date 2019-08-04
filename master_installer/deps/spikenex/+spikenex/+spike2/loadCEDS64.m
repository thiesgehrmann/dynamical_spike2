function loadCEDS64()
% loadCEDS64  Load the CEDS64 library
%
% Syntax:
% OPENFILE(spike2FileName)
% 
%
% Description:
% loadCEDS64  load the CEDS64 library, if it exists, and if it is not yet loaded

% Throws:
% spike2:loadCEDS64:EnvironmentVariableEmpty : CEDS64ML environment variable is not set
% spike2:loadCEDS64:LibraryAbsent : Library not installed a specified location

%% Here load the CEDMAT library
if ~libisloaded('ceds64int')

	cedpath = getenv('CEDS64ML');
	
	assert(~isempty(cedpath), 'spike2:loadCEDS64:EnvironmentVariableEmpty', 'Please set the CEDS64ML environment variable.');

	machine = computer('arch');
	if (strcmp(machine,'win32'))
	    assert(isfile(strcat(cedpath, '\x86\ceds64int.dll')), 'spike2:loadCEDS64:LibraryAbsent', "The CEDS library is not installed at the specified location: %s", cedpath)
	else
	    assert(isfile(strcat(cedpath, '\x64\ceds64int.dll')), 'spike2:loadCEDS64:LibraryAbsent', "The CEDS library is not installed at the specified location: %s", cedpath)
	end

	addpath(cedpath)
	CEDS64LoadLib(cedpath)
end


