#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "winkrt.h"
#include "KrtAPI2.h"
#include "krotnano.h"
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
 sprintf(nameBuff, "%s\\d%05d.cmp", dir, indx);
 return nameBuff;
}

// функция заполняет информацией о файле данных fileName структуру info
// возвращает 1 при успехе, 0 при ошибке. Описание ошибки в drvError
long getFileInfo( T_OPENED_TRACE *trace,
                  const char *fileName,
                  long fileIndex,
                  T_ArrivedData *info
                 )
{

   FILE *idx_file_data;

   FILE *data_file;
   char file_name[_MAX_PATH];
   long file_counter;

   T_File_Head    file_head;
   T_Koord_data   block_head;

   static long num_block_in_spin = 0;

   static long pred_vmt = -1;
   long vmt_for_pred_vmt;

   static long pred_time = 0;
   static long d_time = 0;

   static long pred_trace_prod = 0;
   static long d_trace_prod = 0;

   static long pred_trace_poperd = 0;
   static long d_trace_poperd = 0;

   static unsigned char cur_prod_put = 0;
   static unsigned char new_prod_put = 0;
   static long d_trace_prod_spin = 0;
   static long pred_direct_prod_put = 0;

   static long  first_length = -1;

   static unsigned short pred_num_poweron;

   u8* check_sum_ptr;
   u8 check_sum;

   long i;
   char key_name[1024];
   char key_value[1024];

   (void) fileName;

   file_counter = fileIndex;


/*
   if (fileIndex == 6) {
      file_counter = 6;
//      MessageBox(NULL, " 18 \n", "",MB_OK | MB_SYSTEMMODAL);
   };
*/

   if ( trace->idx_head.num_idx_in_table == 0 )
   {
       file_counter = 0;
       trace->idx_head.num_idx_in_table = 0;
       trace->idx_trc[trace->idx_head.num_idx_in_table].beg_trace = trace->idx_head.trace_len = 0;
   };
/*
   if ( trace->idx_head.num_idx_in_table > 0 ) {

      if (fileIndex <= trace->idx_trc[trace->idx_head.num_idx_in_table-1].file_num) {
        info->length = trace->trace_len - info->start;
        return 1;
      };

   } else {
       file_counter = 0;
       trace->idx_head.num_idx_in_table = 0;
       trace->idx_trc[trace->idx_head.num_idx_in_table].beg_trace = trace->idx_head.trace_len = 0;
   };
*/

   while (file_counter <= fileIndex)
   {
      sprintf(file_name, "%sd%05ld.cmp", trace->path_data, file_counter);
      data_file = fopen(file_name, "rb");
      if (data_file == NULL) {
          sprintf(drvError, "Ошибка открытия файла %s. \n", file_name);
          return 0;
      };


      if ( fread( &file_head, 1, sizeof(file_head), data_file) != sizeof(file_head) )
      {
           return 0;
      };

      trace->idx_head.num_sens = file_head.num_sens;
      trace->idx_head.num_test_in_block = file_head.num_test_in_block;

//      arc_table = (ARC_TABLE_REC *) malloc(sizeof(ARC_TABLE_REC) * file_head.num_test_in_block * sizeof(CORROSION_SENS_TYPE));
//      arc_buf = (u8*) malloc ( sizeof(u8) * file_head.num_test_in_block * sizeof(CORROSION_SENS_TYPE));

//      block_data = (CORROSION_SENS_TYPE *) malloc (sizeof(CORROSION_SENS_TYPE) * file_head.num_sens * file_head.num_test_in_block * sizeof(CORROSION_SENS_TYPE));

      while (fread( &block_head, 1, sizeof(block_head), data_file) == sizeof(block_head))
      {
           num_block_in_spin++;
		   
           if ( trace->idx_head.num_idx_in_table == 0 ) {
               pred_vmt = 0; //block_head.vmt;
               pred_trace_prod = 0; // block_head.odometr_1;
               pred_time = 0; //block_head.time;

               pred_num_poweron = block_head.num_poweron;

               trace->idx_head.num_idx_in_table = 0;

               trace->idx_trc[trace->idx_head.num_idx_in_table].beg_trace = trace->idx_head.trace_len;

               trace->idx_trc[trace->idx_head.num_idx_in_table].first_test_in_block =
               trace->idx_trc[trace->idx_head.num_idx_in_table].beg_poperd = pred_trace_poperd = 0;
               trace->idx_trc[trace->idx_head.num_idx_in_table].vmt = 0;//block_head.vmt;
               trace->idx_trc[trace->idx_head.num_idx_in_table].time = block_head.time; //- pred_time;
               trace->idx_trc[trace->idx_head.num_idx_in_table].shift_in_file = ftell(data_file) - sizeof(block_head);
               trace->idx_trc[trace->idx_head.num_idx_in_table].file_num = file_counter;
           };

           check_sum=0;
           check_sum_ptr = (u8 *)&block_head;

           for (i=0;i<5;i++){
               check_sum = check_sum + (*check_sum_ptr);
               check_sum_ptr++;
           };

           if (check_sum != block_head.check_sum)
           {
               block_head.odometr     =  pred_trace_poperd + trace->idx_head.num_test_in_block;
               block_head.odometr_1   =  cur_prod_put;
               block_head.vmt         =  pred_vmt;
               block_head.num_poweron =  pred_num_poweron;
           };

           vmt_for_pred_vmt = block_head.vmt;

           if ( (pred_num_poweron != block_head.num_poweron) && ( first_length != -1) )
           {
               // Кажись пошла дозапись
               cur_prod_put = new_prod_put;
               pred_trace_poperd = block_head.odometr - trace->idx_head.num_test_in_block;
               block_head.vmt = pred_trace_poperd + 1;
               num_block_in_spin --;
           };

           d_trace_poperd = block_head.odometr - pred_trace_poperd;

           // обработка продольного пути
           new_prod_put = (u8) (block_head.odometr_1 & 127);

           if (new_prod_put != pred_trace_prod )
           {
               if ((new_prod_put == (pred_trace_prod + 1) ) ||
                   (new_prod_put == (pred_trace_prod - 1) )
                  )
               {
                   d_trace_prod_spin += 1;
                   if (new_prod_put == (pred_trace_prod + 1))
                   {
                       trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = 0;
                   } else {
                       trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = 1;
                   };
               }
               else
               {
                   if ((new_prod_put == (pred_trace_prod + 2) ) ||
                       (new_prod_put == (pred_trace_prod - 2) )
                      )
                   {
                       d_trace_prod_spin += 2;
                       if (new_prod_put == (pred_trace_prod + 2) )
                       {
                           trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = 0;
                       } else {
                           trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = 1;
                       };
                   }
                   else
                   {
                       if ((new_prod_put == (pred_trace_prod + 3) ) ||
                           (new_prod_put == (pred_trace_prod - 3) )
                          )
                       {
                           d_trace_prod_spin += 3;
                           if (new_prod_put == (pred_trace_prod + 3) )
                           {
                               trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = 0;
                           } else {
                               trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = 1;
                           };
                       }
                       else
                       {
                           d_trace_prod_spin += 0;
                           trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = pred_direct_prod_put;
                       };
                   };
               }; // else if ( (new_prod_put == ( (pred_trace_prod+1) & 127) ) ||
           }; // if ( (new_prod_put != pred_trace_prod)

           pred_direct_prod_put = trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put;

           pred_trace_prod = (u8) (block_head.odometr_1 & 127);
           // обработка продольного пути


           if (block_head.vmt != pred_vmt)
           {
/*
               // обработка продольного пути
               new_prod_put = (u8) (block_head.odometr_1 & 127);

               if (pred_trace_prod >= new_prod_put) {
                   d_trace_prod_spin = pred_trace_prod - new_prod_put;
                   trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = 1;
               } else {
                   d_trace_prod_spin = new_prod_put - pred_trace_prod;
                   trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = 0;
               };

               if (d_trace_prod_spin > 100)
               {
                   if( (new_prod_put    > 100) && 
                       (pred_trace_prod < 27 ) &&
                       (pred_trace_prod < new_prod_put)
                     )
                   {
                       d_trace_prod_spin = 128-new_prod_put + pred_trace_prod;
                       trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = 1;
                   } else {
                       d_trace_prod_spin = 128-pred_trace_prod + new_prod_put;
                       trace->idx_trc[trace->idx_head.num_idx_in_table].direct_prod_put = 0;
                   };
               };

               pred_trace_prod = (u8) (block_head.odometr_1 & 127);
               // обработка продольного пути
*/
               trace->idx_trc[trace->idx_head.num_idx_in_table].lenght = d_trace_prod_spin;

               trace->idx_trc[trace->idx_head.num_idx_in_table].num_block_in_spin = num_block_in_spin;
               trace->idx_trc[trace->idx_head.num_idx_in_table].property = 0;

               trace->idx_head.num_idx_in_table++;

               trace->idx_head.trace_len += d_trace_prod_spin;
               d_trace_prod_spin = 0;

               d_time = block_head.time - pred_time;
               if (d_time < 0) d_time = 100;
               trace->idx_head.trace_time += d_time;

               pred_vmt = vmt_for_pred_vmt;
               pred_time = block_head.time;

               trace->idx_trc[trace->idx_head.num_idx_in_table].beg_trace = trace->idx_head.trace_len;
               trace->idx_trc[trace->idx_head.num_idx_in_table].beg_poperd = pred_trace_poperd;

               if ( (block_head.vmt == pred_trace_poperd) || (pred_num_poweron != block_head.num_poweron) )
               {
                   trace->idx_trc[trace->idx_head.num_idx_in_table].first_test_in_block = 0;
               } else {

                   trace->idx_trc[trace->idx_head.num_idx_in_table].first_test_in_block =
                     ( (block_head.vmt - trace->idx_trc[trace->idx_head.num_idx_in_table].beg_poperd - 1)
                       * trace->idx_head.num_test_in_block) / d_trace_poperd;
               };

               trace->idx_trc[trace->idx_head.num_idx_in_table].vmt = block_head.vmt;

               trace->idx_trc[trace->idx_head.num_idx_in_table].time = block_head.time; //- pred_time;
               trace->idx_trc[trace->idx_head.num_idx_in_table].shift_in_file = ftell(data_file) - sizeof(block_head);
               trace->idx_trc[trace->idx_head.num_idx_in_table].file_num = file_counter;

               num_block_in_spin = 1;
           }; // if (block_head.vmt != pred_vmt)

           pred_trace_poperd = block_head.odometr;
           pred_num_poweron = block_head.num_poweron;
           first_length = 1;

           fseek(data_file, block_head.size_arc, SEEK_CUR);
      
       }; // while (fread( &block_head, 1, sizeof(block_head), data_file) == sizeof(block_head))

//      free(block_data);
//      free(arc_table);
//      free(arc_buf);

      fclose(data_file);
      data_file=NULL;

      file_counter++;
   }; // while (file_counter <= fileIndex)

   if ( trace->idx_head.num_idx_in_table != 0 ) {

      // Запишем индекс последнего незаконченного оборота
      trace->idx_trc[trace->idx_head.num_idx_in_table].lenght = d_trace_prod_spin;
      
      trace->idx_trc[trace->idx_head.num_idx_in_table].num_block_in_spin = num_block_in_spin;
      trace->idx_trc[trace->idx_head.num_idx_in_table].property = 1;

//      trace->idx_head.num_idx_in_table++;
   }; // if ( first_length != -1 )

//   info->start  = trace->idx_trc[trace->idx_head.num_idx_in_table].beg_trace;
   trace->trace_len = trace->idx_head.trace_len;
   info->length = trace->trace_len - info->start;

       idx_file_data = fopen(trace->idx_file_name, "wb");
       if (idx_file_data==NULL) {
           sprintf(drvError, "Ошибка открытия файла %s. \n", trace->idx_file_name);
           return 0;
       };

       for (i=0; i < trace->idx_head.num_idx_in_table; i++)
       {
           if ( fwrite( &trace->idx_trc[i], 1, sizeof(trace->idx_trc[0]), idx_file_data) != sizeof(trace->idx_trc[0]))
           {
               sprintf(drvError, "Ошибка записи файла %s. \n", trace->idx_file_name);

               fclose(idx_file_data);
               idx_file_data=NULL;

               return 0;
           };

       }; // for (i=0; i < trace->idx_head.num_idx_in_table; i++)

       if ( fwrite( &trace->idx_head, 1, sizeof(trace->idx_head), idx_file_data) != sizeof(trace->idx_head))
       {
           sprintf(drvError, "Ошибка записи файла %s. \n", trace->idx_file_name);
           return 0;
       };

       fclose(idx_file_data);
       idx_file_data=NULL;


//      sprintf(drvError, " complete getFileInfo, file %ld. \n", file_counter);
//      MessageBox(NULL, drvError, "",MB_OK | MB_SYSTEMMODAL);


   // запишем в trc-файл длинну трассы в измерениях продольного одометра
   sprintf(key_name, "%s", TRACE_LEN_KEY);
   sprintf(key_value, "%ld", trace->idx_head.trace_len);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value, trace->trc_file_name);

   // запишем в trc-файл общее количество датчиков
   sprintf(key_name, "%s", CORROSION_SENS_NUM_KEY);
   sprintf(key_value, "%ld", trace->idx_head.num_sens);
   WritePrivateProfileString(EPRO_SECTION, key_name, key_value, trace->trc_file_name);

   // запишем в trc-файл кол-во датчиков коррозии в каждом поясе
   for (i=0; i < 3; i++)
   {
      sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, i);
      sprintf(key_value, "%i", 48);
      WritePrivateProfileString(EPRO_SECTION, key_name, key_value, trace->trc_file_name);
   }; 
   // записали в trc-файл кол-во датчиков коррозии в каждом поясе

   return 1;
}; // long getFileInfo(T_OPENED_TRACE *trace, const char *fileName, 



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