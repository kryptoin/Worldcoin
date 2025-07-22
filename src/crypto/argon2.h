#ifndef BITCOIN_CRYPTO_ARGON2_H
#define BITCOIN_CRYPTO_ARGON2_H

#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

// Argon2d parameters for Worldcoin mining
static const uint32_t WDC_ARGON2_TIME_COST = 1;     // 1 iteration
static const uint32_t WDC_ARGON2_MEMORY_COST = 4096; // 4MB memory
static const uint32_t WDC_ARGON2_PARALLELISM = 1;   // Single thread
static const uint32_t WDC_ARGON2_HASH_LENGTH = 32;  // 256-bit output

void worldcoin_argon2d(const char *input, char *output);

#ifdef __cplusplus
}
#endif

#endif // BITCOIN_CRYPTO_ARGON2_H