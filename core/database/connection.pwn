#include <YSI_Coding\y_hooks>

/**
 * # Header
 */

static
    DB:gHandle
;

/**
 * # External
 */

stock DB:DB_GetHandle() {
    return gHandle;
}

/**
 * # Calls
 */

hook OnGameModeInit() {
    gHandle = DB_Open("database.db");

    if (!gHandle) {
        print("Failed to open a connection to database \"database.db\".");
    }

    return 1;
}

hook OnGameModeExit() {
    DB_Close(gHandle);

    return 1;
}