#include <stdint.h>
#include <string.h>
#include "port/port.h"

#if defined(LEVELDB_PLATFORM_POSIX_SSE)
#if defined(_MSC_VER)
#include <intrin.h>
#elif defined(__GNUC__) && defined(__SSE4_2__)
#include <nmmintrin.h>
#elif defined(__aarch64__) && defined(__ARM_FEATURE_CRC32)
#include <arm_acle.h>
#endif
#endif

namespace leveldb {
namespace port {

#if defined(LEVELDB_PLATFORM_POSIX_SSE)
static inline uint32_t LE_LOAD32(const uint8_t *p) {
  uint32_t word;
  memcpy(&word, p, sizeof(word));
  return word;
}

#if defined(_M_X64) || defined(__x86_64__) || defined(__aarch64__)
static inline uint64_t LE_LOAD64(const uint8_t *p) {
  uint64_t dword;
  memcpy(&dword, p, sizeof(dword));
  return dword;
}
#endif
#endif

uint32_t AcceleratedCRC32C(uint32_t crc, const char* buf, size_t size) {
#if !defined(LEVELDB_PLATFORM_POSIX_SSE)
  return 0;
#else
  const uint8_t *p = reinterpret_cast<const uint8_t *>(buf);
  const uint8_t *e = p + size;
  uint32_t l = crc ^ 0xffffffffu;

#if defined(__aarch64__) && defined(__ARM_FEATURE_CRC32)
  // ARM64 CRC32 intrinsics
  #define STEP1 do {                              \
      l = __crc32cb(l, *p++);                     \
  } while (0)
  #define STEP4 do {                              \
      l = __crc32cw(l, LE_LOAD32(p));             \
      p += 4;                                     \
  } while (0)
  #define STEP8 do {                              \
      l = __crc32cd(l, LE_LOAD64(p));             \
      p += 8;                                     \
  } while (0)
#elif defined(__SSE4_2__)
  // x86 SSE4.2 intrinsics
  #define STEP1 do {                              \
      l = _mm_crc32_u8(l, *p++);                  \
  } while (0)
  #define STEP4 do {                              \
      l = _mm_crc32_u32(l, LE_LOAD32(p));         \
      p += 4;                                     \
  } while (0)
  #define STEP8 do {                              \
      l = _mm_crc32_u64(l, LE_LOAD64(p));         \
      p += 8;                                     \
  } while (0)
#else
  // Fallback - should not reach here if properly configured
  return 0;
#endif

  if (size > 16) {
    for (unsigned int i = reinterpret_cast<uintptr_t>(p) % 8; i; --i) {
      STEP1;
    }
#if defined(_M_X64) || defined(__x86_64__) || defined(__aarch64__)
    while ((e-p) >= 8) {
      STEP8;
    }
    if ((e-p) >= 4) {
      STEP4;
    }
#else
    while ((e-p) >= 4) {
      STEP4;
    }
#endif
  }
  while (p != e) {
    STEP1;
  }
#undef STEP8
#undef STEP4
#undef STEP1
  return l ^ 0xffffffffu;
#endif
}

}
}