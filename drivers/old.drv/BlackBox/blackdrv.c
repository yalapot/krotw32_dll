// 480ep_drv.c - драйвер просмотра данных електронного блока "480 epro" 
// программой KrotW32
//
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>


#include <KrtAPI.h>
#include "krtblack.h"

char warnString[1024];

FILE *new_arc_data;
char new_arc_name[1024];
word new_arc_del_bit_mask=0xFFFF;

int SensRoute[1024];

/* int SensRoute[KROT_BLACK_BOX_ALL_SENS] = {
  0,  3,  6,  9, 12, 16, 19, 22, 25, 28, 32, 35, 38, 41, 44, 48, 51, 54, 57, 60,
 64, 67, 70, 73, 76, 80, 83, 86, 89, 92, 96, 99,102,105,108,112,115,118,121,124,

  1,  4,  7, 10, 13, 17, 20, 23, 26, 29, 33, 36, 39, 42, 45, 49, 52, 55, 58, 61,
 65, 68, 71, 74, 77, 81, 84, 87, 90, 93, 97,100,103,106,109,113,116,119,122,125,

  2,  5,  8, 11, 14, 18, 21, 24, 27, 30, 34, 37, 40, 43, 46, 50, 53, 56, 59, 62,
 66, 69, 72, 75, 78, 82, 85, 88, 91, 94, 98,101,104,107,110,114,117,120,123,126,

 15, 31, 47, 63, 79, 95, 111,127 };*/


//////////////////////////////////////////////////////////////////////////
//Callback - Функции
//////////////////////////////////////////////////////////////////////////

const char* WINAPI krtDrvError(void){
  return drvError;
 };

long WINAPI krtDrvFillData( KRTHANDLE handle, long group, long start,
                           long length, KRTDATA *screen, long *rowData)
{
  long i, j; /* переменная для индексов в циклах */

  long my_start  = start; 
  long my_length = length;

  long curent_trace; /* индекс текущей трассы в списке откр. трасс */

  long pos_in_screen;


//  sprintf(drvError, "krtDrvFillData start= %d, length=%d, group=%d", start, length, group);
//  debugPoint(drvError);

   /* проверим на корректность handle : */
  if (handle<=0) return KRT_ERR;  // недопустимое значение handle
  if (open_trace_counter==0) return KRT_ERR; // нет открытых трасс
  for (i=0; i<open_trace_counter; i++) {
     if (handle==trace_list[i].handle) break;
   };
  if (i==open_trace_counter) {
     sprintf(drvError, "Unknown handle trace (krtDrvFillData)");
     return KRT_ERR; // нет такого handle
   } else curent_trace=i;


   /* проверим корректна ли запрошенная начальная дистанция start */
  if ( my_start > trace_list[curent_trace].full_trace_len ||
       my_start < 0 ) {
     sprintf(drvError, "Illegal start data (krtDrvFillData)");
     return KRT_ERR;
   };

   /* проверим корректна ли длинна запрошенного участка */
  if (my_start+my_length > trace_list[curent_trace].full_trace_len) {
     my_length = trace_list[curent_trace].full_trace_len - my_start;
   };

   /* попытаемся проверить корректность параметра screen */
  if (screen==NULL) {
     sprintf(drvError, "screen==NULL (krtDrvFillData)");
     return KRT_ERR;
   };


  for (i=0; i<KROT_BLACK_BOX_ALL_SENS*length; i++) {
     screen[i]=KRT_PALLETE_SIZE/2;
   };

  /* заполняем затребованный массив  */
  for (i=0; i<my_length; i++) { 
     for (j=0; j < KROT_BLACK_BOX_ALL_SENS; j++ ) { // j=номер физического датчика
       pos_in_screen=length*j + i;

       if (pos_in_screen<0) pos_in_screen=0;
       if (pos_in_screen>KROT_BLACK_BOX_ALL_SENS*length) pos_in_screen=0;

       screen[pos_in_screen]=trace_list[curent_trace].math_trace[my_start+i].sens[ SensRoute[j] ]
                          * KRT_PALLETE_SIZE/MAX_VALUE_DATA;

       if (screen[pos_in_screen]>199) screen[pos_in_screen]=199;
//       screen[pos_in_screen]=trace_list[curent_trace].math_trace[my_start+i].sens[j]
//                          * KRT_PALLETE_SIZE/MAX_VALUE_DATA;

       // заполним сырые данные 
       rowData[pos_in_screen] = trace_list[curent_trace].trace[my_start+i].sens[ SensRoute[j] ];
//       rowData[pos_in_screen] = trace_list[curent_trace].trace[my_start+i].sens[j];
     } //for (j=0; j < KROT_BLACK_BOX_ALL_SENS; j++ ) { 
  }; //for (i=0; i<my_length; i++) { 

  return KRT_OK;
}; /* krtDrvFillData */

