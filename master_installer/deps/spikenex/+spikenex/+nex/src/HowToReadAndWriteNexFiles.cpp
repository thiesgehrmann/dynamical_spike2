#include <stdio.h>
#include <vector>
#include "NexFile.h"
#include "NexFileVariables.h"

#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

void SkeletonCodeToReadNexFile( const char* filePath );
void ReadAllFromNexFile( const char* filePath );
void PrintHeaderInfo( NexFileHeader &fh );
void ReadNeuronData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader );
void ReadEventData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader );
void ReadIntervalData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader );
void ReadWaveformData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader );
void ReadContinuousData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader );
void ReadMarkerData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader );

void SkeletonCodeToWriteNexFile( const char* filePath );
void WriteNexFile( const char* fname );

int main( int argc, char* argv[] )
{
    // assuming this code is running on a Windows 7 computer with NeuroExplorer installed
    // read the test data file
    SkeletonCodeToReadNexFile( "C:\\ProgramData\\Nex Technologies\\NeuroExplorer\\TestDataFile4.nex" );
    ReadAllFromNexFile( "C:\\ProgramData\\Nex Technologies\\NeuroExplorer\\TestDataFile4.nex" );
    
    SkeletonCodeToWriteNexFile( "test1.nex" );
    WriteNexFile( "test.nex" );
    return 0;
}

// simplified code for reading data from .nex file:
// reads data from the first variable
void SkeletonCodeToReadNexFile( const char* filePath )
{
    NexFileHeader fh;
    std::vector<NexVarHeader> varHeaders;

    FILE* fp;

    fp = fopen( filePath, "rb" );

    // 1. read file header
    fread( &fh, sizeof( NexFileHeader ), 1, fp );

    // 2. read the variable headers
    varHeaders.resize( fh.NumVars );
    fread( &varHeaders[0], sizeof( NexVarHeader )*fh.NumVars, 1, fp );

    // 3. read timestamp data for the first variable
    // assuming the first variable is neuron or event
    std::vector<int> timestamps;
    if ( varHeaders[0].Type == NEX_VARIABLE_TYPE_NEURON || varHeaders[0].Type == NEX_VARIABLE_TYPE_EVENT ) {
        // seek to the start of data
        fseek( fp,  varHeaders[0].DataOffset, SEEK_SET );
        // read the timestamps, 4 bytes per timestamp
        timestamps.resize( varHeaders[0].Count );
        fread( &timestamps[0], varHeaders[0].Count * 4, 1, fp );
    }
    fclose( fp );
}

// the code to read all data types from .nex file
void ReadAllFromNexFile( const char* filePath )
{
    NexFileHeader fh;
    std::vector<NexVarHeader> varHeaders;

    FILE* fp;

    fp = fopen( filePath, "rb" );

    // 1. read file header
    fread( &fh, sizeof( NexFileHeader ), 1, fp );
    PrintHeaderInfo( fh );

    // 2. read the variable headers
    varHeaders.resize( fh.NumVars );
    fread( &varHeaders[0], sizeof( NexVarHeader )*fh.NumVars, 1, fp );

    // 3. read variable data
    for ( size_t i = 0; i < varHeaders.size(); ++i ) {
        switch ( varHeaders[i].Type ) {
            case NEX_VARIABLE_TYPE_NEURON:
                ReadNeuronData( fp, varHeaders[i], fh );
                break;
            case NEX_VARIABLE_TYPE_EVENT:
                ReadEventData( fp, varHeaders[i], fh );
                break;
            case NEX_VARIABLE_TYPE_INTERVAL:
                ReadIntervalData( fp, varHeaders[i], fh );
                break;
            case NEX_VARIABLE_TYPE_WAVEFORM:
                ReadWaveformData( fp, varHeaders[i], fh );
                break;
            case NEX_VARIABLE_TYPE_POPULATION_VECTOR:
                printf( "skipping population vector...\n" );
                break;
            case NEX_VARIABLE_TYPE_CONTINUOUS:
                ReadContinuousData( fp, varHeaders[i], fh );
                break;
            case NEX_VARIABLE_TYPE_MARKER:
                ReadMarkerData( fp, varHeaders[i], fh );
                break;
            default:
                printf( "Invalid variable type %d\n", varHeaders[i].Type );
                break;
        }
    }
    fclose( fp );
}

