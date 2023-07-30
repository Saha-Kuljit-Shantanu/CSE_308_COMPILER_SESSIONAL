%option noyywrap

%x CHAR_LIT

%x STR_LIT

%x SINGLE_LINE_COMMENT

%x MULTI_LINE_COMMENT

%{

#include<iostream>

#include "1905119_SymbolTable.cpp"

//#define YYSTYPE


#include "y.tab.h"



using namespace std;

int line_count=1;
int err_count = 0;
int ln;

string sample_char;

string sample_string;
string log_print;
string comment_line;

FILE *logout = fopen("log.txt","w");
//FILE *tokenout;

//SymbolTable sym(10);

extern YYSTYPE yylval;
extern SymbolTable table;
void yyerror(char *);


%}

WS [ \t\f\r\v] 
ALPHABET [a-zA-Z]
DG [0-9]
ENDL \n
INT_LIT {DG}+ 
FLOAT_LIT {DG}*(\.{DG}+)?(E[+-]?{DG}+)?
IDNT ({ALPHABET}|_)({DG}*({ALPHABET}|_)*)*
NOTIDNT {DG}+(({ALPHABET}|_)+{DG}*)+
UNRECOG_CHAR [^A-Za-z0-9_$\t\f\r\v\n ]
NOTFLOAT_LIT {DG}*(\.{DG}+)(\.{DG}+)+
ILLFORM {DG}*((\.{DG}+)?E[+-]?{DG}+)(\.{DG}+)+


%%

{ENDL} {line_count++;}

{WS} 	{}



"if"	{
		fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s= new SymbolInfo(yytext, "IF");
		
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("IF");
		yylval -> setIsLeaf(true);
		yylval -> setRule("IF : if");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return IF;
	}
		
"else"	{
		fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
		
		SymbolInfo *s= new SymbolInfo(yytext, "ELSE");
		
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("ELSE");
		yylval -> setIsLeaf(true);
		yylval -> setRule("ELSE : else");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return ELSE;
	}
	
"for"	{
		fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "FOR");
		
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("FOR");
		yylval -> setIsLeaf(true);
		yylval -> setRule("FOR : for");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return FOR;
	}
		
"while"	{
		fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "WHILE");
		
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("WHILE");
		yylval -> setIsLeaf(true);
		yylval -> setRule("WHILE : while");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return WHILE;
	}
	
"switch"	{
		fprintf(logout,"Line# %d: Token <SWITCH> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "SWITCH");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("SWITCH : switch");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return SWITCH;
	}
		
"case"	{
		fprintf(logout,"Line# %d: Token <CASE> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "CASE");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("CASE : case");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return CASE;
	}
	
"do"	{
		fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "DO");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("DO : do");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return DO;
	}
		
"break"	{
		fprintf(logout,"Line# %d: Token <BREAK> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "BREAK");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("BREAK : break");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return BREAK;
	}
	
"int"	{
		fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s= new SymbolInfo(yytext, "INT");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("INT : int");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return INT;
	}
		
"float"	{
		fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "FLOAT");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("FLOAT : float");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return FLOAT;
	}
	
"char"	{
		fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "CHAR");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("CHAR : char");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return CHAR;
	}
		
"double"	{
		fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "DOUBLE");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("DOUBLE : double");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return DOUBLE;
	}
	
"void"	{
		fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "VOID");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("VOID : void");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return VOID;
	}
		
"return"	{
		fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "RETURN");
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("RETURN");
		yylval -> setIsLeaf(true);
		yylval -> setRule("RETURN : return");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return RETURN;
	}
	
"default"	{
		fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme %s found\n",line_count,yytext);	
		SymbolInfo *s = new SymbolInfo(yytext, "DEFAULT");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("DEFAULT : default");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return DEFAULT;
	}
		
"continue"	{
		fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "CONTINUE");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("CONTINUE : continue");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return CONTINUE;
	}
	
