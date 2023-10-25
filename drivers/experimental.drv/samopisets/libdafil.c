// libdafil.c - компонет драйвера epro_drv (и epro_reg).
// Тела инструментальных функций работы с файлами *.da для драйвера
// просмотра данных електронного блока "epro" программой KrotW32
//

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "krtapi.h"
#include "libdafil.h"
#include "krotepro.h"
#include "heapinsp.h"

#ifdef CALL_LOG

extern char tmp_log_str[8192];

extern char name_log_str[1024];

char tmp_log_str_1[8192];


extern void Log(char *LogString);

#endif

static long pred_cur_orient;
hyper timer_ms;
hyper last_proc_tacts;
      
double last_arctg2;

word calkulate_orientation (double cA, double sA, double orient_scale) {
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

    last_arctg2 = ArcTg2;

    ArcTg2*=orient_scale;
    ArcTg2/=(2*PI);

    if (ArcTg2-((word) ArcTg2)>0.5) ArcTg2+=1;

  return ((word) ArcTg2);
};



long put_code_to_data_buf(int code, T_CODE_SERCH_TABLE *P_code_table,
                                 byte *P_data_buf, long *data_count,
                                 long max_data_count)
{
  static int tiles_for_return;

  tiles_for_return=CLEARE_CODE;

  if (code!=CLEARE_CODE) {
    if (code<P_code_table->char_table_len && code>=0) {
       if (P_code_table->char_table[code].prefics!=CLEARE_CODE) {
           if (P_code_table->char_table[code].prefics==code) {
              return CLEARE_CODE;
            };
           put_code_to_data_buf(P_code_table->char_table[code].prefics,
                                P_code_table, P_data_buf, data_count,
                                max_data_count);
       } else { //if (P_code_table->char_table[code].prefics!=CLEARE_CODE) {
           tiles_for_return=P_code_table->char_table[code].last_char;
       }; //if (P_code_table->char_table[code].prefics!=CLEARE_CODE) {

       P_data_buf[*data_count]=P_code_table->char_table[code].last_char;
       if ((*data_count)<=max_data_count) {
            (*data_count)++;
        } else {
            tiles_for_return=CLEARE_CODE;
        };
     } else {  /* if (code<P_code_table->char_table_len)  */
       if (code>P_code_table->char_table_len || code<0) tiles_for_return=-1;
     };
   };  /* if (code!=CLEARE_CODE)   */

  return tiles_for_return;
}; /* put_code_to_data_buf */


#ifdef CALL_LOG

#define MAX_COLLECTION_LEN  7
#define END_COLLECTION_CHAR 64
#define TABLE_LEN 24000
#define FIRST_CODE_IN_TABLE 4097

typedef struct { 
   word code;
   short collection[MAX_COLLECTION_LEN+1];
} T_CodeTable;

T_CodeTable Table[TABLE_LEN];

long Max_index_Table;
long Complete_colection_count;
long collection_count;

void init_Table() {

  long i, j;
  long code_count;

  long perenos;

    for (i=0; i<TABLE_LEN;i++) {
       Table[i].code = FIRST_CODE_IN_TABLE + i;
       for (j=0; j<=MAX_COLLECTION_LEN; j++) {
           Table[i].collection[j] = END_COLLECTION_CHAR;
        };
     };

    code_count=0;
    collection_count=2;
    while (collection_count <= MAX_COLLECTION_LEN) {

       for (i=0; i<collection_count; i++) {
          Table[code_count].collection[i] = 2;
        };

       while (1) {
          code_count++;

          Complete_colection_count = ( Table[code_count-1].collection[0] == -2 );
          Table[code_count].collection[0] = Table[code_count-1].collection[0];
          for (i=1; i<collection_count; i++) {
              Complete_colection_count = Complete_colection_count && (Table[code_count-1].collection[i] == -2);
              Table[code_count].collection[i] = Table[code_count-1].collection[i];
           };
          if (Complete_colection_count) {
              break;
           };

          i=collection_count-1;
          perenos = 2;
          do { 
              Table[code_count].collection[i] = Table[code_count].collection[i] - perenos;
              if (Table[code_count].collection[i] < -2) {
                 Table[code_count].collection[i] = 2;
                 perenos = 2;
               } else {
                 perenos = 0;
               };
              i--;
           } while ( perenos != 0);

        }; // while (1) {
       collection_count++;
     }; // while (collection_count < MAX_COLLECTION_LEN)

    Max_index_Table = code_count;
}; // void init_Table()

long serch( short * analysis_code, long analysis_code_len, long *serched_code) {

  long table_index_count = Max_index_Table;

  for (table_index_count = Max_index_Table; table_index_count >= 0; table_index_count--) {

          collection_count = 0;

          Complete_colection_count = 
                (Table[table_index_count].collection[collection_count] == analysis_code[collection_count]);

          while ( Complete_colection_count && 
                  (collection_count < MAX_COLLECTION_LEN) &&
                  (collection_count < analysis_code_len) &&
                  (Table[table_index_count].collection[collection_count] != END_COLLECTION_CHAR)
                )
           {

             Complete_colection_count = 
                   (Table[table_index_count].collection[collection_count] == analysis_code[collection_count]);

             collection_count++;

             if (Table[table_index_count].collection[collection_count] == END_COLLECTION_CHAR) {
                 *serched_code = Table[table_index_count].code;
                 return collection_count;

              };

           }; // while  Complete_colection_count && 

   }; // for (table_index_count = Max_index_Table; table_index_count >= 0; table_index_count++) {

  return 0;
}; // long serch( short * analysis_code, long analysis_code_len, long *serched_code)


#endif


    /* arc_data - архивированные данные, arc_size - длинна архивных данных
       в  словах (word), unarc_data - указатель на данные условного шва */
