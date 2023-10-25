// epro_drv.c - тела callback-функций и функции экспортируемых драйвером
// просмотра данных електронного блока "epro" 
// для программы KrotW32
//
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>


#include "krtapi.h"
#include "navigate.h"
#include "krotepro.h"
#include "libdafil.h"
#include "heapinsp.h"

//#define RAZVOROT_PROSMOTRA

FILE *call_log;
char tmp_log_str[1024];
char name_log_str[1024];


#ifdef CALL_LOG

#define LOG_FILE "c:\\epro_log.txt"

void Log(char *LogString) {
 fprintf(call_log, "%s", LogString);
}

#endif


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
        call_log = NULL;

        #ifdef CALL_LOG
        // call_log = fopen(name_log_str, "at");
        call_log = fopen(LOG_FILE, "at");
        if (call_log == NULL)
        {

        //    MessageBox(NULL, "Не удается сохранить Log File на с:",MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
            MessageBoxEx(NULL, "Не удается сохранить Log File на с:","KRT_ERR",MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL, 0x419);

            return FALSE;
        }
        #endif

        break;
   };

   case DLL_PROCESS_DETACH: {

      if (call_log != NULL)  fclose(call_log);
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
  long my_start  = start+1;
  long my_length = length;

  long cur_trace;
  long cur_file;
  long cur_seam;
  long cur_dim;
  long num_dim_in_cur_seam;

  long next_file;
  long next_seam;
  long next_dim;
  long num_dim_in_next_seam;
  long serch_data_flag;

  long length_counter;
  long sens_counter;

  long beg_sens;
  long end_sens;
  long orient_for_cur_dim;
  long y_for_screen;
  long pos_in_screen;
  long shift_dim;

  T_RECORD_EXTEND_SENS record_extended_sens;

  T_OPENED_TRACE *P_trace;

  long start_for_get_data, length_for_get_data;

#ifdef RAZVOROT_PROSMOTRA
  long tmp_value_sens;
#endif


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

#ifdef RAZVOROT_PROSMOTRA
  // для просмотра в обратную сторону
  my_start  = P_trace->trace_len - start - length;
#endif

  // проверим корректен ли параметр group
  if (group >= P_trace->group_num) {
     sprintf(drvError, "group неправильный (krtDrvFillData)");
     return KRT_ERR;
   };

  // Обнуляем экран на всякий случай
   for (i=0; i<P_trace->real_number_sensor_in_group[group]*my_length; i++) {
         screen[i]=0;
       };
  if (P_trace->Median_Filter_length > 0)
  {
      my_start += P_trace->Median_Filter_length / 2;
  };

   // проверим корректна ли запрошенная начальная дистанция start 
  if ( my_start > P_trace->trace_len ||
       my_start < P_trace->file_index[0].beg_track)
   {
     return KRT_OK;
   };

   // проверим корректна ли длинна запрошенного участка
  if (my_start+my_length > P_trace->trace_len) {
     my_length = P_trace->trace_len - my_start;
  };


  start_for_get_data = my_start;
  length_for_get_data = my_length+200;

  if (P_trace->Median_Filter_length > 0)
  {
     start_for_get_data -= (P_trace->Median_Filter_length * 2);
     if (start_for_get_data < 1) start_for_get_data = 1;

     length_for_get_data = length_for_get_data += (P_trace->Median_Filter_length * 2);
     if (start_for_get_data + length_for_get_data > P_trace->trace_len) {
        length_for_get_data = P_trace->trace_len - start_for_get_data;
           };
      };

  if( my_start < P_trace->file_index[ P_trace->num_file_data-1 ].end_track ) 
  {
     if (get_data(P_trace, start_for_get_data, length_for_get_data) == KRT_ERR)
     {
        return KRT_OK;
  };
  } else
  {
      return KRT_OK;
      };
 
  cur_file = P_trace->list_loaded_data->file;
  cur_seam = P_trace->list_loaded_data->seam;
  cur_dim = my_start - P_trace->file_index[cur_file].index_seam[cur_seam].beg_track;
  num_dim_in_cur_seam = P_trace->file_index[cur_file].index_seam[cur_seam].head_of_condition_seam->real_dim;

  if ( cur_dim >= num_dim_in_cur_seam)
  {
      serch_data_flag = 0;
      do {
         if ((cur_seam>=P_trace->file_index[cur_file].num_condition_seam-1)
              ||
             ((cur_file==P_trace->num_file_data-1)
               &&
              (cur_seam>=P_trace->file_index[cur_file].num_condition_seam-2)
             )
            )
         {
             // еще и из следующего файла
             if (cur_file==P_trace->num_file_data-1)
             {
                 // получается и вовсе неоткуда брать, пихаем фон
      return KRT_OK;
             } else { // if (cur_file==cur_seam==P_trace->num_file_data-1)
                 // ну берем из первого усл. шва следующего файла
                 cur_file++;
                 cur_seam=0;
             }; // } else { // if (cur_file==cur_seam==P_trace->num_file_data-1)
         } else { // if (cur_seam==P_trace->file_index[cur_file].num_condition_seam-1)
             // просто берем из следующего усл. шва
             cur_seam++;
         };// } else { // if (cur_seam==P_trace->file_index[cur_file].num_condition_seam-1)
         cur_dim-=num_dim_in_cur_seam;
         num_dim_in_cur_seam = P_trace->file_index[cur_file].index_seam[cur_seam].head_of_condition_seam->real_dim;
         if (cur_dim < num_dim_in_cur_seam) serch_data_flag=1;
      } while (serch_data_flag==0);

  }; // if ( cur_dim >= num_dim_in_cur_seam)

  switch(group) {

    case 0: {
        beg_sens = 0;
        end_sens = P_trace->linesense_size[group];
        break;
     };
    default: {
        beg_sens = 0;
        end_sens = 0;
        for (i=0; i<group; i++) {
            beg_sens += P_trace->linesense_size[i];
            end_sens += P_trace->linesense_size[i];
         };
        end_sens   += P_trace->linesense_size[group];
     };
  };

  // заполняем затребованный массив 
  for (length_counter=0; length_counter < my_length; length_counter++) {

    if (P_trace->Orientation_OFF==0) {

        fseek(P_trace->index_extend_sens.file_data,
              (my_start+length_counter - P_trace->file_index[0].beg_track)
                      * sizeof(record_extended_sens),
              SEEK_SET
             );

        fread(&record_extended_sens,
              1,sizeof(record_extended_sens),
              P_trace->index_extend_sens.file_data);

       orient_for_cur_dim = 
                 ((record_extended_sens.orient
                   *P_trace->real_number_sensor_in_group[group])
                  /P_trace->real_number_sensor_in_group[0]
                 );

       orient_for_cur_dim+=P_trace->Orientation_shift;

       if (group>0) { //поправка для второго пояса
           orient_for_cur_dim+=P_trace->Orientation_shift_2;
        };

     } else {
       orient_for_cur_dim = 0;
     };

    while (orient_for_cur_dim<0) {
       orient_for_cur_dim += (P_trace->real_number_sensor_in_group[group]);
     };
    orient_for_cur_dim %= (P_trace->real_number_sensor_in_group[group]);

    for (sens_counter=0; sens_counter < P_trace->corosion_sens_num; sens_counter++ )
     {
       if (P_trace->Delete_sens_data[sens_counter] != SENSE_DELETE_FLAG)
        {
          y_for_screen = sens_counter - //P_trace->sens_sort[sens_counter] -
                         P_trace->Delete_sens_data[sens_counter];
//                           [P_trace->sens_sort[sens_counter]
//                           ];
          if (sens_counter>=beg_sens && sens_counter<end_sens ) {
             if (P_trace->Orinteation_Direct_count!=0) {
                y_for_screen -= orient_for_cur_dim;
              } else {
                y_for_screen += orient_for_cur_dim;
              };

             while (y_for_screen<0) {
                y_for_screen += P_trace->real_number_sensor_in_group[group];
              };

             y_for_screen %= (P_trace->real_number_sensor_in_group[group]);


             pos_in_screen = (length * y_for_screen) + length_counter;

             // проверим попала ли позиция в экране в границы массива, а то мало ли
      //            if ( pos_in_screen < 0 || 
      //                 pos_in_screen >= (P_trace->linesense_size[group]*length)
      //               ) pos_in_screen=0;

             shift_dim = cur_dim + P_trace->sens_shift[sens_counter];
                                   // ^^^^^ плюс продольное смещение датчика

             if ( shift_dim >= 0)
             {
             // не выдавило ли нас смещение за текущий условный шов
             if (shift_dim < num_dim_in_cur_seam) {

                    if ((P_trace->corosion_sens_num==80 && group==0) ||
                        (P_trace->corosion_sens_num==64 && group==0) ||
                        (P_trace->corosion_sens_num==40 && group==0) ||
                        (P_trace->corosion_sens_num==160 && (group==0 || group==1))
                   )
                 {
                    screen[pos_in_screen] = (KRTDATA)
                           P_trace->file_index[cur_file].index_seam[cur_seam].inquiry[shift_dim].math_sens[sens_counter];
                 } else {
                    screen[pos_in_screen] = (KRTDATA)
                         (
                           (P_trace->file_index[cur_file].index_seam[cur_seam].inquiry[shift_dim].math_sens[sens_counter]
                            *
                            KRT_PALLETE_SIZE
                           )
                           / P_trace->max_data_code);
                 };
                rowData[pos_in_screen] =
                        P_trace->file_index[cur_file].index_seam[cur_seam].inquiry[shift_dim].sens[sens_counter];

              } else { //if (shift_dim < num_dim_in_cur_seam)
                // о, так это надо из следующего условного шва брать
                next_file = cur_file;
                next_seam = cur_seam;
                next_dim = shift_dim;
                num_dim_in_next_seam=num_dim_in_cur_seam;
                serch_data_flag=0;

                do {
                       if ((next_seam>=P_trace->file_index[next_file].num_condition_seam-1)
                        ||
                           ((next_file==P_trace->num_file_data-1)
                         &&
                            (next_seam>=P_trace->file_index[next_file].num_condition_seam-2)
                       )
                      )
                    {
                      // еще и из следующего файла
                          if (next_file==P_trace->num_file_data-1)
                       {
                         // получается и вовсе неоткуда брать, пихаем фон
                         screen[pos_in_screen] = KRT_PALLETE_SIZE / 2;
                         rowData[pos_in_screen] = 0;
                         serch_data_flag=2;
                           } else { // if (cur_file==cur_seam==P_trace->num_file_data-1)
                         // ну берем из первого усл. шва следующего файла
                         next_file++;
                         next_seam=0;
                           }; // } else { // if (cur_file==cur_seam==P_trace->num_file_data-1)
                        } else { // if (cur_seam==P_trace->file_index[cur_file].num_condition_seam-1)
                      // просто берем из следующего усл. шва
                      next_seam++;
                        };// } else { // if (cur_seam==P_trace->file_index[cur_file].num_condition_seam-1)
                   next_dim-=num_dim_in_next_seam;
					   if (P_trace->file_index[next_file].index_seam[next_seam].head_of_condition_seam == NULL)
					   {
						   continue;
					   };
                       num_dim_in_next_seam = P_trace->file_index[next_file].index_seam[next_seam].head_of_condition_seam->real_dim;
                   if (next_dim < num_dim_in_next_seam) serch_data_flag=1;
                   if (serch_data_flag==1) {

                          if ((P_trace->corosion_sens_num==80 && group==0) ||
                              (P_trace->corosion_sens_num==64 && group==0) ||
                              (P_trace->corosion_sens_num==40 && group==0) ||
                              (P_trace->corosion_sens_num==160 && (group==0 || group==1))
                         )
                       {
                          screen[pos_in_screen] = (KRTDATA)
                                 P_trace->file_index[next_file].index_seam[next_seam].inquiry[next_dim].math_sens[sens_counter];
                       } else {
                          screen[pos_in_screen] =  (KRTDATA)
                             (
                              (P_trace->file_index[next_file].index_seam[next_seam].inquiry[next_dim].math_sens[sens_counter]
                               *
                               KRT_PALLETE_SIZE
                              )
                              / P_trace->max_data_code);
                       };
                      rowData[pos_in_screen] =
                              P_trace->file_index[next_file].index_seam[next_seam].inquiry[next_dim].sens[sens_counter];
                    };
                 } while (serch_data_flag==0);
              };// else { if (shift_dim < num_dim_in_cur_seam)

             } else {
                 screen[pos_in_screen] = 0;
             };

             // проверим не превышает ли значение максимальное заявленное
             if (screen[pos_in_screen] >= KRT_PALLETE_SIZE) {
                screen[pos_in_screen] = KRT_PALLETE_SIZE-1;
              };
           };
        };// if (P_trace->Delete_sens_data[sens_counter] != SENSE_DELETE_FLAG)

     }; // for (sens_counter==beg_sens;


    if (length_counter < (my_length-1)) { // проверим нужен ли след.усл.шов
        cur_dim++; 
        if (cur_dim >= num_dim_in_cur_seam) {
           //переходим в след. усл. шов
           cur_seam++;
           if (cur_seam >= P_trace->file_index[cur_file].num_condition_seam) {
               cur_file++;
               if (cur_file >= P_trace->num_file_data) {
                  sprintf(drvError, "что-то не получается перейти к след. усл. шву(krtDrvFillData)");
                  return KRT_ERR;
                }; // if (cur_file >= 
               cur_seam = 0;
            }; // if (cur_seam >= 
           cur_dim = 0;

           if (P_trace->file_index[cur_file].index_seam[cur_seam].head_of_condition_seam==NULL) break;
           num_dim_in_cur_seam = P_trace->file_index[cur_file].index_seam[cur_seam].head_of_condition_seam->real_dim;
         }; // if (cur_dim >= num_dim_in_cur_seam)
    }; // if (lengt_counter < (my_length-1)) { // проверим нужен ли след.усл.шов
  }; // for (length_counter=0; length_counter < my_length; length_counter++)

/*
  {// а тут мы инвертируем порядок датчиков
     long dim_counter;
     long sens_counter;
     long invert_pos_in_screen;
     KRTDATA tmp_screen;
     long tmp_rowData;

     for (dim_counter = 0; dim_counter < length; dim_counter++)
     {
         for (sens_counter = 0; sens_counter < P_trace->real_number_sensor_in_group[group]/2;sens_counter++)
         {
            pos_in_screen = (length * sens_counter) + dim_counter;
            invert_pos_in_screen = (length * (P_trace->real_number_sensor_in_group[group] - 1 - sens_counter)) + dim_counter;


            tmp_screen = screen[pos_in_screen];
            screen[pos_in_screen] = screen[invert_pos_in_screen];
            screen[invert_pos_in_screen] = tmp_screen;


            tmp_rowData = rowData[pos_in_screen];
            rowData[pos_in_screen] = rowData[invert_pos_in_screen];
            rowData[invert_pos_in_screen] = tmp_rowData;

         }
     }

  } // проинвертировали порядок датчиков
*/

#ifdef RAZVOROT_PROSMOTRA

  // разворачиваем картинку для показа в обратную сторону
  for (length_counter=0; length_counter < length/ 2; length_counter++)
  { 
     for(sens_counter=0; sens_counter < P_trace->real_number_sensor_in_group[group]; sens_counter++)
     {
          tmp_value_sens = screen[length * sens_counter + length_counter];
          screen[length * sens_counter + length_counter] = 
                    screen[length * sens_counter + length - length_counter - 1];
          screen[length * sens_counter + length - length_counter - 1] = (unsigned char) tmp_value_sens;


          tmp_value_sens = rowData[length * sens_counter + length_counter];
          rowData[length * sens_counter + length_counter] = 
                    rowData[length * sens_counter + length - length_counter - 1];
          rowData[length * sens_counter + length - length_counter - 1] = tmp_value_sens;
     };
  };

  for (length_counter=0; length_counter < length; length_counter++)
  { 
     for(sens_counter=0; sens_counter < P_trace->real_number_sensor_in_group[group]/2; sens_counter++)
     {
          tmp_value_sens = screen[length * sens_counter + length_counter];
          screen[length * sens_counter + length_counter] = 
              screen[length * (P_trace->real_number_sensor_in_group[group] - sens_counter-1) + length_counter];
          screen[length * (P_trace->real_number_sensor_in_group[group] - sens_counter-1) + length_counter]
              = (unsigned char) tmp_value_sens;


          tmp_value_sens = rowData[length * sens_counter + length_counter];
          rowData[length * sens_counter + length_counter] = 
              rowData[length * (P_trace->real_number_sensor_in_group[group] - sens_counter-1) + length_counter];
          rowData[length * (P_trace->real_number_sensor_in_group[group] - sens_counter-1) + length_counter]
              = tmp_value_sens;
     };
  };

#endif

  return KRT_OK;
}; // krtDrvFillData


