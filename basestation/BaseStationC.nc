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
  //uses interface LocalTime<TMilli> as LocalTime;	
  
}
implementation {
  message_t base_packet;
  bool busy = FALSE;
  uint16_t counter = 0;
  //uint16_t hops;
  //uint16_t bcast_counter_check = 0;
  uint16_t valCelcius, valFahrenheit;
  unsigned long long int time_stamp;
  //uint32_t local_time;
  //uint16_t i,j;
  


  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer.startPeriodic(30000);
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
      //local_time = call LocalTime.get();
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
      
      uint8_t type = message->type;
      uint8_t nodeid = message->nodeid;
      uint16_t val = message->temperature;
      uint16_t bcast_counter_check = message->bcast_counter;
      bool forwarded = message->forwarded;

      //This hop helps configure delays. 
      uint16_t hops = message->hops;
      //uint16_t path[10];
      //for(j = 0; j < 10; j++)
      //{
	//path[j] = message->path[j];  
      //}

      //unsigned long long int bcast_time = message->time;
      
      time_stamp = call TimeStamp.timestamp(msg);
      time_stamp = (time_stamp/1000);
      
      //Set BaseStation node to '0'
      if(nodeid!=0){
      //printf("Packet received at node at second: %d\n", bcast_time);
      //printf("Packet received at basestation at second: %d\n", time_stamp);	
      
      //printf("This is broadcast: %d\n", bcast_counter_check);	
      printf("Node: %d\n", nodeid);
      val = (double)val;
      valCelcius = -39.60 + (0.01 * val);
      valFahrenheit = 32 + (1.8 * valCelcius);
      
      printf("Celcius: %d\n", valCelcius);
      printf("Fahrenheit: %d\n", valFahrenheit);
      printf("Data: %d\n", val);
      	if (forwarded) 
      	{
      		//printf("This message hopped nodes: %d", hops);
      		//printf(" times\n");
	
		//for(i=0; i<10; i++)
		//{
		//	printf("%d", path[i]);
		//	printf(" -> ");
		//}	
		printf("\n\n\n");
      		//printf("This is a forwarded temperature message!\n\n\n");
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
