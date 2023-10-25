
#include <int_unit.h>

#include <tracetool.h>

#include <raw_data_tools.c>

#include <krot_trc.c>

//////////////////////////////////////////////////////////////////////////
//Callback - Функции
//////////////////////////////////////////////////////////////////////////


long WINAPI krtDrvFillData( KRTHANDLE handle, long group, long start,
                           long length, KRTDATA *screen, long *rowData)
{
  long i;
  long my_start  = start;
  long my_length = length;

  long cur_trace;
  long cur_idx;
  long cur_dim;
  long num_dim_in_cur_seam;

  long length_counter;
  long sens_counter;

  long beg_sens;
  long end_sens;
  long pos_in_screen;
  long y_for_screen;

  T_OPENED_TRACE *P_trace;


//  {
//     char tmp_str[1024];
//
//     sprintf(tmp_str,"(krtDrvFillData) %ld\n", group);
//     MessageBox(NULL, tmp_str, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//  }

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

  P_trace = trace_list[cur_trace].trace;

  // проверим корректен ли параметр group
  if (group >= P_trace->idx_head.num_magn_sens_group) {
     sprintf(drvError, "group неправильный (krtDrvFillData)");
     return KRT_ERR;
  };

//  {
//     char tmp_str[1024];
//
//     sprintf(tmp_str,"(krtDrvFillData) P_trace->idx_head.senslines_define[group].sens_num = %ld\n", P_trace->idx_head.senslines_define[group].sens_num);
//     MessageBox(NULL, tmp_str, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//  }

  // Обнуляем экран на всякий случай
   for (i = 0; i < P_trace->idx_head.senslines_define[group].sens_num * my_length; i++)
   {
      screen[i]=0;
   };

   // проверим корректна ли запрошенная начальная дистанция start 
  if ( my_start > P_trace->trace_len ||
       my_start < P_trace->idx_trc[0].beg_trace)
  {
     return KRT_OK;
  };


  if( my_start < P_trace->idx_head.trace_len ) 
  {
     if (get_data(P_trace, my_start, my_length) == KRT_ERR)
         {
            return KRT_OK;
         };
  } else
  {
      return KRT_OK;
  };

  // Ищем где данные 
  for (cur_idx = 0; cur_idx < P_trace->idx_head.num_idx_in_table; cur_idx++)
  {
       if ( my_start <= P_trace->idx_trc[cur_idx].beg_trace + P_trace->idx_trc[cur_idx].real_len)
       {
           break;
       }
  };

  if (cur_idx == P_trace->idx_head.num_idx_in_table)
  {
      return KRT_OK;
  };

  cur_dim = my_start - P_trace->idx_trc[cur_idx].beg_trace;
  num_dim_in_cur_seam = P_trace->idx_trc[cur_idx].real_len;

  // начальный и конечнае датчики в общем массиве 
  beg_sens = end_sens = 0;
  for (i = 0; i < group; i++) {
      beg_sens += P_trace->idx_head.senslines_define[i].sens_num;
      end_sens += P_trace->idx_head.senslines_define[i].sens_num;
  };
  end_sens += P_trace->idx_head.senslines_define[group].sens_num;

  // заполняем затребованный массив 
  for (length_counter=0; length_counter < my_length; length_counter++) {

      for (sens_counter = beg_sens; sens_counter < end_sens; sens_counter++ )
       {
          y_for_screen = sens_counter - beg_sens;

          pos_in_screen = (length * y_for_screen) + length_counter;

          screen[pos_in_screen] =
              P_trace->idx_trc[cur_idx].records[cur_dim].all_sens_data[sens_counter];

          // проверим не превышает ли значение максимальное заявленное
          if (screen[pos_in_screen] >= KRT_PALLETE_SIZE) {
             screen[pos_in_screen] = KRT_PALLETE_SIZE-1;
          };
      }; // for (sens_counter==beg_sens;

      if (length_counter < (my_length-1)) { // проверим нужен ли след.усл.шов
          cur_dim++; 
          if (cur_dim >= num_dim_in_cur_seam) {

               cur_idx ++;

               if (cur_idx == P_trace->idx_head.num_idx_in_table)
               {
                  sprintf(drvError, "что-то не получается перейти к след. усл. шву(krtDrvFillData)");
                  return KRT_OK;
               }; // if (cur_idx == 

               cur_dim = 0;
               num_dim_in_cur_seam = P_trace->idx_trc[cur_idx].real_len;

               if (P_trace->idx_trc[cur_idx].records==NULL) break;
          };
      }; // if (lengt_counter < (my_length-1)) { // проверим нужен ли след.усл.шов

  }; // for (length_counter=0; length_counter < my_length; length_counter++) { 

//  {
//     MessageBox(NULL, "(krtDrvFillData) KRT_OK", "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//  }

  return KRT_OK;
}; // krtDrvFillData


