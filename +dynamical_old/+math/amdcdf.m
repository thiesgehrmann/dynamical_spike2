function [F, X, flatData] = amdcdf(A, xlsFilename, overwrite)
% AMDCDF  Calculates the empirical CDF for an aggregate set of AMD values.
%
% Syntax:
% % Basic processing
% [F, X, flatData] = AMDCDF(amdWindows)
% [___] = AMDCDF(amdMATfile)
%
% % Excel (.xlsx) output
% [___] = AMDCDF(___, xlsFilename)
% [___] = AMDCDF(___, xlsFilename, overwrite)
%
% Description:
% Calculates the empirical cumulative distribution function of the AMD data
% in a set of AMD windows.  All AMD calculations in all specified AMD
% windows are aggregated together (diagonals are not included) and
% processed using the 'ecdf' function from the Statistics and Machine
% Learning toolbox.
%
% Input:
% amdWindows (dynamical.math.AMDWindow array) - Array of AMDWindows to
%     process.  The AMDWindows should have already been processed by the
%     dynamical.math.amd function.
% amdMATfile (string) - Name of the .mat file containing the amdWindows
%     array.  This file is generated by any of the dynamical top level
%     processing functions, e.g. dynamical or dynamical_cli.
% xlsFilename (string) - The name of the .xlsx output file that will
%     contain the ECDF output data.  If not specified, then no data is
%     saved to disk.
% overwrite (logical) - If true, delete the old Excel file and create a new
%     one with only the 'CDF' analysis sheet.  If false, the file isn't
%     deleted, but the old 'CDF' sheet is still removed and created again
%     with the newly calculated data, i.e. all other sheets are untouched.
%     Default: false
%
% Output:
% F (array) - The ECDF evaluated at the points in X using AMD window data.
% X (array) - Distinct observed points in the AMD window data.
% flatData (array) - The data supplied to the 'ecdf' function to generate
%     'F' and 'X'.  This is the aggregate of all the AMD analysis values
%     across all specified AMD windows (diagonals excluded) and flattened
%     to a single array.  The values are NOT sorted.

narginchk(1, 3);

% Process the input variable and handle it differently depending on its
% type.  If it's a string, we assume it's a .mat filename.  If it's a type
% AMDWindow, we copy it directly.  Ultimately, we want the amdWindows array
% to process.
if isa(A, 'dynamical.math.AMDWindow')
    amdWindows = A;
elseif ischar(A)
    % Attempt to load the .mat file, specifically the amdWindows variable.
    load(A, 'amdWindows');
else
    error('Unhandled input type %s', class(A));
end

if nargin < 2
    xlsFilename = [];
end

if nargin < 3
    overwrite = false;
end

% The number of AMDWindows
nWindows = length(amdWindows);

% We'll store the flattened AMD matrices for each AMD window here.
flatAMDs = cell(1, nWindows);
flatZScores = cell(1, nWindows);

for i = 1:nWindows
    % Pull out the window's AMD data into a matrix.
    rawAMD = amdWindows(i).AMD{:,:};
    rawZScore = amdWindows(i).ZScore{:,:};
    
    % Find all the indices of the diagonal.
    iDiag = 1:size(rawAMD,2)+1:numel(rawAMD);
    
    % Set all the diagonal entries to empty.  This has the side effect of
    % collapsing the 2D matrix into an array (without the diagonal values).
    rawAMD(iDiag) = [];
    rawZScore(iDiag) = [];
    
    % Store the flattened data for later processing.
    flatAMDs{i} = rawAMD;
    flatZScores{i} = rawZScore;
end

% Convert all the cells into a single flattened array.
flatAMD = cell2mat(flatAMDs);
flatZScores = cell2mat(flatZScores);

% We might need to remove NaNs, but for now throw an error as I don't think
% they should ever be in the amd data.
assert(~any(isnan(flatAMD)), 'Unexpected NaN values found in the flattened amd data.');
assert(~any(isnan(flatZScores)), 'Unexpected NaN values found in the flattened zscore data.');

% Run the ECDF calculations.
F = cell(1, 2);
X = cell(1, 2);
[F{1}, X{1}] = ecdf(flatAMD);
[F{2}, X{2}] = ecdf(flatZScores);
flatData = {flatAMD, flatZScores};

% If the xls filename is specified, then we'll attempt to save the results
% to the specified Excel file.
if ~isempty(xlsFilename)
    % Until I implement MAC functionality for sheet deletion, we'll limit
    % this part to PC only.
    assert(ispc, 'This function is PC only (no Linux or Mac).');
    
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
    
    % Construct a proper filename.  The user may have not specified an
    % extension or possibly used the old one '.xls'.  To take advantage of
    % larger data sets, we'll need to make sure we're saving to an '.xlsx'
    % file.
    [p, n] = fileparts(xlsFilename);
    xlsFilename = fullfile(p, [n '.xlsx']);
    
    % Look to see if the filename already exists.  If it does, then we'll
    % clear the 'CDF' sheet prior to creating a new one.
    targetSheet = 'CDF';
    newFile = false;
    if exist(xlsFilename, 'file')
        if overwrite
            delete(xlsFilename);
            newFile = true;
        else
            dynamical.util.clearsheet(xlsFilename, targetSheet);
        end
    else
        newFile = true;
    end
    
    feval(excelFcn, xlsFilename, {'AMD_X' 'AMD_Y' 'ZScore_X' 'ZScore_Y'}, ...
        targetSheet, 'A1:D1');
    
    for i = 1:length(F)
        rowEnd = length(F{i}) + 1;
        cols = ExcelCol((1:2) + (i-1)*2);
        
        feval(excelFcn, xlsFilename, [X{i} F{i}], targetSheet, ...
            sprintf('%s2:%s%d', cols{1}, cols{2}, rowEnd));
    end
    
    % Delete the default 'Sheet1' if we created a new file.
    if newFile
        xls_delete_sheets(xlsFilename, 'Sheet1');
    end
end
