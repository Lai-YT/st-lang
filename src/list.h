#ifndef SRC_LIST_H
#define SRC_LIST_H

typedef struct list {
  void *val;
  struct list *rest;
} list_t;

list_t *list_create(void *val, list_t *rest);
void list_delete(list_t *);

#endif /* end of include guard: SRC_LIST_H */
