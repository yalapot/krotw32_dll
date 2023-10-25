/////////////////////////////////////////
// модуль операций драйвера крота с trc и ini файлами
// (C) 2006 by Vitaly Bogomolov
/////////////////////////////////////////
char *getIniItem(const char *iniFile, const char *section, const char *keyName, const char *dflt);
long getIniInt(const char *iniFile, const char *section, const char *keyName, long dflt);
char *getTrcItem(const char *iniFile, const char *keyName, const char *dflt);
long getTrcInt(const char *iniFile, const char *keyName, long dflt);

void setIniItem(const char *iniFile, const char *section, const char *keyName, const char *dflt);
void setIniInt(const char *iniFile, const char *section, const char *keyName, long dflt);
void setTrcItem(const char *iniFile, const char *keyName, const char *dflt);
void setTrcInt(const char *iniFile, const char *keyName, long dflt);

extern char warnString[];
void trcWarn(const char *trcFile);
