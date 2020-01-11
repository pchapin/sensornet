
// Application global constants, structures, etc.

#ifndef TEMP_H
#define TEMP_H

// The Active Message type used for temperature messages. This value is arbitrary.
#define TEMP_AM_TYPE 37

// Sampling period in binary milliseconds
#define SAMPLING_PERIOD 100

// The detailed message structure for packet payloads.
typedef nx_struct {
    nx_uint16_t originating_node;  // Node ID of where the reading was taken.
    nx_uint32_t time_stamp;        // A time stamp as a C standard time_t value.
    nx_uint16_t temperature;       // 16 bit temperature value.
} TempMsg;

#endif
