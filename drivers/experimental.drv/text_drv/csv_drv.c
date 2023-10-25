
#include "csv_drv.h"

char drvError[1024];

T_TRACE_LIST trace_list[MAX_TRACE];
long open_trace_counter;


#include "csv_pars.c"


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

  long my_start  = start;
  long my_length = length;

  long cur_trace;

  long length_counter;
  long sens_counter;

  long table_row;
  long pos_in_screen;



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

  // проверим корректен ли параметр group
  if (group >= 1) {
     sprintf(drvError, "group неправильный (krtDrvFillData)");
     return KRT_ERR;
  };

  // Обнуляем экран на всякий случай
  for (i=0; i < trace_list[cur_trace].column_num * my_length; i++) {
        screen[i]=0;
  };


   // проверим корректна ли запрошенная начальная дистанция start 
  if ( my_start > trace_list[cur_trace].trace_len)
  {
     return KRT_OK;
  };

   // проверим корректна ли длинна запрошенного участка
  if ( my_start + my_length > trace_list[cur_trace].trace_len) {
     my_length = trace_list[cur_trace].trace_len - my_start;
  };

  table_row = my_start;

  // заполняем затребованный массив 
  for (length_counter=0; length_counter < my_length; length_counter++) {

    for (sens_counter=0; sens_counter < trace_list[cur_trace].column_num; sens_counter++ )
     {
          pos_in_screen = (length * sens_counter) + length_counter;

          screen[pos_in_screen] = (KRTDATA)
             trace_list[cur_trace].table[ trace_list[cur_trace].column_num * table_row + sens_counter];// * 200 / 4095;
          if (screen[pos_in_screen] >= 200) screen[pos_in_screen] = 199;

          rowData[pos_in_screen] =
             trace_list[cur_trace].table[ trace_list[cur_trace].column_num * table_row + sens_counter];
     }; // for (sens_counter==beg_sens;

     table_row++;

  }; // for (length_counter=0; length_counter < my_length; length_counter++) { 

  return KRT_OK;

}; // krtDrvFillData


long WINAPI krtDrvGetFirstNode ( KRTHANDLE handle, T_NODE *node,        
                                long start, long sensType, long sensIndex,
                                long length, long controlSize )
{
   long cur_trace;

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

   // настроим controlSize
   if (controlSize>0 && controlSize<length) {
      trace_list[cur_trace].controlSize=(double)(length)/(double)(controlSize);
    } else {
      trace_list[cur_trace].controlSize = 1;
    };

   if (trace_list[cur_trace].controlSize < 1)
    {
      trace_list[cur_trace].controlSize = 1;
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
        break;
      };  // case (KRT_SENS_EXT): {    // вспомогательный

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
   return KRT_OK;
}; // krtDrvGetFirstNodeGroup


long WINAPI krtDrvGetNextNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node)
{
   return KRT_OK;
}; // krtDrvGetNextNodeGroup


