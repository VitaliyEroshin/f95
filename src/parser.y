%skeleton "lalr1.cc"
%require "3.5"

%defines
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires {
    #pragma once
    #include <string>
    #include <cassert>
    #include "utilities/boolean.h"
    #include "utilities/integers.h"
    #include "utilities/strings.h"

    class Scanner;
    class Driver;
}

%define parse.trace
%define parse.error verbose

%code {
    #include "driver.hh"
    #include "location.hh"
    
    static yy::parser::symbol_type yylex(Scanner &scanner) {
        return scanner.ScanToken();
    }
}

%lex-param { Scanner &scanner }

%parse-param { Scanner &scanner }
%parse-param { Driver &driver }

%locations

%define api.token.prefix {TOK_}
%token
    EOF 0 "end of file"
    PROGRAM "program"
    END "end"
    INT_DECLARATION "int_declaration"
    CHARACTER "character"
    LEN "len"
    PRINT "print"
    IF "if"
    ELSE "else"
    THEN "then"
    DO "do"
    DOUBLE_COLON "::"
    COMMA ","
    EQUAL "="
    NEW_LINE_SEPARATOR "n"
    PLUS "+"
    MINUS "-"
    STAR "*"
    SLASH "/"
    PERCENT "%"
    LPAREN "("
    RPAREN ")"
    NEQ "/="
    CONCAT "CONCAT"
    AND_SYM ".AND."
    OR_SYM ".OR."
    NOT_SYM ".NOT."
    TRUE_SYM ".TRUE."
    FALSE_SYM ".FALSE."
    EQUAL_SYM ".EQ."
    NOT_EQUAL_SYM ".NE."
    GE_SYM ".GE."
    LE_SYM ".LE."
    GT_SYM ".GT."
    LS_SYM ".LS."
    GREATER ">"
    LESS "<"
;

%token <std::string> IDENTIFIER "identifier"
%token <std::string> STRING "string"
%token <int> INTEGER "integer"
%nterm <IntExpr> integer_expression
%nterm <BoolExpr> bool_expression
%nterm <StringExpr> string_expression
%nterm <std::string> do_counter

%printer { yyo << $$; } <*>;

%%
%left "+" "-" "%";
%left "*" "/";
%left ".NOT." ".AND." ".OR.";

%start main_scope;
main_scope: 
    %empty
    | program_declaration units program_end "n" main_scope
    | program_declaration units program_end

program_declaration: 
    "program" "identifier" "n" {
        driver.set_program_label($2);
        driver.program_label = $2;
    }

program_end: 
    "end" "program" "identifier" {
        driver.assert_program_label($3);
    }

units:
    %empty
    | block "n" units
    | block
    | "n" units

block:
    statement {
        driver.statement_queue.back()();
        driver.statement_queue.pop_back();
    }
    | conditional_block
    | do_loop_block
    | declaration

statement:
    print
    | assignment
    | string_assignment

print:
    "print" "*" "," "identifier" {
        driver.print($4);
    }

assignment:
    "identifier" "=" integer_expression {
        driver.assign_variable($1, $3);
    }

string_assignment:
    "identifier" "=" string_expression {
        driver.assign_variable($1, $3);
    }

string_expression:
    "identifier" "CONCAT" string_expression {
        $$ = driver.strings.get_strexpr($1) / $3;
    }
    | "identifier" "CONCAT" "identifier" {
        $$ = driver.strings.get_strexpr($1) / driver.strings.get_strexpr($3);
    }
    | "string" { $$ = StringExpr($1); }
    | "string" "CONCAT" string_expression {
        $$ = StringExpr($1) / $3;
    }

declaration:
    integer_declaration
    | character_declaration

character_declaration:
    "character" "(" set_string_length ")" "::" make_strings

set_string_length:
    "len" "=" "integer" {
        driver.strings.set_length($3);
    }

make_strings:
    make_string
    | make_string "," make_strings

make_string:
    "identifier" "=" "string" {
        driver.strings.declare($1);
        driver.strings.set($1, $3);
    }

integer_declaration:
    "int_declaration" "::" make_ints
    | "int_declaration" make_ints

make_ints:
    make_int
    | make_int "," make_ints    

