#ifndef TRACETOOL_C
#define TRACETOOL_C

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <krtapi.h>
#include "tracetool.h"


#ifdef CALL_LOG

long debug_counter;

char tmp_log_str[1024];

#define LOG_FILE "d:\\nano_log.txt"

void Log(char *LogString) {
 FILE *call_log;

 call_log = fopen(LOG_FILE, "at");
 fprintf(call_log, "%s", LogString);
 fclose(call_log);
}

#endif


char register_log_file_name[1024];
char register_log_info[1024];

void Reg_Log(char *LogString) {
    FILE *Reg_log;

    Reg_log = fopen(register_log_file_name, "at");
    fprintf(Reg_log, "%s", LogString);
    fclose(Reg_log);
}

char drvError[1024];

T_TRACE_LIST trace_list[MAX_TRACE];
long open_trace_counter;

char warnString[4096];
char *traceFile;


/* Функция инициализации сегмента данных драйвера */
void WINAPI initTraces(void) {
  open_trace_counter=0;
  strcpy(drvError, "");
};


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
};

const char* WINAPI krtDrvError(void){
   return drvError;
};


// Функция выделения памяти под структуру открытой трассы 
//(типа конструктор T_OPENED_TRACE)
T_OPENED_TRACE * WINAPI init_opened_trace()
{

  T_OPENED_TRACE *space_for_trace;

  space_for_trace = (T_OPENED_TRACE *) malloc(sizeof(T_OPENED_TRACE));
  if (space_for_trace == NULL) {
     sprintf(drvError, "Нет памяти под открытую трассу(init_opened_trace)");
     return space_for_trace;
   };

  // обнулим поля тока что выделенной структуры (на всякий случай)
  space_for_trace->trace_len=0;
  space_for_trace->trace_step=0;
  space_for_trace->trace_time=0;
  strcpy(space_for_trace->path_data, ""); 
  strcpy(space_for_trace->trc_file_name, ""); 

  space_for_trace->idx_head.num_idx_in_table = 0;
  space_for_trace->idx_head.first_file_index = 0;
  space_for_trace->idx_trc = NULL;

  return space_for_trace;
}; // T_OPENED_TRACE * WINAPI init_opened_trace()

// Функция освобождения памяти под структурой открытой трассы
T_OPENED_TRACE * WINAPI free_opened_trace( T_OPENED_TRACE *p_free)
{

  if (p_free != NULL) {
      if ( p_free->idx_trc !=NULL) {
          free(p_free->idx_trc);
          p_free->idx_trc = NULL;
      };

      free(p_free);
      p_free = NULL;
   }; // if ((*p_free)!=NULL) {

  return p_free;
}; //  T_OPENED_TRACE * WINAPI free_opened_trace( T_OPENED_TRACE *p_free)

#endif
