cmake_minimum_required(VERSION 3.10)

project(Lexer C)

# Specify compiler flags
add_compile_options(-std=c99 -Wall -Wextra -Wshadow -Wformat=2 -Wunused)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../lib Lib)

# Add the lexer executable and link against library
file(GLOB C_SRC_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)
list(REMOVE_ITEM C_SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")

add_executable(Lexer ${C_SRC_FILES})

target_compile_definitions(Lexer PRIVATE
    # Particularly resolving the implicit declaration warning on "fileno" used in
    # Flex generated scanner.
    # See also https://github.com/westes/flex/issues/263.
    # And the use of getline requires >= 200809L.
    _POSIX_C_SOURCE=200809L
)
target_link_libraries(Lexer
    PRIVATE  # The Lexer has nothing for others to include, so PRIVATE suffices.
    Lib
)

add_library(LexerLib SHARED ${C_SRC_FILES})

target_compile_definitions(LexerLib
    PRIVATE
    _POSIX_C_SOURCE=200809L
)
target_link_libraries(LexerLib
    # Shared libraries "close" their dependencies.
    # The one that links such library does not need the propagation of links.
    PRIVATE
    Lib
)
