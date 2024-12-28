#include <YSI_Coding\y_hooks>

/**
 * # Header
 */

static enum E_ACCOUNT_DATA {
    E_ACCOUNT_HASH[BCRYPT_HASH_LENGTH],

    E_ACCOUNT_DATABASE_ID,
    E_ACCOUNT_JOB_ID,
    E_ACCOUNT_ADMIN_LEVEL,

    Float:E_ACCOUNT_HUNGER,
    Float:E_ACCOUNT_THIRST,
    Float:E_ACCOUNT_ENERGY,

    Timestamp:E_ACCOUNT_CREATED_AT,
    Timestamp:E_ACCOUNT_UPDATED_AT
};

static 
    gAccountData[MAX_PLAYERS][E_ACCOUNT_DATA]
;

// External
forward OnPlayerLogin(playerid);
forward OnPlayerLogout(playerid);
forward OnPlayerRegister(playerid);

// Internal
forward OnPlayerLoginResponse(playerid, dialogid, response, listitem, string:inputtext[]);
forward OnPlayerRegisterResponse(playerid, dialogid, response, listitem, string:inputtext[]);
forward OnPlayerSexResponse(playerid, dialogid, response, listitem, string:inputtext[]);

/**
 * # External
 */

stock SetAccountJob(playerid, value) {
    gAccountData[playerid][E_ACCOUNT_JOB_ID] = value;
}

stock GetAccountJob(playerid) {
    return gAccountData[playerid][E_ACCOUNT_JOB_ID];
}

stock SetAccountAdminLevel(playerid, value) {
    gAccountData[playerid][E_ACCOUNT_ADMIN_LEVEL] = value;
}

stock GetAccountAdminLevel(playerid) {
    return gAccountData[playerid][E_ACCOUNT_ADMIN_LEVEL];
}

stock SetAccountHunger(playerid, Float:value) {
    gAccountData[playerid][E_ACCOUNT_HUNGER] = value;
}

stock Float:GetAccountHunger(playerid) {
    return gAccountData[playerid][E_ACCOUNT_HUNGER];
}

stock SetAccountThirst(playerid, Float:value) {
    gAccountData[playerid][E_ACCOUNT_THIRST] = value;
}

stock Float:GetAccountThirst(playerid) {
    return gAccountData[playerid][E_ACCOUNT_THIRST];
}

stock SetAccountEnergy(playerid, Float:value) {
    gAccountData[playerid][E_ACCOUNT_ENERGY] = value;
}

stock Float:GetAccountEnergy(playerid) {
    return gAccountData[playerid][E_ACCOUNT_ENERGY];
}

stock Timestamp:GetAccountCreatedAt(playerid) {
    return gAccountData[playerid][E_ACCOUNT_CREATED_AT];
}

stock Timestamp:GetAccountUpdatedAt(playerid) {
    return gAccountData[playerid][E_ACCOUNT_UPDATED_AT];
}

/**
 * # Internal
 */

static SaveAccountInternal(playerid) {
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
        UPDATE \
            `ACCOUNTS` \
        SET \
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
            `UPDATED_AT`   = STRFTIME('%%Y-%%m-%%d %%H:%%M:%%S', 'NOW', 'LOCALTIME') \
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
        x,
        y,
        z,
        a,
        gAccountData[playerid][E_ACCOUNT_DATABASE_ID]
    );

    // Call
    CallLocalFunction("OnPlayerLogout", "i", playerid);
}

