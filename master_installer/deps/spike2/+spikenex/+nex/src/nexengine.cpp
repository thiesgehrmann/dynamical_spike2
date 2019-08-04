#include "nexengine.h"

// Global string variables we use for structure definitions.  We do this to
// avoid recreating the same structure headers over and over.
char **g_fileHeaderFields,
     **g_eventFields,
     **g_markerFields,
     **g_markerValueFields,
     **g_continuousFields,
     **g_varHeaderFields;


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    unsigned int opCode;
    FILE *fp;
    char fileName[256];
    int variableType = -1;
    static bool isInit = false;

    // Do any initialization if we haven't done so yet.
    if (isInit == false) {
        mexPrintf("- Initializing NEX Engine.\n");

        // Setup the 2D char array we use for the mxArray structs.
        initGlobalStructFields();

        // Register the mex exit function.
        mexAtExit(cleanup);

        isInit = true;
    }

    if (nrhs == 0) {
        barf("Usage: nexengine(opCode, args)");
    }

    // Grab the opcode.
    opCode = (unsigned int)mxGetScalar(prhs[0]);

    switch (opCode) {
        // Read the continuous data.
        case GetContinuous:
            variableType = NEX_VARIABLE_TYPE_CONTINUOUS;

            NexFileHeader fileHeader;

            CHECKARGCOUNT(1);

            // Make sure the file argument is a string.
            bool isChar = mxIsChar(prhs[1]);
            if (!isChar) {
                barf("NEXENGINE:GetContinous:File name must be a string.");
            }

            // Extract the filename.
            if (mxGetString(prhs[1], fileName, 256)) {
                barf("NEXENGINE:GetContinous:Failed to extract the file name.");
            }

            // Open up the nex file.
            fp = fopen(fileName, "rb");
            if (fp == NULL) {
                barf("NEXENGINE:GetContinous:Failed to open file.");
            }

            // Read the file header.
            fread(&fileHeader, sizeof(NexFileHeader), 1, fp);

            plhs[0] = readVariableData(fp, &fileHeader, NEX_VARIABLE_TYPE_CONTINUOUS);

            // Close the NEX file.
            fclose(fp);

            break;
        }

        // Read the markers.
        case GetMarkers:
        {
            NexFileHeader fileHeader;

            CHECKARGCOUNT(1);

            // Make sure the file argument is a string.
            bool isChar = mxIsChar(prhs[1]);
            if (!isChar) {
                barf("NEXENGINE:GetMarkers:File name must be a string.");
            }

            // Extract the filename.
            if (mxGetString(prhs[1], fileName, 256)) {
                barf("NEXENGINE:GetMarkers:Failed to extract the file name.");
            }

            // Open up the nex file.
            fp = fopen(fileName, "rb");
            if (fp == NULL) {
                barf("NEXENGINE:GetMarkers:Failed to open file.");
            }

            // Read the file header.
            fread(&fileHeader, sizeof(NexFileHeader), 1, fp);

            plhs[0] = readVariableData(fp, &fileHeader, NEX_VARIABLE_TYPE_MARKER);

            // Close the NEX file.
            fclose(fp);

            break;
        }

        // Read the events.
        case GetEvents:
        {
            NexFileHeader fileHeader;

            CHECKARGCOUNT(1);

            // Make sure the file argument is a string.
            bool isChar = mxIsChar(prhs[1]);
            if (!isChar) {
                barf("NEXENGINE:GetEvents:File name must be a string.");
            }

            // Extract the filename.
            if (mxGetString(prhs[1], fileName, 256)) {
                barf("NEXENGINE:GetEvents:Failed to extract the file name.");
            }

            // Open up the nex file.
            fp = fopen(fileName, "rb");
            if (fp == NULL) {
                barf("NEXENGINE:GetEvents:Failed to open file.");
            }

            // Read the file header.
            fread(&fileHeader, sizeof(NexFileHeader), 1, fp);

            plhs[0] = readVariableData(fp, &fileHeader, NEX_VARIABLE_TYPE_EVENT);

            // Close the NEX file.
            fclose(fp);

            break;
        }

        // Read the file header.
        case GetHeader:
        {
            NexFileHeader fileHeader;

            CHECKARGCOUNT(1);

            // Make sure the file argument is a string.
            bool isChar = mxIsChar(prhs[1]);
            if (!isChar) {
                barf("NEXENGINE:GetHeader:File name must be a string.");
            }

            // Extract the filename.
            if (mxGetString(prhs[1], fileName, 256)) {
                barf("NEXENGINE:GetHeader:Failed to extract the file name.");
            }

            // Open up the nex file.
            fp = fopen(fileName, "rb");
            if (fp == NULL) {
                barf("NEXENGINE:GetHeader:Failed to open file.");
            }

            // Read the header.
            fread(&fileHeader, sizeof(NexFileHeader), 1, fp);

            // Close the file.
            fclose(fp);

            plhs[0] = packFileHeaderData(&fileHeader);

            break;
        }

        default:
            barf("NEXENGINE:Unknown opcode %d\n", opCode);
    }
}


