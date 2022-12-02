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
    /* Forward declaration of classes in order to disable cyclic dependencies */
    class Scanner;
    class Driver;
}


%define parse.trace
%define parse.error verbose

%code {
    #include "driver.hh"
    #include "location.hh"
    
    /* Redefine parser to use our function from scanner */
    static yy::parser::symbol_type yylex(Scanner &scanner) {
        return scanner.ScanToken();
    }
}

%lex-param { Scanner &scanner }

%parse-param { Scanner &scanner }
%parse-param { Driver &driver }

%locations

%define api.token.prefix {TOK_}
// token name in variable
%token
    EOF 0 "end of file"
    PROGRAM "program"
    END "end"
    INT_DECLARATION "int_declaration"
    PRINT "print"
    IF "if"
    ELSE "else"
    THEN "then"
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
%token <int> INTEGER "integer"
%nterm <IntExpr> integer_expression
%nterm <BoolExpr> bool_expression

// Prints output in parsing option for debugging location terminal
%printer { yyo << $$; } <*>;

%%
%left "+" "-" "%";
%left "*" "/";
%left ".NOT." ".AND." ".OR.";

%start main_scope;
main_scope: 
    program_declaration units program_end

program_declaration: 
    "program" "identifier" "n" {
        driver.program_label = $2;
    }

program_end: 
    "end" "program" "identifier" {
        if ($3 != driver.program_label) {
            std::cerr << "Expected label \"" << driver.program_label << "\"" << std::endl;
        }
    }

units:
    %empty
    | statement "n" units
    | statement
    | "n" units

statement:
    declaration
    | assignment
    | print
    | conditional_block

declaration:
    integer_declaration;

integer_declaration:
    "int_declaration" "::" make_ints
    | "int_declaration" make_ints

make_ints:
    make_int
    | make_int "," make_ints    

make_int:
    "identifier" "=" integer_expression {
        driver.integer_variables[$1] = $3();
        // std::cout << "Constructed " << driver.integer_variables[$1] << std::endl;
    }
    | "identifier"

integer_expression:
    "identifier" {
        // std::cout << "Integer " << driver.get_integer_or_abort($1) << ", got ";
        auto l = driver.get_intexpr_or_abort($1);
        // std::cout << l() << std::endl;
        $$ = l;
    }
    | "integer" { 
        $$ = IntExpr($1); 
        // std::cout << "Got IntExpr from integer " << $1 << " -> " << $$() << std::endl;
    }
    | integer_expression "+" integer_expression { $$ = $1 + $3; }
    | integer_expression "-" integer_expression { $$ = $1 - $3; }
    | integer_expression "*" integer_expression { $$ = $1 * $3; }
    | integer_expression "/" integer_expression { $$ = $1 / $3; }
    | integer_expression "%" integer_expression { $$ = $1 % $3; }
    | "(" integer_expression ")" { $$ = $2; }

assignment:
    "identifier" "=" integer_expression {
        driver.get_integer_or_abort($1) = $3();
    }

print:
    "print" integer_expression {
        std::cout << $2() << std::endl;
    }

conditional_block:
    "if" "(" bool_expression ")" make_new_block if_statement {
        driver.conditions_for_if_blocks.push_back($3);
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
    integer_expression "=" "=" integer_expression { $$ = BoolExpr(driver.get_eq_comparison($1, $4)); }
    | integer_expression ".EQ." integer_expression { $$ = BoolExpr(driver.get_eq_comparison($1, $3)); }
    | integer_expression "/" "=" integer_expression { $$ = -BoolExpr(driver.get_eq_comparison($1, $4)); }
    | integer_expression ".NE." integer_expression { $$ = -BoolExpr(driver.get_eq_comparison($1, $3)); }
    | integer_expression ">" "=" integer_expression { $$ = -BoolExpr(driver.get_ls_comparison($1, $4)); }
    | integer_expression ".GE." integer_expression { $$ = -BoolExpr(driver.get_ls_comparison($1, $3)); }
    | integer_expression "<" "=" integer_expression { $$ = -BoolExpr(driver.get_ls_comparison($4, $1)); }
    | integer_expression ".LE." integer_expression { $$ = -BoolExpr(driver.get_ls_comparison($3, $1)); }
    | integer_expression ">" integer_expression { $$ = BoolExpr(driver.get_ls_comparison($3, $1)); }
    | integer_expression ".GT." integer_expression { $$ = BoolExpr(driver.get_ls_comparison($3, $1)); }
    | integer_expression "<" integer_expression { $$ = BoolExpr(driver.get_ls_comparison($1, $3)); }
    | integer_expression ".LS." integer_expression { $$ = BoolExpr(driver.get_ls_comparison($1, $3)); }
    | "(" bool_expression ")" { $$ = $2; }
    | bool_expression ".AND." bool_expression { $$ = $1 & $3; }
    | bool_expression ".OR." bool_expression { $$ = $1 | $3; }
    | ".NOT." bool_expression { $$ = -BoolExpr($2); }
    | ".TRUE." { $$ = BoolExpr(true); }
    | ".FALSE." { $$ = BoolExpr(false); }


if_block:
    make_new_block if_statements

if_statements:
    %empty
    | if_statement "n" if_statements

if_statement:
    if_block_assignment

make_new_block:
    %empty {
        driver.if_blocks.push_back({});
    }

if_block_assignment:
    "identifier" "=" integer_expression {
        std::string key = $1;
        IntExpr value = $3;
        auto f = [key, value, this]() {
            driver.get_integer_or_abort(key) = value();
        };
        driver.if_blocks.back().push_back(f);
    }
    | "print" integer_expression {
        IntExpr result = $2;
        auto f = [result, this]() {
            std::cout << result() << std::endl;
        };
        driver.if_blocks.back().push_back(f);
    }
%%

void
yy::parser::error(const location_type& l, const std::string& m)
{
  std::cerr << l << ": " << m << '\n';
}
