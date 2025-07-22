#include "crypto/argon2.h"
#include <argon2.h>
#include <cstring>

void worldcoin_argon2d(const char *input, char *output)
{
    // Use block header (80 bytes) as input
    // Use a fixed salt for mining (could be derived from input)
    const char salt[] = "WorldcoinArgon2dSalt2025";

    argon2d_hash_raw(WDC_ARGON2_TIME_COST,
                     WDC_ARGON2_MEMORY_COST,
                     WDC_ARGON2_PARALLELISM,
                     input, 80,                    // 80-byte block header
                     salt, sizeof(salt) - 1,      // Fixed salt
                     output, WDC_ARGON2_HASH_LENGTH);
}