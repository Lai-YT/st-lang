cmake_minimum_required(VERSION 3.10)

project(Parser C)

# Specify compiler flags
add_compile_options(-std=c99 -Wall -Wextra -Wshadow -Wformat=2 -Wunused)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../lexer LexerLib)

file(GLOB C_SRC_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c)
add_executable(Parser ${C_SRC_FILES})

target_link_libraries(Parser
    PRIVATE
    Lib LexerLib
)
