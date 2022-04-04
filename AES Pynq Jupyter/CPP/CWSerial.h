#ifndef CWSerial_H
#define CWSerial_H

using namespace std;

class CWSerial
{
    public:
        CWSerial(string device);     //Constructor
        void configure();
        string readCW();      //Maybe not actually a string
        string readCW(int msg_size);  //Maybe not actually a string
        string readlineCW();  //Maybe not actually a string
        void writeCW(string msg);     //Should this be taking a string?
        string getACK();
        string getREAD();
    private:
        string device = "";
};

#endif
