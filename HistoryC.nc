
#include "History.h"

// For convenience...
#define max(a, b)  ((a) < (b) ? (b) : (a))

module HistoryC {
    provides interface History;
}
implementation {

    History  cache[HISTORY_DEPTH];
    History *next_in = &cache;
    size_t   count = 0;

    command void install( History *record )
    {
        *next_in = *record;
        if( ++next_in == cache + HISTORY_DEPTH ) {
            next_in = cache;
        }
        if( count < HISTORY_DEPTH ) {
            ++count;
        }
    }

    command int is_known( History *record )
    {
        size_t limit = max(count, HISTORY_DEPTH);
        
        for( size_t i = 0; i < limit; ++i ) {
            if( cache[i].originating_node == record->originating_node &&
                cache[i].time_stamp == record->time_stamp ) {
                break;
            }
        }

        return (i == limit ? 0 : 1);
    }
    
}
