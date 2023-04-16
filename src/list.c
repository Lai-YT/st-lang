#include "list.h"

#include <stdlib.h>

list_t *list_create(void *val, list_t *rest) {
  list_t *new_list = malloc(sizeof(list_t));
  new_list->val = val;
  new_list->rest = rest;
  return new_list;
}

void list_delete(list_t *list) {
  while (list) {
    list_t *rest = list->rest;
    free(list);
    list = rest;
  }
}
