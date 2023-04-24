cmake_minimum_required(VERSION 3.10)

# This library contains the data structures used across the phases of the compiler
project(Libs C)

# Add the libs library
file(GLOB C_SRC_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)
add_library(Libs SHARED ${C_SRC_FILES})
target_include_directories(Libs PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

# Specify compiler flags
add_library(libs_compiler_flags INTERFACE)
target_compile_features(libs_compiler_flags INTERFACE c_std_99)
target_compile_options(libs_compiler_flags
    INTERFACE
    "-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused;"
)
target_link_libraries(Libs
    # Shared libraries "close" their dependencies.
    # The one that links such library does not need the propagation of links.
    PRIVATE
    m libs_compiler_flags
)

# Add the test executable and link against the library
add_executable(LibsTest
    EXCLUDE_FROM_ALL  # Excluded when building without explicitly specifying target
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/main.c
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/util.c
)
target_compile_definitions(LibsTest PRIVATE
    _GNU_SOURCE # Action handling with sigaction
)
target_link_libraries(LibsTest
    PRIVATE
    libs_compiler_flags Libs
)
