/*
 *  bison specifications for the MIPL language.
 *  Written to meet requirements for CS 5500, Fall 2018.
 */

/*
 *  Declaration section.
 */

%{

#   include <stdio.h>
#   include <ctype.h>
#include <iostream>
#include <vector>
#include <string>
#include "TYPE_INFO.h"
#include "SymbolTable.h"



std::vector<std::string> identNames;
std::vector<std::string> factorTypes;
SymbolTable symbolTable;
SymbolData symData;

char NOT_APPLICABLE[20] = "";
char ARRAY[20]  = "ARRAY";
char BOOLEAN[20]  = "BOOLEAN";
char CHAR[20]  = "CHAR";
char INTEGER[20]  = "INTEGER";
char LOGICAL_OP[20] = "LOGICAL";
char ARITHMETIC_OP[20] = "ARITHMETIC";
char ERROR[20] = "ERROR";


void	ignoreComment();
int ckInt();
void  prRule(const char*, const char*);
void prAdding(const char*, const char*);
void printTokenInfo(const char* tokenType, 
                    const char* lexeme);
void copyArray(char copyTo[], const char copyFrom[]);
void prAdding(const char *name, const char *type, const char *startSign, const char *startIndex, const char* endSign, const char* endIndex, const char *baseType);


int yyerror(const char*);

extern "C" {
    int yyparse(void);
    int yylex(void);
    int yywrap() {return 1;}
}

#define MAX_INT	"2147483647"

#define OUTPUT_TOKENS	     0
#define OUTPUT_PRODUCTIONS 0
//#define LOGICAL_OP 100
//#define ARITHMETIC_OP 101

int lineNum = 1;                   // source line number

%}

%union
{
    char* text;
    TYPE_INFO typeInfo;
    int intValue;
};


/*
 *  Token declaration. 'N_...' for rules, 'T_...' for tokens.
 *  Note: tokens are also used in the flex specification file.
 */
%token      T_LPAREN    T_RPAREN    T_MULT	     T_PLUS
%token      T_COMMA     T_MINUS     T_DOT       T_DOTDOT
%token      T_COLON     T_ASSIGN    T_SCOLON    T_LT
%token      T_LE        T_NE        T_EQ        T_GT
%token      T_GE        T_LBRACK    T_RBRACK    T_DO
%token      T_AND       T_ARRAY     T_BEGIN     T_BOOL
%token      T_CHAR      T_DIV       T_CHARCONST T_INTCONST
%token      T_END       T_FALSE     T_IF        T_INT
%token      T_NOT       T_OF        T_OR        T_PROC
%token      T_PROG      T_READ      T_TRUE      T_IDENT
%token      T_VAR       T_WHILE     T_WRITE     T_UNKNOWN

%token      ST_EOF

%type<text> T_IDENT T_INTCONST T_PROC T_PLUS T_MINUS
%type <typeInfo> N_START N_ADD_OP N_ADD_OP_LOGICAL N_ADD_OP_ARITHMETIC N_MULT_OP N_MULT_OP_LOGICAL N_MULT_OP_ARITHMETIC N_ADDOPLST N_ARRAY N_ARRAYVAR N_ASSIGN N_BLOCK N_BOOLCONST N_COMPOUND N_CONDITION N_CONST N_ENTIREVAR N_EXPR N_FACTOR N_IDENT N_IDENTLST N_IDX N_IDXRANGE N_IDXVAR N_INPUTLST N_INPUTVAR N_INTCONST N_MULTOPLST N_OUTPUT N_OUTPUTLST N_PROCDEC N_PROCHDR N_PROCDECPART N_PROCIDENT N_PROCSTMT N_PROG N_PROGLBL N_READ N_RELOP N_SIGN N_SIMPLE N_SIMPLEEXPR N_STMT N_STMTLST N_STMTPART N_TERM N_TYPE N_VARDEC N_VARDECLST N_VARDECPART N_VARIABLE N_VARIDENT N_WHILE N_WRITE


/*
 *  To eliminate ambiguities.
 */
%nonassoc   T_THEN
%nonassoc   T_ELSE

/*
 *  Starting point.
 */
%start      N_START

/*
 *  Translation rules.
 */
%%
N_START         : N_PROG
                    {
                    prRule("N_START", "N_PROG");
			    printf("\n---- Completed parsing ----\n\n");
			    return 0;
                    }
                ;

