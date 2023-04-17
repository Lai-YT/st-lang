CC := gcc
CFLAG := -std=c99 -g3 -O0
SRC := $(shell find src/ -name *.c)
OBJ := $(addprefix obj/, $(notdir $(SRC:.c=.o)))
TEST_HEADER := $(shell find test/ -name *.h)

.PHONY: dirs clean tests fmt tidy

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

valgrind: bin/tests
	@valgrind \
		--track-origins=yes \
		--show-leak-kinds=all \
		--leak-check=full \
		--leak-resolution=high \
		--error-exitcode=1 \
		$<

fmt:
	clang-format -i -style=file \
		src/*.h src/*.c test/*.h test/*.c

tidy:
	clang-tidy --quiet \
		src/*.h src/*.c test/*.h test/*.c \
		-- $(CFLAG)
