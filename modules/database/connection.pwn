#include <YSI_Coding\y_hooks>

// -----------------------------------------------------------------------------

static DB:g_s_Handle;

// -----------------------------------------------------------------------------

hook OnGameModeInit()
{
    g_s_Handle = DB_Open("database/database.db");

    if (!g_s_Handle) {
        print("Failed to open a connection to database \"database.db\".");
    }

    return 1;
}

hook OnGameModeExit()
{
    DB_Close(g_s_Handle);
    return 1;
}

// -----------------------------------------------------------------------------

stock DB:DB_GetHandle()
{
    return g_s_Handle;
}
