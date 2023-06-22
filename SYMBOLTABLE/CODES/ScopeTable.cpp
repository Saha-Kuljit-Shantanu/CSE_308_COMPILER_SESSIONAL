#include<iostream>
#include<fstream>
#include "SymbolInfo.cpp"


using namespace std;

ofstream fout ("output.txt");

static unsigned long long int SDBM_Hash(string str) {
	unsigned long long int hash = 0;
	unsigned long long int i = 0;
	unsigned long long int len = str.length();

	for (i = 0; i < len; i++)
	{
		hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
	}

	return hash;
}

class ScopeTable{

private:

    SymbolInfo ** scp ;

    long long int num_Buckets;
    long long int table_ID;


    long long int search_help( string name, SymbolInfo* head ){

        long long int tmp = 1;

        SymbolInfo* curr = head;

        if(head == NULL) return -1;

        if (head -> getName() == name) return tmp;

        while(curr -> getName() != name ){

            curr = curr -> getNext();
            tmp++;
            if( curr == NULL ) return -1;

        }

        return tmp;


    }



    SymbolInfo* FETCH_DATA(long long int k, SymbolInfo* head){

        SymbolInfo * s = head;

        for(long long int i= 0; i<k ; i++){

            s = s -> getNext();

        }

        return s;

    }






public:

    ScopeTable* parent_scope;
    
    ScopeTable(long long int table_ID = 0,long long int n = 0,ScopeTable* pt = NULL){

        this -> table_ID = table_ID;
        if( n>0 ){

                scp = new SymbolInfo*[n];
                for(long long int i=0;i<n;i++){

                    scp[i] = new SymbolInfo ;
                }
        }

        num_Buckets = n;
        parent_scope = pt ;
        fout << "        ScopeTable# "<< table_ID <<" created" << endl;

    }

    ~ScopeTable(){

        fout << "        ScopeTable# "<< table_ID <<" removed" << endl;

        for(long long int i=0;i<num_Buckets;i++){

            delete scp[i]  ;
        }

        delete[] scp ;


    }

     SymbolInfo* LOOKUP(string name){

        long long int h = SDBM_Hash(name) % num_Buckets;


        long long int a = search_help(name, scp[h] -> getNext() );

        if( a == -1) {

            //cout << name << " not found in any of the ScopeTables" << endl;
            return NULL;

        }

        else{

            fout << "        '" << name << "' found in ScopeTable# " << table_ID << " at position " << h+1 << ", " << a << endl;
            return FETCH_DATA(a,scp[h]);

        }



    }



    bool INSERT(string name, string type){

        long long int h = SDBM_Hash(name) % num_Buckets;

        SymbolInfo* tmp,*t;

        long long int ltmp = 1;


        long long int res = search_help(name,scp[h] -> getNext());

        if( res != -1 ){

            fout << "        '" << name << "' already exists in the current ScopeTable" << endl;
            return false;

        }

        ///if(scp[h] -> getNext() == NULL ) scp[h] -> setNext ( new SymbolInfo (name,type) );
        ///scp[h] = scp[h] -> getNext();

        tmp = scp[h];

        while(tmp -> getNext() != NULL ){

            tmp = tmp -> getNext();
            ltmp ++;

        }


        tmp -> setNext(new SymbolInfo (name,type));


        fout << "        Inserted in ScopeTable# " << table_ID <<" at position " << h+1 << ", " <<ltmp << endl;
      
        return true;

    }


    bool DELETE(string name){

        long long int h = SDBM_Hash(name) % num_Buckets;

        long long int a = search_help(name,scp[h] -> getNext());

        if( a == -1) {

            fout << "        Not found in the current ScopeTable" << endl;
            return false;

        }



        else{

            SymbolInfo* tmp ;
            if(a != 1) tmp = FETCH_DATA(a-1, scp[h] );
            else tmp = scp[h];

            tmp -> setNext(FETCH_DATA(a+1, scp[h] ));
            tmp = FETCH_DATA(a, scp[h]);
            delete tmp;
            fout << "        Deleted '" << name << "' from ScopeTable# " << table_ID << " at position " << h+1 << ", " << a << endl;
            return true;

        }

    }

    void PRINT(){

        fout << "        ScopeTable# " << table_ID << endl;
    
        for(long long int i = 0; i< num_Buckets; i++){

            fout << "        " <<i+1 << "--> " ;
            SymbolInfo* s = scp[i] ;
            while(s -> getNext() != NULL){

                fout << "<" << s -> getNext() -> getName() << "," << s -> getNext() -> getType() << "> ";
                s = s -> getNext();

            }

            fout << endl;

        }

    //
    

    }


};

/*int main(){

    ScopeTable p(0,7);

    cout << p.INSERT("foo","function");
    cout << p.INSERT("cuba", "variable");
    cout << p.INSERT("<=","expression");
    cout << p.INSERT("123", "number");
    cout << p.INSERT("clip","variable");
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
