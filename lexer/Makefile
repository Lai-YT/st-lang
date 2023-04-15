.PHONY: tests clean

CC := gcc
SRC := turing.l
CGEN := turing-lex.c
LEX := flex
LFLAFS := -l -o $(CGEN)
LEXER := lexer

$(LEXER): $(CGEN)
	$(CC) $< -o $@

$(CGEN): $(SRC)
	$(LEX) $(LFLAFS) $<

tests:
	@./test.sh

clean:
	rm -f $(CGEN) $(LEXER)