make_int:
    "identifier" "=" integer_expression {
        driver.integers.declare($1);
        driver.integers.set($1, $3());
    }
    | "identifier" {
        driver.integers.declare($1);
    }


integer_expression:
    "integer" { $$ = IntExpr($1); }
    | "identifier" { $$ = driver.integers.get_intexpr($1); }
    | integer_expression "+" integer_expression { $$ = $1 + $3; }
    | integer_expression "-" integer_expression { $$ = $1 - $3; }
    | integer_expression "*" integer_expression { $$ = $1 * $3; }
    | integer_expression "/" integer_expression { $$ = $1 / $3; }
    | integer_expression "%" integer_expression { $$ = $1 % $3; }
    | "(" integer_expression ")" { $$ = $2; }

conditional_block:
    "if" "(" bool_expression ")" statement {
        driver.conditions_for_if_blocks.push_back($3);
        driver.if_blocks.push_back(std::move(driver.statement_queue));
        driver.process_if_blocks();
    }
    | "if" if_conditional "end" "if" {
        driver.process_if_blocks();
    }

if_conditional:
    condition_block
    | condition_block "else" "n" if_block
    | condition_block "else" "if" if_conditional

condition_block:
    "(" bool_expression ")" "then" "n" if_block {
        driver.conditions_for_if_blocks.push_back($2);
    }

bool_expression:
    integer_expression "=" "=" integer_expression {
        $$ = BoolExpr(driver.get_eq_comparison($1, $4)); 
    }
    | integer_expression ".EQ." integer_expression {
        $$ = BoolExpr(driver.get_eq_comparison($1, $3));
    }
    | integer_expression "/=" integer_expression {
        $$ = -BoolExpr(driver.get_eq_comparison($1, $3));
    }
    | integer_expression ".NE." integer_expression {
        $$ = -BoolExpr(driver.get_eq_comparison($1, $3)); 
    }
    | integer_expression ">" "=" integer_expression {
        $$ = -BoolExpr(driver.get_ls_comparison($1, $4));
    }
    | integer_expression ".GE." integer_expression {
        $$ = -BoolExpr(driver.get_ls_comparison($1, $3));
    }
    | integer_expression "<" "=" integer_expression {
        $$ = -BoolExpr(driver.get_ls_comparison($4, $1));
    }
    | integer_expression ".LE." integer_expression {
        $$ = -BoolExpr(driver.get_ls_comparison($3, $1));
    }
    | integer_expression ">" integer_expression {
        $$ = BoolExpr(driver.get_ls_comparison($3, $1));
    }
    | integer_expression ".GT." integer_expression {
        $$ = BoolExpr(driver.get_ls_comparison($3, $1));
    }
    | integer_expression "<" integer_expression {
        $$ = BoolExpr(driver.get_ls_comparison($1, $3));
    }
    | integer_expression ".LS." integer_expression {
        $$ = BoolExpr(driver.get_ls_comparison($1, $3));
    }
    | "(" bool_expression ")" { $$ = $2; }
    | bool_expression ".AND." bool_expression { $$ = $1 & $3; }
    | bool_expression ".OR." bool_expression { $$ = $1 | $3; }
    | ".NOT." bool_expression { $$ = -BoolExpr($2); }
    | ".TRUE." { $$ = BoolExpr(true); }
    | ".FALSE." { $$ = BoolExpr(false); }

if_block:
    if_statements {
        driver.if_blocks.emplace_back(std::move(driver.statement_queue));
    }

if_statements:
    %empty
    | statement "n" if_statements

do_loop_block:
    "do" do_counter "=" integer_expression "," integer_expression
    "n" do_statements "end" "do" {
        int& counter = driver.integers.get($2);
        counter = $4();
        do {
            for (auto& f : driver.statement_queue) {
                f();
            }

            ++counter;
        } while (counter <= $6());
    
        driver.statement_queue.clear();
    }

do_counter:
    "identifier" {
        if (!driver.integers.has($1)) {
            driver.integers.declare($1);
        }
        $$ = $1;
    }

do_statements:
    %empty
    | statement "n" do_statements

%%
void yy::parser::error(const location_type& l, const std::string& m) {
  std::cerr << l << ": " << m << '\n';
}
