#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include <map>
#include "1905119_SymbolTable.cpp"



using namespace std;


FILE* code = fopen("Code.txt","w");
FILE* tabout = fopen("Tab.txt","w");
SymbolTable tab(11);
int StackOffset;
int ParamOffset;
int lbl = 0;
bool seflag = false;
bool tflag = false;
bool relflag = false;
bool arithflag = false;
bool mulflag = false;
bool elifjumpflag = false;
bool dotcode = false;
string addop = "ADD";
string mulop = "MUL";
map <string,string> relmap;
map <string,int> logimap;

bool negA = false;
bool notA = false;

vector<bool> temparithflag ;
vector<bool> tempmulflag ;
vector<bool> tempseflag ;
vector<bool> temptflag ;
vector<bool> tempnegA ;
vector<bool> tempnotA ;
vector<int> block;
vector<int> last;
vector<int>looplabel;
int blocklbl = 0;
int endlbl = 0;
int retlbl = 0;

void init(){
	
	relmap[">"] = "JG";
	relmap["<"] = "JL";
	relmap[">="] = "JGE";
	relmap["<="] = "JLE";
	relmap["=="] = "JE";
	relmap["!="] = "JNE";
	logimap ["||"] = 1;
	logimap ["&&"] = 0;
	logimap[">"] = 1;
	logimap["<"] = 1;
	logimap[">="] = 1;
	logimap["<="] = 1;
	logimap["=="] = 1;
	logimap["!="] = 1;
	fprintf(code,";-------\n");
	fprintf(code,";\n");
	fprintf(code,";-------\n");
	fprintf(code,".MODEL SMALL\n");
	fprintf(code,".STACK 1000H\n");



	fprintf(code,".DATA\n\t.CR EQU 0DH\n\t.FR EQU OAH\n\tnumber DB \"00000$\"\n");
}

void printENDL(){

	fprintf(code,"ENDL PROC\n");
	fprintf(code,"\tPUSH AX\n");
	fprintf(code,"\tPUSH DX\n");
	fprintf(code,"\tMOV AH, 2\n");
	fprintf(code,"\tMOV DL, 0DH\n");
	fprintf(code,"\tINT 21H\n");
	fprintf(code,"\tMOV AH, 2\n");
	fprintf(code,"\tMOV DL, 0AH\n");
	fprintf(code,"\tINT 21H\n");
	fprintf(code,"\tPOP DX\n");
	fprintf(code,"\tPOP AX\n");
	fprintf(code,"\tRET\n");
	fprintf(code,"ENDL ENDP\n");


}
void print_output(){

	fprintf(code,"print_output PROC  ;print what is in AX\n");
	fprintf(code,"\tPUSH AX\n");
	fprintf(code,"\tPUSH BX\n");
	fprintf(code,"\tPUSH CX\n");
	fprintf(code,"\tPUSH DX\n");
	fprintf(code,"\tPUSH SI\n");
	
	fprintf(code,"\tLEA SI, NUMBER\n");
	fprintf(code,"\tMOV BX, 10\n");
	fprintf(code,"\tADD SI, 4\n");
	fprintf(code,"\tCMP AX, 0\n");
	fprintf(code,"\tJNGE NEGATE\n");
	
	fprintf(code,"PRINT: \n");
	fprintf(code,"\tXOR DX, DX\n");
	fprintf(code,"\tDIV BX\n");
	fprintf(code,"\tMOV [SI], DL\n");
	fprintf(code,"\tADD [SI], '0'\n");
	fprintf(code,"\tDEC SI\n");
	fprintf(code,"\tCMP AX, 0\n");
	fprintf(code,"\tJNE PRINT\n");
	fprintf(code,"\tINC SI\n");
	fprintf(code,"\tLEA DX, SI\n");
	fprintf(code,"\tMOV AH, 09H\n");
	fprintf(code,"\tINT 21H\n");
	fprintf(code,"\tPOP SI\n");
	fprintf(code,"\tPOP DX\n");
	fprintf(code,"\tPOP CX\n");
	fprintf(code,"\tPOP BX\n");
	fprintf(code,"\tPOP AX\n");
	fprintf(code,"\tRET\n");
	
	fprintf(code,"NEGATE: \n");
	fprintf(code,"\tPUSH AX\n");
	fprintf(code,"\tMOV AH, 02H\n");
	fprintf(code,"\tMOV DL, '-'\n");
	fprintf(code,"\tINT 21H\n");
	fprintf(code,"\tPOP AX\n");
	fprintf(code,"\tNEG AX\n");
	fprintf(code,"\tJMP PRINT\n");
	
	fprintf(code,"print_output ENDP \n");

}

