%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

int yylex();
int yyerror(char *s);
extern FILE* yyin;
extern FILE* tokens;
extern FILE* pars;
extern int yylineno;
int x = 0;

typedef struct ASTNode {
    char* name;
    char* value;
    int num_children;
    struct ASTNode** children;
} ASTNode;

ASTNode* createNode(const char* name, int num_children, ...) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->name = strdup(name);
    node->value = NULL;
    node->num_children = num_children;
    if (num_children > 0) {
        node->children = (ASTNode**)malloc(num_children * sizeof(ASTNode*));
        va_list args;
        va_start(args, num_children);
        for (int i = 0; i < num_children; i++) {
            node->children[i] = va_arg(args, ASTNode*);
        }
        va_end(args);
    } else {
        node->children = NULL;
    }
    return node;
}

ASTNode* createLeaf(const char* name, const char* value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->name = strdup(name);
    node->value = value ? strdup(value) : NULL;
    node->num_children = 0;
    node->children = NULL;
    return node;
}

void printTree(ASTNode* node, int depth) {
    if (!node) return;
    for (int i = 0; i < depth; i++) {
        fprintf(pars, "  ");
    }
    if (node->value) {
        fprintf(pars, "%s (%s)\n", node->name, node->value);
    } else {
        fprintf(pars, "%s\n", node->name);
    }
    for (int i = 0; i < node->num_children; i++) {
        printTree(node->children[i], depth + 1);
    }
}
%}

%union{
	char* str;
    struct ASTNode* node;
}

%token <str>Ret <str>Bool <str>Datatype <str>Else <str>If <str>While <str>For <str>Class <str>Func_type
%token <str>Assign <str>Biop <str>Unop <str>Opnbr <str>Clsbr <str>Opnpar <str>Clspar <str>Osqbr <str>Clsqbr 
%token <str>Smicln <str>Comma <str>Const1 <str>Const2 <str>Const3 <str>Const4 <str>Const_F <str>Id 
%token <str>Public <str>StaticStat <str>New <str>Print <str>Relop <str>Logicop <str>Dot <str>Void
%token <str>ExprKw <str>Declare <str>AssignErr

%type <node> Program Statements Statement ClassDef MethodDef Modifiers Modifier Type Params ParamList Param Block DeclStat ArrayVals ExprStat IfStat ForStat ForInit WhileStat RetStat PrintStat PrintArgs Expr

%left Logicop
%left Relop
%left '+' '-'
%left '*' '/'
%right '!'
%right Unop

%%

Program : Statements { 
            $$ = createNode("Program", 1, $1); 
            printTree($$, 0); 
        }
        ;

Statements : Statement Statements { $$ = createNode("Statements", 2, $1, $2); }
           | Statement { $$ = createNode("Statements", 1, $1); }
           | /* empty */ { $$ = NULL; }
           ;

Statement : DeclStat { $$ = $1; }
          | ExprStat { $$ = $1; }
          | IfStat { $$ = $1; }
          | ForStat { $$ = $1; }
          | WhileStat { $$ = $1; }
          | RetStat { $$ = $1; }
          | PrintStat { $$ = $1; }
          | Block { $$ = $1; }
          | MethodDef { $$ = $1; }
          | ClassDef { $$ = $1; }
          | Expr { $$ = createNode("ExprStat", 1, $1); }
          | error Smicln { yyerrok; $$ = createNode("Error", 0); }
          | error Clspar { yyerrok; $$ = createNode("Error", 0); }
          ;

ClassDef : Class Id Block { $$ = createNode("ClassDef", 2, createLeaf("Id", $2), $3); } ;

MethodDef : Modifiers Type Id Opnbr Params Clsbr Block { 
                $$ = createNode("MethodDef", 5, $1, $2, createLeaf("Id", $3), $5, $7); 
            }
          | Modifiers Type Id Opnbr Params Clsbr Smicln { 
                $$ = createNode("MethodSignature", 4, $1, $2, createLeaf("Id", $3), $5); 
            }
          ;

