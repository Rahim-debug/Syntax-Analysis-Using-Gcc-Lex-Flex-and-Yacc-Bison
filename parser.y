%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
int yyerror(char *s);
extern FILE* yyin;
extern FILE* tokens;
extern FILE* pars;
extern int yylineno;
int x = 0;
%}

%union{
	char*str;
}

%token <str>Ret <str>Bool <str>Datatype <str>Else <str>If <str>While <str>For <str>Class <str>Func_type
%token <str>Assign <str>Biop <str>Unop <str>Opnbr <str>Clsbr <str>Opnpar <str>Clspar <str>Osqbr <str>Clsqbr 
%token <str>Smicln <str>Comma <str>Const1 <str>Const2 <str>Const3 <str>Const4 <str>Const_F <str>Id 
%token <str>Public <str>StaticStat <str>New <str>Print <str>Relop <str>Logicop <str>Dot <str>Void
%token <str>ExprKw <str>Declare <str>AssignErr

%type <str> Type

%left Logicop
%left Relop
%left '+' '-'
%left '*' '/'
%right '!'
%right Unop

%%

Program : Statements
        ;

Statements : Statement Statements
           | Statement
           | /* empty */
           ;

Statement : DeclStat 
          | ExprStat 
          | IfStat 
          | ForStat 
          | WhileStat 
          | RetStat 
          | PrintStat 
          | Block 
          | MethodDef
          | ClassDef
          | Expr { fprintf(pars, " : expression\n"); }
          | error Smicln { yyerrok; }
          | error Clspar { yyerrok; }
          ;

ClassDef : Class Id Block { fprintf(pars, " : class definition\n"); } ;

MethodDef : Modifiers Type Id Opnbr Params Clsbr Block { fprintf(pars, " : method definition\n"); }
          | Modifiers Type Id Opnbr Params Clsbr Smicln { fprintf(pars, " : method signature\n"); }
          ;

Modifiers : Modifiers Modifier | Modifier | /* empty */ ;
Modifier : Public | StaticStat | Func_type ;

Type : Datatype { $$ = $1; } | Void { $$ = $1; } | Id { $$ = $1; } ;

Params : ParamList | /* empty */ ;
ParamList : Param | ParamList Comma Param ;
Param : Type Id | Type Id Osqbr Clsqbr ;

Block : Opnpar Statements Clspar ;

DeclStat : Type Id Assign Expr Smicln { fprintf(pars, " : declaration statement\n"); }
         | Type Id Smicln { fprintf(pars, " : declaration statement\n"); }
         | Type Id Osqbr Const1 Clsqbr Assign Opnpar ArrayVals Clspar Smicln { fprintf(pars, " : array declaration\n"); }
         | Type Id Osqbr Clsqbr Assign Opnpar ArrayVals Clspar Smicln { fprintf(tokens, "Error on Line %d: Missing dimension size or invalid array declaration format without size or initialization constraints.\n", yylineno); YYABORT; }
         | Type Id Assign New Id Opnbr Clsbr Smicln { fprintf(pars, " : object instantiation\n"); }
         | Declare Type Id Smicln
         | Type Id Assign Opnbr Type Clsbr Expr Smicln {
             if ($1 != NULL && $5 != NULL && strcmp($1, "int") == 0 && strcmp($5, "String") == 0) {
                 fprintf(tokens, "Error on Line %d: Incompatible type cast detected between non-matching data types.\n", yylineno);
                 YYABORT;
             }
         }
         ;

ArrayVals : Expr | ArrayVals Comma Expr | /* empty */ ;

ExprStat : Expr Assign Expr Smicln { fprintf(pars, " : assignment statement\n"); }
         | Expr Smicln { fprintf(pars, " : expression statement\n"); }
         | Id Assign Expr '+' Smicln { fprintf(tokens, "Error on Line %d: Malformed expression, trailing operator before ;.\n", yylineno); YYABORT; }
         ;

IfStat : If Opnbr Expr Clsbr Statement 
       | If Opnbr Expr Clsbr Statement Else Statement
       | If Opnbr Expr Clsbr
       | If Expr { fprintf(tokens, "Error on Line %d: Missing parentheses or malformed condition block.\n", yylineno); YYABORT; }
       ;

ForStat : For Opnbr ForInit Smicln Expr Smicln Expr Clsbr Statement 
        | For Opnbr ForInit Smicln Expr Smicln Expr Clsbr
        ;

ForInit : Type Id Assign Expr | Expr Assign Expr | /* empty */ ;

WhileStat : While Opnbr Expr Clsbr Statement 
          | While Opnbr Expr Clsbr
          ;

RetStat : Ret Expr Smicln | Ret Smicln ;

PrintStat : Print Opnbr PrintArgs Clsbr Smicln { fprintf(pars, " : print statement\n"); }
          | Print Opnbr Smicln Clsbr { fprintf(tokens, "Error on Line %d: Malformed parameter or unexpected token ; inside method call.\n", yylineno); YYABORT; }
          ;

PrintArgs : Expr | PrintArgs Comma Expr | /* empty */ ;

Expr : Expr '+' Expr 
     | Expr '-' Expr 
     | Expr '*' Expr 
     | Expr '/' Expr
     | Expr Relop Expr 
     | Expr Logicop Expr 
     | Logicop Expr 
     | Expr Unop 
     | Unop Expr 
     | Opnbr Expr Clsbr 
     | Opnbr Type Clsbr Expr %prec Unop
     | Id Osqbr Expr Clsqbr
     | Id 
     | Const1 | Const2 | Const3 | Const4 | Const_F | Bool 
     | Id Opnbr PrintArgs Clsbr 
     | Expr Logicop Clsbr { fprintf(tokens, "Error on Line %d: Malformed logical expression or missing operand.\n", yylineno); YYABORT; }
     ;

%%

int yyerror(char *s)
{
	fprintf(tokens,"Error on Line %d: Malformed expression or invalid operator sequence.\n",yylineno);
	fprintf(pars,"Error on Line %d: Malformed expression or invalid operator sequence.\n",yylineno);
	return 0;
}

int main(int argc,char*argv[])
{	
	yyin = fopen(argv[1],"r");
	char s1[30] = "seq_tokens_";
	char s2[30] = "parser_";
	strcat(s1,argv[1]);
	strcat(s2,argv[1]);
	tokens = fopen(s1,"w");
	pars = fopen(s2,"w");
    yyparse();
	fclose(yyin);
	fclose(tokens);
	fclose(pars);
    return 0;
}