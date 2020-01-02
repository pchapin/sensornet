
#include "Temp.h"

configuration TempAppC 
{
    // Top level configuration neither uses nor provides any interface.
} 
implementation { 
  
    components TempC;   // "Main" component of this application.
    components SensorC; // Used to read values of the temperature sensor.

    // TinyOS library components..
    components MainC;   // Internal main component.
    components LedsC;   // For "debugging messages" to the LEDs.
    
    components new TimerMilliC( ) as Timer0;      // Timer to drive periodic sensing.
    components new SensirionSht11C( ) as Sensor;  // The temperature sensor itself.

    // Active Message components.
    components ActiveMessageC;
    components new AMSenderC( TEMP_AM_TYPE );

    // System management.
    TempC.Boot   -> MainC;
    TempC.Timer0 -> Timer0;
    TempC.Sensor -> SensorC;

    // Radio control.
    TempC.AMControl -> ActiveMessageC;
    TempC.Packet    -> AMSenderC;
    TempC.AMPacket  -> AMSenderC;
    TempC.AMSend    -> AMSenderC;

    // Sensor access.
    SensorC.Leds -> LedsC;
    SensorC.Read -> Sensor.Temperature;
}
