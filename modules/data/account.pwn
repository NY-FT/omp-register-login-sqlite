#include <YSI_Coding\y_hooks>

// --------------------------------------------------------------------------------

#define MIN_PASSWORD_LENGTH         4
#define MAX_PASSWORD_LENGTH         16

#define START_MONEY                 500
#define START_SKIN_MALE             60
#define START_SKIN_FEMALE           56

#define START_X                     0.0
#define START_Y                     0.0
#define START_Z                     0.0
#define START_A                     0.0

// --------------------------------------------------------------------------------

static enum E_PLAYER_ACCOUNT_DATA
{
    E_PLAYER_PASSWORD[BCRYPT_HASH_LENGTH],

    E_PLAYER_DATABASE_ID,
    E_PLAYER_JOB_ID,
    E_PLAYER_ADMIN_LEVEL,

    Float:E_PLAYER_HUNGER,
    Float:E_PLAYER_THIRST,
    Float:E_PLAYER_ENERGY,

    E_PLAYER_CREATED_AT,
    E_PLAYER_UPDATED_AT
};

static g_s_PlayerAccount[MAX_PLAYERS][E_PLAYER_ACCOUNT_DATA];

// --------------------------------------------------------------------------------

static stock void:__DB_SaveAccount(playerid)
{
    new 
        Float:x, 
        Float:y, 
        Float:z, 
        Float:a;

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    DB_ExecuteQuery(DB_GetHandle(), "\
        UPDATE `ACCOUNTS` SET \
            `MONEY`        = %i, \
            `SCORE`        = %i, \
            `SKIN_ID`      = %i, \
            `INTERIOR_ID`  = %i, \
            `WORLD_ID`     = %i, \
            `WANTED_LEVEL` = %i, \
            `HEALTH`       = %.1f, \
            `ARMOUR`       = %.1f, \
            `JOB_ID`       = %i, \
            `ADMIN_LEVEL`  = %i, \
            `HUNGER`       = %.1f, \
            `THIRST`       = %.1f, \
            `ENERGY`       = %.1f, \
            `X`            = %.4f, \
            `Y`            = %.4f, \
            `Z`            = %.4f, \
            `A`            = %.4f, \
            `UPDATED_AT`   = %i \
        WHERE \
            `ID`           = %i;", 
        GetPlayerMoney(playerid), 
        GetPlayerScore(playerid), 
        GetPlayerSkin(playerid), 
        GetPlayerInterior(playerid), 
        GetPlayerVirtualWorld(playerid), 
        GetPlayerWantedLevel(playerid), 
        GetPlayerHealthf(playerid), 
        GetPlayerArmourf(playerid), 
        g_s_PlayerAccount[playerid][E_PLAYER_JOB_ID], 
        g_s_PlayerAccount[playerid][E_PLAYER_ADMIN_LEVEL], 
        g_s_PlayerAccount[playerid][E_PLAYER_HUNGER], 
        g_s_PlayerAccount[playerid][E_PLAYER_THIRST], 
        g_s_PlayerAccount[playerid][E_PLAYER_ENERGY], 
        x, y, z, a, gettime(),
        g_s_PlayerAccount[playerid][E_PLAYER_DATABASE_ID]
    );
}

