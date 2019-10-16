#ifndef NEXENGINE_H
#define NEXENGINE_H

#include <mex.h>
#include "NexFile.h"
#include "NexFileVariables.h"

// Macro to check that the right number of arguments were passed to a command.
#define CHECKARGCOUNT(x) if (nrhs != (x+1)) {barf("NEXENGINE:%d command requires %d arguments.", opCode, x);}

#define NUM_FILE_HEADER_FIELDS 6
#define NUM_EVENT_FIELDS 3
#define NUM_MARKER_FIELDS 4
#define NUM_MARKER_VALUE_FIELDS 2
#define NUM_CONTINUOUS_FIELDS 8
#define NUM_VAR_HEADER_FIELDS 18

#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

// Enumeration to list all the PVCAMEngine functions.  Has a 1 to 1
// correspondence with the PVCAM.OpCodes enumeration in the MATLAB code.
typedef enum {
    GetHeader = 1,
    GetEvents,
    GetMarkers,
    GetContinuous,
    GetVariableHeaders
} EngineFunctions;


/*******************************************************************************
 barf - Generates a formatted string MATLAB error.

 Syntax:
 barf(const char *formatString, ...)

 Description:
 Calls mexErrMsgTxt, but allows us to pass it a string specified in the same
 format arguments to C/C++ printf().  The maximum string length after all arguments
 are inserted in the format string length is limited to 256 bytes.

 Inputs:
 formatString - String containing the text and format specifiers.
 ... - Optional list of variable arguments contained in the formatString.

 Examples:
 // Throw a MATLAB error with a string containing numbers.
 int myInt = 3;
 double myDouble = 1.09834;
 barf("Times: %d, %f", myInt, myDouble;
*******************************************************************************/
void barf(const char *formatString, ...);


/*******************************************************************************
 packFileHeaderData - Creates an mxArray struct containing file header data.

 Syntax:
 mxArray * packFileHeaderData(NexFileHeader *fileHeader)

 Description:
 Packs file header data into an mxArray of type mxSTRUCT_CLASS.

 Input:
 fileHeader - Point to a file header object.  For the output to be valid, the
     fileHeader object must already be loaded with file header data.

 Output:
 mxArray * - mxSTRUCT_CLASS mxArray containing the file header information.
******************************************************************************/
mxArray * packFileHeaderData(NexFileHeader *fileHeader);


/*******************************************************************************
 packVarHeaderData - Creates an mxArray struct containing var header data.
 
 Syntax:
 mxArray * packVarHeaderData(NexVarHeader *varHeader)
 
 Description:
 Packs var header data into an mxArray of type mxSTRUCT_CLASS.
 
 Input:
 varHeader - Pointer to a var header object.  Data from this object will be
     copied to the returned mxArray.
 
 Output:
 mxArray * - mxSTRUCT_CLASS mxArray containing the var header information.
*******************************************************************************/
mxArray * packVarHeaderData(NexVarHeader *varHeader);


/*******************************************************************************
 initGlobalStructFields - Initializes string arrays needed for mxArray structs.
 
 Syntax:
 initGlobalStructFields()
 
 Description:
 The NEX engine makes use of a lot of MATLAB structs.  One annoying feature of
 creating MATLAB structs via the mex interface is setting up the 2D string
 arrays containing the field names.  We'll put all that string initialization
 here.  This function is only needed to be called once when the mex file is
 first initialized since the field names will never change.
*******************************************************************************/
void initGlobalStructFields(void);


/*******************************************************************************
*******************************************************************************/
mxArray * readVariableData(FILE *fp, NexFileHeader *fileHeader, unsigned int variableType, std::vector<int> channels=std::vector<int>());

/*******************************************************************************
*******************************************************************************/
mxArray * readEventVariable(FILE *fp, NexVarHeader *eventHeader, NexFileHeader *fileHeader);

/*******************************************************************************
*******************************************************************************/
mxArray * readMarkerVariable(FILE *fp, NexVarHeader *markerHeader, NexFileHeader *fileHeader);

/*******************************************************************************
*******************************************************************************/
mxArray * readContinuousVariable(FILE *fp, NexVarHeader *continuousHeader, NexFileHeader *fileHeader);

/*******************************************************************************
*******************************************************************************/
static void cleanup();

#endif
