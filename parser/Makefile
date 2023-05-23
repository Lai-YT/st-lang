.PHONY: parser coverage tests fmt tidy clean valgrind

CC := gcc
YSRC := src/st.y
CGEN := src/st-parse.c
YACC := bison
YFLAGS := -v -t -rcex -o $(CGEN) # -y # for better error message, no POSIX Yacc compatibility
BUILD_DIR := build
BUILD_TYPE := Release

COVERAGE_DIR := .coverage
FMTFLAGS := -i
TIDYFLAGS := --quiet

all: parser

parser: $(CGEN)
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

$(CGEN): $(YSRC)
	$(YACC) $(YFLAGS) $<

tests: parser
	@echo "---"
	@./test.sh

# use gcc for gcov (clang needs some more setups)
coverage: $(CGEN)
	@exec 1>/dev/null \
	&& mkdir -p $(BUILD_DIR) \
	&& cd $(BUILD_DIR) \
	&& cmake .. \
		-DCMAKE_C_COMPILER=gcc \
		-DCMAKE_BUILD_TYPE=Debug \
		-DCOVERAGE=ON \
		-DYGEN=$(CGEN) \
	&& make && make coverage
    # copy reports out from build directory
	@rm -rf $(COVERAGE_DIR) && cp -r $(BUILD_DIR)/coverage/ $(COVERAGE_DIR)
	@echo "Open $(COVERAGE_DIR)/index.html in your browser to view the coverage report."

CFILES := $(wildcard src/*.c src/*.h)

fmt:
	clang-format -style=file $(FMTFLAGS) \
		$(filter-out $(CGEN), $(CFILES))

tidy: parser
	clang-tidy $(TIDYFLAGS) \
		$(filter-out $(CGEN), $(CFILES)) \
		-p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(CGEN) $(COVERAGE_DIR)

valgrind: BUILD_TYPE := Debug
valgrind: parser
	@valgrind \
		--track-origins=yes \
		--leak-check=full \
		--leak-resolution=high \
		--error-exitcode=1 \
		$(BUILD_DIR)/Parser tests/good/msb.st
