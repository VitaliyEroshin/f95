%skeleton "lalr1.cc"
%require "3.5"

%defines
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires {
    #include <string>
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

%code {
    int& get_integer_or_abort(const std::string& key, Driver& driver) {
        auto it = driver.integer_variables.find(key);
        if (it == driver.integer_variables.end()) {
            std::cerr << "Could not find integer variable called";
            std::cerr <<  "(\"" + key + "\"). I am sorry." << std::endl;
            abort();
        }
        return it->second;
    }
}

%locations

%define api.token.prefix {TOK_}
// token name in variable
%token
    END 0 "end of file"
    PROGRAM "program"
    ENDPROGRAM "end"
    INT_DECLARATION "int_declaration"
    PRINT "print"
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
;

%token <std::string> IDENTIFIER "identifier"
%token <int> INTEGER "integer"
%nterm <int> integer_expression

// Prints output in parsing option for debugging location terminal
%printer { yyo << $$; } <*>;

%%
%left "+" "-" "%";
%left "*" "/";

%start main_scope;
main_scope: 
    program_declaration units program_end

program_declaration: 
    "program" "identifier" "n" {
        driver.program_label = $2;
    }

program_end: 
    "end" "identifier" {
        if ($2 != driver.program_label) {
            std::cerr << "Expected label \"" << driver.program_label << "\"" << std::endl;
        }
    }

units:
    %empty
    | statement "n" units
    | statement

statement:
    declaration
    | assignment
    | print

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
        driver.integer_variables[$1] = $3;
    }
    | "identifier"

integer_expression:
    "identifier" {
        $$ = get_integer_or_abort($1, driver);
    }
    | "integer"
    | integer_expression "+" integer_expression { $$ = $1 + $3; }
    | integer_expression "-" integer_expression { $$ = $1 - $3; }
    | integer_expression "*" integer_expression { $$ = $1 * $3; }
    | integer_expression "/" integer_expression { $$ = $1 / $3; }
    | integer_expression "%" integer_expression { $$ = $1 % $3; }
    | "(" integer_expression ")" { $$ = $2; }

assignment:
    "identifier" "=" integer_expression {
        get_integer_or_abort($1, driver) = $3;
    }

print:
    "print" "identifier" {
        std::cout << get_integer_or_abort($2, driver) << std::endl;
    }
%%

void
yy::parser::error(const location_type& l, const std::string& m)
{
  std::cerr << l << ": " << m << '\n';
}
