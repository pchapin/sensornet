#include "BaseStation.h"

configuration BaseStationAppC
{
}
implementation {

  components MainC;
  components BaseStationC;
  components new TimerMilliC();

  components ActiveMessageC;
  components new AMSenderC(AM_TEMPERATURE_MSG);
  components new AMReceiverC(AM_TEMPERATURE_MSG);
  
  components LocalTimeMicroC;

  components PrintfC;
  components SerialStartC;

  BaseStationC.Boot -> MainC;
  BaseStationC.Timer -> TimerMilliC;

  BaseStationC.AMSend -> AMSenderC;
  BaseStationC.Packet -> AMSenderC;
  BaseStationC.Receive -> AMReceiverC;
  BaseStationC.RadioControl -> ActiveMessageC;
  BaseStationC.AMPacket -> AMSenderC;
  BaseStationC.TimeStamp -> ActiveMessageC;
  
  //BaseStationC.LocalTime -> ActiveMessageC;
}
