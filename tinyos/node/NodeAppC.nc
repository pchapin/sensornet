#include "Node.h"


configuration NodeAppC
{
}
implementation {

  components MainC;
  components NodeC;
  components SensorC;
  components LedsC;
  
  components new TimerMilliC() as Timer0;
  components new SensirionSht11C() as Sensor;
  
  components ActiveMessageC;
  components new AMSenderC(AM_TEMPERATURE_MSG);
  components new AMReceiverC(AM_TEMPERATURE_MSG);

  components SerialStartC;

  NodeC.Boot -> MainC;
  NodeC.Timer0 -> Timer0;
  NodeC.Leds -> LedsC;
  NodeC.Sensor -> SensorC;

  NodeC.AMSend -> AMSenderC;
  NodeC.Packet -> AMSenderC;
  NodeC.Receive -> AMReceiverC;
  NodeC.RadioControl -> ActiveMessageC;
  NodeC.AMPacket -> AMSenderC;
	
  SensorC.Leds -> LedsC;
  SensorC.Read -> Sensor.Temperature;
}