long WINAPI krtDrvGetFirstNode ( KRTHANDLE handle, T_NODE *node,        
                                long start, long sensType, long sensIndex,
                                long length, long controlSize )
 {
   long my_start;

   long cur_trace;

   long my_start_vog;

   T_RECORD_EXTEND_SENS record_extended_sens;
   T_RECORD_POWER_DATA record_power_data;
   T_BYPASS_IDX record_bypass_data;

   memset( &record_extended_sens, sizeof(record_extended_sens), 0);
   memset( &record_power_data, sizeof(record_power_data), 0);

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
      trace_list[cur_trace].trace->controlSize=(double)(length)/(double)(controlSize);
    } else {
      trace_list[cur_trace].trace->controlSize=trace_list[cur_trace].trace->trace_step;
    };

   my_start = (start/trace_list[cur_trace].trace->trace_step);

   if (trace_list[cur_trace].trace->controlSize<trace_list[cur_trace].trace->trace_step)
    {
      trace_list[cur_trace].trace->controlSize=trace_list[cur_trace].trace->trace_step;
    };
   // настроили controlSize и теперь заполним остальные поля для krtDrvGetNextNode
   trace_list[cur_trace].trace->nodeType = sensType;
   trace_list[cur_trace].trace->nodeIndex = sensIndex;
   trace_list[cur_trace].trace->nodePos = start;
   // заполним остальные поля для krtDrvGetNextNode

    // проверим корректна ли запрошенная начальная дистанция start 
   if ( my_start >= trace_list[cur_trace].trace->trace_len) 
    {
      sprintf(drvError, "Не попадает start=%i в трассу (krtDrvGetFirstNode)",start);
      my_start = trace_list[cur_trace].trace->trace_len-1;
      // return KRT_ERR;
    };

   my_start -=trace_list[cur_trace].trace->file_index[0].beg_track;

