// 384ep_drv.c - драйвер просмотра данных електронного блока "384 epro" 
// программой KrotW32
//
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <KrtAPI.h>
#include "krtblack.h"

/**********************************************/
BOOL WINAPI DllMain (
    HINSTANCE hinstDLL,  // DLL module handle
    DWORD fdwReason,     // reason called
    LPVOID lpvReserved)  // reserved
{
 (void) hinstDLL;
 (void) lpvReserved;

 switch (fdwReason) {
   case DLL_PROCESS_ATTACH:
    initTraces();
   default:
    break;
  };
 return TRUE;
}

void trcWarn(char *trcFile) {
static int warnCount=0;
char itemName[12];

 warnCount++;
 sprintf(itemName, "Warn%06d", warnCount);
 WritePrivateProfileString(KROT_BLACK_BOX_SECTION, itemName, warnString, trcFile);
}
