#include <iostream>
#include "CWSerial.h"

using namespace std;

    string ACK = "z00";
    string READ = "r";

CWSerial::CWSerial(string device)
{
    this->device = device;
    //TODO connection variable
    cout << "Constructor" << endl;
}

void CWSerial::configure()
{
    
    cout << "CWSerial::configure() NYI" << endl;
    //TODO not yet implemented
}

string CWSerial::read()
{
    //TODO not yet implemented
    cout << "CWSerial::read() NYI" << endl;
    return "CWSerial read() NYI";
}

string CWSerial::read(int msg_size)
{
    //TODO not yet implemented
    cout << "CWSerial::read(int msg_size) NYI" << endl;
    return "CWSerial read(msg_size) NYI";
}

string CWSerial::readline()
{
    //TODO not yet implemented
    cout << "CWSerial::readLine() NYI" << endl;
    return "CWSerial readLine() NYI";
}

void CWSerial::write(string cmd)
{
    cout << "CWSerial::write(string cmd) NYI" << endl;
    //TODO not yet implemented
}

string CWSerial::getACK()
{
    return ACK;
}

string CWSerial::getREAD()
{
    return READ;
}
