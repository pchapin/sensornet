#ifndef NODE_H
#define NODE_H

typedef nx_struct TempMsg {
  nx_uint8_t type;
  nx_uint8_t nodeid;
  nx_uint16_t temperature;
  nx_uint16_t bcast_counter;
  nx_bool forwarded;
  nx_uint16_t hops;
} TempMsg_t;

enum {
  AM_TEMPERATURE_MSG = 7,
};

#endif //NODE_H