static stock void:__ResetPlayerData(playerid)
{
    new 
        gt = gettime();

    ResetPlayerMoney(playerid);
    ResetPlayerWeapons(playerid);

    SetPlayerScore(playerid,        0);
    SetPlayerSkin(playerid,         0);
    SetPlayerInterior(playerid,     0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerWantedLevel(playerid,  0);
    SetPlayerHealth(playerid,       0);
    SetPlayerArmour(playerid,       0);

    g_s_PlayerAccount[playerid][E_PLAYER_DATABASE_ID] = 0;
    g_s_PlayerAccount[playerid][E_PLAYER_JOB_ID]      = 0;
    g_s_PlayerAccount[playerid][E_PLAYER_ADMIN_LEVEL] = 0;
    g_s_PlayerAccount[playerid][E_PLAYER_HUNGER]      = 0.0;
    g_s_PlayerAccount[playerid][E_PLAYER_THIRST]      = 0.0;
    g_s_PlayerAccount[playerid][E_PLAYER_ENERGY]      = 0.0;
    g_s_PlayerAccount[playerid][E_PLAYER_UPDATED_AT]  = gt;
    g_s_PlayerAccount[playerid][E_PLAYER_CREATED_AT]  = gt;
}

// -------------------------------------------------------------------------------------

hook OnPlayerRequestClass(playerid, classid)
{
    PlayerChearChat(playerid, 30);
    TogglePlayerSpectating(playerid, true);

    new 
        DBResult:result = DB_ExecuteQuery(DB_GetHandle(), "SELECT `PASSWORD` FROM `ACCOUNTS` WHERE `NAME` = '%q' LIMIT 1", GetPlayerNamef(playerid));

    if (DB_GetRowCount(result)) 
    {
        DB_GetFieldStringByName(result, "PASSWORD", g_s_PlayerAccount[playerid][E_PLAYER_PASSWORD]);

        Dialog_ShowCallback(playerid, using public OnPlayerEnterResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Entrando", 
            "{FFFFFF}* Coloque sua senha abaixo para entrar com sua conta no servidor:", 
            "Entrar", "Sair"
        );
    }
    else
    {
        Dialog_ShowCallback(playerid, using public OnPlayerCadasterResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Cadastrando", 
            "{FFFFFF}* Coloque uma senha abaixo para cadastrar sua conta no servidor:", 
            "Cadastrar", "Sair"
        );
    }

    DB_FreeResultSet(result);
    return 1;
}

hook OnPlayerConnect(playerid)
{
    __ResetPlayerData(playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    __DB_SaveAccount(playerid);
    return 1;
}

hook OnPlayerCadasterResponse(playerid, dialogid, response, listitem, string:inputtext[])
{
    #pragma unused dialogid
    #pragma unused listitem

    if (!response) {
        return Kick(playerid);
    }

    if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH)) 
    {
        return Dialog_ShowCallback(playerid, using public OnPlayerCadasterResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Cadastrando", 
            "{FFFFFF}* Coloque uma senha abaixo para cadastrar sua conta no servidor:\n\n{FF0000}* Coloque uma senha entre "#MIN_PASSWORD_LENGTH" e "#MAX_PASSWORD_LENGTH" caracteres.", 
            "Cadastrar", "Sair"
        );
    }

    format(
        g_s_PlayerAccount[playerid][E_PLAYER_PASSWORD], 
        MAX_PASSWORD_LENGTH + 1, 
        inputtext
    );

    Dialog_ShowCallback(playerid, using public OnPlayerGenderResponse<iiiis>, DIALOG_STYLE_LIST, "Genero", 
        "Masculino\nFeminino", 
        "Selecionar", "Sair"
    );

    return 1;
}

hook OnPlayerGenderResponse(playerid, dialogid, response, listitem, string:inputtext[])
{
    #pragma unused dialogid
    #pragma unused inputtext

    if (!response) {
        return Kick(playerid);
    }

    inline const OnPasswordHashed(string:hash[])
    {
        format(
            g_s_PlayerAccount[playerid][E_PLAYER_PASSWORD], 
            BCRYPT_HASH_LENGTH, 
            hash
        );

        SetSpawnInfo(playerid, 
            NO_TEAM, 
            listitem ? START_SKIN_FEMALE : START_SKIN_MALE,
            START_X, START_Y, START_Z, START_A
        );
        
        TogglePlayerSpectating(playerid, false);
        PlayerChearChat(playerid, 30);
        SpawnPlayer(playerid);
        GivePlayerMoney(playerid, START_MONEY);

        DB_ExecuteQuery(DB_GetHandle(), "INSERT INTO `ACCOUNTS` (`NAME`, `PASSWORD`, `SKIN_ID`, `CREATED_AT`) VALUES ('%q', '%q', %i, %i);",
            GetPlayerNamef(playerid),
            hash,
            GetPlayerSkin(playerid),
            gettime()
        );

        new DBResult:result = DB_ExecuteQuery(DB_GetHandle(), "SELECT LAST_INSERT_ROWID();");
        g_s_PlayerAccount[playerid][E_PLAYER_DATABASE_ID] = DB_GetFieldInt(result);
        DB_FreeResultSet(result);
    }

    BCrypt_HashInline(
        g_s_PlayerAccount[playerid][E_PLAYER_PASSWORD], 
        BCRYPT_COST, 
        using inline OnPasswordHashed \
    );

    return 1;
}

