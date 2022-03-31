#ifndef CWSerial_H
#define CWSerial_H

using namespace std;

class CWSerial
{
    public:
        CWSerial(string device);     //Constructor
        void configure();
        string read();      //Maybe not actually a string
        string read(int msg_size);  //Maybe not actually a string
        string readline();  //Maybe not actually a string
        void write(string msg);     //Should this be taking a string?
        string getACK();
        string getREAD();
    private:
        string device = "";
};

#endif
