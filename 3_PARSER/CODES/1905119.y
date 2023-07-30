%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "1905119_SymbolTable.cpp"
#define YYSTYPE SymbolInfo*

using namespace std;

int lc = 0;
int pc = 0;
int ZF = 0;
string currType = "VOID";
string currScope;
FILE* symtab;
FILE *pstout ;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern FILE *logout;

extern int line_count;
extern int err_count;


SymbolTable table(11);

FILE* fp;
FILE* errout;
//FILE* fp2;
//FILE* fp3;



void yyerror(char *s)
{
	//write your code
}

void Print(SymbolInfo* x){

	if( x -> getIsLeaf() == false) fprintf(pstout , "%s\t<LINE %d-%d>\n", x -> getRule().c_str() , x -> getStartLine(), x -> getEndLine() );
	else fprintf(pstout , "%s\t<LINE %d>\n", x -> getRule().c_str() , x -> getStartLine() );
	//cout << x -> getRule() << endl;
}

void ParseTree(SymbolInfo* x, int depth){

	for(int i=0; i<depth;i++){
		
		fprintf(pstout," ");
		
	}
	
	Print(x);
	
	for(int i=0; i< x -> getChildren().size() ; i++){
	
		ParseTree(x-> getChild(i) , depth+1);
	
	}
	
	

};


%}

%token IF ELSE FOR WHILE SWITCH CASE DO BREAK INT FLOAT CHAR DOUBLE VOID RETURN DEFAULT CONTINUE PRINTLN ID CONST_INT CONST_FLOAT CONST_CHAR LOGICOP BITOP RELOP NOT LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON

%type start program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements statement declaration_list expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments embed_func_def

%define api.value.type{SymbolInfo*}

%left ASSIGNOP
%left ADDOP
%left MULOP
%right INCOP DECOP
%left LPAREN 
%right RPAREN

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		//write your code in this block in all the similar blocks below
		
		$$ =  new SymbolInfo("start");
		$$ -> setRule("start : program");
		$$ -> setStartLine( $1 -> getStartLine());
		$$ -> setEndLine($1 -> getEndLine() );
		$$ -> addChild($1);
		
		fprintf(logout,"start : program\n");
		
		ParseTree($$, 0);
	}
	;

program : program unit {

		$$ =  new SymbolInfo("program");
		$$ -> setRule("program : program unit");
		$$ -> setStartLine( $1 -> getStartLine());
		$$ -> setEndLine($2 -> getEndLine() );
		$$ -> addChild($1);
		$$ -> addChild($2);
		fprintf(logout,"program : program unit\n");

	}
	| unit{
	
		$$ =  new SymbolInfo("program");
		$$ -> setRule("program : unit");
		$$ -> setStartLine( $1 -> getStartLine());
		$$ -> setEndLine($1 -> getEndLine() );
		$$ -> addChild($1);
		fprintf(logout,"program : unit\n");
	}
	;
	
