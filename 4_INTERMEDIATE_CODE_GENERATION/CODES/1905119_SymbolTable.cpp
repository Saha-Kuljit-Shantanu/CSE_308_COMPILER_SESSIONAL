#include<iostream>

#include "1905119_ScopeTable.cpp"

#include<fstream>

using namespace std;

class SymbolTable{

private :

    ScopeTable* curr;
    ScopeTable* nil;
    long long int cnt ;
    long long int genID ;
    long long int bucket_size;


    void init(long long int n){

        curr = new ScopeTable(1,n,nil);
        genID = 1;
        cnt = 0;
        bucket_size = n;


    }

    void removeAll(){

        while(curr != nil){

            ScopeTable* ltemp = curr -> parent_scope;
            delete curr;
            curr = ltemp;
        }


    }

public :

    SymbolTable(long long int n){

        init(n);

    }

    ~SymbolTable(){

        removeAll();

    }

    void CLEAR(){

        removeAll();

    }

    void EnterScope(){

        genID++;
        curr = new ScopeTable(genID,bucket_size,curr);

        cnt++;

    }

    void ExitScope(){

        ScopeTable* ltemp = curr -> parent_scope;

        if(ltemp == nil) {

            curr -> fout << "        ScopeTable# 1 cannot be removed" << endl ;
            return;
        }

        delete curr;

        curr = ltemp;

        cnt --;

    }

    bool INSERT(string name, string type,FILE* fp, bool isFunc = false, bool isArr = false,bool isDef = false,bool isGlobal = false,int len = 0,int offset = 0){
cout << name<<isGlobal<<len<<offset;
        return curr -> INSERT(name,type,fp,isFunc,isArr,isDef,isGlobal,len,offset);


    }
    
    
    bool INSERT(SymbolInfo* s,FILE* fp){
    
    	return curr -> INSERT(s,fp);
    
    }
   

    SymbolInfo* LOOKUP(string name){

        ScopeTable* ltemp = curr ;
        SymbolInfo* SI = new SymbolInfo();
        while( ltemp != nil){

            SI = ltemp -> LOOKUP(name);
            if(SI -> getName() != "") return SI;
            else ltemp = ltemp -> parent_scope;

        }
   
        curr -> fout << "        '" << name << "' not found in any of the ScopeTables" << endl;
        return SI;

    }

    bool DELETE(string name){

        return curr -> DELETE(name);


    }



    void PRINT_C(FILE* fp){

        curr -> PRINT(fp);

    }

    void PRINT_A(FILE* fp){

        ScopeTable* ltemp = curr ;
        while( ltemp != nil){

            ltemp -> PRINT(fp);
            ltemp = ltemp -> parent_scope;

        }


    }
    
    int getCNT(){
    
    	return cnt;
    
    }



};


/*int main(){

    SymbolTable p(7);
    
    FILE* fp = fopen("asp.txt","w");
    
    cout << "Created file" ;

    cout << p.INSERT("foo","function",fp);
    cout << p.INSERT("cuba", "variable",fp);
    cout << p.INSERT("<=","expression",fp);
    cout << p.INSERT("123", "number",fp);
    cout << p.INSERT("clip","variable",fp);
    p.EnterScope();
    cout << p.INSERT("x","function",fp);
    cout << p.INSERT("y","function",fp);
    cout << p.INSERT(",","function",fp);
    cout << p.INSERT("x","variable",fp);
    cout << p.INSERT("z","variable",fp);

    p.PRINT_A(fp);

  /*  cout << p.DELETE("x");
    cout << p.DELETE("y");

    p.PRINT();

    cout << p.INSERT("y","function");
    cout << p.INSERT(",","function");
    cout << p.INSERT("x","variable");

    p.PRINT();

    cout << p.DELETE("x");
    cout << p.DELETE("z");

    p.PRINT();



}*/