long unarc_lzw (word *arc_data, int arc_size,
                       T_INDEX_SEAM *unarc_data, long corros_num,
                       hyper ver_file, char *target_name, long real_coros_num,
                       T_OPENED_TRACE *opened_trace)
{
   T_CODE_SERCH_TABLE P_code_table; //таблица кодов, выделяем сразу статически
   int  current_char;
   word current_code;
   word old_code;

   unsigned long i, j;
   long k;

   word *P_code_cur;  // указатель на текущее место в буфере кодов
   byte *P_data_buf;  // сюда выделим место под разархивированные данные 
   byte *P_data_cur;  // указатель на текущее место в разархивированных данных

   long max_data_count; // размер буфера под зазархивированные данные
   long data_count=0;   // текущий размер разархивированных данных

   int code_counter=arc_size; // количество архивных кодов
  
   static long full_trace_counter = 0;

   static long back_trace_counter = 0;

   static hyper  d_time;
   static hyper  cur_time;
   static hyper  pred_time;

   static long  debug_counter;
   
   byte pred_znach; // для распределения данных в массив записей T_RECORD_OF_ONE_CYCLE_INQUIRY

   byte *P_arc_data; // указатель на текущее место в разархивированных данных
   byte *P_res_data; // указатель на текущее место в окончательных данных

   T_RECORD_OF_ONE_CYCLE_INQUIRY *inquiry_no_skip;
                                //^^^ записи измерений с размноженными пропусками
   long no_skip_dimension_counter; // счетчик записей уже без пропусков

   long no_arc_sens_counter;

   double cA, sA;

   unsigned long padding_size;

   long sens_divizor;
   long clone_sens;

   static hyper pred_proc_tacts=0;

   byte tmp_pwr_dat[POWER_LINE_NUM_2+2];

   static long pred_accel_x = 0;
   static long pred_accel_y = 0;

   static long scip_counter = 0;

   switch (ver_file) {
      case (VER_FILE_EPRO): {
         padding_size=PADDING_F010_SIZE;
         break;
       };
      case (VER_FILE_EPRO_15): {
         padding_size=PADDING_F015_SIZE;
         break;
       };
      case (VER_FILE_EPRO_2): {
         padding_size=PADDING_F020_SIZE;
         break;
       };

      case (VER_FILE_EPRO_3): {
         padding_size=PADDING_F030_SIZE;
         break;
       };

      case (VER_FILE_EPRO_31): {
         padding_size=PADDING_F031_SIZE;
         break;
       };

      case (VER_FILE_EPRO_32): {
         padding_size=PADDING_F032_SIZE;
         break;
       };

      default : {
         padding_size=PADDING_F010_SIZE;
         sprintf (drvError, "Неизвестная версия файла(unarc_lzw)");
         return KRT_ERR;
       }; // default :
    };

   // выделим место под разархивированные данные
   // сначала вычислим скока места надо под разархивированные данные
   max_data_count= unarc_data->head_of_condition_seam->real_dim * 
                   (padding_size + 
                    (sizeof(EPRO_CORROSION_SENS_TYPE) * corros_num)
                   );

   // выделим место под разархивированные данные
   P_data_buf = (byte *) heap_alloc(max_data_count+1);
   if (P_data_buf ==NULL) {
      sprintf(drvError, "Нет памяти под разархивированные данные(unarc_lzw)");
      return KRT_ERR;
    };

// начали LZW разархивирование 

   // обнулим таблицу кодов
   for (i=0; i<SOURCE_TABLE_LEN; i++) {
     P_code_table.char_table[i].prefics = CLEARE_CODE;
     P_code_table.char_table[i].last_char = (byte) i;
    };

   P_code_table.char_table_len=SOURCE_TABLE_LEN;
   // обнулили таблицу кодов

   P_code_cur = arc_data;
   P_data_cur = P_data_buf;

   old_code=*P_code_cur;
   current_char = put_code_to_data_buf(old_code, &P_code_table, P_data_cur, 
                                       &data_count, max_data_count);
   if (current_char<0) {
      sprintf(drvError, "Архивные данные испорчены (unarc_lzw)");
      return KRT_ERR;
    };
   P_code_cur++;
   code_counter--;

   for ( ; code_counter>0; code_counter--) {
      if (*P_code_cur==CLEARE_CODE) {
        if (code_counter!=1) {
          P_code_table.char_table_len=SOURCE_TABLE_LEN;

          P_code_cur++;
          code_counter--;

          old_code = *P_code_cur;
          current_char = put_code_to_data_buf(old_code, &P_code_table, P_data_cur, 
                               &data_count, max_data_count);
          if (current_char<0) {
             sprintf(drvError, "Архивные данные испорчены (unarc_lzw)");
             return KRT_ERR;
           };
         }; /* if (code_counter!=1) */

       } else { /* if (*P_code_cur==CLEARE_CODE) */
         current_code = *P_code_cur;
         current_char = put_code_to_data_buf(current_code, &P_code_table,
                                             P_data_cur, &data_count, 
                                             max_data_count);
         if (current_char<0) {
            sprintf(drvError, "Архивные данные испорчены (unarc_lzw)");
            return KRT_ERR;
          };
         if (current_char==CLEARE_CODE) {
            current_char = put_code_to_data_buf(old_code, &P_code_table,
                                                P_data_cur, &data_count, 
                                                max_data_count);
            if (current_char<0) {
               sprintf(drvError, "Архивные данные испорчены (unarc_lzw)");
               return KRT_ERR;
             };
            P_data_cur[data_count] = current_char;
            if ( data_count < max_data_count) {
                data_count++;
             } else {
                sprintf(warnString, "array overflow in unarc");
                trcWarn(traceFile);
             };
          };

         P_code_table.char_table[P_code_table.char_table_len].prefics
             =old_code;
         P_code_table.char_table[P_code_table.char_table_len].last_char
             =current_char;
         P_code_table.char_table_len++;

         old_code=current_code;
       }; /* if (*P_code_cur==CLEARE_CODE) */

      P_code_cur++;
    }; /* for ( ; code_counter>0; code_counter--) */

// закончили LZW разархивирование 
// Теперь разархивированные данные начинаются по указателю P_data_buf

// начинаем распределять данные в массив записей T_RECORD_OF_ONE_CYCLE_INQUIRY

   // выделим место под истинные значения получаемые вычислением из их разницы
   unarc_data->inquiry = init_inquiry(corros_num,
                                      unarc_data->head_of_condition_seam->real_dim);

   if (unarc_data->inquiry == NULL) {
      strcat(drvError, "(unarc_lzw)");
      P_data_buf = (byte *) heap_free(P_data_buf);
      return KRT_ERR;
    };

   // Определим указатель на начало "несортированных" данных 
   P_arc_data = P_data_buf;

   // распределять данные некорозионных измерений

   // Определим указатель на начало области записи 
   P_res_data = (byte *) unarc_data->inquiry;

   for (i=0; i<padding_size; i++) {
      pred_znach=0;
      P_data_cur = & P_res_data[i];

      for (j=0 ; j<unarc_data->head_of_condition_seam->real_dim; j++) {
          pred_znach+=(*P_arc_data);
          *P_data_cur = pred_znach;

          P_data_cur += sizeof(T_RECORD_OF_ONE_CYCLE_INQUIRY);
          P_arc_data++;
       };
    };

   // распределять данные корозионных измерений
   P_res_data = (byte *) unarc_data->inquiry->sens;

   for (i=0; i<(sizeof(EPRO_CORROSION_SENS_TYPE)*corros_num); i++) {
      pred_znach=0;
      P_data_cur = & P_res_data[i];

      for (j=0 ; j<unarc_data->head_of_condition_seam->real_dim; j++) {
          pred_znach+=(*P_arc_data);
          *P_data_cur = pred_znach;

          P_data_cur += (sizeof(EPRO_CORROSION_SENS_TYPE) *corros_num);
          P_arc_data++;
       };
    };

   if (strcmp(target_name, TARGET_NAME_PROFIL1400)==0 ||
       strcmp(target_name, TARGET_NAME_PROFIL1400D)==0) {
    } else {
       for (i=0; i<unarc_data->head_of_condition_seam->real_dim; i++) {

           memcpy( tmp_pwr_dat,
                   &unarc_data->inquiry[i].Pic_track_3,
                   POWER_LINE_NUM_2+2);
           memcpy( &unarc_data->inquiry[i].power_val[0],
                   tmp_pwr_dat,
                   POWER_LINE_NUM_2+2);
        };
    };

   P_data_buf = (byte *) heap_free(P_data_buf);

   if ((ver_file == VER_FILE_EPRO_2)  || 
       (ver_file == VER_FILE_EPRO_3)  || 
       (ver_file == VER_FILE_EPRO_31) ||  
       (ver_file == VER_FILE_EPRO_32)) 
    {
       for (i=0; i<unarc_data->head_of_condition_seam->real_dim; i++) {

       full_trace_counter += unarc_data->inquiry[i].skip_cycle;

       if (ver_file != VER_FILE_EPRO_32) {
              for (k=0; k<POWER_LINE_NUM; k++) {
                  unarc_data->inquiry[i].power_val[k] = unarc_data->inquiry[i].power_val[k-8];
               };
              unarc_data->inquiry[i].power_flags = (&unarc_data->inquiry[i].power_flags)[-4] && 0xFF; 
        };

           #ifdef CALL_LOG

               for (no_arc_sens_counter = 0; no_arc_sens_counter<corros_num; no_arc_sens_counter++)
               {
                  sprintf(tmp_log_str, "%d, ",
                     unarc_data->inquiry[i].sens[no_arc_sens_counter]);
                  Log(tmp_log_str);

               }
               Log("\n");

           #endif

           cA=0; sA=0;

           if (corros_num == 288) { //coros 500

/*
              if ((unarc_data->inquiry[i].accel_x < 1000) && (unarc_data->inquiry[i].accel_x > 300))
              {
                 pred_accel_x = unarc_data->inquiry[i].accel_x;
              };

              if (unarc_data->inquiry[i].accel_y < 500)
              {
                 pred_accel_y = unarc_data->inquiry[i].accel_y;
              };

              if (full_trace_counter < 5610)
              {
//                 pred_accel_x = unarc_data->inquiry[i].accel_x;
                 pred_accel_y = unarc_data->inquiry[i].accel_y;
              };

              //                                          dAz         KAz
              sA=((double)(pred_accel_x-619.387)) / 263.849;
              //                                          dAy         KAy
              cA=((double)(pred_accel_y-572.477)) / 269.605;
*/
              //                                          dAz         KAz
              cA=((double)(unarc_data->inquiry[i].accel_y-594.214)) / (262.704);
              //                                          dAy         KAy
              sA=((double)(unarc_data->inquiry[i].accel_x-661.783)) / (269.6);
              unarc_data->inquiry[i].orient =
                   calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
            };

           if (corros_num == 128) { //1000 sit или coros 273
              if (strcmp(target_name, TARGET_NAME_COR1000sit)==0) {
                   // значит 1000 sit
                   //                                          dAz         KAz
                   cA=((double)(unarc_data->inquiry[i].accel_y-482.04)) / (-277.89);
                   //                                          dAy         KAy
                   sA=((double)(unarc_data->inquiry[i].accel_x-501.66)) / (-273.12);
                   unarc_data->inquiry[i].orient = calkulate_orientation(cA, sA, real_coros_num);
               } else {
                  // значит coros 273
                   cA=((double)(unarc_data->inquiry[i].accel_y-623.0)) / (251.0);
                   sA=((double)(unarc_data->inquiry[i].accel_x-439.0)) / (-249.0);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               };
            };

           if (corros_num == 512) { // stress 700
              //                                          dAz         KAz
              cA=((double)(unarc_data->inquiry[i].accel_y-555.004)) / (212.719);
              //                                          dAy         KAy
              sA=((double)(unarc_data->inquiry[i].accel_x-577.936)) / (-239.329);
              unarc_data->inquiry[i].orient =
                   calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
            };

           if (corros_num == 480) { // stress 1000
              //                                          dAz         KAz
              cA=((double)(unarc_data->inquiry[i].accel_y-354.713)) / (-267.67);
              //                                          dAy         KAy
              sA=((double)(unarc_data->inquiry[i].accel_x-593.29)) / (276.08);
              unarc_data->inquiry[i].orient =
                   calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
            };

           if (corros_num == 80) { // profile 700
              if (strcmp(target_name, TARGET_NAME_PROFIL700_2)==0) {
                  // значится новый блок профиль 700
              //                                          dAz         KAz
                  cA=((double)(unarc_data->inquiry[i].accel_y-561.44)) / (274.169);
                  //                                          dAy         KAy
                  sA=((double)(unarc_data->inquiry[i].accel_x-630.899)) / (277.84);
                  unarc_data->inquiry[i].orient =
                       calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else { // if (strcmp(target_name, TARGET_NAME_PROFIL700_2)==0) 
                  if (strcmp(target_name, TARGET_NAME_PROFIL500_2)==0) {
                      // значится новый блок профиль 500
                      //                                          dAz         KAz
                      sA=((double)(unarc_data->inquiry[i].accel_y-404.361)) / (264.913);
                      //                                          dAy         KAy
                      cA=((double)(unarc_data->inquiry[i].accel_x-478.812)) / (-274.92);
                      unarc_data->inquiry[i].orient =
                           calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
                   } else { // if (strcmp(target_name, TARGET_NAME_PROFIL500_2)==0) 
                      // значится старый блок профиль 700
                              //                                          dAz         KAz
                      sA=((double)(unarc_data->inquiry[i].accel_y-336.529)) / (267.879);
                      //                                          dAy         KAy
                      cA=((double)(unarc_data->inquiry[i].accel_x-677.377)) / (-274.0144);
                      unarc_data->inquiry[i].orient =
                           calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
                   }; //if (strcmp(target_name, TARGET_NAME_PROFIL500_2)==0) {
               }; // else { // if (strcmp(target_name, TARGET_NAME_PROFIL700_2)==0) 
            };


           if (corros_num == 528) { //Корозионник 508 (Иран)
              if (strcmp(target_name, TARGET_NAME_CORROS508)==0) {
                   // значит Корозионник 508 (Иран)
                   //                                          dAz         KAz
                   sA=((double)(unarc_data->inquiry[i].accel_y-503.413)) / (-238.14);
                   //                                          dAy         KAy
                   cA=((double)(unarc_data->inquiry[i].accel_x-534.308)) / (-242.59);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит ...
               };
            };

           if (corros_num == 40) { //Профиль 426
              if (strcmp(target_name, TARGET_NAME_PROFIL426)==0) {
                   // значит Профиль 426
                   //                                          dAz         KAz
                   cA=((double)(unarc_data->inquiry[i].accel_y-606.222)) / (-266.73);
                   //                                          dAy         KAy
                   sA=((double)(unarc_data->inquiry[i].accel_x-493.311)) / (-266.394);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит ...
               };
            };

           if (corros_num == 576) { //Стресс 1200
              if (strcmp(target_name, TARGET_NAME_STRESS1200)==0) {
                   // значит Стресс 1200
                   //                                          dAz         KAz
                   sA=((double)(unarc_data->inquiry[i].accel_y-498.425)) / (-254.87);
                   //                                          dAy         KAy
                   cA=((double)(unarc_data->inquiry[i].accel_x-490.753)) / (270.453);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит
               };
            };

           if (corros_num == 672) { //Стресс 500

              if (strcmp(target_name, TARGET_NAME_STRESS500)==0) {
                   // значит Стресс 500
                   //                                          dAz         KAz
                   sA=((double)(unarc_data->inquiry[i].accel_y-632.172)) / (270.017);
                   //                                          dAy         KAy
                   cA=((double)(unarc_data->inquiry[i].accel_x-522.695)) / (266.499);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит
               };
            };

           if (corros_num == 960) { //Стресс 1400
              if (strcmp(target_name, TARGET_NAME_STRESS1400)==0) {
                   // значит Стресс 1400
                   //                                          dAz         KAz
                   sA=((double)((unarc_data->inquiry[i].accel_y & 0x0FFF) -355.0)) / (-271.11);
                   //                                          dAy         KAy
                   cA=((double)((unarc_data->inquiry[i].accel_x & 0x0FFF) -524.93)) / (-262.89);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит
               };
            };

           if (corros_num == 1152) { //Корозионник 1400
              if (strcmp(target_name, TARGET_NAME_COROSS1400)==0) {
                   // значит Корозионник 1400
                   //                                          dAz         KAz
                   sA=((double)(unarc_data->inquiry[i].accel_y-664.249)) / (-260.6);
                   //                                          dAy         KAy
                   cA=((double)(unarc_data->inquiry[i].accel_x-499.833)) / (-271.852);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит
               };
            };

           if (corros_num == 160) { // Профиль 1400
              if (strcmp(target_name, TARGET_NAME_PROFIL1400)==0 ||
                  strcmp(target_name, TARGET_NAME_PROFIL1400D)==0) {
                   // значит Профиль 1400
                   //                                          dAz         KAz
                   cA=((double)((unarc_data->inquiry[i].accel_y & 0x0FFF) -1529.42)) / (978.57);
                   //                                          dAy         KAy
                   sA=((double)((unarc_data->inquiry[i].accel_x & 0x0FFF) -2408.945)) / (-1001.88);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит
               };
            };

           if (corros_num == 256) { // Корозионник 700
              if (strcmp(target_name, TARGET_NAME_COROSS700)==0) {
//                   // значит корозионник 700
//                   //                                          dAz         KAz
//                   cA=((double)(unarc_data->inquiry[i].accel_y-346.838)) / (-264.92);
//                   //                                          dAy         KAy
//                   sA=((double)(unarc_data->inquiry[i].accel_x-597.397)) / (273.174);

                   //                                          dAz         KAz
                   cA=((double)(unarc_data->inquiry[i].accel_y-380.239)) / (-264.75);
                   //                                          dAy         KAy
                   sA=((double)(unarc_data->inquiry[i].accel_x-466.187)) / (272.436);

                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит
               };
            };

           if (corros_num == 192) { // Корозионник 325
              if (strcmp(target_name, TARGET_NAME_CORROS325)==0) {
                   // значит Профиль 1400
                   //                                          dAz         KAz
                   cA=((double)(unarc_data->inquiry[i].accel_y-408.481)) / (265.205);
                   //                                          dAy         KAy
                   sA=((double)(unarc_data->inquiry[i].accel_x-479.748)) / (-274.951);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит
               };
            };

           if (corros_num == 64) { //Профиль 325
              if (strcmp(target_name, TARGET_NAME_PROFIL325)==0) {
                   // значит Профиль 426
                   //                                          dAz         KAz
                   cA=((double)(unarc_data->inquiry[i].accel_y-341.696)) / (-267.49);
                   //                                          dAy         KAy
                   sA=((double)(unarc_data->inquiry[i].accel_x-469.463)) / (-273.991);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит ...
               };
            };

           if (corros_num == 384) { //Корозионник 426
              if (strcmp(target_name, TARGET_NAME_CORROS426L)==0 ||
                  strcmp(target_name, TARGET_NAME_CORROS426D)==0
                 )
               {
                   // значит Корозионник 426
                   //                                          dAz         KAz
                   sA=((double)(unarc_data->inquiry[i].accel_y-527.455)) / (-266.33);
                   //                                          dAy         KAy
                   cA=((double)(unarc_data->inquiry[i].accel_x-651.892)) / (-264.296);
                   unarc_data->inquiry[i].orient =
                        calkulate_orientation(cA, sA, opened_trace->real_number_sensor_in_group[0]);
               } else {
                  // значит ...
               };
            };

           #ifdef CALL_LOG

//               // Выводим данные акселерометров с пересчитанными коэффициентами
//                 sprintf(tmp_log_str, "%lu, %f, %f\n",
//                 full_trace_counter, cA, sA);
//                 Log(tmp_log_str);
           #endif



#ifdef CALL_LOG
/*
       // точное время для ПГ

       if (full_trace_counter==0) {
           pred_time = unarc_data->inquiry[i].proc_tacts;
        };


//       if (unarc_data->inquiry[i].Pic_ful_track < 5)
//       {
//           full_trace_counter = full_trace_counter;
//       }

//       if (full_trace_counter < 10078)
//       {
//          back_trace_counter = full_trace_counter - 3;
//          pred_time = unarc_data->inquiry[i].proc_tacts;
//       }
//       else
       {

           if ( (unarc_data->inquiry[i].service_bit & 1) == 0)
           {
                if ( (unarc_data->inquiry[i].service_bit & 2) != 0)
                {
                  back_trace_counter += ( 2 * unarc_data->inquiry[i].skip_cycle );
                }
           } else {
                if ( (unarc_data->inquiry[i].service_bit & 4) == 0)
                {
                  back_trace_counter += ( 2 * unarc_data->inquiry[i].skip_cycle );
                }
           };

           cur_time = unarc_data->inquiry[i].proc_tacts;

           if ( cur_time < pred_time)
           {
                pred_time = cur_time - 300000;
           };

           d_time = cur_time - pred_time;

           d_time *= 32768;
           d_time /= 59659;
           d_time *= 100000;
           d_time /= opened_trace->frequency_processor;

           debug_counter = (long) unarc_data->inquiry[i].odom_number;
           sprintf(tmp_log_str, "%ld; %ld; ", full_trace_counter - back_trace_counter, d_time ); //, debug_counter);
           if (debug_counter) {
              strcat(tmp_log_str, "1\n");
           } else {
              strcat(tmp_log_str, "0\n");
           };
           Log(tmp_log_str);

           pred_time = cur_time;
       };
*/
#endif


           #ifdef CALL_LOG

           #define SPEAD_STEP 50
/*
           // выводим скорость
           if (full_trace_counter==0) {
               pred_time = unarc_data->inquiry[i].proc_tacts;
               next_step_full_trace_counter = SPEAD_STEP;
            };

           if (full_trace_counter >= next_step_full_trace_counter) {

                d_Pic_ful_track = full_trace_counter - pred_Pic_ful_track;

                cur_time = unarc_data->inquiry[i].proc_tacts;

                if ( cur_time < pred_time)
                {
                     pred_time = cur_time - 300000;
                };

                d_time = cur_time - pred_time;

                d_time *= 32768; // для DOS
                d_time /= 59659; // для DOS

                d_time *= 100000;                            // общее
                d_time /= opened_trace->frequency_processor; // общее

                if (d_time !=0 ) 
                {
                   spead = (d_Pic_ful_track * 500000) / d_time;
                } else {
                   spead = d_Pic_ful_track / 1;
                };

                sprintf(tmp_log_str, "%ld; %ld\n", full_trace_counter/2, spead);
                Log(tmp_log_str);

                pred_Pic_ful_track = full_trace_counter;
                pred_time = cur_time;
                next_step_full_trace_counter += SPEAD_STEP;
           };

*/

/*
           sprintf(name_log_str, "c:\\epro_log%.2ld.txt", debug_counter);

           // выводим датчики и ориентацию профиля 1400

           if ( (full_trace_counter % (100000*2)) == 0)
            {
                debug_counter++;
            };

            sprintf(tmp_log_str, "%4ld; ", full_trace_counter);

            for (j=0; j<corros_num/2; j++) {

                    translate_res = unarc_data->inquiry[i].sens[j];

                    prof_calibr_index=0;
                    while (translate_res < 
                            (opened_trace->profil_calibrate[j][prof_calibr_index])
                          )
                     {
                       prof_calibr_index++;
                     }; //while (translate_res ...

                    if (prof_calibr_index<=1) {
                        translate_res = 0;
                     } else {
                        translate_res = 10*(prof_calibr_index)
                        + 10 *
                        (
                        opened_trace->profil_calibrate[j][prof_calibr_index-1]
                        - 
                        translate_res
                        )
                         /
                        (
                         opened_trace->profil_calibrate[j][prof_calibr_index-1]
                         -
                         opened_trace->profil_calibrate[j][prof_calibr_index]
                        );

                     };

                sprintf(tmp_log_str_1, "%ld; ", translate_res);
               strcat(tmp_log_str, tmp_log_str_1);
             };

            sprintf(tmp_log_str_1, "%f\n", last_arctg2);
            strcat(tmp_log_str, tmp_log_str_1);
            Log(tmp_log_str);
*/
#endif


#ifdef CALL_LOG
       
/*    
//           if ( unarc_data->inquiry[i].skip_cycle > 1) {
               scip_counter += (unarc_data->inquiry[i].skip_cycle - 1);
               // Выводим пропуски
               sprintf(tmp_log_str, "%ld, %d \n", //, %ld\n",
                    unarc_data->inquiry[i].Pic_ful_track, unarc_data->inquiry[i].skip_cycle);//, scip_counter);
               Log(tmp_log_str);
//            };
*/

/*
         // вывод одометров профиля
       sprintf(tmp_log_str, "%ld = %ld, %ld, %ld (%ld) \n",
                          unarc_data->inquiry[i].Pic_ful_track,
                          unarc_data->inquiry[i].Pic_track_1,
                          unarc_data->inquiry[i].Pic_track_2,
                          unarc_data->inquiry[i].Pic_track_3,
                          unarc_data->inquiry[i].service_bit & 0x3
              );
       Log(tmp_log_str);
*/
#endif


        };  //for (i=0; i<unarc_data->head_of_condition_seam->real_dim; i++) {
    };  //if (ver_file == VER_FILE_EPRO_2) {


#ifdef CALL_LOG
//
//   for (i=0; i<unarc_data->head_of_condition_seam->real_dim; i++) {
//      // ориентация
//      sprintf(tmp_log_str, "%d\n", unarc_data->inquiry[i].orient);
//      Log(tmp_log_str);
//      debug_counter=0;
//    };
//

//   for (i=0; i<unarc_data->head_of_condition_seam->real_dim; i++) {
//      // температура
//      sprintf(tmp_log_str, "%ld, %ld\n", unarc_data->inquiry[i].Pic_ful_track,
//               (long) (0.868 * unarc_data->inquiry[i].termo - 61) );
//      Log(tmp_log_str);
//    };
#endif



#ifdef CALL_LOG
/*
 // движение туда обратно
   for (i=0; i<unarc_data->head_of_condition_seam->real_dim; i++) {

      d_Pic_ful_track=unarc_data->inquiry[i].Pic_ful_track-pred_Pic_ful_track;
      d_odom_forward=pred_odom_forward-unarc_data->inquiry[i].odom_forward;

         sprintf(tmp_log_str, "%d, %d, %d, %d\n",
                 unarc_data->inquiry[i].Pic_ful_track,
                 unarc_data->inquiry[i].odom_forward,
                 unarc_data->inquiry[i].Pic_ful_track-unarc_data->inquiry[i].odom_forward,
                 unarc_data->inquiry[i].service_bit & 0x6
                 );
         Log(tmp_log_str);
      pred_Pic_ful_track=unarc_data->inquiry[i].Pic_ful_track;
      pred_odom_forward=unarc_data->inquiry[i].odom_forward;
    };
*/
#endif

   if ( (unarc_data->head_of_condition_seam->real_dim 
         >=
         (unarc_data->head_of_condition_seam->end_odom -
          unarc_data->head_of_condition_seam->beg_odom +
          unarc_data->inquiry[0].skip_cycle
         )
        )  // если пропущенных измерений нет
        &&
        (unarc_data->head_of_condition_seam->cor_num_div==0)
      )

    {
       return KRT_OK;
    };

   sens_divizor=unarc_data->head_of_condition_seam->cor_num_div+1;

   // тута надо еще размножить пропуски в измерениях, раз они есть
   inquiry_no_skip = init_inquiry(corros_num,
                                  unarc_data->head_of_condition_seam->end_odom -
                                  unarc_data->head_of_condition_seam->beg_odom +
                                  unarc_data->inquiry[0].skip_cycle+1
                                 );
   if (inquiry_no_skip == NULL) {
      sprintf(drvError, "Нет памяти под истинные значения без пропусков(unarc_lzw)");
      return KRT_ERR;
    };


   no_skip_dimension_counter=0;
   for (i=0; i<unarc_data->head_of_condition_seam->real_dim; i++) {
      for (j=0; j<unarc_data->inquiry[i].skip_cycle; j++) {
         inquiry_no_skip[no_skip_dimension_counter].skip_cycle = 1;

         inquiry_no_skip[no_skip_dimension_counter].proc_tacts = 
                         pred_proc_tacts + (j+1) *
                         (unarc_data->inquiry[i].proc_tacts-pred_proc_tacts)/
                         unarc_data->inquiry[i].skip_cycle;

         inquiry_no_skip[no_skip_dimension_counter].odom_number =
                                            unarc_data->inquiry[i].odom_number;

         inquiry_no_skip[no_skip_dimension_counter].termo =
                                            unarc_data->inquiry[i].termo;

         inquiry_no_skip[no_skip_dimension_counter].orient =
                                            unarc_data->inquiry[i].orient;

         inquiry_no_skip[no_skip_dimension_counter].vibro_1 =
                                            unarc_data->inquiry[i].skip_cycle;

         inquiry_no_skip[no_skip_dimension_counter].Pic_ful_track =
                                            unarc_data->inquiry[i].Pic_ful_track;

         inquiry_no_skip[no_skip_dimension_counter].Pic_track_1 =
                                            unarc_data->inquiry[i].Pic_track_1;

         inquiry_no_skip[no_skip_dimension_counter].Pic_track_2 =
                                            unarc_data->inquiry[i].Pic_track_2;

         inquiry_no_skip[no_skip_dimension_counter].odom_forward =
                                            unarc_data->inquiry[i].odom_forward;

         inquiry_no_skip[no_skip_dimension_counter].accel_x =
                                            unarc_data->inquiry[i].accel_x;

         inquiry_no_skip[no_skip_dimension_counter].accel_y =
                                            unarc_data->inquiry[i].accel_y;

         inquiry_no_skip[no_skip_dimension_counter].service_bit =
                                            unarc_data->inquiry[i].service_bit;

         inquiry_no_skip[no_skip_dimension_counter].Pic_track_3 =
                                            unarc_data->inquiry[i].Pic_track_3;

         inquiry_no_skip[no_skip_dimension_counter].Pic_track_4 =
                                            unarc_data->inquiry[i].Pic_track_4;

         for (k=0; k<POWER_LINE_NUM_2; k++) {
              inquiry_no_skip[no_skip_dimension_counter].power_val[k] =
                                           unarc_data->inquiry[i].power_val[k];
          };
         inquiry_no_skip[no_skip_dimension_counter].power_flags =
                                           unarc_data->inquiry[i].power_flags; 

         for (k=0; k<corros_num/sens_divizor; k++) {
            for (clone_sens=0; clone_sens<sens_divizor; clone_sens++) {
                if ((i<unarc_data->head_of_condition_seam->real_dim-1) && (j>0)) {

                    inquiry_no_skip[no_skip_dimension_counter].sens[k*sens_divizor+clone_sens] =
                           unarc_data->inquiry[i].sens[k]
                           +
                           (unarc_data->inquiry[i+1].sens[k] 
                             -
                            unarc_data->inquiry[i].sens[k]
                           ) 
                            / 
                           unarc_data->inquiry[i].skip_cycle
                            *
                           j;
                 } else {
                    inquiry_no_skip[no_skip_dimension_counter].sens[k*sens_divizor+clone_sens] =
                                   unarc_data->inquiry[i].sens[k];
                 };

             };
          };
         no_skip_dimension_counter++;
       }; // for (j=0;
      pred_proc_tacts=unarc_data->inquiry[i].proc_tacts;

    }; // for (i=0; 

   unarc_data->head_of_condition_seam->real_dim=no_skip_dimension_counter;

   unarc_data->inquiry=free_inquiry(unarc_data->inquiry);

   unarc_data->inquiry=inquiry_no_skip;
   return KRT_OK;
}; // unarc_lzw


// увеличение имени номера файла вида "XXnnnnnХXX":
int inc_file_name(char *file_name) {
  file_name[6]++;
  if (file_name[6]>'9') {
    file_name[6]='0';
    file_name[5]++;
    if (file_name[5]>'9') {
      file_name[5]='0';
      file_name[4]++;
      if (file_name[4]>'9') {
        file_name[4]='0';
        file_name[3]++;
        if (file_name[3]>'9') {
          file_name[3]='0';
          file_name[2]++;
          if (file_name[2]>'9') {
             sprintf(drvError, "Ошибка inc_file_name('%s')", file_name);
             return KRT_ERR;
           };
         };
       };
     };
   };
   return KRT_OK;
 }; /* inc_file_name(char *file_name) */



  // должно быть заполнено  p_seam->smooth_orientation_beg
long smooth_orientation(T_INDEX_SEAM *p_seam,
                               double mul_factor,
                               long max_sens_num,
                               long max_orient_value)
{

  long inquiry_counter, k;

  long current_or=0;

  long average_sens_or = 0;
  long av_sens_old_or[AVERAGE_LENGTH_ORIENT]= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  long av_sens_len_or=1;

  long *P_av_sens_old_or=av_sens_old_or;

  long low_tube_cur_orient = max_sens_num/4;
  long up_tube_cur_orient  = max_sens_num-max_sens_num/4;
  long low_tube_src_orient = max_orient_value/4;
  long up_tube_src_orient  = max_orient_value-max_orient_value/4;


  // заполним вспомогательные переменные сглаживания ориентации
  current_or = p_seam->smooth_orientation_beg;
  average_sens_or = current_or * AVERAGE_LENGTH_ORIENT * 256;
  for (k=0; k< AVERAGE_LENGTH_ORIENT; k++) {
     av_sens_old_or[k]= current_or * 256;
   };

  // сглаживаем ориентацию 
  for (inquiry_counter=0; 
       inquiry_counter < (long) p_seam->head_of_condition_seam->real_dim;
       inquiry_counter++)
   {
      // тут из ориентации выкидываем FF
      if (p_seam->inquiry[inquiry_counter].orient > max_orient_value) {
          p_seam->inquiry[inquiry_counter].orient = (word) max_orient_value;
       };

        // отработаем переход через мах значение к 0
      if (current_or > up_tube_cur_orient && 
          p_seam->inquiry[inquiry_counter].orient < low_tube_src_orient) 
       {
          current_or = (long) (mul_factor * p_seam->inquiry[inquiry_counter].orient);
          current_or += max_sens_num;
       } else {
            // отработаем переход через 0 значение к max
          if (current_or < low_tube_cur_orient && 
              p_seam->inquiry[inquiry_counter].orient > up_tube_src_orient) 
           {
              current_or = (long) (mul_factor * p_seam->inquiry[inquiry_counter].orient);
              current_or = max_sens_num - current_or;
              current_or *= (-1);
           } else {
             current_or = (long) (mul_factor * p_seam->inquiry[inquiry_counter].orient);
           };
       };

      av_sens_len_or--;
      if (av_sens_len_or < 0) av_sens_len_or = AVERAGE_LENGTH_ORIENT-1;
      P_av_sens_old_or  = &av_sens_old_or[av_sens_len_or];

      current_or *= 256;
      average_sens_or -= *P_av_sens_old_or;
      average_sens_or += current_or;
      *P_av_sens_old_or = average_sens_or;

      *P_av_sens_old_or /= AVERAGE_LENGTH_ORIENT;
      average_sens_or -= current_or;
      average_sens_or += *P_av_sens_old_or;

      current_or = *P_av_sens_old_or;

      current_or /= 256;

      if (current_or >= max_sens_num)
       {
           current_or=0;  
           average_sens_or =(long) (current_or) * AVERAGE_LENGTH_ORIENT * 256;
           for (k=0; k< AVERAGE_LENGTH_ORIENT; k++) {
              av_sens_old_or[k]=(long)(current_or)*256;
            };
       } else {
           if (current_or<0) {
              current_or=max_sens_num-1;
              average_sens_or =(long) (current_or) * AVERAGE_LENGTH_ORIENT * 256;
              for (k=0; k< AVERAGE_LENGTH_ORIENT; k++) {
                 av_sens_old_or[k]=(long)(current_or)*256;
               };
            };
       };
      p_seam->inquiry[inquiry_counter].orient = (word) current_or;
   };// for (inquiry_counter=0; 

  pred_cur_orient = current_or;

  return KRT_OK;
}; // long smooth_orientation() {

// возвращает указатель на массив сумм предыдущих ... или NULL при ошибке
long * smooth_data (T_INDEX_SEAM *p_seam,                    
                    T_OPENED_TRACE *opened_trace,
                    long reg_flag
                   ) 
 {
 
  int dimension_counter, sens_counter, group_counter;
  int nuber_dimension_in_seam;
  int first_sens_in_cur_group;

  long translate_res;

  static long average_sens[MAX_CORROZION_NUM];
  static long av_sens_old[MAX_CORROZION_NUM][MAX_SMOOTH_WIN_LENGTH];

  static long av_sens_len[MAX_GROUP_NUM];

  EPRO_CORROSION_SENS_TYPE tmp_sens[MAX_CORROZION_NUM];

  static long abs_dim[MAX_CORROZION_NUM];
  static long pred_dim[MAX_CORROZION_NUM];
  int i;

  long prof_sens_num, prof_calibr_index;

  static long pred_sens_value[4096];
  static long pred_sens_value_repeat[4096];

  float f_shift;

//------------------------------------------------------------------------
/*
  first_sens_in_cur_group = 0;
  for ( group_counter=0; 
        group_counter<opened_trace->group_num;
        first_sens_in_cur_group+=opened_trace->linesense_size[group_counter++]
      ) 
   {
      for (sens_counter=first_sens_in_cur_group; 
           sens_counter < (first_sens_in_cur_group+opened_trace->linesense_size[group_counter]);
           sens_counter++) 
       {
          average_sens[sens_counter] =
                p_seam->smooth_data_beg[sens_counter] *
                opened_trace->smooth_win_length[group_counter]*256;
          for (av_sens_len[group_counter]=0;
               av_sens_len[group_counter]<opened_trace->smooth_win_length[group_counter];
               av_sens_len[group_counter]++) 
           {
             av_sens_old[sens_counter][av_sens_len[group_counter]] =
                  p_seam->smooth_data_beg[sens_counter]*256;
           };
       };
      av_sens_len[group_counter]=1;
   };
*/

  for (sens_counter = 0; sens_counter < MAX_CORROZION_NUM; sens_counter++) 
  {
     abs_dim[sens_counter] = 0;
     pred_dim[sens_counter] = 0;
  };


  first_sens_in_cur_group = 0;
  for ( group_counter=0; 
        group_counter<opened_trace->group_num;
        first_sens_in_cur_group += opened_trace->linesense_size[group_counter++]
      ) 
   {
      for (sens_counter=first_sens_in_cur_group; 
           sens_counter < (first_sens_in_cur_group+opened_trace->linesense_size[group_counter]);
           sens_counter++) 
       {
          average_sens[sens_counter] =
                p_seam->smooth_data_beg[sens_counter] *
                opened_trace->smooth_win_length[group_counter] * 256;
          for (av_sens_len[group_counter]=0;
               av_sens_len[group_counter]<opened_trace->smooth_win_length[group_counter];
               av_sens_len[group_counter]++) 
           {
             av_sens_old[sens_counter][av_sens_len[group_counter]] =
                 p_seam->smooth_data_beg[sens_counter] * 256;
           };
       };
      av_sens_len[group_counter]=1;
   };


//------------------------------------------------------------------------

  nuber_dimension_in_seam = p_seam->head_of_condition_seam->real_dim;

  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {

     // отсортируем данные
     for (sens_counter=0; 
          sens_counter < opened_trace->corosion_sens_num;
          sens_counter++) 
      {
          if ( opened_trace->Sckip_sens_data[sens_counter] > 0 ) {
             tmp_sens[opened_trace->sens_sort[sens_counter]] = 0;
           } else {
              tmp_sens[opened_trace->sens_sort[sens_counter]] =
                  p_seam->inquiry[dimension_counter].sens[sens_counter];
           };
      };

      for (sens_counter=0; 
           sens_counter < opened_trace->corosion_sens_num;
           sens_counter++) 
      {
         p_seam->inquiry[dimension_counter].sens[sens_counter] =
            tmp_sens[sens_counter];
      };
     // отсортировали данные

     first_sens_in_cur_group = 0;
     for ( group_counter=0;
           group_counter<opened_trace->group_num;
           first_sens_in_cur_group+=opened_trace->linesense_size[group_counter++]
         ) 
     {
         av_sens_len[group_counter]--;
         if (av_sens_len[group_counter]<0) {
             av_sens_len[group_counter] = opened_trace->smooth_win_length[group_counter]-1;
          }

         for (sens_counter=first_sens_in_cur_group; 
              sens_counter < (first_sens_in_cur_group+opened_trace->linesense_size[group_counter]);
              sens_counter++) 
         {
             if (p_seam->inquiry[dimension_counter].sens!=NULL) {
                 // проинвертируем данные если это надо
                 if (opened_trace->invert_sens_data[sens_counter]!=0) {
                    p_seam->inquiry[dimension_counter].sens[sens_counter] = 
                             ((EPRO_CORROSION_SENS_TYPE)opened_trace->max_data_code) -
                             p_seam->inquiry[dimension_counter].sens[sens_counter];
                  };

                 translate_res = p_seam->inquiry[dimension_counter].sens[sens_counter];
              } else {
                 translate_res = av_sens_old[sens_counter][av_sens_len[group_counter]] / 256;
              };

             translate_res *= 256;
             average_sens[sens_counter] -= av_sens_old[sens_counter][av_sens_len[group_counter]];

             average_sens[sens_counter] += translate_res;
             av_sens_old[sens_counter][av_sens_len[group_counter]] = average_sens[sens_counter];

             av_sens_old[sens_counter][av_sens_len[group_counter]]  /= opened_trace->smooth_win_length[group_counter];
             average_sens[sens_counter] -= translate_res;
             average_sens[sens_counter] += av_sens_old[sens_counter][av_sens_len[group_counter]];

             translate_res -= av_sens_old[sens_counter][av_sens_len[group_counter]];

             translate_res*=opened_trace->Amplification_Group[group_counter];

             translate_res /= 256;

             translate_res += opened_trace->max_data_code/2;

             if (translate_res>opened_trace->max_data_code) {
                 translate_res=opened_trace->max_data_code;
              } else {
                 if (translate_res<0) translate_res=0;
              };

             if (translate_res <= opened_trace->lo_border) {
                 translate_res = opened_trace->lo_border;
             }

             if (reg_flag!=1) {
                if (opened_trace->Smooth_data_OFF==0) {
                    p_seam->inquiry[dimension_counter].math_sens[sens_counter] = 
                        (EPRO_CORROSION_SENS_TYPE) translate_res;
                 } else {
                    p_seam->inquiry[dimension_counter].math_sens[sens_counter] = 
                        p_seam->inquiry[dimension_counter].sens[sens_counter];
                 };
              };

         }; // for (sens_counter=

     }; // for ( group_counter=0;

    // заполним толщину
    if (opened_trace->sens_for_thick+opened_trace->sens_for_thick_count >
         opened_trace->linesense_size[0])
     {
        opened_trace->sens_for_thick_count = 
        opened_trace->linesense_size[0]-opened_trace->sens_for_thick;
     };

     translate_res=0;
     for( sens_counter=0;
          sens_counter<opened_trace->sens_for_thick_count;
          sens_counter++
        )
      {
        translate_res+=(average_sens[sens_counter+opened_trace->sens_for_thick]
                         /256/opened_trace->smooth_win_length[0]);
      };

     p_seam->inquiry[dimension_counter].Thick = (word)
          (translate_res / opened_trace->sens_for_thick_count);
    // заполнили толщину

   }; // for dimension_counter

  return average_sens;
 }; // long * smooth_data (T_INDEX_SEAM *p_seam,


#define alfa 10

long exponent_filter( T_INDEX_SEAM *p_seam, long add_seam_test_num, T_OPENED_TRACE *opened_trace)
{
    static long Smoth[MAX_CORROZION_NUM];

    long sens_num;

    long result;

	 // собственно усредненние занчений
    for (sens_num = 0; 
         sens_num < opened_trace->corosion_sens_num;
         sens_num ++) 
    {
       if (opened_trace->Smooth_data_OFF==0) {

           result =  alfa * p_seam->inquiry[add_seam_test_num].sens[sens_num];

           result += (100 - alfa) * Smoth[sens_num];

           result /= 100;

           Smoth[sens_num] = result;


           result = p_seam->inquiry[add_seam_test_num].sens[sens_num];

           result =

           ( result - Smoth[sens_num] )
           *
           opened_trace->Amplification_Group[0]
           +
           ( opened_trace->max_data_code / 2 );

           if (result >= opened_trace->max_data_code) result = opened_trace->max_data_code - 2;
           if (result < 0 ) result = 0;

           p_seam->inquiry[add_seam_test_num].math_sens[sens_num] = (word) result;

        } else {
           p_seam->inquiry[add_seam_test_num].math_sens[sens_num] = 
               p_seam->inquiry[add_seam_test_num].sens[sens_num];
        };
    }; // for sens_counter

/*
    for (dimension_counter=0;
         dimension_counter<nuber_dimension_in_seam;
         dimension_counter++) 
     {
       Averade_for_Thick = 0;
       for (sens_counter=0; 
            sens_counter < opened_trace->corosion_sens_num; 
            sens_counter++) 
        {
           // посчитаем толщину
           Averade_for_Thick += average_sens[sens_counter];
        };
       p_seam->inquiry[dimension_counter].Thick = (word)
               (Averade_for_Thick / opened_trace->corosion_sens_num );
     };
*/


   return 0;

}; // long exponent_filter( T_INDEX_SEAM *p_seam, long add_sens_num)



long median_filter( T_INDEX_SEAM *p_seam, long add_seam_test_num, T_OPENED_TRACE *opened_trace)
{
    static long src_data_bufer [MAX_MEDIAN_FILTER_LENGTH] [MAX_CORROZION_NUM];

    static long cur_src_data_buf_len = 0;

    static long cur_pos_src_data_buf = 0;

    static long av_sens_median [MAX_CORROZION_NUM][MAX_DATA_MEDIAN];

    long pos_data_buf;


    long src_buf_len_count, sens_num;

    int value_counter;

    static long max_gistogr_val[MAX_CORROZION_NUM];

    static long average_sens[MAX_CORROZION_NUM];
    static long average_sens_pred[MAX_CORROZION_NUM];
    static long first_flag = 0;

    long result;

    if (opened_trace->Median_Filter_length > MAX_MEDIAN_FILTER_LENGTH)
    {
        opened_trace->Median_Filter_length = MAX_MEDIAN_FILTER_LENGTH;
    };

    if (opened_trace->Median_Filter_length < 2)
    {
        opened_trace->Median_Filter_length = 2;
    };

    if (cur_src_data_buf_len >= opened_trace->Median_Filter_length)
    {
        // вычеркнем устаревшее значение из таблица гистограм
        for (sens_num = 0; sens_num < opened_trace->corosion_sens_num; sens_num ++)
        {
            av_sens_median [sens_num] [ src_data_bufer [cur_pos_src_data_buf] [sens_num] ] --;

            value_counter = src_data_bufer [cur_pos_src_data_buf] [sens_num];

            if ( value_counter == average_sens[sens_num] )
            {
                 max_gistogr_val[sens_num] = 0;
                 // ищем максимумы гистограмы датчика
                 for (value_counter = 0;
                      value_counter < MAX_DATA_MEDIAN;
                      value_counter++) 
                 {
                     if (max_gistogr_val[sens_num] < av_sens_median [sens_num][value_counter] )
                     {
                          max_gistogr_val[sens_num] = av_sens_median [sens_num][value_counter];

                          average_sens[sens_num] = value_counter;
                     };
                 }; // for value_counter;
            };

        };
        cur_src_data_buf_len--;
        // вычеркнули устаревшее значение из таблица гистограм
    };

    // добавим новое значение в буфер исходных данных и таблицу гистограмм
    for (sens_num = 0; sens_num < opened_trace->corosion_sens_num; sens_num ++)
    {
        src_data_bufer [cur_pos_src_data_buf] [sens_num] 
               = (p_seam->inquiry[add_seam_test_num].sens[sens_num] - 32768);

        av_sens_median [sens_num] [ src_data_bufer [cur_pos_src_data_buf] [sens_num] ] ++;

        value_counter = src_data_bufer [cur_pos_src_data_buf] [sens_num];

        if ( value_counter != average_sens[sens_num] )
        {
             if (max_gistogr_val[sens_num] < av_sens_median [sens_num][value_counter] )
             {
                  max_gistogr_val[sens_num] = av_sens_median [sens_num][value_counter];

                  average_sens[sens_num] = value_counter;
             };
        };

    };
    // добавили новое значение в буфер исходных данных и таблицу гистограм

    cur_src_data_buf_len++;

    cur_pos_src_data_buf++;
    if (cur_pos_src_data_buf >= opened_trace->Median_Filter_length) cur_pos_src_data_buf=0;


//    if (first_flag < opened_trace->Median_Filter_length)
    //{
        for (sens_num = 0; 
             sens_num < opened_trace->corosion_sens_num;
             sens_num ++)
        {
              average_sens_pred[sens_num] = average_sens[sens_num];
        }
        first_flag ++;

/*     } else 
     {
        for (sens_num = 0; 
             sens_num < opened_trace->corosion_sens_num;
             sens_num ++)
        {

             if ( ((average_sens[sens_num] - average_sens_pred[sens_num]) >  3) ||
                  ((average_sens[sens_num] - average_sens_pred[sens_num]) < -3)
                )
             {
                average_sens_pred[sens_num] += ((average_sens[sens_num] - average_sens_pred[sens_num])/5);
             } else {
                average_sens_pred[sens_num] = average_sens[sens_num];
             }
			 
        }
     };
*/
    pos_data_buf = cur_pos_src_data_buf - 1 - opened_trace->Median_Filter_length/2;
    if (pos_data_buf < 0) pos_data_buf = opened_trace->Median_Filter_length + pos_data_buf;

	 // собственно усредненние занчений
    for (sens_num = 0; 
         sens_num < opened_trace->corosion_sens_num;
         sens_num ++) 
    {
       if (opened_trace->Smooth_data_OFF==0) {

           result = ( src_data_bufer[ pos_data_buf ][sens_num] - average_sens_pred[sens_num] );
           
           result *= opened_trace->Amplification_Group[0];
           
           result += ( opened_trace->max_data_code / 2 );

           if (result >= opened_trace->max_data_code ) result = opened_trace->max_data_code - 2;
           if (result < 0 ) result = 0;

           p_seam->inquiry[add_seam_test_num].math_sens[sens_num] = (word) result;

           p_seam->inquiry[add_seam_test_num].sens[sens_num] = src_data_bufer[ pos_data_buf ][sens_num];

        } else {
           p_seam->inquiry[add_seam_test_num].math_sens[sens_num] = 
               p_seam->inquiry[add_seam_test_num].sens[sens_num] = src_data_bufer[ pos_data_buf ][sens_num];
        };
    }; // for sens_counter

/*
    for (dimension_counter=0;
         dimension_counter<nuber_dimension_in_seam;
         dimension_counter++) 
     {
       Averade_for_Thick = 0;
       for (sens_counter=0; 
            sens_counter < opened_trace->corosion_sens_num; 
            sens_counter++) 
        {
           // посчитаем толщину
           Averade_for_Thick += average_sens[sens_counter];
        };
       p_seam->inquiry[dimension_counter].Thick = (word)
               (Averade_for_Thick / opened_trace->corosion_sens_num );
     };
*/


   return 0;

}; // long median_filter( T_INDEX_SEAM *p_seam, long add_sens_num)

// возвращает указатель на массив сумм предыдущих ... или NULL при ошибке
long * Use_median_data (
                         T_INDEX_SEAM *p_seam,
                         T_OPENED_TRACE *opened_trace,
                         long reg_flag
                       ) 
 {
 
  int dimension_counter, sens_counter;
  int nuber_dimension_in_seam;

  EPRO_CORROSION_SENS_TYPE tmp_sens[MAX_CORROZION_NUM];

  hyper Averade_for_Thick;

  nuber_dimension_in_seam = p_seam->head_of_condition_seam->real_dim;


  for (dimension_counter = 0;
       dimension_counter < nuber_dimension_in_seam;
       dimension_counter++) 
  {
     Averade_for_Thick = 0;
     for (sens_counter=0; 
          sens_counter < opened_trace->corosion_sens_num; 
          sens_counter++) 
      {
         // проинвертируем данные если это надо
         if (opened_trace->invert_sens_data[sens_counter]!=0) {
            p_seam->inquiry[dimension_counter].sens[sens_counter] = (word)
                    (opened_trace->max_data_code -
                    p_seam->inquiry[dimension_counter].sens[sens_counter]);
          };
       };
  }; //for (dimension_counter=0


  for (dimension_counter = 0;
       dimension_counter < nuber_dimension_in_seam;
       dimension_counter++) 
  {
     // отсортируем данные
     for (sens_counter=0; 
          sens_counter < opened_trace->corosion_sens_num;
          sens_counter++) 
      {
            tmp_sens[opened_trace->sens_sort[sens_counter]] =
                p_seam->inquiry[dimension_counter].sens[sens_counter];
      }; // for (sens_counter=0; 

      for (sens_counter=0; 
           sens_counter < opened_trace->corosion_sens_num;
           sens_counter++) 
       {
         p_seam->inquiry[dimension_counter].sens[sens_counter] =
            tmp_sens[sens_counter];
       };

   }; // for (dimension_counter = 0;


  for (dimension_counter = 0;
       dimension_counter < nuber_dimension_in_seam;
       dimension_counter++) 
  {
     median_filter( p_seam, dimension_counter, opened_trace);

     //exponent_filter( p_seam, dimension_counter, opened_trace);

  }; // for (dimension_counter=0;

  return NULL;
}; // long * Use_median_data (



long enumerate_work_files( char *first_File, 
                           long *data_path_len,
                           long *files_num) 
{
  char path_first_file[_MAX_PATH];
  FILE *cur_file;
  
  T_FILE_HEADER file_header;
  long read_res;         // кол-во байтов прочитанное fread

  // посчитаем длинну строки пути до первого файла (без имени)
  strcpy(path_first_file, first_File);
  *data_path_len=strlen(path_first_file);

  while ((*data_path_len>0) && (path_first_file[*data_path_len-1]!='\\')) {
    path_first_file[(*data_path_len)-1]=0;
    (*data_path_len)--;
   };
  // посчитали длинну строки пути до первого файла (без имени)


  *files_num=1;
  strcpy(path_first_file, first_File);
  if (inc_file_name(&path_first_file[*data_path_len])!=KRT_OK ) {
    strcat(drvError, "(enumerate_work_files)");
    return KRT_ERR;
   };

  while ((cur_file=fopen(path_first_file, "rb")) !=NULL) {
	 // прочитаем заголовок файла
     read_res=fread(&file_header, 1, sizeof(T_FILE_HEADER), cur_file);

     fclose(cur_file);

     if (read_res != sizeof(T_FILE_HEADER)) {
        break;
     };

     (*files_num)++;
     if (inc_file_name(&path_first_file[*data_path_len])!= KRT_OK ){
        strcat(drvError, "(enumerate_work_files)");
        return KRT_ERR;
      };
   }; // while ( (trace_list.trace->file_data=fopen(current_file_data, "rb") !=NULL) {

  return KRT_OK;
 }; // long enumerate_work_files(

long enumerate_seam_in_files( T_INDEX_FILE *index_file) { 

  long read_res;         // кол-во байтов прочитанное fread
  long pos_in_file;      // в каком месте файла находимся

  T_DESCRIPTOR cur_descriptor; // шаблон дескриптора файла
  T_CONDITION_SEAM cur_seam;

  T_FILE_HEADER file_header;

  // откроем файл данных
  index_file->file_data = fopen(index_file->file_name, "rb");
  if (index_file->file_data ==NULL) {
    sprintf (drvError, "Ошибка открытия файла %s(enumerate_seam_in_files)", index_file->file_name);
    return KRT_ERR;
   };

  // прочитаем заголовок файла
  read_res=fread(&file_header, 1, sizeof(T_FILE_HEADER), index_file->file_data);

  if (read_res != sizeof(T_FILE_HEADER)) {
    sprintf (drvError, "Ошибка чтения заголовка файла %s(enumerate_seam_in_files)", index_file->file_name);
    fclose(index_file->file_data);
    index_file->file_data =NULL;
    return KRT_ERR;
   };
  pos_in_file=read_res;

  index_file->num_condition_seam=0;
  // пока файл не закончился, будем читать и пересчитывать усл. швы
  while((read_res=fread(&cur_descriptor, 1, sizeof(T_DESCRIPTOR), index_file->file_data) 
        ) ==  sizeof(T_DESCRIPTOR))
   {
      pos_in_file+=read_res;

      if (cur_descriptor.ver_file==VER_FILE_EPRO    ||
          cur_descriptor.ver_file==VER_FILE_EPRO_2  ||
          cur_descriptor.ver_file==VER_FILE_EPRO_3  ||
          cur_descriptor.ver_file==VER_FILE_EPRO_31 ||
          cur_descriptor.ver_file==VER_FILE_EPRO_32 ||
          cur_descriptor.ver_file==VER_FILE_EPRO_15
         ) {
         switch (cur_descriptor.descriptor_type) {
            case (DESCRIPTOR_CONDITION_SEAM): {
               if (cur_descriptor.descriptor_Size!=sizeof(T_CONDITION_SEAM)+sizeof(T_DESCRIPTOR))
                {
                  sprintf (drvError, "Ошибка формата файла %s(enumerate_seam_in_files)", index_file->file_name);
                  fclose(index_file->file_data);
                  index_file->file_data =NULL;
                  return KRT_ERR;
                };
              if((read_res=fread(&cur_seam, 1, sizeof(T_CONDITION_SEAM), index_file->file_data) 
                    ) ==  sizeof(T_CONDITION_SEAM)) {
                   pos_in_file+=read_res;
                   index_file->num_condition_seam++;
                   pos_in_file+=cur_seam.arc_size;
                   fseek (index_file->file_data, pos_in_file, SEEK_SET);
                   break;
                } else {
                  sprintf (drvError, "Ошибка чтения усл. шва %s(enumerate_seam_in_files)", index_file->file_name);
                  fclose(index_file->file_data);
                  index_file->file_data =NULL;
                  return KRT_ERR;
                };
             }; //case (DESCRIPTOR_CONDITION_SEAM):

            case (DESCRIPTOR_START_PROGRAM):
            case (DESCRIPTOR_OFF_UVD):
            case (DESCRIPTOR_ON_UVD):
            case (DESCRIPTOR_BEGIN_STOP):
            case (DESCRIPTOR_END_STOP): {
              if((read_res=fread(&cur_seam, 1, cur_descriptor.descriptor_Size, index_file->file_data) 
                    ) ==  cur_descriptor.descriptor_Size) 
                {
                  pos_in_file+=cur_descriptor.descriptor_Size;
                  break;
                } else {
                  sprintf (drvError, "Ошибка чтения данных дескриптора %s(enumerate_seam_in_files)", index_file->file_name);
                  fclose(index_file->file_data);
                  index_file->file_data =NULL;
                  return KRT_ERR;
                };
             }; // case (DESCRIPTOR_END_STOP):

            default : {
               sprintf (drvError, "Неизвестный дескриптор(enumerate_seam_in_files)");
               fclose(index_file->file_data);
               index_file->file_data =NULL;
               return KRT_ERR;
             }; // default :

          }; // switch (cur_descriptor.descriptor_type)

       } else { // if (cur_descriptor.ver_file==VER_FILE_EPRO)
         sprintf (drvError, "Неизвестная версия файла(enumerate_seam_in_files)");
         fclose(index_file->file_data);
         index_file->file_data =NULL;
         return KRT_ERR;
       }; // if (cur_descriptor.ver_file==VER_FILE_EPRO)

      fseek (index_file->file_data, pos_in_file, SEEK_SET);
   }; // while(fread( &cur_descriptor, 1,

  // закроем файл данных
  fclose(index_file->file_data);
  index_file->file_data = NULL;

  return KRT_OK;
}; // long enumerate_seam_in_files(

// 
long calkulate_index_files_and_sems(T_OPENED_TRACE *opened_trace,
                                           long file_counter)
{
  static long smooth_beg[MAX_CORROZION_NUM];
  long *smooth_data_result;

  unsigned long read_res;         // кол-во байтов прочитанное fread
  unsigned long sum_read_res;

  long pos_in_file;      // в каком месте файла находимся
  long seam_counter;     // счетчик усл. шва
  long sens_counter;
  long group_counter;
  long first_sens_in_cur_group;

  dword dimension_counter;
  long cur_termo;

  T_DESCRIPTOR cur_descriptor; // шаблон дескриптора

  T_FILE_HEADER file_header;

  word *arc_data;

  T_INDEX_FILE *index_file;

  long smooth_orient_res;

  T_NAVIGATION_DATA NavData;
  T_VOG_DATA VogData;
  static long my_start;

  static long pred_Pic_ful_track=0;
  static long pred_odom_forward=0;
  static long d_Pic_ful_track=0;
  static long d_odom_forward=0;
  static long move_forward_count=0;
  static long move_bakward_count=0;

  static hyper full_timer_ms = 0;
  static hyper pred_timer_ms = 0;
  static hyper shift_time_after_stop = 0;
  static long pred_spead;

  FILE *ext_data;
  FILE *power_data;

  long i;

  static long pred_beg_track=0;
  static long pred_end_track=0;
  
  index_file = &opened_trace->file_index[file_counter];

  // откроем файл данных
  index_file->file_data = fopen(index_file->file_name, "rb");
  if (index_file->file_data ==NULL) {
    sprintf (drvError, "Ошибка открытия файла %s(calkulate_index_files_and_sems)", index_file->file_name);
    return KRT_ERR;
   };

  // прочитаем заголовок файла
  read_res=fread(&file_header, 1, sizeof(T_FILE_HEADER), index_file->file_data);

  if (read_res != sizeof(T_FILE_HEADER)) {
    sprintf (drvError, "Ошибка чтения заголовка файла %s(calkulate_index_files_and_sems)", index_file->file_name);
    fclose(index_file->file_data);
    index_file->file_data =NULL;
    return KRT_ERR;
   };
  pos_in_file=read_res;

  // заполним поле количества датчиков и частоту процессора:
  // возможно надо его еще и анализировать, вдруг меняется
  // на протяжении трассы, но пока и так пойдет.
  opened_trace->frequency_processor = file_header.proc_frequency;
  strcpy(opened_trace->target_name, file_header.target_name);

  if (strcmp(opened_trace->target_name, TARGET_NAME_COROSS700)==0)
  {
       opened_trace->frequency_processor = file_header.proc_frequency = 498078981;
  };

/*
  if (strcmp(opened_trace->target_name, TARGET_NAME_STRESS500)==0)
  {
       opened_trace->frequency_processor = file_header.proc_frequency = 265924140;
  };
*/
  if (file_counter==0) {
     opened_trace->corosion_sens_num = file_header.cor_num;
     // заполним данные зависящие от конкретного кол-ва датчиков
     init_bort_factor_data (opened_trace, file_header.target_name, file_counter);
   };

  if ( (strcmp(opened_trace->target_name, TARGET_NAME_STRESS1400)==0)  || 
       (strcmp(opened_trace->target_name, TARGET_NAME_COROSS1400)==0)  ||
       (strcmp(opened_trace->target_name, TARGET_NAME_PROFIL1400)==0)  ||
       (strcmp(opened_trace->target_name, TARGET_NAME_COROSS500)==0)   ||
       (strcmp(opened_trace->target_name, TARGET_NAME_COROSS700)==0)   ||
       (strcmp(opened_trace->target_name, TARGET_NAME_PROFIL700_2)==0) || 
       (strcmp(opened_trace->target_name, TARGET_NAME_PROFIL500_2)==0) ||
       (strcmp(opened_trace->target_name, TARGET_NAME_STRESS500)==0)   ||
       (strcmp(opened_trace->target_name, TARGET_NAME_CORROS426L)==0)  ||
       (strcmp(opened_trace->target_name, TARGET_NAME_STRESS1000)==0)  ||
       (strcmp(opened_trace->target_name, TARGET_NAME_CORROS325)==0) 
     )
    {
       // Значится Линух (linux) бортовуха
      timer_ms = opened_trace->frequency_processor;
      timer_ms *= 16384;
      timer_ms /= 298295;
      opened_trace->frequency_processor = (unsigned long) timer_ms;
    };

//-----------------------------------------------------------------------------
  for (seam_counter=0; seam_counter<index_file->num_condition_seam; seam_counter++) {
      index_file->index_seam[seam_counter].smooth_data_beg = 
                init_smooth_data_beg(opened_trace->corosion_sens_num);
      if (index_file->index_seam[seam_counter].smooth_data_beg==NULL) {
         strcat(drvError, "(calkulate_index_files_and_sems)");
         fclose(index_file->file_data);
         index_file->file_data =NULL;
         return KRT_ERR;
       };
   };
//---------------------------------------------------------------------

  seam_counter=0;

  ext_data = fopen(opened_trace->index_extend_sens.file_name, "ab");

  power_data = fopen(opened_trace->index_power_lines.file_name, "ab");


  // пока файл не закончился, будем читать и индексировать
  while((read_res=fread(&cur_descriptor, 1, sizeof(T_DESCRIPTOR), index_file->file_data) 
        ) ==  sizeof(T_DESCRIPTOR))
   {
     sum_read_res=read_res;

     switch (cur_descriptor.descriptor_type) {
        case (DESCRIPTOR_CONDITION_SEAM): {
           if (cur_descriptor.descriptor_Size!=sizeof(T_CONDITION_SEAM)+sizeof(T_DESCRIPTOR))
            {
              sprintf (drvError, "Ошибка формата файла %s(calkulate_index_files_and_sems)", index_file->file_name);
              fclose(index_file->file_data);
              index_file->file_data =NULL;
              return KRT_ERR;
            };
           index_file->index_seam[seam_counter].head_of_condition_seam =
                    init_condition_seam();
           if (index_file->index_seam[seam_counter].head_of_condition_seam==NULL) {
             strcat (drvError, "(calkulate_index_files_and_sems)");
             fclose(index_file->file_data);
             index_file->file_data =NULL;
             return KRT_ERR;
            };

           if((read_res=fread(index_file->index_seam[seam_counter].head_of_condition_seam,
                              1, sizeof(T_CONDITION_SEAM), index_file->file_data
                             ) 
              ) !=  sizeof(T_CONDITION_SEAM)) 
            {
              sprintf (drvError, "Ошибка чтения усл. шва %s(calkulate_index_files_and_sems)", index_file->file_name);
              fclose(index_file->file_data);
              index_file->file_data =NULL;
              return KRT_ERR;
            };
           sum_read_res+=read_res;

           index_file->index_seam[seam_counter].beg_track = pred_end_track+1;
//                   index_file->index_seam[seam_counter].head_of_condition_seam->beg_odom;

           index_file->index_seam[seam_counter].end_track =
              index_file->index_seam[seam_counter].beg_track +
              index_file->index_seam[seam_counter].head_of_condition_seam->end_odom
              -
              index_file->index_seam[seam_counter].head_of_condition_seam->beg_odom;

           pred_end_track = index_file->index_seam[seam_counter].end_track;

           index_file->index_seam[seam_counter].shift_in_file=pos_in_file;

           pos_in_file+=sum_read_res;

           if (seam_counter==0) {  // если это первый найденный усл.шов

              if ( (opened_trace->corosion_sens_num==80) ||
//                   (opened_trace->corosion_sens_num==64) ||
                   (opened_trace->corosion_sens_num==40) ||
                   (opened_trace->corosion_sens_num==160) )
               {
                  // если это у нас профиль
                  if (read_data_profil_ini(opened_trace) == KRT_ERR) {
                     // что-то не так с калибровкой профиля
                   };
               };
			  VogData.file_data = NULL;
              Init_VogData(&VogData, opened_trace->trc_file_name);
			  NavData.file_data = NULL;
              Init_NavData(&NavData, opened_trace->trc_file_name);

              // зададим начало данных в файле от начала трассы
              index_file->beg_track = index_file->index_seam[seam_counter].beg_track;
            };

           if (seam_counter == index_file->num_condition_seam-1) { // если это последний найденный усл.шов
              // зададим конец данных в файле от начала трассы
              index_file->end_track=index_file->index_seam[seam_counter].end_track;
            };

           // и сформировать индексную информацию
           arc_data=(word *) heap_alloc(index_file->index_seam[seam_counter].head_of_condition_seam->arc_size);

           if (arc_data==NULL) {
              sprintf (drvError, "Ошибка выделения памяти под архивные данные(calkulate_index_files_and_sems)");
              index_file->index_seam[seam_counter].head_of_condition_seam = 
                      free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);
              fclose(index_file->file_data);
              index_file->file_data =NULL;
              return KRT_ERR;
            };

           if((read_res=fread(arc_data, 1, 
                              index_file->index_seam[seam_counter].head_of_condition_seam->arc_size,
                              index_file->file_data) 
             ) != index_file->index_seam[seam_counter].head_of_condition_seam->arc_size)
            {
              seam_counter++;
              sprintf (drvError, "Ошибка чтения файла %s (calkulate_index_files_and_sems)", index_file->file_name);
			  break;
              index_file->index_seam[seam_counter].head_of_condition_seam = 
                      free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);
              arc_data = (WORD *) heap_free(arc_data);
              fclose(index_file->file_data);
              index_file->file_data =NULL;
              return KRT_ERR;
            };

           pos_in_file+=index_file->index_seam[seam_counter].head_of_condition_seam->arc_size;

           // разархивируем данные
           if (unarc_lzw(arc_data, 
                         index_file->index_seam[seam_counter].head_of_condition_seam->arc_size/2, 
                         &index_file->index_seam[seam_counter],
                         opened_trace->corosion_sens_num,
                         cur_descriptor.ver_file, opened_trace->target_name,
                         opened_trace->real_number_sensor_in_group[0],
                         opened_trace
                        )
                == KRT_ERR) 
            {
              strcat (drvError, "(calkulate_index_files_and_sems)");
              arc_data = (WORD *) heap_free(arc_data);

              // освободим весь условный шов
              index_file->index_seam[seam_counter].inquiry =
                   free_inquiry(index_file->index_seam[seam_counter].inquiry);

              index_file->index_seam[seam_counter].head_of_condition_seam = 
                      free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);
              fclose(index_file->file_data);
              index_file->file_data =NULL;
              return KRT_ERR;
            };
            // разархивировали данные 


/*

  // Сделаем диферинциальное вычитание между соседними измерениями
  seam = seam_counter;
  for (dim_count = 0;
       dim_count < index_file->index_seam[seam].head_of_condition_seam->real_dim-1;
       dim_count++)
  {
      for ( sens_count = 0; 
            sens_count < opened_trace->corosion_sens_num; 
            sens_count++)
      {
          result_value =  index_file->index_seam[seam].inquiry[dim_count].sens[sens_count];
          result_value -= index_file->index_seam[seam].inquiry[dim_count+1].sens[sens_count];
          result_value += 23000;

          index_file->index_seam[seam].inquiry[dim_count].sens[sens_count] =
          result_value;

      }; // for  sens_count = 0; 

  }; // for dim_count = 0;

  dim_count = index_file->index_seam[seam].head_of_condition_seam->real_dim-1;
  for ( sens_count = 0; 
        sens_count < opened_trace->corosion_sens_num; 
        sens_count++)
  {
        index_file->index_seam[seam].inquiry[dim_count].sens[sens_count] =
        index_file->index_seam[seam].inquiry[dim_count-1].sens[sens_count];
  };


*/


           arc_data = (WORD *) heap_free(arc_data);

            // теперь их надо обработать


           // проиндексируем время
           // время первого измерения в усл. шве
           index_file->index_seam[seam_counter].beg_time =
               index_file->index_seam[seam_counter].inquiry[0].proc_tacts;
           index_file->index_seam[seam_counter].beg_time *= 32768;
           index_file->index_seam[seam_counter].beg_time /= 59659;
           index_file->index_seam[seam_counter].beg_time *= 100;
           index_file->index_seam[seam_counter].beg_time /=
                                        opened_trace->frequency_processor;
           
           // время последнего измерения в усл. шве
           index_file->index_seam[seam_counter].end_time =
               index_file->index_seam[seam_counter].inquiry[
                 index_file->index_seam[seam_counter].head_of_condition_seam->real_dim-1
                ].proc_tacts;
           index_file->index_seam[seam_counter].end_time *= 32768;
           index_file->index_seam[seam_counter].end_time /= 59659;
           index_file->index_seam[seam_counter].end_time *= 100;
           index_file->index_seam[seam_counter].end_time /=
                                        opened_trace->frequency_processor;
           // проиндексировали время


           // проиндексируем начальные значения сглаживания
//---------------------------------------------------------------------------------
           if (seam_counter == 0 && file_counter == 0) {
               for (sens_counter=0; sens_counter<opened_trace->corosion_sens_num; sens_counter++)
                {
                  index_file->index_seam[0].smooth_data_beg[0] = 
                      index_file->index_seam[0].inquiry[0].math_sens[sens_counter];
                };
            } else {
               for (sens_counter=0; sens_counter<opened_trace->corosion_sens_num; sens_counter++)
                {
                  index_file->index_seam[seam_counter].smooth_data_beg[sens_counter] = 
                      smooth_beg[sens_counter];
                };
            };
//------------------------------------------------------------------------------
           smooth_data_result = 
                   smooth_data (&index_file->index_seam[seam_counter],
                                opened_trace, 1);
//---------------------------------------------------------------------
           if (smooth_data_result  == NULL) 
            {
              strcat (drvError, "(calkulate_index_files_and_sems)");

              // освободим весь условный шов
              index_file->index_seam[seam_counter].inquiry =
                  free_inquiry(index_file->index_seam[seam_counter].inquiry);

              index_file->index_seam[seam_counter].head_of_condition_seam=
                       free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);

              index_file->index_seam[seam_counter].smooth_data_beg = 
                 free_smooth_data_beg(index_file->index_seam[seam_counter].smooth_data_beg);

              fclose(index_file->file_data);
              index_file->file_data =NULL;
              return KRT_ERR;
            };

           for (sens_counter=0; sens_counter<opened_trace->corosion_sens_num; sens_counter++)
            {
              // найдем в каком поясе датчик
              first_sens_in_cur_group = 0;
              for ( group_counter=0; 
				    group_counter<opened_trace->group_num;
                    first_sens_in_cur_group+=opened_trace->linesense_size[group_counter++]
                  ) 
               {
				if ( group_counter>=opened_trace->group_num)
				{
					group_counter = opened_trace->group_num-1;
					break;
				};
                if ((sens_counter >= first_sens_in_cur_group) &&
                    ((sens_counter - first_sens_in_cur_group) < opened_trace->linesense_size[group_counter])
                   ) 
                 {
                   break;
                 };
               };
              // нашли в каком поясе датчик

              smooth_beg[sens_counter] = smooth_data_result[sens_counter]
                                         / opened_trace->smooth_win_length[group_counter]
                                         / 256;
            };
           // проиндексировали начальные значения сглаживания
//-------------------------------------------------------------------

           // Посчитаем ориентацию если это необходимо c rec.mat
           if (opened_trace->Get_Orient_from_NAV!=0) {

              for (dimension_counter=0;
                   dimension_counter<index_file->index_seam[seam_counter].head_of_condition_seam->real_dim;
                   dimension_counter++) 
               {
                  my_start++;
                  index_file->index_seam[seam_counter].inquiry[dimension_counter].orient
                      =get_orient_from_NAV(my_start,
                                           &NavData,
                                           opened_trace->real_number_sensor_in_group[0]);

               };
            }; // if (opened_trace->Get_Orient_from_NAV!=0) {
           // посчитали ориентацию если это было необходимо c rec.mat

           // Посчитаем ориентацию если это необходимо c rec.vog
           if (opened_trace->Get_Orient_from_VOG!=0) {

              for (dimension_counter=0;
                   dimension_counter<index_file->index_seam[seam_counter].head_of_condition_seam->real_dim;
                   dimension_counter++) 
               {
                  my_start++;
                  index_file->index_seam[seam_counter].inquiry[dimension_counter].orient
                      =get_orient_from_VOG(my_start, // /2,
                                           &VogData,
                                           opened_trace->real_number_sensor_in_group[0]);

               };
            }; // if (opened_trace->Get_Orient_from_VOG!=0) {
           // посчитали ориентацию если это было необходимо c rec.vog

           // проиндексируем ориентацию
           if (seam_counter == 0 && file_counter == 0) {
              index_file->index_seam[seam_counter].smooth_orientation_beg = 
                  index_file->index_seam[seam_counter].inquiry[0].orient;
            } else {
              index_file->index_seam[seam_counter].smooth_orientation_beg = 
                              pred_cur_orient;
            };

           if ((cur_descriptor.ver_file==VER_FILE_EPRO)
               ||
               (cur_descriptor.ver_file==VER_FILE_EPRO_15))
            {

               if ((opened_trace->corosion_sens_num!=80) &&
                      (opened_trace->corosion_sens_num!=40) )
                {
                   smooth_orient_res=
                    smooth_orientation (&index_file->index_seam[seam_counter],
                                        opened_trace->orientation_mul_factor,
                                        opened_trace->real_number_sensor_in_group[0],
//                                        122);
                                        0x7F);
                } else {
                   smooth_orient_res=
                    smooth_orientation (&index_file->index_seam[seam_counter],
                                        1.0,
                                        opened_trace->real_number_sensor_in_group[0],
                                        opened_trace->real_number_sensor_in_group[0]);
                };
            } else {
               // cur_descriptor.ver_file==VER_FILE_EPRO_2
               smooth_orient_res=
                smooth_orientation (&index_file->index_seam[seam_counter],
                                    1.0,
                                    opened_trace->real_number_sensor_in_group[0],
                                    opened_trace->real_number_sensor_in_group[0]);
            };

           if (smooth_orient_res == KRT_ERR) 
            {
              strcat (drvError, "(calkulate_index_files_and_sems)");

              // освободим весь условный шов
              index_file->index_seam[seam_counter].inquiry =
                  free_inquiry(index_file->index_seam[seam_counter].inquiry);

              index_file->index_seam[seam_counter].head_of_condition_seam = 
                      free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);
              fclose(index_file->file_data);
              index_file->file_data =NULL;
              return KRT_ERR;
            };
           // проиндексировали ориентацию

           // Запишем индексы дополнительных датчиков
           for (dimension_counter=0;
                dimension_counter<index_file->index_seam[seam_counter].head_of_condition_seam->real_dim;
                dimension_counter++) 
            {
               timer_ms = index_file->index_seam[seam_counter].inquiry[dimension_counter].proc_tacts;
               timer_ms *= 32768;
               timer_ms /= 59659;
               timer_ms *= 100;
               timer_ms /= opened_trace->frequency_processor;

               // отработаем сброс времени на ходу (перезапуск процессора)
/*               if (timer_ms < pred_timer_ms)
               {
                   shift_time_after_stop = pred_timer_ms + 200000;
               }
               timer_ms += shift_time_after_stop;
*/
               // учтем направление движения
               d_Pic_ful_track = index_file->index_seam[seam_counter].inquiry[dimension_counter].Pic_ful_track-pred_Pic_ful_track;
               d_odom_forward = pred_odom_forward-index_file->index_seam[seam_counter].inquiry[dimension_counter].odom_forward;

               if ( (d_Pic_ful_track == d_odom_forward) && (move_bakward_count>10) ) {
                   full_timer_ms -= timer_ms - pred_timer_ms;
                   move_forward_count=0;
                   move_bakward_count++;
               } else {
                   full_timer_ms += timer_ms - pred_timer_ms;
                   move_forward_count++;
                   move_bakward_count=0;
               };

               pred_timer_ms = timer_ms;

               opened_trace->index_extend_sens.extend_sens.time = (long) full_timer_ms;

               pred_Pic_ful_track = index_file->index_seam[seam_counter].inquiry[dimension_counter].Pic_ful_track;
               pred_odom_forward = index_file->index_seam[seam_counter].inquiry[dimension_counter].odom_forward;


               opened_trace->index_extend_sens.extend_sens.orient = 0;
//                        index_file->index_seam[seam_counter].inquiry[dimension_counter].orient;

               opened_trace->index_extend_sens.extend_sens.termo=
                        (long) (0.868 * index_file->index_seam[seam_counter].inquiry[dimension_counter].termo - 61);

//  время между прерываниями в микросекундах
//               if (timer_ms-pred_timer_ms==0) {
//                  opened_trace->index_extend_sens.extend_sens.Thick=pred_spead;
//                } else {
//                  opened_trace->index_extend_sens.extend_sens.Thick=timer_ms-pred_timer_ms;
//                  pred_spead=timer_ms-pred_timer_ms;
//                };
//               pred_timer_ms=timer_ms;

               opened_trace->index_extend_sens.extend_sens.Thick=
                        index_file->index_seam[seam_counter].inquiry[dimension_counter].Thick;

               if (fwrite(&opened_trace->index_extend_sens.extend_sens,
                          1, sizeof(T_RECORD_EXTEND_SENS),
                          ext_data
                         ) != sizeof(T_RECORD_EXTEND_SENS)
                  )
                {
                   sprintf(drvError, "Ошибка записи ext_index (calkulate_index_files_and_sems)");
                   fclose(ext_data);
                   arc_data = (WORD *) heap_free(arc_data);

                   fclose(index_file->file_data);
                   index_file->file_data =NULL;

                   index_file->index_seam[seam_counter].head_of_condition_seam =
                          free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);

                   return KRT_ERR;
                };

               // Запишем информацию о линиях питания, если она есть
               if (cur_descriptor.ver_file==VER_FILE_EPRO_3  ||
                   cur_descriptor.ver_file==VER_FILE_EPRO_31 ||
                   cur_descriptor.ver_file==VER_FILE_EPRO_32 ||
                   cur_descriptor.ver_file==VER_FILE_EPRO_15) 
                {
                   for (i=0; i<POWER_LINE_NUM; i++) {
                      opened_trace->index_power_lines.power_data.power_lines[i] =
                         index_file->index_seam[seam_counter].inquiry[dimension_counter].power_val[i];
                    };

                   opened_trace->index_power_lines.power_data.power_flags =
                       index_file->index_seam[seam_counter].inquiry[dimension_counter].power_flags;


                   if (fwrite(&opened_trace->index_power_lines.power_data,
                              1, sizeof(T_RECORD_POWER_DATA),
                              power_data
                             ) != sizeof(T_RECORD_POWER_DATA)
                      )
                    {
                       sprintf(drvError, "Ошибка записи ext_index (calkulate_index_files_and_sems)");
                       fclose(ext_data);
                       arc_data = (WORD *) heap_free(arc_data);

                       fclose(index_file->file_data);
                       index_file->file_data =NULL;

                       index_file->index_seam[seam_counter].head_of_condition_seam =
                              free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);

                       return KRT_ERR;
                    };

                };
               // Запишем информацию о линиях питания, если она есть

            }; //  for (dimension_counter=0; ...

           // Записали индексы дополнительных датчиков

           // Найдем максимальную и минимальную температуру
           for (dimension_counter=0;
                dimension_counter<index_file->index_seam[seam_counter].head_of_condition_seam->real_dim;
                dimension_counter++) 
            {
               cur_termo=(long) (0.868 * index_file->index_seam[seam_counter].inquiry[dimension_counter].termo - 61);
               if (opened_trace->MaxTermo<cur_termo) {
                   opened_trace->MaxTermo=cur_termo;
                };
               
               if (opened_trace->MinTermo>cur_termo) {
                   opened_trace->MinTermo=cur_termo;
                };
            };
           // Нашли максимальную и минимальную температуру


