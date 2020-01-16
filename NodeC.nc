#include "Timer.h"

module NodeC
{
  uses {
    interface Boot;
    interface Timer<TMilli> as Timer0;
    interface Leds;
    interface Sensor;

    interface AMSend;
    interface Packet;
    interface Receive;
    interface SplitControl as RadioControl;
    interface AMPacket;
  }
}
implementation {
  am_addr_t bcast_node;
  message_t self_temp_packet, node_temp_packet, bcast_temp_packet;
  bool busy = FALSE;
  uint16_t counter;

  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) { }
  event void RadioControl.stopDone(error_t err) { }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    if (len != sizeof(TempMsg_t)) {
      return msg;
    } else {
      TempMsg_t* message = (TempMsg_t*)payload;
      TempMsg_t* bcast_temp_msg;
      TempMsg_t* node_temp_msg;
      uint8_t type = message->type;
      
      if (type == 0) {
        
        if (message->counter <= counter) {
          return msg ;
        }
        
        counter = message->counter;
        bcast_node = call AMPacket.source(msg);

        bcast_temp_msg = (TempMsg_t*)call Packet.getPayload(&bcast_temp_packet, sizeof(TempMsg_t));
        bcast_temp_msg->type = message->type;
        bcast_temp_msg->counter = counter;
        bcast_temp_msg->forwarded = TRUE;
        if (call AMSend.send(AM_BROADCAST_ADDR, &bcast_temp_packet, sizeof(TempMsg_t)) == SUCCESS) {
          busy = TRUE;
        }

        call Leds.led1Toggle();
        if (message->forwarded) { call Leds.led2Toggle(); }

        call Timer0.startOneShot(300);

      } else {
        call Leds.led2Toggle();

        node_temp_msg = (TempMsg_t*)call Packet.getPayload(&node_temp_packet, sizeof(TempMsg_t));
        node_temp_msg->type = message->type;
        node_temp_msg->nodeid = message->nodeid;
        node_temp_msg->forwarded = TRUE;
        node_temp_msg->temperature = message->temperature;
        node_temp_msg->counter = message->counter;
        if (call AMSend.send(bcast_node, &node_temp_packet, sizeof(TempMsg_t)) == SUCCESS) {
          busy = TRUE;
        }
      }
      return msg;
    }
  }

  // Read sense data and send to parent
  event void Timer0.fired() {
    call Sensor.read_sensor();
  }

  event void Sensor.sensor_done( uint16_t temperature) {
    TempMsg_t* self_temp_msg;
    self_temp_msg = (TempMsg_t*)call Packet.getPayload(&self_temp_packet, sizeof(TempMsg_t));
    self_temp_msg->type = 1;
    self_temp_msg->nodeid = TOS_NODE_ID;
    self_temp_msg->forwarded = FALSE;
    self_temp_msg->temperature = temperature;
    if (call AMSend.send(bcast_node, &self_temp_packet, sizeof(TempMsg_t)) == SUCCESS) 
    { 
    	busy = TRUE; 
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (&self_temp_packet == msg || &bcast_temp_packet == msg || &node_temp_packet == msg) {
      busy = FALSE;
    }
  }
}
