#include "list.h"

#include <stdlib.h>

List* list_create(void* val, List* rest) {
  List* new_list = malloc(sizeof(List));
  new_list->val = val;
  new_list->rest = rest;
  return new_list;
}

void list_delete(List* list) {
  while (list) {
    List* rest = list->rest;
    free(list);
    list = rest;
  }
}

int list_length(List* list) {
  int length = 0;
  while (list) {
    ++length;
    list = list->rest;
  }
  return length;
}
