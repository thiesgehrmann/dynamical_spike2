function [ timecodes ] = getneurondatachannel(input1, channelid)
% GETNEURONDATACHANNEL  Extracts the data for neurons from a specified channel in a SPIKE2 data/file.
%
% Syntax:
% % Get all neuron data from a single channel.
% neuronTable = GETNEURONDATACHANNEL(spikeFileName, channel)
% ___ = GETNEURONDATACHANNEL(fileID, channel)
%
% Description:
% Extracts all the data for neurons in a channel from a SPIKE2 file.
%  All available information about the neurons is returned in
%  a table format. Further, if a filename is specified, it
%  saves the result of this extraction to '/filename/.getneurondatachannel./channelid/.mat'
%
% Input:
% spikeFileName (string) - The name of the SPIKE2 file to read.
% fileID (number) - A file ID to a previously opened SPIKE2 file via fopen.
% channel (int) - Numeric indices of specific neurons to read.
%
% Output:
% neuronTable (table) - Table of extracted neuron data.  Each column
%     corresponds to a field found in the raw neuron data.
%
%     Variables:
%     * name (categorical)
%     * varVersion (scalar) NOTE: This variable means NOTHING in SPIKE2
%     * wireNumber (scalar) NOTE: This variable means NOTHING in SPIKE2
%     * unitNumber (scalar) NOTE: This variable means NOTHING in SPIKE2
%     * xPos (scalar)       NOTE: This variable means NOTHING in SPIKE2
%     * yPos (scalar)       NOTE: This variable means NOTHING in SPIKE2
%     * timestamps (cell) - Contains a Mx1 array of the timestamp data.


%% Setup
% Check our input and prepare the SPIKE2 file.
narginchk(2, 2);

% Open the SPIKE2 file.
[fh, wasOpened] = openfile(input1);

savefilename = "";

if wasOpened
	savefilename = sprintf("%s.getneurondatachannel.%d.mat", input1, channelid);
	if isfile(savefilename)
		fprintf("Loading pre-processed from %s\n", savefilename);
		timecodes = load(savefilename);
		return
	end
  cleanupObj = onCleanup(@() closefile(fh));
end

% Initialize the data storage
stepsize  = 10000;
starttime = 0;
code = [];
time = [];
updatelength = 0;

maxtime = CEDS64ChanMaxTime(fh, channelid);

while 1

	[im, em] = CEDS64ReadMarkers(fh, channelid, stepsize, starttime);

	if im == 0
		break
	end
	
	newcode = cat(1, em.m_Code1);
	newtime = cat(1, em.m_Time);

	starttime = max(newtime)+1; % So we don't get overlapping segments

	code = cat(1, code, newcode);
	time = cat(1, time, newtime);
    
  for i = 1:updatelength
      fprintf('\b')
  end

  updatelength = fprintf('Reading channel %d [%d%%]', channelid, starttime*100/maxtime);

	if im < stepsize
		break;
	end

end

time = arrayfun(@(t) CEDS64TicksToSecs(fh, t), time);

uc = unique(code);
timecodes.name       = arrayfun(@(nid) sprintf("chan_%d_code_%d", channelid, nid), uc);
timecodes.varVersion = zeros(size(uc));
timecodes.wireNumber = zeros(size(uc));
timecodes.unitNumber = ones(size(uc));
timecodes.xPos       = zeros(size(uc));
timecodes.yPos       = ones(size(uc));
timecodes.timestamps = arrayfun(@(nid) time(find(code == nid)),uc,'UniformOutput',false);

if wasOpened
	fprintf("\nSaving channel %d to to %s\n", channelid, savefilename);
	save(savefilename, '-struct', 'timecodes');
end