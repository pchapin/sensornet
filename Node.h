#ifndef NODE_H
#define NODE_H

typedef nx_struct TempMsg {
  nx_uint8_t type;
  nx_uint8_t nodeid;
  nx_uint16_t temperature;
  nx_uint16_t counter;
  nx_bool forwarded;
} TempMsg_t;

enum {
  AM_TEMPERATURE_MSG = 7,
};

#endif //NODE_H
