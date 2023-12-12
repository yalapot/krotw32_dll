// krotepro.c - драйвер epro_drv.
// Объявление глобальных данных и тела инструментальных функций драйвера
// просмотра данных електронного блока "epro" программой KrotW32
//

#ifndef krotnano_512_c
#define krotnano_512_c

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <process.h>


#include <krtapi.h>
#include <krotnano_512.h>

#include "tracetool.c"


// ZSTD
//#include "ZSTD/fse.h"        
//#include "ZSTD/fse_static.h" 
//#include "ZSTD/zstd_static.h"
//#include "ZSTD/fse.c"        

//#include "ZSTD/zstd.h"
//#include "ZSTD/zstd.c"


#define MAX_ORIENTATION_FILTER_LENGTH 200

long Orientation_x_smooth(long new_value)
{
    static long src_data_bufer [MAX_ORIENTATION_FILTER_LENGTH];

    static long cur_src_data_buf_len = 0;

    static long cur_pos_src_data_buf = 0;

    long pos_data_buf;

    long Sum_value;

    long result;

/*
  long current_or=0;

  long low_tube_cur_orient = max_sens_num/4;
  long up_tube_cur_orient  = max_sens_num-max_sens_num/4;
  long low_tube_src_orient = max_orient_value/4;
  long up_tube_src_orient  = max_orient_value-max_orient_value/4;

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
*/


    // добавим новое значение в буфер исходных данных
    src_data_bufer [cur_pos_src_data_buf] = new_value;

    cur_src_data_buf_len++;
    if (cur_src_data_buf_len >= MAX_ORIENTATION_FILTER_LENGTH) cur_src_data_buf_len = MAX_ORIENTATION_FILTER_LENGTH;

    cur_pos_src_data_buf++;
    if (cur_pos_src_data_buf >= MAX_ORIENTATION_FILTER_LENGTH) cur_pos_src_data_buf=0;
    // добавили новое значение в буфер исходных данных

    Sum_value = 0;
    for (pos_data_buf=0; pos_data_buf < cur_src_data_buf_len; pos_data_buf++)
    {
       Sum_value += src_data_bufer [pos_data_buf];
    }

    result = Sum_value / cur_src_data_buf_len;

    return result;

}; // long Orientation_smooth

long Orientation_y_smooth(long new_value)
{
    static long src_data_bufer [MAX_ORIENTATION_FILTER_LENGTH];

    static long cur_src_data_buf_len = 0;

    static long cur_pos_src_data_buf = 0;

    long pos_data_buf;

    long Sum_value;

    long result;

    // добавим новое значение в буфер исходных данных
    src_data_bufer [cur_pos_src_data_buf] = new_value;

    cur_src_data_buf_len++;
    if (cur_src_data_buf_len >= MAX_ORIENTATION_FILTER_LENGTH) cur_src_data_buf_len = MAX_ORIENTATION_FILTER_LENGTH;

    cur_pos_src_data_buf++;
    if (cur_pos_src_data_buf >= MAX_ORIENTATION_FILTER_LENGTH) cur_pos_src_data_buf=0;
    // добавили новое значение в буфер исходных данных

    Sum_value = 0;
    for (pos_data_buf=0; pos_data_buf < cur_src_data_buf_len; pos_data_buf++)
    {
       Sum_value += src_data_bufer [pos_data_buf];
    }

    result = Sum_value / cur_src_data_buf_len;

    return result;

}; // long Orientation_smooth


