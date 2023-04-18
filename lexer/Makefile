.PHONY: tests clean

CC := gcc
LSRC := turing.l
CGEN := turing-lex.c
LEX := flex
LFLAGS := -l -o $(CGEN)
LEXER := lexer
CFLAGS := -std=c99 -I../src
SRC := $(wildcard ../src/*.c)
OBJ := $(addprefix ../obj/, $(notdir $(SRC:.c=.o)))

$(LEXER): $(CGEN) $(OBJ) $(SRC)
	$(CC) -o $@ $(CGEN) $(OBJ) $(CFLAGS)

../obj/%.o: ../src/%.c
	$(CC) -c -o $@ $<

$(CGEN): $(LSRC)
	$(LEX) $(LFLAGS) $<

tests:
	@./test.sh

clean:
	rm -f $(CGEN) $(LEXER)
