#include<iostream>



using namespace std;

class SymbolInfo{

private:

    string name;
    string type;
    SymbolInfo* next;

public :

    SymbolInfo(string name= "" , string type= "",SymbolInfo* next = NULL){

        this -> name = name;
        this -> type = type;
        this -> next = next;

    }

    void setName(string name){

        this -> name = name ;
    }

    void setType(string type){

        this -> type = type ;
    }

    void setNext(SymbolInfo* next){

        this -> next = next ;
    }

    string getName(){

        return name ;

    }

    string getType(){

        return type;

    }

    SymbolInfo* getNext(){

        return next ;
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

};
