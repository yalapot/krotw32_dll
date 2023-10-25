#include <stdio.h>
#include <string.h>
#include "driver.h"

char drv_Error[KRT_TEXT]; // �������� ��������� ������

///////////////////////////////////////////////////////
long UnloadDriver(T_DRIVER *drv) {
 if (drv->inst) FreeLibrary(drv->inst);
 drv->inst = NULL;
 return KRT_OK;
}

///////////////////////////////////////////////////////
long noFunc(T_DRIVER *drv, const char *func) {
 sprintf(drv_Error, "� �������� %s ����������� ������� %s", drv->file, func);
 UnloadDriver(drv);
 return KRT_ERR;
}

///////////////////////////////////////////////////////
long LoadDriver(const char *drvFile, T_DRIVER *drv) {
T_DRVINFO driver1;
T_DRVINFO2 driver2;

 strncpy(drv->file, drvFile, KRT_TEXT-1);

 drv->inst = LoadLibrary(drv->file);
 if (drv->inst == NULL) {
  sprintf (
   drv_Error, 
   "�� ���� ��������� ������� %s\nGetLastError code: %d", 
   drv->file, 
   GetLastError()
          );
  return KRT_ERR;
 }

 // ����� ������� krtDriverInfo
 drv->krtDriverInfo = (drv_DriverInfo) GetProcAddress(drv->inst, FUNC_INFO);
 if (!drv->krtDriverInfo) return noFunc(drv, FUNC_INFO);

 // ����� ������� krtOpenTrace
 drv->krtOpenTrace = (drv_OpenTrace) GetProcAddress(drv->inst, FUNC_OPEN);
 if (!drv->krtOpenTrace) return noFunc(drv, FUNC_OPEN);

 // ����� ������� krtCloseTrace
 drv->krtCloseTrace = (drv_CloseTrace) GetProcAddress(drv->inst, FUNC_CLOSE);
 if (!drv->krtCloseTrace) return noFunc(drv, FUNC_CLOSE);

 // ����� krtDriverInfo - ������ ������ API ��������
 if ((*(drv->krtDriverInfo)) (&driver1) == KRT_ERR) {
  sprintf (drv_Error, "������ ��� ������ krtDriverInfo");
  UnloadDriver(drv);
  return KRT_ERR;
 }

 // ��������� ������ API ��������
 switch ( driver1.apiVer ) {
  
  case KRT_APIVER:

   drv->apiVer           = KRT_APIVER;
   drv->isSpiral         = 0;
   drv->verMax           = 0; 
   drv->verMin           = 0; 

   drv->krtOnline        = NULL;         
   drv->krtDriverInfoExt = NULL;  
   drv->krtRegister2     = NULL;

   strncpy(drv->sign, "V0", KRT_TEXT); 
   strncpy(drv->name, "Driver for first krtapi version", KRT_TEXT); 
   strncpy(drv->copyRt, "(C) by Vitaly Bogomolov", KRT_TEXT); 

   drv->krtRegister = driver1.krtDrvRegister;

   break;
  
  case KRT_APIVER2:

   drv->krtDriverInfoExt = (drv2_DriverInfoExt) GetProcAddress(drv->inst, FUNC_INFOEXT);
   if (!drv->krtDriverInfoExt) return noFunc(drv, FUNC_INFOEXT);

   // ����� krtDriverInfoExt - ������ ���������� �������� �������� ���������� ������ API
   if ((*(drv->krtDriverInfoExt)) (KRT_APIVER2, &driver2) == KRT_ERR) {
    sprintf(drv_Error, "������ ��� ������ krtDriverInfoExt");
    UnloadDriver(drv);
    return KRT_ERR;
   }

   drv->apiVer       = KRT_APIVER2;
   drv->isSpiral     = driver2.pigType;
   drv->verMax       = driver2.drvVerMax;
   drv->verMin       = driver2.drvVerMin;

   drv->krtRegister  = driver1.krtDrvRegister;
   drv->krtOnline    = driver2.krtOnline;         
   drv->krtRegister2 = driver2.krtDrvRegister;

   strncpy(drv->sign,   driver2.drvSign,   KRT_TEXT); 
   strncpy(drv->name,   driver2.drvName,   KRT_TEXT); 
   strncpy(drv->copyRt, driver2.drvCopyRt, KRT_TEXT); 

   break;

  default :

   sprintf(drv_Error, "����������� ������ API (%ld) � �������� %s", driver1.apiVer, drv->file);
   UnloadDriver(drv);
   return KRT_ERR;
 }

 return KRT_OK;
}
