
#include "History.h"

interface History {
    // Installs the information about the given packet into the history database.
    command void install( History *record );

    // Looks up the given packet. This command returns True if it exists in the history
    // database. Such packages have been seen before. Otherwise this command returns false.
    command int is_known( History *record );
}