long KRTAPI krtDrvRegister (
 const char * datFile, 
 const char * trcFile, 
 char **errText, 
 long (KRTAPI *userBreak) (short percentDone)
 ) 
{

  char csv_file_name[1024];
  char tmp_str[1024];

  if (GetPrivateProfileString("CSV_CONFIGURATION", "FILE_NAME", "", csv_file_name, sizeof(csv_file_name), datFile) == 0)
  {
//     sprintf (drvError, "Ошибка чтения имени рабочего файла %s.", datFile);
//     return KRT_ERR;
     WritePrivateProfileString(DRIVER_DATA, "WORK_FILE_NAME", datFile, trcFile);
  } else {
     WritePrivateProfileString(DRIVER_DATA, "WORK_FILE_NAME", csv_file_name, trcFile);
  }


  if (GetPrivateProfileString("CSV_CONFIGURATION", "ROW_HEADER", "", tmp_str, sizeof(tmp_str), datFile) == 0)
  {
//     sprintf (drvError, "Ошибка чтения ROW_HEADER %s.", datFile);
//     return KRT_ERR;
     sprintf(tmp_str, "1");
  };

  WritePrivateProfileString(DRIVER_DATA, "ROW_HEADER", tmp_str, trcFile);

  if (GetPrivateProfileString("CSV_CONFIGURATION", "COLUMN_HEADER", "", tmp_str, sizeof(tmp_str), datFile) == 0)
  {
//     sprintf (drvError, "Ошибка чтения COLUMN_HEADER %s.", datFile);
//     return KRT_ERR;
     sprintf(tmp_str, "0");
  };

  WritePrivateProfileString(DRIVER_DATA, "COLUMN_HEADER", tmp_str, trcFile);


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

   char csv_file_name[1024];
   FILE *csv_file;

   long file_length;

   char* table_str;

   long curent_trace;

   char data_path[1024];
   long data_path_len;
   char file_path[1024];


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

       if (GetPrivateProfileString(DRIVER_DATA, "WORK_FILE_NAME", "", csv_file_name, sizeof(csv_file_name), traceFile) == 0)
       {
          sprintf (drvError, "Ошибка чтения имени рабочего файла %s.", traceFile);
          return KRT_ERR;
       };

       csv_file = fopen(csv_file_name, "rb");

       if (csv_file == NULL)
       {
           // выделим путь до файлов с данными из полного пути
           strcpy(data_path, traceFile);

           data_path_len=strlen(data_path);

           while ((data_path_len>0) && (data_path[data_path_len-1]!='\\')) {
              data_path[data_path_len - 1] = 0;
              data_path_len--;
           };

           sprintf(file_path, "%s%s", data_path, csv_file_name);
           csv_file = fopen(file_path, "rb");
           if (csv_file == NULL)
           {
               sprintf (drvError, "Ошибка открытия рабочего файла %s.", file_path);
               return KRT_ERR;
           }
       }

       fseek(csv_file, 0, SEEK_END);
       file_length = ftell(csv_file);
       fseek(csv_file, 0, SEEK_SET);

       table_str = malloc(file_length);
       if (table_str == NULL)
       {
          sprintf (drvError, "Ошибка выделения памяти под данные файла.");
          return KRT_ERR;
       }

       fread (table_str, 1, file_length, csv_file);

       fclose (csv_file);


       if (GetPrivateProfileString(DRIVER_DATA, "ROW_HEADER", "", csv_file_name, sizeof(csv_file_name), traceFile) == 0)
       {
          sprintf (drvError, "Ошибка чтения имени рабочего файла %s.", traceFile);
          return KRT_ERR;
       };
       trace_list[curent_trace].row_header    = atoi(csv_file_name);

       if (GetPrivateProfileString(DRIVER_DATA, "COLUMN_HEADER", "", csv_file_name, sizeof(csv_file_name), traceFile) == 0)
       {
          sprintf (drvError, "Ошибка чтения имени рабочего файла %s.", traceFile);
          return KRT_ERR;
       };
       trace_list[curent_trace].column_header = atoi(csv_file_name);


       trace_list[curent_trace].row_num  = 
           get_row_num ( trace_list[curent_trace].column_header, table_str, file_length);

       trace_list[curent_trace].column_num = 
           get_column_num ( trace_list[curent_trace].row_header,
                            trace_list[curent_trace].column_header,
                            table_str, file_length);


       trace_list[curent_trace].table = malloc(file_length*2);

       if (trace_list[curent_trace].table == NULL)
       {
          free (table_str);
          sprintf (drvError, "Ошибка выделения памяти под данные файла.");
          return KRT_ERR;
       }

       get_csv_table ( trace_list[curent_trace].row_header,
                       trace_list[curent_trace].column_header,
                       table_str,
                       trace_list[curent_trace].table,
                       trace_list[curent_trace].row_num,
                       trace_list[curent_trace].column_num
                     );

       free (table_str);

       trace_list[curent_trace].trace_len = trace_list[curent_trace].row_num;
       
       open_trace_counter++;

       inf->sensGroups = 1; 
       inf->extSensors = 0;

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
    inf->stepSize   = 5;

    inf->group[0].num     = trace_list[curent_trace].column_num;
    inf->group[0].type    = SENS_TYPE_HOLL;
    inf->group[0].minValue= 0;
    inf->group[0].maxValue= KRT_PALLETE_SIZE;

    inf->group[0].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
    inf->group[0].minRowVal= 0; // минимальное значение сырых данных 
    inf->group[0].maxRowVal= 4095; //65535; // максимальное значение сырых данных 

    inf->length   = trace_list[curent_trace].row_num;
	if (inf->length < 1000) inf->length = 1000;

    inf->time     = 10000;


    inf->orientNum  = 1;
    inf->orientStep = 5;

    inf->timerNum  = 1;
    inf->timerStep = 5;  

    inf->odoNum  = 1;
    inf->odoStep = 5;

    inf->speedMin = -100;
    inf->speedMax =  100;

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
        if ( trace_list[curent_trace].table != NULL) {
           free(trace_list[curent_trace].table);
           trace_list[curent_trace].table = NULL;
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
