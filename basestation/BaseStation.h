#ifndef BASESTATION_H
#define BASESTATION_H

typedef nx_struct TempMsg {
  nx_uint8_t type;
  nx_uint8_t nodeid;
  nx_uint16_t temperature;
  nx_uint16_t bcast_counter;
  nx_bool forwarded;
  nx_uint16_t hops;
  //nx_uint16_t path[10];
} TempMsg_t;

enum {
  AM_TEMPERATURE_MSG = 7,
};

#endif //BASESTATION_H_
