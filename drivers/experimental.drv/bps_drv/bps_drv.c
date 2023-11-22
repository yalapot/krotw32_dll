
#include "bps_drv.h"

char drvError[1024];

T_TRACE_LIST trace_list[MAX_TRACE];
long open_trace_counter;

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
   {
      initTraces();
      break;
   };

   case DLL_PROCESS_DETACH: {
      break;
   };

   default:
      break;
   };

 return TRUE;
};

//////////////////////////////////////////////////////////////////////////
//Callback - Функции
//////////////////////////////////////////////////////////////////////////


const char* WINAPI krtDrvError(void){
  return drvError;
};

long WINAPI krtDrvFillData( KRTHANDLE handle, long group, long start,
                           long length, KRTDATA *screen, long *rowData)
{
  long i;
  long my_length = length;
  long cur_trace;

  (void) group;
  (void) start;
  (void) rowData;

  if (open_trace_counter==0) {
     sprintf (drvError, "нет открытых трасс(krtDrvFillData)");
     return KRT_ERR;
  };

  // найдем открытую трассу в списке:
  for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
     if (handle==trace_list[cur_trace].handle) break;
  };

  if (cur_trace >= open_trace_counter) {
     sprintf(drvError, "не найден handle (krtDrvFillData)");
     return KRT_ERR; 
  };

  // Обнуляем экран
  for (i=0; i < trace_list[cur_trace].sens_num * my_length; i++) {
        screen[i]=0;
  };

  return KRT_OK;

}; // krtDrvFillData


