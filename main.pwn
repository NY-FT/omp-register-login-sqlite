#include <open.mp>
#include <bcrypt>
#include <chrono>

#define YSI_NO_HEAP_MALLOC

// Y
#include <YSI_Coding\y_hooks>
#include <YSI_Visual\y_dialog>
#include <YSI_Extra\y_inline_bcrypt>

/**
 * # Header
 */

#define MIN_PASSWORD_LENGTH (4)
#define MAX_PASSWORD_LENGTH (16)

#define START_MONEY (500)
#define START_SKIN_MALE (60)
#define START_SKIN_FEMALE (56)

#define START_X (0.0)
#define START_Y (0.0)
#define START_Z (0.0)
#define START_A (0.0)

// Database
#include ".\core\database\connection.pwn"

// Util
#include ".\core\util\player.pwn"

// Player
#include ".\core\player\account.pwn"

main(){}