/* -------- */
/* Prologue */
/* -------- */
%{

/* Includes */
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "command/commands.h"
#include "parser/parser.h"
#include "parser/tree.h"

/* Prototypes */
int CommandParser_lex(void);
void CommandParser_error(char *s);

/* Local Variables */
Dnchar tokenName;
List<Dnchar> stepNameStack;
VTypes::DataType declaredType;

%}

// Redeclare function names
%name-prefix="CommandParser_"

/* Type Definition */
%union {
	int functionId;			/* Function enum id */
	Dnchar *name;			/* character pointer for names */
	TreeNode *node;			/* node pointer */
	Variable *variable;		/* variable pointer */
	Tree *functree;			/* user-defined function (tree) pointer */
	VTypes::DataType vtype;		/* variable type for next declarations */
	int intconst;			/* integer constant value */
	double doubleconst;		/* double constant value */
};

%token <intconst> INTCONST
%token <doubleconst> DOUBLECONST
%token <name> NEWTOKEN STEPTOKEN
%token <variable> VAR LOCALVAR
%token <functionId> FUNCCALL
%token <functree> USERFUNCCALL
%token <vtype> VTYPE
%token DO WHILE FOR IF RETURN DUMMY OPTION
%nonassoc ELSE

%left AND OR
%left '=' PEQ MEQ TEQ DEQ 
%left GEQ LEQ EQ NEQ '>' '<'
%left '+' '-'
%left '*' '/' '%'
%right UMINUS
%left PLUSPLUS MINUSMINUS
%right '!'
%right '^'

%type <node> constant expr rawexpr func var rawvar arg args
%type <node> fstatement decexpr statement block blockment statementlist exprlist ARRAYCONST
%type <node> namelist namelistitem newname
%type <name> newvar
%type <node> pushscope declaration userfunc userfuncdef

%%

program:
	/* empty */					{ }
	| statementlist					{ if (($1 != NULL) && (!cmdparser.addStatement($1))) YYABORT; }
	;

/* Compound Statement */

block:
	'{' pushscope statementlist '}' popscope	{ $$ = cmdparser.joinCommands($2,$3); }
	| '{' '}'					{ $$ = cmdparser.addFunction(Command::NoFunction); }
        ;

pushscope:
	/* empty */					{ $$ = cmdparser.pushScope(); if ($$ == NULL) YYABORT; }
	;

popscope:
	/* empty */					{ if (!cmdparser.popScope()) YYABORT; }
	;

statementlist:
	blockment					{ $$ = $1; }
	| statementlist blockment 			{ if (($1 != NULL) && ($2 != NULL)) $$ = cmdparser.joinCommands($1, $2); }
	;

blockment:
	statement ';'					{ $$ = $1; }
	| block						{ $$ = $1; }
	| fstatement					{ $$ = $1; if ($$ == NULL) YYABORT; }
	| userfuncdef					{ $$ = NULL; }
	;

/* Single Statement / Flow Control */

statement:
	decexpr						{ $$ = $1; }
	| RETURN expr					{ $$ = cmdparser.addFunction(Command::Return,$2); }
	| RETURN 					{ $$ = cmdparser.addFunction(Command::Return); }
	| statement decexpr				{ printf("Error: Expected ';' before current expression.\n"); YYABORT; }
	;

decexpr:
	declaration					{ $$ = $1; }
	| expr						{ $$ = $1; }
	;

fstatement:
	IF '(' expr ')' blockment ELSE blockment	{ $$ = cmdparser.addFunction(Command::If,$3,$5,$7); }
	| IF '(' expr ')' blockment			{ $$ = cmdparser.addFunction(Command::If,$3,$5); }
	| FOR pushscope '(' decexpr ';' expr ';' expr ')' blockment { $$ = cmdparser.joinCommands($2, cmdparser.addFunction(Command::For, $4,$6,$8,$10)); cmdparser.popScope(); }
	| WHILE pushscope '(' expr ')' blockment	{ $$ = cmdparser.joinCommands($2, cmdparser.addFunction(Command::While, $4,$6)); cmdparser.popScope(); }
	| DO pushscope blockment WHILE '(' expr ')' ';'	{ $$ = cmdparser.joinCommands($2, cmdparser.addFunction(Command::DoWhile, $3,$6)); cmdparser.popScope(); }
	;

/* Constants */

constant:
	INTCONST					{ $$ = cmdparser.addConstant($1); }
	| DOUBLECONST					{ $$ = cmdparser.addConstant($1); }
	;


/* User-defined function */

userfuncdef:
	VTYPE savetype NEWTOKEN '(' pushfunc args ')' block { if (!cmdparser.addStatement($8)) YYABORT; cmdparser.popTree(); declaredType = VTypes::NoData; }
	;

args:
	/* empty */					{ }
	| arg						{ }
	| args ',' arg					{ }
	;