N_ADD_OP : N_ADD_OP_LOGICAL
            {
                copyArray($$.opType,LOGICAL_OP);
            }
            | N_ADD_OP_ARITHMETIC
            {
                copyArray($$.opType,ARITHMETIC_OP);
            }
            ;

N_ADD_OP_LOGICAL        : T_OR 
                            {
                                prRule("N_ADD_OP_LOGICAL", "T_OR");
                            }
                        ;
N_ADD_OP_ARITHMETIC     : T_PLUS
                            {
                                prRule("N_ADD_OP_ARITHMETIC", "T_PLUS");
                            }
                        | T_MINUS
                            {
                                prRule("N_ADD_OP_ARITHMETIC", "T_MINUS");
                            }
                        ;
N_MULT_OP               : N_MULT_OP_LOGICAL
                            {
                                prRule("N_MULT_OP", "N_MULT_OP_LOGICAL");
                                copyArray($$.opType,LOGICAL_OP);
                            }
                        | N_MULT_OP_ARITHMETIC
                            {
                                prRule("N_MULT_OP", "N_MULT_OP_ARITHMETIC");
                                copyArray($$.opType,ARITHMETIC_OP);
                            }
                        ;
N_MULT_OP_LOGICAL      : T_AND
                            {
                                prRule("N_ MULT_OP_LOGICAL", "T_AND");
                            }
                        ;
N_MULT_OP_ARITHMETIC    : T_MULT
                            {
                                prRule("N_MULT_OP_ARITHMETIC", "T_MULT");
                            }
                        | T_DIV
                            {
                                prRule("N_MULT_OP_ARITHMETIC", "T_DIV");
                            }
                        ;
N_ADDOPLST      : /* epsilon */
                    {
                    prRule("N_ADDOPLST", "epsilon");
                    }
                | N_ADD_OP N_TERM N_ADDOPLST
                    {
                    prRule("N_ADDOPLST", "N_ADD_OP N_TERM N_ADDOPLST");
                    }
                ;
N_ARRAY         : T_ARRAY T_LBRACK N_IDXRANGE T_RBRACK T_OF N_SIMPLE
                    {
                        prRule("N_ARRAY","T_ARRAY T_LBRACK N_IDXRANGE T_RBRACK T_OF N_SIMPLE");
                        copyArray($$.type,ARRAY);
                        copyArray($$.startSign,$3.startSign);
                        copyArray($$.startIndex,$3.startIndex);
                        copyArray($$.endSign,$3.endSign);
                        copyArray($$.endIndex,$3.endIndex);
                        copyArray($$.baseType,$6.type);
                        
                        std::string stSign = $3.startSign;
                        std::string stIndex = $3.startIndex;
                        std::string eSign = $3.endSign;
                        std::string eIndex = $3.endIndex;
                        int startNum = stoi(stIndex);
                        int endNum = stoi(eIndex);
                        //std::cout << "                                            " << $3.startSign << $3.startIndex << ".." << $3.endSign << $3.endIndex << std::endl;                       
                        //std::cout << "                                                     " << stSign << stIndex << ".." << eSign << eIndex << std::endl;

                        if(stSign == "-")
                        {
                            startNum = -startNum;
                        }
                        if(eSign == "-")
                        {
                            endNum = -endNum;
                        }
                        //std::cout << startNum << ".." << endNum << std::endl;

                        if(startNum > endNum)
                        {
                            yyerror("Start index must be less than or equal to end index of array");
                        }
                    }
                ;
N_ARRAYVAR      : N_ENTIREVAR
                    {
                        copyArray($$.lexeme,$1.lexeme);
                        prRule("N_ARRAYVAR", "N_ENTIREVAR");
                    }
                ;
N_ASSIGN        : N_VARIABLE T_ASSIGN N_EXPR
                    {
                        SymbolData lhs;
                        SymbolData rhs;
                        try
                        {
                            lhs = symbolTable.getSymbolData($1.lexeme);
                            rhs = symbolTable.getSymbolData($3.lexeme); //there's problem if rhs is an int const
                        } catch(...){}

                        if((lhs.m_type != "PROCEDURE" && rhs.m_type == "PROCEDURE") 
                            || (lhs.m_type == "PROCEDURE" && rhs.m_type != "PROCEDURE"))
                        {
                            yyerror("Procedure/variable mismatch");
                        }

                        std::string exprType = $3.type;
                        std::string exprVarType = $3.varType;
                        if(exprType == "ARRAY" && exprVarType == "IDXVAR")
                        {
                            exprType = $3.baseType;
                        }

                        //std::cout << "________________________________________________________________________" << exprType << "_" << std::endl;
                        
                        if(exprType != "") //just in case
                        {
                            std::string vType = $1.varType;
                            if(lhs.m_type == "ARRAY" && vType == "NON_IDXVAR")
                            {
                                yyerror("Cannot make assignment to an array");
                            }
                            if(lhs.m_type != exprType && lhs.m_baseType != exprType)
                            {
                                yyerror("Expression must be of same type as variable");
                            }
                        }
                        prRule("N_ASSIGN", "N_VARIABLE T_ASSIGN N_EXPR");
                    }
                ;