void PRINT_param_list(SymbolInfo * s){

	
			
	s -> setOffset(ParamOffset-2);
	s -> setLen(2);
	ParamOffset =ParamOffset - 2;
	
	
	bool t = tab . INSERT(s,tabout);

}

void PRINT_dec_list(SymbolInfo * s,int sz = 1){

	if(tab.getCNT() >= 1) {
			
		s -> setOffset(StackOffset+2);
		s -> setLen(2*sz);
		StackOffset =StackOffset + 2*sz;
		fprintf(code,"\tSUB SP, %d\n", s ->getLen());
				
	}
			
	else{
			
		s -> setIsGlobal(true);
		fprintf(code,"\t%s DW %d DUP (0000H)\n", s -> getName().c_str(),sz);	
				
			
	}
	
	bool t = tab . INSERT(s,tabout);

}

void r_var_print(SymbolInfo* t,int k = 0){

	if( t -> getIsGlobal() == true) fprintf(code,"\tMOV AX, %s\n" , t -> getName().c_str() );
	else if ( t -> getIsParam() == true) fprintf(code,"\tMOV AX, [BP + %d]\n",  t -> getOffset() + 2*k );
	else fprintf(code,"\tMOV AX, [BP - %d]\n",  t -> getOffset() + 2*k );

}

void l_var_print(SymbolInfo* t,int k = 0){

	if( t -> getIsGlobal() == true) fprintf(code,"\tMOV %s, AX\n" , t -> getName().c_str() );
	else if ( t -> getIsParam() == true) fprintf(code,"\tMOV [BP + %d],AX\n",  t -> getOffset() + 2*k );
	else fprintf(code,"\tMOV [BP - %d], AX\n",  t -> getOffset() + 2*k );

}

void jump_statement(SymbolInfo* s,SymbolInfo* t){

	
	fprintf(code,"L%d: \n", lbl+ 1);
	/*if(elifjumpflag == false) */fprintf(code,"\tMOV AX, 1\n");
	if(elifjumpflag == true);
	fprintf(code,"\tJMP L%d\n", lbl+3 );
		
	fprintf(code,"L%d: \n", lbl+ 2);
	/*if(elifjumpflag == false)*/ fprintf(code,"\tMOV AX, 0\n" );
	if(elifjumpflag == true);
		
	fprintf(code,"L%d: \n", lbl+ 3);
	lbl = lbl +3;
}

void program(SymbolInfo* s);
void unit(SymbolInfo* s);

void var_declaration(SymbolInfo* s );

void declaration_list(SymbolInfo* s);
void parameter_list(SymbolInfo* s);

void func_declaration(SymbolInfo* s );
void func_definition(SymbolInfo* s );

void embed_func_def(SymbolInfo* s);
void compound_statement(SymbolInfo* s);
void statements(SymbolInfo* s);
void statement(SymbolInfo* s,bool fromElse = false);

void print_statement(SymbolInfo* s);

void expression_statement(SymbolInfo* s);
void expression(SymbolInfo* s);
SymbolInfo* variable(SymbolInfo* s);
void logic_expression(SymbolInfo* s);
void rel_expression(SymbolInfo* s);
void simple_expression(SymbolInfo* s);
void term(SymbolInfo* s);
void unary_expression(SymbolInfo* s);
void factor(SymbolInfo* s);






void start(SymbolInfo* s,int depth = 0){

	
	cout << "start" << endl;
	init();
	program(s -> getChild(0) );
	printENDL();
	print_output();
	fprintf(code,"EM:\n");
	fprintf(code,"END main");
	
	fclose(code);
	
	ifstream file("Code.txt");
	ofstream fout("optCode.txt");
	
	string line;
	string ln[3];
	
	 getline (file,ln[0]);
	 getline (file,ln[1]);
	 
	 //PUSH AX
	//POP CX
	//MOV AX,CX
	
	while ( getline (file,line) ) {
	
		if(ln[1] == "\tPUSH AX" && line == "\tPOP AX") {
			fout << ln[0] << endl;
			//ln[0] = ln[1];
			//ln[1] = line; 
			ln[0] = "";
			ln[1] = "";
		}
		
		else if(ln[0] == "\tPUSH AX" && ln[1] == "\tPOP CX" && line == "\tMOV AX,CX") {
			//fout << ln[0] << endl;
			//ln[0] = ln[1];
			//ln[1] = line; 
			ln[0] = "";
			ln[1] = "";
		}
		
		else{
			fout << ln[0] << endl;
			ln[0] = ln[1];
			ln[1] = line; 
		}
		
		
	
	}
	
	fout << ln[1] << endl;
	fout << ln[2] << endl;
	
	file.close();
	fout.close();

}

