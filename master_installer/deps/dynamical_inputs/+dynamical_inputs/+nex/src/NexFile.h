#ifndef NEXFILE_H
#define NEXFILE_H

#define NEX_VARIABLE_TYPE_NEURON (0)
#define NEX_VARIABLE_TYPE_EVENT (1)
#define NEX_VARIABLE_TYPE_INTERVAL (2)
#define NEX_VARIABLE_TYPE_WAVEFORM (3)
#define NEX_VARIABLE_TYPE_POPULATION_VECTOR (4)
#define NEX_VARIABLE_TYPE_CONTINUOUS (5)
#define NEX_VARIABLE_TYPE_MARKER (6)

#pragma pack(push, 2)

// .nex file header structure
struct NexFileHeader 
{
    int  MagicNumber; // string NEX1; numeric value: 827868494 decimal or 0x3158454E hex
    int  NexFileVersion; // current version (Feb-2011) is 106;
    // when reading existing .nex files, use the following rules:
    // Versions 102 and 103: beta versions; should not be used
    // Versions 100, 101 and 104: use standard .nex data read algorithm as described,
    //     except that NexVarHeader::MVOffset and NexVarHeader::PrethresholdTimeInSeconds are not used and are always zero
    // Version 105: indicates that NexVarHeader::MVOffset can be non-zero
    // Version 106: indicates that NexVarHeader::PrethresholdTimeInSeconds can be non-zero

    char Comment[256]; // file comment
    double Frequency;  // timestamps frequency, in Hertz
                       // timestamp values are stored in ticks, where tick = 1/Frequency.
    int  Beg;	// minimum timestamp
    int  End;	// maximum timestamp + 1
    int  NumVars;    // number of variables in the file
    int  NextFileHeader; // position of the next file header in the file
                         // this field is not implemented yet
    char Padding[256]; // padding for future expansion
};

// .nex file variable header structure
struct NexVarHeader 
{
    int Type; // 0 - neuron, 1 - event, 2- interval, 3 - waveform, 4 - pop. vector, 5 - continuously recorded, 6 - marker
        // see #define statements above
    int Version; // almost always should be Version = 100; 
                 // use Version = 101 if it is a neuron or waveform variable and WireNumber and UnitNumber are valid 
                 // use Version = 102 if it is a waveform variable and PrethresholdTimeInSeconds is valid
    char Name[64]; // variable name
    int DataOffset; // where the data array for this variable is located in the file
    int Count; // neuron variable: number of timestamps
               // event variable: number of timestamps
               // interval variable: number of intervals
               // waveform variable: number of waveforms
               // continuous variable: number of fragments
               // population vector: number of weights
    int WireNumber; // neurons and waveforms only; for data from PLX files, channel number from the record header
    int UnitNumber; // neurons and waveforms only; for data from PLX files, unit number from the record header
    int Gain; // neurons only, not used
    int Filter; // neurons only, not used
    double XPos; // neurons only, X axis electrode position in (0,100) range, used in 3D display
    double YPos; //  neurons only, Y axis electrode position in (0,100) range, used in 3D display
    double WFrequency; // waveforms and continuous variables only, w/f or cont. sampling frequency in Hertz
    double ADtoMV; // waveforms and continuous variables only, coeff. to convert from A/D values to Millivolts.
                   // see formula below MVOffset below
    int NPointsWave; // waveform variable: number of points in each wave
                     // continuous variable: number of data points
    int		NMarkers; // marker events only, how many values are associated with each marker
    int		MarkerLength; // marker events only, how many characters are in each marker value
    double	MVOffset; // waveforms and continuous variables only, 
                      // this offset is used to convert A/D values in Millivolts:
                      //  mv = raw * ADtoMV + MVOffset
    double PrethresholdTimeInSeconds; // for waveforms, pre-threshold time in seconds
       // if waveform timestamp in seconds is t, 
       // then the timestamp of the first point of waveform is t - PrethresholdTimeInSeconds
    char	Padding[52]; // padding for future expansion
};

#pragma pack(pop)

#endif
