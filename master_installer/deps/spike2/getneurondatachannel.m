function [ timecodes ] = getNeuronDataChannel(input1, channelid)



%% Setup
% Check our input and prepare the SPIKE2 file.
narginchk(2, 2);

% Open the SPIKE2 file.
[fh, wasOpened] = openfile(input1);

% Initialize the data storage
stepsize  = 10000;
starttime = 0;
code = [];
time = [];
update = "";

maxtime = CEDS64ChanMaxTime(fh, channelid);

while 1

	[im, em] = CEDS64ReadMarkers(fh, channelid, stepsize, starttime);
	
	newcode = cat(1, em.m_Code1);
	newtime = cat(1, em.m_Time);

	starttime = max(newtime);

	code = cat(1, code, newcode);
	time = cat(1, time, newtime);
    
  for i = 1:strlength(update)
      fprintf('\b')
  end
  update = sprintf("Reading channel %d [%d]", channelid, starttime*100/maxtime);
  fprintf(update)
	
	if im < stepsize
		break;
	end

end

time = arrayfun(@(t) CEDS64TicksToSecs(fh, t), time);

uc = unique(code);
timecodes.name       = arrayfun(@(nid) sprintf("chan%dcode%d", 30, nid), uc);
timecodes.varVersion = zeros(size(uc));
timecodes.wireNumber = zeros(size(uc));
timecodes.unitNumber = zeros(size(uc));
timecodes.xPos       = zeros(size(uc));
timecodes.yPos       = zeros(size(uc));
timecodes.timestamps = arrayfun(@(nid) time(find(code == nid)),uc,'UniformOutput',false);