void program(SymbolInfo* s){

	cout << "program" << endl;
	for(int i=0;i<s -> getChildren().size() ;i++){
	
		
		if( s -> getChild(i) -> getSymbolName() == "program") program(s -> getChild(i));
		else if( s -> getChild(i) -> getSymbolName() == "unit") unit(s -> getChild(i));
		
	}
	

}

void unit(SymbolInfo* s){

	cout << "unit" << endl;
	for(int i=0;i<s -> getChildren().size() ;i++){
	
		if( s -> getChild(i) -> getSymbolName() == "var_declaration") {
		
			
			var_declaration(s -> getChild(i));
			if(dotcode == false)fprintf(code,".CODE\n");
			dotcode = true;
			
		}
		
		else if( s -> getChild(i) -> getSymbolName() == "func_declaration") {
		
			if(dotcode == false) fprintf(code,".CODE\n");
			dotcode = true;
			func_declaration(s -> getChild(i));
		}
		else if( s -> getChild(i) -> getSymbolName() == "func_definition") {
		
			if(dotcode == false) fprintf(code,".CODE\n");
			dotcode = true;
			func_definition(s -> getChild(i));
		};
		
		
	}

}

void var_declaration(SymbolInfo* s ){

	cout << "var_declaration" << endl;
	for(int i=0;i<s -> getChildren().size() ;i++){
	
		if( s -> getChild(i) -> getSymbolName() == "declaration_list") {
			
			declaration_list(s -> getChild(i));
			for(int j = 0; j< s -> getChild(i) -> getDecList().size() ; j++){
			
				//s -> getChild(i) -> get(j) -> getName();
				if( s -> getChild(i) -> getID(j) -> getIsArray() == false) PRINT_dec_list(s -> getChild(i) -> getID(j));
				else PRINT_dec_list(s -> getChild(i) -> getID(j) , s -> getChild(i) -> getID(j) -> getArrSize() );
				 
			
			}
			
		}
		
	}

}

void func_declaration(SymbolInfo* s ){

	cout << "func_declaration" << endl;
	

}

void func_definition(SymbolInfo* s ){

	cout << "func_definition" << endl;
	
	
	
	embed_func_def(s -> getChild(0) );
	if(s -> getChild(0) -> getChild(1) -> getName() == "main" ) fprintf(code,"\tMOV AX, @DATA\n\tMOV DS, AX\n");
	fprintf(code,"\tPUSH BP\n\tMOV BP, SP\n");
	int argsize = 2*s -> getChild(0) -> getParamList().size();
	compound_statement(s -> getChild(1) );
	
	fprintf(code,"R%d:\n",retlbl);
	
	retlbl++;
	if( s -> getChild(0) -> getChild(1) -> getName() == "main") fprintf(code,"\tPOP BP\n\tMOV AH, 4CH\n\tINT21H\n");
	else if( argsize != 0) fprintf(code,"\tPOP BP\n\tRET %d\n",argsize);
	else fprintf(code,"\tPOP BP\n\tRET \n");
	argsize = 0;
	//ParamOffset = 2;
	
	fprintf(code,"%s ENDP\n", s -> getName().c_str());
	//StackOffset = 0;

}

void declaration_list(SymbolInfo* s){

	cout << "declaration_list" << endl;
	if(s -> getChildren().size() == 1 || s -> getChildren().size() == 4){
		
		cout << "Found ID : " << s -> getChild(0) -> getName() << endl;
	
		cout << "End of List" << endl;
	
	}
	
	if(s -> getChildren().size() == 3 || s -> getChildren().size() == 6){
	
		cout << "Found ID : " << s -> getChild(2) -> getName() << endl;
		
		declaration_list(s -> getChild(0));
	}

	

}


void embed_func_def(SymbolInfo* s){

	cout << "embed_func_def" << endl;
	bool t = tab.INSERT(s -> getChild(1),tabout);
	
	tab . EnterScope();
	//if(s -> getChildren().size() == 5 ){
	//	parameter_list(s -> getChild(3) );
	//}
	
	ParamOffset = 4 + 2*s -> getParamList().size();
	parameter_list(s);
	
	
	StackOffset = 0;
	
	fprintf(code,"%s PROC\n",s -> getChild(1) -> getName().c_str() );


}

