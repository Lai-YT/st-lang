.PHONY: tests clean fmt tidy

CC := gcc
LSRC := turing.l
CGEN := turing-lex.c
LEX := flex
LFLAGS := -l -o $(CGEN)
LEXER := lexer
CFLAGS := -std=c99 -I../src
# Particularly resolving the implicit declaration warning on "fileno" used in
# Flex generated scanner.
# See also https://github.com/westes/flex/issues/263.
USE_POSIX_SYMBOLS =	-D_POSIX_C_SOURCE

SRC := $(wildcard ../src/*.c)
OBJ := $(addprefix ../obj/, $(notdir $(SRC:.c=.o)))

FMTFLAGS := -i
TIDYFLAGS := --quiet

$(LEXER): $(CGEN) lextest.c $(OBJ) $(SRC)
	$(CC) -o $@ $(CGEN) lextest.c $(OBJ) $(CFLAGS) $(USE_POSIX_SYMBOLS)

../obj/%.o: ../src/%.c
	$(CC) -c -o $@ $< $(CFLAGS)

$(CGEN): $(LSRC)
	$(LEX) $(LFLAGS) $<

tests:
	@./test.sh

fmt:
	clang-format -style=file $(FMTFLAGS) \
		$(filter-out $(CGEN), $(wildcard *.c *.h))

tidy:
	clang-tidy $(TIDYFLAGS) \
		$(filter-out $(CGEN), $(wildcard *.c *.h)) \
		-- $(CFLAGS)

clean:
	rm -f $(CGEN) $(LEXER)
