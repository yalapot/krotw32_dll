// ������ ��������/�������� ��������� �������
// (C) 2005 by Vitaly Bogomolov

#include "krtapi.h"
#include "krtapi2.h"

#define FUNC_INFO      "krtDriverInfo"
#define FUNC_OPEN      "krtOpenTrace"
#define FUNC_CLOSE     "krtCloseTrace"
#define FUNC_INFOEXT   "krtDriverInfoExt"

// ���������� ��������� �������� ��������
typedef struct {

 HINSTANCE           inst;              // ���������� ��������

 long apiVer;                           // ������ API ��������
 long isSpiral;                         // �������������?
 long verMax;                           // ����� ������ ��������, ������� ������
 long verMin;                           // ����� ������ ��������, ������� ������

 // ��������� �� ������� ��������

 drv_Register        krtRegister;       // ����������� ������
 drv_DriverInfo      krtDriverInfo;     // ������� �������� ��������
 drv_OpenTrace       krtOpenTrace;      // �������� �������
 drv_CloseTrace      krtCloseTrace;     // �������� �������

 // ��������� �� ������� �������� ������ 1

 drv2_Online         krtOnline;         // ��������� ����������� ��������� ����� ������
 drv2_DriverInfoExt  krtDriverInfoExt;  // �������� �������� ������ 1
 drv2_Register       krtRegister2;      // ����������� ������

 char                sign[KRT_TEXT];    // ���������
 char                name[KRT_TEXT];    // ������������
 char                copyRt[KRT_TEXT];  // ������ ���������
 char                file[KRT_TEXT];    // ���� ��������

} T_DRIVER;

extern char drv_Error[];                // �������� ��������� ������

// ������� ��������� ���� ��������, �������� ����� drvFile
// � ��������� ��������� T_DRIVER ����������� � ���.
extern long LoadDriver(const char *drvFile, T_DRIVER *drv);

// ������� ��������� �������, ����� ����������� �������� LoadDriver
extern long UnloadDriver(T_DRIVER *drv);