void parameter_list(SymbolInfo* s){
	
	for(int j = 0; j< s -> getParamList().size() ; j++){
			
		//s -> getChild(i) -> get(j) -> getName();
		//if( s -> getChild(i) -> getID(j) -> getIsArray() == false) PRINT_dec_list(s -> getChild(i) -> getID(j));
		//else PRINT_dec_list(s -> getChild(i) -> getID(j) , s -> getChild(i) -> getID(j) -> getArrSize() );
		PRINT_param_list(s  -> getParam(j));		 
			
	}

}
void compound_statement(SymbolInfo* s){

	cout << "compound_statement" << endl;
	
	statements(s -> getChild(1) ) ;
	tab . PRINT_A(tabout);
	tab . ExitScope();

}

void statements(SymbolInfo* s){
	
	for(int i=0;i<s -> getChildren().size() ;i++){
	
		if( s -> getChild(i) -> getSymbolName() == "statements") {
		
			cout << "statements" << endl;
			//statement(s -> getChild(1) );
			statements(s -> getChild(i));
			
			
		}
		
		else if( s -> getChild(i) -> getSymbolName() == "statement"){
		
			cout << "statement" << endl;
			statement(s -> getChild(i));
		}
		
		
		
	}
}

void statement(SymbolInfo* s,bool fromElse){

	cout << s -> getChild(0) -> getSymbolName();

	for(int i=0;i<s -> getChildren().size() ;i++){
	
		if( s -> getChild(i) -> getSymbolName() == "var_declaration") {
		
			cout << "Variable declaration" << endl;
			
			var_declaration(s -> getChild(i));
			
		}
		
		else if( s -> getChild(i) -> getSymbolName() == "compound_statement") {
		
			cout << "Compound Statement" << endl;
			
			tab.EnterScope();
			compound_statement(s -> getChild(i));
			
		}
		
		else if( s -> getChild(i) -> getSymbolName() == "expression_statement") {
		
			cout << "Expression Statement" << endl;
			
			expression_statement(s -> getChild(i));
			lbl++;
			
		}
		
		else if( s -> getChild(i) -> getSymbolName() == "PRINTLN") {
		
			cout << "Print Statement" << endl;
			
			print_statement(s -> getChild(i+2));
			lbl++;
			
		}
		
		else if( s -> getChild(i) -> getSymbolName() == "IF" && s -> getChildren().size() == 7) {
		
			cout << "IF ELSE Statement" << endl;
			
			//elifjumpflag = true;
			//expression_statement(s -> getChild(1));
			//jump_statement();
			
			
			//lbl++;
			
			if(fromElse == false) fprintf(code, "L%d:\n", lbl );
			 
			
			expression(s -> getChild(2) ) ;
			fprintf(code, "\tCMP AX,0\n" );
			fprintf(code, "\tJE B%d\n", blocklbl );
			block.push_back(blocklbl);
			lbl++;
			blocklbl++;
			
			if(fromElse == false) endlbl++;
			
			statement(s -> getChild(4));
			//lbl++;
			fprintf(code, "\tJMP E%d\n", endlbl );
			last.push_back(endlbl);
			
			if( s -> getChild(6) -> getChild(0) -> getName()  != "IF") {
			
				//end.push_back(endlbl);
				//endlbl++;
			
			}
			
			int x = block[block.size() - 1];
			block.pop_back();
			fprintf(code, "B%d:\n", x );
			//blocklbl++;
			
			statement(s -> getChild(6),true);
			//lbl++;
			
			int y = last[last.size() - 1];
			last.pop_back();
			if(fromElse == false)fprintf(code, "E%d:\n", y );
			
		}
		
		else if( s -> getChild(i) -> getSymbolName() == "IF" && s -> getChildren().size() == 5) {
		
			cout << "IF Statement" << endl;
			
			//elifjumpflag = true;
			//expression_statement(s -> getChild(1));
			//jump_statement();
			
			
			//lbl++;
			if(fromElse == false) fprintf(code, "L%d:\n", lbl );
			
			expression(s -> getChild(2) ) ;
			
			lbl++;
			fprintf(code, "\tCMP AX,0\n" );
			if(fromElse == false) endlbl++;
			fprintf(code, "\tJE E%d\n", endlbl );
			last.push_back(endlbl);
			//endlbl++;
			
			statement(s -> getChild(4));
			
			int y = last[last.size() - 1];
			last.pop_back();
			fprintf(code, "E%d:\n", y );
			
			
		}
		
		else if( s -> getChild(i) -> getSymbolName() == "FOR" ) {
		
			cout << "FOR Statement" << endl;
			
			
			
			expression_statement(s -> getChild(2) ) ;
			
			//cout << "ashchhi" ;
			
			lbl++;
			
			looplabel.push_back(lbl );
			
			expression_statement(s -> getChild(3) ) ;
			
			lbl++;
			
			fprintf(code, "\tCMP AX,0\n" );
			if(fromElse == false) endlbl++;
			fprintf(code, "\tJE E%d\n", endlbl );
			last.push_back(endlbl);
			
			
			statement(s -> getChild(6));
			
			expression(s -> getChild(4) );
			
			int y = last[last.size() - 1];
			last.pop_back();
			
			int x = looplabel[looplabel.size() - 1];
			looplabel.pop_back();
			
			fprintf(code, "\tJNE L%d\n", x );
			fprintf(code, "E%d:\n", y );
			break;
			
			
		}
		
		else if( s -> getChild(i) -> getSymbolName() == "WHILE" ) {
		
			cout << "WHILE Statement" << endl;
			
			
			
			
			
			looplabel.push_back(lbl );
			
			//expression_statement(s -> getChild(4) ) ;
			
			fprintf(code, "L%d: \n", lbl);
			expression(s -> getChild(2) ) ;
			
			//lbl++;
			
			lbl++;
			
			fprintf(code, "\tCMP AX,0\n" );
			if(fromElse == false) endlbl++;
			fprintf(code, "\tJE E%d\n", endlbl );
			last.push_back(endlbl);
			
			
			statement(s -> getChild(4));
			
			
			
			int y = last[last.size() - 1];
			last.pop_back();
			
			int x = looplabel[looplabel.size() - 1];
			looplabel.pop_back();
			
			fprintf(code, "\tJNE L%d\n", x );
			fprintf(code, "E%d:\n", y );
			
			
		}
		
		else if( s -> getChild(i) -> getSymbolName() == "RETURN"){
		
			cout << "RETURN Statement" << endl;
			
			expression(s -> getChild(1) );
			fprintf(code,"\tJMP R%d\n",retlbl);
			
		
		}
		
		
		
	}

}