void initGlobalStructFields(void)
{
    static bool isInit = false;

    // If this function hasn't been called before, initialize the global strings.
    if (!isInit) {
        // Create the file header field strings.
        g_fileHeaderFields = (char**)mxMalloc(sizeof(char*) * NUM_FILE_HEADER_FIELDS);
        mexMakeMemoryPersistent(g_fileHeaderFields);
        for (int i = 0; i < NUM_FILE_HEADER_FIELDS; i++) {
            g_fileHeaderFields[i] = (char*)mxMalloc(sizeof(char) * 32);
            mexMakeMemoryPersistent(g_fileHeaderFields[i]);
        }
        sprintf(g_fileHeaderFields[0], "version");
        sprintf(g_fileHeaderFields[1], "comment");
        sprintf(g_fileHeaderFields[2], "freq");
        sprintf(g_fileHeaderFields[3], "tbeg");
        sprintf(g_fileHeaderFields[4], "tend");
        sprintf(g_fileHeaderFields[5], "numvars");
        
        // Create the structure headers for an event variable.
        g_eventFields = (char**)mxMalloc(sizeof(char*) * NUM_EVENT_FIELDS);
        mexMakeMemoryPersistent(g_eventFields);
        for (int i = 0; i < NUM_EVENT_FIELDS; i++) {
            g_eventFields[i] = (char*)mxMalloc(sizeof(char) * 32);
            mexMakeMemoryPersistent(g_eventFields[i]);
        }
        sprintf(g_eventFields[0], "name");
        sprintf(g_eventFields[1], "varVersion");
        sprintf(g_eventFields[2], "timestamps");
        
        // Create the structure headers for a marker variable.
        g_markerFields = (char**)mxMalloc(sizeof(char*) * NUM_MARKER_FIELDS);
        mexMakeMemoryPersistent(g_markerFields);
        for (int i = 0; i < NUM_MARKER_FIELDS; i++) {
            g_markerFields[i] = (char*)mxMalloc(sizeof(char) * 32);
            mexMakeMemoryPersistent(g_markerFields[i]);
        }
        sprintf(g_markerFields[0], "name");
        sprintf(g_markerFields[1], "varVersion");
        sprintf(g_markerFields[2], "timestamps");
        sprintf(g_markerFields[3], "values");
        
        // Create the structure headers for a marker variable's values field.
        g_markerValueFields = (char**)mxMalloc(sizeof(char*) * NUM_MARKER_VALUE_FIELDS);
        mexMakeMemoryPersistent(g_markerValueFields);
        for (int i = 0; i < NUM_MARKER_VALUE_FIELDS; i++) {
            g_markerValueFields[i] = (char*)mxMalloc(sizeof(char) * 32);
            mexMakeMemoryPersistent(g_markerValueFields[i]);
        }
        sprintf(g_markerValueFields[0], "name");
        sprintf(g_markerValueFields[1], "strings");
        
        // Create the structure headers for a marker variable.
        g_continuousFields = (char**)mxMalloc(sizeof(char*) * NUM_CONTINUOUS_FIELDS);
        mexMakeMemoryPersistent(g_continuousFields);
        for (int i = 0; i < NUM_CONTINUOUS_FIELDS; i++) {
            g_continuousFields[i] = (char*)mxMalloc(sizeof(char) * 32);
            mexMakeMemoryPersistent(g_continuousFields[i]);
        }
        sprintf(g_continuousFields[0], "name");
        sprintf(g_continuousFields[1], "varVersion");
        sprintf(g_continuousFields[2], "ADtoMV");
        sprintf(g_continuousFields[3], "MVOffset");
        sprintf(g_continuousFields[4], "ADFrequency");
        sprintf(g_continuousFields[5], "timestamps");
        sprintf(g_continuousFields[6], "fragmentStarts");
        sprintf(g_continuousFields[7], "data");
        
        // Create the variable headers field strings.
        g_varHeaderFields = (char**)mxMalloc(sizeof(char*) * NUM_VAR_HEADER_FIELDS);
        mexMakeMemoryPersistent(g_varHeaderFields);
        for (int i = 0; i < NUM_VAR_HEADER_FIELDS; i++) {
            g_varHeaderFields[i] = (char*)mxMalloc(sizeof(char) * 32);
            mexMakeMemoryPersistent(g_varHeaderFields[i]);
        }
        sprintf(g_varHeaderFields[0], "type");
        sprintf(g_varHeaderFields[1], "version");
        sprintf(g_varHeaderFields[2], "name");
        sprintf(g_varHeaderFields[3], "dataOffset");
        sprintf(g_varHeaderFields[4], "count");
        sprintf(g_varHeaderFields[5], "wireNumber");
        sprintf(g_varHeaderFields[6], "unitNumber");
        sprintf(g_varHeaderFields[7], "gain");
        sprintf(g_varHeaderFields[8], "filter");
        sprintf(g_varHeaderFields[9], "xPos");
        sprintf(g_varHeaderFields[10], "yPos");
        sprintf(g_varHeaderFields[11], "WFrequency");
        sprintf(g_varHeaderFields[12], "ADtoMV");
        sprintf(g_varHeaderFields[13], "NPointsWave");
        sprintf(g_varHeaderFields[14], "nMarkers");
        sprintf(g_varHeaderFields[15], "markerLength");
        sprintf(g_varHeaderFields[16], "MVOffset");
        sprintf(g_varHeaderFields[17], "prethresholdTimeInSeconds");
        
        // Indicate that init was run so that the next time this function is called
        // it won't run the string initialization.
        isInit = true;
    }
}


