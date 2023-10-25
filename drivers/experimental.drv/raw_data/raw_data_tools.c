
#ifndef krotnano_512_c
#define krotnano_512_c

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <process.h>


#include <krtapi.h>

#include "tracetool.h"

#include "tracetool.c"


// ZSTD
//#include "ZSTD/fse.h"        
//#include "ZSTD/fse_static.h" 
//#include "ZSTD/zstd_static.h"
//#include "ZSTD/fse.c"        

//#include "ZSTD/zstd.h"
//#include "ZSTD/zstd.c"


#define Num_parallel_thread 16
HANDLE hThread_1 [Num_parallel_thread];
unsigned thread_1_ID [Num_parallel_thread];


typedef struct {
   T_OPENED_TRACE *P_trace;
   long block_idx;
} T_UARC_THREAD_ARG;

void get_block_data(T_OPENED_TRACE *opened_trace, long cur_idx)
{

   long cur_file_idx;

   FILE * data_file;
   char file_name[1024];

   _record_data * data_block;

   long record_data_pos;
   char * record_data;

   long test_counter;
   long sens_counter;
   long group_counter;
   long all_sens_data_pos;

   long tmp_recalkulate_value;


      cur_file_idx = opened_trace->idx_trc[cur_idx].file_num;

      sprintf(file_name, "%sraw%05ld.dat", opened_trace->path_data, cur_file_idx);
      data_file = fopen(file_name, "rb");
      fseek(data_file, opened_trace->idx_trc[cur_idx].shift_in_file, SEEK_SET);

      // разархивируем данные
      record_data = malloc(opened_trace->idx_head.full_record_size * RECORDS_IN_BLOCK);
      fread(record_data, opened_trace->idx_trc[cur_idx].num_test_in_block, opened_trace->idx_head.full_record_size, data_file);
      // разархивировали данные

      data_block = malloc( sizeof(data_block[0]) * opened_trace->idx_trc[cur_idx].num_test_in_block);

      record_data_pos = 0;
      for ( test_counter = 0;
            test_counter < opened_trace->idx_trc[cur_idx].num_test_in_block;
            test_counter ++)
      {
         memcpy( &(data_block[test_counter].odom_counter),
                 &(record_data[record_data_pos]),
                 opened_trace->idx_head.odometer_define.size);
         record_data_pos += opened_trace->idx_head.odometer_define.size;

         memcpy( &(data_block[test_counter].time),
                 &(record_data[record_data_pos]),
                 opened_trace->idx_head.timer_define.size);
         record_data_pos += opened_trace->idx_head.timer_define.size;

         // дополнительные датчики если есть
         for ( sens_counter = 0;
               sens_counter < opened_trace->idx_head.num_add_sens;
               sens_counter ++)
         {
             data_block[test_counter].add_sensors[sens_counter] = 0;
             memcpy( &(data_block[test_counter].add_sensors[sens_counter]),
                     &(record_data[record_data_pos]),
                     opened_trace->idx_head.others_sens_define[sens_counter].size);
             record_data_pos += opened_trace->idx_head.others_sens_define[sens_counter].size;
         } // for( sens_counter = 0;

         // основные датчики
         all_sens_data_pos = 0;
         for ( group_counter = 0;
               group_counter < opened_trace->idx_head.num_magn_sens_group;
               group_counter ++)
         {
             for ( sens_counter = 0;
                   sens_counter < opened_trace->idx_head.senslines_define[group_counter].sens_num;
                   sens_counter ++)
             {
                // берем только самый старший байт автоматичестки отсекая младшие биты т.к. палитра все равно 200 градаций
                memcpy( &(data_block[test_counter].all_sens_data[all_sens_data_pos]),
                        &(record_data[record_data_pos]),
                        sizeof(unsigned char) );

                { // смасштабируем данные в 200 градаций нашей палитры
                    tmp_recalkulate_value = data_block[test_counter].all_sens_data[all_sens_data_pos];

                    if (opened_trace->idx_head.senslines_define[group_counter].int_type == 1)
                    {
                       tmp_recalkulate_value = (char) data_block[test_counter].all_sens_data[all_sens_data_pos];

//                       if ( tmp_recalkulate_value >= 127) tmp_recalkulate_value = 0;

                       tmp_recalkulate_value += 128;
                    }

//   {
//      char tmp_str[1024];
//
//      sprintf(tmp_str,"all_sens_data_pos = %ld data = %d tmp_recalkulate_value = %ld\n",
//                       all_sens_data_pos,
//                       data_block[test_counter].all_sens_data[all_sens_data_pos],
//                       tmp_recalkulate_value);
//
//      MessageBox(NULL, tmp_str, "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//   }


                    tmp_recalkulate_value = tmp_recalkulate_value * 199 / 256;
                    data_block[test_counter].all_sens_data[all_sens_data_pos] = (unsigned char) tmp_recalkulate_value;
                }

                all_sens_data_pos += sizeof(unsigned char);
                record_data_pos += opened_trace->idx_head.senslines_define[group_counter].size;

             } // for( sens_counter = 0;
         } // for( group_counter = 0;

      } // for ( test_counter = 0;

      free(record_data);

      fclose(data_file);

      if (opened_trace->idx_trc[cur_idx].num_test_in_block == opened_trace->idx_trc[cur_idx].real_len)
      {
          opened_trace->idx_trc[cur_idx].records = data_block;
      } else { // отработаем переменный шаг одометра и пропуски

          long d_trace_mm;
          long pred_odometer_value;

          _record_data * shift_data_block;
 
          long num_record_for_copy;
          long i;
          long shift_block_pos;
          long overflow_value = 0;

          shift_data_block = malloc( sizeof(shift_data_block[0]) * opened_trace->idx_trc[cur_idx].real_len);

          pred_odometer_value = opened_trace->idx_trc[cur_idx].pred_odometer_value;

          shift_block_pos = 0;
          for ( test_counter = 0;
                test_counter < opened_trace->idx_trc[cur_idx].num_test_in_block;
                test_counter ++)
          {
              d_trace_mm = data_block[test_counter].odom_counter - pred_odometer_value;
              pred_odometer_value = data_block[test_counter].odom_counter;

              if (d_trace_mm <= 0) d_trace_mm = opened_trace->trace_step;

              num_record_for_copy = 1;

              if ( d_trace_mm != opened_trace->trace_step)
              {
                   if ( d_trace_mm < opened_trace->trace_step)
                   {
                       overflow_value += (opened_trace->trace_step - d_trace_mm);

                       if (overflow_value >= opened_trace->trace_step)
                       {
                          overflow_value -= opened_trace->trace_step;
                          num_record_for_copy = 0;
                       }
                   } else {
                       num_record_for_copy = d_trace_mm / opened_trace->trace_step;
                       overflow_value += d_trace_mm % opened_trace->trace_step;
                   }
              } else {
                  overflow_value = 0;
              }

              for (i = 0; i < num_record_for_copy; i++)
              {
                  if (shift_block_pos >= opened_trace->idx_trc[cur_idx].real_len)
                  {
                      shift_block_pos = opened_trace->idx_trc[cur_idx].real_len - 1;
                  }
                  memcpy( &(shift_data_block[shift_block_pos]), &(data_block[test_counter]), sizeof(data_block[0]));
                  shift_block_pos ++;

              }
          } // for ( test_counter = 0;

          free(data_block);

          opened_trace->idx_trc[cur_idx].records = shift_data_block;

      } // отработали переменный шаг одометра и пропуски

} // void get_block_data(T_OPENED_TRACE *opened_trace, long cur_idx)


