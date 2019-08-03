function save2excel(nexFileName, stabilityData, amdStruct, hWaitbar, ...
                    stabilityMethod, dateSuffix)
% SAVE2EXCEL  Saves the stability data to an Excel file.
%
%

return

import dynamical.util.averagesequentialbouts;

narginchk(6, 6);

% Windows has built-in Excel writing functionality, while Mac and Linux do
% not.  For Mac and Linux machines, we use an open source library called
% 'xlwrite' from the MATLAB community.  The syntax of the two functions (as
% we use them) are the same.
if ispc
    excelFcn = 'xlswrite';
    addSheetWarningID = 'MATLAB:xlswrite:AddSheet';
else
    excelFcn = 'xlwrite';
    addSheetWarningID = 'xlwrite:AddSheet';
end

% When the function ends or if there is an error, reset the warning setting
% for adding an Excel sheet to what it was prior to calling this function.
warningSetting = warning('query', addSheetWarningID);
warning('off', addSheetWarningID);
cleanupObj = onCleanup(@() warning(warningSetting.state, addSheetWarningID));

% Construct an Excel filename that looks like the .nex filename, but with a
% date appended to the end.  This lets us automatically save multiple
% analyses without nuking prior output.
[p, f] = fileparts(nexFileName);
xlsFileName = fullfile(p, [f dateSuffix '.xlsx']);

dynamical.dprintf(1, '%% Saving %s...', xlsFileName);

nStabilities = numel(stabilityData.data);

switch lower(stabilityMethod)
    case 'neighbor'
        % Stability
        feval(excelFcn, xlsFileName, {'Time (s)' 'Stability'}, 'Stability', 'A1:B1');
        r = sprintf('%s%d:%s%d', 'A', 2, 'B', nStabilities+1);
        feval(excelFcn, xlsFileName, [stabilityData.times' stabilityData.data'], 'Stability', r);
        
        if ishandle(hWaitbar)
            waitbar(0.1667, hWaitbar);
        end
        
        % Mean Sequential Stability
        seqBouts = averagesequentialbouts(stabilityData.times, stabilityData.data, amdStruct.WindowStep);
        
        nSeqBouts = length(seqBouts);
        
        toRangeStr = @(sb) sprintf('%.2f-%.2f', sb.seqStart, sb.seqStop);
        seqTimeRanges = arrayfun(toRangeStr, seqBouts, 'UniformOutput', false);
        seqAverages = num2cell([seqBouts.seqAverage]');
        
        feval(excelFcn, xlsFileName, {'Sequential Time Range', 'Mean Sequential Stability'}, 'Stability', 'D1:E1');
        r = sprintf('%s%d:%s%d', 'D', 2, 'E', nSeqBouts + 1);
        feval(excelFcn, xlsFileName, [seqTimeRanges, seqAverages], 'Stability', r);
        
        if ishandle(hWaitbar)
            waitbar(0.3334, hWaitbar);
        end
        
        % Mean Stability
        r = sprintf('%s%d:%s%d', 'G', 1, 'G', 2);
        feval(excelFcn, xlsFileName, {'Mean Stability';mean(stabilityData.data)}, 'Stability', r);
        
        if ishandle(hWaitbar)
            waitbar(0.5, hWaitbar);
        end
        
    case 'all'
        windowNames = arrayfun(@(x) {sprintf('%d', x)}, 1:size(stabilityData.data, 1));
        nWindowNames = length(windowNames);
        
        % Stability
        feval(excelFcn, xlsFileName, {'Window'}, 'Stability', 'A1:A1');
        es = ExcelCol([1 2 nWindowNames+1]);
        r = sprintf('%s%d:%s%d', es{1}, 2, es{1}, nWindowNames+1);
        feval(excelFcn, xlsFileName, windowNames', 'Stability', r);
        r = sprintf('%s%d:%s%d', es{2}, 1, es{3}, 1);
        feval(excelFcn, xlsFileName, windowNames, 'Stability', r);
        if ishandle(hWaitbar)
            waitbar(0.25, hWaitbar);
        end
        r = sprintf('%s%d:%s%d', es{2}, 2, es{3}, nWindowNames+1);
        feval(excelFcn, xlsFileName, stabilityData.data, 'Stability', r);
        if ishandle(hWaitbar)
            waitbar(0.5, hWaitbar);
        end
        
    otherwise
        error('Excel export for method "%s" not implemented yet', stabilityMethod);
end

o = 0;

paramsList = fieldnames(amdStruct);
nParams = length(paramsList);
for i = 1:nParams
    paramName = paramsList{i};
    paramValue = amdStruct.(paramName);
    
    if isrow(paramValue)
        paramValue = paramValue';
    end
    
    colStart = o + i;
    colEnd = colStart;
    rowStart = 1;
    rowEnd = length(paramValue) + 1;
    
    es = ExcelCol([colStart colEnd]);
    rangeString = sprintf('%s%d:%s%d', es{1}, rowStart, es{2}, rowEnd);
    
    if isstring(paramValue)
        paramValue = cellstr(paramValue);
    elseif ishandle(paramValue)
        paramValue = true;
    end
    
    if iscell(paramValue)
        rangeData = [paramName ; paramValue];
    else
        rangeData = {paramName ; paramValue};
    end
    
    feval(excelFcn, xlsFileName, rangeData, 'Meta', rangeString);
    
    if ishandle(hWaitbar)
        waitbar(0.5 + i/nParams/2, hWaitbar);
    end
end

dynamical.dprintf(1, 'Done\n');