void ReadNeuronData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader )
{
    std::vector<int> timestamps;
    timestamps.resize( varHeader.Count );

    // seek to the start of data
    fseek( fp,  varHeader.DataOffset, SEEK_SET );
    // read the timestamps, 4 bytes per timestamp
    fread( &timestamps[0], varHeader.Count * 4, 1, fp );

    printf( "Neuron '%s' [%d timestamps]:", varHeader.Name, varHeader.Count );
    // print values of the first 3 timestamps
    for ( size_t i = 0; i < min( 3, timestamps.size() ); ++i ) {
        printf( " %.6f", ( double )timestamps[i] / fileHeader.Frequency );
    }
    printf( "...\n" );
}

// this is identical to ReadNeuronData
void ReadEventData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader )
{
    std::vector<int> timestamps;
    timestamps.resize( varHeader.Count );

    // seek to the start of data
    fseek( fp,  varHeader.DataOffset, SEEK_SET );
    // read the timestamps, 4 bytes per timestamp
    fread( &timestamps[0], varHeader.Count * 4, 1, fp );

    printf( "Event '%s' [%d timestamps]:", varHeader.Name, varHeader.Count );
    // print values of the first 3 timestamps
    for ( size_t i = 0; i < min( 3, timestamps.size() ); ++i ) {
        printf( " %.6f", ( double )timestamps[i] / fileHeader.Frequency );
    }
    printf( "...\n" );
}

void ReadIntervalData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader )
{
    std::vector<int> startTimestamps;
    std::vector<int> endTimestamps;
    startTimestamps.resize( varHeader.Count );
    endTimestamps.resize( varHeader.Count );

    // seek to the start of data
    fseek( fp,  varHeader.DataOffset, SEEK_SET );
    // read interval starts then ends
    fread( &startTimestamps[0], varHeader.Count * 4, 1, fp );
    fread( &endTimestamps[0], varHeader.Count * 4, 1, fp );

    printf( "Interval var. '%s' [%d intervals]:", varHeader.Name, varHeader.Count );
    // print values of the first 3 intervals
    for ( size_t i = 0; i < min( 3, startTimestamps.size() ); ++i ) {
        printf( " [%.6f,%.6f] ", ( double )startTimestamps[i] / fileHeader.Frequency, ( double )endTimestamps[i] / fileHeader.Frequency );
    }
    printf( "...\n" );
}

void ReadWaveformData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader )
{
    std::vector<int> timestamps;
    timestamps.resize( varHeader.Count );

    std::vector<short> waveforms;
    waveforms.resize( varHeader.Count * varHeader.NPointsWave );

    // seek to the start of data
    fseek( fp,  varHeader.DataOffset, SEEK_SET );
    // read timestamps
    fread( &timestamps[0], varHeader.Count * 4, 1, fp );
    // read waveform values
    fread( &waveforms[0], varHeader.Count * varHeader.NPointsWave * 2, 1, fp );

    printf( "Waveform '%s' [%d waveforms]:", varHeader.Name, varHeader.Count );
    // print the first 3 values of the first waveform
    for ( size_t i = 0; i < min( 1, timestamps.size() ); ++i ) {
        printf( " %.6f:", ( double )timestamps[i] / fileHeader.Frequency );
        for ( int wavePoint = 0; wavePoint < min( 3, varHeader.NPointsWave ); ++wavePoint ) {
            printf( "%.2f,", ( double )waveforms[ i * varHeader.NPointsWave + wavePoint] * varHeader.ADtoMV );
        }
    }
    printf( "...\n" );
}

