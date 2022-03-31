#include <iostream>
#include <pigpio.h>
#include "CWSerial.h"
#include "CRasp.h"

using namespace std;

int main()
{
    /* In[1] */
    cout << "Hello World!" << endl;
    /* End of In[1] */

    /* In[2] */
    if (gpioInitialise() < 0)
    {
        return 1;       //If this fails, return 1 (error), stop the program
    }
    gpioSetMode(14, PI_OUTPUT);
    /* End of In[2] */

    /* In[3] pulls in the AES library, skipping for now */
        //TODO (probably)

    /* In[4] - In[6] do nothing in our current python file */

    /* In[7] */
        //Implemented in file CWSerial.cpp

    /* In[8] */
    bool mode = false;
    /* End of In[8] */

    /* In[9] */
        //TODO
        //Implemented method in this file

    /* In[10] */
        //Implemented method in this file

    /* In[ ]: */
    string data = "";
    string key = "aesEncryptionKey";            //CHANGE KEY CHANGE KEY CHANGE KEY CHANGE KEY CHANGE KEY CHANGE KEY
    CWSerial cw_com = CWSerial("/dev/ttyUSB0");
    cw_com.configure();

    while(true)
    {
        string inp = cw_com.readline();

        if(inp.at(0) == 'k')
        {
            key = format_hexstr_as_bytestr(inp.substr(1));
            cw_com.write(make_cmd(cw_com.getACK()));
            inp = cw_com.readline();
        }
    }


    return 0;       //End of the program
}

string encrypt(string key, string plaintext)
{
    //TODO implement this
    cout << "encrypt CRrasp - NYI";
    return "";
}

string make_cmd(string cmd)
{
    return make_cmd(cmd, "");
}

string make_cmd(string cmd, string byte_data)
{
    string returnMe = cmd + byte_data + "\n";
    return returnMe;
}

string format_bytestr_as_hexstr(string text)
{
    static char hex[] = "0123456789ABCDEF";
    string returnMe = "";
    for(int i =0; i < text.length(); i++)
    {
        char convertThisCharToHex = text.at(i);
        returnMe = returnMe + hex[convertThisCharToHex / 16];       //Gets the first hex digit
        returnMe = returnMe + hex[convertThisCharToHex % 16];       //Gets the second hex digit
    }
    return returnMe;
}

string format_hexstr_as_bytestr(string hexstr)
{
    string returnMe = "";
    for(int i = 0; i < hexstr.length(); i = i + 2)
    {
        char firstChar = hexstr.at(i);
        char secondChar = hexstr.at(i + 1);

        firstChar = hexCharToDecimal(firstChar);        //Convert char '6' to a value of 0x06, char 'C' to 0x0C, etc
        secondChar = hexCharToDecimal(secondChar);

        char addMeToString = firstChar*16 + secondChar;
        returnMe = returnMe + addMeToString;
    }
    return returnMe;
}

int hexCharToDecimal(char convertMe)
{
    if(convertMe > 57)
    {
        return convertMe - 55;
    }
    else
    {
        return convertMe - 48;
    }
}