long WINAPI krtDrvGetFirstNode ( KRTHANDLE handle, T_NODE *node,        
                                long start, long sensType, long sensIndex,
                                long length, long controlSize )
 {
  int i; /* переменная для индексов в циклах */

  int curent_trace;  /* индекс текущей трассы в списке откр. трасс */

   /* проверим на корректность handle : */
  if (handle<=0) return KRT_ERR;  // недопустимое значение handle
  if (open_trace_counter==0) return KRT_ERR; // нет открытых трасс
  for (i=0; i<open_trace_counter; i++) {
     if (handle==trace_list[i].handle) break;
   };
  if (i==open_trace_counter) {
     sprintf(drvError, "Unknown handle trace (krtDrvGetFirstNode)");
     return KRT_ERR; // нет  такого handle
   } else curent_trace=i;

   /* попытаемся проверить корректность параметра node */
  if (node==NULL) {
     sprintf(drvError, "node==NULL (krtDrvGetFirstNode)");
     return KRT_ERR;
   };

  node->Val=start;
  node->Pos = start;

  trace_list[curent_trace].start=start+1;

   return KRT_OK;
 }; /* krtDrvGetFirstNode */


long WINAPI krtDrvGetNextNode ( KRTHANDLE handle, T_NODE *node) {
  int i; /* переменная для индексов в циклах */

  int curent_trace;  /* индекс текущей трассы в списке откр. трасс */

   /* проверим на корректность handle : */
  if (handle<=0) return KRT_ERR;  // недопустимое значение handle
  if (open_trace_counter==0) return KRT_ERR; // нет открытых трасс
  for (i=0; i<open_trace_counter; i++) {
     if (handle==trace_list[i].handle) break;
   };
  if (i==open_trace_counter) {
     sprintf(drvError, "Unknown handle trace (krtDrvGetNextNode)");
     return KRT_ERR; // нет  такого handle
   } else curent_trace=i;

   /* попытаемся проверить корректность параметра node */
  if (node==NULL) {
     sprintf(drvError, "node==NULL (krtDrvGetNextNode)");
     return KRT_ERR;
   };

   node->Val = trace_list[curent_trace].start;
   node->Pos = trace_list[curent_trace].start;

   trace_list[curent_trace].start+=1;
                         

   return KRT_OK;
 }; /* krtDrvGetNextNode */



long WINAPI krtDrvGetFirstNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node,        
                                long start, long sensGroup,
                                long length, long controlSize )
 {
   return KRT_OK;
 }; /* krtDrvGetFirstNodeGroup  */


long WINAPI krtDrvGetNextNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node) {

   return KRT_OK;
 }; /* krtDrvGetNextNodeGroup */

/* функция регистрации записи */
long KRTAPI krtDrvRegister (
 LPSTR datFile, 
 LPSTR trcFile, 
 char **errText, 
 long (KRTAPI *userBreak) (short percentDone)
 ) 
{
  short percent=0;

  char current_path[MAXPATH];
  long  path_len;


  traceFile = trcFile;
  strcpy(current_path, datFile);
  path_len=strlen(current_path);

  while ((path_len>0) && (current_path[path_len-1]!='\\')){
    current_path[path_len-1]=0;
    path_len=strlen(current_path);
   };
 
  // запись необходимой информации в заданный trc-файл
  WritePrivateProfileString(KROT_BLACK_BOX_SECTION, DATA_PATH_KEY, current_path, trcFile);

  WritePrivateProfileString(KROT_BLACK_BOX_SECTION, "amplification_1_poyas", "10", trcFile);
  WritePrivateProfileString(KROT_BLACK_BOX_SECTION, "Invert_sensors", "", trcFile);

  WritePrivateProfileString(KROT_BLACK_BOX_SECTION, AVERAGE_LENGTH_KEY, "8", trcFile);


  return KRT_OK;
 }; /* krtDrvRegister */

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

}; /* krtDriverInfo (T_DRVINFO *drv ) */