static ResetPlayerDataInternal(playerid) {
    ResetPlayerMoney(playerid);
    ResetPlayerWeapons(playerid);

    SetPlayerScore(playerid,        0);
    SetPlayerSkin(playerid,         0);
    SetPlayerInterior(playerid,     0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerWantedLevel(playerid,  0);
    SetPlayerHealth(playerid,       0);
    SetPlayerArmour(playerid,       0);

    gAccountData[playerid][E_ACCOUNT_DATABASE_ID] = 0;
    gAccountData[playerid][E_ACCOUNT_JOB_ID]      = 0;
    gAccountData[playerid][E_ACCOUNT_ADMIN_LEVEL] = 0;
    gAccountData[playerid][E_ACCOUNT_HUNGER]      = 0.0;
    gAccountData[playerid][E_ACCOUNT_THIRST]      = 0.0;
    gAccountData[playerid][E_ACCOUNT_ENERGY]      = 0.0;
}

/**
 * # Calls
 */

hook OnPlayerRequestClass(playerid, classid) {
    new const
        DBResult:result = DB_ExecuteQuery(DB_GetHandle(), "SELECT `HASH` FROM `ACCOUNTS` WHERE `NAME` = '%q' LIMIT 1;", ReturnPlayerName(playerid))
    ;

    if (DB_GetRowCount(result)) {
        DB_GetFieldStringByName(result, "HASH", gAccountData[playerid][E_ACCOUNT_HASH]);

        Dialog_ShowCallback(playerid, using public OnPlayerLoginResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Entrando",
            "{FFFFFF}Coloque sua senha abaixo para entrar com sua conta no servidor:",
            "Entrar", "Sair"
        );
    } else {
        Dialog_ShowCallback(playerid, using public OnPlayerRegisterResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Cadastrando",
            "{FFFFFF}Coloque uma senha abaixo para cadastrar sua conta no servidor:",
            "Cadastrar", "Sair"
        );
    }
    
    DB_FreeResultSet(result);

    return 1;
}

hook OnPlayerConnect(playerid) {
    ResetPlayerDataInternal(playerid);

    return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
    SaveAccountInternal(playerid);

    return 1;
}

/**
 * # Dialogs
 */

hook OnPlayerLoginResponse(playerid, dialogid, response, listitem, string:inputtext[]) {
    if (!response) {
        return Kick(playerid);
    }

    inline const OnPasswordChecked(bool:success) {
        if (success) {
            new const
                DBResult:result = DB_ExecuteQuery(DB_GetHandle(), "\
                    SELECT \
                        *, \
                        STRFTIME('%%Y-%%m-%%dT%%H:%%M:%%S', `CREATED_AT`) AS `CREATED_AT_LOCAL`, \
                        STRFTIME('%%Y-%%m-%%dT%%H:%%M:%%S', `UPDATED_AT`) AS `UPDATED_AT_LOCAL` \
                    FROM \
                        `ACCOUNTS` \
                    WHERE \
                        `NAME` = '%q' LIMIT 1;", ReturnPlayerName(playerid))
            ;

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

            // Chrono
            new
                output[32]
            ;

            DB_GetFieldStringByName(result, "CREATED_AT_LOCAL", output);
            TimeParse(output, ISO6801_FULL_LOCAL, gAccountData[playerid][E_ACCOUNT_CREATED_AT]);

            DB_GetFieldStringByName(result, "UPDATED_AT_LOCAL", output);
            TimeParse(output, ISO6801_FULL_LOCAL, gAccountData[playerid][E_ACCOUNT_UPDATED_AT]);

            // Spawn
            SetSpawnInfo(playerid,
                NO_TEAM,
                DB_GetFieldIntByName(result, "SKIN_ID"),
                DB_GetFieldFloatByName(result, "X"), DB_GetFieldFloatByName(result, "Y"), DB_GetFieldFloatByName(result, "Z"), DB_GetFieldFloatByName(result, "A")
            );

            TogglePlayerSpectating(playerid, false);
            PlayerChearChat(playerid, 30);
            SpawnPlayer(playerid);

            // Free
            DB_FreeResultSet(result);

            // Call
            CallLocalFunction("OnPlayerLogin", "i", playerid);
        } else {
            Dialog_ShowCallback(playerid, using public OnPlayerLoginResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Entrando",
                "{FFFFFF}Coloque sua senha abaixo para entrar com sua conta no servidor:\n\n{FF0000}Senha incorreta. Tente novamente!",
                "Entrar", "Sair"
            );
        }
    }

    BCrypt_CheckInline(
        inputtext,
        gAccountData[playerid][E_ACCOUNT_HASH],
        using inline OnPasswordChecked \
    );

    return 1;
}

public OnPlayerRegisterResponse(playerid, dialogid, response, listitem, string:inputtext[]) {
    if (!response) {
        return Kick(playerid);
    }

    if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH)) {
        return Dialog_ShowCallback(playerid, using public OnPlayerRegisterResponse<iiiis>, DIALOG_STYLE_PASSWORD, "Cadastrando",
            "{FFFFFF}Coloque uma senha abaixo para cadastrar sua conta no servidor:\n\n{FF0000}Coloque uma senha entre "#MIN_PASSWORD_LENGTH" e "#MAX_PASSWORD_LENGTH" caracteres.",
            "Cadastrar", "Sair"
        );
    }

    format(
        gAccountData[playerid][E_ACCOUNT_HASH],
        _,
        inputtext
    );

    Dialog_ShowCallback(playerid, using public OnPlayerSexResponse<iiiis>, DIALOG_STYLE_LIST, "Sexo", "Masculino\nFeminino", "Selecionar", "Sair");

    return 1;
}

public OnPlayerSexResponse(playerid, dialogid, response, listitem, string:inputtext[]) {
    if (!response) {
        return Kick(playerid);
    }

    inline const OnPasswordHashed(string:hash[]) {
        SetSpawnInfo(playerid, 
            NO_TEAM, 
            listitem ? START_SKIN_FEMALE : START_SKIN_MALE,
            START_X, START_Y, START_Z, START_A
        );
        
        TogglePlayerSpectating(playerid, false);
        PlayerChearChat(playerid, 30);
        SpawnPlayer(playerid);
        GivePlayerMoney(playerid, START_MONEY);

        DB_ExecuteQuery(DB_GetHandle(), "INSERT INTO `ACCOUNTS` (`NAME`, `HASH`, `SKIN_ID`) VALUES ('%q', '%q', %i);",
            ReturnPlayerName(playerid),
            hash,
            GetPlayerSkin(playerid)
        );

        new const
            DBResult:result = DB_ExecuteQuery(DB_GetHandle(), "SELECT `ID` FROM `ACCOUNTS` WHERE `NAME` = '%q' LIMIT 1;", ReturnPlayerName(playerid))
        ;

        format(gAccountData[playerid][E_ACCOUNT_HASH], _, hash);
        gAccountData[playerid][E_ACCOUNT_DATABASE_ID] = DB_GetFieldIntByName(result, "ID");

        // Free
        DB_FreeResultSet(result);

        // Call
        CallLocalFunction("OnPlayerRegister", "i", playerid);
    }

    BCrypt_HashInline(
        gAccountData[playerid][E_ACCOUNT_HASH],
        BCRYPT_COST,
        using inline OnPasswordHashed \
    );

    return 1;
}