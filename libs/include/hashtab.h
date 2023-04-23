#ifndef SRC_HASHTAB_H
#define SRC_HASHTAB_H

#include <stdbool.h>

#ifndef HASHTAB_BASE_CAPACITY
/// @brief Define before including this file if you want to use another base
/// capacity. The actual capacity will be the greater closest prime.
#define HASHTAB_BASE_CAPACITY 53
#endif

/// @brief A hash table that takes a char string as the key.
typedef struct HashTable HashTable;

/// @return How many items there are in the hash table.
int hashtab_size(HashTable*);

/// @note Should be freed after use with hashtab_delete.
HashTable* hashtab_create();

/// @note Frees the hash table created previously with hashtab_create. The
/// inserted vals are not freed.
void hashtab_delete(HashTable*);

/// @brief Inserts the key-val pair into the hash table. val is updated if key
/// already exists.
/// @note The val may or may not be heap-allocated since the hash table does
/// not take the ownership. If val is heap allocated, the caller has to free it
/// manually (you may use an iterator).
void hashtab_insert(HashTable* ht, const char* key, void* val);

/// @return The val mapped by key; NULL if not exists.
void* hashtab_search(HashTable*, const char* key);

/// @brief Removes the key and its val from the table if the key exists.
/// @note The val is not freed since its ownership isn't taken.
void hashtab_remove(HashTable*, const char* key);

/// @brief An iterator that augments the usage of the hash table.
typedef struct HashTableIterator HashTableIterator;

/// @note The iterator becomes invalid once an operation is made during
/// iteration.
HashTableIterator* hashtab_itr_create(HashTable*);

void hashtab_itr_delete(HashTableIterator*);

/// @exception Assertion error if no preceding call on hashtab_itr_to_next.
const char* hashtab_itr_key(HashTableIterator*);

/// @exception Assertion error if no preceding call on hashtab_itr_to_next.
void* hashtab_itr_value(HashTableIterator*);

/// @return Whether there are items remained in the hash table.
bool hashtab_itr_is_done(HashTableIterator*);

/// @note Only call this function on an iterator that's not done.
/// @exception Assertion error if the iterator is done.
void hashtab_itr_to_next(HashTableIterator*);

/// @brief Iterates over the hash table with an iterator and executes the
/// statement for each iteration.
/// @param ht The hash table to iterate over.
/// @param itr_name The name of the iterator to be created by this macro, which
/// can be used within the statement to refer to the current value or key.
/// @param statement The statement to execute in every iteration.If there are
/// multiple statements, they should be enclosed in curly brackets. The
/// statement can use the `continue` and `break` keywords to control the
/// iteration, and the `return` keyword to exit the function that calls this
/// macro.
/// @note This macro creates an iterator object internally and deletes it after
/// the iteration is complete.
#define HASHTAB_ITR_FOR_EACH(ht, itr_name, statement)      \
  {                                                        \
    HashTableIterator*(itr_name) = hashtab_itr_create(ht); \
    while (!hashtab_itr_is_done(itr_name)) {               \
      hashtab_itr_to_next(itr_name);                       \
      statement;                                           \
    }                                                      \
    hashtab_itr_delete(itr_name);                          \
  }

#endif /* end of include guard: SRC_HASHTAB_H */