long WINAPI krtDrvGetFirstNode ( KRTHANDLE handle, T_NODE *node,        
                                long start, long sensType, long sensIndex,
                                long length, long controlSize )
{
   long cur_trace;
   long my_start;
   
   if (open_trace_counter==0) {
      sprintf (drvError, "нет открытых трасс(krtDrvGetFirstNode)");
      return KRT_ERR;
   };

   // найдем открытую трассу в списке:
   for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
      if (handle==trace_list[cur_trace].handle) break;
   };

   if (cur_trace >= open_trace_counter) {
      sprintf(drvError, "не найден handle (krtDrvGetFirstNode)");
      return KRT_ERR; 
   };

   my_start = start/trace_list[cur_trace].trace_step;

   // настроим controlSize
   if (controlSize>0 && controlSize<length) {
      trace_list[cur_trace].controlSize=(double)(length)/(double)(controlSize);
    } else {
      trace_list[cur_trace].controlSize = trace_list[cur_trace].trace_step;
    };

   if (trace_list[cur_trace].controlSize < trace_list[cur_trace].trace_step)
    {
      trace_list[cur_trace].controlSize = trace_list[cur_trace].trace_step;
    };
   // настроили controlSize и теперь заполним остальные поля для krtDrvGetNextNode
   trace_list[cur_trace].nodeType = sensType;
   trace_list[cur_trace].nodeIndex = sensIndex;
   trace_list[cur_trace].nodePos = start;
   // заполним остальные поля для krtDrvGetNextNode

   switch (sensType) {

      case (KRT_SENS_ODO): {     // одометр
         node->Val=start;
         node->Pos=start;
         break;
      };

      case (KRT_SENS_TIMER): { // таймер
         node->Val=start;
         node->Pos=start;
         break;
      };

      case (KRT_SENS_ORIENT): {  // ориентация
         switch (sensIndex) {
            case(-1L):
            case(0): {
              node->Val = 0;
              node->Pos = start;
              break;
            };
         };
         break;
      };


      case (KRT_SENS_EXT): {    // вспомогательный
         if (my_start >= trace_list[cur_trace].trace_len) break;
         switch (sensIndex) {

            case (0): { // абсолютное давление
               // 
               if ( (strncmp(trace_list[cur_trace].device_ID, "1405", 4)==0) ||
                    (strncmp(trace_list[cur_trace].device_ID, "1410", 4)==0)
                  )
               {
                   // абс. давление для девайсов 1405, 1410
                   // P = (A-186)*3300 / 0,24 / 1023  кПа
                   node->Val=(long) (trace_list[cur_trace].bps_idx[my_start].abs_pressure - 186) * 
                                    3300 *100/24 / 1023 ;

               } else {
                   // для девайсов 1406, 1411, 1007, 1012
                   // P = (A-186)*3300/(16*150/13790*1023)  кПа
                   node->Val=(long) (trace_list[cur_trace].bps_idx[my_start].abs_pressure - 186) * 
                                    3300 / 178;
               }

               node->Pos = start;
               break;
            };

            case (1): { // дифференциальное давление

               // для 1406, 1405, 1411
               if ( (strncmp(trace_list[cur_trace].device_ID, "1406", 4)==0) ||
                    (strncmp(trace_list[cur_trace].device_ID, "1405", 4)==0) ||
                    (strncmp(trace_list[cur_trace].device_ID, "1410", 4)==0) ||
                    (strncmp(trace_list[cur_trace].device_ID, "1411", 4)==0) ||
                    (strncmp(trace_list[cur_trace].device_ID, "1007", 4)==0) ||
                    (strncmp(trace_list[cur_trace].device_ID, "1012", 4)==0) ||
                    (strncmp(trace_list[cur_trace].device_ID, "1206", 4)==0) ||
                    (strncmp(trace_list[cur_trace].device_ID, "1212", 4)==0)
                  )
               {
                   // dP = A*3300/(10.8*0.282*1023) кПа
                   node->Val=(long) trace_list[cur_trace].bps_idx[my_start].diff_pressure * 
                                3300 / 3139;

               } else {
                   // dP = (A*3300/1023-1250) *2*0,08) кПа
                   node->Val = (
                                  (long) trace_list[cur_trace].bps_idx[my_start].diff_pressure *
                                   3300 / 1023 - 1250
                               ) * 2 * 8 / 100;

//                  node->Val=(long) trace_list[cur_trace].bps_idx[my_start].diff_pressure;
               }
               node->Pos = start;
               break;
            };

            case (2): { // скорость
               double speed = trace_list[cur_trace].bps_idx[my_start].speed;
               speed *= trace_list[cur_trace].odometer_step;

               node->Val=(long) speed;
               node->Pos = start;
               break;
            };

            case (3): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].motor_state;
               node->Pos = start;
               break;
            };

            case (4): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].board_state;
               node->Pos = start;
               break;
            };

            case (5): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].choke_curr_position_ticks;
               node->Pos = start;
               break;
            };

            case (6): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].choke_curr_position_angle;
               node->Pos = start;
               break;
            };

            case (7): {
               node->Val=(long) trace_list[cur_trace].bps_idx[my_start].choke_position;
               node->Pos = start;
               break;
            };

            case (8): { // ток двигателя
               node->Val=(long) ( trace_list[cur_trace].bps_idx[my_start].motor_battary_current *
                                  1018) / 1000;
//               battary_current *= 0.0010175;

               node->Pos = start;
               break;
            };

            case (9): {  // напряжение

//               battary_voltage *= 0.127451;

//               if ((strncmp(trace_list[cur_trace].device_ID, "1406", 4)==0) ||
//                   (strncmp(trace_list[cur_trace].device_ID, "1411", 4)==0) ||
//                   (strncmp(trace_list[cur_trace].device_ID, "1405", 4)==0) ||
//                   (strncmp(trace_list[cur_trace].device_ID, "1410", 4)==0) ||
//                   (strncmp(trace_list[cur_trace].device_ID, "1007", 4)==0) ||
//                   (strncmp(trace_list[cur_trace].device_ID, "1012", 4)==0)
//                  )
//               {
                   // для 1406, 1411, 1405, 1410
                   // = A * 2,5 / 255 * 13
                   node->Val=(long) (trace_list[cur_trace].bps_idx[my_start].motor_battary_voltage *
                                     127451) / 1000;
//               } else {
//                   // = A * 2,5 / 255 * 11 = A * 10.784
//                   node->Val=(long) (trace_list[cur_trace].bps_idx[my_start].motor_battary_voltage *
//                                     10784 / 100);
//               }
               node->Pos = start;
               break;
            };

            case (10): { // одометер в см (поэтому делим на 10)
               double odometer = trace_list[cur_trace].bps_idx[my_start].Odometr;
               odometer *= trace_list[cur_trace].odometer_step / 10;

               node->Val=(long) odometer;
               node->Pos = start;
               break;
            };

            default:{
               sprintf(drvError, "bad sensIndex parameter(krtDrvGetFirstNode)");
               return KRT_ERR;
             };
          }; // switch (sensIndex)

          break;
      };  // case (KRT_SENS_EXT):    // вспомогательный

      default : {
        node->Val=start;
        node->Pos=start;
        sprintf(drvError, "bad sensType parameter(krtDrvGetFirstNode)");
        return KRT_ERR;
      };
   };

   return KRT_OK;
}; // krtDrvGetFirstNode