N_BLOCK         : N_VARDECPART N_PROCDECPART N_STMTPART
                    {
                        prRule("N_BLOCK", "N_VARDECPART N_PROCDECPART N_STMTPART");
                        symbolTable.popScope();
                    }
                ;
N_BOOLCONST     : T_TRUE
                    {
                    prRule("N_BOOLCONST", "T_TRUE");
                    }
                | T_FALSE
                    {
                    prRule("N_BOOLCONST", "T_FALSE");
                    }
                ;
N_COMPOUND      : T_BEGIN N_STMT N_STMTLST T_END
                    {
                    prRule("N_COMPOUND", "T_BEGIN N_STMT N_STMTLST T_END");
                    }
                ;
N_CONDITION     : T_IF N_EXPR T_THEN N_STMT
                    {
                        prRule("N_CONDITION", "T_IF N_EXPR T_THEN N_STMT");
                        
                        std::string exprType = $2.type;
                        if(exprType != "") //just in case type is empty, just ignore it
                        {
                            if(exprType != "BOOLEAN") //type must be bool
                            {
                                //std::cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@here1" << std::endl;
                                yyerror("Expression must be of type boolean");
                            }
                        }
                    }
                | T_IF N_EXPR T_THEN N_STMT T_ELSE N_STMT
                    {
                        prRule("N_CONDITION", "T_IF N_EXPR T_THEN N_STMT T_ELSE N_STMT");

                        std::string temp = $2.type;
                        if(temp != "") //just in case type is empty, just ignore it
                        {
                            if(temp != "BOOLEAN") //type must be bool
                            {
                                //std::cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@here2" << std::endl;
                                yyerror("Expression must be of type boolean");
                            }
                        }
                    }
                ;
N_CONST         : N_INTCONST
                    {
                        copyArray($$.lexeme,$1.lexeme);
                        copyArray($$.type,INTEGER);
                        prRule("N_CONST", "N_INTCONST");
                    }
                | T_CHARCONST
                    {
                        //copyArray($$.lexeme,$1);
                        copyArray($$.type,CHAR);
                        prRule("N_CONST", "T_CHARCONST");
                    }
                | N_BOOLCONST
                    {
                        copyArray($$.type,BOOLEAN);
                        prRule("N_CONST", "N_BOOLCONST");
                    }
                ;
N_ENTIREVAR     : N_VARIDENT
                    {
                        copyArray($$.lexeme,$1.lexeme);
                        copyArray($$.type,$1.type);
                        prRule("N_ENTIREVAR", "N_VARIDENT");
                    }
                ;
N_EXPR          : N_SIMPLEEXPR
                    {
                        copyArray($$.lexeme,$1.lexeme);
                        copyArray($$.type,$1.type);
                        copyArray($$.baseType,$1.baseType);
                        copyArray($$.varType,$1.varType);
                        prRule("N_EXPR", "N_SIMPLEEXPR");
                    }
                | N_SIMPLEEXPR N_RELOP N_SIMPLEEXPR
                    {
                        std::string exprOneType = $1.type;
                        std::string exprTwoType = $3.type;
                        copyArray($$.type,BOOLEAN);
                        //std::cout << "__________lhstype = " << exprOneType << "____ rhsType = " << exprTwoType << "____" << std::endl;
                        if(exprOneType == "ARRAY")
                        {
                            exprOneType = $1.baseType;
                        }
                        if(exprTwoType == "ARRAY")
                        {
                            exprTwoType = $3.baseType;
                        }
            
                        if(exprOneType != exprTwoType)
                        {
                            //std::cout << "__________lhstype = " << exprOneType << "____ rhsType = " << exprTwoType << "____" << std::endl;
                            yyerror("Expressions must both be int, or both char, or both boolean");
                        }
                        
                        prRule("N_EXPR", "N_SIMPLEEXPR N_RELOP N_SIMPLEEXPR");
                    }
                ;
