cmake_minimum_required(VERSION 3.10)

project(Parser C)

# Specify compiler flags
add_compile_options(-std=c99 -Wall -Wextra -Wshadow -Wformat=2 -Wunused)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../lexer LexerLib)

file(GLOB C_SRC_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)
add_executable(Parser ${C_SRC_FILES})

target_link_libraries(Parser
    PRIVATE
    Lib LexerLib m
)

option(COVERAGE OFF)
if (COVERAGE)
    enable_testing()

    file(GLOB BAD_TESTS ${CMAKE_CURRENT_SOURCE_DIR}/tests/bad/*.st)
    foreach(test_file ${BAD_TESTS})
        get_filename_component(filename ${test_file} NAME_WE)
        add_test(
            NAME "run_bad_${filename}"
            # these tests will and should exit 1,
            # which makes gcov unable to collect coverage data,
            # so use the `--coverage` option to always exit 0
            COMMAND $<TARGET_FILE:Parser> --allow-semantic-errors ${test_file}
        )
    endforeach()
    file(GLOB GOOD_TESTS ${CMAKE_CURRENT_SOURCE_DIR}/tests/good/*.st)
    foreach(test_file ${GOOD_TESTS})
        get_filename_component(filename ${test_file} NAME_WE)
        add_test(
            NAME "run_good_${filename}"
            COMMAND $<TARGET_FILE:Parser> ${test_file}
        )
    endforeach()

    include(CodeCoverage.cmake)
    append_coverage_compiler_flags_to_target(Parser)
    setup_target_for_coverage_lcov(
        NAME coverage
        EXECUTABLE ctest
        EXCLUDE ${YGEN}  # generated file
    )
endif()
