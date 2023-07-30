#include<iostream>
#include<vector>


using namespace std;

class SymbolInfo{

private:

    string name;
    string symbolName;
    string type;
    SymbolInfo* next;
    vector<SymbolInfo*> dec_list ;
    vector<SymbolInfo*> param_list ;
    string type_spec;
    bool isFunction = false ,isDefinition = false ,isArray = false;
    int size = 0;
    int arrsize = 0;
    int paramsize = 0;
    bool isConst = false;
    
    int stl;
    int endl;
    bool isLeaf = false;
    string rule;
    int offset = 0;
    int len = 0;
    bool isGlobal = false;
    bool isParam = false;
    
    
    vector<SymbolInfo*> children;

public :

    string code;
    
    SymbolInfo(string name= "" , string type= "",SymbolInfo* next = NULL, string type_spec = ""){

        this -> name = name;
        this -> type = type;
        this -> next = next;
        
        this -> type_spec = type_spec;
        //this -> dec_list.clear();
    	//if(this -> dec_list.empty() ) this -> dec_list.push_back(new Symbolinfo());
        
        this -> isFunction = false ;
        this -> isDefinition = false ;
        this -> isArray = false;
        this -> isConst = false;
        
        size = 0;
    	arrsize = 0;
    	paramsize = 0;

    }
    
    SymbolInfo(SymbolInfo* s){
    
    	
    	this -> name = s -> name;
    	this -> type = s -> type;
        this -> next = s -> next;
        this -> type_spec = s -> type_spec;
    	if(this -> dec_list.empty() ) this -> dec_list = s -> dec_list;
    	if(this -> param_list.empty() ) this -> param_list = s -> param_list;
        this -> isFunction = s -> isFunction;
        this -> isArray = s -> isArray;
        this -> isDefinition = s -> isDefinition;
        this -> isConst = s -> isConst;
        this -> isGlobal = s -> isGlobal;
        this -> offset = s -> offset;
        this -> len = s -> len;
        
        size = s ->size;
    	arrsize = s -> arrsize;
    	paramsize = s -> paramsize;
    
    }

    void setName(string name){

        this -> name = name ;
    }
    
    void setSymbolName(string symbolName){

        this -> symbolName = symbolName ;
    }

    void setType(string type){

        this -> type = type ;
    }

    void setNext(SymbolInfo* next){

        this -> next = next ;
    }

    void push_declist(SymbolInfo* k){
    
    	this -> dec_list.push_back(k);
    	size++;
    }
    
     void push_paramlist(SymbolInfo* k){
    
    	this -> param_list.push_back(k);
    	k -> setIsParam( true );
    	paramsize++;
    
    }
    
    void setTypeSpec(string k){
    
    	this -> type_spec = k;
    }
    
    void setIsFunction(bool t = false){
    
    	this -> isFunction = t;
    }
    
    void setIsDefinition(bool t = false){
    
    	this -> isDefinition = t;
    }
    
    void setIsArray(bool t = false,int sz = 0){
    
    	this -> isArray = t;
    	if(t == true) arrsize = sz;
  
    }
    
    void setIsConst(bool t = false){
    
    	this -> isConst = t;
    
    }
    
    void setIsParam(bool t = false){
    
    	this -> isParam = t;
    
    }
    
    string getName(){

        return name ;

    }
    
    string getSymbolName(){

        return symbolName ;

    }

    string getType(){

        return type;

    }

    SymbolInfo* getNext(){

        return next ;
    }
    
    string getTypeSpec(){
    
    	return this -> type_spec ;
    }
    
    vector<SymbolInfo*> getDecList(){
    
    	return this -> dec_list;
    
    }
    
    vector<SymbolInfo*> getParamList(){
    
    	return this -> param_list;
    
    }
    
    SymbolInfo* getID(int k){
    
    	return this -> dec_list[k];
    
    }
    
    SymbolInfo* getParam(int k){
    
    	return this -> param_list[k];
    
    }
    
    bool getIsFunction(){
    
    	return this -> isFunction;
    }
    
    bool getIsDefinition(){
    
    	return this -> isDefinition ;
    }
    
    bool getIsArray(){
    
    	return this -> isArray;
    }
    
    bool getIsConst(){
    
    	return this -> isConst;
    
    }
    
    bool getIsParam(){
    	
    	return this -> isParam;
    }
    
    int getSize(){
    
    	return this -> size;
    }
    
    int getArrSize(){
    
    	return this -> arrsize;
    }

    bool operator == ( SymbolInfo Q){

        if(name == Q. getName()){

            return true;

        }

        else return false;
    }

    bool operator != (SymbolInfo Q){

        if(this -> name == Q. getName()){

            return false;

        }

        else return true;
    }
    
    /*void Print(){
    
    	cout << " <" << name ;
    	if(isArray == true) cout << "[" << arrsize << "]" ; 
    	cout << "," << type_spec << ">" << endl;
    	
    
    }*/
    
    void setStartLine(int ln){
    	
    	this -> stl = ln;
    }
    
    void setEndLine(int ln){
    
    	this -> endl = ln;
    
    }
    
    void setRule(string rule){
    	
    	this -> rule = rule;
    }
    
    void setIsLeaf(bool isLeaf){
    
    	this -> isLeaf = isLeaf;
    
    }
    
    int getStartLine(){
    	
    	return this -> stl;
    }
    
    int getEndLine(){
    
    	return this -> endl;
    
    }
    
    string getRule(){
    	
    	return this -> rule;
    }
    
    bool getIsLeaf(){
    
    	return this -> isLeaf ;
    
    }
    
    
    void addChild(SymbolInfo* child){
    
    	this -> children . push_back(child);
    
    }
    
    void setOffset( int offset){
    
    	this -> offset = offset;
    
    }
    
    int getOffset(){
    
    	return this -> offset;
    
    }
    
    vector<SymbolInfo*> getChildren (){
    	
    	return this -> children;
    }
    
    SymbolInfo* getChild (int i){
    	
    	return this -> children[i];
    }
    
    void setIsGlobal(bool isGlobal){
    
    	this -> isGlobal = isGlobal;
    
    }
    
    bool getIsGlobal(){
    
    	return this -> isGlobal;
    
    }
    
    void setLen(int len){
    
    	this -> len = len;
    
    }
    
    int getLen(){
    	
    	return this -> len;
    }
    
    
    

};
