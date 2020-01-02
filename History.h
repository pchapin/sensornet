
#ifndef HISTORY_H
#define HISTORY_H

#include <time.h>

#define HISTORY_DEPTH 16

typedef struct {
    int    originating_node;
    time_t time_stamp;
} History;

#endif