long  smooth_data ( T_OPENED_TRACE *P_trace, long cur_idx)
{
 
  long if_RV_dimension_counter, dimension_counter, sens_counter;

  long translate_res;

  static long average_sens[MAX_CORROZION_NUM];
  static long av_sens_old[MAX_CORROZION_NUM][MAX_SMOOTH_WIN_LENGTH];
  static long av_sens_len[MAX_CORROZION_NUM];

  long group = 0;


  for (if_RV_dimension_counter = 0;
       if_RV_dimension_counter < P_trace->idx_trc[cur_idx].real_len;
       if_RV_dimension_counter++) 
   {
         //
         if ( P_trace->ReversView ^ P_trace->Revers_MATH ) {
             dimension_counter = (P_trace->idx_trc[cur_idx].real_len-1)
                                  - if_RV_dimension_counter;
         } else {
             dimension_counter = if_RV_dimension_counter;
         }

         for (sens_counter = 0;
              sens_counter < P_trace->idx_head.num_sens;
              sens_counter++) 
         {
             av_sens_len[sens_counter]--;
             if ( (av_sens_len[sens_counter]<0) || (av_sens_len[sens_counter] >= P_trace->smooth_win_length[group]) )
             {
                 av_sens_len[sens_counter] = P_trace->smooth_win_length[group]-1;
             }

             if ( sens_counter < FIRST_SENSLINE_SIZE )
             {
                 group = 0;
             } else {
                 group = 1;
             };

             translate_res = P_trace->idx_trc[cur_idx].records[dimension_counter].magn_sensors_data[sens_counter];
             translate_res *= 256;
             average_sens[sens_counter] -= av_sens_old[sens_counter][av_sens_len[sens_counter]];

             average_sens[sens_counter] += translate_res;
             av_sens_old[sens_counter][av_sens_len[sens_counter]] = average_sens[sens_counter];

             av_sens_old[sens_counter][av_sens_len[sens_counter]]  /= P_trace->smooth_win_length[group];
             average_sens[sens_counter] -= translate_res;
             average_sens[sens_counter] += av_sens_old[sens_counter][av_sens_len[sens_counter]];

             translate_res -= av_sens_old[sens_counter][av_sens_len[sens_counter]];

             translate_res*=P_trace->Amplification_Group[group];

             translate_res /= 256;

             translate_res += P_trace->max_data_code/2;

             if (translate_res > P_trace->max_data_code) {
                 translate_res = P_trace->max_data_code;
             } else {
                 if (translate_res<0) translate_res=0;
             };

             if (P_trace->Smooth_data_OFF==0) {
                 if ( P_trace->ReversView ^ P_trace->Revers_MATH )
                 {
                    P_trace->idx_trc[cur_idx].math_records[dimension_counter].magn_sensors_data[sens_counter] =
                             (u16) translate_res;
                 } else {
                    P_trace->idx_trc[cur_idx].revers_math_records[dimension_counter].magn_sensors_data[sens_counter] =
                             (u16) translate_res;
                 };
              } else {
                 P_trace->idx_trc[cur_idx].math_records[dimension_counter].magn_sensors_data[sens_counter] =
                          P_trace->idx_trc[cur_idx].records[dimension_counter].magn_sensors_data[sens_counter];
              };

         }; // for (sens_counter=)

   }; //  for (if_RV_dimension_counter = 0;

  return KRT_OK;
}; // long * smooth_data (T_INDEX_SEAM *p_seam,


#define MAX_MEDIAN_FILTER_LENGTH 500
#define MAX_DATA_MEDIAN 4096