mxArray* readMarkerVariable(FILE* fp, NexVarHeader *markerHeader, NexFileHeader *fileHeader)
{
    mxArray *markerStruct;

    // Allocate memory for the timestamps.
    std::vector<int> timestamps;
    timestamps.resize(markerHeader->Count);

    // Find the start of the marker variable data.
    fseek(fp, markerHeader->DataOffset, SEEK_SET);

    // Read the marker timestamps.
    fread(&timestamps[0], markerHeader->Count * 4, 1, fp);

    // Create a vector to hold the field names.
    std::vector <std::string> fieldNames;
    fieldNames.resize(markerHeader->NMarkers);

    // Create a vector to hold the field values.
    std::vector <std::vector<std::string> > fieldValues;
    fieldValues.resize(markerHeader->NMarkers);

    // Temp char vectors we will use to read into.
    std::vector<char> fieldName;
    std::vector<char> buf;

    // Read the marker field names and values
    for (int field = 0; field < markerHeader->NMarkers; field++) {
        // read the name of the data field
        fieldName.resize(65, 0);
        fread(&fieldName[0], 64, 1, fp);
        fieldNames[field] = (const char*)&fieldName[0];
        for (int j = 0; j < markerHeader->Count; j++) {
            // Read the field value for the j-th timestamp.
            buf.resize(markerHeader->MarkerLength + 1, 0);
            fread(&buf[0], markerHeader->MarkerLength, 1, fp);
            std::string s = (const char*)&buf[0];
            fieldValues[field].push_back(s);
        }
    }

    // Create the marker struct.
    markerStruct = mxCreateStructMatrix(1, 1, NUM_MARKER_FIELDS, (const char**)g_markerFields);

    // Stick the marker name and version info into the struct.
    mxSetField(markerStruct, 0, "name", mxCreateString(markerHeader->Name));
    mxSetField(markerStruct, 0, "varVersion", mxCreateDoubleScalar(markerHeader->Version));

    // Stick the timestamps into the struct.  First we must convert the values
    // into seconds.
    mxArray *tstamps = mxCreateDoubleMatrix(timestamps.size(), 1, mxREAL);
    double *t = mxGetPr(tstamps);
    for (size_t i = 0; i < timestamps.size(); i++) {
        t[i] = (double)timestamps[i] / (double)fileHeader->Frequency;
    }
    mxSetField(markerStruct, 0, "timestamps", tstamps);

    // Loop over all the values and stick them in a cell array.  Insert the
    // cell array into the main marker struct.
    mxArray *valueCell = mxCreateCellMatrix(fieldNames.size(), 1);
    for (size_t i = 0; i < fieldNames.size(); i++) {
        // Create a marker value struct.
        mxArray *valueStruct = mxCreateStructMatrix(1, 1, NUM_MARKER_VALUE_FIELDS, (const char**)g_markerValueFields);

        // Set the marker value name.
        mxSetField(valueStruct, 0, "name", mxCreateString(fieldNames[i].c_str()));

        // Get all the value strings and stick them in a cell array.
        mxArray *stringsCell = mxCreateCellMatrix(timestamps.size(), 1);
        for (size_t j = 0; j < timestamps.size(); j++) {
            mxSetCell(stringsCell, j, mxCreateString(fieldValues[i][j].c_str()));
        }
        mxSetField(valueStruct, 0, "strings", stringsCell);

        // Insert the marker value into the value cell array.
        mxSetCell(valueCell, i, valueStruct);
    }
    mxSetField(markerStruct, 0, "values", valueCell);

    return markerStruct;
}