N_FACTOR        : N_SIGN N_VARIABLE
                    {
                        copyArray($$.lexeme,$2.lexeme);
                        copyArray($$.type,$2.type);
                        copyArray($$.baseType,$2.baseType);
                        copyArray($$.varType,$2.varType);

                        std::string signLex = $1.lexeme;
                        std::string varType = $2.type;
                        if((signLex == "-" || signLex == "+") && varType != "INTEGER")
                        {
                            yyerror("Expression must be of type integer");
                        }

                        prRule("N_FACTOR", "N_SIGN N_VARIABLE");
                    }
                | N_CONST
                    {
                        copyArray($$.lexeme,$1.lexeme);
                        copyArray($$.type,$1.type);
                        prRule("N_FACTOR", "N_CONST");
                    }
                | T_LPAREN N_EXPR T_RPAREN
                    {
                        copyArray($$.type,$2.type);
                        prRule("N_FACTOR", "T_LPAREN N_EXPR T_RPAREN");
                    }
                | T_NOT N_FACTOR
                    {
                        prRule("N_FACTOR", "T_NOT N_FACTOR");
                        copyArray($$.type,$2.type);
                        std::string factType = $2.type;
                        if(factType != "BOOLEAN")
                        {
                            //std::cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@here3" << std::endl;
                            yyerror("Expression must be of type boolean");
                        }
                    }
                ;
N_IDENT         : T_IDENT
                    {
                        //printf("The Ident's name is %s\n", $1);
                        copyArray($$.lexeme,$1);
                        prRule("N_IDENT", "T_IDENT");
                    }
                ;
N_IDENTLST      : /* epsilon */
                    {
                    prRule("N_IDENTLST", "epsilon");
                    }
                | T_COMMA N_IDENT {identNames.push_back($2.lexeme);} N_IDENTLST
                    {
                        //copyArray($$.lexeme,$2.lexeme);
                        prRule("N_IDENTLST", "T_COMMA N_IDENT N_IDENTLST");
                    }
                ;
N_IDX           : N_INTCONST
                    {
                        copyArray($$.type , NOT_APPLICABLE);
                        copyArray($$.startSign,$1.startSign);
                        copyArray($$.startIndex, $1.startIndex);
                        copyArray($$.endSign,$1.endSign);
                        copyArray($$.endIndex,$1.endIndex);
                        copyArray($$.baseType,NOT_APPLICABLE);
                        prRule("N_IDX", "N_INTCONST");
                    }
                ;
N_IDXRANGE      : N_IDX T_DOTDOT N_IDX
                    {
                        prRule("N_IDXRANGE", "N_IDX T_DOTDOT N_IDX");
                        copyArray($$.type , NOT_APPLICABLE);
                        copyArray($$.startSign,$1.startSign);
                        copyArray($$.startIndex , $1.startIndex);
                        copyArray($$.endSign,$3.endSign);
                        copyArray($$.endIndex , $3.endIndex);
                        copyArray($$.baseType , NOT_APPLICABLE);
                        

                    }
                ;
N_IDXVAR        : N_ARRAYVAR T_LBRACK N_EXPR T_RBRACK
                    {
                        prRule("N_IDXVAR", "N_ARRAYVAR T_LBRACK N_EXPR T_RBRACK");
                        
                        //copyArray($$.lexeme, $3.lexeme);
                        SymbolData expr;
                        SymbolData array;
                        if($3.lexeme != "" && $3.lexeme[0] != '0' && $3.lexeme[0] != '1'
                            && $3.lexeme[0] != '2' && $3.lexeme[0] != '3' && $3.lexeme[0] != '4'
                            && $3.lexeme[0] != '5' && $3.lexeme[0] != '6' && $3.lexeme[0] != '7'
                            && $3.lexeme[0] != '8' && $3.lexeme[0] != '9'
                        ) //if N_EXPR is a var and not a const
                        {
                            try
                            {
                                expr = symbolTable.getSymbolData($3.lexeme);
                                if(expr.m_type == "PROCEDURE")
                                {
                                    yyerror("Procedure/variable mismatch");
                                }
                                if(expr.m_type != "ARRAY")
                                {
                                    if(expr.m_type != INTEGER)
                                    {
                                        yyerror("Index expression must be of type integer");
                                    }
                                }
                                else
                                {
                                    if(expr.m_baseType != INTEGER)
                                    {
                                        yyerror("Index expression must be of type integer");
                                    }
                                }
                                
                            }
                            catch(...){ }
                        }


                        try
                        {
                            //std::cout << $1.lexeme << std::endl;
                            array = symbolTable.getSymbolData($1.lexeme);
                            //std::cout << array.m_type << "   " << array.m_baseType << std::endl;
                            copyArray($$.type,array.m_type.c_str());
                            copyArray($$.baseType,array.m_baseType.c_str());
                        }
                        catch(...) { }
                        if(array.m_type == "PROCEDURE")
                        {
                            yyerror("Procedure/variable mismatch");
                        }
                        if(array.m_type != "ARRAY")
                        {
                            yyerror("Indexed variable must be of array type");
                        }


                        //std::cout << "________________________________________________________________________" << $3.type << "___" << std::endl;
                        std::string t = $3.type;
                        //std::string bt = $3.baseType;
                        //std::cout << "_____________________________________" << t << "__" << bt << std::endl;
                        if(t != "ARRAY")
                        {
                            if(t == "CHAR" || t == "BOOLEAN" /*|| (t == "ARRAY" && bt != "INTEGER")*/)
                            {
                                yyerror("Index expression must be of type integer");
                            }
                        }
                        
                    }
                ;
