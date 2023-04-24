cmake_minimum_required(VERSION 3.10)

# This library contains the data structures used across the phases of the compiler
project(Lib C)

# Add the lib library
file(GLOB C_SRC_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)
add_library(Lib SHARED ${C_SRC_FILES})
target_include_directories(Lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

# Specify compiler flags
add_library(lib_compiler_flags INTERFACE)
target_compile_features(lib_compiler_flags INTERFACE c_std_99)
target_compile_options(lib_compiler_flags
    INTERFACE
    "-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused;"
)
target_link_libraries(Lib
    # Shared libraries "close" their dependencies.
    # The one that links such library does not need the propagation of links.
    PRIVATE
    m lib_compiler_flags
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
    lib_compiler_flags Lib
)