long WINAPI krtDrvGetFirstNode ( KRTHANDLE handle, T_NODE *node,        
                                long start, long sensType, long sensIndex,
                                long length, long controlSize )
 {

   long my_start;

   long cur_trace;

   long idx_count;
   long test_count;

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

   my_start = (start/trace_list[cur_trace].trace->trace_step);

   // настроим controlSize
   if (controlSize>0 && controlSize<length) {
      trace_list[cur_trace].trace->controlSize = (long) ((double)(length)/(double)(controlSize));
   } else {
      trace_list[cur_trace].trace->controlSize = trace_list[cur_trace].trace->trace_step;
   };

   // настроили controlSize и теперь заполним остальные поля для krtDrvGetNextNode
   trace_list[cur_trace].trace->nodeType = sensType;
   trace_list[cur_trace].trace->nodeIndex = sensIndex;
   trace_list[cur_trace].trace->nodePos = start;
   // заполним остальные поля для krtDrvGetNextNode

   if ( my_start < 0) my_start = 0;

    // проверим корректна ли запрошенная начальная дистанция start 
   if ( my_start >= trace_list[cur_trace].trace->trace_len) 
   {
      sprintf(drvError, "Не попадает start=%i в трассу (krtDrvGetFirstNode)",start);
      my_start = trace_list[cur_trace].trace->trace_len-1;
      // return KRT_ERR;
   };

   // Ищем где данные 
   for (idx_count = 0; idx_count <  trace_list[cur_trace].trace->idx_head.num_idx_in_table; idx_count++)
   {
        if ( my_start <= ( trace_list[cur_trace].trace->idx_trc[idx_count].beg_trace + 
                           trace_list[cur_trace].trace->idx_trc[idx_count].real_len-1) )
        {
            break;
        }

       // попутно освобождаем память
       if ( trace_list[cur_trace].trace->idx_trc[idx_count].records != NULL)
       {
           free(trace_list[cur_trace].trace->idx_trc[idx_count].records);
           trace_list[cur_trace].trace->idx_trc[idx_count].records = NULL;
       }

   };

   if ( trace_list[cur_trace].trace->idx_trc[idx_count].records == NULL)
   {
        if ((idx_count-1 >= 0) && ( trace_list[cur_trace].trace->idx_trc[idx_count-1].records != NULL))
        {
            free(trace_list[cur_trace].trace->idx_trc[idx_count-1].records);
            trace_list[cur_trace].trace->idx_trc[idx_count-1].records = NULL;
        }

        get_block_data(trace_list[cur_trace].trace, idx_count);
   }
   test_count = my_start - trace_list[cur_trace].trace->idx_trc[idx_count].beg_trace;
   if (test_count<0) test_count = 0;

/*   {
       char tmp_str[1024];

       sprintf(tmp_str, "(krtDrvGetFirstNode)\n my_start=%ld\n idx_trc[idx_count].beg_trace = %ld\n idx_count = %ld\n test_count = %ld\n",
                   my_start, trace_list[cur_trace].trace->idx_trc[idx_count].beg_trace, idx_count, test_count);
       MessageBox(NULL, tmp_str, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
   }
*/

   switch (sensType) {

      case (KRT_SENS_ODO): {     // одометр
         node->Val=start;
         node->Pos=start;
         break;
      };

      case (KRT_SENS_TIMER): {   // таймер

         node->Val = 0;

         node->Val = trace_list[cur_trace].trace->idx_trc[idx_count].records[test_count].time;

         node->Pos = start;
         break;
      };

     case (KRT_SENS_EXT): {    // вспомогательный

//        switch (sensIndex) {


//           case (0): { // температура

              node->Val = trace_list[cur_trace].trace->idx_trc[idx_count].records[test_count].add_sensors[sensIndex];
              node->Pos = start;

              break;
//            };

//           default:{
//              node->Val=0;
//              node->Pos=start;
//              sprintf(drvError, "bad sensIndex parameter(krtDrvGetFirstNode)");
//              return KRT_OK;
//           };
//        }; // switch (sensIndex) {

        break;
     };  // case (KRT_SENS_EXT): {    // вспомогательный

     default : {
        node->Val=0;
        node->Pos=start;
        sprintf(drvError, "bad sensType parameter(krtDrvGetFirstNode)");
        return KRT_ERR;
     };
   };

   return KRT_OK;
 }; // krtDrvGetFirstNode