//   if (sensType != KRT_SENS_TIMER) {
//          my_start += trace_list[cur_trace].trace->max_sens_shift;
//   };

/*
   if ( (sensType == KRT_SENS_THICK) &&
        (strcmp(trace_list[cur_trace].trace->target_name, TARGET_NAME_STRS700sit) == 0)
      )
   {
      my_start -= trace_list[cur_trace].trace->max_sens_shift;
   };




   if ( (sensType == KRT_SENS_THICK) &&
        (strcmp(trace_list[cur_trace].trace->target_name, TARGET_NAME_STRS700sit) == 0)
      )
   {
      my_start += trace_list[cur_trace].trace->max_sens_shift;
   };
*/

#ifdef RAZVOROT_PROSMOTRA
   // для разворота просмотра
   my_start  = trace_list[cur_trace].trace->trace_len - my_start;

#endif


   if (my_start < 1)
    {
//      sprintf(drvError, "Не попадает start=%i в трассу (krtDrvGetFirstNode)",start);
      my_start = 1;
	  //trace_list[cur_trace].trace->file_index[0].beg_track;
      // return KRT_ERR;
    };

 //  if (trace_list[cur_trace].trace->file_index[0].beg_track > 1) {
 //      my_start -=trace_list[cur_trace].trace->file_index[0].beg_track;
 //      if (my_start < 1) my_start = 1;
 //   };

   if(my_start>=trace_list[cur_trace].trace->file_index[
                  trace_list[cur_trace].trace->num_file_data-1
                 ].end_track
      ) 
    {
       node->Val=0;
       node->Pos=start;

       if( (sensType==KRT_SENS_EXT) || (sensType==KRT_SENS_AZIMUTH) || (sensType==KRT_SENS_TANGAZH) )
       {
       } else {
            return KRT_OK;
       }
    } else {

        fseek(trace_list[cur_trace].trace->index_extend_sens.file_data,
              my_start * sizeof(record_extended_sens),
              SEEK_SET
             );

        fread(&record_extended_sens,
              1,sizeof(record_extended_sens),
              trace_list[cur_trace].trace->index_extend_sens.file_data);
    };

   if (trace_list[cur_trace].trace->index_power_lines.file_data!=NULL) {

        fseek(trace_list[cur_trace].trace->index_power_lines.file_data,
              my_start * sizeof(record_power_data),
              SEEK_SET
             );

        fread(&record_power_data,
              1,sizeof(record_power_data),
              trace_list[cur_trace].trace->index_power_lines.file_data);
    };

   if (trace_list[cur_trace].trace->index_bypass.file_data!=NULL) {
        fseek(trace_list[cur_trace].trace->index_bypass.file_data,
              my_start * sizeof(record_bypass_data),
              SEEK_SET
             );

        fread(&record_bypass_data,
              1,sizeof(record_bypass_data),
              trace_list[cur_trace].trace->index_bypass.file_data);
   };


   if (trace_list[cur_trace].trace->trace_step == 10)
   {
       my_start_vog=my_start +
                         trace_list[cur_trace].trace->PigL3/10;
//                             / trace_list[cur_trace].trace->trace_step);
   } else {
      my_start_vog = my_start / 2 +
                         trace_list[cur_trace].trace->PigL3/10;
//                           / trace_list[cur_trace].trace->trace_step);
   };

   if ( (strcmp(trace_list[cur_trace].trace->target_name, TARGET_NAME_STRS700sit) == 0)
      )
   {
//      my_start_vog -= (trace_list[cur_trace].trace->max_sens_shift);
   };

   my_start_vog += trace_list[cur_trace].trace->ShiftNavigation_data;
   if (my_start_vog < 1 ) my_start_vog = 1;


   if (trace_list[cur_trace].VogData.file_data!=NULL) {
       // вычисляем и читаем нужную запись в rec.mat
       if (GetVogData(my_start_vog, &trace_list[cur_trace].VogData)!=KRT_OK) {
           strcat(drvError, "(krtDrvGetFirstNode)");
           return KRT_ERR;
        };
   };

