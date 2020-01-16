
module SensorC
{
    provides interface Sensor;
    uses {
        interface Leds;
        interface Read<uint16_t>;
    }
}
implementation
{
    command void Sensor.read_sensor( ) 
    {
        call Read.read( );
    }

    event void Read.readDone( error_t result, uint16_t data )
    {
        // Ignore errors...
        if( result == SUCCESS ) {

            // This displays the least significant three bits of the value read.
            // This is not very interesting (and might not even change from reading to reading).
            // Probably better would be toggle an LED at each reading... or something.
            if( data & 0x0004 )
                call Leds.led2On( );
            else
                call Leds.led2Off( );
            if( data & 0x0002 )
                call Leds.led1On( );
            else
                call Leds.led1Off( );
            if( data & 0x0001 )
                call Leds.led0On( );
            else
                call Leds.led0Off( );

            // Tell the higher level component that we have data.
            signal Sensor.sensor_done( data );
        }
    }
}
