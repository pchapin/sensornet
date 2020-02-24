#include "Timer.h"
#include "printf.h"

#define NEW_PRINTF_SEMANTICS

module BaseStationC
{
  uses {
    interface Boot;
    interface Timer<TMilli>;

    interface AMSend;
    interface Packet;
    interface Receive;
    interface SplitControl as RadioControl;
    interface AMPacket;
  }
  
  uses interface PacketTimeStamp<TMilli, uint32_t> as TimeStamp;
  
}
implementation {
  message_t base_packet;
  bool busy = FALSE;
  uint16_t counter = 0;
  uint16_t valCelsius, valFahrenheit;

	
  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      // Send broadcast for sensor data every 10 minutes
      call Timer.startPeriodic(600000);
    }
  }
  event void RadioControl.stopDone(error_t err) {}

  // Send a broadcast message
  event void Timer.fired() {
    if (busy) {
      return;
    } else {

      TempMsg_t* base_msg;
      base_msg = (TempMsg_t*)call Packet.getPayload(&base_packet, sizeof(TempMsg_t));
      base_msg->type = 0;
      base_msg->bcast_counter = counter;
      base_msg->forwarded = FALSE;
      base_msg->hops = 0;
      counter++;
    
      if (call AMSend.send(AM_BROADCAST_ADDR, &base_packet, sizeof(TempMsg_t)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    if (len != sizeof(TempMsg_t)) {
      return msg;
    } else {
      TempMsg_t* message = (TempMsg_t*)payload;
      
      // Get the parts of the message
      uint8_t type = message->type;
      uint8_t nodeid = message->nodeid;
      uint16_t val = message->temperature;
      uint16_t bcast_counter_check = message->bcast_counter;
      bool forwarded = message->forwarded;
	
      // BaseStation node id must be set to '0', ignore basestation messages.
      if(nodeid!=0){
      
      // Converting sensor data to Celsius and Fahrenheit.
      val = (double)val;
      valCelsius = -39.60 + (0.01 * val);
      //valFahrenheit = 32 + (1.8 * valCelsius);
     
      // Printed format to be written to a .txt file
      printf("%d,%d\n", nodeid,valCelsius); 
      
      // Flush the printf buffer
      printfflush();
      }
      return msg;
    }
  }


  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (&base_packet == msg) {
      busy = FALSE;
    }
  }
}