hook OnPlayerEnterResponse(playerid, dialogid, response, listitem, string:inputtext[])
{
    #pragma unused dialogid
    #pragma unused listitem

    if (!response) {
        return Kick(playerid);
    }

    inline const OnPasswordMatched(bool:sucess)
    {
        if (sucess)
        {
            new 
                DBResult:result = DB_ExecuteQuery(DB_GetHandle(), "SELECT * FROM `ACCOUNTS` WHERE `NAME` = '%q' LIMIT 1", GetPlayerNamef(playerid));

            GivePlayerMoney(playerid,       DB_GetFieldIntByName(result, "MONEY"));
            SetPlayerScore(playerid,        DB_GetFieldIntByName(result, "SCORE"));
            SetPlayerInterior(playerid,     DB_GetFieldIntByName(result, "INTERIOR_ID"));
            SetPlayerVirtualWorld(playerid, DB_GetFieldIntByName(result, "WORLD_ID"));
            SetPlayerWantedLevel(playerid,  DB_GetFieldIntByName(result, "WANTED_LEVEL"));
            SetPlayerHealth(playerid,       DB_GetFieldFloatByName(result, "HEALTH"));
            SetPlayerArmour(playerid,       DB_GetFieldFloatByName(result, "ARMOUR"));

            g_s_PlayerAccount[playerid][E_PLAYER_DATABASE_ID] = DB_GetFieldIntByName(result, "ID");
            g_s_PlayerAccount[playerid][E_PLAYER_JOB_ID]      = DB_GetFieldIntByName(result, "JOB_ID");
            g_s_PlayerAccount[playerid][E_PLAYER_ADMIN_LEVEL] = DB_GetFieldIntByName(result, "ADMIN_LEVEL");
            g_s_PlayerAccount[playerid][E_PLAYER_HUNGER]      = DB_GetFieldFloatByName(result, "HUNGER");
            g_s_PlayerAccount[playerid][E_PLAYER_THIRST]      = DB_GetFieldFloatByName(result, "THIRST");
            g_s_PlayerAccount[playerid][E_PLAYER_ENERGY]      = DB_GetFieldFloatByName(result, "ENERGY");
            g_s_PlayerAccount[playerid][E_PLAYER_CREATED_AT]  = DB_GetFieldIntByName(result, "CREATED_AT");
            g_s_PlayerAccount[playerid][E_PLAYER_UPDATED_AT]  = DB_GetFieldIntByName(result, "UPDATED_AT");

            SetSpawnInfo(playerid, 
                NO_TEAM, 
                DB_GetFieldIntByName(result, "SKIN_ID"), 
                DB_GetFieldFloatByName(result, "X"), DB_GetFieldFloatByName(result, "Y"), DB_GetFieldFloatByName(result, "Z"), DB_GetFieldFloatByName(result, "A")
            );

            TogglePlayerSpectating(playerid, false);
            PlayerChearChat(playerid, 30);
            SpawnPlayer(playerid);
            DB_FreeResultSet(result);
        }
        else
        {
            Dialog_ShowCallback(playerid, using public OnPlayerEnterResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Entrando", 
                "{FFFFFF}* Coloque sua senha abaixo para entrar com sua conta no servidor:\n\n{FF0000}* Senha incorreta. Tente novamente!", 
                "Entrar", "Sair"
            );
        }
    }

    BCrypt_CheckInline(
        inputtext, 
        g_s_PlayerAccount[playerid][E_PLAYER_PASSWORD], 
        using inline OnPasswordMatched \
    );

    return 1;
}
