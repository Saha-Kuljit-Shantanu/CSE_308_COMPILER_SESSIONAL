%option noyywrap

%x CHAR_LIT

%x STR_LIT

%x SINGLE_LINE_COMMENT

%x MULTI_LINE_COMMENT

%{

#include<iostream>

#include "1905119_SymbolTable.cpp"

using namespace std;

int line_count=1;
int err_count = 0;
int ln;

string sample_char;

string sample_string;
string log_print;
string comment_line;

FILE *logout;
FILE *tokenout;

SymbolTable sym(10);

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
		fprintf(tokenout,"<IF, if>\n");
		fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);
	}
		
"else"	{
		fprintf(tokenout,"<ELSE, else>\n");
		fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
	}
	
"for"	{
		fprintf(tokenout,"<FOR, for>\n");
		fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext);
	}
		
"while"	{
		fprintf(tokenout,"<WHILE, while>\n");
		fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
	}
	
"switch"	{
		fprintf(tokenout,"<SWITCH, switch>\n");
		fprintf(logout,"Line# %d: Token <SWITCH> Lexeme %s found\n",line_count,yytext);
	}
		
"case"	{
		fprintf(tokenout,"<CASE, case>\n");
		fprintf(logout,"Line# %d: Token <CASE> Lexeme %s found\n",line_count,yytext);
	}
	
"do"	{
		fprintf(tokenout,"<DO, do>\n");
		fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",line_count,yytext);
	}
		
"break"	{
		fprintf(tokenout,"<BREAK, break>\n");
		fprintf(logout,"Line# %d: Token <BREAK> Lexeme %s found\n",line_count,yytext);
	}
	
"int"	{
		fprintf(tokenout,"<INT, int>\n");
		fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
	}
		
"float"	{
		fprintf(tokenout,"<FLOAT, float>\n");
		fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
	}
	
"char"	{
		fprintf(tokenout,"<CHAR, char>\n");
		fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",line_count,yytext);
	}
		
"double"	{
		fprintf(tokenout,"<DOUBLE, double>\n");
		fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",line_count,yytext);
	}
	
"void"	{
		fprintf(tokenout,"<VOID, void>\n");
		fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
	}
		
"return"	{
		fprintf(tokenout,"<RETURN, return>\n");
		fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
	}
	
"default"	{
		fprintf(tokenout,"<DEFAULT, default>\n");
		fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme %s found\n",line_count,yytext);
	}
		
"continue"	{
		fprintf(tokenout,"<CONTINUE, continue>\n");
		fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme %s found\n",line_count,yytext);
	}
	
{IDNT}	{
		fprintf(tokenout,"<ID, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
		if( sym.INSERT(yytext,"ID",logout) == true)	sym.PRINT_A(logout);
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

	fprintf(tokenout,"<CONST_INT, %s>\n",yytext);
	fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);

	}
	
{FLOAT_LIT} {

	fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
	fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);

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
			
			fprintf(tokenout,"<CONST_CHAR, %s>\n",sample_char.c_str());
			fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,sample_char.c_str());
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

		

"++"	|

"--"	{
		fprintf(tokenout,"<INCOP, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
			
	}


"+"	|

"-"	{
		fprintf(tokenout,"<ADDOP, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
			
	}
	

	
"&&"	|

"||"	{
		fprintf(tokenout,"<LOGICOP, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
			
	}
		
"*"	|

"/"	|

"%"	{
		fprintf(tokenout,"<MULOP, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
	}
	
"<<"	|

">>"	|

"^"	|

"&"	|

"|"	{
		fprintf(tokenout,"<BITOP, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
	}

	
"<="	|

"<"	|

">="	|

">"	|

"=="	|

"!="	{
		fprintf(tokenout,"<RELOP, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
	}
	
"="	{
		fprintf(tokenout,"<ASSIGNOP, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			
	}
	
"!"	{
		fprintf(tokenout,"<NOT, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
			
	}
	
"("	{
		fprintf(tokenout,"<LPAREN, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
			
	}
				
")"	{
		fprintf(tokenout,"<RPAREN, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
			
	}
	
"{"	{
		fprintf(tokenout,"<LCURL, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
		sym.EnterScope();
			
	}
	
"}"	{
		fprintf(tokenout,"<RCURL, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
		sym.ExitScope();
		
			
	}
	
"["	{
		fprintf(tokenout,"<LSQUARE, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
			
	}
	
"]"	{
		fprintf(tokenout,"<RSQUARE, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
			
	}
	
","	{
		fprintf(tokenout,"<COMMA, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
			
	}
	
";"	{
		fprintf(tokenout,"<SEMICOLON, %s>\n",yytext);
		fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			
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
		
			fprintf(tokenout,"<SINGLE LINE STRING, %s>\n",sample_string.c_str());
			fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme \"%s\" found\n",ln,log_print.c_str());
		
		}
		
		if(ln < line_count) {
		
			fprintf(tokenout,"<MULTI LINE STRING, %s>\n",sample_string.c_str());
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



int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	
	sym.PRINT_A(logout);
	
	fprintf(logout ,"Total lines: %d\n",line_count-1);
	fprintf(logout ,"Total errors: %d\n", err_count);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}