N_INPUTLST      : /* epsilon */
                    {
                    prRule("N_INPUTLST", "epsilon");
                    }
                | T_COMMA N_INPUTVAR N_INPUTLST
                    {
                    prRule("N_INPUTLST", "T_COMMA N_INPUTVAR N_INPUTLST");
                    }
                ;
N_INPUTVAR      : N_VARIABLE
                    {
                    prRule("N_INPUTVAR", "N_VARIABLE");
                    }
                ;
N_INTCONST      : N_SIGN T_INTCONST
                    {
                        copyArray($$.type , NOT_APPLICABLE);
                        copyArray($$.startSign,$1.startSign);
                        copyArray($$.startIndex , $2);
                        copyArray($$.startSign,$1.endSign);
                        copyArray($$.endIndex , $2);
                        copyArray($$.baseType , NOT_APPLICABLE);
                        copyArray($$.lexeme,$2);
                        prRule("N_INTCONST", "N_SIGN T_INTCONST");
                    }
                ;
N_MULTOPLST     : /* epsilon */
                    {
                        prRule("N_MULTOPLST", "epsilon");
                        
                    }
                | N_MULT_OP N_FACTOR N_MULTOPLST
                    {
                        std::string factType = $2.type;
                        factorTypes.push_back(factType);
                        std::string operType = $1.opType;
                        if(factType != "")
                        {
                            if(operType == "ARITHMETIC" && factType != "INTEGER")
                            {
                                yyerror("Expression must be of type integer");
                            }
                            if(operType == "LOGICAL" && factType != "BOOLEAN")
                            {
                                //std::cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@here4" << std::endl;
                                yyerror("Expression must be of type boolean");
                            }


                            if(operType == "ARITHMETIC" && factType == "INTEGER")
                            {
                                copyArray($$.type,INTEGER);
                            }
                            else if(operType == "ARITHMETIC")
                            {
                                copyArray($$.type,ERROR);
                            }
                        } 

                        prRule("N_MULTOPLST", "N_MULTOP N_FACTOR N_MULTOPLST");
                    }
                ;
N_OUTPUT        : N_EXPR
                    {
                        //printf("%s\n",$1.type);
                        //printf("%s\n",$1.baseType);
                        //if($1.type != ARRAY)
                            copyArray($$.type,$1.type);
                        //else
                        //    copyArray($$.type, $1.baseType);
                        prRule("N_OUTPUT", "N_EXPR");
                    }
                ;
N_OUTPUTLST     : /* epsilon */
                    {
                    prRule("N_OUTPUTLST", "epsilon");
                    }
                | T_COMMA N_OUTPUT N_OUTPUTLST
                    {
                    prRule("N_OUTPUTLST", "T_COMMA N_OUTPUT N_OUTPUTLST");
                    }
                ;
N_PROCDEC       : N_PROCHDR N_BLOCK
                    {
                    prRule("N_PROCDEC", "N_PROCHDR N_BLOCK");
                    }
                ;
N_PROCHDR       : T_PROC T_IDENT T_SCOLON
                    {
                        prRule("N_PROCHDR", "T_PROC T_IDENT T_SCOLON");
                        //prAdding($2,$1);
                        symData = SymbolData("PROCEDURE");
                        symbolTable.addEntry($2,symData, lineNum);
                        symbolTable.pushScope();
                    }
                ;
