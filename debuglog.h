#ifndef _DEBUGLOG_H_
#define _DEBUGLOG_H_

#define LOG_DFLT_FILE "c:\\krot.log"  // ��� ���-����� �� ���������

extern char *LogFile;                 // ��� ���-�����
extern char LogString[];              // ������ ��� ������ � ���
extern void Log(void);                // ������� ������ � ���

#endif
