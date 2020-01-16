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
  uint16_t valCelcius, valFahrenheit;
  unsigned long long int time_stamp;
  time_t now;
  


  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer.startPeriodic(2000);
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
      base_msg->counter = counter;
      base_msg->forwarded = FALSE;
      counter++;
      if (call AMSend.send(AM_BROADCAST_ADDR, &base_packet, sizeof(TempMsg_t)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }

  // When message is received
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    if (len != sizeof(TempMsg_t)) {
      return msg;
    } else {
    	 
      TempMsg_t* message = (TempMsg_t*)payload;
      
      uint8_t type = message->type;
      uint8_t nodeid = message->nodeid;
      uint16_t val = message->temperature;
      uint16_t counterid = message->counter;
      bool forwarded = message->forwarded;
      
      time_stamp = call TimeStamp.timestamp(msg);
      time_stamp = (time_stamp/1000);
      now = time(0);
      
      //Set BaseStation node to '0'
      if(nodeid!=0){
      printf("Packet Timestamp in Seconds: %d\n", time_stamp);	
      
      //printf("Message Number: %d\n", counterid);	
      printf("Node: %d\n", nodeid);
      val = (double)val;
      valCelcius = -39.60 + (0.01 * val);
      valFahrenheit = 32 + (1.8 * valCelcius);
      
      printf("Celcius: %d\n", valCelcius);
      printf("Fahrenheit: %d\n", valFahrenheit);
      printf("Data: %d\n", val);
      	if (forwarded) 
      	{
      		printf("This is a forwarded temperature message!\n\n\n");
      	}
      	else{
      		printf("\n\n\n");
      	}
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
