#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "winkrt.h"
#include "KrtAPI2.h"
#include "krotepro.h"
#include "reciever.h"

#define HandleArrSize 2

typedef struct {      
 HANDLE hStopEvent;
 char waitDir[1024];
 HANDLE hThread; 
} T_WAIT_PARAM;

static T_WAIT_PARAM threadParam;
static T_ArrivedData dataLast;
static T_ArrivedData dataInfo;
static T_OPENED_TRACE *curTrace;

static int fileExist(char *fileName) {
FILE *in;

 in = fopen(fileName, "rb");
 if (in) {
  fclose(in);
  return 1;
 } else {
  return 0;
 }
}

char * makeName(char *nameBuff, const char *dir, int indx) {
 sprintf(nameBuff, "%s\\tm%05d.da", dir, indx);
 return nameBuff;
}

DWORD WINAPI ThreadFunc(LPVOID lpParam) { 
T_WAIT_PARAM *param;
char readyFile[1024];
char currFile[1024];
int fileIndex = 0;    

DWORD dwWaitStatus; 
HANDLE dwChangeHandles[HandleArrSize]; 

 param = (T_WAIT_PARAM *) lpParam;

 dataInfo.start = -1;
 dataInfo.length = -1;

 do {
  fileIndex++;
  makeName(currFile, param->waitDir, fileIndex);
 } while (fileExist(currFile));

 dwChangeHandles[0] = FindFirstChangeNotification( 
    param->waitDir,                // directory to watch 
    FALSE,                         // do not watch the subtree 
    FILE_NOTIFY_CHANGE_FILE_NAME); // watch file name changes 
 
 if (dwChangeHandles[0] == INVALID_HANDLE_VALUE) {
  sprintf(drvError, "Can't create FindFirstChangeNotification. Err code: %ld\n", GetLastError());
//  debugPoint(drvError);
  return 1; 
 }
 
 dwChangeHandles[1] = param->hStopEvent;

 for (;;) { 
 
  // Wait for notification.
  dwWaitStatus = WaitForMultipleObjects(HandleArrSize, dwChangeHandles, FALSE, INFINITE); 
 
  switch (dwWaitStatus) { 

   case WAIT_OBJECT_0: 

   if ( FindNextChangeNotification(dwChangeHandles[0]) == FALSE ) {
    sprintf(drvError, "FindNextChangeNotification failed. Err code: %ld\n", GetLastError());
    return 1; 
   }

   if (fileExist(currFile)) {

    makeName(readyFile, param->waitDir, (fileIndex-1));
    makeName(currFile, param->waitDir, fileIndex+1);
    getFileInfo(curTrace, readyFile, fileIndex-1, &dataLast);


    if (dataInfo.length >=0) {
     dataInfo.length += dataLast.length;
    } else {
     dataInfo.start  = dataLast.start;
     dataInfo.length = dataLast.length;
    }
	 
    if ( (curTrace->newDataRegistered) && ((*(curTrace->newDataRegistered)) (&dataInfo)) ) {
     dataInfo.start = -1;
     dataInfo.length = -1;
    }

    fileIndex++;

   } 

   break; 
 
   case WAIT_OBJECT_0 + 1: 
    return 0;

   default: 
    sprintf(drvError, "Unknown dwWaitStatus %ld. Err code: %ld\n", dwWaitStatus, GetLastError());
    return 1; 
  }
 } 

} 

long startDataRecieve(T_OPENED_TRACE *trace, long (KRTAPI *newDataRegistered) (T_ArrivedData *newData)) {

 threadParam.hStopEvent = CreateEvent( 
        NULL,   // no security attributes
        FALSE,  // auto-reset event object
        FALSE,  // initial state is nonsignaled
        NULL);  // unnamed object

 if (threadParam.hStopEvent == NULL) { 
  sprintf(drvError, "Create StopEvent error: %d\n", GetLastError() ); 
  return 0;
 }

 curTrace = trace;
 curTrace->newDataRegistered = newDataRegistered;
 strcpy(threadParam.waitDir, curTrace->path_data);

 threadParam.hThread = CreateThread( 
   NULL,                        // no security attributes 
   0,                           // use default stack size  
   ThreadFunc,                  // thread function 
   &threadParam,                // argument to thread function 
   0,                           // use default creation flags 
   NULL);                       // not returns the thread identifier 
 
 if (threadParam.hThread == NULL) {
  sprintf(drvError, "CreateThread failed");
  return 0;
 }

 return 1;
}

long stopDataRecieve(T_OPENED_TRACE *trace) {

 if (!SetEvent(threadParam.hStopEvent)) {
  sprintf(drvError, "Can't set stop event. Err code: %d\n", GetLastError() ); 
  return 1;
 }
 
 Sleep(100);
 CloseHandle( threadParam.hThread );
 CloseHandle( threadParam.hStopEvent );
 trace->newDataRegistered = NULL;
 return 0;
}
