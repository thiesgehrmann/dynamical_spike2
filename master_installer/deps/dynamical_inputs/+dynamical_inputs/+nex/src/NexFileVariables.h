#ifndef NEXFILEVARIABLES_H
#define NEXFILEVARIABLES_H

#include <string>
#include <vector>

// some helper classes for saving data to .nex files

class NexFileVariable
{
public:
    NexFileVariable( const char* name, double timestampFrequency )
        : m_Name( name ), m_TimestampFrequency( timestampFrequency )
        , m_DataOffset( 0 ) {}

    virtual void WriteVariableHeader( FILE* fp, int& dataOffset ) = 0;
    virtual void WriteData( FILE* fp ) = 0;

protected:
    std::string m_Name;
    double m_TimestampFrequency;
    int m_DataOffset;
};

class Neuron : public NexFileVariable
{
public:
    Neuron( const char* name, double timestampFrequency ): NexFileVariable( name, timestampFrequency ) {}

    void AddTimestampInSeconds( double tsInSeconds ) {
        m_Timestamps.push_back( ( int )( tsInSeconds * m_TimestampFrequency ) );
    }

    virtual void WriteVariableHeader( FILE* fp, int& dataOffset ) {
        // store data offset for our data
        m_DataOffset = dataOffset;

        // fill variable header and save it
        NexVarHeader varheader;
        memset( &varheader, 0, sizeof( NexVarHeader ) );
        varheader.Type = NEX_VARIABLE_TYPE_NEURON;
        varheader.Version = 100;
        strcpy( varheader.Name, m_Name.c_str() ); // variable name
        varheader.DataOffset = dataOffset;
        varheader.Count = ( int )m_Timestamps.size(); // number of timestamps
        fwrite( &varheader, sizeof( NexVarHeader ), 1, fp );

        // adjust offset: add the bytes of the neuron timestamp array
        dataOffset += varheader.Count * sizeof( int );
    }

    virtual void WriteData( FILE* fp ) {
        fwrite( &m_Timestamps[0], m_Timestamps.size() * sizeof( int ), 1, fp );
    }

protected:
    std::vector<int> m_Timestamps;
};

#endif
