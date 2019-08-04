function averaged = averagesequentialbouts(time, data, boutLength)
%AVERAGESEQUENTIALBOUTS Average temporally sequential data points together
%
%   In
%   time (vector, numeric): time
%   data (vector, numeric): data
%   boutLength (scalar, numeric): time difference between sequential points
%   
%   Out
%   averaged (vector, struct): data after averaging sequential points
%   
%   averaged(1-N).seqStart = start time
%   averaged(1-N).seqStop = end time
%   averaged(1-N).seqAverage = average data in [start time, end time]
%   
%   Usage
%   averaged = AVERAGESEQUENTIALBOUTS(time, data, boutLength)

narginchk(3, 3);

validateattributes(time, {'numeric'}, {'vector' 'nonempty' 'increasing'}, mfilename, 'time', 1);
validateattributes(data, {'numeric'}, {'vector' 'nonempty'}, mfilename, 'data', 2);
validateattributes(boutLength, {'numeric'}, {'scalar', 'nonnegative', 'nonzero'}, mfilename, 'boutLength', 3);

assert(length(time) == length(data),...
    'time and data must have same the number of elements');

nElements = length(time);

% find difference between current time and previous time
timeDiffs = zeros(nElements, 1);
for t = 1:nElements
    if t == 1
        timeDiffs(t) = Inf;
    else
        timeDiffs(t) = time(t) - time(t-1);
    end
end

% label each element as belonging to a specific sequential group
seqLabel = 0;
labels = zeros(nElements, 1);
for l = 1:nElements
    diffSameAsBoutLength = fpequal(timeDiffs(l), boutLength);
    
    if l == 1 || ~diffSameAsBoutLength
        seqLabel = seqLabel + 1;
        labels(l) = seqLabel;
    else
        labels(l) = labels(l-1);
    end
end

% average elements that are part of same sequence together
averagedBout = @(start, stop, avg)...
    struct('seqStart', start, 'seqStop', stop, 'seqAverage', avg);

averaged = averagedBout({}, {}, {});

for s = 1:seqLabel
    sequence = (labels == s);
    seqTime = time(sequence);
    seqData = data(sequence);
    
    averaged = [averaged;...
        averagedBout(seqTime(1), seqTime(end), mean(seqData))];
end
end

function equal = fpequal(a, b)
    largest = max(abs(a), abs(b));
    tolerance = eps(largest);
    equal = abs(a - b) <= tolerance;
end

