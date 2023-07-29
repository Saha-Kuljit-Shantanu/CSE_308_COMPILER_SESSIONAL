#include<iostream>
#include "SymbolTable.cpp"
#include<fstream>
#include<string>
#include<sstream>
#include<stdlib.h>

using namespace std;

int main(){

    ifstream fin ("input.txt");

    string line,word,words[4];

    int i=0,cmd = 1;

    long long int bucket_size;

    getline(fin,word);

    bucket_size = stoi(word);

    SymbolTable ST(bucket_size);

    while(getline(fin,line)){

        fout <<"Cmd " << cmd <<": " << line << endl;

        stringstream x(line);

        while(getline(x,word,' ') && i<4){


            words[i] = word;
            i++;

        }

        if(i == 3 && words[0] == "I"){

            bool a = ST.INSERT(words[1], words[2]);
        }

        else if(i == 2 && words[0] == "L"){

            SymbolInfo* a = ST.LOOKUP(words[1]);
        }

        else if(i == 2 && words[0] == "D"){

            bool a = ST.DELETE(words[1]);
        }

        else if(i == 2 && words[0] == "P"){

            if(words[1] == "A") ST.PRINT_A();
            if(words[1] == "C") ST.PRINT_C();
        }

        else if(i == 1 && words[0] == "S"){

            ST.EnterScope();
        }

        else if(i == 1 && words[0] == "E"){

            ST.ExitScope();
        }

        else if(i == 1 && words[0] == "Q"){

            ST.CLEAR();
        }

        else {

            fout << "        Number of parameters mismatch for the command " << words[0] << endl;
        }

        cmd++;
        i=0;

    }


}