/*               // Выводим данные вогов
                 sprintf(tmp_log_str, "%f, %f\n",
                     trace_list[cur_trace].VogData.cur_data.Psi, trace_list[cur_trace].VogData.cur_data.Teta);
//                 sprintf(tmp_log_str, "%lu, %d, %d\n",
//                 full_trace_counter, unarc_data->inquiry[i].accel_x, unarc_data->inquiry[i].accel_y);
                 Log(tmp_log_str);
*/

   switch (sensType) {

      case (KRT_SENS_ODO): {     // одометр
         node->Val=start;
         node->Pos=start;
         break;
       };

      case (KRT_SENS_ORIENT): {  // ориентация
         switch (sensIndex) {
            case(-1L):
            case(0): {
              node->Val = record_extended_sens.orient;
              node->Pos = start;
              break;
             };
          };
         break;
       };

     case (KRT_SENS_TEMP): {    // температура
         // T = (ADC/102 - 1.375) / 0.0225
        node->Val = record_extended_sens.termo;

        if (node->Val>trace_list[cur_trace].trace->MaxTermo) {
           node->Val=trace_list[cur_trace].trace->MaxTermo;
         }

        if (node->Val<trace_list[cur_trace].trace->MinTermo) {
           node->Val=trace_list[cur_trace].trace->MinTermo;
         }

        node->Pos = start;
        break;
       };

     case (KRT_SENS_TIMER): { // таймер
        node->Val =  record_extended_sens.time;

#ifdef RAZVOROT_PROSMOTRA
		 // для разворота просмотра
        node->Val  = trace_list[cur_trace].trace->trace_time - record_extended_sens.time;
#endif


        node->Pos = start;
        if (start==0) {
           node->Val=record_extended_sens.time-10000;
           if (node->Val<0) node->Val=0;
         };
        break;
       };

     case (KRT_SENS_THICK): {   // толщина
        node->Val = record_extended_sens.Thick;
        node->Pos = start;
        break;
      };

      case (KRT_SENS_PRESS) : // Давление
      {
          node->Val = 0;
          node->Pos = start;
          break;
      };

      case (KRT_SENS_SHAKE) : // Вибрация
      {
          node->Val = 0;
          node->Pos = start;
          break;
      };

      case (KRT_SENS_AZIMUTH) : // Psi;  азимут, (градус * 100)
      {
          node->Val=(long) (trace_list[cur_trace].VogData.cur_data.Psi
                            * 180 * 100 / PI
                           );
          node->Pos = start;
          break;
      };

      case (KRT_SENS_TANGAZH) : // Teta  тангаж, (градус * 100)
      {
         node->Val=(long) (trace_list[cur_trace].VogData.cur_data.Teta
                           * 180 * 100 / PI
                          );
         node->Pos = start;
         break;
      };


      case (KRT_SENS_EXT): {    // вспомогательный

         if (trace_list[cur_trace].NavData.file_data!=NULL) {
             // вычисляем и читаем нужную запись в rec.mat
             if (GetNavData(my_start_vog, &trace_list[cur_trace].NavData)!=KRT_OK) {
                 strcat(drvError, "(krtDrvGetFirstNode)");
                 return KRT_ERR;
              };
          } else {
             sensIndex+=6;      
          };

         switch (sensIndex) {
            case (0): { // Vog X
               node->Val=(long) (trace_list[cur_trace].NavData.cur_data.VogX 
                                 * trace_list[cur_trace].trace->VOG_koeff_umn
                                );
               node->Pos = start;
               break;
             }; /* case  0 */
            case (1): { // Vog Y
               node->Val=(long) (trace_list[cur_trace].NavData.cur_data.VogY 
                                 * trace_list[cur_trace].trace->VOG_koeff_umn
                                );
               node->Pos = start;
               break;
             }; /* case  0 */
            case (2): { // Vog Z
               node->Val=(long) (trace_list[cur_trace].NavData.cur_data.VogZ
                                 * trace_list[cur_trace].trace->VOG_koeff_umn
                                );
               node->Pos = start;
               break;
             }; /* case  0 */
            case (3): { // Accel X
               node->Val=(long) (trace_list[cur_trace].NavData.cur_data.AccelX 
                                 * trace_list[cur_trace].trace->ACCEL_koeff_umn
                                );
               node->Pos = start;
               break;
             }; /* case  0 */
            case (4): { // Accel Y
               node->Val=(long) (trace_list[cur_trace].NavData.cur_data.AccelY
                                 * trace_list[cur_trace].trace->ACCEL_koeff_umn
                                );
               node->Pos = start;
               break;
             }; /* case  0 */
            case (5): { // Accel Z
               node->Val=(long) (trace_list[cur_trace].NavData.cur_data.AccelZ
                                 * trace_list[cur_trace].trace->ACCEL_koeff_umn
                                );
               node->Pos = start;
               break;
             }; /* case  0 */
/*
            case ( 6): {
                node->Val= (record_bypass_data.abs_pressure-197) * 127;
                node->Pos = start;
                break;            
             };
            case ( 7): {
                node->Val= (record_bypass_data.diff_pressure-512) * 256;
                node->Pos = start;
                break;            
             };

            case ( 8): {
                node->Val= record_bypass_data.speed;
                node->Pos = start;
                break;            
             };

            case ( 9): {
                node->Val= record_bypass_data.motor_state;
                node->Pos = start;
                break;            
             };

            case (10): {
                node->Val= record_bypass_data.board_state;
                node->Pos = start;
                break;            
             };


            case (11): {
                node->Val= record_bypass_data.choke_curr_position_ticks;
                node->Pos = start;
                break;            
             };

            case (12): {
                node->Val= record_bypass_data.choke_curr_position_angle;
                node->Pos = start;
                break;            
             };
                      
            case (13): {
                node->Val= record_bypass_data.choke_position;
                node->Pos = start;
                break;            
             };
*/

            case ( 6):
            case ( 7):
            case ( 8):
            case ( 9):
            case (10):
            case (11):
            case (12):
            case (13): { // power lines 0-7
               node->Val=(long) record_power_data.power_lines[sensIndex-6]*20;
               node->Pos = start;
               break;
             }; // case 6-13

            case (14): { // power flags
               node->Val=(long) record_power_data.power_flags;
               node->Pos = start;
               break;
             }; // case 14

            case (15) : // овальность
            {
                long ovalnost = 0;

                if (trace_list[cur_trace].trace->ovalnost_data == NULL)
                { 
                   node->Val = -50;
                   node->Pos = start;
                   break;
                }

                fseek( trace_list[cur_trace].trace->ovalnost_data, my_start * sizeof(ovalnost), SEEK_SET );
                fread( &ovalnost, 1, sizeof(ovalnost), trace_list[cur_trace].trace->ovalnost_data);

                node->Val = ovalnost;
                node->Pos = start;
                break;
            };



            default:{
               sprintf(drvError, "bad sensIndex parameter(krtDrvGetFirstNode)");
               return KRT_ERR;
             };
          }; // switch (sensIndex) {
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
 }; /* krtDrvGetFirstNode */


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
 }; /* krtDrvGetNextNode */