long WINAPI krtDrvGetNextNode ( KRTHANDLE handle, T_NODE *node) {

   long cur_trace;

//  {
//      MessageBox(NULL,
//     "(krtDrvGetNextNode) 111",
//     "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//  }

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

   trace_list[cur_trace].trace->nodePos += (long)
               trace_list[cur_trace].trace->controlSize;

   if (krtDrvGetFirstNode (handle, node, trace_list[cur_trace].trace->nodePos,
                           trace_list[cur_trace].trace->nodeType,
                           trace_list[cur_trace].trace->nodeIndex, (long) trace_list[cur_trace].trace->controlSize, 1
                          )
       == KRT_ERR)
   {
      strcat(drvError, "(krtDrvGetNextNode)");
      return KRT_ERR; 
   };

   return KRT_OK;
 }; // krtDrvGetNextNode

/*
long save_start;

long WINAPI krtDrvGetFirstNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node,        
                                long start, long sensGroup,
                                long length, long controlSize )
 {

  {
      MessageBox(NULL,
     "(krtDrvGetFirstNodeGroup) 111",
     "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);

  }
      node->vogx   = 0;
      node->vogy   = 0;
      node->vogz   = 0;
                                                                     
      node->vogext1= 0;
      node->vogext2= 0;
      node->vogext3= 0;
                                                               
      node->vogPos = start; //trace_list[curent_trace].VogData.cur_data.Dist*10;
      node->odoPos = start;

      save_start = start;

   return KRT_OK;
}; // krtDrvGetFirstNodeGroup


long WINAPI krtDrvGetNextNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node) {

  {
      MessageBox(NULL,
     "(krtDrvGetNextNodeGroup) 111",
     "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);

  }
      save_start++;

      node->vogx   = 0;
      node->vogy   = 0;
      node->vogz   = 0;
                                                                     
      node->vogext1= 0;
      node->vogext2= 0;
      node->vogext3= 0;
                                                               
      node->vogPos = save_start;
      node->odoPos = save_start;

   return KRT_OK;
}; // krtDrvGetNextNodeGroup


*/

#include <krot_register.c>


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


