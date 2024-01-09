#include <YSI_Coding\y_hooks>

/**
 * # Header
 */

#define MIN_PASSWORD_LENGTH         4
#define MAX_PASSWORD_LENGTH         16
#define DB_TIMESTAMP_LENGTH         (10 + 1 + 9)

#define START_MONEY                 500
#define START_SKIN_MALE             60
#define START_SKIN_FEMALE           56

#define START_X                     0.0
#define START_Y                     0.0
#define START_Z                     0.0
#define START_A                     0.0

static enum E_ACCOUNT_DATA {
    E_ACCOUNT_PASSWORD[BCRYPT_HASH_LENGTH],

    E_ACCOUNT_DATABASE_ID,
    E_ACCOUNT_JOB_ID,
    E_ACCOUNT_ADMIN_LEVEL,

    Float:E_ACCOUNT_HUNGER,
    Float:E_ACCOUNT_THIRST,
    Float:E_ACCOUNT_ENERGY,

    E_ACCOUNT_CREATED_AT[DB_TIMESTAMP_LENGTH + 1],
    E_ACCOUNT_UPDATED_AT[DB_TIMESTAMP_LENGTH + 1]
};

static 
    gAccountData[MAX_PLAYERS][E_ACCOUNT_DATA]
;

forward OnPlayerLoginResponse(playerid, dialogid, response, listitem, string:inputtext[]);
forward OnPlayerRegisterResponse(playerid, dialogid, response, listitem, string:inputtext[]);
forward OnPlayerGenderResponse(playerid, dialogid, response, listitem, string:inputtext[]);

/**
 * # Internal
 */

static stock void:_@_SaveAccount(playerid) {
    new 
        Float:x, 
        Float:y, 
        Float:z, 
        Float:a,
        Float:health,
        Float:armour
    ;

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    GetPlayerHealth(playerid, health);
    GetPlayerArmour(playerid, armour);

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
            `UPDATED_AT`   = STRFTIME('%%Y-%%m-%%d %%H:%%M:%%S', %i) \
        WHERE \
            `ID`           = %i;", 
        GetPlayerMoney(playerid), 
        GetPlayerScore(playerid), 
        GetPlayerSkin(playerid), 
        GetPlayerInterior(playerid), 
        GetPlayerVirtualWorld(playerid), 
        GetPlayerWantedLevel(playerid), 
        health, 
        armour, 
        gAccountData[playerid][E_ACCOUNT_JOB_ID], 
        gAccountData[playerid][E_ACCOUNT_ADMIN_LEVEL], 
        gAccountData[playerid][E_ACCOUNT_HUNGER], 
        gAccountData[playerid][E_ACCOUNT_THIRST], 
        gAccountData[playerid][E_ACCOUNT_ENERGY], 
        x, y, z, a, gettime(),
        gAccountData[playerid][E_ACCOUNT_DATABASE_ID]
    );
}

