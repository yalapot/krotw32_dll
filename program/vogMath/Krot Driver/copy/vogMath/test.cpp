#include <string.h>

#include <iostream>
#include <sstream>

extern "C" { 

#include "vogMath.h" 
#include "iniTool.h"
#include "vogTrc.h"

extern char lastVogError[];

}

#include "tester.h"

using std::cout;

// calback function for register func
long KRTAPI informUser(short percentDone, const char *msg) {
static bool firstCall = true;

 if (firstCall) {
  cout << msg;
  firstCall = false;
 }
 return 0;
}

// function for checking files equal
void checkFile(
KrtTester *test, 
const char *f1,
const char *f2
) {

std::ostringstream o;

 o << "fc " << f1 << " " << f2 << " >nul";
 long ret = system(o.str().c_str());
 o.str("");
 o << "file " << f1 << " not equal " << f2;
 test->make(ret == 0, o.str().c_str(), NULL);

 return;
}

// function for checking ini file keys
void checkIni(
KrtTester *test, 
const char *trc,
const char *sec,
const char *key,
const char *val
) {

std::ostringstream o;

 char *itm = getIniItem(trc, sec, key, "");
 o << trc << " [" << sec << "]:" << key;
 o << " != " << val << " (" << itm << ")";
 bool rslt = strcmp(val, itm) == 0 ? true : false;
 test->make(rslt, o.str().c_str(), NULL);

 return;
}

////////////////////////////////////////////
// main func
int main(int argc, char *argv[]) {

 cout << "Test suit for vog.dll code. (C) 2006 by Vitaly Bogomolov\n";
 KrtTester test;
 std::ostringstream o;
 long ret;

 // *************************************************
 // creating index vog file test 
 const char *trcFile = ".\\test.trc";

 // check api call
 ret = krotCreateVogIndex ("va000000.104", ".", trcFile, NULL); //informUser
 test.make(ret != KRT_ERR, "krotCreateVogIndex return KRT_ERR", lastVogError);

 // check trc keys values
 checkIni(&test, trcFile, VOG_DATA, VOG_DATA_FIELD, VOG_FILE_FIELD);
 checkIni(&test, trcFile, VOG_DATA, VOG_DATA_COORD, VOG_FILE_COORD);

 // check output files
 checkFile(&test, VOG_FILE_FIELD, "old_Rec_Mat.dat");
 checkFile(&test, VOG_FILE_COORD, "old_Rec_Vog.dat");

 // *************************************************
 // print total result
 test.print();
 return test.result();
}
