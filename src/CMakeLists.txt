cmake_minimum_required(VERSION 3.22)

project(F95Interpreter)

find_package(BISON 3.5 REQUIRED)
find_package(FLEX REQUIRED)

set(CMAKE_CXX_STANDARD 17)

set(
    HEADERS
    ${F95Interpreter_SOURCE_DIR}/driver.hh
    ${F95Interpreter_SOURCE_DIR}/parser.hh
    )

BISON_TARGET(
    Parser
    parser.y
    ${F95Interpreter_SOURCE_DIR}/parser.cpp
    COMPILE_FLAGS --graph 
    COMPILE_FLAGS -Wcounterexamples
    DEFINES_FILE ${F95Interpreter_SOURCE_DIR}/parser.hh
)

FLEX_TARGET(
    Scanner
    scanner.l
    ${F95Interpreter_SOURCE_DIR}/scanner.cpp
)

ADD_FLEX_BISON_DEPENDENCY(Scanner Parser)

add_executable(
    main
    main.cpp
    driver.cpp
    ${BISON_Parser_OUTPUTS}
    ${FLEX_Scanner_OUTPUTS}
)
target_include_directories(main PRIVATE ${F95Interpreter_SOURCE_DIR})