N_PROCDECPART   : /* epsilon */
                    {
                    prRule("N_PROCDECPART", "epsilon");
                    }
                | N_PROCDEC T_SCOLON N_PROCDECPART
                    {
                    prRule("N_PROCDECPART",
                        "N_PROCDEC T_SCOLON N_PROCDECPART");
                    }
                ;
N_PROCIDENT     : T_IDENT
                    {
                    prRule("N_PROCIDENT", "T_IDENT");
                    }
                ;
N_PROCSTMT      : N_PROCIDENT
                    {
                    prRule("N_PROCSTMT", "N_PROCIDENT");
                    }
                ;
N_PROG          : N_PROGLBL T_IDENT T_SCOLON  { prRule("N_PROG","N_PROGLBL T_IDENT T_SCOLON N_BLOCK T_DOT"); /*prAdding($2,"PROGRAM");*/ symData = SymbolData("PROGRAM"); symbolTable.addEntry($2,symData, lineNum); } N_BLOCK T_DOT
                    {
                        
                        
                    }
                ;
N_PROGLBL       : T_PROG
                    {
                        prRule("N_PROGLBL", "T_PROG");
                        symbolTable.pushScope();
                    }
                ;
N_READ          : T_READ T_LPAREN N_INPUTVAR N_INPUTLST T_RPAREN
                    {
                        std::string inputVarType = $3.type;
                        if(inputVarType != "INTEGER" && inputVarType != "CHAR")
                        {
                            yyerror("Input variable must be of type integer or char");
                        }

                        prRule("N_READ", "T_READ T_LPAREN N_INPUTVAR N_INPUTLST T_RPAREN");
                    }
                ;
N_RELOP         : T_LT
                    {
                    prRule("N_RELOP", "T_LT");
                    }
                | T_GT
                    {
                    prRule("N_RELOP", "T_GT");
                    }
                | T_LE
                    {
                    prRule("N_RELOP", "T_LE");
                    }
                | T_GE
                    {
                    prRule("N_RELOP", "T_GE");
                    }
                | T_EQ
                    {
                    prRule("N_RELOP", "T_EQ");
                    }
                | T_NE
                    {
                    prRule("N_RELOP", "T_NE");
                    }
                ;
N_SIGN          : /* epsilon */
                    {
                        prRule("N_SIGN", "epsilon");
                        copyArray($$.startSign,NOT_APPLICABLE);
                        copyArray($$.endSign,NOT_APPLICABLE);
                        copyArray($$.lexeme,NOT_APPLICABLE);
                    }
                | T_PLUS
                    {
                        prRule("N_SIGN", "T_PLUS");
                        copyArray($$.startSign,$1);
                        copyArray($$.endSign,$1);
                        copyArray($$.lexeme,$1);
                    }
                | T_MINUS
                    {
                        prRule("N_SIGN", "T_MINUS");
                        copyArray($$.startSign,$1);
                        copyArray($$.endSign,$1);
                        copyArray($$.lexeme,$1);
                    }
                ;
N_SIMPLE        : T_INT
                    {
                        copyArray($$.type , INTEGER);
                        copyArray($$.startIndex , NOT_APPLICABLE);
                        copyArray($$.endIndex , NOT_APPLICABLE);
                        copyArray($$.baseType , NOT_APPLICABLE);
                        prRule("N_SIMPLE", "T_INT");
                    }
                | T_CHAR
                    {
                        copyArray($$.type , CHAR);
                        copyArray($$.startIndex , NOT_APPLICABLE);
                        copyArray($$.endIndex , NOT_APPLICABLE);
                        copyArray($$.baseType , NOT_APPLICABLE);
                        prRule("N_SIMPLE", "T_CHAR");
                    }
                | T_BOOL
                    {
                        copyArray($$.type , BOOLEAN);
                        copyArray($$.startIndex , NOT_APPLICABLE);
                        copyArray($$.endIndex , NOT_APPLICABLE);
                        copyArray($$.baseType , NOT_APPLICABLE);
                        prRule("N_SIMPLE", "T_BOOL");
                    }
                ;
N_SIMPLEEXPR    : N_TERM N_ADDOPLST
                    {
                        copyArray($$.lexeme,$1.lexeme);
                        copyArray($$.type,$1.type);
                        copyArray($$.baseType,$1.baseType);
                        copyArray($$.varType,$1.varType);
                        prRule("N_SIMPLEEXPR", "N_TERM N_ADDOPLST");
                    }
                ;