Modifiers : Modifiers Modifier { $$ = createNode("Modifiers", 2, $1, $2); }
          | Modifier { $$ = createNode("Modifiers", 1, $1); }
          | /* empty */ { $$ = NULL; }
          ;

Modifier : Public { $$ = createLeaf("Modifier", $1); }
         | StaticStat { $$ = createLeaf("Modifier", $1); }
         | Func_type { $$ = createLeaf("Modifier", $1); }
         ;

Type : Datatype { $$ = createLeaf("Type", $1); } 
     | Void { $$ = createLeaf("Type", $1); } 
     | Id { $$ = createLeaf("Type", $1); } 
     ;

Params : ParamList { $$ = createNode("Params", 1, $1); } 
       | /* empty */ { $$ = NULL; } 
       ;

ParamList : Param { $$ = createNode("ParamList", 1, $1); } 
          | ParamList Comma Param { $$ = createNode("ParamList", 2, $1, $3); } 
          ;

Param : Type Id { $$ = createNode("Param", 2, $1, createLeaf("Id", $2)); } 
      | Type Id Osqbr Clsqbr { $$ = createNode("ArrayParam", 2, $1, createLeaf("Id", $2)); } 
      ;

Block : Opnpar Statements Clspar { $$ = createNode("Block", 1, $2); } ;

DeclStat : Type Id Assign Expr Smicln { 
               $$ = createNode("DeclStat", 3, $1, createLeaf("Id", $2), $4); 
           }
         | Type Id Smicln { 
               $$ = createNode("DeclStat", 2, $1, createLeaf("Id", $2)); 
           }
         | Type Id Osqbr Const1 Clsqbr Assign Opnpar ArrayVals Clspar Smicln { 
               $$ = createNode("ArrayDeclStat", 4, $1, createLeaf("Id", $2), createLeaf("Size", $4), $8); 
           }
         | Type Id Osqbr Clsqbr Assign Opnpar ArrayVals Clspar Smicln { 
               fprintf(tokens, "Error on Line %d: Missing dimension size or invalid array declaration format without size or initialization constraints.\n", yylineno); YYABORT; 
           }
         | Type Id Assign New Id Opnbr Clsbr Smicln { 
               $$ = createNode("ObjectInstantiation", 3, $1, createLeaf("Id", $2), createLeaf("Class", $5)); 
           }
         | Declare Type Id Smicln {
               $$ = createNode("DeclStat", 3, createLeaf("Declare", $1), $2, createLeaf("Id", $3));
           }
         | Type Id Assign Opnbr Type Clsbr Expr Smicln {
             if ($1 && $1->value && $5 && $5->value && strcmp($1->value, "int") == 0 && strcmp($5->value, "String") == 0) {
                 fprintf(tokens, "Error on Line %d: Incompatible type cast detected between non-matching data types.\n", yylineno);
                 YYABORT;
             }
             $$ = createNode("CastDeclStat", 4, $1, createLeaf("Id", $2), $5, $7);
         }
         ;

ArrayVals : Expr { $$ = createNode("ArrayVals", 1, $1); }
          | ArrayVals Comma Expr { $$ = createNode("ArrayVals", 2, $1, $3); }
          | /* empty */ { $$ = NULL; }
          ;

ExprStat : Expr Assign Expr Smicln { $$ = createNode("AssignStat", 2, $1, $3); }
         | Expr Smicln { $$ = createNode("ExprStat", 1, $1); }
         | Id Assign Expr '+' Smicln { 
               fprintf(tokens, "Error on Line %d: Malformed expression, trailing operator before ;.\n", yylineno); YYABORT; 
           }
         ;

IfStat : If Opnbr Expr Clsbr Statement { 
             $$ = createNode("IfStat", 2, $3, $5); 
         }
       | If Opnbr Expr Clsbr Statement Else Statement { 
             $$ = createNode("IfElseStat", 3, $3, $5, $7); 
         }
       | If Opnbr Expr Clsbr { 
             $$ = createNode("IfStat", 1, $3); 
         }
       | If Expr { 
             fprintf(tokens, "Error on Line %d: Missing parentheses or malformed condition block.\n", yylineno); YYABORT; 
         }
       ;