unsigned __stdcall Thread_NANO_512_uarc( void* pArguments )
{

    T_UARC_THREAD_ARG * uarc_thread_arg = pArguments;

    get_block_data( uarc_thread_arg->P_trace, uarc_thread_arg->block_idx);

    _endthreadex(0);
    return 0;

} // unsigned __stdcall Thread_NANO512_uarc( void* pArguments )


long get_data(T_OPENED_TRACE *opened_trace, long start, long length) {
  
  long cur_idx, first_idx, last_idx;

  first_idx = opened_trace->idx_head.num_idx_in_table;

  // Ищем где данные 
  for (cur_idx = 0; cur_idx < opened_trace->idx_head.num_idx_in_table; cur_idx++)
  {
       // попутно освобождаем память
       if ( opened_trace->idx_trc[cur_idx].records != NULL)
       {
           free(opened_trace->idx_trc[cur_idx].records);
           opened_trace->idx_trc[cur_idx].records = NULL;
       }

       if ( start <= opened_trace->idx_trc[cur_idx].beg_trace + opened_trace->idx_trc[cur_idx].real_len)
       {
           first_idx = cur_idx;
           break;
       }
  };

  if (first_idx == opened_trace->idx_head.num_idx_in_table)
  {
      return KRT_OK;
  };

  // вычислим скока блоков нам надо
  cur_idx = first_idx;
  do
  {
       if ( opened_trace->idx_trc[cur_idx].records != NULL)
       {
           free(opened_trace->idx_trc[cur_idx].records);
           opened_trace->idx_trc[cur_idx].records = NULL;
       }

       if ( (cur_idx+1) >= opened_trace->idx_head.num_idx_in_table ) break;
  }
  while( (start + length + 200) >  
         (opened_trace->idx_trc[cur_idx].beg_trace + opened_trace->idx_trc[cur_idx++].real_len)
       );

  last_idx = cur_idx;
  if (last_idx >= opened_trace->idx_head.num_idx_in_table)
  {
      last_idx = opened_trace->idx_head.num_idx_in_table-1;
  }
  // вычислили скока блоков нам надо

  // доосвобождаем память
  for (cur_idx = last_idx+1; cur_idx < opened_trace->idx_head.num_idx_in_table; cur_idx++)
  {
       if ( opened_trace->idx_trc[cur_idx].records != NULL)
       {
           free(opened_trace->idx_trc[cur_idx].records);
           opened_trace->idx_trc[cur_idx].records = NULL;
       }
  };

  // вычислим какие файлы нам надо и загрузим их
//  first_file = opened_trace->idx_trc[first_idx].file_num;
//  cur_idx = last_idx;
//  if (last_idx < opened_trace->idx_head.num_idx_in_table-1) cur_idx++;
//  last_file = opened_trace->idx_trc[cur_idx].file_num;

  // вариант с последовательным получением данных
  for ( cur_idx = first_idx; cur_idx <=last_idx; cur_idx++)
  {
      get_block_data(opened_trace, cur_idx);
  };
  // конец варианта с последовательным получением данных

  return KRT_OK;
}; // long get_data(T_OPENED_TRACE *opened_trace, long start, long length)


#endif
