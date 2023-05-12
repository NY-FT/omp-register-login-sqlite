stock GetPlayerNamef(playerid)
{
    static 
        name[MAX_PLAYER_NAME + 1];

    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

stock Float:GetPlayerHealthf(playerid)
{
    static 
        Float:value;

    GetPlayerHealth(playerid, value);
    return value;
}

stock Float:GetPlayerArmourf(playerid)
{
    static 
        Float:value;

    GetPlayerArmour(playerid, value);
    return value;
}

stock void:PlayerChearChat(playerid, rows)
{
    for (new i; i < rows; i++) {
        SendClientMessage(playerid, -1, #);
    }
}