long WINAPI krtDrvGetNextNode ( KRTHANDLE handle, T_NODE *node) {

   long cur_trace;

   if (open_trace_counter==0) {
      sprintf (drvError, "нет открытых трасс(krtDrvGetNextNode)");
      return KRT_ERR;
    };

   // найдем открытую трассу в списке:
   for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
      if (handle==trace_list[cur_trace].handle) break;
    };
   if (cur_trace >= open_trace_counter) {
      sprintf(drvError, "не найден handle (krtDrvGetNextNode)");
      return KRT_ERR; 
    };

   trace_list[cur_trace].nodePos += (long)
               trace_list[cur_trace].controlSize;

   if (krtDrvGetFirstNode (handle, node, trace_list[cur_trace].nodePos,
                           trace_list[cur_trace].nodeType,
                           trace_list[cur_trace].nodeIndex, (long) trace_list[cur_trace].controlSize, 1
                          )
       == KRT_ERR)
    {
      strcat(drvError, "(krtDrvGetNextNode)");
      return KRT_ERR; 
    };

   return KRT_OK;
}; /* krtDrvGetNextNode */


long WINAPI krtDrvGetFirstNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node,
                                      long start, long sensGroup,
                                      long length, long controlSize )
{
   (void) handle;
   (void) node;
   (void) start;
   (void) sensGroup;
   (void) length;
   (void) controlSize;

   return KRT_OK;
}; // krtDrvGetFirstNodeGroup


long WINAPI krtDrvGetNextNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node)
{
   (void) handle;
   (void) node;

   return KRT_OK;
}; // krtDrvGetNextNodeGroup


