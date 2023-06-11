.PHONY: codegen fmt tidy clean tests coverage valgrind

CC := gcc
YSRC := src/st.y
CGEN := src/st-parse.c
YACC := bison
YFLAGS := -v -t -rcex -o $(CGEN)
BUILD_DIR := build
BUILD_TYPE := Release

COVERAGE_DIR := .coverage
FMTFLAGS := -i
TIDYFLAGS := --quiet

all: codegen

codegen: $(CGEN)
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

CFILES := $(wildcard src/*.c src/*.h)

fmt:
	clang-format -style=file $(FMTFLAGS) \
		$(filter-out $(CGEN), $(CFILES))

tidy: codegen
	clang-tidy $(TIDYFLAGS) \
		$(filter-out $(CGEN), $(CFILES)) \
		-p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(CGEN) $(COVERAGE_DIR)

tests: export CODEGEN=$(BUILD_DIR)/CodeGen
tests: codegen
    # ignore enormous warnings
	@make -C ../javaa 2>/dev/null
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

valgrind: BUILD_TYPE := Debug
valgrind: export CODEGEN=$(BUILD_DIR)/CodeGen
valgrind: codegen
	@./memory_test.sh
