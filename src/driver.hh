#pragma once

#include <map>
#include <string>
#include <fstream>
#include "scanner.h"
#include "parser.hh"

class Driver {
 public:
    Driver();
    std::string program_label;

    std::map<std::string, int> integer_variables;
    std::map<std::string, std::string> string_variables;

    int parse(const std::string& f);
    std::string file;

    void scan_begin();
    void scan_end();

    bool trace_parsing;
    bool trace_scanning;
    bool show_tokens;
    yy::location location;

    friend class Scanner;
    Scanner scanner;
    yy::parser parser;
    bool location_debug;
 private:
    std::ifstream stream;

};
