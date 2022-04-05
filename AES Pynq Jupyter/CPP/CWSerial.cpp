#include <iostream>
#include "CWSerial.h"
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <unistd.h>


using namespace std;

string ACK = "z00\n";
string READ = "r";

struct termios tty;
int serial_port;

CWSerial::CWSerial(string device)
{
    this->device = device;
    //TODO connection variable
    cout << "Constructor" << endl;
}

void CWSerial::configure()
{
    const char* deviceCharStar = device.c_str();
    serial_port = open(deviceCharStar, O_RDWR);
    if(serial_port < 0)
    {
        cerr << "Error from tcgetattr: " << errno << endl;
    }
    if(tcgetattr(serial_port, &tty) != 0)
    {
        cerr << "Error from tcgetattr: " << errno << endl;
    }
    tty.c_cflag &= ~PARENB;     //No parity bits
    tty.c_cflag &= ~CSTOPB;     // Clear stop field, only one stop bit used
    tty.c_cflag |= CS8;         //Eight bits per byte
    tty.c_cflag &= ~CRTSCTS;    //Flow control RTS/CTS disabled
    tty.c_cflag |= CREAD | CLOCAL; // Turn on READ & ignore ctrl lines (CLOCAL = 1)

    cfsetispeed(&tty, B38400);
    cfsetospeed(&tty, B38400);

    tty.c_lflag &= ~ECHO; // Disable echo

    if (tcsetattr(serial_port, TCSANOW, &tty) != 0)
    {
        cerr << "Error from tcgetattr: " << errno << endl;
    }
}

string CWSerial::readCW()
{
    //TODO check this
    char read_buf [2048];
    int sizeOfMessageReceived = 0;
    while(sizeOfMessageReceived == 0)
    {
        sizeOfMessageReceived = read(serial_port, &read_buf, sizeof(read_buf));
    }
    string returnMe = "";
    for(int i = 0; i < sizeOfMessageReceived; i++)
    {
        returnMe = returnMe + read_buf[i];
    }
    return returnMe;
}

string CWSerial::readCW(int msg_size)
{
    //TODO
    cout << "read(int msg_size) doesn't do anything with msg_size at all (right now)" << endl;
    return readCW();
}

string CWSerial::readlineCW()
{
    //TODO not yet implemented
    return readCW();
}

void CWSerial::writeCW(string cmd)
{
    const char* cmdCharStar = cmd.c_str();
    cout << "writing: " << cmdCharStar << endl;
    write(serial_port, cmdCharStar, cmd.length());
}

string CWSerial::getACK()
{
    return ACK;
}

string CWSerial::getREAD()
{
    return READ;
}