/*
space_for_trace->trace_info.speedMin=0;
space_for_trace->trace_info.speedMax=0;

*/

           // вроде обработали

           // освободим проиндексированный условный шов от данных
           index_file->index_seam[seam_counter].inquiry = 
              free_inquiry(index_file->index_seam[seam_counter].inquiry);
           if (index_file->index_seam[seam_counter].inquiry != NULL) {
              strcat (drvError, "(calkulate_index_files_and_sems)");
              arc_data = (WORD *) heap_free(arc_data);

              fclose(index_file->file_data);
              index_file->file_data =NULL;

              index_file->index_seam[seam_counter].head_of_condition_seam=
                     free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);

              return KRT_ERR;
            };

           index_file->index_seam[seam_counter].head_of_condition_seam = 
                   free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);
           // освободили проиндексированный условный шов от данных
           // при этом поле smooth_data_beg ни в коем случае не трогаем
           // т.к. это тоже индексы

           seam_counter++;
           break;
         }; //case (DESCRIPTOR_CONDITION_SEAM):

        case (DESCRIPTOR_START_PROGRAM ):
        case (DESCRIPTOR_OFF_UVD):
        case (DESCRIPTOR_ON_UVD): 
        case (DESCRIPTOR_BEGIN_STOP):
        case (DESCRIPTOR_END_STOP): {
           pos_in_file+=read_res;

           break;
         }; // case (DESCRIPTOR_END_STOP):

        default : {
           sprintf (drvError, "Неизвестный дескриптор(calkulate_index_files_and_sems)");
           fclose(index_file->file_data);
           index_file->file_data =NULL;
           return KRT_ERR;
         }; // default :
      }; // switch (cur_descriptor.descriptor_type)

    sum_read_res=0;
   }; // while(fread( &cur_descriptor, 1, DESCRIPTOR_LEN

  fclose(ext_data);

  if (VogData.file_data != NULL) {
	  fclose(VogData.file_data);
	  VogData.file_data = NULL;
   };

  if (NavData.file_data != NULL) {
	  fclose(NavData.file_data);
	  NavData.file_data = NULL;
   };


  if (power_data!=NULL) { 
     fclose(power_data);
     power_data=NULL;
   };

  if (seam_counter != index_file->num_condition_seam) {
     // получается недочитали посчитанные до это усл. швы
     sprintf (drvError, "Ошибка пересчета усл. швов(calkulate_index_files_and_sems)");
     fclose(index_file->file_data);
     index_file->file_data = NULL;
     return KRT_ERR;
   };
  //файл закончился, прочитали и проиндексировали

  // закроем файл данных
  fclose(index_file->file_data);
  index_file->file_data =NULL;

  return KRT_OK;
}; // long calkulate_index_files_and_sems


