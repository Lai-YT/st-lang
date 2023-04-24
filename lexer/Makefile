.PHONY: lexer tests fmt tidy clean

CC := gcc
LSRC := src/turing.l
CGEN := src/turing-lex.c
LEX := flex
LFLAGS := -l -o $(CGEN)
BUILD_DIR := build

FMTFLAGS := -i
TIDYFLAGS := --quiet

all: lexer

lexer: $(CGEN)
    # CMAKE_EXPORT_COMPILE_COMMANDS=ON is required for generating the
    # compile_commands.json file used by Clang-Tidy
	@exec 1>/dev/null \
	&& mkdir -p $(BUILD_DIR) \
	&& cd $(BUILD_DIR) \
	&& cmake .. \
		-DCMAKE_C_COMPILER=$(CC) -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	&& cmake --build .

$(CGEN): $(LSRC)
	$(LEX) $(LFLAGS) $<

tests: lexer
	@./test.sh

CFILES := $(wildcard src/*.c src/*.h)

fmt:
	clang-format -style=file $(FMTFLAGS) \
		$(filter-out $(CGEN), $(CFILES))

tidy: lexer
	clang-tidy $(TIDYFLAGS) \
		$(filter-out $(CGEN), $(CFILES)) \
		-p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(CGEN)