mxArray* packFileHeaderData(NexFileHeader *fileHeader)
{
    // Create the MATLAB struct to hold the header data.
    mxArray *headerStruct = mxCreateStructMatrix(1, 1, NUM_FILE_HEADER_FIELDS, (const char**)g_fileHeaderFields);

    // Stuff the header data into the struct.  Divide the start/stop times by the
    // frequency to put them in seconds.
    mxSetField(headerStruct, 0, "version", mxCreateDoubleScalar(fileHeader->NexFileVersion));
    mxSetField(headerStruct, 0, "comment", mxCreateString(fileHeader->Comment));
    mxSetField(headerStruct, 0, "tbeg", mxCreateDoubleScalar((double)fileHeader->Beg / (double)fileHeader->Frequency));
    mxSetField(headerStruct, 0, "tend", mxCreateDoubleScalar((double)fileHeader->End / (double)fileHeader->Frequency));
    mxSetField(headerStruct, 0, "freq", mxCreateDoubleScalar(fileHeader->Frequency));
    mxSetField(headerStruct, 0, "numvars", mxCreateDoubleScalar(fileHeader->NumVars));

    return headerStruct;
}


mxArray * packVarHeaderData(NexVarHeader *varHeader)
{
    // Create the MATLAB struct to hold the header data.
    //mxArray headerStruct = mxCreateStructMatrix(1, )
}


mxArray* readEventVariable(FILE *fp, NexVarHeader *eventHeader, NexFileHeader *fileHeader)
{
    std::vector<int> timestamps;
    mxArray *eventStruct,
            *matTimeStamps;
    double *t;

    // Resize the vector to the number of event timestamps.
    timestamps.resize(eventHeader->Count);

    // Create the MATLAB struct to hold the event data.
    eventStruct = mxCreateStructMatrix(1, 1, NUM_EVENT_FIELDS, (const char**)g_eventFields);

    // Find the start of data.
    fseek(fp, eventHeader->DataOffset, SEEK_SET);

    // read the timestamps, 4 bytes per timestamp
    fread(&timestamps[0], eventHeader->Count * 4, 1, fp);

    // Set the event name and its version.
    mxSetField(eventStruct, 0, "name", mxCreateString(eventHeader->Name));
    mxSetField(eventStruct, 0, "varVersion", mxCreateDoubleScalar(eventHeader->Version));

    // Create an mxArray to hold the timestamp data.
    matTimeStamps = mxCreateDoubleMatrix(timestamps.size(), 1, mxREAL);

    // Copy the timestamp data into the mxArray.  Divide by the frequency to convert
    // to seconds.
    t = mxGetPr(matTimeStamps);
    for (size_t i = 0; i < timestamps.size(); i++) {
        t[i] = (double)timestamps[i] / fileHeader->Frequency;
    }

    // Stick the timestamps into the MATLAB struct.
    mxSetField(eventStruct, 0, "timestamps", matTimeStamps);

    return eventStruct;
}


