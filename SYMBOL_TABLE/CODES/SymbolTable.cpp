#include<iostream>

#include "ScopeTable.cpp"

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

            fout << "        ScopeTable# 1 cannot be removed" << endl ;
            return;
        }

        delete curr;

        curr = ltemp;

        cnt --;

    }

    bool INSERT(string name, string type){

        return curr -> INSERT(name,type);


    }

    SymbolInfo* LOOKUP(string name){

        ScopeTable* ltemp = curr ;
        SymbolInfo* SI;
        while( ltemp != nil){

            SI = ltemp -> LOOKUP(name);
            if(SI != NULL) return SI;
            else ltemp = ltemp -> parent_scope;

        }
   
        fout << "        '" << name << "' not found in any of the ScopeTables" << endl;
        return SI;

    }

    bool DELETE(string name){

        return curr -> DELETE(name);


    }



    void PRINT_C(){

        curr -> PRINT();

    }

    void PRINT_A(){

        ScopeTable* ltemp = curr ;
        while( ltemp != nil){

            ltemp -> PRINT();
            ltemp = ltemp -> parent_scope;

        }


    }



};


/*int main(){

    SymbolTable p(7);

    cout << p.INSERT("foo","function");
    cout << p.INSERT("cuba", "variable");
    cout << p.INSERT("<=","expression");
    cout << p.INSERT("123", "number");
    cout << p.INSERT("clip","variable");
    p.EnterScope();
    cout << p.INSERT("x","function");
    cout << p.INSERT("y","function");
    cout << p.INSERT(",","function");
    cout << p.INSERT("x","variable");

    p.PRINT();

    cout << p.DELETE("x");
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