N_STMT          : N_ASSIGN
                    {
                    prRule("N_STMT", "N_ASSIGN");
                    }
                | N_PROCSTMT
                    {
                    prRule("N_STMT", "N_PROCSTMT");
                    }
                | N_READ
                    {
                    prRule("N_STMT", "N_READ");
                    }
                | N_WRITE
                    {
                    prRule("N_STMT", "N_WRITE");
                    }
                | N_CONDITION
                    {
                    prRule("N_STMT", "N_CONDITION");
                    }
                | N_WHILE
                    {
                    prRule("N_STMT", "N_WHILE");
                    }
                | N_COMPOUND
                    {
                    prRule("N_STMT", "N_COMPOUND");
                    }
                ;
N_STMTLST       : /* epsilon */
                    {
                    prRule("N_STMTLST", "epsilon");
                    }
                | T_SCOLON N_STMT N_STMTLST
                    {
                    prRule("N_STMTLST", "T_SCOLON N_STMT N_STMTLST");
                    }
                ;
N_STMTPART      : N_COMPOUND
                    {
                    prRule("N_STMTPART", "N_COMPOUND");
                    }
                ;
N_TERM          : N_FACTOR N_MULTOPLST
                    {
                        copyArray($$.lexeme,$1.lexeme);
                        copyArray($$.type,$1.type);
                        copyArray($$.baseType,$1.baseType);
                        copyArray($$.varType,$1.varType);
                        
                        std::string opListType = $2.type;
                        if(opListType != "")
                        {
                            if(opListType == "ERROR")
                            {
                                copyArray($$.type,$2.type);
                            }
                        }

                        factorTypes.clear();
                        prRule("N_TERM", "N_FACTOR N_MULTOPLST");
                    }
                ;
N_TYPE          : N_SIMPLE
                    {
                        copyArray($$.type , $1.type);
                        copyArray($$.startIndex , $1.startIndex);
                        copyArray($$.endIndex , $1.endIndex);
                        copyArray($$.baseType , $1.baseType);
                        prRule("N_TYPE", "N_SIMPLE");
                    }
                | N_ARRAY
                    {
                        copyArray($$.type , $1.type);
                        copyArray($$.startSign,$1.startSign);
                        copyArray($$.startIndex , $1.startIndex);
                        copyArray($$.endSign,$1.endSign);
                        copyArray($$.endIndex , $1.endIndex);
                        copyArray($$.baseType , $1.baseType);
                        prRule("N_TYPE", "N_ARRAY");
                    }
                ;
N_VARDEC        : N_IDENT N_IDENTLST T_COLON N_TYPE
                    {
                        prRule("N_VARDEC", "N_IDENT N_IDENTLST T_COLON N_TYPE");
                        //prAdding($1.lexeme,$4.type, $4.startSign, $4.startIndex, $4.endSign, $4.endIndex, $4.baseType);
                        symData = SymbolData($4.type, $4.startSign, $4.startIndex, $4.endSign, $4.endIndex, $4.baseType);
                        symbolTable.addEntry($1.lexeme,symData, lineNum);
                        for(unsigned i = 0; i < identNames.size(); i++)
                        {
                           //prAdding(identNames[i].c_str(),$4.type, $4.startSign, $4.startIndex, $4.endSign ,$4.endIndex, $4.baseType); 
                           symData = SymbolData($4.type, $4.startSign, $4.startIndex, $4.endSign, $4.endIndex, $4.baseType);
                           symbolTable.addEntry(identNames[i],symData, lineNum);
                        }
                        identNames.clear();
                    }
                ;
N_VARDECLST     : /* epsilon */
                    {
                    prRule("N_VARDECLST", "epsilon");
                    }
                | N_VARDEC T_SCOLON N_VARDECLST
                    {
                    prRule("N_VARDECLST", "N_VARDEC T_SCOLON N_VARDECLST");
                    }
                ;
N_VARDECPART    : /* epsilon */
                    {
                    prRule("N_VARDECPART", "epsilon");
                    }
                | T_VAR N_VARDEC T_SCOLON N_VARDECLST
                    {
                    prRule("N_VARDECPART",
                        "T_VAR N_VARDEC T_SCOLON N_VARDECLST");
                    }
                ;