arg:
	VTYPE savetype NEWTOKEN savetokenname		{ $$ = cmdparser.addVariableAsArgument(declaredType, &tokenName); }
	| VTYPE savetype NEWTOKEN savetokenname '=' expr { $$ = cmdparser.addVariableAsArgument(declaredType, &tokenName, $6); }
	;

pushfunc:
	/* empty */					{ cmdparser.pushFunction(yylval.name->get(), declaredType); }
	;

/* Variable declaration and name / assignment list */

namelistitem:
	newname						{ $$ = $1; if ($1 == NULL) YYABORT; }
	;

namelist:
	namelistitem					{ $$ = $1; }
	| namelist ',' namelistitem			{ if ($3 == NULL) YYABORT; $$ = Tree::joinArguments($3,$1); }
	| namelist namelistitem				{ printf("Error: Missing comma between declarations?\n"); YYABORT; }
	;

newname:
	newvar '[' expr ']' 				{ $$ = cmdparser.addArrayVariable(declaredType, &tokenName, $3); }
	| newvar '=' expr 				{ $$ = cmdparser.addVariable(declaredType, &tokenName, $3); }
	| newvar '=' ARRAYCONST				{ $$ = cmdparser.addVariable(declaredType, &tokenName, $3); }
	| newvar '[' expr ']' '=' expr			{ $$ = cmdparser.addArrayVariable(declaredType, &tokenName,$3,$6); }
	| newvar '[' expr ']' '=' ARRAYCONST		{ $$ = cmdparser.addArrayVariable(declaredType, &tokenName,$3,$6); }
	| newvar					{ $$ = cmdparser.addVariable(declaredType, $1); }
	;

newvar:
	VAR 						{ tokenName = yylval.variable->name(); $$ = &tokenName; }
	| FUNCCALL					{ tokenName = Command::data[yylval.functionId].keyword; $$ = &tokenName; }
	| LOCALVAR					{ printf("Error: Existing variable in local scope cannot be redeclared.\n"); YYABORT; }
	| constant					{ printf("Error: Constant value found in declaration.\n"); YYABORT; }
	| USERFUNCCALL					{ printf("Error: Existing user-defined function name cannot be redeclared.\n"); YYABORT; }
	| VTYPE						{ printf("Error: Type-name used in variable declaration.\n"); YYABORT; }
	| NEWTOKEN savetokenname			{ if (declaredType == VTypes::NoData) { printf("Token '%s' is undeclared.\n", tokenName.get()); YYABORT; } $$ = $1; }
	;

declaration:
	VTYPE savetype namelist				{ $$ = cmdparser.addDeclarations($3); declaredType = VTypes::NoData; }
	| VTYPE savetype error				{ printf("Illegal use of reserved word '%s'.\n", VTypes::dataType(declaredType)); YYABORT; }
	;

/* Variables / Paths */

step:
	STEPTOKEN pushstepname '[' expr ']' 		{ if (!cmdparser.expandPath(stepNameStack.last(), $4)) YYABORT; stepNameStack.removeLast(); }
	| STEPTOKEN pushstepname '(' exprlist ')' 	{ if (!cmdparser.expandPath(stepNameStack.last(), NULL, $4)) YYABORT; stepNameStack.removeLast(); }
	| STEPTOKEN pushstepname '(' ')' 		{ if (!cmdparser.expandPath(stepNameStack.last(), NULL, NULL)) YYABORT; stepNameStack.removeLast(); }
	| STEPTOKEN pushstepname 			{ if (!cmdparser.expandPath($1)) YYABORT; stepNameStack.removeLast(); }
	;

steplist:
	step 						{ }
	| steplist '.' step				{ }
	| steplist error				{ printf("Error formulating path.\n"); YYABORT; }
	;

var:
	rawvar						{ $$ = $1; if ($$ == NULL) YYABORT; }
	;

rawvar:
	VAR '[' expr ']'				{ $$ = cmdparser.wrapVariable($1,$3); }
	| VAR						{ $$ = cmdparser.wrapVariable($1); }
	| LOCALVAR '[' expr ']'				{ $$ = cmdparser.wrapVariable($1,$3); }
	| LOCALVAR					{ $$ = cmdparser.wrapVariable($1); }
	| rawvar '.' 					{ cmdparser.createPath($1); }
		steplist				{ $$ = cmdparser.finalisePath(); }
	| rawvar '('					{ printf("Can't use a variable as a function. Did you mean '[' instead?\n"); $$ = NULL; }
	;

/* Expressions */

exprlist:
	expr						{ $$ = $1; if ($$ == NULL) YYABORT; }
	| exprlist ',' expr				{ $$ = Tree::joinArguments($3,$1); }
	| exprlist expr					{ printf("Error: Missing comma between items.\n"); YYABORT; }
	;

expr:
	rawexpr						{ $$ = $1; if ($$ == NULL) YYABORT; }
	;

