
extern char drvError[];

extern long startDataRecieve(T_OPENED_TRACE *trace, long (KRTAPI *newDataRegistered) (T_ArrivedData *newData));
extern long stopDataRecieve(T_OPENED_TRACE *trace);
extern long getFileInfo(T_OPENED_TRACE *trace, const char *fileName, long fileIndex,T_ArrivedData *info);