long load_seam_data(T_OPENED_TRACE *opened_trace, long file, long seam) {

  T_DESCRIPTOR cur_descriptor; // шаблон дескриптора

  word *arc_data;
  long i;

  if( fseek (opened_trace->file_index[file].file_data, 
              opened_trace->file_index[file].index_seam[seam].shift_in_file,
              SEEK_SET
             )
       !=  0)
   {
     sprintf (drvError, "не передвинулся указатель в файле(load_seam_data)");
     return KRT_ERR;
   };

  if (fread(&cur_descriptor, 1, sizeof(T_DESCRIPTOR), opened_trace->file_index[file].file_data) 
        !=  sizeof(T_DESCRIPTOR))
   {
     sprintf (drvError, "ошибка чтения дескриптора(load_seam_data)");
     return KRT_ERR;
   };

  if ( 
      (cur_descriptor.descriptor_type !=DESCRIPTOR_CONDITION_SEAM) ||
      (cur_descriptor.descriptor_Size!=sizeof(T_CONDITION_SEAM)+sizeof(T_DESCRIPTOR))
     )
   {
     sprintf (drvError, "Неизвестный формат файла (load_seam_data)");
     return KRT_ERR;
   }; //  if (cur_descriptor.ver_file != VER_FILE_EPRO) {

  opened_trace->file_index[file].index_seam[seam].head_of_condition_seam = 
         init_condition_seam();
  if (opened_trace->file_index[file].index_seam[seam].head_of_condition_seam==NULL) {
     strcat (drvError, "(load_seam_data)");
     return KRT_ERR;
   };

  if( (fread(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam,
             1, sizeof(T_CONDITION_SEAM), opened_trace->file_index[file].file_data) 
      ) != sizeof(T_CONDITION_SEAM))
   {
     sprintf (drvError, "ошибка чтения заголовка усл. шва(load_seam_data)");
     opened_trace->file_index[file].index_seam[seam].head_of_condition_seam =
       free_condition_seam(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam);
     return KRT_ERR;
   };

  arc_data=(word *) heap_alloc(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam->arc_size);

  if (arc_data==NULL) {
     sprintf (drvError, "Ошибка выделения памяти под архивные данные(load_seam_data)");
     opened_trace->file_index[file].index_seam[seam].head_of_condition_seam =
       free_condition_seam(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam);
     return KRT_ERR;
   };

  i=fread(arc_data, 1, 
           opened_trace->file_index[file].index_seam[seam].head_of_condition_seam->arc_size,
           opened_trace->file_index[file].file_data
		   );
   if (i != opened_trace->file_index[file].index_seam[seam].head_of_condition_seam->arc_size
    )
   {
     sprintf (drvError, "Ошибка чтения файла(load_seam_data)");
     opened_trace->file_index[file].index_seam[seam].head_of_condition_seam =
       free_condition_seam(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam);
     arc_data = (WORD *) heap_free(arc_data);
     return KRT_ERR;
   };

  // разархивируем данные
  if (unarc_lzw(arc_data, 
                opened_trace->file_index[file].index_seam[seam].head_of_condition_seam->arc_size/2, 
                &opened_trace->file_index[file].index_seam[seam],
                opened_trace->corosion_sens_num,
                cur_descriptor.ver_file, opened_trace->target_name,
                opened_trace->real_number_sensor_in_group[0],
                opened_trace
               )
       == KRT_ERR) 
   {
     strcat (drvError, "(load_seam_data)");
     arc_data = (WORD *) heap_free(arc_data);

     // освободим весь условный шов
     opened_trace->file_index[file].index_seam[seam].inquiry =
        free_inquiry(opened_trace->file_index[file].index_seam[seam].inquiry);
     opened_trace->file_index[file].index_seam[seam].head_of_condition_seam =
       free_condition_seam(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam);
     return KRT_ERR;
   };
   // разархивировали данные 
  arc_data = (WORD *) heap_free(arc_data);

/*
  // Сделаем диферинциальное вычитание между соседними измерениями
  for (dim_count = 0;
       dim_count < opened_trace->file_index[file].index_seam[seam].head_of_condition_seam->real_dim-1;
       dim_count++)
  {
      for ( sens_count = 0; 
            sens_count < opened_trace->corosion_sens_num; 
            sens_count++)
      {
          result_value =  opened_trace->file_index[file].index_seam[seam].inquiry[dim_count].sens[sens_count];
          result_value -= opened_trace->file_index[file].index_seam[seam].inquiry[dim_count+1].sens[sens_count];
          result_value += 23000;

          opened_trace->file_index[file].index_seam[seam].inquiry[dim_count].sens[sens_count] =
          result_value;

      }; // for  sens_count = 0; 

  }; // for dim_count = 0;

  dim_count = opened_trace->file_index[file].index_seam[seam].head_of_condition_seam->real_dim-1;
  for ( sens_count = 0; 
        sens_count < opened_trace->corosion_sens_num; 
        sens_count++)
  {
        opened_trace->file_index[file].index_seam[seam].inquiry[dim_count].sens[sens_count] =
        opened_trace->file_index[file].index_seam[seam].inquiry[dim_count-1].sens[sens_count];
  };

*/
    if (opened_trace->Median_Filter_length > 0)
    {
        Use_median_data(&opened_trace->file_index[file].index_seam[seam], opened_trace, 0);
    } else {
        smooth_data (&opened_trace->file_index[file].index_seam[seam], opened_trace, 0);
    }

  return KRT_OK;
 }; // long load_seam_data(T_OPENED_TRACE *opened_trace, long file, long seam) {