long EXPORT KRTAPI krtOpenTrace(const LPSTR traceFile, KRTHANDLE handle, T_TRACEINFO *inf, long draft){
  long i, j; /* переменная для индексов в циклах */

  char current_path[MAXPATH];

  char file_name[_MAX_FNAME];

  FILE *dat_file;

  T_HEAD_OF_CONDITION_SEAM Head;

  T_RECORD_OF_ONE_CYCLE_INQUIRY dimension[CONDITIONAL_SEAM_STD_LEN];

  long current_len;

  long *P_average_sens;
  long *P_av_sens_old;

  long average_sens[KROT_BLACK_BOX_ALL_SENS];
  long av_sens_old[MAX_AVERAGE_LENGTH][KROT_BLACK_BOX_ALL_SENS];
  long av_sens_len;

  long average_length=8;
  long sens_counter;

  T_RECORD_OF_ONE_CYCLE_INQUIRY *data;
  T_RECORD_OF_ONE_CYCLE_INQUIRY *math_data;
  long translate_res;

  char str_cur_value[256];
  char tmp_str[1024];

  char seps[]   = " ,\t\n";
  char sub_seps[]   = " -\t\n";
  char *token;
  char *sub_token;

  long low_range, high_range, next_token; 
  long PeriodCounter;	
  long Period;
  long Phase;

  for (i=0; i < KROT_BLACK_BOX_ALL_SENS; i++)
	{SensRoute[i] = i;}

  inf->krtDrvError = krtDrvError; // а вдруг ош. кака, надо заполнить заранее

   //  debugPoint("Enter krtOpenTrace");


  if (draft) {
     // сначала заполним одинаковую для всех типов записи информацию
    inf->extSensors = 0;    // два дополнительных датчика
    inf->sensGroups = 1; // скока поясов развертки
    return KRT_OK;
   };


   /* Проверим на корректность handle */
  if (handle<=0) return KRT_ERR;
  if (open_trace_counter>=MAX_TRACE) {
     sprintf (drvError, "Уже открыто слишком много трасс.(krtOpenTrace)");
     return KRT_ERR;
   };

  for (i=0; i<open_trace_counter; i++) {
     if (handle==trace_list[i].handle) {
        sprintf (drvError, "Повторное использование handle.");
        return KRT_ERR;
      };
   };

   /* проверим на корректность inf */
  if (inf==NULL) {
     sprintf (drvError, "Параметр Inf==NULL");
     return KRT_ERR;
   };

  trace_list[open_trace_counter].handle=handle;

    /* читаем из trc-файла путь на рабочий каталог */
  if (GetPrivateProfileString(KROT_BLACK_BOX_SECTION , DATA_PATH_KEY, "",
           current_path, sizeof(current_path), traceFile)==0)
   {
     sprintf (drvError, "Ошибка чтения пути на данные из файла %s.", traceFile);
     return KRT_ERR;
   };

  if (GetPrivateProfileString(KROT_BLACK_BOX_SECTION, PERIOD_KEY, "",
          str_cur_value, sizeof(str_cur_value), traceFile)==0)
    {
     Period = 0; //sprintf (drvError, "Ошибка чтения периода прореживания %s.", traceFile);
    }
  else
  { 
      Period=atoi(str_cur_value);
  };
  

  if (GetPrivateProfileString(KROT_BLACK_BOX_SECTION, PHASE_KEY, "",
          str_cur_value, sizeof(str_cur_value), traceFile)==0)
   {
     Phase = 0;
      //sprintf (drvError, "Ошибка чтения фазы прореживания %s.", traceFile);
     
   }
  else
   {
     Phase=atoi(str_cur_value);  
   }  
  

  if (Phase>Period)
	{sprintf (drvError, "Фаза больше периода %s.", traceFile); 
	 return KRT_ERR; };

  // прочитаем переменные для усиления по поясам
  trace_list[open_trace_counter].amplification_1_poyas=0;
  if (GetPrivateProfileString(KROT_BLACK_BOX_SECTION, "amplification_1_poyas", "",
          str_cur_value, sizeof(str_cur_value), traceFile)==0)
   {
     sprintf (drvError, "Ошибка чтения усиления 1 пояса %s.", traceFile);
   };
  trace_list[open_trace_counter].amplification_1_poyas=atoi(str_cur_value);
  if ( trace_list[open_trace_counter].amplification_1_poyas==0) trace_list[open_trace_counter].amplification_1_poyas=1;

  // прочитаем размер окна пересчета математики
  if (GetPrivateProfileString(KROT_BLACK_BOX_SECTION, AVERAGE_LENGTH_KEY, "",
          str_cur_value, sizeof(str_cur_value), traceFile)==0)
   {
     sprintf (drvError, "Ошибка чтения размера окна пересчета математики %s.", traceFile);
   } else {
     average_length=atoi(str_cur_value);
   };
  if ( average_length>1023) average_length=1023;
  if ( average_length<1) average_length=1;
  

    /* читаем из senssort.ini-файла таблицу инвертирования сигнало датчиков */
    /* на всякий случай заполним таблицу инвертирования */
   for (i=0; i<KROT_BLACK_BOX_ALL_SENS; i++) {
      trace_list[open_trace_counter].invert_data[i]=0;
    };

   if (GetPrivateProfileString(KROT_BLACK_BOX_SECTION, "Invert_sensors", "",
           str_cur_value, sizeof(str_cur_value), traceFile)==0)
    {
      sprintf (drvError, "Ошибка чтения таблицы инверсии %s.", traceFile);
    } else {
      strcpy(tmp_str, str_cur_value);
      token = strtok(str_cur_value, seps );
      next_token=1;
      while (token!=NULL) {
         sub_token = strtok(token, sub_seps );
         if (sub_token==NULL) {
             low_range=0;
          } else {
             low_range=atoi(sub_token);
          };
         sub_token = strtok(NULL, seps );
         if (sub_token==NULL) {
             high_range=low_range;
          } else {
             high_range=atoi(sub_token);
          };
         if (high_range>=low_range) {
             for (i=low_range; i<=high_range; i++) {
                trace_list[open_trace_counter].invert_data[SensRoute[i]]=1;
             };
          };
         strcpy(str_cur_value, tmp_str);
         token = strtok(str_cur_value, seps );
         for (i=0; i<next_token; i++) {
            token = strtok(NULL, seps);
          };
         next_token++;
       };
    };
    /* прочитали таблицу инвертирования сигнало датчиков */


   strcpy(file_name, current_path);
   strcat(file_name, "tm00000.da");

   if (dat_file=fopen(file_name, "rb")) {

      trace_list[open_trace_counter].full_trace_len=0;
      PeriodCounter = 0;
      while (fread(&(Head.arc_mode), 1, sizeof(T_HEAD_OF_CONDITION_SEAM), dat_file)>0) {
         fread (&(dimension[0]), Head.real_inquiry,
                     sizeof(T_RECORD_OF_ONE_CYCLE_INQUIRY), dat_file);

         for (i=0; i<Head.real_inquiry; i++) {
			   if (PeriodCounter == Phase)  {
           trace_list[open_trace_counter].full_trace_len+=
						dimension[i].skip_cycle;};
				
			   PeriodCounter++;		
			   if (PeriodCounter > Period)
					{PeriodCounter = 0;};
		}; // if PeriodCounter=Period
      } ; // for (int i=0); 
   }; /* if (da t_file=fopen(file_name, "rb")) */

     /* файл закончился */
   fclose(dat_file);

   inf->length = trace_list[open_trace_counter].full_trace_len*10;
       
   
   inf->length-=10 * (Period + 1); // ха-ха а Витальке дадим на 1 см меньше, 
                    // т.к. считаем и 0 за отсчет 


   inf->askMetod=SENS_ASK_DIST;
   inf->stepSize=10;

   inf->group[0].num=KROT_BLACK_BOX_ALL_SENS;
   inf->group[0].type=SENS_TYPE_HOLL;
   inf->group[0].minValue=0;
   inf->group[0].maxValue=KRT_PALLETE_SIZE;
   inf->group[0].isRow=1;          // 1/0 если 0 сырые данные не поддерживаются
   inf->group[0].maxRowVal=MAX_VALUE_DATA; // максимальное значение сырых данных 
   inf->group[0].minRowVal=0;      // мин. значение сырых данных 

      /* */
   inf->odoNum=1;
   inf->odoStep=10;   // передается только для справки
                            // потом не используется а смотрится
                            // на pos узла датчика

     /* Инициализируем указатели на Callback - Функции */
   inf->krtDrvGetFirstNode      = krtDrvGetFirstNode;
   inf->krtDrvGetNextNode       = krtDrvGetNextNode;
   inf->krtDrvGetFirstNodeGroup = krtDrvGetFirstNodeGroup;
   inf->krtDrvGetNextNodeGroup  = krtDrvGetNextNodeGroup;
   inf->krtDrvFillData          = krtDrvFillData;


   trace_list[open_trace_counter].trace
         = malloc(sizeof(T_RECORD_OF_ONE_CYCLE_INQUIRY)*
                   trace_list[open_trace_counter].full_trace_len);
   if (trace_list[open_trace_counter].trace==NULL) {
      sprintf (drvError, "Ошибка выделения памяти.");
      return KRT_ERR;
    };

   trace_list[open_trace_counter].math_trace
         = malloc(sizeof(T_RECORD_OF_ONE_CYCLE_INQUIRY)*
                   trace_list[open_trace_counter].full_trace_len);
   if (trace_list[open_trace_counter].math_trace==NULL) {
      sprintf (drvError, "Ошибка выделения памяти.");
      return KRT_ERR;
    };

   strcpy(file_name, current_path);
   strcat(file_name, "tm00000.da");

   current_len=0;
   if (dat_file=fopen(file_name, "rb")) {
       PeriodCounter = 0; 
       while (fread(&(Head.arc_mode), 1, sizeof(T_HEAD_OF_CONDITION_SEAM), dat_file)>0) 
        {
         fread (&(dimension[0]), Head.real_inquiry, 
                              sizeof(T_RECORD_OF_ONE_CYCLE_INQUIRY), dat_file);

           for (i=0; i<Head.real_inquiry; i++) 
               {
                for (j=0; j<dimension[i].skip_cycle; j++) 
                  {
                    if (PeriodCounter == Phase)
                    {  
               memcpy(&trace_list[open_trace_counter].trace[current_len],
                      &dimension[i].skip_cycle, 
                      sizeof(T_RECORD_OF_ONE_CYCLE_INQUIRY));
               current_len++;
                    } ;// if (PeriodCounter == Phase) 
                    PeriodCounter++;
			        if (PeriodCounter > Period)
                      {PeriodCounter = 0;};                    
                  } 					 
          }; // for (int i=0; 
        }; // while
   }; /* if (dat_file=fopen(file_name, "rb")) */

     /* файл закончился */
   fclose(dat_file);

// ---------------------
   av_sens_len=1;
   data=trace_list[open_trace_counter].trace;
   math_data=trace_list[open_trace_counter].math_trace;


   for (i=0; i<KROT_BLACK_BOX_ALL_SENS; i++) {
      average_sens[i]=(data->sens[i])*256*average_length;
      for (j=0; j<average_length; j++) av_sens_old[j][i]=(data->sens[i])*256;
    };


   for (i=0; i<trace_list[open_trace_counter].full_trace_len; i++) {
       av_sens_len--;
       if (av_sens_len<0) av_sens_len=average_length-1;
       P_average_sens=average_sens;
       P_av_sens_old = &av_sens_old[av_sens_len][0];

       for (sens_counter=0; sens_counter<KROT_BLACK_BOX_ALL_SENS; sens_counter++) {

         if (trace_list[open_trace_counter].invert_data[sens_counter]==1) {
             data->sens[sens_counter]=MAX_VALUE_DATA-data->sens[sens_counter];
          };

         translate_res = data->sens[sens_counter];

         translate_res *= 256;
         *P_average_sens -= *P_av_sens_old;

         *P_average_sens += translate_res;
         *P_av_sens_old = *P_average_sens;

         *P_av_sens_old /= average_length;
         *P_average_sens -= translate_res;
         *P_average_sens += *P_av_sens_old;

         translate_res -= *P_av_sens_old;

         translate_res /= 256;

         translate_res *= trace_list[open_trace_counter].amplification_1_poyas;

         translate_res += MAX_VALUE_DATA/2;

         if (translate_res>MAX_VALUE_DATA) translate_res=MAX_VALUE_DATA;
           else if (translate_res<0) translate_res=0;


         math_data->sens[sens_counter]= (word) translate_res;

         P_average_sens++;
         P_av_sens_old++;
        }; // for sens_counter
      data++;
      math_data++;
    };
//--------------------------------
   open_trace_counter++;

  return KRT_OK;
 }; /* krtOpenTrace  */

long EXPORT KRTAPI krtCloseTrace ( KRTHANDLE handle) {
  int i; /* переменная для индексов в циклах */

   /* Проверим на корректность handle */
  if (handle<=0) return KRT_ERR;  // недопустимое значение handle
  if (open_trace_counter==0) return KRT_ERR; // нет открытых трасс
  for (i=0; i<open_trace_counter; i++) {
    if (handle==trace_list[i].handle) {

       free(trace_list[i].trace);
       free(trace_list[i].math_trace);

       open_trace_counter--;

       trace_list[i].handle      = trace_list[open_trace_counter].handle;
       trace_list[i].full_trace_len = trace_list[open_trace_counter].full_trace_len;
       trace_list[i].trace       = trace_list[open_trace_counter].trace;
       trace_list[i].math_trace  = trace_list[open_trace_counter].math_trace;
       return KRT_OK;
     };
   };

  return KRT_ERR; // нет такого handle
 }; /* krtCloseTrace */