cmake_minimum_required(VERSION 3.10)

project(Lexer C)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../libs DataStructure)

# Add the lexer executable and link against library
file(GLOB C_SRC_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)
add_executable(Lexer ${C_SRC_FILES})

# Specify compiler flags
add_library(lexer_compiler_flags INTERFACE)
target_compile_features(lexer_compiler_flags INTERFACE c_std_99)
target_compile_options(lexer_compiler_flags
    INTERFACE
    "-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused"
)
target_compile_definitions(Lexer PRIVATE
    # Particularly resolving the implicit declaration warning on "fileno" used in
    # Flex generated scanner.
    # See also https://github.com/westes/flex/issues/263.
    _POSIX_C_SOURCE
)
target_link_libraries(Lexer
    PRIVATE  # The Lexer has nothing for others to include, so PRIVATE suffices.
    lexer_compiler_flags DataStructure
)
