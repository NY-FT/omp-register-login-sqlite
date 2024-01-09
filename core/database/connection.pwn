#include <YSI_Coding\y_hooks>

/**
 * # Header
 */

static
    DB:gHandle
;

/**
 * # Functions
 */

stock DB:DB_GetHandle() {
    return gHandle;
}

/**
 * # Hooks
 */

hook OnGameModeInit() {
    gHandle = DB_Open("database/database.db");

    if (!gHandle) {
        print("Failed to open a connection to database \"database.db\".");
    }

    return 1;
}

hook OnGameModeExit() {
    DB_Close(gHandle);

    return 1;
}