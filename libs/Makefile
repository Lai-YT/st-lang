CC := gcc
LIB := -lm
CFLAGS := -std=c99 -g3 -O0 $(LIB) \
	-MMD # generate dependency files
SRC := $(wildcard src/*.c)
OBJ := $(addprefix obj/, $(notdir $(SRC:.c=.o)))

# headers of test cases has their name suffixed with `test_`, and has no .c file
TEST_HEADER := $(wildcard test/test_*.h)
TEST_SRC := $(filter-out test/main.c, $(wildcard test/*.c))

# for customizing, e.g., make fmt FMTFLAGS='--dry-run --Werror'
FMTFLAGS := -i
TIDYFLAGS := --quiet

.PHONY: dirs clean tests fmt tidy

all: dirs tests

tests: bin/tests
	@echo "Run tests..."
	@./$<

# TEST_SRCs are separately compiled into object files, which is for convenience
bin/tests: test/main.c $(OBJ) $(TEST_SRC) $(TEST_HEADER)
	$(CC) -o $@ $< $(OBJ) $(TEST_SRC) $(CFLAGS)

obj/%.o: src/%.c
	$(CC) -c -o $@ $< $(CFLAGS)

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
	clang-format -style=file $(FMTFLAGS) \
		src/*.h src/*.c test/*.h test/*.c

tidy:
	clang-tidy $(TIDYFLAGS) \
		src/*.h src/*.c test/*.h test/*.c \
		-- $(CFLAGS)

-include $(SRC:.c=.d)