void ReadContinuousData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader )
{
    std::vector<int> fragment_timestamps;
    std::vector<int>  fragment_indexes;
    fragment_timestamps.resize( varHeader.Count );
    fragment_indexes.resize( varHeader.Count );

    std::vector<short> advalues;
    advalues.resize( varHeader.NPointsWave );

    // seek to the start of data
    fseek( fp,  varHeader.DataOffset, SEEK_SET );
    // read timestamps
    fread( &fragment_timestamps[0], varHeader.Count * 4, 1, fp );
    // read fragment indexes
    fread( &fragment_indexes[0], varHeader.Count * 4, 1, fp );
    // read a/d  values
    fread( &advalues[0], varHeader.NPointsWave * 2, 1, fp );

    printf( "Continuous '%s' [%d fragments, %d data points]:", varHeader.Name, varHeader.Count, varHeader.NPointsWave );
    // print timestamps and values of the first 2 data points
    // if the first fragment has more than 1 point
    if ( fragment_timestamps.size() > 0 ) {
        int numPointsInFirstFragment = 0;
        if ( fragment_indexes.size() > 1 ) {
            numPointsInFirstFragment = fragment_indexes[1];
        } else {
            numPointsInFirstFragment = ( int )advalues.size();
        }
        if ( numPointsInFirstFragment > 1 ) {
            printf( "%.6f:%.3f,", ( double )fragment_timestamps[0] / fileHeader.Frequency, advalues[0]*varHeader.ADtoMV );
            printf( "%.6f:%.3f,", ( ( double )fragment_timestamps[0] / fileHeader.Frequency ) + ( 1.0 / varHeader.WFrequency ), advalues[1]*varHeader.ADtoMV );
        }
    }
    printf( "...\n" );
}

void ReadMarkerData( FILE* fp, NexVarHeader& varHeader, NexFileHeader& fileHeader )
{
    std::vector<int> timestamps;
    timestamps.resize( varHeader.Count );

    // seek to the start of data
    fseek( fp,  varHeader.DataOffset, SEEK_SET );
    // read timestamps
    fread( &timestamps[0], varHeader.Count * 4, 1, fp );

    // reserve vector for field names
    std::vector < std::string > fieldNames;
    fieldNames.resize( varHeader.NMarkers );

    // reserve matrix for field values
    std::vector < std::vector<  std::string > > fieldValues;
    fieldValues.resize( varHeader.NMarkers );

    // temp char vectors we will use to read into
    std::vector<char> fieldName;
    std::vector<char> buf;

    // read the marker field names and values
    for ( int field = 0; field < varHeader.NMarkers; field++ ) {
        // read the name of the data field
        fieldName.resize( 65, 0 );
        fread( &fieldName[0], 64, 1, fp );
        fieldNames[field] = ( const char* )&fieldName[0];
        for ( int j = 0; j < varHeader.Count; j++ ) {
            // read the field value for the j-th timestamp
            buf.resize( varHeader.MarkerLength + 1, 0 );
            fread( &buf[0], varHeader.MarkerLength, 1, fp );
            std::string s = ( const char* )&buf[0];
            fieldValues[field].push_back( s );
        }
    }

    printf( "Marker '%s' [%d values]:", varHeader.Name, varHeader.Count );
    // print the first marker values
    for ( size_t i = 0; i < min( 1, timestamps.size() ); ++i ) {
        printf( " %.6f:", ( double )timestamps[i] / fileHeader.Frequency );
        for ( size_t f = 0; f < fieldNames.size(); ++f ) {
            printf( "'%s':'%s', ", fieldNames[f].c_str(), fieldValues[f][i].c_str() );
        }
    }
    printf( "...\n" );
}


void PrintHeaderInfo( NexFileHeader &fh )
{
    printf( "Nex file version: %d\n", fh.NexFileVersion );
    printf( "Frequency: %f hz\n", fh.Frequency );
    printf( "Duration: %f sec\n", ( double )fh.End / fh.Frequency );
    printf( "Number of variables: %d\n", fh.NumVars );
}

// --------------------------------- writing .nex files --------------------------------------

void FillTestData( double fileTimestampFrequency, std::vector<NexFileVariable*>& fileVariables )
{
    Neuron* neuron1 = new Neuron( "Neuron1", fileTimestampFrequency );
    fileVariables.push_back( neuron1 );

    // add timestamps 1.5s, 4.1s, 5.3s:
    neuron1->AddTimestampInSeconds( 1.5 );
    neuron1->AddTimestampInSeconds( 4.1 );
    neuron1->AddTimestampInSeconds( 5.3 );

    Neuron* neuron2 = new Neuron( "Neuron2", fileTimestampFrequency );
    fileVariables.push_back( neuron2 );

    // add timestamps 0.005s, 1.123s:
    neuron2->AddTimestampInSeconds( 0.005 );
    neuron2->AddTimestampInSeconds( 1.123 );
}

