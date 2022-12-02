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
  #define YY_USER_ACTION UpdateLocation();
%}

%%
%{
  yy::location& loc = driver.location;
%}

{blank}+   {}

"program"           return yy::parser::make_PROGRAM(loc);
"end"               return yy::parser::make_END(loc);
"integer"           return yy::parser::make_INT_DECLARATION(loc);
"print"             return yy::parser::make_PRINT(loc);
"if"                return yy::parser::make_IF(loc);
"else"              return yy::parser::make_ELSE(loc);
"then"              return yy::parser::make_THEN(loc);
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
".AND."             return yy::parser::make_AND_SYM(loc);
".OR."              return yy::parser::make_OR_SYM(loc);
".NOT."             return yy::parser::make_NOT_SYM(loc);
".TRUE."            return yy::parser::make_TRUE_SYM(loc);
".FALSE."           return yy::parser::make_FALSE_SYM(loc);
".EQ."              return yy::parser::make_EQUAL_SYM(loc);
".NE."              return yy::parser::make_NOT_EQUAL_SYM(loc);
".GE."              return yy::parser::make_GE_SYM(loc);
".LE."              return yy::parser::make_LE_SYM(loc);
".GT."              return yy::parser::make_GT_SYM(loc);
".LS."              return yy::parser::make_LS_SYM(loc);
">"                 return yy::parser::make_GREATER(loc);
"<"                 return yy::parser::make_LESS(loc);

\n+                 {
                        loc.lines(yyleng);
                        loc.step();
                        return yy::parser::make_NEW_LINE_SEPARATOR(loc);
                    }

{int}               return make_INTEGER(yytext, loc);
{id}                {
                        if (driver.location_debug) {
                            std::cerr << "ID found " << yytext << std::endl;
                        }
                        return yy::parser::make_IDENTIFIER(yytext, loc);
                    }
.                   {
                        throw yy::parser::syntax_error(loc, "invalid character: " + std::string(yytext));
                    }
<<EOF>>             return yy::parser::make_EOF (loc);
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