"println" {
		fprintf(logout,"Line# %d: Token <PRINTLN> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "PRINTLN");
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("PRINTLN");
		yylval -> setIsLeaf(true);
		yylval -> setRule("PRINTLN : printf");
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return PRINTLN;


}
	
{IDNT}	{
		
		SymbolInfo *s = new SymbolInfo(yytext, "ID");
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("ID");
		yylval -> setIsLeaf(true);
		yylval -> setRule("ID : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
		return ID;
	}
	
{NOTFLOAT_LIT} {
	
		err_count++;
		fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",line_count,yytext);

	}
	
{ILLFORM} {

		err_count++;
		fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",line_count,yytext);

	
	}
	

	
 
{INT_LIT} {

		fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "CONST_INT");
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("INT_LIT");
		yylval -> setIsLeaf(true);
		yylval -> setRule("CONST_INT : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return CONST_INT;

	}
	
{FLOAT_LIT} {

	
		fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "CONST_FLOAT");
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("FLOAT_LIT");
		yylval -> setIsLeaf(true);
		yylval -> setRule("CONST_FLOAT : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return CONST_FLOAT;

	}
	
{NOTIDNT}	{

		err_count++;
		fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",line_count,yytext);
	}
	
\'	{

	sample_char = "";
	log_print = "";
	BEGIN CHAR_LIT;
	
	}
	
	




<CHAR_LIT>\\a   sample_char += "\a" ; 
<CHAR_LIT>\\b  sample_char += "\b"  ; 
<CHAR_LIT>\\v  sample_char += "\v"  ; 
<CHAR_LIT>\\0  sample_char += "\0"  ;
<CHAR_LIT>\\r  sample_char += "\r"  ; 
<CHAR_LIT>\\f  sample_char += "\f"  ; 
<CHAR_LIT>\\t  sample_char += "\t"  ;
<CHAR_LIT>\\n  sample_char += "\n"  ; 
<CHAR_LIT>\\\"  sample_char += "\"" ; 
<CHAR_LIT>\\\\ sample_char += "\\"  ; 
<CHAR_LIT>\\\'  sample_char += "\'" ;



<CHAR_LIT><<EOF>> {

		
		
		err_count++;
		
		fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR '%s\n",line_count,sample_char.c_str());
		
		BEGIN INITIAL;

	}

	
<CHAR_LIT>\' {

		
		
		
		
		if(sample_char.size() > 1)
		
		{
			err_count ++;
			fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR '%s'\n",line_count,sample_char.c_str());
		}
			
		else if( sample_char.size() == 0){
		
			err_count ++;
			fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR '%s'\n",line_count,sample_char.c_str());
			
		}
		
		else {
			
			fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,sample_char.c_str());
			SymbolInfo *s = new  SymbolInfo(yytext, "CONST_CHAR");
			yylval = (YYSTYPE)s;
			return CONST_CHAR;
		}
		BEGIN INITIAL;
	}
	
<CHAR_LIT>[\r]?[\n] {

		err_count++;
		fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR '%s\n",line_count,sample_char.c_str());
		
		line_count++;
		BEGIN INITIAL;


	}
	
<CHAR_LIT>. sample_char += yytext[0];

\"	{
		
		sample_string = "";
		log_print = "";
		ln = line_count;
		BEGIN STR_LIT;

	}	
	
\/\/	{

		comment_line = "";
		ln = line_count;
		BEGIN SINGLE_LINE_COMMENT;
	}
	
\/\*	{
		
		comment_line = "";
		ln = line_count;
		BEGIN MULTI_LINE_COMMENT;

	}

		

"++"	{

		fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "INCOP");
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("INC");
		yylval -> setIsLeaf(true);
		yylval -> setRule("INCOP : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return INCOP;

	}