static stock void:_@_ResetPlayerData(playerid) {
    ResetPlayerMoney(playerid);
    ResetPlayerWeapons(playerid);

    SetPlayerScore(playerid,        0);
    SetPlayerSkin(playerid,         0);
    SetPlayerInterior(playerid,     0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerWantedLevel(playerid,  0);
    SetPlayerHealth(playerid,       0);
    SetPlayerArmour(playerid,       0);

    gAccountData[playerid][E_ACCOUNT_DATABASE_ID]   = 0;
    gAccountData[playerid][E_ACCOUNT_JOB_ID]        = 0;
    gAccountData[playerid][E_ACCOUNT_ADMIN_LEVEL]   = 0;
    gAccountData[playerid][E_ACCOUNT_HUNGER]        = 0.0;
    gAccountData[playerid][E_ACCOUNT_THIRST]        = 0.0;
    gAccountData[playerid][E_ACCOUNT_ENERGY]        = 0.0;
    gAccountData[playerid][E_ACCOUNT_UPDATED_AT][0] = EOS;
    gAccountData[playerid][E_ACCOUNT_CREATED_AT][0] = EOS;
}

/**
 * # Hooks
 */

hook OnPlayerRequestClass(playerid, classid) {
    #pragma unused classid

    new
        DBResult:result = DB_ExecuteQuery(DB_GetHandle(), "SELECT `PASSWORD` FROM `ACCOUNTS` WHERE `NAME` = '%q' LIMIT 1", ReturnPlayerName(playerid))
    ;

    if (DB_GetRowCount(result)) {
        DB_GetFieldStringByName(result, "PASSWORD", gAccountData[playerid][E_ACCOUNT_PASSWORD]);

        Dialog_ShowCallback(playerid, using public OnPlayerLoginResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Entrando", 
            "{FFFFFF}* Coloque sua senha abaixo para entrar com sua conta no servidor:", 
            "Entrar", "Sair"
        );
    } else {
        Dialog_ShowCallback(playerid, using public OnPlayerRegisterResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Cadastrando", 
            "{FFFFFF}* Coloque uma senha abaixo para cadastrar sua conta no servidor:", 
            "Cadastrar", "Sair"
        );
    }

    DB_FreeResultSet(result);

    return 1;
}

hook OnPlayerConnect(playerid) {
    _@_ResetPlayerData(playerid);

    return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
    #pragma unused reason

    _@_SaveAccount(playerid);

    return 1;
}

/**
 * # Callbacks
 */

hook OnPlayerLoginResponse(playerid, dialogid, response, listitem, string:inputtext[]) {
    #pragma unused dialogid
    #pragma unused listitem

    if (!response) {
        return Kick(playerid);
    }

    inline const PasswordChecked(bool:sucess) {
        if (sucess) {
            new 
                DBResult:result = DB_ExecuteQuery(DB_GetHandle(), "SELECT * FROM `ACCOUNTS` WHERE `NAME` = '%q' LIMIT 1", ReturnPlayerName(playerid))
            ;

            DB_GetFieldStringByName(result, "CREATED_AT", gAccountData[playerid][E_ACCOUNT_CREATED_AT]);
            DB_GetFieldStringByName(result, "UPDATED_AT", gAccountData[playerid][E_ACCOUNT_UPDATED_AT]);

            GivePlayerMoney(playerid,       DB_GetFieldIntByName(result, "MONEY"));
            SetPlayerScore(playerid,        DB_GetFieldIntByName(result, "SCORE"));
            SetPlayerInterior(playerid,     DB_GetFieldIntByName(result, "INTERIOR_ID"));
            SetPlayerVirtualWorld(playerid, DB_GetFieldIntByName(result, "WORLD_ID"));
            SetPlayerWantedLevel(playerid,  DB_GetFieldIntByName(result, "WANTED_LEVEL"));
            SetPlayerHealth(playerid,       DB_GetFieldFloatByName(result, "HEALTH"));
            SetPlayerArmour(playerid,       DB_GetFieldFloatByName(result, "ARMOUR"));

            gAccountData[playerid][E_ACCOUNT_DATABASE_ID] = DB_GetFieldIntByName(result, "ID");
            gAccountData[playerid][E_ACCOUNT_JOB_ID]      = DB_GetFieldIntByName(result, "JOB_ID");
            gAccountData[playerid][E_ACCOUNT_ADMIN_LEVEL] = DB_GetFieldIntByName(result, "ADMIN_LEVEL");
            gAccountData[playerid][E_ACCOUNT_HUNGER]      = DB_GetFieldFloatByName(result, "HUNGER");
            gAccountData[playerid][E_ACCOUNT_THIRST]      = DB_GetFieldFloatByName(result, "THIRST");
            gAccountData[playerid][E_ACCOUNT_ENERGY]      = DB_GetFieldFloatByName(result, "ENERGY");

            SetSpawnInfo(playerid, 
                NO_TEAM, 
                DB_GetFieldIntByName(result, "SKIN_ID"), 
                DB_GetFieldFloatByName(result, "X"), DB_GetFieldFloatByName(result, "Y"), DB_GetFieldFloatByName(result, "Z"), DB_GetFieldFloatByName(result, "A")
            );

            TogglePlayerSpectating(playerid, false);
            PlayerChearChat(playerid, 30);
            SpawnPlayer(playerid);
            DB_FreeResultSet(result);
        } else {
            Dialog_ShowCallback(playerid, using public OnPlayerLoginResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Entrando", 
                "{FFFFFF}* Coloque sua senha abaixo para entrar com sua conta no servidor:\n\n{FF0000}* Senha incorreta. Tente novamente!", 
                "Entrar", "Sair"
            );
        }
    }

    BCrypt_CheckInline(
        inputtext, 
        gAccountData[playerid][E_ACCOUNT_PASSWORD], 
        using inline PasswordChecked \
    );

    return 1;
}

public OnPlayerRegisterResponse(playerid, dialogid, response, listitem, string:inputtext[]) {
    #pragma unused dialogid
    #pragma unused listitem

    if (!response) {
        return Kick(playerid);
    }

    if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH)) {
        return Dialog_ShowCallback(playerid, using public OnPlayerRegisterResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Cadastrando", 
            "{FFFFFF}* Coloque uma senha abaixo para cadastrar sua conta no servidor:\n\n{FF0000}* Coloque uma senha entre "#MIN_PASSWORD_LENGTH" e "#MAX_PASSWORD_LENGTH" caracteres.", 
            "Cadastrar", "Sair"
        );
    }

    format(
        gAccountData[playerid][E_ACCOUNT_PASSWORD], 
        MAX_PASSWORD_LENGTH + 1, 
        inputtext
    );

    Dialog_ShowCallback(playerid, using public OnPlayerGenderResponse<iiiis>, DIALOG_STYLE_LIST, "Genero", 
        "Masculino\nFeminino", 
        "Selecionar", "Sair"
    );

    return 1;
}

public OnPlayerGenderResponse(playerid, dialogid, response, listitem, string:inputtext[]) {
    #pragma unused dialogid
    #pragma unused inputtext

    if (!response) {
        return Kick(playerid);
    }

    inline const PasswordHashed(string:hash[]) {
        format(
            gAccountData[playerid][E_ACCOUNT_PASSWORD], 
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

        DB_ExecuteQuery(DB_GetHandle(), "INSERT INTO `ACCOUNTS` (`NAME`, `PASSWORD`, `SKIN_ID`) VALUES ('%q', '%q', %i);",
            ReturnPlayerName(playerid),
            hash,
            GetPlayerSkin(playerid)
        );

        new DBResult:result = DB_ExecuteQuery(DB_GetHandle(), "SELECT `ID` FROM `ACCOUNTS` WHERE `NAME` = '%q' LIMIT 1;", ReturnPlayerName(playerid));
        gAccountData[playerid][E_ACCOUNT_DATABASE_ID] = DB_GetFieldIntByName(result, "ID");
        DB_FreeResultSet(result);
    }

    BCrypt_HashInline(
        gAccountData[playerid][E_ACCOUNT_PASSWORD], 
        BCRYPT_COST, 
        using inline PasswordHashed \
    );

    return 1;
}
