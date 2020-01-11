
#include "Temp.h"

module TempC {
    uses {
        // Application specific...
        interface Sensor;

        // TinyOS library...
        interface Boot;
        interface Timer<TMilli> as Timer0;

        // Active Message related...
        interface SplitControl as AMControl;
        interface Packet;
        interface AMPacket;
        interface AMSend;
    }
}
implementation {
    bool busy = FALSE;
    message_t packet;

    event void Boot.booted( )
    {
        call AMControl.start( );
    }

    event void AMControl.startDone( error_t err )
    {
        if( err == SUCCESS ) {
            call Timer0.startPeriodic( SAMPLING_PERIOD );
        }
        else {
            call AMControl.start( );
        }
    }

    event void AMControl.stopDone( error_t err )
    {
        // Do nothing. Required by the compiler to provide an implementation.
    }

    event void Timer0.fired( )
    {
        call Sensor.read_sensor( );
    }

    event void Sensor.sensor_done( uint16_t data )
    {
        if( !busy ) {
            TempMsg *temp_packet = (TempMsg*)(call Packet.getPayload(&packet, sizeof(TempMsg)));
            temp_packet->originating_node = TOS_NODE_ID;
            temp_packet->time_stamp = 0;   // FINISH ME!
            temp_packet->temperature = data;
            if( call AMSend.send( AM_BROADCAST_ADDR, &packet, sizeof(TempMsg)) == SUCCESS) {
                busy = TRUE;
            }
        }
    }

    event void AMSend.sendDone( message_t *msg, error_t error )
    {
        if( &packet == msg ) {
            busy = FALSE;
        }
    }
}