long KRTAPI krtDrvRegister (
 const char * datFile, 
 const char * trcFile, 
 char **errText, 
 long (KRTAPI *userBreak) (short percentDone)
 ) 
{
   FILE * data_file;
   char file_name[1024];

   long data_path_len;
   char data_path[_MAX_PATH]; // путь до файлов с данными

   FILE *idx_file_data;
   char idx_file_name[1024];

   long file_counter, persent_value, read_len;

   struct T_BYPASS_HEADER bypas_header;

   struct T_BYPASS_INFO bypass_info;


   (void) errText;
   (void) userBreak;

   strcpy(file_name, &datFile[strlen(datFile)-9]);
   file_name[5]=0;
   file_counter = atoi(file_name);

   // выделим путь до файлов с данными из полного пути до первого файла
   strcpy(data_path, datFile);
   data_path_len=strlen(data_path);

   while ((data_path_len>0) && (data_path[data_path_len-1]!='\\')) {
     data_path[data_path_len - 1] = 0;
     data_path_len--;
   };

   sprintf(idx_file_name, "%sbaypas.idx", data_path);

   idx_file_data = fopen(idx_file_name, "wb");
   if (idx_file_data==NULL) {
       sprintf(drvError, "Ошибка открытия файла %s. \n", idx_file_name);
       return KRT_ERR;
   };

   sprintf(file_name, "%sBP%05ld.dat", data_path, file_counter);

   while ( (data_file = fopen(file_name, "rb")) != NULL) {

       read_len = fread( &bypas_header, 1, sizeof(struct T_BYPASS_HEADER), data_file);
       if (read_len != sizeof(struct T_BYPASS_HEADER)) {
          fclose(data_file);
          break;
       };

       persent_value = file_counter;
       if (persent_value<0)  persent_value=0;
       if (persent_value>99) persent_value=99;

       // проверка не пытается ли пользователь прервать нас принудительно и 
       // заодно передадим процент проделанной работы
       if (userBreak((short) persent_value ) ) {
          sprintf (drvError, "Отменено пользователем (krtDrvRegister)");

          fclose(data_file);
          data_file=NULL;

          fclose(idx_file_data);
          idx_file_data=NULL;
          return KRT_ERR;
       };


       while (fread( &bypass_info, 1, sizeof(struct T_BYPASS_INFO), data_file) 
           == sizeof(struct T_BYPASS_INFO))
       {

            fwrite(&(bypass_info.abs_pressure), 1, 15, idx_file_data);
            fwrite(&(bypass_info.Odometr), 1, sizeof(bypass_info.Odometr), idx_file_data);

       }; //  while (fread( &bypass_info, 1, sizeof(struct T_BYPASS_INFO), data_file) 


       fclose(data_file);
       data_file=NULL;

       file_counter++;

       sprintf(file_name, "%sbp%05ld.dat",  data_path, file_counter);

   }; //   while ( (data_file = fopen(file_name, "rb")) != NULL)

   fclose(idx_file_data);

   WritePrivateProfileString(DRIVER_DATA, "WORK_FILE_NAME", idx_file_name, trcFile);

   WritePrivateProfileString(DRIVER_DATA, "DEVICE_ID", bypas_header.id_str, trcFile);

   { //запишем шаг одометра
       double odometer_step = 5;
       char odometer_step_str[1024];


       if ( (strncmp(bypas_header.id_str, "1206", 4)==0) ||
            (strncmp(bypas_header.id_str, "1212", 4)==0)
          )
       {
          odometer_step = 3;
       }

       if ( 
            (strncmp(bypas_header.id_str, "1405", 4)==0) ||
            (strncmp(bypas_header.id_str, "1406", 4)==0) ||
            (strncmp(bypas_header.id_str, "1410", 4)==0) ||
            (strncmp(bypas_header.id_str, "1411", 4)==0) ||
            (strncmp(bypas_header.id_str, "1412", 4)==0) ||
            (strncmp(bypas_header.id_str, "1415", 4)==0) ||
            (strncmp(bypas_header.id_str, "1416", 4)==0)
          )
       {
          // длинна окружности = 100 * 5 = 166 * x;  => x = 500/166 =  3.012048192771;
          // т.е. изменение длинны в % относительно колеса с шагом 3 мм = 3.012048192771 / 3 = 1.004016064257

          odometer_step = 3.012048192771;
       }

       sprintf(odometer_step_str, "%f" ,odometer_step);
       WritePrivateProfileString(DRIVER_DATA, "odometer_step", odometer_step_str, trcFile);
   }


   // Автоматическое открытие нужных датчиков
   WritePrivateProfileString("UserSettings", "ctlExt00", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0Min", "74", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0Max", "4801", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0Size", "2", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0AutoBorders", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0Ruler1Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0Ruler2Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt0Ruler2Enable", "0", trcFile);

   WritePrivateProfileString("UserSettings", "ctlExt10", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1Min", "-4", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1Max", "198", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1Size", "2", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1AutoBorders", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1Ruler1Value", "-4096", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1Ruler2Value", "-4096", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt1Ruler2Enable", "0", trcFile);

   WritePrivateProfileString("UserSettings", "ctlExt20", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2Min", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2Max", "675", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2Size", "2", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2AutoBorders", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2Ruler1Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2Ruler2Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt2Ruler2Enable", "0", trcFile);

   WritePrivateProfileString("UserSettings", "ctlExt30", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3Min", "-127", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3Max", "127", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3Size", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3AutoBorders", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3Ruler1Value", "-127", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3Ruler2Value", "-127", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt3Ruler2Enable", "0", trcFile);

   WritePrivateProfileString("UserSettings", "ctlExt40", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4Min", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4Max", "255", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4Size", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4AutoBorders", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4Ruler1Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4Ruler2Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt4Ruler2Enable", "0", trcFile);

   WritePrivateProfileString("UserSettings", "ctlExt50", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5Min", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5Max", "255", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5Size", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5AutoBorders", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5Ruler1Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5Ruler2Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt5Ruler2Enable", "0", trcFile);


   WritePrivateProfileString("UserSettings", "ctlExt60", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6Min", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6Max", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6Size", "2", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6AutoBorders", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6Ruler1Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6Ruler2Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt6Ruler2Enable", "0", trcFile);

   WritePrivateProfileString("UserSettings", "ctlExt70", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7Min", "-1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7Max", "20", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7Size", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7AutoBorders", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7Ruler1Value", "-1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7Ruler2Value", "-1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt7Ruler2Enable", "0", trcFile);

   WritePrivateProfileString("UserSettings", "ctlExt80", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8Min", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8Max", "4095", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8Size", "2", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8AutoBorders", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8Ruler1Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8Ruler2Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt8Ruler2Enable", "0", trcFile);

   WritePrivateProfileString("UserSettings", "ctlExt90", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9Min", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9Max", "30000", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9Size", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9AutoBorders", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9Ruler1Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9Ruler2Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt9Ruler2Enable", "0", trcFile);

   WritePrivateProfileString("UserSettings", "ctlExt100", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10Min", "20065535", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10Max", "21186077", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10Size", "2", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10AutoBorders", "1", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10DiskretGraph", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10Reverse", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10Ruler1Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10Ruler1Color", "-2147483634", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10Ruler2Value", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10Ruler2Color", "-2147483641", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10Ruler1Enable", "0", trcFile);
   WritePrivateProfileString("UserSettings", "ctlExt10Ruler2Enable", "0", trcFile);
   // закончилось автоматическое открытие нужных датчиков

   return KRT_OK;
}; // krtDrvRegister

//////////////////////////////////////////////////////////////////////////
// закончились Callback - Функции
//////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////
// Функции экспортируемые драйвером
//////////////////////////////////////////////////////////////////////////

long EXPORT KRTAPI krtDriverInfo (T_DRVINFO *drv ) {
  if (drv==NULL) return KRT_ERR;

  drv->apiVer = KRT_APIVER;
  drv->krtDrvRegister = krtDrvRegister;
  return KRT_OK;

}; // krtDriverInfo (T_DRVINFO *drv )


long EXPORT KRTAPI krtOpenTrace(const char * traceFile, KRTHANDLE handle, T_TRACEINFO *inf, long draft){

   char bps_file_name[1024];
   FILE *bps_file;

   long file_length;

   long curent_trace;

   char data_path[1024];
   long data_path_len;
   char file_path[1024];

   long ext_sens_index;

   struct T_BYPASS_HEADER Bypas_header;


   inf->krtDrvError = krtDrvError; // а вдруг ош. кака, надо заполнить заранее

     // Проверим на корректность handle
    if (handle<=0) {
       sprintf (drvError, "handle не больше нуля(krtOpenTrace)");
       return KRT_ERR;
     };


    if (draft) {
       if (open_trace_counter>=MAX_TRACE) {
          sprintf (drvError, "Уже открыто слишком много трасс.(krtOpenTrace)");
          return KRT_ERR;
       };

       for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
          if (handle==trace_list[curent_trace].handle) {
             sprintf (drvError, "Повторное использование handle.(krtOpenTrace)");
             return KRT_ERR;
          };
       };

       curent_trace = open_trace_counter;

       trace_list[curent_trace].handle=handle;

       if (GetPrivateProfileString(DRIVER_DATA, "WORK_FILE_NAME", "", bps_file_name, sizeof(bps_file_name), traceFile) == 0)
       {
          sprintf (drvError, "Ошибка чтения имени рабочего файла %s.", traceFile);
          return KRT_ERR;
       };

       bps_file = fopen(bps_file_name, "rb");

       if (bps_file == NULL)
       {
           // выделим путь до файлов с данными из полного пути
           strcpy(data_path, traceFile);

           data_path_len=strlen(data_path);

           while ((data_path_len>0) && (data_path[data_path_len-1]!='\\')) {
              data_path[data_path_len - 1] = 0;
              data_path_len--;
           };

           sprintf(file_path, "%s%s", data_path, bps_file_name);
           bps_file = fopen(file_path, "rb");
           if (bps_file == NULL)
           {
               sprintf (drvError, "Ошибка открытия рабочего файла %s.", file_path);
               return KRT_ERR;
           }
       }

       fseek(bps_file, 0, SEEK_END);
       file_length = ftell(bps_file);

       GetPrivateProfileString(DRIVER_DATA, "DEVICE_ID", "", Bypas_header.id_str, 16, traceFile);
       strncpy(trace_list[curent_trace].device_ID, Bypas_header.id_str, 8);

       { // прочитаем шаг одомтра
            char odometer_step_str[1024];

            GetPrivateProfileString(DRIVER_DATA, "odometer_step", "5", odometer_step_str, 256, traceFile);
            trace_list[curent_trace].odometer_step = atof(odometer_step_str);
       }

       fseek(bps_file, 0, SEEK_SET);
       trace_list[curent_trace].bps_idx = malloc(file_length);
       fread (trace_list[curent_trace].bps_idx, 1, file_length, bps_file);

       fclose (bps_file);

       trace_list[curent_trace].trace_len = file_length / sizeof(trace_list[curent_trace].bps_idx[0]);
       trace_list[curent_trace].sens_num = 16;
       trace_list[curent_trace].trace_step = 100;

       open_trace_counter++;

       inf->sensGroups = 1; 
       inf->extSensors = 11;

       return KRT_OK;
    }; //   if (draft) {


    // о! а это уже повторный вызов krtOpenTrace с draft == 0
    if (open_trace_counter==0) {
       sprintf (drvError, "нет открытых трасс(krtOpenTrace)");
       return KRT_ERR;
    };

    // найдем открытую трассу в списке:
    for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
       if (handle==trace_list[curent_trace].handle) break;
    };

    if (curent_trace >= open_trace_counter) {
       sprintf(drvError, "не найден handle (krtOpenTrace)");
       return KRT_ERR; 
    };


    inf->sensGroups = 1;
    inf->askMetod   = SENS_ASK_DIST;
    inf->stepSize   = trace_list[curent_trace].trace_step;

    inf->group[0].num     = trace_list[curent_trace].sens_num;
    inf->group[0].type    = SENS_TYPE_HOLL;
    inf->group[0].minValue= 0;
    inf->group[0].maxValue= KRT_PALLETE_SIZE;

    inf->group[0].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
    inf->group[0].minRowVal= 0; // минимальное значение сырых данных 
    inf->group[0].maxRowVal= 65535; // максимальное значение сырых данных 

    inf->length   = trace_list[curent_trace].trace_len * trace_list[curent_trace].trace_step;

    inf->time     = 10000;

    inf->orientNum  = 1;
    inf->orientStep = trace_list[curent_trace].trace_step;

    inf->timerNum  = 1;
    inf->timerStep = trace_list[curent_trace].trace_step;  

    inf->odoNum  = 1;
    inf->odoStep = trace_list[curent_trace].trace_step;

    inf->speedMin = -100;
    inf->speedMax =  100;

    ext_sens_index=0;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 100000;
    strncpy (inf->extSens[ext_sens_index].name, "Абсолютное давление, кПа", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = -4096;
    inf->extSens[ext_sens_index].maxValue =  4096;
    strncpy (inf->extSens[ext_sens_index].name, "Разница давлений, кПа", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 4096;
    strncpy (inf->extSens[ext_sens_index].name, "Скорость, см/сек", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = -127;
    inf->extSens[ext_sens_index].maxValue = 127;
    strncpy (inf->extSens[ext_sens_index].name, "Состояние мотора", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 255;
    strncpy (inf->extSens[ext_sens_index].name, "Датчик положения заслонки, ед.АЦП", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 255;
    strncpy (inf->extSens[ext_sens_index].name, "Позиция заслонки в тиках", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 255;
    strncpy (inf->extSens[ext_sens_index].name, "Позиция заслонки", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = -1;
    inf->extSens[ext_sens_index].maxValue = 20;
    strncpy (inf->extSens[ext_sens_index].name, "Ожидаемая позиция заслонки", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 4095;
    strncpy (inf->extSens[ext_sens_index].name, "Ток мотора, mA", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 30000;
    strncpy (inf->extSens[ext_sens_index].name, "Напряжение, mV", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;

    inf->extSens[ext_sens_index].minValue = 0;
    inf->extSens[ext_sens_index].maxValue = 20065535;
    strncpy (inf->extSens[ext_sens_index].name, "Расстояние по одометру, см", EXT_SENS_NAME_LENGTH);
    ext_sens_index++;


       // Инициализируем указатели на Callback - Функции 
    inf->krtDrvFillData          = krtDrvFillData;
    inf->krtDrvGetFirstNode      = krtDrvGetFirstNode;
    inf->krtDrvGetNextNode       = krtDrvGetNextNode;
   // inf->krtDrvGetFirstNodeGroup = krtDrvGetFirstNodeGroup;
   // inf->krtDrvGetNextNodeGroup  = krtDrvGetNextNodeGroup;

    return KRT_OK;
}; // krtOpenTrace

long EXPORT KRTAPI krtCloseTrace ( KRTHANDLE handle) {
  int curent_trace; 

  if (open_trace_counter==0) {
     sprintf (drvError, "нет открытых трасс(krtCloseTrace)");
     return KRT_ERR;
   };

  // найдем открытую трассу в списке:
  for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
     if (handle==trace_list[curent_trace].handle) {
        // и закроем ее
        if ( trace_list[curent_trace].bps_idx != NULL) {
           free(trace_list[curent_trace].bps_idx);
           trace_list[curent_trace].bps_idx = NULL;
        };

        open_trace_counter--;

        trace_list[curent_trace].handle = trace_list[open_trace_counter].handle;

        trace_list[open_trace_counter].handle = 0;

        return KRT_OK;
      };
   };


  sprintf(drvError, "не найден handle (krtCloseTrace)");
  return KRT_ERR; 
}; // krtCloseTrace 
