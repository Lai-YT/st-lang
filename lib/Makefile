CC := gcc

# for customizing, e.g., make fmt FMTFLAGS='--dry-run --Werror'
FMTFLAGS := -i
TIDYFLAGS := --quiet
BUILD_DIR := build
TEST_EXE := LibTest

.PHONY: build tests fmt tidy clean

all: build

build:
  # CMAKE_EXPORT_COMPILE_COMMANDS=ON is required for generating the
  # compile_commands.json file used by Clang-Tidy
	@exec 1>/dev/null \
	&& mkdir -p $(BUILD_DIR) \
	&& cd $(BUILD_DIR) \
	&& cmake .. \
		-DCMAKE_C_COMPILER=$(CC) -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	&& cmake --build . --target $(TEST_EXE)

tests: build
	@echo "Run tests..."
	@$(BUILD_DIR)/$(TEST_EXE)

valgrind: build
	@valgrind \
		--track-origins=yes \
		--show-leak-kinds=all \
		--leak-check=full \
		--leak-resolution=high \
		--error-exitcode=1 \
		$(BUILD_DIR)/$(TEST_EXE)

CFILES := $(wildcard include/*.h src/*.c src/*.h tests/*.c tests/*.h)

fmt:
	clang-format -style=file $(FMTFLAGS) \
		$(CFILES)

# needs the build so we can get the compile_commands.json
tidy: build
	clang-tidy $(TIDYFLAGS) \
		$(CFILES) \
		-p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)