void expression_statement(SymbolInfo* s){

	if(s -> getChildren().size() == 2 ) {
		cout << "Expression " << endl;
		fprintf(code, "L%d:\n", lbl );
		expression( s -> getChild(0) );
	}

}

void expression(SymbolInfo* s){

	if(s -> getChild(0) -> getSymbolName()== "logic_expression"){
	
		cout << "Logic_Expression " << endl;
		//fprintf(code, "L%d:\n", lbl );
		logic_expression(s -> getChild(0) );
				
	}
	
	else if(s -> getChild(0) -> getSymbolName() == "variable"){
	
		//logic_expression(s -> getChild(0);
		cout << "Variable " << endl;
		SymbolInfo* t = variable(s -> getChild(0)) ;
		
		
		if(t -> getIsGlobal() == true) {
		
			//fprintf(code, "L%d:\n", lbl );
			logic_expression(s -> getChild(2) );
			fprintf(code,"\tMOV %s, AX\n\tPUSH AX\n\tPOP AX\n" , t -> getName().c_str() );
			 
		}
		
			
		else {
			//fprintf(code, "L%d:\n", lbl );
			logic_expression(s -> getChild(2) );
			
			if(t -> getIsParam()  == true ) fprintf(code,"\tMOV [BP + %d], AX\n\tPUSH AX\n\tPOP AX\n",  t -> getOffset()  );
			else if(s-> getChild(0) -> getChildren().size()  == 1 ) fprintf(code,"\tMOV [BP - %d], AX\n\tPUSH AX\n\tPOP AX\n",  t -> getOffset()  );
			
			
			else fprintf(code,"\tMOV [BP - %d], AX\n\tPUSH AX\n\tPOP AX\n",  t -> getOffset() +2 * stoi( s-> getChild(0) -> getChild(2) -> getName() ) );
			
			
		}	
		
		//lbl++;	
	}

}

void print_statement(SymbolInfo* s){

	
	SymbolInfo* t = tab. LOOKUP(s -> getName() );
	
	fprintf(code, "L%d:\n", lbl );
	
	r_var_print(t);
	
	fprintf(code,"\tCALL print_output\n");
	fprintf(code,"\tCALL ENDL\n");
	
	//MOV AX, i
	//CALL print_output
	//CALL new_line

}

SymbolInfo* variable(SymbolInfo* s){

	//cout << "Found" << endl;
	SymbolInfo* t = tab. LOOKUP(s -> getChild(0) -> getName() );
	//cout << "Found" << endl;
	return t;
}