N_VARIABLE      : N_ENTIREVAR
                    {
                        copyArray($$.lexeme,$1.lexeme);
                        copyArray($$.type,$1.type);
                        char blah[20] = "NON_IDXVAR";
                        copyArray($$.varType,blah);
                        prRule("N_VARIABLE", "N_ENTIREVAR");
                    }
                | N_IDXVAR
                    {
                        copyArray($$.type,$1.type);
                        copyArray($$.baseType,$1.baseType);
                        char blah[20] = "IDXVAR";
                        copyArray($$.varType,blah);
                        prRule("N_VARIABLE", "N_IDXVAR");
                    }
                ;
N_VARIDENT      : T_IDENT
                    {
                        
                        prRule("N_VARIDENT", "T_IDENT");
                        copyArray($$.lexeme,$1);
                        try
                        {
                            std::string type = symbolTable.getSymbolData($1).m_type;
                            //std::string baseType = symbolTable.getSymbolData($1).m_baseType;
                            //std::cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" << temp << std::endl;
                            copyArray($$.type,type.c_str());
                            // if(type == "ARRAY")
                            // {
                            //     copyArray($$.baseType,baseType.c_str());
                            // }

                        } catch(...){}

                        if(symbolTable.findSymbolInAnyScope($1) == -1)
                        {
                            yyerror("Undefined identifier");
                        }
                    }
                ;
N_WHILE         : T_WHILE N_EXPR
                    {
                        if($2.type != "") //just in case type is empty
                        {
                            //std::cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@" << $2.type << std::endl;
                            std::string temp = $2.type;
                            if(temp != "BOOLEAN") //if expr is not a bool
                            {
                                //std::cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@here5" << std::endl;
                                yyerror("Expression must be of type boolean");
                            }
                        }
                        prRule("N_WHILE", "T_WHILE N_EXPR T_DO N_STMT");
                    }
                    T_DO N_STMT
                ;
N_WRITE         : T_WRITE T_LPAREN N_OUTPUT N_OUTPUTLST T_RPAREN
                    {
                        std::string outType = $3.type;
                        if(outType == "ARRAY")
                            outType = $3.baseType;
                        if(outType != "INTEGER" && outType != "CHAR")
                        {
                            yyerror("Output expression must be of type integer or char");
                        }

                        prRule("N_WRITE", "T_WRITE T_LPAREN N_OUTPUT N_OUTPUTLST T_RPAREN");
                    }
                ;
%%


#include "lex.yy.c"
extern FILE *yyin;


void copyArray(char copyTo[], const char copyFrom[])
{
    for(int i = 0; i < 20; i++)
    {
        copyTo[i] = copyFrom[i];
    }

    return;
}

void prRule(const char *lhs, const char *rhs) 
{
  if (OUTPUT_PRODUCTIONS)
    printf("%s -> %s\n", lhs, rhs);
  return;
}


void prAdding(const char *name, const char *type)
{
    printf("___Adding %s to symbol table with type %s\n", name, type);
    return;
}


void prAdding(const char *name, const char *type, const char *startSign, const char *startIndex, const char* endSign, const char* endIndex, const char *baseType)
{
    if(startIndex[0] != '\0')
        printf("___Adding %s to symbol table with type %s %s%s .. %s%s OF %s\n", name, type, startSign, startIndex, endSign, endIndex, baseType);
    else
        printf("___Adding %s to symbol table with type %s\n", name, type);
    return;
}


int yyerror(const char *s) 
{
  printf("Line %d: %s\n", lineNum, s);
  exit(1);
}

int ckInt() 
{
  char *ptr;
  int	rc = 0;
  ptr = yytext;

  /* ignore sign and leading zeroes */
  if (*ptr == '-' || *ptr == '+')
    ++ptr;
  while (*ptr == '0')
    ++ptr;

  switch (*ptr) {
  case '1':	/* ALL are valid */
			break;

  case '2':	/* it depends */
			if (strcmp(MAX_INT, ptr) < 0)
				rc = 1;
			break;

  default:	     /* ALL are invalid */
			rc = 1;
			break;
		}
  return rc;
}

void ignoreComment() 
{
  char c, pc = 0;

  /* read and ignore the input until you get an ending token */
  while (((c = yyinput()) != ')' || pc != '*') && c != 0) {
    pc = c;
    if (c == '\n') lineNum++;
  }

  return;
}

void printTokenInfo(const char* tokenType, const char* lexeme) 
{
  if (OUTPUT_TOKENS)
    printf("TOKEN: %-15s  LEXEME: %s\n", tokenType, lexeme);
}

int main()
{
  // loop as long as there is anything to parse
  do {
    yyparse();
  } while (!feof(yyin));

  return 0;
}



