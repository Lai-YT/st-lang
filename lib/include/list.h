#ifndef LIB_LIST_H
#define LIB_LIST_H

typedef struct List {
  void* val;
  struct List* rest;
} List;

List* list_create(void* val, List* rest);
void list_delete(List*);

#endif /* end of include guard: LIB_LIST_H */