"--"	{
		fprintf(logout,"Line# %d: Token <DECOP> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "DECOP");
		yylval = (YYSTYPE)s;
		yylval -> setSymbolName("DEC");
		yylval -> setIsLeaf(true);
		yylval -> setRule("DECOP : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return DECOP;
			
	}


"+"	|

"-"	{
		
		fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "ADDOP");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("ADDOP : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return ADDOP;
			
	}
	

	
"&&"	|

"||"	{
		
		fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "LOGICOP");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("LOGICOP : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return LOGICOP;
			
	}
		
"*"	|

"/"	|

"%"	{
		
		fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "MULOP");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("MULOP : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return MULOP;
	}
	
"<<"	|

">>"	|

"^"	|

"&"	|

"|"	{
	
		fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "BITOP");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("BITOP : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return BITOP;
	}

	
"<="	|

"<"	|

">="	|

">"	|

"=="	|

"!="	{
		
		fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "RELOP");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("RELOP : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return RELOP;
	}
	
"="	{
		
		fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "ASSIGNOP");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("ASSIGNOP : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return ASSIGNOP;
			
	}
	
"!"	{
		
		fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new  SymbolInfo(yytext, "NOT");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("NOT : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return NOT;
			
	}
	
"("	{
		
		fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "LPAREN");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("LPAREN : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return LPAREN;
			
	}
				
")"	{
		
		fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s= new SymbolInfo(yytext, "RPAREN");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("RPAREN : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return RPAREN;
			
	}
	
"{"	{
		
		fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
		//table.EnterScope();
		SymbolInfo *s = new SymbolInfo(yytext, "LCURL");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("LCURL : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return LCURL;
			
	}
	
"}"	{
		
		fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
		//table.ExitScope();
		SymbolInfo *s = new SymbolInfo(yytext, "RCURL");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("RCURL : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return RCURL;
			
	}
	
"["	{
		
		fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "LTHIRD");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("LSQUARE : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return LTHIRD;
			
	}
	
"]"	{
		
		fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "RTHIRD");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("RSQUARE : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return RTHIRD;
			
	}
	
","	{
		
		fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "COMMA");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("COMMA : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return COMMA;
			
	}
	
";"	{
		
		fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
		SymbolInfo *s = new SymbolInfo(yytext, "SEMICOLON");
		yylval = (YYSTYPE)s;
		yylval -> setIsLeaf(true);
		yylval -> setRule("SEMICOLON : " + s -> getName());
		yylval -> setStartLine(line_count);
		yylval -> setEndLine(line_count);
		return SEMICOLON;
			
	}
	
	
	
	
	
<STR_LIT>\\a   sample_string += "\a", log_print += "\\a";
<STR_LIT>\\b  sample_string += "\b" , log_print += "\\b"; 
<STR_LIT>\\v  sample_string += "\v" , log_print += "\\v"; 
<STR_LIT>\\0  sample_string += "\0" , log_print += "\\0";
<STR_LIT>\\r  sample_string += "\r" , log_print += "\\r"; 
<STR_LIT>\\f  sample_string += "\f" , log_print += "\\f"; 
<STR_LIT>\\t  sample_string += "\t" , log_print += "\\t";
<STR_LIT>\\n  sample_string += "\n" , log_print += "\\n"; 
<STR_LIT>\\\"  sample_string += "\"", log_print += "\\\""; 
<STR_LIT>\\\\ sample_string += "\\" , log_print += "\\\\"; 
<STR_LIT>\\\'  sample_string += "\'", log_print += "\\\'";



<STR_LIT><<EOF>> {

		
		
		err_count++;
		
		fprintf(logout,"Error at line# %d: UNFINISHED_STRING \"%s\n",ln,sample_string.c_str());
		
		BEGIN INITIAL;

	}

	
<STR_LIT>\" {	
		
			
		if(ln == line_count) {
		
			//fprintf(tokenout,"<SINGLE LINE STRING, %s>\n",sample_string.c_str());
			fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme \"%s\" found\n",ln,log_print.c_str());
		
		}
		
		if(ln < line_count) {
		
			//fprintf(tokenout,"<MULTI LINE STRING, %s>\n",sample_string.c_str());
			fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme \"%s\" found\n",ln,log_print.c_str());
		
		}
		BEGIN INITIAL;
	}
	
<STR_LIT>\\[\r]?[\n] {
		
		line_count++;
		log_print += yytext;
		sample_string += "";

	}
	
<STR_LIT>[\r]?[\n] {

		err_count++;
		fprintf(logout,"Error at line# %d: UNFINISHED_STRING \"%s\n",ln,sample_string.c_str());
		
		line_count++;
		BEGIN INITIAL;


	}
	
<STR_LIT>. sample_string += yytext[0],log_print += yytext[0];

		

<SINGLE_LINE_COMMENT><<EOF>> {

		
		if(ln == line_count) {
		
			
			fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme //%s found\n",ln,comment_line.c_str());
		
		}
		
		if(ln < line_count) {
		
			
			fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme //%s found\n",ln,comment_line.c_str());
		
		}
		
		
		
		BEGIN INITIAL;

	}
	



		
<SINGLE_LINE_COMMENT>\\[\r]?[\n] {
		
		line_count++;
		comment_line += yytext;


	}
	
<SINGLE_LINE_COMMENT>[\r]?[\n] {

		if(ln == line_count) {
		
			
			fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme //%s found\n",ln,comment_line.c_str());
		
		}
		
		if(ln < line_count) {
		
			
			fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme //%s found\n",ln,comment_line.c_str());
		
		}
		
		line_count++;
		BEGIN INITIAL;


	}
	

<SINGLE_LINE_COMMENT>. comment_line += yytext[0];

<MULTI_LINE_COMMENT><<EOF>> {

		
		
		
		err_count++;
		
		fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT /*%s\n",ln,comment_line.c_str());
		
		BEGIN INITIAL;

	}
	



	
<MULTI_LINE_COMMENT>[\r]?[\n] {

		line_count++;
		comment_line += yytext;


	}
	
<MULTI_LINE_COMMENT>\*\/ {	
		
			
		
		fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme /*%s*/ found\n",ln,comment_line.c_str());

		BEGIN INITIAL;
	}
	

<MULTI_LINE_COMMENT>. comment_line += yytext[0];

{UNRECOG_CHAR} {

		err_count++;
		fprintf(logout,"Error at line# %d: UNRECOGNIZED_CHAR %s found\n",line_count,yytext);

	}	
	
%%







