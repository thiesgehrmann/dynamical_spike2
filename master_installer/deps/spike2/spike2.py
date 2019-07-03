import neo

def getintervaltimes(input1, intervalName, isCaseSensitive):
    """
     GETINTERVALTIMES  Gets interval data from a NEX file.
    
     Syntax:
     intervalTable = GETINTERVALTIMES(nexFileName, intervalName)
     ___ = GETINTERVALTIMES(fileID, intervalName)
     ___ = GETINTERVALTIMES(___, isCaseSensitive)
    
     Description:
     Read the interval table (start/stop times) from a nex file for a
     specified interval.
    
     Input:
     nexFileName (string) - The name of the NEX file to read.
     fileID (integer) - A file ID to a previously opened NEX file via fopen.
     intervalName (string) - The name of the interval to extract.
     isCaseSensitive (logical) - If true, we do a case sensitive search for
         the interval name.  Default: false
    
     Output:
     intervalTable (table) - A table of the start and end times for all
         intervals matching the interval type.  As a convenience, the duration
         of each interval (row) is added as a 3rd column to the table.
    
     Examples:
     % Get REM interval times (case insensitive).
     intervalTable = GETINTERVALTIMES('C:\datafile.nex', 'REM')
    
     % Get REM interval times (case sensitive).
     intervalTable = GETINTERVALTIMES('C:\datafile.nex', 'Rem', true);  
    """
    pass
#edef

def getneurondata(input1, indices):
    """
    GETNEURONDATA  Extracts the data for specified neurons from NEX data/file.
    
    Syntax:
    % Get all neuron data.
    neuronTable = GETNEURONDATA(nexFileName)
    ___ = GETNEURONDATA(fileID)
    ___ = GETNEURONDATA(___, indices)
    
    Description:
    Extracts all the data for specified neurons from a NEX file or a NEX
    data struct.  All available information about the neurons is returned in
    a table format.
    
    Input:
    nexFileName (string) - The name of the NEX file to read.
    fileID (number) - A file ID to a previously opened NEX file via fopen.
    indices (vector) - Numeric indices of specific neurons to read.
    
    Output:
    neuronTable (table) - Table of extracted neuron data.  Each column
        corresponds to a field found in the raw neuron data.
    
        Variables:
        * name (categorical)
        * varVersion (scalar)
        * wireNumber (scalar)
        * unitNumber (scalar)
        * xPos (scalar)
        * yPos (scalar)
        * timestamps (cell) - Contains a Mx1 array of the timestamp data.
    """
    pass
#edef

def listintervalnames(input1):
    """
    LISTINTERVALNAMES  Lists the interval names found in the NEX data or file.
    
    Syntax:
    intervalTypes = LISTINTERVALNAMES(nexFileName)
    intervalTypes = LISTINTERVALNAMES(fileID)
    
    Description:
    Gets a list of the interval names found in the nex data/file.
    
    Input:
    nexFileName (1xN char) - The name of the NEX file to read.
    fileID (integer) - A file ID to a previously opened NEX file via fopen.
    
    Output:
    intervalNames (string array) - String array where each element is the
        name of an interval.

    """
    pass
#edef

def readfileheader(input1):
    """
    READFILEHEADER  Reads the file header information from a NEX file.
    
    Syntax:
    fileHeader = READFILEHEADER(nexFileName)
    fileHeader = READFILEHEADER(fileID);
    
    Description:
    Extracts the top level header file information from a NEX file.
    
    Input:
    nexFileName (string) - The name of the NEX file from which to
        extract the header.
    fileID (integer) - A file ID to a previously opened NEX file via fopen.
    
    Output:
    fileHeader (struct) - The header information from the NEX file.
        Fields:
        version (scalar) - NEX file version
        comment (string) - File comment
        freq (scalar) - Timestamp frequency (Hz)
        tbeg (scalar) - Minimum timestamp (s)
        tend (scalar) - Maximum timestamp (s)
        numvars (scalar) - The number of variables in the file.
    
    Throws:
    nex:getfileheader:InvalidNEXFile - File specified is not a NEX file.
    
    Examples:
    % Read header data by specifiying the file name.
    fileHeader = getfileheader('myfilename.nex');
    
    % Read header data by specifying a file ID.
    fid = fopen('myfilename.nex', 'r', 'l', 'US-ASCII');
    fileHeader = getfileheader('myfilename.nex');
    """
    pass
#edef