void logic_expression(SymbolInfo* s){

	if(s-> getChildren().size() == 1){
	
		rel_expression(s-> getChild(0));
	}
	
	else if(s-> getChildren().size() == 3){
	
		//bool tempelifjumpflag = elifjumpflag;
		//elifjumpflag = false;
		
		rel_expression(s-> getChild(0));
		fprintf(code,"\tPUSH AX\n" );
		rel_expression(s-> getChild(2));
		//relflag = false;
		//elifjumpflag = tempelifjumpflag;
		fprintf(code,"\tPOP DX\n" );
		
		fprintf(code,"\tCMP AX,0\n" );
		if( s -> getChild(1) -> getName() == "&&" )fprintf(code,"\tJE L%d\n", lbl+2 );
		if( s -> getChild(1) -> getName() == "||" )fprintf(code,"\tJNE L%d\n", lbl+1 );
		
		//tempelifjumpflag = elifjumpflag;
		//elifjumpflag = false;
		
		//if(relflag == false) lbl = lbl +3;
		//elifjumpflag = tempelifjumpflag;
		//relflag = false;
		fprintf(code,"\tCMP DX,0\n" );
		if( s -> getChild(1) -> getName() == "&&" )fprintf(code,"\tJE L%d\n", lbl+2 );
		if( s -> getChild(1) -> getName() == "||" )fprintf(code,"\tJE L%d\n", lbl+2 );
		/*if(elifjumpflag == false)*/ jump_statement(s-> getChild(1),s-> getChild(1));
		
	}

}

void rel_expression(SymbolInfo* s){
	
	if(s-> getChildren().size() == 1){
	
		simple_expression(s-> getChild(0));
		if( arithflag == true) fprintf(code,"\tMOV AX, BX\n" );
		arithflag = false;
		if(mulflag == true)fprintf(code,"\tMOV AX,CX\n");
		mulflag = false;
	}
	
	else if(s-> getChildren().size() == 3){
	
		//relflag = true;
		simple_expression(s-> getChild(0));
		fprintf(code,"\tPUSH AX\n" );
		simple_expression(s-> getChild(2));
		if( arithflag == true) fprintf(code,"\tMOV AX, BX\n" );
		arithflag = false;
		if(mulflag == true)fprintf(code,"\tMOV AX,CX\n");
		mulflag = false;
		fprintf(code,"\tPOP DX\n" );
		fprintf(code,"\tCMP DX,AX\n" );
		fprintf(code,"\t%s L%d\n", relmap[s-> getChild(1) -> getName()].c_str() , lbl+ 1);
		fprintf(code,"\tJMP L%d\n", lbl+2 );
		//string tmp = s-> getChild(1) -> getName().c_str() ;s-> getChild(1) -> getName()
		/*if(elifjumpflag == false)*/ jump_statement(s-> getChild(1), s-> getChild(1));
		
		
	}
	
}

void simple_expression(SymbolInfo* s){

	//if( s -> getChildren().size() == 3) {
		
		
		
		//if(flag == false) term(s -> getChild(2));
		
		//if(/*s -> getChild(1) -> getName() == "+" && */flag == true) {
			
		//	term(s -> getChild(2));
		//	fprintf(code,"\t%s AX, DX\n",addop.c_str() );
			
		//}
		
		//fprintf(code,"\tMOV DX, AX\n" );
		
		//(Not NECESSARY) simple_expression(s -> getChild(0);
		
		//if(s -> getChild(1) -> getName() == "+") addop = "ADD";
		
		//else if(s -> getChild(1) -> getName() == "-") addop = "SUB";
		
		//flag = true;
		
		//simple_expression(s -> getChild(0));
		
			
		
	//}
	
	if( s -> getChildren().size() == 3) {
		
		
		seflag = true ;
		
		arithflag = true;
		
		simple_expression(s -> getChild(0));
		
		if(s -> getChild(1) -> getName() == "+") addop = "ADD";
		
		else if(s -> getChild(1) -> getName() == "-") addop = "SUB";
		
		//if(/*s -> getChild(1) -> getName() == "+" && */flag == true) {
			
			
		term(s -> getChild(2));
		if(mulflag == true)fprintf(code,"\tMOV AX,CX\n");
		mulflag = false;
		fprintf(code,"\t%s BX, AX\n",addop.c_str() );
			
		//}
		
		//if(flag == false) term(s -> getChild(2));
		
		
		
		
		
		//simple_expression(s -> getChild(0);
		
		
		
		//flag = true;
		
		
		
			
		
	}
	
	else if( s -> getChildren().size() == 1) {
	
		//if(tflag == true)fprintf(code,"\tPUSH BX\n");
		term( s-> getChild(0)) ;
		if(mulflag == true)fprintf(code,"\tMOV AX,CX\n");
		mulflag = false;
		if(seflag == true) fprintf(code,"\tMOV BX, AX\n" );
		seflag = false;
	
	}
	
	//else if( s -> getChildren().size() == 1) {
		
		//cout << flag << endl;
		//if(flag == false) term(s -> getChild(0));
		//else{
			
		//	term(s -> getChild(0));
		//	fprintf(code,"\t%s AX, DX\n", addop.c_str() );
		
		//}
		//flag = false;
			
	//}
	
	//for(int i=0;i<s -> getChildren().size() ;i++){
	
	//	if( s -> getChild(i) -> getSymbolName() == "term") {
		
	//		term(s -> getChild(i));
			
	//	}
		
	//	else if( s -> getChild(i) -> getSymbolName() == "simple_expression") {
		
			
	//	}
		
		
		
	//}
}