long EXPORT KRTAPI krtOpenTrace(const char * traceFile, KRTHANDLE handle, T_TRACEINFO *inf, long draft){

   long curent_trace;

   char key_name[1024];
   char key_value[1024];


   FILE *idx_file_data;
   char idx_file_name[1024];
   long idx_table_size;

   long ext_sens_index;

   long group_counter;


   inf->krtDrvError = krtDrvError; // а вдруг ош. кака, надо заполнить заранее

   // Проверим на корректность handle
  if (handle<=0) {
     sprintf (drvError, "handle не больше нуля(krtOpenTrace)");
     return KRT_ERR;
  };

//  {
//     char tmp_str[1024];
//
//     sprintf(tmp_str, "(krtOpenTrace) draft = %ld", draft);
//     MessageBox(NULL, tmp_str, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//  }

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

     trace_list[curent_trace].trace = init_opened_trace();

     if (trace_list[curent_trace].trace == NULL) {
        strcat (drvError, "(krtOpenTrace)");
        return KRT_ERR;
     };

     strcpy(trace_list[curent_trace].trace->trc_file_name, traceFile);
     
     // читаем из trc-файла путь на рабочий каталог
     sprintf(key_name, "%s", PATH_DATA_KEY);
     if (GetPrivateProfileString(DRIVER_DATA, key_name, "", key_value, sizeof(key_value), traceFile) == 0)
     {
         // вычленим строку пути до trc-файла (без имени самого файла)
         strcpy(key_value, traceFile);

         while((strlen(key_value)>0) && (key_value[strlen(key_value)-1]!='\\')) {
           key_value[strlen(key_value)-1]=0;
         };
     };
     strcpy(trace_list[curent_trace].trace->path_data, key_value);
     // прочитли из trc-файла путь на рабочий каталог

#pragma warning(disable : 4090)  // давим варнинг про константу-строку при передаче в функцию
     // читаем из trc-файла длинну трассы в отсчетах одометра
     trace_list[curent_trace].trace->trace_len =
                   Get_long_key( TRACE_LEN_KEY, DRIVER_DATA, -1, traceFile);
     if (trace_list[curent_trace].trace->trace_len == -1)
     {
        sprintf (drvError, "Ошибка чтения длинны трассы из файла %s.", traceFile);
        return KRT_ERR;
     };

     // читаем из trc-файла шаг одометра
     trace_list[curent_trace].trace->trace_step =
                   Get_long_key( TRACE_STEP_KEY, DRIVER_DATA, 5, traceFile);

     // читаем из trc-файла диаметер трубы
     trace_list[curent_trace].trace->Diameter =
                   Get_long_key( PIPE_DIAMETER_KEY, DRIVER_DATA, 100, traceFile);
	 
     // создаем и подгружаем индексы по открываемой трассе 
     sprintf(idx_file_name, "%strace.idx", trace_list[curent_trace].trace->path_data);

     idx_file_data = fopen(idx_file_name, "rb");
     if (idx_file_data==NULL) {
         sprintf(drvError, "Ошибка открытия файла %s. \n", idx_file_name);
         return KRT_ERR;
     };

     fseek(idx_file_data, 0-sizeof(trace_list[curent_trace].trace->idx_head), SEEK_END);
     fread( &(trace_list[curent_trace].trace->idx_head), 1, sizeof(trace_list[curent_trace].trace->idx_head), idx_file_data);

     idx_table_size = sizeof(T_IDX_TRC) * trace_list[curent_trace].trace->idx_head.num_idx_in_table;

     trace_list[curent_trace].trace->idx_trc = malloc(idx_table_size);

     fseek(idx_file_data, 0, SEEK_SET);
     fread( trace_list[curent_trace].trace->idx_trc,1 ,idx_table_size, idx_file_data);

     fclose(idx_file_data);
     idx_file_data=NULL;

     trace_list[curent_trace].trace->trace_time = 
                      trace_list[curent_trace].trace->idx_head.trace_time;


     // !!!!!! заполняем путь на лог файл на случай использования  Reg_Log(register_log_info);
     sprintf(register_log_file_name, "%sReg_Log.txt", trace_list[curent_trace].trace->path_data);

/*
  {
      sprintf(register_log_file_name, "%sReg_Log.txt", trace_list[curent_trace].trace->path_data);

      MessageBox(NULL, register_log_file_name, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);

      sprintf(register_log_info, "trace_list[curent_trace].trace->trace_len = %ld\n", trace_list[curent_trace].trace->trace_len);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "trace_list[curent_trace].trace->trace_step = %ld\n", trace_list[curent_trace].trace->trace_step);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "trace_list[curent_trace].trace->trace_time = %ld\n", trace_list[curent_trace].trace->trace_time);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "trace_list[curent_trace].trace->path_data = %s\n", trace_list[curent_trace].trace->path_data);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "trace_list[curent_trace].trace->first_file_index = %ld\n", trace_list[curent_trace].trace->first_file_index);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "trace_list[curent_trace].trace->trc_file_name = %s\n", trace_list[curent_trace].trace->trc_file_name);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "trace_list[curent_trace].trace->Diameter = %ld\n", trace_list[curent_trace].trace->Diameter);
      Reg_Log(register_log_info);

      sprintf(register_log_info, "num_idx_in_table = %ld\n", trace_list[curent_trace].trace->idx_head.num_idx_in_table);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "first_file_index = %ld\n", trace_list[curent_trace].trace->idx_head.first_file_index);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "trace_len = %ld\n", trace_list[curent_trace].trace->idx_head.trace_len);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "trace_time = %ld\n", trace_list[curent_trace].trace->idx_head.trace_time);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "full_record_size = %ld\n", trace_list[curent_trace].trace->idx_head.full_record_size);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "num_all_sens = %ld\n", trace_list[curent_trace].trace->idx_head.num_all_sens);
      Reg_Log(register_log_info);

      sprintf(register_log_info, "odometer_define.name = %s\n", trace_list[curent_trace].trace->idx_head.odometer_define.name);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "odometer_define.title = %s\n", trace_list[curent_trace].trace->idx_head.odometer_define.title);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "odometer_define.size = %ld\n", trace_list[curent_trace].trace->idx_head.odometer_define.size);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "odometer_define.int_type = %ld\n", trace_list[curent_trace].trace->idx_head.odometer_define.int_type);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "odometer_define.shift_in_record = %ld\n", trace_list[curent_trace].trace->idx_head.odometer_define.shift_in_record);
      Reg_Log(register_log_info);

      sprintf(register_log_info, "timer_define.name = %s\n", trace_list[curent_trace].trace->idx_head.timer_define.name);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "timer_define.title = %s\n", trace_list[curent_trace].trace->idx_head.timer_define.title);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "timer_define.size = %ld\n", trace_list[curent_trace].trace->idx_head.timer_define.size);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "timer_define.int_type = %ld\n", trace_list[curent_trace].trace->idx_head.timer_define.int_type);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "timer_define.shift_in_record = %ld\n", trace_list[curent_trace].trace->idx_head.timer_define.shift_in_record);
      Reg_Log(register_log_info);

      sprintf(register_log_info, "num_add_sens = %ld\n", trace_list[curent_trace].trace->idx_head.num_add_sens);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "others_sens_define[0].name = %s\n", trace_list[curent_trace].trace->idx_head.others_sens_define[0].name);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "others_sens_define[0].title = %s\n", trace_list[curent_trace].trace->idx_head.others_sens_define[0].title);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "others_sens_define[0].size = %ld\n", trace_list[curent_trace].trace->idx_head.others_sens_define[0].size);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "others_sens_define[0].int_type = %ld\n", trace_list[curent_trace].trace->idx_head.others_sens_define[0].int_type);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "others_sens_define[0].shift_in_record = %ld\n", trace_list[curent_trace].trace->idx_head.others_sens_define[0].shift_in_record);
      Reg_Log(register_log_info);

      sprintf(register_log_info, "num_magn_sens_group = %ld\n", trace_list[curent_trace].trace->idx_head.num_magn_sens_group);
      Reg_Log(register_log_info);

      sprintf(register_log_info, "senslines_define[0].name = %s\n", trace_list[curent_trace].trace->idx_head.senslines_define[0].name);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "senslines_define[0].title = %s\n", trace_list[curent_trace].trace->idx_head.senslines_define[0].title);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "senslines_define[0].size = %ld\n", trace_list[curent_trace].trace->idx_head.senslines_define[0].size);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "senslines_define[0].int_type = %ld\n", trace_list[curent_trace].trace->idx_head.senslines_define[0].int_type);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "senslines_define[0].sens_num = %ld\n", trace_list[curent_trace].trace->idx_head.senslines_define[0].sens_num);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "senslines_define[0].shift_in_record = %ld\n", trace_list[curent_trace].trace->idx_head.senslines_define[0].shift_in_record);
      Reg_Log(register_log_info);

      sprintf(register_log_info, "senslines_define[1].name = %s\n", trace_list[curent_trace].trace->idx_head.senslines_define[1].name);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "senslines_define[1].title = %s\n", trace_list[curent_trace].trace->idx_head.senslines_define[1].title);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "senslines_define[1].size = %ld\n", trace_list[curent_trace].trace->idx_head.senslines_define[1].size);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "senslines_define[1].int_type = %ld\n", trace_list[curent_trace].trace->idx_head.senslines_define[1].int_type);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "senslines_define[1].sens_num = %ld\n", trace_list[curent_trace].trace->idx_head.senslines_define[1].sens_num);
      Reg_Log(register_log_info);
      sprintf(register_log_info, "senslines_define[1].shift_in_record = %ld\n", trace_list[curent_trace].trace->idx_head.senslines_define[1].shift_in_record);
      Reg_Log(register_log_info);
  }
*/
     // скока поясов развертки:
     inf->sensGroups = trace_list[curent_trace].trace->idx_head.num_magn_sens_group; 

     inf->extSensors = trace_list[curent_trace].trace->idx_head.num_add_sens;

     open_trace_counter++;
      // открыли трассу

//     {
//        sprintf(register_log_info, "%s\n", "(krtOpenTrace) 22222");
//        Reg_Log(register_log_info);
//     }

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

  // заполним данные об открываемой трассе
  inf->sensGroups = trace_list[curent_trace].trace->idx_head.num_magn_sens_group;
  inf->askMetod   = SENS_ASK_DIST;
  inf->stepSize   = trace_list[curent_trace].trace->trace_step;

  // заполним параметры секторов
  for (group_counter = 0; group_counter < inf->sensGroups; group_counter++)
  {
      inf->group[group_counter].num     = trace_list[curent_trace].trace->idx_head.senslines_define[group_counter].sens_num;

      inf->group[group_counter].type    = SENS_TYPE_MFL;

      inf->group[group_counter].minValue= 0;
      inf->group[group_counter].maxValue= KRT_PALLETE_SIZE;

      inf->group[group_counter].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
      inf->group[group_counter].minRowVal= 0; // минимальное значение сырых данных 
      inf->group[group_counter].maxRowVal= 4096; // максимальное значение сырых данных 
  }

  // ха-ха а Витальке дадим на 1 измерение меньше, т.к. считаем и 0 за отсчет
  inf->length   = (trace_list[curent_trace].trace->trace_len - 1) *
                      trace_list[curent_trace].trace->trace_step;

  inf->time     = trace_list[curent_trace].trace->trace_time ;


  inf->orientNum  = 0;
  inf->orientStep = trace_list[curent_trace].trace->trace_step;

  inf->timerNum  = 1;
  inf->timerStep = trace_list[curent_trace].trace->trace_step;

  inf->odoNum  = 1;
  inf->odoStep = trace_list[curent_trace].trace->trace_step;

  inf->tempNum  = 0;
  inf->tempStep = trace_list[curent_trace].trace->trace_step;
  inf->tempMin  = -100;
  inf->tempMax  =  100;

  inf->speedMin = -100;
  inf->speedMax =  100;


  // Подключим вспомогательные датчики
  for (ext_sens_index = 0;
       ext_sens_index < trace_list[curent_trace].trace->idx_head.num_add_sens;
       ext_sens_index ++)
  {
     inf->extSens[ext_sens_index].minValue = 0;
     inf->extSens[ext_sens_index].maxValue = 10000;
     strncpy (
      inf->extSens[ext_sens_index].name, 
      trace_list[curent_trace].trace->idx_head.others_sens_define[ext_sens_index].name, 
      EXT_SENS_NAME_LENGTH
     );
  }

     // Инициализируем указатели на Callback - Функции 
  inf->krtDrvFillData          = krtDrvFillData;
  inf->krtDrvGetFirstNode      = krtDrvGetFirstNode;
  inf->krtDrvGetNextNode       = krtDrvGetNextNode;


//  inf->krtDrvGetFirstNodeGroup = krtDrvGetFirstNodeGroup;
//  inf->krtDrvGetNextNodeGroup  = krtDrvGetNextNodeGroup;

/*
  {
      MessageBox(NULL,
     "(krtOpenTrace) 22222",
     "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);

      sprintf(register_log_info, "%s\n", "(krtOpenTrace) 22222");
      Reg_Log(register_log_info);
  }
*/

  return KRT_OK;
}; // krtOpenTrace

