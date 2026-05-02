
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     Ret = 258,
     Bool = 259,
     Datatype = 260,
     Else = 261,
     If = 262,
     While = 263,
     For = 264,
     Class = 265,
     Func_type = 266,
     Assign = 267,
     Biop = 268,
     Unop = 269,
     Opnbr = 270,
     Clsbr = 271,
     Opnpar = 272,
     Clspar = 273,
     Osqbr = 274,
     Clsqbr = 275,
     Smicln = 276,
     Comma = 277,
     Const1 = 278,
     Const2 = 279,
     Const3 = 280,
     Const4 = 281,
     Const_F = 282,
     Id = 283,
     Public = 284,
     StaticStat = 285,
     New = 286,
     Print = 287,
     Relop = 288,
     Logicop = 289,
     Dot = 290,
     Void = 291,
     ExprKw = 292,
     Declare = 293,
     AssignErr = 294
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 66 "parser.y"

	char* str;
    struct ASTNode* node;



/* Line 1676 of yacc.c  */
#line 98 "parser.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