void term(SymbolInfo* s){

	//for(int i=0;i<s -> getChildren().size() ;i++){
	
	//	if( s -> getChild(i) -> getSymbolName() == "unary_expression") {
		
	//		cout << "term " << endl;
	//		unary_expression(s -> getChild(i));
			
	//	}
		
	//}
	
	if( s -> getChildren().size() == 3) {
		
		
		tflag = true;
		
		mulflag = true;
		
		term(s -> getChild(0));
		
		if(s -> getChild(1) -> getName() == "*") mulop = "MUL";
		
		else if(s -> getChild(1) -> getName() == "/") mulop = "DIV";
		
		else if(s -> getChild(1) -> getName() == "%") mulop = "DIV";
		
		//if(/*s -> getChild(1) -> getName() == "+" && */flag == true) {
			
			
		unary_expression(s -> getChild(2));
		
		if(mulop == "DIV" ) {
		
			fprintf(code,"\tPUSH CX\n\tPUSH AX\n\tPOP CX\n\tPOP AX\n" );
		
		}
		fprintf(code,"\tCWD\n\t%s CX\n",mulop.c_str() );
		
		if(s -> getChild(1) -> getName() == "%"){
		
			fprintf(code,"\tPUSH DX\n");
		
		}
		
		else fprintf(code,"\tPUSH AX\n");
		
		fprintf(code,"\tPOP CX\n");
			
		//}
		
		//if(flag == false) term(s -> getChild(2));
		
		
		
		
		
		//simple_expression(s -> getChild(0);
		
		
		
		//flag = true;
		
		
		
			
		
	}
	
	else if( s -> getChildren().size() == 1) {
	
		unary_expression( s-> getChild(0)) ;
		if(tflag == true) fprintf(code,"\tMOV CX, AX\n" );
		tflag = false;
	
	}
}

void unary_expression(SymbolInfo* s){
	
	if(s -> getChild(0) -> getSymbolName() == "factor"){
	
		cout << "unary_expression " << endl;
		factor(s -> getChild(0));
	
	}
	
	else if(s -> getChild(0) -> getName() == "-"){
	
		cout << "unary_expression " << endl;
		negA = !negA;
		//factor(s -> getChild(0));
		unary_expression(s -> getChild(1));
	
	}
	
	else if(s -> getChild(0) -> getName() == "!"){
	
		cout << "unary_expression " << endl;
		notA = !notA;
		//factor(s -> getChild(0));
		unary_expression(s -> getChild(1));
	
	}
}

