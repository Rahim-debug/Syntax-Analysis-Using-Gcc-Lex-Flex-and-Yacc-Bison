%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.tab.h"
FILE* tokens;
FILE* pars;
%}

%option yylineno

/* Rules */
constant4   [-]?[1-9][0-9]*|0
constant_f  [-]?[0-9]+\.[0-9]+
constant1   [1-9][0-9]*|0
constant2   \"([^"\\]|\\.)*\"
constant3   ['].[']
variable    [A-Za-z][A-Za-z0-9_]*

invalid_var1 [0-9]+[A-Za-z_][A-Za-z0-9_]*
invalid_var2 {variable}\$

func_type   ("global"|"local")
tf          ("true"|"false")
class       ("class")
for         ("for")
while       ("while")
if          ("if")
else        ("else"|"otherwise")
return      ("return")
new         ("new")
public      ("public")
staticStat  ("staticStat")
print       ("System.out.println"|"System.out.print"|"print")

relop       ("=="|">="|"<="|"!="|">"|"<")
logicop     ("&&"|"||"|"!")
unop        ("postincr"|"postdecr"|"++"|"--")
datatype    ("int"|"char"|"string"|"String"|"bool"|"boolean"|"float"|"double")
void        ("void")

%%

"//".*      { /* Ignore single-line comments */ }
"/*"([^*]|\*+[^*/])*\*+"/" { 
    for(int i=0; i<yyleng; i++) {
        if(yytext[i] == '\n') yylineno++; /* actually %option yylineno handles this inside flex automatically usually, but we keep it */
    }
}
[ \t\r]+    { /* ignore spaces */ }
\n          { /* %option yylineno handles this */ }

{invalid_var1} { fprintf(tokens, "Error on Line %d: Invalid identifier format (cannot start with a number).\n", yylineno); return 0; }
{invalid_var2} { fprintf(tokens, "Error on Line %d: Illegal character $ in the identifier.\n", yylineno); return 0; }

{datatype}  { fprintf(tokens,"datatype : %s\n",yytext); yylval.str = strdup(yytext); return Datatype; }
{void}      { fprintf(tokens,"datatype : %s\n",yytext); yylval.str = strdup(yytext); return Void; }

{if}        { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return If; }
{else}      { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return Else; }
{for}       { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return For; }
{while}     { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return While; }
{return}    { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return Ret; }
{new}       { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return New; }
{public}    { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return Public; }
{staticStat} { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return StaticStat; }
{print}     { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return Print; }
{class}     { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return Class; }
{tf}        { fprintf(tokens,"constant : %s\n",yytext); yylval.str = strdup(yytext); return Bool; }
{func_type} { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return Func_type; }

"expr"      { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return ExprKw; }
"declare"   { fprintf(tokens,"reserved keyword : %s\n",yytext); yylval.str = strdup(yytext); return Declare; }

"+"         { fprintf(tokens,"operator : %s\n",yytext); yylval.str = strdup(yytext); return '+'; }
"-"         { fprintf(tokens,"operator : %s\n",yytext); yylval.str = strdup(yytext); return '-'; }
"*"         { fprintf(tokens,"operator : %s\n",yytext); yylval.str = strdup(yytext); return '*'; }
"/"         { fprintf(tokens,"operator : %s\n",yytext); yylval.str = strdup(yytext); return '/'; }
"="         { fprintf(tokens,"operator : %s\n",yytext); yylval.str = strdup(yytext); return Assign; }

{relop}     { fprintf(tokens,"operator : %s\n",yytext); yylval.str = strdup(yytext); return Relop; }
{logicop}   { fprintf(tokens,"operator : %s\n",yytext); yylval.str = strdup(yytext); return Logicop; }
{unop}      { fprintf(tokens,"operator : %s\n",yytext); yylval.str = strdup(yytext); return Unop; }

"("         { fprintf(tokens,"special symbol : %s\n",yytext); yylval.str = strdup(yytext); return Opnbr; }
")"         { fprintf(tokens,"special symbol : %s\n",yytext); yylval.str = strdup(yytext); return Clsbr; }
"{"         { fprintf(tokens,"special symbol : %s\n",yytext); yylval.str = strdup(yytext); return Opnpar; }
"}"         { fprintf(tokens,"special symbol : %s\n",yytext); yylval.str = strdup(yytext); return Clspar; }
"["         { fprintf(tokens,"special symbol : %s\n",yytext); yylval.str = strdup(yytext); return Osqbr; }
"]"         { fprintf(tokens,"special symbol : %s\n",yytext); yylval.str = strdup(yytext); return Clsqbr; }
";"         { fprintf(tokens,"punctuation : %s\n",yytext); yylval.str = strdup(yytext); return Smicln; }
","         { fprintf(tokens,"punctuation : %s\n",yytext); yylval.str = strdup(yytext); return Comma; }
"."         { fprintf(tokens,"punctuation : %s\n",yytext); yylval.str = strdup(yytext); return Dot; }
":="        { fprintf(tokens,"operator : %s\n",yytext); return AssignErr; }

{constant_f} { fprintf(tokens,"constant : %s\n",yytext); yylval.str = strdup(yytext); return Const_F; }
{constant1} { fprintf(tokens,"constant : %s\n",yytext); yylval.str = strdup(yytext); return Const1; }
{constant2} { fprintf(tokens,"constant : %s\n",yytext); yylval.str = strdup(yytext); return Const2; }
{constant3} { fprintf(tokens,"constant : %s\n",yytext); yylval.str = strdup(yytext); return Const3; }
{constant4} { fprintf(tokens,"constant : %s\n",yytext); yylval.str = strdup(yytext); return Const4; }

{variable}  { fprintf(tokens,"id : %s\n",yytext); yylval.str = strdup(yytext); return Id; }

.           { fprintf(tokens,"lexical error at %d",yylineno); return 0; }

%%

int yywrap() { return 1; }