// the code that demonstrates the steps of writing .nex file:
// 1. write file header
// 1.a calculate data offset for the first variable
// 2. write variable headers and update data offset
// 3. write variable data
void SkeletonCodeToWriteNexFile( const char* filePath )
{
    double fileTimestampFrequency = 10000; // frequency is 10000 hz, or 100 us time resolution
    std::vector<NexFileVariable*> fileVariables;

    FillTestData( fileTimestampFrequency, fileVariables );

    FILE* fp = fopen( filePath, "wb" );
    if ( fp == 0 ) return;

    // 1. write file header
    NexFileHeader fh;
    memset( &fh, 0, sizeof( NexFileHeader ) );
    char magic[] = "NEX1";
    fh.MagicNumber = *( int* )magic;
    fh.NexFileVersion = 100;
    strcpy( fh.Comment, "test nex file" );
    fh.Frequency = fileTimestampFrequency; 
    fh.Beg = 0;
    fh.End = ( int )( fileTimestampFrequency * 10 ); // 10 seconds of data in the file
    fh.NumVars = ( int )fileVariables.size(); // number of variables in the file
    fh.NextFileHeader = 0;

    fwrite( &fh, sizeof( NexFileHeader ), 1, fp );

    // 1.a calculate data offset for the first variable
    // right after all the headers
    int dataOffset = sizeof( NexFileHeader ) + fh.NumVars * sizeof( NexVarHeader );

    // 2. write variable headers and update data offset
    for ( size_t i = 0; i < fileVariables.size(); ++i ) {
        fileVariables[i]->WriteVariableHeader( fp, dataOffset );
    }

    // 3. write variable data
    for ( size_t i = 0; i < fileVariables.size(); ++i ) {
        fileVariables[i]->WriteData( fp );
    }

    fclose( fp );

    // clean up
    for ( size_t i = 0; i < fileVariables.size(); ++i ) {
        delete fileVariables[i];
    }
}