long median_filter(long cur_idx, long add_seam_test_num, T_OPENED_TRACE *P_trace)
{
    static long src_data_bufer [MAX_MEDIAN_FILTER_LENGTH] [MAX_CORROZION_NUM];
    static long cur_src_data_buf_len = 0;
    static long cur_pos_src_data_buf = 0;
    static long av_sens_median [MAX_CORROZION_NUM][MAX_DATA_MEDIAN];

    long pos_data_buf;

    long sens_num;

    int value_counter;

    static long max_gistogr_val[MAX_CORROZION_NUM];
    static long average_sens[MAX_CORROZION_NUM];
    static long average_sens_pred[MAX_CORROZION_NUM];
    static long first_flag = 0;

    long result;

    long group = 0;

    if (first_flag == 0) 
    {
        for (sens_num = 0; sens_num < P_trace->corosion_sens_num; sens_num ++)
        {
            for (value_counter = 0;
                 value_counter < MAX_DATA_MEDIAN;
                 value_counter++) 
            {
                av_sens_median [sens_num][value_counter] = 0;
            };
        };
        first_flag = 1;
    };

    if (P_trace->Median_Filter_length > MAX_MEDIAN_FILTER_LENGTH)
    {
        P_trace->Median_Filter_length = MAX_MEDIAN_FILTER_LENGTH;
    };

    if (P_trace->Median_Filter_length < 2)
    {
        P_trace->Median_Filter_length = 2;
    };

    if (cur_src_data_buf_len >= P_trace->Median_Filter_length)
    {
        // вычеркнем устаревшее значение из таблица гистограм
        for (sens_num = 0; sens_num < P_trace->corosion_sens_num; sens_num ++)
        {
            value_counter = src_data_bufer [cur_pos_src_data_buf] [sens_num];

            av_sens_median [sens_num] [ value_counter ] --;
        };
        cur_src_data_buf_len--;
        // вычеркнули устаревшее значение из таблица гистограм
    };

    // добавим новое значение в буфер исходных данных и таблицу гистограмм
    for (sens_num = 0; sens_num < P_trace->corosion_sens_num; sens_num ++)
    {
        src_data_bufer [cur_pos_src_data_buf] [sens_num] = 
           P_trace->idx_trc[cur_idx].records[add_seam_test_num].magn_sensors_data[sens_num];

        value_counter = src_data_bufer [cur_pos_src_data_buf] [sens_num];

        av_sens_median [sens_num] [ value_counter ] ++;
    };
    cur_src_data_buf_len++;
    // добавили новое значение в буфер исходных данных и таблицу гистограм

    // ищем максимумы гистограмы датчика
    for (sens_num = 0; sens_num < P_trace->corosion_sens_num; sens_num ++)
    {
        max_gistogr_val[sens_num] = 0;
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

    for (sens_num = 0; sens_num < P_trace->corosion_sens_num; sens_num ++)
    {
       average_sens_pred[sens_num] = average_sens[sens_num];
    };

    pos_data_buf = cur_pos_src_data_buf - P_trace->Median_Filter_length/2;
    if (pos_data_buf < 0) pos_data_buf = P_trace->Median_Filter_length + pos_data_buf;

    cur_pos_src_data_buf++;
    if (cur_pos_src_data_buf >= P_trace->Median_Filter_length) cur_pos_src_data_buf=0;

	 // собственно усредненние занчений
    for (sens_num = 0; sens_num < P_trace->corosion_sens_num; sens_num ++) 
    {
        if ( sens_num < FIRST_SENSLINE_SIZE )  group = 0; else group = 1;

        result =  src_data_bufer[ pos_data_buf ][sens_num] - average_sens_pred[sens_num];
        result *= P_trace->Amplification_Group[group];
        result += (P_trace->max_data_code / 2);

        if (result >= P_trace->max_data_code) result = P_trace->max_data_code - 2;
        if (result < 0 ) result = 0;

        P_trace->idx_trc[cur_idx].math_records[add_seam_test_num].magn_sensors_data[sens_num]
            = (WORD) result;

    }; // for sens_counter

   return 0;

}; // long median_filter

long Use_median_data (  long cur_idx,
                        T_OPENED_TRACE *P_trace
                     ) 
 {
 
  int dimension_counter;
  int nuber_dimension_in_seam;

  nuber_dimension_in_seam = P_trace->idx_trc[cur_idx].real_len;


  for (dimension_counter = 0; dimension_counter < nuber_dimension_in_seam; dimension_counter++) 
  {
     median_filter( cur_idx, dimension_counter, P_trace);
  }; // for (dimension_counter=0;

  return KRT_OK;
}; // long Use_median_data (

#define POLIGON_FILTER_LENGTH 30

long poligon_filter(long cur_idx, long add_seam_test_num, T_OPENED_TRACE *P_trace)
{
    static long src_data_bufer [POLIGON_FILTER_LENGTH] [MAX_CORROZION_NUM];
    static long cur_src_data_buf_len = 0;
    static long cur_pos_src_data_buf = 0;

    long pos_in_buf_for_average;

    long sens_num;

    int bufer_shift_counter;

    long average_value;
    static long average_sum = 0;
    static long first_flag = 0;

    long result;

    long group = 0;

    if (first_flag == 0) 
    {
        for (sens_num = 0; sens_num < P_trace->corosion_sens_num; sens_num ++)
        {
            for (bufer_shift_counter = 0;
                 bufer_shift_counter < POLIGON_FILTER_LENGTH;
                 bufer_shift_counter++) 
            {
                src_data_bufer [bufer_shift_counter] [sens_num] = 0;
            };
        };
        first_flag = 1;
    };

    if (cur_src_data_buf_len >= POLIGON_FILTER_LENGTH)
    {
        // вычеркнем устаревшее значение из буфера исходных данных
        cur_src_data_buf_len--;
        // вычеркнули устаревшее значение из буфера исходных данных
        for (sens_num = 0; sens_num < P_trace->corosion_sens_num; sens_num ++)
        {
            average_sum -= src_data_bufer [cur_pos_src_data_buf] [sens_num];
        };
    };

    // добавим новое значение в буфер исходных данных
    for (sens_num = 0; sens_num < P_trace->corosion_sens_num; sens_num ++)
    {
        src_data_bufer [cur_pos_src_data_buf] [sens_num] = 
           P_trace->idx_trc[cur_idx].records[add_seam_test_num].magn_sensors_data[sens_num];
        average_sum += src_data_bufer [cur_pos_src_data_buf] [sens_num];
    };
    cur_src_data_buf_len++;
    // добавили новое значение в буфер исходных данных

    average_value = average_sum / (POLIGON_FILTER_LENGTH * P_trace->corosion_sens_num);

    // собственно усредненние занчений
    for (sens_num = 0; sens_num < P_trace->corosion_sens_num; sens_num ++) 
    {
        if ( sens_num < FIRST_SENSLINE_SIZE )  group = 0; else group = 1;

        pos_in_buf_for_average = cur_pos_src_data_buf - POLIGON_FILTER_LENGTH/2;
        if (pos_in_buf_for_average < 0) pos_in_buf_for_average += POLIGON_FILTER_LENGTH;

        result =  src_data_bufer[ pos_in_buf_for_average ][sens_num] - average_value;
        result *= P_trace->Amplification_Group[group];
        result += (P_trace->max_data_code / 2);

        if (result >= P_trace->max_data_code) result = P_trace->max_data_code - 2;
        if (result < 0 ) result = 0;

        P_trace->idx_trc[cur_idx].math_records[add_seam_test_num].magn_sensors_data[sens_num]
            = (WORD) result;

    }; // for sens_counter

    cur_pos_src_data_buf++;
    if (cur_pos_src_data_buf >= POLIGON_FILTER_LENGTH) cur_pos_src_data_buf=0;
 
    return 0;

}; // long poligon_filter

long Use_poligon_data (  long cur_idx,
                        T_OPENED_TRACE *P_trace
                     ) 
 {
 
  int dimension_counter;
  int nuber_dimension_in_seam;

  nuber_dimension_in_seam = P_trace->idx_trc[cur_idx].real_len;


  for (dimension_counter = 0; dimension_counter < nuber_dimension_in_seam; dimension_counter++) 
  {
     poligon_filter( cur_idx, dimension_counter, P_trace);
  }; // for (dimension_counter=0;

  return KRT_OK;
}; // long Use_poligon_data (




#define Num_parallel_thread 16
HANDLE hThread_1 [Num_parallel_thread];
unsigned thread_1_ID [Num_parallel_thread];


typedef struct {
   T_OPENED_TRACE *P_trace;
   long block_idx;
} T_UARC_THREAD_ARG;

void get_block_data(T_OPENED_TRACE *opened_trace, long cur_idx)
{

   long file_pos, cur_file_idx;

   _compressed_block_header compressed_block_header;

   unsigned short tmp_sort_data[MAGN_SENSORS];

   _data_block unpacked_data_block;

   long decompressed_size;

   char qlz_scratch[QLZ_SCRATCH_COMPRESS];

   _record_data * data_block;

   _record_data * data_block_skip;


   long data_block_skip_counter;
   long test_counter;
   long sens_counter;
   long skip_tests;

   long pred_prioritet_od=0;
   long pred_odom_result_counter;


      cur_file_idx = opened_trace->idx_trc[cur_idx].file_num;
      file_pos = opened_trace->idx_trc[cur_idx].shift_in_file;

      memcpy( &compressed_block_header,
              &(opened_trace->Files_buffers.file[cur_file_idx].data[file_pos]),
              sizeof(compressed_block_header) );
      file_pos += sizeof(compressed_block_header);


      // разархивируем данные
      decompressed_size = 
          qlz_decompress( (const char *) &(opened_trace->Files_buffers.file[cur_file_idx].data[file_pos]),
                          (char*) unpacked_data_block.records, qlz_scratch);
      if (decompressed_size == 0) return;


/*	 ZSTD
      decompressed_size=ZSTD_decompress(
           (char*) unpacked_data_block.records,
           sizeof(unpacked_data_block.records),
           (char *) &(opened_trace->Files_buffers.file[cur_file_idx].data[file_pos]),
           compressed_block_header.compressed_block_size
         );
*/
      
      delta_decode( (char*) unpacked_data_block.records, sizeof(unpacked_data_block.records) );
      data_block = malloc(sizeof(data_block[0]) * RECORDS_IN_BLOCK);
      DeOptimize( (unsigned char*) unpacked_data_block.records,
                  (unsigned char*) data_block,
                  sizeof(_record_data)/2, RECORDS_IN_BLOCK);
      // разархивировали данные

      // если есть пропуски размножим измерения
      pred_odom_result_counter = opened_trace->idx_trc[cur_idx].pred_odom_result_counter;
      pred_prioritet_od = opened_trace->idx_trc[cur_idx].property;

      if (compressed_block_header.real_dim != opened_trace->idx_trc[cur_idx].real_len) {

           data_block_skip_counter = 0;
           data_block_skip = malloc(sizeof(data_block_skip[0]) * opened_trace->idx_trc[cur_idx].real_len);
           if (data_block_skip == NULL)  return;

           for (test_counter = 0; test_counter < compressed_block_header.real_dim; test_counter++)
           {
               skip_tests = data_block[test_counter].odom_result_counter - 
                            pred_odom_result_counter;

//               if (skip_tests > 1000 ) skip_tests += 900;

               if ((skip_tests <= 0) /* || (skip_tests >= 1000)*/ ) skip_tests = 0;

               if ( (data_block[test_counter].service_bits & 1) != pred_prioritet_od)
               {
                   pred_prioritet_od = data_block[test_counter].service_bits & 1;
                   skip_tests += ADD_THEN_CAHANGE_ODOM;
               }

               while (skip_tests > 0)
               {
                    memcpy( &data_block_skip[data_block_skip_counter],
                            &data_block[test_counter],
                            sizeof(data_block[test_counter])
                          );

                    data_block_skip_counter++;
                    if (data_block_skip_counter >= opened_trace->idx_trc[cur_idx].real_len)
                    {
                        data_block_skip_counter = opened_trace->idx_trc[cur_idx].real_len - 1;
                        break;
                    }
                    skip_tests--;
               }; // while (skip_tests > 0)
               pred_odom_result_counter = data_block[test_counter].odom_result_counter;
           }; // for (test_counter = 0; test_counter < arc_block.header.real_dim; test_counter++)

           free(data_block);
           data_block = data_block_skip;
           // если есть пропуски размножили измерения

      } else { // if (arc_block.header.real_dim != opened_trace->idx_trc[cur_idx].real_len)

          pred_odom_result_counter = data_block[opened_trace->idx_trc[cur_idx].real_len-1].odom_result_counter;
      };

      opened_trace->idx_trc[cur_idx].records = data_block;

      opened_trace->idx_trc[cur_idx].math_records =
             malloc(sizeof(opened_trace->idx_trc[cur_idx].math_records[0]) * 
                    opened_trace->idx_trc[cur_idx].real_len
                   );
      for ( test_counter = 0;
            test_counter < opened_trace->idx_trc[cur_idx].real_len;
            test_counter ++ )
      {
          for (sens_counter = 0;
               sens_counter < opened_trace->idx_head.num_sens;
               sens_counter++) 
          {
              opened_trace->idx_trc[cur_idx].math_records[test_counter].magn_sensors_data[sens_counter] = 0;
          };
      };

      opened_trace->idx_trc[cur_idx].revers_math_records =
             malloc(sizeof(opened_trace->idx_trc[cur_idx].revers_math_records[0]) * 
                    opened_trace->idx_trc[cur_idx].real_len
                   );

      for ( test_counter = 0;
            test_counter < opened_trace->idx_trc[cur_idx].real_len;
            test_counter ++ )
      {
          for (sens_counter = 0;
               sens_counter < opened_trace->idx_head.num_sens;
               sens_counter++) 
          {
              opened_trace->idx_trc[cur_idx].revers_math_records[test_counter].magn_sensors_data[sens_counter] = 0;
          };
      };

      // отсортируем данные
      for (test_counter = 0; test_counter < opened_trace->idx_trc[cur_idx].real_len; test_counter++)
      {
          for (sens_counter = 0; sens_counter < MAGN_SENSORS; sens_counter++)
          {
             tmp_sort_data[sens_counter] =
             opened_trace->idx_trc[cur_idx].records[test_counter].magn_sensors_data[opened_trace->sens_sort[sens_counter]];

          };

          for (sens_counter = 0; sens_counter < MAGN_SENSORS; sens_counter++)
          {
             opened_trace->idx_trc[cur_idx].records[test_counter].magn_sensors_data[sens_counter] =
             tmp_sort_data[sens_counter];

          };
      };
      // Отсортировали данные

      // проинвертируем данные
      for (test_counter = 0; test_counter < opened_trace->idx_trc[cur_idx].real_len; test_counter++) 
      {
          for (sens_counter = 0; sens_counter < MAGN_SENSORS; sens_counter++)
          {
              if (opened_trace->invert_sens_data[sens_counter] != 0)
              {
                  if ( opened_trace->max_data_code >
                       (opened_trace->idx_trc[cur_idx].records[test_counter].magn_sensors_data[sens_counter] & 0xfff)
                     )
                  {
                      opened_trace->idx_trc[cur_idx].records[test_counter].magn_sensors_data[sens_counter] 
                                = (WORD) opened_trace->max_data_code - (opened_trace->idx_trc[cur_idx].records[test_counter].magn_sensors_data[sens_counter] & 0xfff);
                  } else {
                      opened_trace->idx_trc[cur_idx].records[test_counter].magn_sensors_data[sens_counter] = 0;
                  }
              };
          };
      }; //for (test_counter )
      // проинвертировали данные

} // void get_block_data(T_OPENED_TRACE *opened_trace, long cur_idx)


unsigned __stdcall Thread_NANO_512_uarc( void* pArguments )
{

    T_UARC_THREAD_ARG * uarc_thread_arg = pArguments;

    get_block_data( uarc_thread_arg->P_trace, uarc_thread_arg->block_idx);

    _endthreadex(0);
    return 0;

} // unsigned __stdcall Thread_NANO512_uarc( void* pArguments )


long get_data(T_OPENED_TRACE *opened_trace, long start, long length) {
  
  long cur_idx, first_idx, last_idx, first_file, last_file, i;

  T_UARC_THREAD_ARG uarc_thread_arg[Num_parallel_thread];
  long num_Thread_for_use;

  long if_RV_cur_idx;

  long Revers_MATH_save;

  first_idx = opened_trace->idx_head.num_idx_in_table;

  // Ищем где данные 
  for (cur_idx = 0; cur_idx < opened_trace->idx_head.num_idx_in_table; cur_idx++)
  {
       // попутно освобождаем память
       if ( opened_trace->idx_trc[cur_idx].math_records != NULL)
       {
           free(opened_trace->idx_trc[cur_idx].math_records);
           opened_trace->idx_trc[cur_idx].math_records = NULL;
       }

       if ( opened_trace->idx_trc[cur_idx].revers_math_records != NULL)
       {
           free(opened_trace->idx_trc[cur_idx].revers_math_records);
           opened_trace->idx_trc[cur_idx].revers_math_records = NULL;
       }

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
//       if ( opened_trace->idx_trc[cur_idx].math_records != NULL)
//       {
//           free(opened_trace->idx_trc[cur_idx].math_records);
//           opened_trace->idx_trc[cur_idx].math_records = NULL;
//       }
//
//       if ( (cur_idx+1) >= opened_trace->idx_head.num_idx_in_table ) break;
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
       if ( opened_trace->idx_trc[cur_idx].math_records != NULL)
       {
           free(opened_trace->idx_trc[cur_idx].math_records);
           opened_trace->idx_trc[cur_idx].math_records = NULL;
       }

       if ( opened_trace->idx_trc[cur_idx].revers_math_records != NULL)
       {
           free(opened_trace->idx_trc[cur_idx].revers_math_records);
           opened_trace->idx_trc[cur_idx].revers_math_records = NULL;
       }

       if ( opened_trace->idx_trc[cur_idx].records != NULL)
       {
           free(opened_trace->idx_trc[cur_idx].records);
           opened_trace->idx_trc[cur_idx].records = NULL;
       }
  };

  // вычислим какие файлы нам надо и загрузим их
  first_file = opened_trace->idx_trc[first_idx].file_num;
  cur_idx = last_idx;
  if (last_idx < opened_trace->idx_head.num_idx_in_table-1) cur_idx++;
  last_file = opened_trace->idx_trc[cur_idx].file_num;

  load_files_data( &(opened_trace->Files_buffers), first_file, last_file,
                   opened_trace->path_data, STR_FILE_MASK);


/*
  // вариант с последовательным получением данных
  for ( cur_idx = first_idx; cur_idx <=last_idx; cur_idx++)
  {
      get_block_data(opened_trace, cur_idx);
  };
  // конец варианта с последовательным получением данных
*/


  // вариант с параллельным получением данных
  for ( cur_idx = first_idx; cur_idx <= last_idx; cur_idx += Num_parallel_thread)
  {
      num_Thread_for_use = last_idx - cur_idx + 1;
      if (num_Thread_for_use > Num_parallel_thread) num_Thread_for_use = Num_parallel_thread;

      for (i = 0; i < num_Thread_for_use; i++)
      {
          if (opened_trace->idx_trc[cur_idx+i].records == NULL)
          {
             uarc_thread_arg[i].P_trace   = opened_trace;
             uarc_thread_arg[i].block_idx  = cur_idx + i;

             hThread_1[i] = (HANDLE)_beginthreadex( NULL, 0, &Thread_NANO_512_uarc, &(uarc_thread_arg[i]), 0, &(thread_1_ID[i]) );
          } else {
             hThread_1[i] = NULL;
          }
       };

      for (i = 0; i < num_Thread_for_use; i++)
      {
          if (hThread_1[i] != NULL)
          {
             WaitForSingleObject( hThread_1[i], INFINITE );
             CloseHandle( hThread_1[i] );
          }
      };
  };
  // конец варианта с параллельным получением данных

  Revers_MATH_save = opened_trace->Revers_MATH;
  for ( opened_trace->Revers_MATH = 0 + (!opened_trace->Standart_MATH);
        opened_trace->Revers_MATH < 1 + Revers_MATH_save;
        opened_trace->Revers_MATH ++)
  {
      for ( cur_idx = first_idx; cur_idx <= last_idx; cur_idx++)
      {
          if ( opened_trace->ReversView ^ opened_trace->Revers_MATH ){
              if_RV_cur_idx = first_idx + (last_idx - cur_idx);
          } else {
              if_RV_cur_idx = cur_idx;
          }

          if (opened_trace->Median_Filter_length > 0)
          {
             //Use_poligon_data (cur_idx, opened_trace);
             Use_median_data (if_RV_cur_idx, opened_trace);
          } else
          {
             smooth_data ( opened_trace, if_RV_cur_idx );
          };
      };
  };
  opened_trace->Revers_MATH = Revers_MATH_save;

  return KRT_OK;
}; // long get_data(T_OPENED_TRACE *opened_trace, long start, long length)


#endif