long WINAPI krtDrvGetFirstNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node,        
                                long start, long sensGroup,
                                long length, long controlSize )
 {
  int i; // переменная для индексов в циклах

  long my_start  = start/10;

  long my_start_vog;

  int curent_trace;  /* индекс текущей трассы в списке откр. трасс */


   /* проверим на корректность handle : */
  if (handle<=0) return KRT_ERR;   // недопустимое значение handle
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

   /* проверим корректна ли запрошенная начальная дистанция start */
  if (my_start<0) my_start=0;
  if ( my_start >= trace_list[curent_trace].trace->trace_len ) {
    my_start = trace_list[curent_trace].trace->trace_len;
   };

  trace_list[curent_trace].cur_par_nodeGroup.startPos=my_start;
  trace_list[curent_trace].cur_par_nodeGroup.sensPos=my_start;

  if (controlSize>0 && controlSize<length/10) {
     trace_list[curent_trace].cur_par_nodeGroup.controlSize=(float)(length/controlSize/9.9);
   } else {
     trace_list[curent_trace].cur_par_nodeGroup.controlSize=1.0;
   };


  my_start= (long) (
          ((float)(trace_list[curent_trace].cur_par_nodeGroup.sensPos-
                 trace_list[curent_trace].cur_par_nodeGroup.startPos)*
           trace_list[curent_trace].cur_par_nodeGroup.controlSize) +
           trace_list[curent_trace].cur_par_nodeGroup.startPos
          );

  trace_list[curent_trace].cur_par_nodeGroup.sensPos++;

  start=my_start*10;

   /* выбираем действие в зависимости от типа датчика */
  if (sensGroup && KRT_SENS_VOG) {
     my_start_vog=my_start+1;

     my_start_vog +=  trace_list[curent_trace].trace->PigL3/10;
//                         / trace_list[curent_trace].trace->trace_step);

     my_start_vog += trace_list[curent_trace].trace->ShiftNavigation_data ;
     if (my_start_vog < 1 ) my_start_vog = 1;

     // вычисляем и читаем нужную запись в Vog.mat
     if (GetVogData(my_start_vog, &trace_list[curent_trace].VogData)!=KRT_OK) {
        strcat(drvError, "(krtDrvGetFirstNodeGroup)");
        return KRT_ERR;
      };

      node->vogx   = trace_list[curent_trace].VogData.cur_data.VogX*10;
      node->vogy   = trace_list[curent_trace].VogData.cur_data.VogY*10;
      node->vogz   = trace_list[curent_trace].VogData.cur_data.VogZ*10;
                                                                     
      node->vogext1= trace_list[curent_trace].VogData.cur_data.Psi;
      node->vogext2= trace_list[curent_trace].VogData.cur_data.Teta;
      node->vogext3= trace_list[curent_trace].VogData.cur_data.Gamma;
                                                               
      node->vogPos = my_start*10; //trace_list[curent_trace].VogData.cur_data.Dist*10;
      node->odoPos = my_start*10;

   } else {
       sprintf(drvError, "bad sensGroup parameter(krtDrvGetFirstNodeGroup)");
       return KRT_ERR;
   };

   trace_list[curent_trace].cur_par_nodeGroup.sensTypeGroup = sensGroup;

   return KRT_OK;
 }; /* krtDrvGetFirstNodeGroup  */


long WINAPI krtDrvGetNextNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node) {
  int i;

  int curent_trace;  // индекс текущей трассы в списке откр. трасс 
  long start;
  long my_start;

  long my_start_vog;

   // проверим на корректность handle :
  if (handle<=0) return KRT_ERR;   // недопустимое значение handle
  if (open_trace_counter==0) return KRT_ERR; // нет открытых трасс
  for (i=0; i<open_trace_counter; i++) {
     if (handle==trace_list[i].handle) break;
   };
  if (i==open_trace_counter) {
     sprintf(drvError, "Unknown handle trace (krtDrvGetNextNodeGroup)");
     return KRT_ERR; // нет  такого handle
   } else curent_trace=i;

   // попытаемся проверить корректность параметра node 
  if (node==NULL) {
     sprintf(drvError, "node==NULL (krtDrvGetNextNodeGroup)");
     return KRT_ERR;
   };

  my_start= (long) (
          ((float)(trace_list[curent_trace].cur_par_nodeGroup.sensPos-
                 trace_list[curent_trace].cur_par_nodeGroup.startPos)*
           trace_list[curent_trace].cur_par_nodeGroup.controlSize) +
           trace_list[curent_trace].cur_par_nodeGroup.startPos
          );

  trace_list[curent_trace].cur_par_nodeGroup.sensPos++;

   // проверим корректна ли запрошенная начальная дистанция start
  if (my_start<0) my_start=0;
  if ( my_start >= trace_list[curent_trace].trace->trace_len ) {
    my_start = trace_list[curent_trace].trace->trace_len;
   };

  start=my_start*10;

   // выбираем действие в зависимости от типа датчика 
  if (trace_list[curent_trace].cur_par_nodeGroup.sensTypeGroup && KRT_SENS_VOG) {
     my_start_vog=my_start+1;

     my_start_vog +=  trace_list[curent_trace].trace->PigL3/10;
//                          / trace_list[curent_trace].trace->trace_step);

     // вычисляем и читаем нужную запись в Vog.mat
     if (GetVogData(my_start_vog, &trace_list[curent_trace].VogData)!=KRT_OK) {
        strcat(drvError, "(krtDrvGetNextNodeGroup)");
        return KRT_ERR;
      };

      node->vogx   = trace_list[curent_trace].VogData.cur_data.VogX*10;
      node->vogy   = trace_list[curent_trace].VogData.cur_data.VogY*10;
      node->vogz   = trace_list[curent_trace].VogData.cur_data.VogZ*10;
                                                                     
      node->vogext1= trace_list[curent_trace].VogData.cur_data.Psi;
      node->vogext2= trace_list[curent_trace].VogData.cur_data.Teta;
      node->vogext3= trace_list[curent_trace].VogData.cur_data.Gamma;
                                                               
      node->vogPos = my_start*10; //trace_list[curent_trace].VogData.cur_data.Dist*10;
      node->odoPos = my_start*10;

   } else {
       sprintf(drvError, "bad sensGroup parameter(krtDrvGetNextNodeGroup)");
       return KRT_ERR;
   };

   return KRT_OK;
 };