mxArray* readContinuousVariable(FILE *fp, NexVarHeader *continuousHeader, NexFileHeader *fileHeader)
{
    mxArray *continuousStruct;

    // Create the continuous struct.
    continuousStruct = mxCreateStructMatrix(1, 1, NUM_CONTINUOUS_FIELDS, (const char**)g_continuousFields);

    // Set the continuous meta data.
    mxSetField(continuousStruct, 0, "name", mxCreateString(continuousHeader->Name));
    mxSetField(continuousStruct, 0, "varVersion", mxCreateDoubleScalar(continuousHeader->Version));
    mxSetField(continuousStruct, 0, "ADtoMV", mxCreateDoubleScalar(continuousHeader->ADtoMV));
    mxSetField(continuousStruct, 0, "MVOffset", mxCreateDoubleScalar(continuousHeader->MVOffset));
    mxSetField(continuousStruct, 0, "ADFrequency", mxCreateDoubleScalar(continuousHeader->WFrequency));

    std::vector<int> fragment_timestamps;
    std::vector<int>  fragment_indexes;
    fragment_timestamps.resize(continuousHeader->Count);
    fragment_indexes.resize(continuousHeader->Count);

    std::vector<short> advalues;
    advalues.resize(continuousHeader->NPointsWave);

    // Locate the start of the data.
    fseek(fp, continuousHeader->DataOffset, SEEK_SET);

    // Read the timestamps.
    fread(&fragment_timestamps[0], continuousHeader->Count * 4, 1, fp);

    // Read the fragment indices.
    fread(&fragment_indexes[0], continuousHeader->Count * 4, 1, fp);

    // Read the AD values.
    fread(&advalues[0], continuousHeader->NPointsWave * 2, 1, fp);

    // Set the fragment starts and timestamps.
    if (continuousHeader->Count >= 1) {
        // Allocate our mxArrays to hold the data.
        mxArray *fragIndices = mxCreateDoubleMatrix(continuousHeader->Count, 1, mxREAL);
        mxArray *fragTimestamps = mxCreateDoubleMatrix(continuousHeader->Count, 1, mxREAL);
        double *fi = mxGetPr(fragIndices);
        double *ft = mxGetPr(fragTimestamps);

        // Convert the fragment values into doubles.
        for (size_t i = 0; i < continuousHeader->Count; i++) {
            // Add 1 to the fragment indices since MATLAB is 1 indexed.
            fi[i] = (double)fragment_indexes[i] + 1;
            ft[i] = (double)fragment_timestamps[i] / (double)fileHeader->Frequency;
        }

        mxSetField(continuousStruct, 0, "fragmentStarts", fragIndices);
        mxSetField(continuousStruct, 0, "timestamps", fragTimestamps);

        // Extract the raw data and stuff into an mxArray.
        mxArray *adData = mxCreateDoubleMatrix(advalues.size(), 1, mxREAL);
        double *a = mxGetPr(adData);
        for (size_t i = 0; i < advalues.size(); i++) {
            a[i] = (double)advalues[i] * (double)continuousHeader->ADtoMV;
        }
        mxSetField(continuousStruct, 0, "data", adData);
    }

//     mexPrintf( "Continuous '%s' [%d fragments, %d data points]:", continuousHeader->Name, continuousHeader->Count, continuousHeader->NPointsWave );
//     // print timestamps and values of the first 2 data points
//     // if the first fragment has more than 1 point
//     if ( fragment_timestamps.size() > 0 ) {
//         int numPointsInFirstFragment = 0;
//         if ( fragment_indexes.size() > 1 ) {
//             numPointsInFirstFragment = fragment_indexes[1];
//         } else {
//             numPointsInFirstFragment = ( int )advalues.size();
//         }
//         if ( numPointsInFirstFragment > 1 ) {
//             mexPrintf( "%.6f:%.3f,", ( double )fragment_timestamps[0] / fileHeader->Frequency, advalues[0]*continuousHeader->ADtoMV );
//             mexPrintf( "%.6f:%.3f,", ( ( double )fragment_timestamps[0] / fileHeader->Frequency ) + ( 1.0 / continuousHeader->WFrequency ), advalues[1]*continuousHeader->ADtoMV );
//         }
//     }
//     mexPrintf( "...\n" );

    return continuousStruct;
}


