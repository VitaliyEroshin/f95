%{
    #include <cerrno>
    #include <climits>
    #include <cstdlib>
    #include <cstring> // strerror
    #include <string>
    #include <iostream>
    #include "driver.hh"
    #include "parser.hh"
%}

%option noyywrap nounput noinput batch debug

%option c++
%option yyclass="Scanner"
%option caseless

%{
  // Code definitions at the end of scanner.cpp

  // A number symbol corresponding to the value in S.
  yy::parser::symbol_type make_INTEGER(
    const std::string &s,
    const yy::parser::location_type& loc
  );

  void Scanner::UpdateLocation() {
    if (driver.location_debug) {
        std::cerr << "Action called " << driver.location << std::endl;
    }
    driver.location.columns(yyleng);
  }
%}

id    [a-zA-Z][a-zA-Z_0-9]*
int   [0-9]+
blank [ \t\r]

%{
  // Code run each time a pattern is matched.
  #define YY_USER_ACTION UpdateLocation();
%}

%%


%{
  // A handy shortcut to the location held by the driver.
  yy::location& loc = driver.location;
  if (driver.location_debug) {
  // Code run each time yylex is called.
    std::cerr << "BEFORE " << loc << std::endl;
  }
  // loc.step();
  if (driver.location_debug) {
    std::cerr << "AFTER " <<  loc << std::endl;
  }
%}

{blank}+   {
    if (driver.location_debug) {
        std::cerr << "Blank matched" << std::endl;
    }
    // loc.step();
}

"program"           return yy::parser::make_PROGRAM(loc);
"end program"       return yy::parser::make_ENDPROGRAM(loc);
"integer"           return yy::parser::make_INT_DECLARATION(loc);
"print"             return yy::parser::make_PRINT(loc);
"::"                return yy::parser::make_DOUBLE_COLON(loc);
","                 return yy::parser::make_COMMA(loc);
"="                 return yy::parser::make_EQUAL(loc);
"+"                 return yy::parser::make_PLUS(loc);
"-"                 return yy::parser::make_MINUS(loc);
"*"                 return yy::parser::make_STAR(loc);
"/"                 return yy::parser::make_SLASH(loc);
"%"                 return yy::parser::make_PERCENT(loc);
"("                 return yy::parser::make_LPAREN(loc);
")"                 return yy::parser::make_RPAREN(loc);

\n+                 {
                        loc.lines(yyleng);
                        loc.step();
                        return yy::parser::make_NEW_LINE_SEPARATOR(loc);
                    }

{int}      return make_INTEGER(yytext, loc);
{id}       {
                if (driver.location_debug) {
                    std::cerr << "ID found " << yytext << std::endl;
                }
                return yy::parser::make_IDENTIFIER(yytext, loc);
           }
.          {
                throw yy::parser::syntax_error(loc, "invalid character: " + std::string(yytext));
           }
<<EOF>>    return yy::parser::make_END (loc);
%%

yy::parser::symbol_type make_INTEGER(
  const std::string &s,
  const yy::parser::location_type& loc
) {
  errno = 0;
  long n = strtol(s.c_str(), NULL, 10);
  if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE))
    throw yy::parser::syntax_error(loc, "integer is out of range: " + s);
  return yy::parser::make_INTEGER((int) n, loc);
}