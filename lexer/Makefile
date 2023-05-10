.PHONY: lexer tests fmt tidy clean

CC := gcc
LSRC := src/st.l
CGEN := src/st-lex.c
HGEN := $(CGEN:.c=.h)
LEX := flex
LFLAGS := -l --header-file=$(HGEN) -o $(CGEN)
BUILD_DIR := build
BUILD_TYPE := Release

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
		-DCMAKE_C_COMPILER=$(CC) \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
	&& cmake --build .

$(CGEN): $(LSRC)
	$(LEX) $(LFLAGS) $<

tests: lexer
	@./test.sh

CFILES := $(filter-out $(CGEN) $(HGEN),$(wildcard src/*.c src/*.h))

fmt:
	clang-format -style=file $(FMTFLAGS) \
		$(CFILES)

tidy: lexer
	clang-tidy $(TIDYFLAGS) \
		$(CFILES) \
		-p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(CGEN) $(HGEN)
