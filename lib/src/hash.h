#ifndef LIB_SRC_HASH_H
#define LIB_SRC_HASH_H

#include <stdint.h>

/*
 * The following hash functions refer to http://www.cse.yorku.ca/~oz/hash.html.
 */

uint64_t djb2_hash(const char* s) {
  uint64_t hash = 5381;
  uint8_t c;
  while ((c = (uint8_t)*s++)) {
    hash = ((hash << 5) + hash) ^ c; /* hash * 33 ^ c */
  }
  return hash;
}

uint64_t sdbm_hash(const char* s) {
  uint64_t hash = 0;
  uint8_t c;
  while ((c = (uint8_t)*s++)) {
    hash = (hash << 6) + (hash << 16) - hash + c; /* hash * 65599 + c */
  }
  return hash;
}

#endif /* end of include guard: LIB_SRC_HASH_H */