rawexpr:
	constant					{ $$ = $1; }
	| func						{ $$ = $1; }
	| userfunc					{ $$ = $1; }
	| var '=' expr					{ $$ = cmdparser.addOperator(Command::OperatorAssignment,$1,$3); }
	| var '=' ARRAYCONST				{ $$ = cmdparser.addOperator(Command::OperatorAssignment,$1,$3); }
	| var '=' error					{ printf("Mangled expression used in assignment.\n"); YYABORT; }
	| var PEQ expr					{ $$ = cmdparser.addOperator(Command::OperatorAssignmentPlus,$1,$3); }
	| var MEQ expr					{ $$ = cmdparser.addOperator(Command::OperatorAssignmentSubtract,$1,$3); }
	| var TEQ expr					{ $$ = cmdparser.addOperator(Command::OperatorAssignmentMultiply,$1,$3); }
	| var DEQ expr					{ $$ = cmdparser.addOperator(Command::OperatorAssignmentDivide,$1,$3); }
	| '-' expr %prec UMINUS				{ $$ = cmdparser.addOperator(Command::OperatorNegate, $2); }
	| var PLUSPLUS					{ $$ = cmdparser.addOperator(Command::OperatorPostfixIncrease, $1);  }
	| var MINUSMINUS				{ $$ = cmdparser.addOperator(Command::OperatorPostfixDecrease, $1); }
	| PLUSPLUS var					{ $$ = cmdparser.addOperator(Command::OperatorPrefixIncrease, $2); }
	| MINUSMINUS var				{ $$ = cmdparser.addOperator(Command::OperatorPrefixDecrease, $2); }
	| var						{ $$ = $1; }
	| expr '+' expr					{ $$ = cmdparser.addOperator(Command::OperatorAdd, $1, $3); }
	| expr '-' expr					{ $$ = cmdparser.addOperator(Command::OperatorSubtract, $1, $3); }
	| expr '*' expr					{ $$ = cmdparser.addOperator(Command::OperatorMultiply, $1, $3); }
	| expr '/' expr					{ $$ = cmdparser.addOperator(Command::OperatorDivide, $1, $3); }
	| expr '^' expr					{ $$ = cmdparser.addOperator(Command::OperatorPower, $1, $3); }
	| expr '%' expr					{ $$ = cmdparser.addOperator(Command::OperatorModulus, $1, $3); }
	| expr EQ expr					{ $$ = cmdparser.addOperator(Command::OperatorEqualTo, $1, $3); }
	| expr NEQ expr					{ $$ = cmdparser.addOperator(Command::OperatorNotEqualTo, $1, $3); }
	| expr '>' expr					{ $$ = cmdparser.addOperator(Command::OperatorGreaterThan, $1, $3); }
	| expr GEQ expr					{ $$ = cmdparser.addOperator(Command::OperatorGreaterThanEqualTo, $1, $3); }
	| expr '<' expr					{ $$ = cmdparser.addOperator(Command::OperatorLessThan, $1, $3); }
	| expr LEQ expr					{ $$ = cmdparser.addOperator(Command::OperatorLessThanEqualTo, $1, $3); }
	| expr AND expr					{ $$ = cmdparser.addOperator(Command::OperatorAnd, $1, $3); }
	| expr OR expr					{ $$ = cmdparser.addOperator(Command::OperatorOr, $1, $3); }
	| '(' expr ')'					{ $$ = $2; }
	| '!' expr					{ $$ = cmdparser.addOperator(Command::OperatorNot, $2); }
	| NEWTOKEN					{ printf("Error: '%s' has not been declared as a function or a variable.\n", yylval.name->get()); YYABORT; }
	;


/* Array Vector Constant / Assignment Group */
ARRAYCONST:
	'{' exprlist '}'				{ $$ = cmdparser.addArrayConstant($2); }
	;

/* Functions */

func:
	FUNCCALL '(' ')'				{ $$ = cmdparser.addFunction( (Command::Function) $1); }
	| FUNCCALL '(' exprlist ')' 			{ $$ = cmdparser.addFunctionWithArglist( (Command::Function) $1,$3); }
	| FUNCCALL					{ $$ = cmdparser.addFunction( (Command::Function) $1); }
	;

userfunc:
	USERFUNCCALL '(' exprlist ')' 			{ $$ = cmdparser.addUserFunction($1,$3); }
	| USERFUNCCALL '(' ')'				{ $$ = cmdparser.addUserFunction($1); }
	| USERFUNCCALL					{ $$ = cmdparser.addUserFunction($1); }
	;

/* Semantic Value Subroutines */

savetokenname:
	/* empty */					{ tokenName = *yylval.name; }
	;

savetype:
	/* empty */					{ declaredType = yylval.vtype; }
	;

pushstepname:
	/* empty */					{ stepNameStack.add()->set(yylval.name->get()); }
	;

%%

void yyerror(char *s)
{
}
