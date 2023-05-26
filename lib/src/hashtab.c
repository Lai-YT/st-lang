#include "hashtab.h"

#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <stddef.h>  // NULL
#include <stdlib.h>
#include <string.h>

static bool is_prime(int n);
/// @return The first prime equal or larger than n.
static int next_prime(int n);

/// @brief The underlying data structure that represents the key-value pair of
/// the hash table.
typedef struct Item {
  char* key;
  void* val;  // void* is used for generic
} Item;

struct HashTable {
  int capacity;
  int size;
  Item** items;
};

int hashtab_size(HashTable* ht) {
  return ht->size;
}

/// @note val may or may not be heap-allocated, its ownership isn't taken.
static Item* hashtab_create_item(const char* key, void* val) {
  Item* item = malloc(sizeof(Item));
  item->key = malloc(sizeof(char) * (strlen(key) + 1 /* null terminator */));
  strcpy(item->key, key);
  item->val = val;
  return item;
}

/// @note The val in the item is not freed.
static void hashtab_delete_item(Item* item) {
  free(item->key);
  free(item);
}

static HashTable* hashtab_create_with_capacity(int capacity) {
  HashTable* ht = malloc(sizeof(HashTable));
  ht->capacity = capacity;
  ht->size = 0;
  // initialize to NULL, which means unused
  ht->items = calloc(ht->capacity, sizeof(Item));
  return ht;
}

HashTable* hashtab_create() {
  return hashtab_create_with_capacity(next_prime(HASHTAB_BASE_CAPACITY));
}

void hashtab_delete(HashTable* ht) {
  for (int i = 0; i < ht->capacity; i++) {
    if (ht->items[i]) {
      hashtab_delete_item(ht->items[i]);
      ht->items[i] = NULL;
    }
  }
  free(ht->items);
  free(ht);
}

/// @return The integer hash of the string s, which is in range (0,
/// num_of_buckets].
/// @param s The string to be hashed.
/// @param prime Can be roughly equal to the number of characters in the
/// alphabet of s.
/// @param num_of_buckets
/// @details Using the polynomial rolling hash.
static int hashtab_hash(const char* s, int prime, int num_of_buckets) {
  int hash = 0;
  int prime_pow = 1;
  for (size_t i = 0; s[i] != '\0'; i++) {
    hash += (s[i] * prime_pow) % num_of_buckets;
    prime_pow = (prime_pow * prime) % num_of_buckets;
  }
  return hash;
}

/// @brief A double hashing function that hashes the key into [0, capacity).
/// @note Hashing is a large topic. This hash function is easy but may not be
/// good.
static int hashtab_get_hashed_key(const char* key, int capacity, int attempt) {
  // Our alphabet is the ASCII codes, which has 128 characters.
  // Choose two primes larger than that.
  int prime_1 = 131;
  int hash_1 = hashtab_hash(key, prime_1, capacity);
  int prime_2 = 151;
  int hash_2 = hashtab_hash(key, prime_2, capacity);
  return (hash_1 + attempt * (hash_2 + 1 /* never zero */)) % capacity;
}

/// @brief The items that points to this marker is deleted.
static Item* const HASHTAB_DELETE_MARKER = NULL;

/// @return Whether the key of the item is "key".
/// @note Not null-safe.
static bool hashtab_has_key(Item* item, const char* key) {
  return item != HASHTAB_DELETE_MARKER && strcmp(item->key, key) == 0;
}

/// @note An internal-use-only helper that returns the item for modification.
/// @return The pointer to the position of the item with key. If the key does
/// not exist, returns the position where the key should be if it is inserted.
static Item** hashtab_search_item(HashTable* ht, const char* key) {
  int attempt = 0;
  int i;
  do {
    i = hashtab_get_hashed_key(key, ht->capacity, attempt++);
  } while (ht->items[i] && !hashtab_has_key(ht->items[i], key));
  return &ht->items[i];
}

/// @return An integer between 0 and 100.
static int get_load_factor(HashTable* ht) {
  // avoid floating-point arithmetic
  return ht->size * 100 / ht->capacity;
}

static bool is_high_load(HashTable* ht) {
  return get_load_factor(ht) > 70;
}

static bool is_low_load(HashTable* ht) {
  return get_load_factor(ht) < 10;
}

