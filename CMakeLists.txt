cmake_minimum_required(VERSION 3.22)

project(F95Interpreter)

find_package(BISON 3.5 REQUIRED)
find_package(FLEX REQUIRED)

set(CMAKE_CXX_STANDARD 17)

set(
    HEADERS
    ${PROJECT_SOURCE_DIR}/driver.hh
    ${PROJECT_SOURCE_DIR}/parser.hh
)

set(SOURCE ${PROJECT_SOURCE_DIR}/src/)

BISON_TARGET(
    Parser
    ${SOURCE}/parser.y
    ${SOURCE}/parser.cpp
    COMPILE_FLAGS --graph 
    COMPILE_FLAGS -Wcounterexamples
    DEFINES_FILE ${SOURCE}/parser.hh
)

FLEX_TARGET(
    Scanner
    ${SOURCE}/scanner.l
    ${SOURCE}/scanner.cpp
)

ADD_FLEX_BISON_DEPENDENCY(Scanner Parser)

add_executable(
    interpreter
    ${SOURCE}/main.cpp
    ${SOURCE}/driver.cpp
    ${SOURCE}/utilities/boolean.cpp
    ${SOURCE}/utilities/integers.cpp
    ${SOURCE}/utilities/strings.cpp
    ${BISON_Parser_OUTPUTS}
    ${FLEX_Scanner_OUTPUTS}
)
target_include_directories(interpreter PRIVATE ${SOURCE})

set_target_properties(interpreter
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin
)