mxArray* readVariableData(FILE *fp, NexFileHeader *fileHeader, unsigned int variableType, std::vector<int> channels)
{
    std::vector<NexVarHeader> allHeaders;
    std::vector<unsigned int> varIndices;
    mxArray *data;

    // Read in all the variable header data.
    allHeaders.resize(fileHeader->NumVars);
    fread(&allHeaders[0], sizeof(NexVarHeader) * fileHeader->NumVars, 1, fp);

    // Loop through the variable list and record the indices of the ones matching
    // the specified variable type.
    for (size_t i = 0; i < allHeaders.size(); i++) {
        if (allHeaders[i].Type == variableType) {
            varIndices.push_back(i);
        }
    }

    // If the channels weren't specified, we'll construct a list of all
    // channels, i.e. get all the data.
    if (channels.empty()) {
        for (size_t i = 0; i < varIndices.size(); i++) {
            channels.push_back(i);
        }
    }

    // Create a cell array to hold the variable channels.
    data = mxCreateCellMatrix(channels.size(), 1);

    // Loop over all the "channels" we want to extract from this variable.  What
    // I'm calling a channel is the data associated with a specific variable
    // header entry.
    for (size_t i = 0; i < nIndices; i++) {
        // Extract the variable header index corresponding with our "channel"
        // index.
        size_t iHeader = varIndices[indices[i]];

        switch (allHeaders[iHeader].Type) {
            case NEX_VARIABLE_TYPE_CONTINUOUS:
                mxSetCell(data, i, readContinuousVariable(fp, &allHeaders[iHeader], fileHeader));
                break;

            case NEX_VARIABLE_TYPE_MARKER:
                mxSetCell(data, i, readMarkerVariable(fp, &allHeaders[iHeader], fileHeader));
                break;

            case NEX_VARIABLE_TYPE_EVENT:
                mxSetCell(data, i, readEventVariable(fp, &allHeaders[iHeader], fileHeader));
                break;

            default:
                barf("NEXENGINE:readVariableData:Invalid variable type.");
        }
    }

    if (!varIndices.empty()) {


        // Create a cell array to hold the makers.
        data = mxCreateCellMatrix(nData, 1);

        // We'll use this counter as an index into the mex cell matrix.  Data we
        // want to read and store will be put into the cell matrix at the index
        // value.
        size_t counter = 0;

        // Loop over all the variables and extract only the specified variables.
        for (size_t i = 0; i < varHeaders.size(); i++) {
            if (varHeaders[i].Type == variableType) {
                switch (varHeaders[i].Type) {
                    case NEX_VARIABLE_TYPE_CONTINUOUS:
                        mxSetCell(data, counter++, readContinuousVariable(fp, &varHeaders[i], fileHeader));
                        break;

                    case NEX_VARIABLE_TYPE_MARKER:
                        mxSetCell(data, counter++, readMarkerVariable(fp, &varHeaders[i], fileHeader));
                        break;

                    case NEX_VARIABLE_TYPE_EVENT:
                        mxSetCell(data, counter++, 	(fp, &varHeaders[i], fileHeader));
                        break;

                    default:
                        barf("NEXENGINE:readData:Invalid variable type.");
                }
            }
        }
    }
    else {
        // Return an empty matrix if nothing was found.
        data = mxCreateDoubleMatrix(0, 0, mxREAL);
    }

    return data;
}


static void cleanup()
{
    int i;

    mexPrintf("- Cleaning up mex memory.\n");

    // Delete the memory we allocated for the file header fields.
    for (i = 0; i < NUM_FILE_HEADER_FIELDS; i++) {
        mxFree(g_fileHeaderFields[i]);
    }
    mxFree(g_fileHeaderFields);

    // Delete the memory allocated for the event fields.
    for (i = 0; i < NUM_EVENT_FIELDS; i++) {
        mxFree(g_eventFields[i]);
    }
    mxFree(g_eventFields);

    // Delete the memory allocated for the marker fields.
    for (i = 0; i < NUM_MARKER_FIELDS; i++) {
        mxFree(g_markerFields[i]);
    }
    mxFree(g_markerFields);

    // Delete the memory allocated for the marker value fields.
    for (i = 0; i < NUM_MARKER_VALUE_FIELDS; i++) {
        mxFree(g_markerValueFields[i]);
    }
    mxFree(g_markerValueFields);

    // Delete the memory allocated for the continuous fields.
    for (i = 0; i < NUM_CONTINUOUS_FIELDS; i++) {
        mxFree(g_continuousFields[i]);
    }
    mxFree(g_continuousFields);
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////
// barf
//
// Spits an error to the MATLAB console.
/////////////////////////////////////////////////////////////////////////////////////////////////////////
void barf(const char *formatString, ...)
{
    int numCharsWritten;
    char errorString[512];
    va_list argptr;

    // Create the error string.
    va_start(argptr, formatString);
    numCharsWritten = vsprintf(errorString, formatString, argptr);
    va_end(argptr);

    if (numCharsWritten < 0) {
        // Shouldn't ever happen, but you never know.
        mexErrMsgTxt("NEXENGINE:barf:vsprintf failure.\n");
    }
    else if (numCharsWritten >= 512) {
        // Just stick in a string terminator.  Presumably, it'll be obvious
        // if the error message is too long.
        errorString[511] = '\0';
    }
    else {
        mexErrMsgTxt(errorString);
    }
}