/* функция регистрации записи */
long KRTAPI krtDrvRegister (
 const char * datFile, 
 const char * trcFile, 
 char **errText, 
 long (KRTAPI *userBreak) (short percentDone)
 ) 
{
  char  data_path[_MAX_PATH]; // путь до файлов с данными
  long  data_path_len=0;      // длинна строки пути до данных (в символах)
  long  num_work_files=0;     // количество рабочих файлов

  long file_counter;     // номер текущего файла с данными

  long reg_trc = open_trace_counter; // место в списке трасс где будет,
                                     // происходить регистрация 

  char tmp_str[_MAX_PATH];

  *errText = &(drvError[0]);
  traceFile = (char *) trcFile; // заглобалим имя trc-файла на случай варнингов при регистрации

  // выделим путь до файлов с данными из полного пути до первого файла
  // и пересчитаем файлы с данными:
  strcpy(data_path, datFile);
  if (enumerate_work_files(data_path, &data_path_len, &num_work_files)==KRT_ERR)
   {
     strcat(drvError, "(krtDrvRegister)");
     return KRT_ERR;
   };
  // выделили путь до файлов с данными из полного пути до первого файла

  trace_list[reg_trc].handle=0;
  trace_list[reg_trc].trace=init_opened_trace();
  if (trace_list[reg_trc].trace == NULL) {
     strcat(drvError, "(krtDrvRegister)");
     return KRT_ERR;
   };

  // запишем путь до файлов с данными в заданный trc-файл
  data_path[data_path_len]=0; // обрубим имя файла из пути

  trace_list[reg_trc].trace->num_file_data=num_work_files;

  // запомним и для себя в открытой трассе путь на рабочие файлы
  strcpy(trace_list[reg_trc].trace->path_data, data_path);

  // запомним и для себя в открытой трассе имя первого рабочего файла
  strcpy(trace_list[reg_trc].trace->first_file_name, &datFile[data_path_len]);

  // запомним еще для себя в открытой трассе путь на trc-файл
  strcpy(trace_list[reg_trc].trace->trc_file_name, trcFile);

  // запишем еще для себя в открытой трассе путь на индексный файл
  strcat(data_path, IDX_FILE_NAME);
  strcpy(trace_list[reg_trc].trace->idx_file_name, data_path);

  // читаем из trc-файла данные если они там есть
  if (read_data_from_trc(trace_list[reg_trc].trace) == KRT_ERR)
   {
     strcat(drvError, "(krtDrvRegister)");
//     trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
//     return KRT_ERR;
   };

  // Еще раз перезапишем пути на файлы полученные от вторички ....
  data_path[data_path_len]=0; // обрубим имя файла из пути

  trace_list[reg_trc].trace->num_file_data=num_work_files;

  // запомним и для себя в открытой трассе путь на рабочие файлы
  strcpy(trace_list[reg_trc].trace->path_data, data_path);

  // запомним и для себя в открытой трассе имя первого рабочего файла
  strcpy(trace_list[reg_trc].trace->first_file_name, &datFile[data_path_len]);

  // запомним еще для себя в открытой трассе путь на trc-файл
  strcpy(trace_list[reg_trc].trace->trc_file_name, trcFile);

  // запишем еще для себя в открытой трассе путь на индексные файлы
  strcpy(trace_list[reg_trc].trace->idx_file_name, data_path);
  strcat(trace_list[reg_trc].trace->idx_file_name, IDX_FILE_NAME);

  strcpy(trace_list[reg_trc].trace->index_extend_sens.file_name, data_path);
  strcat(trace_list[reg_trc].trace->index_extend_sens.file_name, EXT_IDX_FILE_NAME);

  // очистим файл от данных если они там есть
  trace_list[reg_trc].trace->index_extend_sens.file_data = 
  fopen(trace_list[reg_trc].trace->index_extend_sens.file_name, "wb");
  fclose( (FILE*) trace_list[reg_trc].trace->index_extend_sens.file_data);
  // очистили файл от данных если они там есть

  strcpy(trace_list[reg_trc].trace->index_power_lines.file_name, data_path);
  strcat(trace_list[reg_trc].trace->index_power_lines.file_name, PWR_IDX_FILE_NAME);

  // очистим файл от данных если они там есть
  trace_list[reg_trc].trace->index_power_lines.file_data = 
  fopen(trace_list[reg_trc].trace->index_power_lines.file_name, "wb");
  fclose( (FILE*) trace_list[reg_trc].trace->index_power_lines.file_data);
  // очистили файл от данных если они там есть

  // теперь проинициализируем индексы по файлам, мы же уже знаем скока их.
  trace_list[reg_trc].trace->file_index = init_index_files
                                      (
                                        trace_list[reg_trc].trace->num_file_data
                                      );
  if (trace_list[reg_trc].trace->file_index==NULL) {
     strcat(drvError, "(krtDrvRegister)");
     trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
     return KRT_ERR;
   };

  if (init_name_files(trace_list[reg_trc].trace,
                      (char *) datFile, data_path_len) == KRT_ERR) 
   {
     strcat(drvError, "(krtDrvRegister)");
     trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
     return KRT_ERR;
   };

  // пересчитаем условные швы во всех файлах и инициализируем индексы усл. швов
  for (file_counter=0; file_counter<trace_list[reg_trc].trace->num_file_data; file_counter++) 
   {
     // проверка не пытается ли пользователь прервать нас принудительно и 
     // заодно передадим процент проделанной работы
     if (userBreak((short)((file_counter)/num_work_files))) {
        sprintf (drvError, "Отменено пользователем (krtDrvRegister)");
        trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
        return KRT_ERR;
      };

     if (enumerate_seam_in_files(&trace_list[reg_trc].trace->file_index[file_counter])==KRT_ERR)
      {
        strcat(drvError, "(krtDrvRegister)");
        trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
        return KRT_ERR;
      };// if (enumerate_seam_in_files(&trace_list[reg_trc].trace->file_index[file_counter])


     trace_list[reg_trc].trace->file_index[file_counter].index_seam = 
        init_index_seams(trace_list[reg_trc].trace->file_index[file_counter].num_condition_seam);
     if ( trace_list[reg_trc].trace->file_index[file_counter].index_seam == NULL) 
      {
        strcat(drvError, "(krtDrvRegister)");
        trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
        return KRT_ERR;
      }; //if (init_index_seams(&trace_list[reg_trc].trace->file_index[file_counter])

   }; //  for (file_counter=0; file_counter<trace_list[reg_trc].trace->num_file_data; file_counter) 
  // пересчитали условные швы во всех файлах и инициализировали индексы усл. швов

  // теперь начнем окончательную индексацию
  for (file_counter=0; file_counter<trace_list[reg_trc].trace->num_file_data; file_counter++) 
   {
     // проверка не пытается ли пользователь прервать нас принудительно и 
     // заодно передадим процент проделанной работы
     if (userBreak((short)((file_counter*100)/num_work_files))) {
       sprintf (drvError, "Отменено пользователем (krtDrvRegister)");
       trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
       return KRT_ERR;
      };

     if ( calkulate_index_files_and_sems
                 ( &trace_list[reg_trc], file_counter) 
          == KRT_ERR
        )
      {
        strcat(drvError, "(krtDrvRegister)");
        trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
        return KRT_ERR;
      };

   }; //  for (file_counter=0; file_counter<trace_list[reg_trc].trace->num_file_data; file_counter) 
  // вроде как закончили окончательную индексацию

  // заполним расст трассы
  trace_list[reg_trc].trace->trace_len =
    trace_list[reg_trc].trace->file_index[trace_list[reg_trc].trace->num_file_data-1].end_track;
  // заполнили расст трассы


  // заполним время работы на трассе
  trace_list[reg_trc].trace->trace_time = (long)
         trace_list[reg_trc].trace->file_index
              [ 
                trace_list[reg_trc].trace->num_file_data-1
              ].index_seam
                   [
                       trace_list[reg_trc].trace->file_index
                           [ 
                             trace_list[reg_trc].trace->num_file_data-1
                           ].num_condition_seam-1
                   ].end_time;
  // заполнили время работы на трассе

  if (save_index_info(trace_list[reg_trc].trace) != KRT_OK ) {
     strcat(drvError, "(krtDrvRegister)");
     trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
     return KRT_ERR;
   };

  // Если путь на рабочий каталог совпадает с путем на файл *.trc,
  // то путь на рабочий каталог обнуляем
  if (strncmp(trace_list[reg_trc].trace->path_data, trcFile,
              strlen(trace_list[reg_trc].trace->path_data))
      == 0
     )
   {
      strcpy(trace_list[reg_trc].trace->path_data, "");
   };

  // Если путь на индексный файл совпадает с путем на файл *.trc,
  // то путь на индексный файл обнуляем

  // вычленим строку пути до trc-файла (без имени самого файла)
  strcpy(tmp_str, trcFile);

  while((strlen(tmp_str)>0) && (tmp_str[strlen(tmp_str)-1]!='\\')) {
    tmp_str[strlen(tmp_str)-1]=0;
  };

  if (strncmp(tmp_str, trace_list[reg_trc].trace->idx_file_name,
              strlen(tmp_str))
      == 0
     )
   {
      strcpy(trace_list[reg_trc].trace->idx_file_name, "");
   };

  if (write_data_to_trc(trace_list[reg_trc].trace) == KRT_ERR) {
     strcat(drvError, "(krtDrvRegister)");
     trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
     return KRT_ERR;
   };

  trace_list[reg_trc].trace = free_opened_trace(trace_list[reg_trc].trace);
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


long EXPORT KRTAPI krtOpenTrace(const char * traceFile, KRTHANDLE handle, T_TRACEINFO *inf, long draft){

   long curent_trace;
   long ext_sens_index;


   inf->krtDrvError = krtDrvError; // а вдруг ош. кака, надо заполнить заранее

      //  debugPoint("Enter krtOpenTrace");

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

     // создаем и подгружаем индексы по открываемой трассе 
     trace_list[curent_trace].trace =  creation_trace_with_a_loading_index_info
           (
             (char *) traceFile
           );
     if (trace_list[curent_trace].trace == NULL) {
        strcat (drvError, "(krtOpenTrace)");
        return KRT_ERR;
      };
     
     open_trace_counter++;
     // открыли трассу

       // скока поясов развертки:
     inf->sensGroups = trace_list[curent_trace].trace->group_num;


     {
          char ext_idx_file_name[1024];

          sprintf(ext_idx_file_name, "%sovalnost.idx", trace_list[curent_trace].trace->path_data);

          trace_list[curent_trace].trace->ovalnost_data = fopen(ext_idx_file_name, "rb");
          if (trace_list[curent_trace].trace->ovalnost_data==NULL) {
              sprintf(drvError, "Ошибка открытия файла %s. \n", ext_idx_file_name);
              trace_list[curent_trace].trace->ovalnost_data = NULL;
          } else {
              trace_list[curent_trace].trace->add_ext_sens_ovalnost++;
          };
     };
     // проверим есть ли навигационные данные
     if (Serch_navigete(&trace_list[curent_trace])==KRT_OK) {
         // раз есть надо заявить дополнительные датчики
         inf->extSensors = 7;
      } else {
         inf->extSensors = 10;
      };

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

  // подготовим структуру работы с навигационными данными
  if (Init_navigete(&trace_list[curent_trace], inf)!=KRT_OK) {
     // что-то не так с навигацией
   };

  // заполним для вторички данные об открываемой трассе
  inf->sensGroups = trace_list[curent_trace].trace->group_num;
  inf->askMetod   = SENS_ASK_DIST;
  inf->stepSize   =  trace_list[curent_trace].trace->trace_step;


  // заполним параметры первого сектора
  inf->group[0].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[0];
  inf->group[0].type    = SENS_TYPE_MFL;
  inf->group[0].minValue= 0;
  inf->group[0].maxValue= KRT_PALLETE_SIZE;

  inf->group[0].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
  inf->group[0].minRowVal= 0; // минимальное значение сырых данных 
  inf->group[0].maxRowVal= trace_list[curent_trace].trace->max_data_code; // максимальное значение сырых данных 

  // заполним параметры второго сектора, если он есть
  if (trace_list[curent_trace].trace->group_num>1) {
     inf->group[1].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[1];
     inf->group[1].type    = SENS_TYPE_MFL;
     inf->group[1].minValue= 0;
     inf->group[1].maxValue= KRT_PALLETE_SIZE;

     inf->group[1].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
     inf->group[1].minRowVal= 0; // минимальное значение сырых данных 
     inf->group[1].maxRowVal= trace_list[curent_trace].trace->max_data_code; // максимальное значение сырых данных 
   };

  if ( (trace_list[curent_trace].trace->corosion_sens_num==80) ||
       (trace_list[curent_trace].trace->corosion_sens_num==64) ||
       (trace_list[curent_trace].trace->corosion_sens_num==40))
   {
      // если это у нас профиль
      inf->group[0].type=SENS_TYPE_PROFIL;
      if (read_data_profil_ini(trace_list[curent_trace].trace) == KRT_ERR) {
         // что-то не так с калибровкой профиля
         strcat(drvError, "(krtOpenTrace)\n");
         strcat(drvError, "Скопируйте в каталог с данными файл calibrat.prf");
         return KRT_ERR; 
       };
   };

  if (trace_list[curent_trace].trace->corosion_sens_num==160) {
      // если это у нас профиль 1400
      inf->group[0].type=SENS_TYPE_PROFIL;
      if (read_data_profil_ini(trace_list[curent_trace].trace) == KRT_ERR) {
         // что-то не так с калибровкой профиля
         strcat(drvError, "(krtOpenTrace)\n");
         strcat(drvError, "Скопируйте в каталог с данными файл calibrat.prf");
         return KRT_ERR; 
       };

      // первый пояс
      inf->group[0].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[0];
      inf->group[0].type    = SENS_TYPE_PROFIL;
      inf->group[0].minValue= 0;
      inf->group[0].maxValue= KRT_PALLETE_SIZE;

      inf->group[0].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
      inf->group[0].minRowVal= 0; // минимальное значение сырых данных 
      inf->group[0].maxRowVal= trace_list[curent_trace].trace->max_data_code; // максимальное значение сырых данных 

      // второй пояс
      inf->group[1].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[1];
      inf->group[1].type    = SENS_TYPE_PROFIL;
      inf->group[1].minValue= 0;
      inf->group[1].maxValue= KRT_PALLETE_SIZE;

      inf->group[1].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
      inf->group[1].minRowVal= 0; // минимальное значение сырых данных 
      inf->group[1].maxRowVal= trace_list[curent_trace].trace->max_data_code; // максимальное значение сырых данных 

      // третий пояс
      inf->group[2].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[2];
      inf->group[2].type    = SENS_TYPE_MFL;
      inf->group[2].minValue= 0;
      inf->group[2].maxValue= KRT_PALLETE_SIZE;

      inf->group[2].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
      inf->group[2].minRowVal= 0; // минимальное значение сырых данных 
      inf->group[2].maxRowVal= trace_list[curent_trace].trace->max_data_code; // максимальное значение сырых данных 

      // четвертый пояс
      inf->group[3].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[3];
      inf->group[3].type    = SENS_TYPE_MFL;
      inf->group[3].minValue= 0;
      inf->group[3].maxValue= KRT_PALLETE_SIZE;

      inf->group[3].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
      inf->group[3].minRowVal= 0; // минимальное значение сырых данных 
      inf->group[3].maxRowVal= trace_list[curent_trace].trace->max_data_code; // максимальное значение сырых данных 

   };


  // ха-ха а Витальке дадим на 1 измерение меньше, т.к. считаем и 0 за отсчет 
  inf->length   = (trace_list[curent_trace].trace->trace_len - 1) *
                  trace_list[curent_trace].trace->trace_step;

  inf->time     = trace_list[curent_trace].trace->trace_time;


  inf->orientNum  = 1;
  inf->orientStep = trace_list[curent_trace].trace->trace_step;

  inf->timerNum  = 1;
  inf->timerStep = trace_list[curent_trace].trace->trace_step;  

  inf->odoNum  = 1;
  inf->odoStep = trace_list[curent_trace].trace->trace_step;

  inf->tempNum  = 1;
  inf->tempStep = trace_list[curent_trace].trace->trace_step;
  inf->tempMin  = trace_list[curent_trace].trace->MinTermo;
  inf->tempMax  = trace_list[curent_trace].trace->MaxTermo;

  if (inf->tempMin>=inf->tempMax) {
     inf->tempMin  = trace_list[curent_trace].trace->MinTermo=-100;
     inf->tempMax  = trace_list[curent_trace].trace->MaxTermo=100;
   };

    // типа датчик толщины 
  inf->wallThickNum = 1;       // количество каналов
  inf->wallThickMin = 0;       // минимальное значение канала 
  inf->wallThickMax = trace_list[curent_trace].trace->max_data_code;  // максимальное значение канала 

  inf->speedMin = -100;
  inf->speedMax =  100;

  inf->shakeNum  =  1; // вибрация
  inf->shakeStep =  trace_list[curent_trace].trace->trace_step;
  inf->shakeMin  = -100;
  inf->shakeMax  =  100;


  inf->pressNum =  1; // давление
  inf->pressStep=  trace_list[curent_trace].trace->trace_step;
  inf->pressMin = -100;
  inf->pressMax =  100;

  // Подключим вспомогательные датчики
  ext_sens_index=0;
  if (trace_list[curent_trace].NavData.file_data!=NULL)
   {
      inf->extSens[ext_sens_index].minValue = -70*VOG_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +70*VOG_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "ВОГ X", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -70*VOG_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +70*VOG_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "ВОГ Y", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -70*VOG_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +70*VOG_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "ВОГ Z", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;


      inf->extSens[ext_sens_index].minValue = -10*ACCEL_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +10*ACCEL_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "Акселерометр X", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -10*ACCEL_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +10*ACCEL_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "Акселерометр Y", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -10*ACCEL_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +10*ACCEL_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "Акселерометр Z", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;
   } else { // if (trace_list[curent_trace].NavData.file_data!=NULL)

       inf->extSens[ext_sens_index].minValue = -100000;
       inf->extSens[ext_sens_index].maxValue = 100000;
       inf->extSens[ext_sens_index].maxValue = 4095;
       strncpy (
        inf->extSens[ext_sens_index].name,
//        "abs_pressure",
        "Ток линии 1", 
        EXT_SENS_NAME_LENGTH
       );
       ext_sens_index++;

       inf->extSens[ext_sens_index].minValue = -100000;
       inf->extSens[ext_sens_index].maxValue = 100000;
       inf->extSens[ext_sens_index].maxValue = 4095;
       strncpy (
        inf->extSens[ext_sens_index].name,
//        "diff_pressure",
        "Ток линии 2", 
        EXT_SENS_NAME_LENGTH
       );
       ext_sens_index++;

       inf->extSens[ext_sens_index].minValue = 0;
       inf->extSens[ext_sens_index].maxValue = 35565;
       inf->extSens[ext_sens_index].maxValue = 4095;
       strncpy (
        inf->extSens[ext_sens_index].name,
//        "speed",
        "Ток линии 3", 
        EXT_SENS_NAME_LENGTH
       );
       ext_sens_index++;

       inf->extSens[ext_sens_index].minValue = 0;
       inf->extSens[ext_sens_index].maxValue = 256;
       inf->extSens[ext_sens_index].maxValue = 4095;
       strncpy (
        inf->extSens[ext_sens_index].name,
//        "motor_state",
        "Ток линии 4", 
        EXT_SENS_NAME_LENGTH
       );
       ext_sens_index++;

       inf->extSens[ext_sens_index].minValue = 0;
       inf->extSens[ext_sens_index].maxValue = 256;
       inf->extSens[ext_sens_index].maxValue = 4095;
       strncpy (
        inf->extSens[ext_sens_index].name,
//        "board_state",
        "Ток линии 5", 
        EXT_SENS_NAME_LENGTH
       );
       ext_sens_index++;

       inf->extSens[ext_sens_index].minValue = 0;
       inf->extSens[ext_sens_index].maxValue = 256;
       inf->extSens[ext_sens_index].maxValue = 4095;
       strncpy (
        inf->extSens[ext_sens_index].name,
//        "choke_curr_position_ticks",
        "Ток линии 6", 
        EXT_SENS_NAME_LENGTH
       );
       ext_sens_index++;

       inf->extSens[ext_sens_index].minValue = 0;
       inf->extSens[ext_sens_index].maxValue = 256;
       inf->extSens[ext_sens_index].maxValue = 4095;
       strncpy (
        inf->extSens[ext_sens_index].name,
//        "choke_curr_position_angle",
        "Ток линии 7", 
        EXT_SENS_NAME_LENGTH
       );
       ext_sens_index++;

       inf->extSens[ext_sens_index].minValue = 0;
       inf->extSens[ext_sens_index].maxValue = 256;
       inf->extSens[ext_sens_index].maxValue = 4095;
       strncpy (
        inf->extSens[ext_sens_index].name,
//        "choke_position",
        "Ток линии 8", 
        EXT_SENS_NAME_LENGTH
       );
       ext_sens_index++;

       inf->extSens[ext_sens_index].minValue = 0;
       inf->extSens[ext_sens_index].maxValue = 4095;
       strncpy (
        inf->extSens[ext_sens_index].name, 
        "Флаги линий питания", 
        EXT_SENS_NAME_LENGTH
       );
       ext_sens_index++;

       inf->extSens[ext_sens_index].minValue = -100;
       inf->extSens[ext_sens_index].maxValue =  200;
       strncpy (
        inf->extSens[ext_sens_index].name, 
        "Овальность, %", 
        EXT_SENS_NAME_LENGTH
       );
       ext_sens_index++;
   };
  // Подключили вспомогательные датчики


     // Инициализируем указатели на Callback - Функции 
  inf->krtDrvFillData          = krtDrvFillData;
  inf->krtDrvGetFirstNode      = krtDrvGetFirstNode;
  inf->krtDrvGetNextNode       = krtDrvGetNextNode;
  inf->krtDrvGetFirstNodeGroup = krtDrvGetFirstNodeGroup;
  inf->krtDrvGetNextNodeGroup  = krtDrvGetNextNodeGroup;


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

        if (trace_list[curent_trace].trace->ovalnost_data != NULL)
        {
           fclose(trace_list[curent_trace].trace->ovalnost_data);
        }

        if ( free_opened_trace(trace_list[curent_trace].trace) != NULL) {
           sprintf (drvError, "ошибка закрытия трассы(krtCloseTrace)");
           return KRT_ERR;
         };

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