long get_data(T_OPENED_TRACE *opened_trace, long start, long length) {

  T_LOADED_DATA * loaded_data;
  T_LOADED_DATA * cur_item;
  T_LOADED_DATA * pred_item;
  
  T_LOADED_DATA * trace_item;
  T_LOADED_DATA * pred_trace_item;

  long file_counter;
  long seam_counter;
  long serch_file_counter;

  long seam_loaded_res;
  long bonus_seam_counter;
  long close_file_res;

  long i;

   // луче освободим лишние усл. швы, чтобы не занимать память
  cur_item = opened_trace->list_loaded_data;
  while (cur_item!=NULL) {
     // освободим весь условный шов
     opened_trace->file_index[cur_item->file].index_seam[cur_item->seam].inquiry =
        free_inquiry(opened_trace->file_index[cur_item->file].index_seam[cur_item->seam].inquiry);
     opened_trace->file_index[cur_item->file].index_seam[cur_item->seam].head_of_condition_seam =
        free_condition_seam(opened_trace->file_index[cur_item->file].index_seam[cur_item->seam].head_of_condition_seam);

     cur_item=cur_item->Next_element;
   };

  cur_item = free_list_loaded_data (opened_trace->list_loaded_data);
  opened_trace->list_loaded_data = NULL;
   // освободили лишние усл. швы, чтобы не занимать память


  length+=1000; // загрузим-ко лучше лишний условный шов если мы близко к его границе

  // поправим length на продольные смещения датчиков
  length+=opened_trace->max_sens_shift;
  if (start+length<opened_trace->file_index[0].beg_track) {
     length = 0;
   };
  if (start+length>opened_trace->file_index[opened_trace->num_file_data-1].end_track) {
     length=opened_trace->file_index[opened_trace->num_file_data-1].end_track-start;
   };
  // поправили length на продольные смещения датчиков

  // составим список требуемых для загрузки данных пока только с учетом расстояний

  // найдем файл в котором начало запрошенной области
  for (file_counter=0; file_counter<opened_trace->num_file_data; file_counter++) {
     if ( (start >= opened_trace->file_index[file_counter].beg_track) &&
          (start <= opened_trace->file_index[file_counter].end_track)
        ) break;
   }; // for (file_counter

  if (file_counter >= opened_trace->num_file_data) {
      // значит не попадает начало, ни в один файл
     sprintf (drvError, "Начало участка почему-то не попал в трассу(get_data)");
     return KRT_ERR;
   };
  // нашли файл в котором начало запрошенной области

  // Убедимся что файл открыт, ежели что откроем закрыв другой
  if (opened_trace->file_index[file_counter].file_data==NULL) {
      // Закроем сначала другой файл
      close_file_res=0;
      if (file_counter != opened_trace->num_file_data-1) {
         for (serch_file_counter=file_counter+1; serch_file_counter<opened_trace->num_file_data;serch_file_counter++) {
            if (opened_trace->file_index[serch_file_counter].file_data!=NULL) {
               fclose(opened_trace->file_index[serch_file_counter].file_data);
               opened_trace->file_index[serch_file_counter].file_data=NULL;
               close_file_res=1;
               break;
             };
          };
       };

      if (close_file_res==0) {
         for (serch_file_counter=0; serch_file_counter<opened_trace->num_file_data;serch_file_counter++) {
            if (opened_trace->file_index[serch_file_counter].file_data!=NULL) {
               fclose(opened_trace->file_index[serch_file_counter].file_data);
               opened_trace->file_index[serch_file_counter].file_data=NULL;
               break;
             };
          };
       };

      // теперь откроем нужный
     opened_trace->file_index[file_counter].file_data = 
            fopen(opened_trace->file_index[file_counter].file_name, "rb");
     if (opened_trace->file_index[file_counter].file_data ==NULL) {
       sprintf (drvError, "Ошибка открытия файла %s(get_data)",
                opened_trace->file_index[file_counter].file_name
               );
       opened_trace = free_opened_trace(opened_trace);
       return KRT_ERR;
      };
   };


  // найдем усл.шов в котором начало запрошенной области
  for (seam_counter=0;
       seam_counter<opened_trace->file_index[file_counter].num_condition_seam;
       seam_counter++
      ) 
   {
     if ( (start >= opened_trace->file_index[file_counter].index_seam[seam_counter].beg_track) &&
          (start <= opened_trace->file_index[file_counter].index_seam[seam_counter].end_track)
        ) break;
   };

   if (seam_counter >= opened_trace->file_index[file_counter].num_condition_seam) {
      // значит не попадает начало, ни в один файл
     sprintf (drvError, "Начало участка почему-то не попал в файл(get_data)");
     return KRT_ERR;
   };
  // нашли номер файла и условного шва для первого запрошенного участка

  loaded_data=init_loaded_data();
  cur_item=loaded_data;
  pred_item = NULL;

  cur_item->file = file_counter;
  cur_item->seam = seam_counter;

  length -= (opened_trace->file_index[file_counter].index_seam[seam_counter].end_track - 
             opened_trace->file_index[file_counter].index_seam[seam_counter].beg_track + 1);

  // переберем следующие условные швы, если они нужны
  while (length > 0) {
     seam_counter++;
     if (seam_counter >= opened_trace->file_index[file_counter].num_condition_seam) {
        // в текущем файле условные швы закончились ...
        seam_counter = 0;

        file_counter++;
        if (file_counter >= opened_trace->num_file_data) {
            // значит не попадает начало, ни в один файл
           sprintf (drvError, "Конец участка почему-то не попал в трассу(get_data)");
           return KRT_ERR;
         };
        // Убедимся что файл открыт, ежели что откроем закрыв другой
        if (opened_trace->file_index[file_counter].file_data==NULL) {
            // Закроем сначала другой файл
            close_file_res=0;
            if (file_counter != opened_trace->num_file_data-1) {
               for (serch_file_counter=file_counter+1; serch_file_counter<opened_trace->num_file_data;serch_file_counter++) {
                  if (opened_trace->file_index[serch_file_counter].file_data!=NULL) {
                     fclose(opened_trace->file_index[serch_file_counter].file_data);
                     opened_trace->file_index[serch_file_counter].file_data=NULL;
                     close_file_res=1;
                     break;
                   };
                };
             };

            if (close_file_res==0) {
               for (serch_file_counter=0; serch_file_counter<loaded_data->file;serch_file_counter++) {
                  if (opened_trace->file_index[serch_file_counter].file_data!=NULL) {
                     fclose(opened_trace->file_index[serch_file_counter].file_data);
                     opened_trace->file_index[serch_file_counter].file_data=NULL;
                     break;
                   };
                };
             };

            // теперь откроем нужный
           opened_trace->file_index[file_counter].file_data = 
                  fopen(opened_trace->file_index[file_counter].file_name, "rb");
           if (opened_trace->file_index[file_counter].file_data ==NULL) {
             sprintf (drvError, "Ошибка открытия файла %s(get_data)",
                      opened_trace->file_index[file_counter].file_name
                     );
             opened_trace = free_opened_trace(opened_trace);
             return KRT_ERR;
            };
         };
      }; // if (seam_counter >= opened_trace->file_index[file_counter].num_condition_seam) {

     // добавим следующий условный шов
     pred_item = cur_item;
     cur_item = init_loaded_data();
     pred_item->Next_element = cur_item;

     cur_item->file = file_counter;
     cur_item->seam = seam_counter;

     length -= (opened_trace->file_index[file_counter].index_seam[seam_counter].end_track - 
                opened_trace->file_index[file_counter].index_seam[seam_counter].beg_track + 1);
   }; //   while (length > 0) {
  // составили список требуемых для загрузки данных пока только с учетом расстояний

  // проверим есть ли уже загруженные данные, а если нет, то загрузим
  cur_item = loaded_data;
  pred_item = NULL;

  while (cur_item != NULL) {
     seam_loaded_res = KRT_ERR;

     trace_item = opened_trace->list_loaded_data;
     pred_trace_item = NULL;

     while (trace_item != NULL) {
        if ( (cur_item->file == trace_item->file) &&
             (cur_item->seam == trace_item->seam) )
         {   // нашли загруженный усл. шов
            seam_loaded_res = KRT_OK;

            // надо теперь этот усл. шов вычеркнуть из трассового списка
            if (pred_trace_item == NULL) {
               opened_trace->list_loaded_data = trace_item->Next_element;
               trace_item=free_loaded_data(trace_item);
               if (trace_item!=NULL) {
                  strcat (drvError, "(get_data)");
                  return KRT_ERR;
                };
               trace_item = opened_trace->list_loaded_data;
             } else {
               pred_trace_item->Next_element = trace_item->Next_element;
               trace_item=free_loaded_data(trace_item);
               if (trace_item!=NULL) {
                  strcat (drvError, "(get_data)");
                  return KRT_ERR;
                };
               trace_item = pred_trace_item->Next_element;
             };
            break;
         };

        pred_trace_item = trace_item;
        trace_item = trace_item->Next_element;
      }; // while (trace_item != NULL) {

     if (seam_loaded_res == KRT_ERR ) {
         // не нашли загруженный усл. шов, надо загрузить
        if (load_seam_data(opened_trace, cur_item->file, cur_item->seam) == KRT_ERR) {
           strcat (drvError, "(get_data)");

           return KRT_ERR;

         };
      };

     pred_item = cur_item;
     cur_item = cur_item->Next_element;
   }; // while (cur_item != NULL) {
  // проверили есть ли уже загруженные данные, и загрузили недостающие


  opened_trace->list_loaded_data = loaded_data;

  return KRT_OK;
}; // T_LOADED_DATA * get_data(long beg_length, long end_length)
