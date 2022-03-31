#ifndef CRasp_H
#define CRasp_H

using namespace std;

string make_cmd(string cmd);
string make_cmd(string cmd, string byte_data);
string format_bytestr_as_hexstr(string text);
string format_hexstr_as_bytestr(string hexstr);
int hexCharToDecimal(char convertMe);

#endif