// code that writes various data types to .nex file
void WriteNexFile( const char* fname )
{
    FILE* fp = fopen( fname, "wb" );
    if ( fp == 0 ) return;

    // we'll make a .nex file with 6 variables:
    // - two spike trains
    // - one interval variable
    // - one continuous variable
    // - one waveform variable
    // - one marker variable

    // first, let's fill the spike trains
    // we will work with time resolution of 100 us or frequency 10000 Hz
    // neuron 1: spikes at 1, 2, and 3 sec
    int train1[3] = { 10000, 20000, 30000} ; // in time ticks: 1.*10000, etc.
    // neuron 2: spikes at 5, and 6 sec
    int train2[2] = { 50000, 60000} ; // in time ticks

    // interval variable with 2 intervals: (1 sec, 2 sec) and (4 sec, 6 sec)
    int intstart[2] = { 10000, 40000 };
    int intend[2]   = { 20000, 60000 };

    // continuous variable: 2 fragments, one starts at 1 sec, another at 7 sec
    int num_fragments = 2;
    int cont_ts[2] = { 10000, 70000 };
    // continuous variable: first fragment has 5 data points, second fragment has 3 data points
    // what we need to store is the index of the first data point in each fragment
    // for the first fragment, the first data point is point number 0,
    // for the second fragment, the first data point is point number 5
    int cont_num_points[2] = { 0, 5 };
    // continuous variable: a/d values
    int num_data_points = 8;
    short cont_data_points[8] = { 0, 1, 2, 3, 4, 0, 4, 6 };

    // waveform variable: 3 waveforms, start at 0.5 sec, 1.5 sec and 2 sec
    int num_wf = 3;
    int wf_ts[3] = { 5000, 15000, 20000 };
    // waveform variable: a/d values
    int num_data_points_in_wave = 8;
    // waveform values
    short waveform_values1[8] = { 0, 1, 2, 3, 4, 5, 6, 7};
    short waveform_values2[8] = { 7, 6, 5, 4, 3, 2, 1, 0};
    short waveform_values3[8] = { 0, 1, 2, 3, 4, 5, 6, 7};

    // marker variable: 3 markers, each has 2 fields
    // markers are at 1, 2, and 3 sec
    int marker_ts[3] = { 10000, 20000, 30000} ; // in time ticks: 1.*10000, etc.
    // names of marker fields;
    char marker_field_names[2][64];
    memset( marker_field_names[0], 0, 64 );
    strcpy( marker_field_names[0], "field1" );
    memset( marker_field_names[1], 0, 64 );
    strcpy( marker_field_names[1], "field2" );

    // values of the first marker field:
    char* marker_field_values1[] = {"field1value1", "field1value2", "field1value3"};
    // values of the second marker field:
    char* marker_field_values2[] = {"field2value1", "field2value2", "field2value3"};

    NexFileHeader fh;
    memset( &fh, 0, sizeof( NexFileHeader ) );
    char magic[] = "NEX1";
    fh.MagicNumber = *( int* )magic;
    fh.NexFileVersion = 100;
    strcpy( fh.Comment, "test nex file" );
    fh.Frequency = 10000.; // frequency is 10000 hz, or 100 us time resolution
    fh.Beg = 0;
    fh.End = 10000 * 10; // 10 seconds of data in the file
    fh.NumVars = 6;  // we have 6 variables in the file
    fh.NextFileHeader = 0;

    fwrite( &fh, sizeof( NexFileHeader ), 1, fp );

    // calculate the data offset for the first variable
    // right after all the headers
    int offset = sizeof( NexFileHeader ) + fh.NumVars * sizeof( NexVarHeader );

    NexVarHeader varheader;
    memset( &varheader, 0, sizeof( NexVarHeader ) );

    // neuron 1 header
    varheader.Type = NEX_VARIABLE_TYPE_NEURON; // neuron type
    varheader.Version = 100;
    strcpy( varheader.Name, "neuron1" ); // variable name
    varheader.DataOffset = offset;
    varheader.Count = 3;  // number of timestamps
    fwrite( &varheader, sizeof( NexVarHeader ), 1, fp );

    // adjust offset: add the bytes of the neuron1 timestamp array
    offset += varheader.Count * sizeof( int );

    // neuron 2 header
    memset( &varheader, 0, sizeof( NexVarHeader ) );
    varheader.Type = NEX_VARIABLE_TYPE_NEURON; // neuron type
    varheader.Version = 100;
    strcpy( varheader.Name, "neuron2" ); // variable name
    varheader.DataOffset = offset;
    varheader.Count = 2;  // number of timestamps
    fwrite( &varheader, sizeof( NexVarHeader ), 1, fp );

    // adjust offset: add the bytes of the neuron2 timestamp array
    offset += varheader.Count * sizeof( int );

    // interval header
    memset( &varheader, 0, sizeof( NexVarHeader ) );
    varheader.Type = NEX_VARIABLE_TYPE_INTERVAL; // interval type
    varheader.Version = 100;
    strcpy( varheader.Name, "interval1" ); // variable name
    varheader.DataOffset = offset;
    varheader.Count = 2;  // number of intervals
    fwrite( &varheader, sizeof( NexVarHeader ), 1, fp );

    // adjust offset: add the bytes of the interval starts and ends
    offset += varheader.Count * sizeof( int ) * 2;

    // continuous variable header
    memset( &varheader, 0, sizeof( NexVarHeader ) );
    varheader.Type = NEX_VARIABLE_TYPE_CONTINUOUS; // continuous type
    varheader.Version = 100;
    strcpy( varheader.Name, "continuous1" ); // variable name
    varheader.DataOffset = offset;
    varheader.Count = 2;  // number of fragments
    varheader.NPointsWave = 8; // we have 8 a/d values in 2 fragments
    varheader.WFrequency = 10; // this is a/d frequency, 10 data points per second
    varheader.ADtoMV = 0.001; // this is a coefficient to convert a/d values to millivolts.
    // 0.001 here means that the stored a/d values are in volts.

    fwrite( &varheader, sizeof( NexVarHeader ), 1, fp );

    // adjust offset: add the bytes of fragment timestamps
    offset += varheader.Count * sizeof( int );
    // adjust offset: add the bytes of fragment number of values
    offset += varheader.Count * sizeof( int );
    // adjust offset: add the bytes of a/d values
    offset += varheader.NPointsWave * sizeof( short );

    // waveform variable header
    memset( &varheader, 0, sizeof( NexVarHeader ) );
    varheader.Type = NEX_VARIABLE_TYPE_WAVEFORM; // waveform type
    varheader.Version = 100;
    strcpy( varheader.Name, "wave1" ); // variable name
    varheader.DataOffset = offset;
    varheader.Count = 3;  // number of waveforms
    varheader.NPointsWave = 8; // we have 8 a/d values in each waveform
    varheader.WFrequency = 1000; // this is a/d frequency, 1000 data points per second
    varheader.ADtoMV = 1.; // this is a coefficient to convert a/d values to millivolts.
    // 1 here means that the stored a/d values are in millivolts.

    fwrite( &varheader, sizeof( NexVarHeader ), 1, fp );

    // adjust offset: add the bytes of waveform timestamps
    offset += varheader.Count * sizeof( int );
    // adjust offset: add the bytes of a/d values
    offset += varheader.Count * varheader.NPointsWave * sizeof( short );

    // marker header
    memset( &varheader, 0, sizeof( NexVarHeader ) );
    varheader.Type = NEX_VARIABLE_TYPE_MARKER; // marker type
    varheader.Version = 100;
    strcpy( varheader.Name, "marker1" ); // variable name
    varheader.DataOffset = offset;
    varheader.Count = 3;  // number of markers (timestamps)
    varheader.NMarkers = 2; // number of marker fields for each timestamp
    varheader.MarkerLength = 16; // number of bytes for each field string
    fwrite( &varheader, sizeof( NexVarHeader ), 1, fp );

    // adjust offset: add the bytes of timestamps
    offset += varheader.Count * sizeof( int );
    // adjust offset: add the bytes of field names (64 bytes per field) and field values
    offset += varheader.NMarkers * ( 64 + varheader.Count * varheader.MarkerLength );

    // now, write the data in the same order as we wrote the headers
    // first spike train
    fwrite( train1, 3 * sizeof( int ), 1, fp );
    // second spike train
    fwrite( train2, 2 * sizeof( int ), 1, fp );
    // interval variable -- for the intervals, first we write starts, then ends
    fwrite( intstart, 2 * sizeof( int ), 1, fp );
    fwrite( intend, 2 * sizeof( int ), 1, fp );

    // for the continuous variable, first we write fragment timestamps,
    // then fragment counts, and finally, a/d values
    fwrite( cont_ts, num_fragments * sizeof( int ), 1, fp );
    fwrite( cont_num_points, num_fragments * sizeof( int ), 1, fp );
    fwrite( cont_data_points, num_data_points * sizeof( short ), 1, fp );

    // for waveform variable, first we write w/f timestamps,
    // then, a/d values
    fwrite( wf_ts, num_wf * sizeof( int ), 1, fp );
    fwrite( waveform_values1, 8 * sizeof( short ), 1, fp );
    fwrite( waveform_values2, 8 * sizeof( short ), 1, fp );
    fwrite( waveform_values3, 8 * sizeof( short ), 1, fp );

    char buf[16];
    // for the marker variable, first we write the timestamps,
    fwrite( marker_ts, 3 * sizeof( int ), 1, fp );
    // then, for each field --
    // field name (we have to use exactly 64 bytes for each name)
    fwrite( marker_field_names[0], 64, 1, fp );
    // then, marker field values for the first field
    // we have to use exactly varheader.MarkerLength bytes for each value
    for ( int i = 0; i < 3; i++ ) {
        strcpy( buf, marker_field_values1[i] );
        fwrite( buf, 16, 1, fp );
    }
    // field name for the second filed
    fwrite( marker_field_names[1], 64, 1, fp );
    // finally, marker field values for the second field
    // we have to use exactly varheader.MarkerLength bytes for each value
    for ( int i = 0; i < 3; i++ ) {
        strcpy( buf, marker_field_values2[i] );
        fwrite( buf, 16, 1, fp );
    }

    printf( "created .nex file '%s'\n", fname );
    fclose( fp );
}

