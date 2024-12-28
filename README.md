## **Dependências**

1. [Southclaws-chrono](https://github.com/Southclaws/pawn-chrono/releases)
2. [Sreyas-Sreelal-BCrypt](https://github.com/Sreyas-Sreelal/samp-bcrypt/releases)
3. [YSI-Includes](https://github.com/pawn-lang/YSI-Includes/releases)

## **Funções**

* **SetAccountJob**`(playerid, value)`
* **GetAccountJob**`(playerid)`
* **SetAccountAdminLevel**`(playerid, value)`
* **GetAccountAdminLevel**`(playerid)`
* **SetAccountHunger**`(playerid, Float:value)`
* **`Float:`GetAccountHunger**`(playerid)`
* **SetAccountThirst**`(playerid, Float:value)`
* **`Float:`GetAccountThirst**`(playerid)`
* **SetAccountEnergy**`(playerid, Float:value)`
* **`Float:`GetAccountEnergy**`(playerid)`
* **`Timestamp:`GetAccountCreatedAt**`(playerid)`
* **`Timestamp:`GetAccountUpdatedAt**`(playerid)`
 
## **Chamadas**

* **OnPlayerLogin**`(playerid)`
* **OnPlayerLogout**`(playerid)`
* **OnPlayerRegister**`(playerid)`

## **Exemplo**

```pwn
public OnPlayerLogin(playerid) {
    new
        output[32]
    ;

    TimeFormat(GetAccountUpdatedAt(playerid), "%d/%m/%Y %H:%M:%S", output);
    SendClientMessage(playerid, -1, "Entrou em: %s", output);

    return 1;
}
```