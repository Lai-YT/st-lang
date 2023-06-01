cmake_minimum_required(VERSION 3.10)

project(CodeGen C)

# Specify compiler flags
add_compile_options(-std=c99 -Wall -Wextra -Wshadow -Wformat=2 -Wunused)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../lexer LexerLib)

file(GLOB C_SRC_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)
add_executable(CodeGen ${C_SRC_FILES})
target_include_directories(CodeGen PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../parser/include)
target_link_libraries(CodeGen
    PRIVATE
    Lib LexerLib
)

option(COVERAGE OFF)
if (COVERAGE)
    enable_testing()

    file(GLOB TESTS ${CMAKE_CURRENT_SOURCE_DIR}/tests/*.st)
    foreach(test_file ${TESTS})
        get_filename_component(filename ${test_file} NAME_WE)
        add_test(
            NAME "run_${filename}"
            # these tests will and should exit 1,
            # which makes gcov unable to collect coverage data,
            # so use the `--coverage` option to always exit 0
            COMMAND $<TARGET_FILE:CodeGen> ${test_file}
        )
    endforeach()

    include(CodeCoverage.cmake)
    append_coverage_compiler_flags_to_target(CodeGen)
    setup_target_for_coverage_lcov(
        NAME coverage
        EXECUTABLE ctest
        EXCLUDE ${YGEN}
    )
endif()