long EXPORT KRTAPI krtCloseTrace ( KRTHANDLE handle) {
  int curent_trace; 

  long cur_idx;

  if (open_trace_counter==0) {
     sprintf (drvError, "нет открытых трасс(krtCloseTrace)");
     return KRT_ERR;
   };

  // найдем открытую трассу в списке:
  for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
     if (handle==trace_list[curent_trace].handle) {

        for (cur_idx=0; cur_idx < trace_list[curent_trace].trace->idx_head.num_idx_in_table; cur_idx++)
        {
            if ( trace_list[curent_trace].trace->idx_trc[cur_idx].records != NULL) {
                free(trace_list[curent_trace].trace->idx_trc[cur_idx].records);
                trace_list[curent_trace].trace->idx_trc[cur_idx].records = NULL;
            };
        };

        if (trace_list[curent_trace].trace->idx_trc != NULL)
        {
            free(trace_list[curent_trace].trace->idx_trc);
            trace_list[curent_trace].trace->idx_trc = NULL;
        }

        // и закроем ее
        free_opened_trace(trace_list[curent_trace].trace);

        open_trace_counter--;

        trace_list[curent_trace].handle = trace_list[open_trace_counter].handle;
        trace_list[curent_trace].trace  = trace_list[open_trace_counter].trace;

        trace_list[open_trace_counter].handle = 0;
        trace_list[open_trace_counter].trace  = NULL;

        return KRT_OK;
      };
   };

  sprintf(drvError, "не найден handle (krtCloseTrace)");
  return KRT_ERR; 

}; // krtCloseTrace