void factor(SymbolInfo* s){

	for(int i=0;i<s -> getChildren().size() ;i++){
	
		if( s -> getChild(i) -> getSymbolName() == "INT_LIT") {
		
			cout << "Factor " << endl;
			fprintf(code,"\tMOV AX, %s\n", s -> getChild(i) -> getName().c_str());
			//else fprintf(code,"\tMOV AX, -%s\n", s -> getChild(i) -> getName().c_str());
			if (negA == true) fprintf(code,"\tNEG AX\n");
			negA = false;
			if (notA == true) fprintf(code,"\tNOT AX\n");
			notA = false;
			
		}
		
		if( s -> getChild(i) -> getSymbolName() == "variable") {
		
			cout << "Factor " << endl;
			if(s -> getChild(i) -> getChildren() .size() == 4)  r_var_print(variable(s -> getChild(i) ), stoi(s -> getChild(i) -> getChild(2) -> getName() ) );
			else r_var_print(variable(s -> getChild(i) ) );
			if(negA == true) fprintf(code,"\tNEG AX\n");
			negA = false;
			if (notA == true) fprintf(code,"\tNOT AX\n");
			notA = false;
			//if(s -> getChild(i) -> getChildren() .size() == 4) l_var_print(variable(s -> getChild(i) ), stoi(s -> getChild(i) -> getChild(2) -> getName() ) );
			//else l_var_print(variable(s -> getChild(i) ) );
		}
		
		if( s -> getChild(i) -> getSymbolName() == "ID") {
			
			cout << "Factor : func Call " << endl;
			if(mulflag == true ) fprintf(code,"\tPUSH CX\n");
			if(arithflag == true )fprintf(code,"\tPUSH BX\n");
			tempmulflag.push_back(mulflag);//array banano laagbey
			mulflag = false;
			temparithflag.push_back(arithflag);//
			arithflag = false;
			tempnotA.push_back(notA);//
			notA = false;
			tempnegA.push_back(negA);//
			negA = false;
			
			
			
			cout << s -> getChild(2) -> getDecList().size()<< endl;
			//expression( s -> getChild(i) );
			for( int i=0 ; i< s -> getChild(2) -> getDecList().size() ;i++) {
			
				temptflag.push_back(tflag);//array banano laagbey
				tflag = false;
				tempseflag.push_back(seflag);//
				seflag = false;
				logic_expression(s -> getChild(2) -> getID(i) );
				fprintf(code,"\tPUSH AX\n");
				seflag = tempmulflag[tempseflag.size() -1] ;
				tflag = temparithflag[temptflag.size() -1];
				tempseflag.pop_back();
				temptflag.pop_back();
				
			
			}
			fprintf(code,"\tCALL %s\n", s -> getChild(0) -> getName().c_str() );
			mulflag = tempmulflag[tempmulflag.size() -1] ;
			arithflag = temparithflag[temparithflag.size() -1];
			notA = tempnotA[tempnotA.size() -1];
			negA = tempnegA[tempnegA.size() -1];
			tempmulflag.pop_back();
			temparithflag.pop_back();
			tempnotA.pop_back();
			tempnegA.pop_back();
			if(arithflag == true )fprintf(code,"\tPOP BX\n");
			if(mulflag == true )fprintf(code,"\tPOP CX\n");
			if(negA == true) fprintf(code,"\tNEG AX\n");
			if (notA == true) fprintf(code,"\tNOT AX\n");
			
		}
		
		if( s -> getChild(i) -> getSymbolName() == "expression") {
			
			cout << "Factor " << endl;
			if(mulflag == true ) fprintf(code,"\tPUSH CX\n");
			if(arithflag == true )fprintf(code,"\tPUSH BX\n");
			tempmulflag.push_back(mulflag);//array banano laagbey
			mulflag = false;
			temparithflag.push_back(arithflag);//
			arithflag = false;
			tempnotA.push_back(notA);//
			notA = false;
			tempnegA.push_back(negA);//
			negA = false;
			expression( s -> getChild(i) );
			mulflag = tempmulflag[tempmulflag.size() -1] ;
			arithflag = temparithflag[temparithflag.size() -1];
			notA = tempnotA[tempnotA.size() -1];
			negA = tempnegA[tempnegA.size() -1];
			tempmulflag.pop_back();
			temparithflag.pop_back();
			tempnotA.pop_back();
			tempnegA.pop_back();
			if(arithflag == true )fprintf(code,"\tPOP BX\n");
			if(mulflag == true )fprintf(code,"\tPOP CX\n");
			if(negA == true) fprintf(code,"\tNEG AX\n");
			if (notA == true) fprintf(code,"\tNOT AX\n");
			
		}
		
		if( s -> getChild(i) -> getSymbolName() == "INC") {
			
			cout << "Factor " << endl;
			fprintf(code,"\tINC AX\n");
			if(s -> getChild(0) -> getChildren() .size() == 4) l_var_print(variable(s -> getChild(0) ), stoi(s -> getChild(0) -> getChild(2) -> getName() ) );
			else l_var_print(variable(s -> getChild(0) ) );
			
			
			
		}
		
		if( s -> getChild(i) -> getSymbolName() == "DEC") {
			
			cout << "Factor " << endl;
			fprintf(code,"\tDEC AX\n");
			if(s -> getChild(0) -> getChildren() .size() == 4) l_var_print(variable(s -> getChild(0) ), stoi(s -> getChild(0) -> getChild(2) -> getName() ) );
			else l_var_print(variable(s -> getChild(0) ) );
			
		}
	}
	
	

}



