CC := gcc
CFLAG := -std=c99
SRC := $(shell find src/ -name *.c)
OBJ := $(addprefix obj/, $(notdir $(SRC:.c=.o)))
TEST_HEADER := $(shell find test/ -name *.h)

.PHONY: dirs clean fmt tests

all: dirs tests

tests: bin/tests
	@echo "Run tests..."
	@./$<

bin/tests: test/main.c $(OBJ) $(TEST_HEADER)
	$(CC) -o $@ $< $(OBJ) $(CFLAG)

obj/%.o: src/%.c
	$(CC) -c -o $@ $< $(CFLAG)

clean:
	rm -rf obj/ bin/

dirs:
	mkdir -p bin obj

fmt:
	clang-format -i -style=file \
		src/*.h src/*.c test/*.h test/*.c
