cmake_minimum_required(VERSION 3.10)

# This library contains the data structures used across the phases of the compiler
project(Lib C)

# Specify compiler flags
add_compile_options(-std=c99 -Wall -Wextra -Wshadow -Wformat=2 -Wunused)

# Add the lib library
file(GLOB C_SRC_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)
add_library(Lib SHARED ${C_SRC_FILES})
target_include_directories(Lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

target_link_libraries(Lib
    # Shared libraries "close" their dependencies.
    # The one that links such library does not need the propagation of links.
    PRIVATE
    m
)

# Add the test executable and link against the library
add_executable(LibTest
    EXCLUDE_FROM_ALL  # Excluded when building without explicitly specifying target
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/main.c
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/util.c
)
target_compile_definitions(LibTest PRIVATE
    _GNU_SOURCE # Action handling with sigaction
)
target_link_libraries(LibTest
    PRIVATE
    Lib
)
