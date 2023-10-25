#ifndef TRACETOOL_C
#define TRACETOOL_C

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <krtapi.h>
#include <tracetool.h>


#ifdef CALL_LOG

long debug_counter;

char tmp_log_str[1024];

#define LOG_FILE "d:\\nano_log.txt"

void Log(char *LogString) {
 static FILE *call_log = NULL;

 if (call_log == NULL) call_log = fopen(LOG_FILE, "at");

 fprintf(call_log, "%s", LogString);

// fclose(call_log); call_log = NULL; // если раскоментировать то будет закрывать файл, после каждой порции данных
}

#define LOG_FILE_BIN "d:\\odom_log.bin"
void BinLog(void *save_dat, long lengt_dat) {
 static FILE *bin_log = NULL;

 if (bin_log == NULL) bin_log = fopen(LOG_FILE_BIN, "ab");

 fwrite( save_dat, 1, lengt_dat, bin_log);

// fclose(bin_log); bin_log = NULL; // если раскоментировать то будет закрывать файл, после каждой порции данных
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
  long i;

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
  space_for_trace->idx_head.trace_len        = 0;
  space_for_trace->idx_head.trace_time       = 0;
  space_for_trace->idx_trc = NULL;
  Init_All_FileData( &(space_for_trace->Files_buffers));

  space_for_trace->ext_idx_file_data = NULL;
  space_for_trace->pressure_data = NULL;

  space_for_trace->corosion_sens_num=0;
  space_for_trace->group_num=0;

  space_for_trace->max_data_code=0;

  space_for_trace->Smooth_data_OFF=0;

  for (i=0; i<MAX_GROUP_NUM; i++) {
     space_for_trace->linesense_size[i]=0;
     space_for_trace->Amplification_Group[i]=0;
     space_for_trace->smooth_win_length[i] = 0;
   };

  space_for_trace->max_sens_shift=0;

  for (i=0; i<MAX_CORROZION_NUM; i++) {
     space_for_trace->sens_shift[i]=0;
     space_for_trace->sens_sort[i]=i;
     space_for_trace->invert_sens_data[i]=0;
   };

  space_for_trace->Orientation_OFF=0;
  space_for_trace->Orientation_shift=0;
  space_for_trace->Orientation_shift_2=0;
  space_for_trace->Orinteation_Direct_count=0;

  space_for_trace->nodeType=0; 
  space_for_trace->nodeIndex=0;            
  space_for_trace->nodePos=0;
  space_for_trace->controlSize=0;

  space_for_trace->sens_for_thick=0;
  space_for_trace->sens_for_thick_count=1;

  space_for_trace->add_ext_sens_ovalnost=0;
  space_for_trace->add_ext_sens_bps_pressure=0;
  space_for_trace->add_ext_sens_thick_II=0;

  space_for_trace->BendingPlane = 0;

  space_for_trace->ReversView = 0;

  space_for_trace->ShiftNavigation_data = 0;

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

      if ( p_free->ext_idx_file_data !=NULL) {
          fclose(p_free->ext_idx_file_data);
          p_free->ext_idx_file_data = NULL;
      };

      if ( p_free->pressure_data !=NULL) {
          fclose(p_free->pressure_data);
          p_free->pressure_data = NULL;
      };

      if ( p_free->ovalnost_data !=NULL) {
          fclose(p_free->ovalnost_data);
          p_free->ovalnost_data = NULL;
      };

      free_files_data( &(p_free->Files_buffers));

      free(p_free);
      p_free = NULL;
   }; // if ((*p_free)!=NULL) {

  return p_free;
}; //  T_OPENED_TRACE * WINAPI free_opened_trace( T_OPENED_TRACE *p_free)

long read_data_profil_ini(T_OPENED_TRACE * opened_trace)
{
   char key_name[1024];
   char key_value[1024];
   char profil_ini_file_name[1024];

   long i, j, k;

   char seps[]   = " ,\t\n";
   char *token;
   long next_token; 

   FILE *prf_calibrate;


   // начальная инициализация массива на всякий случай
   k=1000;
   for (j=0; j < MAX_PROFILE_CALIBRATE; j++) {
      for (i=0; i<  MAX_PROFILE_NUM_SENS; i++) {
         opened_trace->profil_calibrate[i][j]=k;
      };
      k+=100;
   };

   sprintf(profil_ini_file_name, "%s%s", opened_trace->path_data, PROFIL_INI_FILE_NAME);

   prf_calibrate=fopen(profil_ini_file_name, "rb");
   if (prf_calibrate == NULL) {
         sprintf(drvError, "Нет калибровки профильных датчиков(read_data_profil_ini)");
         return KRT_ERR;
   };
   fclose(prf_calibrate);

   // читаем из trc-файла калибровку профильных датчиков
   for (i=0; i < opened_trace->corosion_sens_num; i++) {
      sprintf(key_name, "%s%i", Profil_calibrate_KEY, i);
      if (GetPrivateProfileString(PROFILE_SECTION, key_name, "", key_value,
                                  sizeof(key_value), profil_ini_file_name) != 0)
      {
         next_token=0;
         token = strtok(key_value, seps);
         while (token!=NULL) {
            opened_trace->profil_calibrate[i][next_token]=atoi(token);

            next_token++;
            token = strtok(NULL, seps);
         };

         for (j=next_token; j < MAX_PROFILE_CALIBRATE; j++) {
            opened_trace->profil_calibrate[i][j] = 
                    opened_trace->profil_calibrate[i][j-1] - 100;
         };
      };
   };
   // прочитали из trc-файла калибровку профильных датчиков

   return KRT_OK;
}; // long read_data_profil_ini(T_OPENED_TRACE * opened_trace)


u16 calkulate_orientation (double cA, double sA, double orient_scale)
{
  double ArcTg2;

    if (cA == 0) {
        if (sA < 0) {
            ArcTg2 = 1.5 * PI;
         } else {
            ArcTg2 = 0.5 * PI;
         };
     } else {
         if (cA < 0) {
             ArcTg2 =  PI + atan(sA / cA);
          } else {
             if (sA < 0) {
                 ArcTg2 = atan(sA / cA) + 2 * PI;
              } else {
                 ArcTg2 = atan(sA / cA);
              };
          };
     };

    ArcTg2*=orient_scale;
    ArcTg2/=(2*PI);

    if (ArcTg2-((u16) ArcTg2)>0.5) ArcTg2+=1;

  return ((u16) ArcTg2);
};

#endif