unit : var_declaration{

		$$ =  new SymbolInfo("unit");
		$$ -> setRule("unit : var_declaration");
		$$ -> setStartLine( $1 -> getStartLine());
		$$ -> setEndLine($1 -> getEndLine() );
		$$ -> addChild($1);
		fprintf(logout,"unit : var_declaration\n");

     }
     | func_declaration{
     
     		$$ =  new SymbolInfo("unit");
     		//$1 -> getParamList().clear();
		$$ -> setRule("unit : func_declaration");
		$$ -> setStartLine( $1 -> getStartLine());
		$$ -> setEndLine($1 -> getEndLine() );
		$$ -> addChild($1);
     		fprintf(logout,"unit : func_declaration\n");
     
     }
     | func_definition{
     
     		$$ =  new SymbolInfo("unit");
		$$ -> setRule("unit : func_definition");
		$$ -> setStartLine( $1 -> getStartLine());
		$$ -> setEndLine($1 -> getEndLine() );
		$$ -> addChild($1);
     		fprintf(logout,"unit : func_definition\n");
     
     }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON{
			
			//$$ -> getParamList().clear();
			//$4 -> getParamList().clear();
			$$ = new SymbolInfo($4);
			$$ -> setName( $2 -> getName()) ;
			$2 -> setIsFunction(true);
			$$ -> setIsFunction(true);
			$$ -> setTypeSpec($1 -> getType());
			bool t = table. INSERT( $$ -> getName() ,$$ -> getTypeSpec() , symtab, $$ ->  getIsFunction() , $$ ->  getIsArray() );
			
			SymbolInfo *s = table.LOOKUP($$ -> getName());
			
			
			for (int i=0; i< $$ -> getParamList().size() ; i++){
			
				s -> push_paramlist($$ -> getParam(i));
				
			}
			$$ -> setRule("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
			$$ -> setStartLine( $1 -> getStartLine());
			$$ -> setEndLine($6 -> getEndLine() );
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
			$$ -> addChild($5);
			$$ -> addChild($6);
			
			//$$ -> getParamList().clear();
			//s -> getParamList().clear();
			fprintf(logout,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n");
			//SymbolInfo *k = table.LOOKUP($$ -> getName()); cout << k-> getParamList().size() ;
			
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON{
		
			$$ = new SymbolInfo($2);
			$2 -> setIsFunction(true);
			$$ -> setIsFunction(true);
			$$ -> setTypeSpec($1 -> getType());
			
			bool t = table. INSERT( $$ -> getName() ,$$ -> getTypeSpec() , symtab, $$ -> getIsFunction() , $$ -> getIsArray() ) ;
			$$ -> setRule("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
			$$ -> setStartLine( $1 -> getStartLine());
			$$ -> setEndLine($5 -> getEndLine() );
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
			$$ -> addChild($5);
			fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n");
		
		}
		;
		 
func_definition :  embed_func_def compound_statement{
			
			/*if( pc < $$ -> getParamList().size() ){
				
				
			}
			
			else{
			
				
			
			}*/
			
			$$ =  new SymbolInfo($1);
			$$ -> setRule("func_definition :  embed_func_def compound_statement");
			$$ -> setStartLine( $1 -> getStartLine());
			$$ -> setEndLine($2 -> getEndLine() );
			$$ -> addChild($1);
			$$ -> addChild($2);
			
			
			fprintf(logout,"func_definition : embed_func_def compound_statement\n");
			
		}
			
		
 		;				


embed_func_def	: type_specifier ID LPAREN parameter_list RPAREN{

			$$ = new SymbolInfo($4);
			$$ -> setName( $2 -> getName()) ;
			$$ -> setType( "Function" );
			$$ -> setTypeSpec( $1 -> getType() );
			$$ -> setIsFunction(true);
			$$ -> setIsDefinition(true);
			$2 -> setIsFunction(true);
			$2 -> setIsDefinition(true);
			//$$ -> setTypeSpec($1 -> getType());
			bool t = table. INSERT( $$ -> getName() ,$$ -> getTypeSpec() , symtab, $$ -> getIsFunction() , $$ -> getIsArray(), $$ -> getIsDefinition() );
			
			SymbolInfo *s = table.LOOKUP($$ -> getName());
			
		
			
			table . EnterScope();
			
			
			currType = $1 -> getType();
			currScope = $2 -> getName();
			
			if(table.getCNT() > 1){
				
				fprintf(errout,"Line# %d: Function defined within another function\n",line_count );
				
				err_count++;
			}
			
			if(t == false && s -> getIsFunction() == false) {
				
				fprintf(errout,"Line# %d: '%s' redeclared as different kind of symbol \n",line_count,$$ -> getName().c_str() );
				
				err_count ++;
			}
			
			else if(t == false && s->getType() != $$ ->getTypeSpec() ){
				
				fprintf(errout,"Line# %d: Conflicting types for '%s' \n",line_count,$$ -> getName().c_str() );
					
				err_count ++;
				
			}
			
			
			else if(t == false && $$ -> getParamList(). size() < s -> getParamList(). size()) {
			
				//fprintf(errout,"Line# %d: Too few arguments to function '%s'\n",line_count, $$ -> getName().c_str() );
				
				fprintf(errout,"Line# %d: Conflicting types for '%s' \n",line_count,$$ -> getName().c_str() );
					
				err_count ++;
			
			}
			
			else if(t == false && $$ -> getParamList(). size() > s -> getParamList(). size()) {
			
				//fprintf(errout,"Line# %d: Too many arguments to function '%s'\n",line_count, $$ -> getName().c_str() );
				
				fprintf(errout,"Line# %d: Conflicting types for '%s' \n",line_count,$$ -> getName().c_str() );
					
				err_count ++;
			
			}
			
			for (int i=0; i< $$ -> getParamList().size() ; i++){
			
				if(t ==true) s -> push_paramlist($$ -> getParam(i));
				
				else if(t == false && $$ -> getParamList(). size() == s -> getParamList(). size()){
				
					if($$ -> getParam(i) -> getType() != s -> getParam(i) -> getType() ){
						
						//fprintf(errout,"Line# %d: Type mismatch for argument %d of '%s'\n",line_count,i+1, $$ -> getName().c_str() );
						fprintf(errout,"Line# %d: Conflicting types for '%s' \n",line_count,$$ -> getName().c_str() );
					
						err_count ++;
					}
				
				}
			
				if( $$ -> getParam(i) -> getName() == "int" || $$ -> getParam(i) -> getName() == "float" || $$ -> getParam(i) -> getName() == "void")		{
					
					fprintf(errout,"Line# %d: No definition of parameter for argument %d of '%s'\n",line_count,i+1, $$ -> getName().c_str() );
					
					err_count ++;	
				
				}
			
				else{
				
					bool b = table. INSERT( $$ ->getParam(i) -> getName(), $$ ->getParam(i) -> getTypeSpec(), symtab, $$ ->getParam(i) -> getIsFunction(), $$ ->getParam(i) -> getIsArray() );
				
					if( b == false) {
				
						fprintf(errout,"Line# %d: Redefinition of parameter '%s' \n",line_count,$$ -> getParam(i) -> getName().c_str() );
						err_count ++;
				
					}
					
				}
			
			
			}
			
			
			cout << table.LOOKUP($$ -> getName()) -> getParamList().size();
			
			
			pc = 0;
			
			$$ =  new SymbolInfo("func_definition");
			$$ -> setRule("embed_func_def : type_specifier ID LPAREN parameter_list RPAREN");
			$$ -> setStartLine( $1 -> getStartLine());
			$$ -> setEndLine($5 -> getEndLine() );
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
			$$ -> addChild($5);
			
			
			fprintf(logout,"embed_func_definition : type_specifier ID LPAREN parameter_list RPAREN\n");

		}
		| type_specifier ID LPAREN RPAREN {
		
			$$ = new SymbolInfo($2);
			$$ -> setIsFunction(true);
			$$ -> setIsDefinition(true);
			$2 -> setIsFunction(true);
			$2 -> setIsDefinition(true);
			$$ -> setTypeSpec($1 -> getType());
			bool t = table . INSERT( $$ -> getName() ,$$ -> getTypeSpec() , symtab, $$ -> getIsFunction() , $$ -> getIsArray() ,$$ -> getIsDefinition());
			
			table . EnterScope();
			
			currType = $1 -> getType();
			currScope = $2 -> getName();
			
			if(table.getCNT() > 1){
				
				fprintf(errout,"Line# %d: Function defined within another function\n",line_count );
				
				err_count++;
			}
			
			$$ =  new SymbolInfo("func_definition");
			$$ -> setRule("embed_func_def : type_specifier ID LPAREN RPAREN");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($4 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
			
			fprintf(logout,"embed_func_def : type_specifier ID LPAREN RPAREN\n");
		
		};
parameter_list  : parameter_list COMMA type_specifier ID{

			
 			$$ = new SymbolInfo($1);
 			$4 -> setTypeSpec( $3 -> getType() );
 			$4 -> setType( $3 -> getType() );
 			$$ -> push_paramlist($4);
 			
 			
 			pc++;
 			
 			$$ -> setRule("parameter_list : parameter_list COMMA type_specifier ID");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($4 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
 			
			fprintf(logout,"parameter_list  : parameter_list COMMA type_specifier ID\n");

		}	
		| parameter_list COMMA type_specifier{
		
			$$ = new SymbolInfo($1);
			$3 -> setTypeSpec( $3 -> getType() );
			$$ -> push_paramlist($3);
			
			$$ -> setRule("parameter_list : parameter_list COMMA type_specifier");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			
			fprintf(logout,"parameter_list : parameter_list COMMA type_specifier\n");
		
		}
 		| type_specifier ID{
 		
 			$$ = new SymbolInfo();
 			$$ -> getParamList().clear();
 			$2 -> setTypeSpec( $1 -> getType() );
 			$2 -> setType( $1 -> getType() );
 			$$ -> push_paramlist($2);
 			
 			$$ -> setRule("parameter_list : type_specifier ID");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($2 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			
 			fprintf(logout,"parameter_list : type_specifier ID \n");
 			
 			pc++;
 			
 		}
		| type_specifier{
		
			$$ = new SymbolInfo();
			$$ -> getParamList().clear();
 			$1 -> setTypeSpec( $1 -> getType() );
 			$$ -> push_paramlist($1);
 			
 			$$ -> setRule("parameter_list : type_specifier");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"parameter_list : type_specifier \n");
		
		}
 		;

 		
compound_statement : LCURL statements RCURL{
			//table . EnterScope();
			$$ = new SymbolInfo("compound_statement");
			table . PRINT_A(logout);
			table . ExitScope();
			
			$$ -> setRule("compound_statement : LCURL statements RCURL");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			fprintf(logout,"compound_statement  : LCURL statements RCURL\n");

		}
 		    | LCURL RCURL{
 		    
 		    	table . PRINT_A(logout);
 		    	table . ExitScope();
 		    	
 		    	$$ = new SymbolInfo("compound_statement");
 		    	$$ -> setRule("compound_statement : LCURL RCURL");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($2 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			
 		    	fprintf(logout,"compound_statement  : LCURL RCURL\n");
 		    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON { 

			$$ = new SymbolInfo($2);
			$$ -> setName("Variable Declaration");
			$$ -> setTypeSpec($1 -> getType());
			//cout << $$ -> getSize() << endl;
			//cout << lc << endl;
			
			
			
			for(int i=0;i<lc ;i++){
			
				$$ -> getID(i) -> setTypeSpec($1 -> getType());
				bool t = table . INSERT($$ -> getID(i) -> getName() ,$$ -> getID(i) -> getTypeSpec() , symtab, $$ -> getID(i) -> getIsFunction() , $$ -> getID(i) -> getIsArray() );
				
				if($1 -> getType() == "VOID") {
			
					fprintf(errout,"Line# %d: Variable or field '%s' declared 'void' \n",line_count, $$ -> getID(i) -> getName().c_str() );
					//lc = 0;
					err_count ++;
				}
				
				if(t == false)  {
					SymbolInfo* s = table . LOOKUP($$ -> getID(i) -> getName());
				
					if( $$ -> getID(i) -> getIsFunction() == s -> getIsFunction() ){
					
						if( $$ -> getID(i) -> getTypeSpec() == s -> getTypeSpec() ){
							fprintf(errout,"Line# %d: Redefinition of Variable '%s' \n",line_count,$$ -> getID(i) -> getName().c_str() );
							
						}
						
						else fprintf(errout,"Line# %d: Conflicting types for '%s' \n",line_count,$$ -> getID(i) -> getName().c_str() );
						
					
					}
					
					else fprintf(errout,"Line# %d: '%s' redeclared as different kind of symbol \n",line_count,$$ -> getID(i) -> getName().c_str() );
					
					err_count ++;
				
				}
				//$$ -> getID(i) -> Print();
			
			}
			
			table . PRINT_A(symtab);
			
			lc = 0;
			
			$$ -> setRule("var_declaration : type_specifier declaration_list SEMICOLON");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			
			fprintf(logout,"var_declaration : type_specifier declaration_list SEMICOLON\n");
			
		}
 		 ;
 		 
type_specifier	: INT {

		 	$$ = new SymbolInfo($1); 
		 	
		 	$$ -> setRule("type_specifier : INT");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			
		 	fprintf(logout,"type_specifier : INT\n");	
	

		}
 		| FLOAT {

			$$ = new SymbolInfo($1);
			
			$$ -> setRule("type_specifier : FLOAT");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"type_specifier : FLOAT\n");

		}
 		| VOID {

			$$ = new SymbolInfo($1);
			
			$$ -> setRule("type_specifier : VOID");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"type_specifier : VOID\n");

		}
 		;
 		
declaration_list : declaration_list COMMA ID {

			$$ = new SymbolInfo($1);
			$$ -> push_declist($3);
			//$$ = $1; 
			lc = lc + 1;
			//cout << $3 -> getName() << endl;
			
			$$ -> setRule("declaration_list : declaration_list COMMA ID");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			fprintf(logout,"declaration_list : declaration_list COMMA ID\n");
			

		 }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
 		  
 		  	$$ = new SymbolInfo($1);
 		  	$3 -> setIsArray(true,stoi($5 -> getName()) );
 		  	$$ -> push_declist($3);
			//$$ = $1;
 		  	lc = lc + 1;
 		  	//cout << $3 -> getName() << endl;
 		  	
 		  	$$ -> setRule("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($6 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
			$$ -> addChild($5);
			$$ -> addChild($6);
 		  	fprintf(logout,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE\n");
 		  	
 		  }
 		  | ID   {
 		  
 		  	
 		  	$$ = new SymbolInfo("Declaration List");
 		  	$$ -> push_declist($1);
 		  	lc = lc + 1;
 		  	
 		  	$$ -> setRule("declaration_list : ID");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			
 		  	fprintf(logout,"declaration_list : ID\n");
 		  
 		  }
 		  | ID LTHIRD CONST_INT RTHIRD  {
 		  
 		  	$1 -> setIsArray(true, stoi($3 -> getName() ));
 		  	$$ = new SymbolInfo("Declaration List");
 		  	$$ -> push_declist($1);
 		  	lc = lc + 1;
 		  	
 		  	$$ -> setRule("declaration_list : ID LTHIRD CONST_INT RTHIRD");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($4 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
 		  	fprintf(logout,"declaration_list : ID LSQUARE CONST_INT RSQUARE\n");
 		  
 		  }
 		  ;
 		  
statements : statement {

			$$ = new SymbolInfo("Statements");
			$$ -> setRule("statements : statement");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"statements : statement\n");

		}
	   | statements statement {

			$$ = new SymbolInfo("Statements");
			$$ -> setRule("statements : statements statement");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"statements : statements statement\n");

		}
	| statements func_definition{
	
			$$ = new SymbolInfo("Statements");
			$$ -> setRule("statements : statements func_definition");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"statements : statements func_definition\n");
	
	}
	
	| statements func_declaration{
	
			$$ = new SymbolInfo("Statements");
			
			
			fprintf(errout,"Line# %d: Function declared within another function\n",line_count );
				
			err_count++;
			$$ -> setRule("statements : statements func_declaration");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"statements : statements func_declaration\n");
	
	}
	   ;
	   
statement : var_declaration {

			$$ = new SymbolInfo("statement");
			$$ -> setRule("statement : var_declaration");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"statement : var_declaration\n");

		}
	  | expression_statement {

			$$ = new SymbolInfo("statement");
			$$ -> setRule("statement : expression_statement");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"statement : expression_statement\n");

		}
	  | compound_statement {

			$$ = new SymbolInfo("statement");
			$$ -> setRule("statement : compound_statement");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			
			fprintf(logout,"statement : compound_statement\n");

		}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
	  
	  		$$ = new SymbolInfo("statement");
			$$ -> setRule("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($7 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
			$$ -> addChild($5);
			$$ -> addChild($6);
			$$ -> addChild($7);

			fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");

		}
	  | IF LPAREN expression RPAREN statement	%prec LOWER_THAN_ELSE {
	  
	  	$$ = new SymbolInfo("statement");
		$$ -> setRule("statement : IF LPAREN expression RPAREN statement");
		$$ -> setStartLine($1 -> getStartLine() );
		$$ -> setEndLine($5 -> getEndLine() );
			
		$$ -> addChild($1);
		$$ -> addChild($2);
		$$ -> addChild($3);
		$$ -> addChild($4);
		$$ -> addChild($5);
			
	  	fprintf(logout,"statement : IF LPAREN expression RPAREN statement \n");
	  
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
	  
	  		$$ = new SymbolInfo("statement");
			$$ -> setRule("statement : IF LPAREN expression RPAREN statement ELSE statement");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($7 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
			$$ -> addChild($5);
			$$ -> addChild($6);
			$$ -> addChild($7);

			fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement\n");

		}
	  | WHILE LPAREN expression RPAREN statement {

			$$ = new SymbolInfo("statement");
			$$ -> setRule("statement : WHILE LPAREN expression RPAREN statement");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($5 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
			$$ -> addChild($5);
			
			fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement\n");

		}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {

			$$ = new SymbolInfo("statement");
			$$ -> setRule("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($5 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);
			$$ -> addChild($5);
			
			fprintf(logout,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");

		}
	  | RETURN expression SEMICOLON {

			$$ = new SymbolInfo("statement");
			
			if($2 -> getType() != currType) {
			
				fprintf(errout,"Line# %d: Return type mismatch for '%s',cannot convert '%s' to '%s' \n",line_count, currScope.c_str(), $2 -> getType().c_str() , currType.c_str() );
				
				err_count ++;
			
			} 
			$$ -> setRule("statement : RETURN expression SEMICOLON");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			
			
			fprintf(logout,"statement : RETURN expression SEMICOLON\n");

		}
	  ;
	  
expression_statement 	: SEMICOLON {

			$$ = new SymbolInfo("expression_statement");
			$$ -> setRule("expression_statement : SEMICOLON");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			
			fprintf(logout,"expression_statement : SEMICOLON\n");

		}			
			| expression SEMICOLON {
			
			$$ = new SymbolInfo($1);
			$$ -> setRule("expression_statement : expression SEMICOLON");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($2 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);

			fprintf(logout,"expression_statement : expression SEMICOLON\n");

		}
			;
	  
variable : ID {

			
			SymbolInfo* s = table. LOOKUP( $1 -> getName() );

			$1 -> setType(s -> getType() );
			$1 -> setTypeSpec(s -> getType() );
			
			$$ = new SymbolInfo($1);
			
			if(  s -> getName() == "" || s -> getIsFunction() == true ) {
			
				fprintf(errout, "Line# %d: Undeclared variable '%s'\n",line_count , $1 -> getName().c_str() );
				err_count ++;
			}
			
			else if(  s -> getIsArray() == true) {
			
				fprintf(errout, "Line# %d: '%s' is an array\n",line_count , $1 -> getName().c_str() );
				err_count ++;
			}
			
			/*else if( s -> getType() == "VOID"){
			
				fprintf(errout, "Undeclared Vaeriable '%s'", $1 -> getName() );
			}*/
			
			$$ -> setRule("variable : ID");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			
			fprintf(logout,"variable : ID\n");

		} 		
	 | ID LTHIRD expression RTHIRD {
	 
	 		
			SymbolInfo* s = table. LOOKUP( $1 -> getName() );
			
			$1 -> setType(s -> getType() );
			$1 -> setTypeSpec(s -> getType() );
			
			$$ = new SymbolInfo($1);
			if(  s-> getName() == "" || s -> getIsFunction() == true) {
			
				fprintf(errout, "Line# %d: Undeclared variable '%s'\n",line_count , $1 -> getName().c_str() );
				err_count ++;
			}
			
			else if(  s -> getIsArray() == false) {
			
				fprintf(errout, "Line# %d: '%s' is not an array\n",line_count , $1 -> getName().c_str() );
				err_count ++;
			}
			
			else if( $3 -> getTypeSpec() == "VOID") {
			
				fprintf(errout, "Line# %d: Void cannot be used in expression\n",line_count );
				err_count ++;
			}
			
			else if( $3 -> getTypeSpec() != "INT") {
			
				fprintf(errout, "Line# %d: Array subscript is not an integer\n",line_count );
				err_count ++;
			}
			
			$$ -> setRule("variable : ID LSQUARE expression RSQUARE");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($4 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			$$ -> addChild($4);

			fprintf(logout,"variable : ID LSQUARE expression RSQUARE\n");

		}  
	 ;
	 
 expression : logic_expression	{

			$$ = new SymbolInfo($1);
			
			$$ -> setRule("expression : logic_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"expression : logic_expression\n");
			

		} 
	   | variable ASSIGNOP logic_expression {

			$$ = new SymbolInfo($1);
			if( $3 -> getTypeSpec() == "VOID" ){
				fprintf(errout,"Line# %d: Void cannot be used in expression \n",line_count );
				err_count ++;
			}
			
			if( $1 -> getTypeSpec() == "INT" && $3 -> getTypeSpec() == "FLOAT"){
			
				fprintf(errout,"Line# %d: Warning: possible loss of data in assignment of FLOAT to INT\n",line_count );
				err_count ++;
			}
			
			$$ -> setRule("expression : variable ASSIGNOP logic_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			
			
			fprintf(logout,"expression : variable ASSIGNOP logic_expression\n");
			

		} 	
	   ;
			
logic_expression : rel_expression {

			$$ = new SymbolInfo($1);
			
			$$ -> setRule("logic_expression : rel_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			
			fprintf(logout,"logic_expression : rel_expression\n");

		} 	
		 | rel_expression LOGICOP rel_expression {

			$$ = new SymbolInfo($1);
			if( $1 -> getType() == "VOID" || $3 -> getType() == "VOID" ){
				fprintf(errout,"Line# %d: Void cannot be used in expression \n",line_count );
				err_count ++;
			}
			
			$$ -> setRule("logic_expression : rel_expression LOGICOP rel_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			fprintf(logout,"logic_expression : rel_expression LOGICOP rel_expression\n");

		} 	
		 ;
			
rel_expression	: simple_expression {

			$$ = new SymbolInfo($1);
			
			$$ -> setRule("rel_expression : simple_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			
			fprintf(logout,"rel_expression : simple_expression\n");

		}
		| simple_expression RELOP simple_expression {

			$$ = new SymbolInfo($1);
			if( $1 -> getType() == "VOID" || $3 -> getType() == "VOID" ){
				fprintf(errout,"Line# %d: Void cannot be used in expression \n",line_count );
				err_count ++;
			}
			
			$$ -> setRule("rel_expression : simple_expression RELOP simple_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			fprintf(logout,"rel_expression : simple_expression RELOP simple_expression\n");

		}	
		;
				
simple_expression : term {

			$$ = new SymbolInfo($1);
			
			$$ -> setRule("simple_expression : term");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"simple_expression : term\n");
			

		}
		  | simple_expression ADDOP term {

			$$ = new SymbolInfo($1);
			if( $1 -> getType() == "VOID" || $3 -> getType() == "VOID"){
				fprintf(errout,"Line# %d: Void cannot be used in expression \n",line_count );
				err_count ++;
			}
			
			$$ -> setRule("simple_expression : simple_expression ADDOP term");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			fprintf(logout,"simple_expression : simple_expression ADDOP term\n");

		}
		  ;
					
term :	unary_expression {

			$$ = new SymbolInfo($1);
			
			$$ -> setRule("term : unary_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			
			fprintf(logout,"term : unary_expression\n");

		}
     |  term MULOP unary_expression {

			
			$$ = new SymbolInfo($1);
			if( $1 -> getType() == "VOID" || $3 -> getType() == "VOID"){
				fprintf(errout,"Line# %d: Void cannot be used in expression \n",line_count );
				err_count ++;
			}
			
			if( $2 -> getName() == "%" && ($1 -> getType() != "INT" || $3 -> getType() != "INT")){
			
				fprintf(errout,"Line# %d: Operands of modulus must be integers\n",line_count );
				err_count ++;
				
				
			}
			
			if( ($2 -> getName() == "%" || $2 -> getName() == "/")  && ZF == 1){
			
				fprintf(errout,"Line# %d: Warning: division by zero i=0f=1Const=0\n",line_count );
				err_count ++;
				ZF = 0;
				
			}
			
			ZF = 0;
			
			$$ -> setRule("term : term MULOP unary_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			fprintf(logout,"term : term MULOP unary_expression\n");

		}
     ;

unary_expression : ADDOP unary_expression {

			$$ = new SymbolInfo($2);
			if( $2 -> getType() == "VOID"){
				fprintf(errout,"Line# %d: Void cannot be used in expression \n",line_count );
				err_count ++;
			}
			
			$$ -> setRule("unary_expression : ADDOP unary_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($2 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			
			fprintf(logout,"unary_expression : ADDOP unary_expression\n");

		} 
		 | NOT unary_expression {

			$$ = new SymbolInfo($2);
			if( $2 -> getType() == "VOID"){
				fprintf(errout,"Line# %d: Void cannot be used in expression \n",line_count );
				err_count ++;
			}
			
			$$ -> setRule("unary_expression : NOT unary_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($2 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			
			fprintf(logout,"unary_expression : NOT unary_expression\n");

		} 
		 | factor {

			$$ = new SymbolInfo($1);
			
			$$ -> setRule("unary_expression : factor");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"unary_expression : factor\n");

		} 
		 ;
	
factor	: variable {

		$$ = new SymbolInfo($1);
		
		
		$$ -> setRule("factor : variable");
		$$ -> setStartLine($1 -> getStartLine() );
		$$ -> setEndLine($1 -> getEndLine() );
			
		$$ -> addChild($1);
		fprintf(logout,"factor : variable\n");

	}
	| ID LPAREN argument_list RPAREN {
	
		SymbolInfo* s = table. LOOKUP( $1 -> getName() );
		//if( s-> getName() != "") cout << s-> getParamList().size();

		$1 -> setType(s -> getType() );
		$1 -> setTypeSpec(s -> getType() );
			
		if( s-> getName() != "") cout << s-> getParamList().size();	
			
		$$ = new SymbolInfo($1);
			
		if(  s -> getName() == "" ) {
			
			fprintf(errout, "Line# %d: Undeclared function '%s'\n",line_count , $1 -> getName().c_str() );
			err_count ++;
			
		}
		
		else if(  s -> getIsFunction() == false ) {
			
			fprintf(errout, "Line# %d: Undeclared function '%s'\n",line_count , $1 -> getName().c_str() );
			err_count ++;
			
		}
		
		else if( s -> getIsFunction() == true &&  s -> getIsDefinition() == false){
		
			fprintf(errout, "Line# %d: Declared but undefined function '%s'\n",line_count , $1 -> getName().c_str() );
			err_count ++;
		
		}
		
		else {
			
			if(s -> getParamList().size() < $3 -> getDecList().size()){
				
				fprintf(errout,"Line# %d: Too many arguments to function '%s'\n",line_count, $$ -> getName().c_str() );
				//fprintf(errout,"$1# %d: $3# '%d'\n",$1 -> getParamList().size() , $3 -> getDecList().size() );
				err_count ++;
			}
			
			else if(s -> getParamList().size() > $3 -> getDecList().size()){
				
				fprintf(errout,"Line# %d: Too few arguments to function '%s'\n",line_count, $$ -> getName().c_str() );
				err_count ++;
			}
		
			
			else{
			
				for(int i=0; i< s -> getParamList().size() ; i++ ){
				
					SymbolInfo* r = table.LOOKUP($3 -> getID(i) -> getName());
					
					
					if( r -> getName() == "" && $3 -> getID(i) -> getIsConst() == false) {
					
						fprintf(errout,"Line# %d: Undeclared Variable'%s'\n",line_count, $3 -> getID(i) -> getName().c_str() );
						
					
						err_count ++;
					}
				
					if(s -> getParam(i) -> getType() != $3 -> getID(i) -> getType() ){
						
						fprintf(errout,"Line# %d: Type mismatch for argument %d of '%s'\n",line_count,i+1, $$ -> getName().c_str() );
						
					
						err_count ++;
					}
				}
			
			}
		}
		
		$$ -> setRule("variable : ID LSQUARE expression RSQUARE");
		$$ -> setStartLine($1 -> getStartLine() );
		$$ -> setEndLine($4 -> getEndLine() );
			
		$$ -> addChild($1);
		$$ -> addChild($2);
		$$ -> addChild($3);
		$$ -> addChild($4);
		fprintf(logout,"factor : ID LPAREN argument_list RPAREN\n");
	
	}
	| LPAREN expression RPAREN {
	
		$$ = new SymbolInfo("factor");
		$$ -> setRule("variable : LPAREN expression RPAREN");
		$$ -> setStartLine($1 -> getStartLine() );
		$$ -> setEndLine($3 -> getEndLine() );
			
		$$ -> addChild($1);
		$$ -> addChild($2);
		$$ -> addChild($3);
		
		fprintf(logout,"factor : LPAREN expression RPAREN\n");
	
	}

	| CONST_INT {
	
		if( stoi( $1 -> getName() ) == 0 ) ZF = 1 ;
		$1 -> setTypeSpec("INT");
		$1 -> setType("INT");
		$1 -> setIsConst(true);
		$$ = new SymbolInfo($1);
		
		$$ -> setRule("factor : CONST_INT");
		$$ -> setStartLine($1 -> getStartLine() );
		$$ -> setEndLine($1 -> getEndLine() );
			
		$$ -> addChild($1);
		fprintf(logout,"factor : CONST_INT\n");
	
	}
	| CONST_FLOAT {
	
		if( stof( $1 -> getName() ) == 0 ) ZF = 1;
		$1 -> setTypeSpec("FLOAT");
		$1 -> setType("FLOAT");
		$1 -> setIsConst(true);
		$$ = new SymbolInfo($1);
		
		$$ -> setRule("factor : CONST_FLOAT");
		$$ -> setStartLine($1 -> getStartLine() );
		$$ -> setEndLine($1 -> getEndLine() );
			
		$$ -> addChild($1);
		fprintf(logout,"factor : CONST_FLOAT\n");
	
	}
	| variable INCOP {
	
		$$ = new SymbolInfo($1);
		$$ -> setRule("factor : variable INCOP");
		$$ -> setStartLine($1 -> getStartLine() );
		$$ -> setEndLine($2 -> getEndLine() );
			
		$$ -> addChild($1);
		$$ -> addChild($2);
		fprintf(logout,"factor : variable INCOP\n");
	
	}
	| variable DECOP {
	
		$$ = new SymbolInfo($1);
		$$ -> setRule("factor : variable DECOP");
		$$ -> setStartLine($1 -> getStartLine() );
		$$ -> setEndLine($2 -> getEndLine() );
			
		$$ -> addChild($1);
		$$ -> addChild($2);
		fprintf(logout,"factor : variable DECOP\n");
	
	}
	;
	
argument_list : arguments{
			
			$$ = new SymbolInfo($1);
			$$ -> setRule("argument_list : arguments");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
			fprintf(logout,"argument_list : arguments\n");
			
		}
			  |{
			  
			  $$ = new SymbolInfo("Argument_List");
			  fprintf(logout,"argument_list : \n");
			  }
			  ;
	
arguments : arguments COMMA logic_expression{
			
			$$ = new SymbolInfo($1);
			$$ -> push_declist($3);
			
			lc = lc + 1;
			
			$$ -> setRule("arguments : arguments COMMA logic_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($3 -> getEndLine() );
			
			$$ -> addChild($1);
			$$ -> addChild($2);
			$$ -> addChild($3);
			
			fprintf(logout,"arguments : arguments COMMA logic_expression\n");
		}
	      | logic_expression{
	      
	      		$$ = new SymbolInfo("Argument List");
 		  	$$ -> push_declist($1);
 		  	lc = lc + 1;
 		  	
 		  	$$ -> setRule("arguments : logic_expression");
			$$ -> setStartLine($1 -> getStartLine() );
			$$ -> setEndLine($1 -> getEndLine() );
			
			$$ -> addChild($1);
 		  	fprintf(logout,"arguments : logic_expressions\n");
	      
	      }
	      ;
 

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	
	//fp2= fopen(argv[2],"w");
	//fclose(fp2);
	//fp3= fopen(argv[3],"w");
	//fclose(fp3);
	
	//fp2= fopen(argv[2],"a");
	//fp3= fopen(argv[3],"a");
	
	symtab= fopen("SymbolTable.txt","w");
	errout= fopen("error.txt","w");
	pstout= fopen("Parsetree.txt","w");
	
	

	yyin=fp;
	yyparse();
	
	//Total Lines: 73
	//Total Errors: 23
	
	fprintf(logout, "Total Lines: %d\n", line_count);
	fprintf(logout, "Total Errors: %d\n", err_count);
	

	//fclose(fp2);
	//fclose(fp3);
	
	//table.PRINT_A(logout);
	
	return 0;
}

