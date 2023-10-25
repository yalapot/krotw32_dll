#include <stdio.h>
#include <stdlib.h>

#include "winkrt.h"
#include "krtBase.h"
#include "iniTool.h"

/////////////////////////////////////////
char *getIniItem(
const char *iniFile,
const char *section,
const char *keyName,
const char *dflt
) {
static char buff[1024];

 if (GetPrivateProfileString(section, keyName, dflt, buff, sizeof(buff), iniFile) == 0) {
  strcpy(buff, dflt);
 }

 return buff;
}

/////////////////////////////////////////
void setIniItem(
const char *iniFile,
const char *section,
const char *keyName,
const char *dflt
) {
 WritePrivateProfileString(section, keyName, dflt, iniFile);
}

/////////////////////////////////////////
char *getTrcItem(
const char *iniFile,
const char *keyName,
const char *dflt
) {
 return getIniItem(iniFile, DRIVER_DATA, keyName, dflt);
}

/////////////////////////////////////////
void setTrcItem(
const char *iniFile,
const char *keyName,
const char *dflt
) {
 setIniItem(iniFile, DRIVER_DATA, keyName, dflt);
}

/////////////////////////////////////////
long getIniInt(
const char *iniFile,
const char *section,
const char *keyName,
long dflt
) {
char buff[1024];
 sprintf(buff, "%ld", dflt);
 return atol(getIniItem(iniFile, section, keyName, buff));
}

/////////////////////////////////////////
void setIniInt(
const char *iniFile,
const char *section,
const char *keyName,
long dflt
) {
char buff[1024];
 sprintf(buff, "%ld", dflt);
 setIniItem(iniFile, section, keyName, buff);
}

/////////////////////////////////////////
long getTrcInt(
const char *iniFile,
const char *keyName,
long dflt
) {
 return getIniInt(iniFile, DRIVER_DATA, keyName, dflt);
}

/////////////////////////////////////////
void setTrcInt(
const char *iniFile,
const char *keyName,
long dflt
) {
 setIniInt(iniFile, DRIVER_DATA, keyName, dflt);
}

char warnString[4096];

/////////////////////////////////////////
void trcWarn(
const char *trcFile
) {
static int warnCount=0;
char itemName[12];

  warnCount++;
  sprintf(itemName, "Warn%06d", warnCount);
  setTrcItem(trcFile, itemName, warnString);
}