ForStat : For Opnbr ForInit Smicln Expr Smicln Expr Clsbr Statement { 
              $$ = createNode("ForStat", 4, $3, $5, $7, $9); 
          }
        | For Opnbr ForInit Smicln Expr Smicln Expr Clsbr { 
              $$ = createNode("ForStat", 3, $3, $5, $7); 
          }
        ;

ForInit : Type Id Assign Expr { $$ = createNode("ForInitDecl", 3, $1, createLeaf("Id", $2), $4); }
        | Expr Assign Expr { $$ = createNode("ForInitAssign", 2, $1, $3); }
        | /* empty */ { $$ = NULL; }
        ;

WhileStat : While Opnbr Expr Clsbr Statement { $$ = createNode("WhileStat", 2, $3, $5); }
          | While Opnbr Expr Clsbr { $$ = createNode("WhileStat", 1, $3); }
          ;

RetStat : Ret Expr Smicln { $$ = createNode("RetStat", 1, $2); }
        | Ret Smicln { $$ = createNode("RetStat", 0); }
        ;

PrintStat : Print Opnbr PrintArgs Clsbr Smicln { $$ = createNode("PrintStat", 1, $3); }
          | Print Opnbr Smicln Clsbr { 
                fprintf(tokens, "Error on Line %d: Malformed parameter or unexpected token ; inside method call.\n", yylineno); YYABORT; 
            }
          ;

PrintArgs : Expr { $$ = createNode("PrintArgs", 1, $1); }
          | PrintArgs Comma Expr { $$ = createNode("PrintArgs", 2, $1, $3); }
          | /* empty */ { $$ = NULL; }
          ;

Expr : Expr '+' Expr { $$ = createNode("Expr", 3, $1, createLeaf("Operator", "+"), $3); }
     | Expr '-' Expr { $$ = createNode("Expr", 3, $1, createLeaf("Operator", "-"), $3); }
     | Expr '*' Expr { $$ = createNode("Expr", 3, $1, createLeaf("Operator", "*"), $3); }
     | Expr '/' Expr { $$ = createNode("Expr", 3, $1, createLeaf("Operator", "/"), $3); }
     | Expr Relop Expr { $$ = createNode("Expr", 3, $1, createLeaf("Relop", $2), $3); }
     | Expr Logicop Expr { $$ = createNode("Expr", 3, $1, createLeaf("Logicop", $2), $3); }
     | Logicop Expr { $$ = createNode("UnaryExpr", 2, createLeaf("Logicop", $1), $2); }
     | Expr Unop { $$ = createNode("PostOp", 2, $1, createLeaf("Unop", $2)); }
     | Unop Expr { $$ = createNode("PreOp", 2, createLeaf("Unop", $1), $2); }
     | Opnbr Expr Clsbr { $$ = createNode("ParenExpr", 1, $2); }
     | Opnbr Type Clsbr Expr %prec Unop { $$ = createNode("CastExpr", 2, $2, $4); }
     | Id Osqbr Expr Clsqbr { $$ = createNode("ArrayAccess", 2, createLeaf("Id", $1), $3); }
     | Id { $$ = createLeaf("Id", $1); }
     | Const1 { $$ = createLeaf("Const1", $1); }
     | Const2 { $$ = createLeaf("Const2", $1); }
     | Const3 { $$ = createLeaf("Const3", $1); }
     | Const4 { $$ = createLeaf("Const4", $1); }
     | Const_F { $$ = createLeaf("Const_F", $1); }
     | Bool { $$ = createLeaf("Bool", $1); }
     | Id Opnbr PrintArgs Clsbr { $$ = createNode("MethodCall", 2, createLeaf("Id", $1), $3); }
     | Expr Logicop Clsbr { 
           fprintf(tokens, "Error on Line %d: Malformed logical expression or missing operand.\n", yylineno); YYABORT; 
       }
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
    if (argc < 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }
	yyin = fopen(argv[1],"r");
	char s1[100] = "seq_tokens_";
	char s2[100] = "parser_";
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