/// @note If the capacity is lower than HASHTAB_BASE_CAPACITY,
/// HASHTAB_BASE_CAPACITY is used; if the capacity is not a prime number, the
/// greater closet prime number is used.
static void hashtab_resize(HashTable* old, int capacity);

/// @details Double up the capacity if the table is under high load after the
/// insertion.
void hashtab_insert(HashTable* ht, const char* key, void* val) {
  Item** item_p = hashtab_search_item(ht, key);
  if (*item_p) {
    hashtab_delete_item(*item_p);
    ht->size--;
  }
  *item_p = hashtab_create_item(key, val);
  ht->size++;

  if (is_high_load(ht)) {
    hashtab_resize(ht, ht->capacity * 2);
  }
}

void* hashtab_search(HashTable* ht, const char* key) {
  Item** item_p = hashtab_search_item(ht, key);
  return *item_p ? (*item_p)->val : NULL;
}

/// @details Half down the capacity if the table is under low load after the
/// deletion.
void hashtab_remove(HashTable* ht, const char* key) {
  Item** item_p = hashtab_search_item(ht, key);
  if (*item_p) {
    hashtab_delete_item(*item_p);
    *item_p = HASHTAB_DELETE_MARKER;
    ht->size--;

    if (is_low_load(ht)) {
      hashtab_resize(ht, ht->capacity / 2);
    }
  }
}

static void hashtab_resize(HashTable* old, int capacity) {
  if (capacity < HASHTAB_BASE_CAPACITY) {
    capacity = HASHTAB_BASE_CAPACITY;
  }
  if (!is_prime(capacity)) {
    capacity = next_prime(capacity);
  }

  // 2. Create a new has2 table with the new capacity
  HashTable* new = hashtab_create_with_capacity(capacity);

  // 2. Insert the items of the old table into the new table
  for (int i = 0; i < old->capacity; i++) {
    Item* item = old->items[i];
    if (item && item != HASHTAB_DELETE_MARKER) {
      hashtab_insert(new, item->key, item->val);
    }
  }

  // 3. Point to the new table
  HashTable ht_to_free = *old;
  *old = *new;

  // 4. Free the old table
  *new = ht_to_free;
  // free the items from old and the table itself from new
  hashtab_delete(new);
}

struct HashTableIterator {
  int pos;
  int seen_so_far;
  HashTable* ht;
};

HashTableIterator* hashtab_itr_create(HashTable* ht) {
  HashTableIterator* itr = malloc(sizeof(HashTableIterator));
  itr->ht = ht;
  itr->pos
      = -1;  // if init to 0, hashtab_itr_to_next may skip the first used pair
  itr->seen_so_far = 0;
  return itr;
}

void hashtab_itr_delete(HashTableIterator* itr) {
  free(itr);
}

bool hashtab_itr_is_done(HashTableIterator* itr) {
  return itr->seen_so_far == itr->ht->size;
}

void hashtab_itr_to_next(HashTableIterator* itr) {
  assert(!hashtab_itr_is_done(itr));
  for (itr->pos++; itr->pos < itr->ht->capacity; itr->pos++) {
    if (itr->ht->items[itr->pos]
        && itr->ht->items[itr->pos] != HASHTAB_DELETE_MARKER) {
      itr->seen_so_far++;
      return;
    }
  }
}

const char* hashtab_itr_key(HashTableIterator* itr) {
  assert(itr->pos != -1);
  return itr->ht->items[itr->pos]->key;
}

void* hashtab_itr_value(HashTableIterator* itr) {
  assert(itr->pos != -1);
  return itr->ht->items[itr->pos]->val;
}

static bool is_prime(int n) {
  if (n < 2) {
    return false;
  }
  if (n < 4) {
    return true;
  }

  // fast pass the even number easily, and check odd numbers only
  if (n % 2 == 0) {
    return false;
  }
  const int the_sqrt = floor(sqrt(n));
  for (int i = 3; i <= the_sqrt; i += 2) {
    if (n % i == 0) {
      return false;
    }
  }
  return true;
}

static int next_prime(int n) {
  if (n < 0) {
    return 2;
  }
  while (!is_prime(n)) {
    n++;
  }
  return n;
}
