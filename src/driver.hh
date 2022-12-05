#pragma once

#include <fstream>
#include <functional>
#include <map>
#include <queue>
#include <string>
#include <vector>

#include "parser.hh"
#include "scanner.h"
#include "utilities/boolean.h"
#include "utilities/integers.h"
#include "utilities/strings.h"

class Driver {
  public:
    Driver();

    std::string program_label;

    IntegersModule integers;
    StringsModule strings;

    std::vector<std::vector<std::function<void()>>> if_blocks;
    std::vector<BoolExpr> conditions_for_if_blocks;
    std::vector<std::function<void()>> statement_queue;

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
    std::function<bool()> get_eq_comparison(IntExpr lhs, IntExpr rhs);
    std::function<bool()> get_ls_comparison(IntExpr lhs, IntExpr rhs);

    int& get_integer(const std::string& variable);
    void print(const std::string& variable);
    void assign_variable(const std::string& variable, IntExpr expression);
    void assign_variable(const std::string& variable, StringExpr expression);
    void assert_program_label(const std::string& label);
    void set_program_label(const std::string& label);

  private:
    std::ifstream stream;

};
