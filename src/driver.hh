#pragma once

#include <map>
#include <string>
#include <fstream>
#include <queue>
#include <vector>
#include <functional>
#include <any>
#include "scanner.h"
#include "parser.hh"
#include "utilities/boolean.h"
#include "utilities/integers.h"

class Driver {
 public:
    Driver();
    std::string program_label;

    std::map<std::string, int> integer_variables;
    std::map<std::string, std::string> string_variables;
    std::vector<std::vector<std::function<void()>>> if_blocks;
    std::vector<BoolExpr> conditions_for_if_blocks;

    int parse(const std::string& f);
    std::string file;

    void scan_begin();
    void scan_end();

    yy::location location;

    friend class Scanner;
    Scanner scanner;
    yy::parser parser;
    bool location_debug;
    bool trace_scanning;
    bool trace_parsing;

    void process_if_blocks();
    int& get_integer_or_abort(std::string key);
    std::function<bool()> get_eq_comparison(IntExpr lhs, IntExpr rhs);
    std::function<bool()> get_ls_comparison(IntExpr lhs, IntExpr rhs);
    IntExpr get_intexpr_or_abort(std::string key);

 private:
    std::ifstream stream;

};
