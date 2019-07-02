function clearsheet(xlsFilename, sheetName)

% Retrieve sheet names 
[~, sheetNames] = xlsfinfo(xlsFilename);

% Look to see if the sheet exists in the file already.
if any(strcmp(sheetName, sheetNames))
    % Open Excel as a COM Automation server
    Excel = actxserver('Excel.Application');
    
    % Open Excel workbook
    Workbook = Excel.Workbooks.Open(xlsFilename);
    
    % Clear the content of the sheets (from the second onwards)
    Excel.ActiveWorkBook.Sheets.Item(sheetName).Cells.Clear;
    
    % Now save/close/quit/delete
    Workbook.Save;
    Excel.Workbook.Close;
    invoke(Excel, 'Quit');
    delete(Excel);
end