CC := gcc
CFLAG := -std=c99 -g3 -O0
SRC := $(shell find src/ -name *.c)
OBJ := $(addprefix obj/, $(notdir $(SRC:.c=.o)))

# headers of test cases has their name suffixed with `test_`, and has no .c file
TEST_HEADER := $(shell find test/ -name test_*.h)
TEST_SRC := $(shell find test/ -name *.c ! -name main.c)

# for customizing, e.g., make fmt FMTFLAG='--dry-run --Werror'
FMTFLAG := -i
TIDYFLAG := --quiet

.PHONY: dirs clean tests fmt tidy

all: dirs tests

tests: bin/tests
	@echo "Run tests..."
	@./$<

# TEST_SRCs are separately compiled into object files, which is for convenience
bin/tests: test/main.c $(OBJ) $(TEST_SRC) $(TEST_HEADER)
	$(CC) -o $@ $< $(OBJ) $(TEST_SRC) $(CFLAG)

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
	clang-format -style=file $(FMTFLAG) \
		src/*.h src/*.c test/*.h test/*.c

tidy:
	clang-tidy $(TIDYFLAG) \
		src/*.h src/*.c test/*.h test/*.c \
		-- $(CFLAG)
