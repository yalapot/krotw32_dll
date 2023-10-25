#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <krtapi.h>

#include "navigate.c"

#include <tracetool.c>

#include "krot_trc.c"

#include "directmove.c"
#include "drivewheel.c"
#include "height_arrow.h"

#include "acselerometr1.c"
#include "acselerometr2.c"

#include "bending_plane.h"

//#define RAZVOROT_PROSMOTRA
//#define ORIENTATION_FROM_VOG


// ***************************************************************
// функция одной итерации фильтра "Експоненциальное среднее"

/*
#define EXP_AVRG_KOEFF 0.8
long Exponent_smooth (long value)
{
   static double Exponent_average;

   Exponent_average = value * EXP_AVRG_KOEFF + Exponent_average * (1-EXP_AVRG_KOEFF);

   return (long) Exponent_average;
}


long Exponent_average (
long value,                       // очередное значение в фильтруемом ряду
long ExpAvrgWaightingCoefficient, // весовой коэффициэнт фильтра (значения от 0 до 100)
long ReinitExponent_average       // проинициализировать среднее очередным значением (TRUE/FALSE)
)
{
   static double Exponent_average;
   double ExpAvrgWC_double = ExpAvrgWaightingCoefficient;
   double result;


   if (ReinitExponent_average)
   {
       result = Exponent_average = value;
   } else {
       ExpAvrgWC_double /= 100;
       result = value;
       result = result * ExpAvrgWC_double + Exponent_average * (1.0 - ExpAvrgWC_double);
       Exponent_average = result;
   }

   return (long) result;
}


int fltExponent (
KRTDATA* data,                    // указатель на массив обработанных данных страницы развертки
KRTROW *rowData,                  // указатель на буфер сырых данных для страницы
long *dataOrnt,                   // указатель на вектор ориентации страничного буфера
long length,                      // размер массива по X
long sens_num,                    // размер массива по Y(количество датчиков)
long ExpAvrgWaightingCoefficient, // весовой коэффициэнт фильтра (значения от 0 до 100)
long Amplifer                     // параметр усиления фильтра (значения от 1 до 100)
) {

  long sens_counter, length_counter, tmp_long;

 (void) dataOrnt;


  for ( sens_counter = 0; sens_counter < sens_num; sens_counter ++)
  {
     tmp_long = rowData[length * sens_counter + 0] - 
                 Exponent_average(rowData[length * sens_counter + 0],
                                  ExpAvrgWaightingCoefficient, TRUE);

     for (length_counter = 0; length_counter < length; length_counter++)
     { 
         tmp_long = rowData[length * sens_counter + length_counter] - 
                    Exponent_average(rowData[length * sens_counter + length_counter],
                                     ExpAvrgWaightingCoefficient, FALSE);
         tmp_long *= Amplifer;

         tmp_long = 100 + (tmp_long * KRT_PALLETE_SIZE) / 4096;

         if (tmp_long >= KRT_PALLETE_SIZE) tmp_long = KRT_PALLETE_SIZE-1;
         if (tmp_long < 0) tmp_long = 0;

         data[length * sens_counter + length_counter] =  (KRTDATA) tmp_long;
     }
  }

 return 0;
}
*/

/*
long median_filter( T_INDEX_SEAM *p_seam, long add_seam_test_num, T_OPENED_TRACE *opened_trace)
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
        src_data_bufer [cur_pos_src_data_buf] [sens_num] = p_seam->inquiry[add_seam_test_num].sens[sens_num];

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


    if (first_flag < opened_trace->Median_Filter_length)
    {
        for (sens_num = 0; 
             sens_num < opened_trace->corosion_sens_num;
             sens_num ++)
        {
              average_sens_pred[sens_num] = average_sens[sens_num];
        }
        first_flag ++;

     } else 
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

    pos_data_buf = cur_pos_src_data_buf - 1 - opened_trace->Median_Filter_length/2;
    if (pos_data_buf < 0) pos_data_buf = opened_trace->Median_Filter_length + pos_data_buf;

	 // собственно усредненние занчений
    for (sens_num = 0; 
         sens_num < opened_trace->corosion_sens_num;
         sens_num ++) 
    {
       if (opened_trace->Smooth_data_OFF==0) {

           result =

           ( src_data_bufer[ pos_data_buf ][sens_num] - average_sens_pred[sens_num] )
           *
           opened_trace->Amplification_Group[0]
           +
           ( opened_trace->max_data_code / 2 );

           if (result >= opened_trace->max_data_code) result = opened_trace->max_data_code - 2;
           if (result < 0 ) result = 0;

           p_seam->inquiry[add_seam_test_num].math_sens[sens_num] = (word) result;

           p_seam->inquiry[add_seam_test_num].sens[sens_num] = (word) src_data_bufer[ pos_data_buf ][sens_num];

        } else {
           p_seam->inquiry[add_seam_test_num].math_sens[sens_num] = 
               p_seam->inquiry[add_seam_test_num].sens[sens_num] = (word) src_data_bufer[ pos_data_buf ][sens_num];
        };
    }; // for sens_counter

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
  long current_skip=0;

  hyper Averade_for_Thick;

  (void) reg_flag;

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
        if (opened_trace->max_data_code<=4096){ // если это не 16 битные данные
            // то еще и старшие 4 бита обрезаем
            tmp_sens[opened_trace->sens_sort[sens_counter]] =
                p_seam->inquiry[dimension_counter].sens[sens_counter] & 0x0FFF;
         } else {
            if (sens_counter%64==0) current_skip=0;
            if ( opened_trace->Sckip_sens_data[sens_counter] > 0 ) {
               current_skip++;
               tmp_sens[opened_trace->sens_sort[sens_counter]] = 0;
             } else {
                tmp_sens[opened_trace->sens_sort[sens_counter]] =
                    p_seam->inquiry[dimension_counter].sens[sens_counter-current_skip];
             };
         };
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

*/

#define MAX_ORIENTATION_FILTER_LENGTH 20

long Orientation_x_smooth(long new_value)
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


// возвращает указатель на массив сумм предыдущих ... или NULL при ошибке
long  smooth_data ( T_OPENED_TRACE *P_trace,
                    u16 * data,
                    u16 * smooth_data,
                    long group
                  ) 
 {
 
  int dimension_counter, sens_counter;

  long translate_res;

  static long average_sens[MAX_CORROZION_NUM];
  static long av_sens_old[MAX_CORROZION_NUM][MAX_SMOOTH_WIN_LENGTH];
  static long av_sens_len[MAX_CORROZION_NUM];


  for (dimension_counter=0;
       dimension_counter < P_trace->idx_head.num_test_in_block;
       dimension_counter++) 
   {

         for (sens_counter = 0;
              sens_counter < P_trace->idx_head.num_sens;
              sens_counter++) 
         {

             if (P_trace->Smooth_data_OFF != 0) {
                 smooth_data[ dimension_counter * P_trace->idx_head.num_sens + sens_counter ] =
                      data[ dimension_counter * P_trace->idx_head.num_sens + sens_counter ] & 0xfff;
                 continue;
             }

             if (sens_counter < FIRST_SENSLINE_SIZE) {
                 group = 0;
             } else {
//                 if (sens_counter < (FIRST_SENSLINE_SIZE + THECOND_SENSLINE_SIZE) )
//                 {
                     group = 1;
//                 } else {
//                      if (sens_counter < (FIRST_SENSLINE_SIZE + THECOND_SENSLINE_SIZE + THORD_SENSLINE_SIZE) )
//                      {
//                          group = 2;
//                      } else {
//                          group = 3;
//                      }
//                 }
             }

             av_sens_len[sens_counter]--;
             if (av_sens_len[sens_counter]<0) {
                 av_sens_len[sens_counter] = P_trace->smooth_win_length[group]-1;
             }

             translate_res = data[ dimension_counter * P_trace->idx_head.num_sens + sens_counter ] & 0xfff;


#pragma warning(disable : 4127)  // давим варнинг про константу в условии

             if (PROFIL_ROW_INVERSE == 1)
                 translate_res = MAX_DATA_CODE - translate_res;

#pragma warning(default:4127)

#ifdef PROFIL_MATH_INVERSE
            translate_res = MAX_DATA_CODE - translate_res;
#endif


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

             if (translate_res>P_trace->max_data_code) {
                 translate_res=P_trace->max_data_code;
             } else {
                 if (translate_res<0) translate_res=0;
             };

             smooth_data[ dimension_counter * P_trace->idx_head.num_sens + sens_counter ] =
                   (u16) translate_res;

         }; // for (sens_counter=

   }; // for dimension_counter

  return KRT_OK;
}; // long * smooth_data (T_INDEX_SEAM *p_seam,


long Gary_uarc( FILE * data_file,
                CORROSION_SENS_TYPE* block_data,
                int arc_size,
                int num_test_in_block,
                int num_sens
              )
{

   long beg_arc = 0;

   long sens_counter;
   long test_counter;

   long repeat_counter;
   long table_counter;
   long bit_counter;
   long num_elem_in_table;
   long num_bit_in_arc;
   long num_byte_in_arc;
   long first_arc_byte_in_buf;
   long shift_bit_data;
   s32 delta;
   s32 sign;

   ARC_TABLE_REC * arc_table;
   u8  src_table_rec;
   u8*   arc_buf;


   arc_buf = (u8*) malloc ( sizeof(u8) * num_test_in_block * sizeof(CORROSION_SENS_TYPE));
   arc_table = (ARC_TABLE_REC *) malloc(sizeof(ARC_TABLE_REC) * num_test_in_block * sizeof(CORROSION_SENS_TYPE));

   beg_arc = ftell (data_file);

   // читаем и разархивируем показания датчиков
   for (sens_counter = 0; sens_counter < num_sens; sens_counter++) {

       // читаем первое показание датчика в блоке
       repeat_counter=0;
       fread( &block_data[sens_counter],1,sizeof(CORROSION_SENS_TYPE),data_file);
       repeat_counter++;

       // читаем таблицу сжатия данных
       table_counter=0;
       while (repeat_counter < num_test_in_block) {
          fread( &src_table_rec, 1, sizeof(src_table_rec), data_file);

          arc_table[table_counter].num_repeat = (src_table_rec & 0xf0) >> 4;
          arc_table[table_counter].num_repeat++;
          arc_table[table_counter].num_bit = src_table_rec & 0xf;

          if ( arc_table[table_counter].num_bit < 4) arc_table[table_counter].num_bit = 16 + arc_table[table_counter].num_bit;

          repeat_counter += arc_table[table_counter].num_repeat;
          table_counter++;
       }; // while (repeat_counter < NUM_TEST_IN_BLOCK)
       num_elem_in_table = table_counter;

       if (repeat_counter > num_test_in_block) {
	      if (arc_size > 0)
          {
              fseek(data_file, beg_arc + arc_size, SEEK_SET);
              continue;
          } else {
              break;
          }
       };

       // считаем количество байт архивного блока датчика
       num_bit_in_arc = 0;
       for (table_counter=0; table_counter < num_elem_in_table; table_counter++) {
           num_bit_in_arc += arc_table[table_counter].num_repeat * arc_table[table_counter].num_bit;
       };

       num_byte_in_arc = num_bit_in_arc / NUM_BIT_IN_BYTE;
       if ( num_bit_in_arc % NUM_BIT_IN_BYTE)  num_byte_in_arc++;

       // Читаем архивные данные
       fread( arc_buf, 1, num_byte_in_arc, data_file);

       bit_counter=0;
       test_counter = 1;
       for (table_counter=0; table_counter < num_elem_in_table; table_counter++) {

           for (repeat_counter = 0; repeat_counter < arc_table[table_counter].num_repeat; repeat_counter++) {
              first_arc_byte_in_buf = bit_counter / NUM_BIT_IN_BYTE;
              shift_bit_data = bit_counter % NUM_BIT_IN_BYTE;

              sign = arc_buf[first_arc_byte_in_buf] + arc_buf[first_arc_byte_in_buf+1] * 256 +
                     arc_buf[first_arc_byte_in_buf+2] * 65536 + arc_buf[first_arc_byte_in_buf+3] * 16777216;

              sign  = sign << (32 - shift_bit_data - arc_table[table_counter].num_bit);
              delta = sign & 0x7fffffff;
              sign  = sign & 0x80000000;
              sign  = sign >>31;

              delta = delta >> (32 - arc_table[table_counter].num_bit);

              if (arc_table[table_counter].num_bit == 16) sign = 0;
              if (arc_table[table_counter].num_bit == 17) sign = 1;

              if (sign!=0) delta = -delta;

              block_data[num_sens * test_counter + sens_counter] = (WORD)
                      (block_data[num_sens * (test_counter-1) + sens_counter] + delta);

              test_counter++;
              bit_counter += arc_table[table_counter].num_bit;
           }; // for repeat_counter
       }; // for table_counter
   }; // for sens_counter


#ifdef THIS_INTROSCOPE_325_id3201010444
   // поправим значения некоторых датчиков

   {
       long tmp_data;

       for (sens_counter = 200; sens_counter < 206; sens_counter++)
       {
           for (test_counter = 0; test_counter < num_test_in_block; test_counter++)
           {
               tmp_data = block_data[num_sens * test_counter + sens_counter];

               tmp_data = 3943 - tmp_data;

               tmp_data = 3943 - (tmp_data + tmp_data / 4);

               block_data[num_sens * test_counter + sens_counter] = (WORD) tmp_data;
           } // for (test_counter
       }; // for sens_counter


       for (sens_counter = 416; sens_counter < 448; sens_counter++)
       {
           for (test_counter = 0; test_counter < num_test_in_block; test_counter++)
           {
               tmp_data = block_data[num_sens * test_counter + sens_counter];

               tmp_data = 3943 - tmp_data;

               tmp_data = 3943 - (tmp_data + tmp_data / 4);

               block_data[num_sens * test_counter + sens_counter] = (WORD) tmp_data;
           } // for (test_counter
       }; // for sens_counter


       for (sens_counter = 462; sens_counter < 470; sens_counter++)
       {
           for (test_counter = 0; test_counter < num_test_in_block; test_counter++)
           {
               tmp_data = block_data[num_sens * test_counter + sens_counter];

               tmp_data = 3943 - tmp_data;

               tmp_data = 3943 - (tmp_data + tmp_data / 4);

               block_data[num_sens * test_counter + sens_counter] = (WORD) tmp_data;
           } // for (test_counter
       }; // for sens_counter


       for (sens_counter = 480; sens_counter < 512; sens_counter++)
       {
           for (test_counter = 0; test_counter < num_test_in_block; test_counter++)
           {
               tmp_data = block_data[num_sens * test_counter + sens_counter];

               tmp_data = 3943 - tmp_data;

               tmp_data = 3943 - (tmp_data + tmp_data / 4);

               block_data[num_sens * test_counter + sens_counter] = (WORD) tmp_data;
           } // for (test_counter
       }; // for sens_counter

   }

   // поправили значения некоторых датчиков
#endif

   if ( arc_size > 0)
   {
       fseek(data_file, beg_arc + arc_size, SEEK_SET);
   }

   free(arc_table);
   free(arc_buf);

   return KRT_OK;
} // long Gary_uarc()

long Sort_sens_data( CORROSION_SENS_TYPE* block_data,
                     T_OPENED_TRACE *P_trace)
{
   long sens_counter;
   long test_counter;

   CORROSION_SENS_TYPE* tmp_sort_data;
   tmp_sort_data = (CORROSION_SENS_TYPE *) malloc (sizeof(CORROSION_SENS_TYPE) * P_trace->idx_head.num_sens * P_trace->idx_head.num_test_in_block);

   // Отсортируем данные
   memcpy(tmp_sort_data, block_data,
          sizeof(CORROSION_SENS_TYPE) * P_trace->idx_head.num_sens * P_trace->idx_head.num_test_in_block
         );
   for (test_counter = 0; test_counter < P_trace->idx_head.num_test_in_block; test_counter++)
   {
       for (sens_counter = 0; sens_counter < P_trace->idx_head.num_sens; sens_counter++)
       {
           if (P_trace->invert_sens_data[sens_counter] != 0)
           {
               if (tmp_sort_data[P_trace->idx_head.num_sens * test_counter + P_trace->sens_sort[sens_counter]] 
                   >  P_trace->max_data_code)
               {
                  tmp_sort_data[P_trace->idx_head.num_sens * test_counter + P_trace->sens_sort[sens_counter]]
                      = (WORD) P_trace->max_data_code;
               }

               block_data[P_trace->idx_head.num_sens * test_counter + sens_counter] = (WORD)
                   (P_trace->max_data_code -
                    tmp_sort_data[P_trace->idx_head.num_sens * test_counter + P_trace->sens_sort[sens_counter]]);
           } else {
               block_data[P_trace->idx_head.num_sens * test_counter + sens_counter] = (WORD)
                   tmp_sort_data[P_trace->idx_head.num_sens * test_counter + P_trace->sens_sort[sens_counter]];
           }
       };
   };
   // Отсортировали данные

   free(tmp_sort_data);

   return KRT_OK;
} // long Sort_sens_data()


long Get_data( T_OPENED_TRACE *P_trace,
                   long start,
                   long length,
                   long group,
                   long * uarc_data,
                   KRTDATA *screen,
                   T_Koord_data * koord_data
                  ) 
{
  static long cur_file_idx = -1;
  static FILE * data_file = NULL;
  static char file_name[1024];

  long sens_counter;
  long test_counter;

  long beg_sens, end_sens, i;
  long length_counter;
  long idx_count;

  T_Koord_data block_head;

  T_RECORD_EXTEND_SENS * ext_sens;

  CORROSION_SENS_TYPE* block_data;
  CORROSION_SENS_TYPE* block_data_smooth;

  long real_len_first_test_in_block = 0;

  long orient_for_cur_sens = 0;
  long length_for_cur_sens = 0;
  long screen_pos=0;
  long block_pos; 

  long preload_math_idx;
  long preloadmath_num_idx;
  long block_counter;

  long prof_sens_num;

  long local_length_count;
  long end_local_length_count;

  long odometer_for_cur_dim = 0;

//  long skip_dimension_flag = 0;


  // Ищем по индексам где искать начало данных
  for (idx_count=0; idx_count < P_trace->idx_head.num_idx_in_table; idx_count++)
  {
     if ( P_trace->idx_trc[idx_count].beg_trace >= start) break;
  };

  if (P_trace->idx_trc[idx_count].beg_trace > start) idx_count--;

  block_data = (CORROSION_SENS_TYPE *) malloc (sizeof(CORROSION_SENS_TYPE) * P_trace->idx_head.num_sens * P_trace->idx_head.num_test_in_block);
  block_data_smooth = (CORROSION_SENS_TYPE *) malloc (sizeof(CORROSION_SENS_TYPE) * P_trace->idx_head.num_sens * P_trace->idx_head.num_test_in_block);

// ------------------------------------------------------------------------------------
// Сделать предварительную настройку фильтра математики
#pragma region presetting_math_filter

  if ( idx_count > 0 )
  {
      preload_math_idx = idx_count;

      if (preload_math_idx > 5)
      {
         preloadmath_num_idx = 5;
         preload_math_idx -= 5;
      } else {
         preloadmath_num_idx = preload_math_idx;
         preload_math_idx = 0;
      };

      for (block_counter = 0; block_counter < preloadmath_num_idx; block_counter++)
      {
          if ( cur_file_idx != P_trace->idx_trc[preload_math_idx].file_num )
          {
              if ( data_file != NULL) fclose (data_file);

              cur_file_idx = P_trace->idx_trc[preload_math_idx].file_num;

              sprintf(file_name, "%sd%05ld.cmp", P_trace->path_data, cur_file_idx);

              data_file = fopen(file_name, "rb");
              if (data_file == NULL) {
                  sprintf(drvError, "Ошибка открытия файла %s.(Get_data) ", file_name);
                  free(block_data);
                  free(block_data_smooth);
                  return KRT_ERR;
              };
          };

          fseek(data_file, P_trace->idx_trc[preload_math_idx].shift_in_file, SEEK_SET);
          fread( &block_head, 1, sizeof(block_head), data_file);


#ifdef NOT_USE_ARC_SIZE
          Gary_uarc( data_file, block_data, 0,
                     P_trace->idx_head.num_test_in_block, P_trace->idx_head.num_sens         
                   );
#else				   
          Gary_uarc( data_file, block_data, block_head.arc_size,
                     P_trace->idx_head.num_test_in_block, P_trace->idx_head.num_sens         
                   );
#endif

          Sort_sens_data(block_data, P_trace);

//          kalibrate_sens_use ( P_trace, block_data);

          smooth_data ( P_trace, block_data, block_data_smooth, 0);

          preload_math_idx++;
      }; // for (block_counter = 0; block_counter < preloadmath_num_idx; block_counter++)
  }; // if ( idx_count > 0)
#pragma endregion  //presetting_math_filter
// -------------------------------------------------------------------------------------

  if ( cur_file_idx != P_trace->idx_trc[idx_count].file_num )
  {
      if ( data_file != NULL) fclose (data_file);

      cur_file_idx = P_trace->idx_trc[idx_count].file_num;

      sprintf(file_name, "%sd%05ld.cmp", P_trace->path_data, cur_file_idx);

      data_file = fopen(file_name, "rb");
      if (data_file == NULL) {
          sprintf(drvError, "Ошибка открытия файла %s.(Get_data) ", file_name);
          free(block_data);
          free(block_data_smooth);
          return KRT_ERR;
      };
  };

  real_len_first_test_in_block = (start - P_trace->idx_trc[idx_count].beg_trace);

  length_counter = 0;

  ext_sens = malloc ( sizeof(ext_sens[0]) * (length + P_trace->max_sens_shift) );

  fseek( P_trace->ext_idx_file_data, start  * sizeof(ext_sens[0]), SEEK_SET );
  fread(ext_sens, 1, sizeof(ext_sens[0]) * (length + P_trace->max_sens_shift), P_trace->ext_idx_file_data);

  while (length_counter < (length + P_trace->max_sens_shift)) {
      fseek(data_file, P_trace->idx_trc[idx_count].shift_in_file, SEEK_SET);

      while(fread( &block_head, 1, sizeof(block_head), data_file) != sizeof(block_head)) {
          fclose(data_file);
          data_file=NULL;

          cur_file_idx++;

          sprintf(file_name, "%sd%05ld.cmp", P_trace->path_data, cur_file_idx);

          data_file = fopen(file_name, "rb");
          if (data_file == NULL) {
              sprintf(drvError, "Ошибка открытия файла %s.(Get_data) ", file_name);
              free(ext_sens);
              free(block_data);
              free(block_data_smooth);
              return KRT_ERR;
          }

          fseek(data_file, P_trace->idx_trc[idx_count].shift_in_file, SEEK_SET);

      } // while(fread( &block_head, 1, sizeof(block_head), data_file) != sizeof(block_head))

#ifdef NOT_USE_ARC_SIZE
          Gary_uarc( data_file, block_data, 0,
                     P_trace->idx_head.num_test_in_block, P_trace->idx_head.num_sens         
                   );
#else				   
          Gary_uarc( data_file, block_data, block_head.arc_size,
                     P_trace->idx_head.num_test_in_block, P_trace->idx_head.num_sens         
                   );
#endif

      Sort_sens_data(block_data, P_trace);
      smooth_data ( P_trace, block_data, block_data_smooth, 0);

      beg_sens = 0;
      end_sens = P_trace->linesense_size[group];

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
      if ( THIS_PROFIL )
#pragma warning(default:4127)
      {
           if (group > 1)
           {
              beg_sens += P_trace->linesense_size[1];
              end_sens += P_trace->linesense_size[1];
           }
      }else {
          for (i=0; i<group; i++) {
              beg_sens += P_trace->linesense_size[i];
              end_sens += P_trace->linesense_size[i];
          }
      }
 
      local_length_count = real_len_first_test_in_block;
      end_local_length_count = P_trace->idx_trc[idx_count].real_len;

      for ( ; local_length_count < end_local_length_count; local_length_count++)
      {
          test_counter = (local_length_count * P_trace->idx_head.num_test_in_block) / P_trace->idx_trc[idx_count].real_len;

          if (length_counter < (length + P_trace->max_sens_shift)) {
              prof_sens_num = 0;

              if ( group == 2) prof_sens_num = FIRST_SENSLINE_SIZE;

              for (sens_counter = beg_sens; sens_counter < end_sens; sens_counter++) {
                  if (P_trace->Delete_sens_data[sens_counter] != SENSE_DELETE_FLAG) {

                      orient_for_cur_sens = sens_counter - P_trace->Delete_sens_data[sens_counter];
                      length_for_cur_sens = length_counter - P_trace->sens_shift[sens_counter];

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
                      if ( group == 1 && (! THIS_PROFIL))
#pragma warning(default:4127)
                      {
                         orient_for_cur_sens -= P_trace->real_number_sensor_in_group[group];
                      }

                      if (P_trace->Orientation_OFF == 0) {
                           orient_for_cur_sens += P_trace->Orientation_shift;

                           if (length_for_cur_sens >= 0) {
                                if ( group == 0) {
                                   orient_for_cur_sens += ext_sens [length_for_cur_sens].orient;
                                } else {
                                   orient_for_cur_sens += ext_sens [length_for_cur_sens].orient *
                                                          P_trace->linesense_size[group] / P_trace->linesense_size[0];
                                }

                                if ( group == 1) orient_for_cur_sens += P_trace->Orientation_shift_2;
                                if ( group == 2) orient_for_cur_sens += P_trace->Orientation_shift_3;
                                if ( group == 3) orient_for_cur_sens += P_trace->Orientation_shift_4;
                           }
                      } // if (P_trace->Orientation_OFF == 0)

                      while (orient_for_cur_sens < 0) {
                         orient_for_cur_sens += P_trace->real_number_sensor_in_group[group];
                      }

                      while (orient_for_cur_sens >= P_trace->real_number_sensor_in_group[group]) {
                         orient_for_cur_sens %= P_trace->real_number_sensor_in_group[group];
                      }

                      if ((length_for_cur_sens >= 0) && (length_for_cur_sens < length)) {
                          screen_pos = length_for_cur_sens + length * orient_for_cur_sens;

                          if ((screen_pos >= length * P_trace->real_number_sensor_in_group[group]) || (screen_pos < 0)) {
                             prof_sens_num ++;
                             continue;
                          }

                          block_pos = P_trace->idx_head.num_sens * test_counter + sens_counter;

                          uarc_data [screen_pos] = block_data[block_pos] & 0xfff;

                          if ( P_trace->Zerro_sens_data[sens_counter - P_trace->Delete_sens_data[sens_counter]] == 1) {
                             screen[screen_pos] = 100;
                          } else {

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
                               if (THIS_PROFIL && ((group == 0) || (group == 2) ))
#pragma warning(default:4127)
                               {
                                    screen[screen_pos] = (KRTDATA)
                                        Calculate_profil_mm( uarc_data [screen_pos], prof_sens_num, P_trace);
                               } else {
                                    screen[screen_pos] = (byte) (block_data_smooth [block_pos] * 200 / P_trace->max_data_code);
                               }

                               if ((P_trace->Odometers_tools_use > 0) && (group == 0)) {
                                   if (drive_wheel_data != NULL)
                                   {
                                      long dim_with_shift =  start + length_for_cur_sens;

                                      #ifdef USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS
                                          dim_with_shift += P_trace->max_sens_shift;
                                      #endif

                                      if ( dim_with_shift < 0 ) dim_with_shift = 0;
                                      if ( dim_with_shift > P_trace->trace_len ) dim_with_shift = P_trace->trace_len - 1;

                                      odometer_for_cur_dim = (long) drive_wheel_data[dim_with_shift];
                                   }

                                   if ((sens_counter == P_trace->Odometer_0_sens) && (odometer_for_cur_dim == 0)) screen[screen_pos] = 125;
                                   if ((sens_counter == P_trace->Odometer_1_sens) && (odometer_for_cur_dim == 1)) screen[screen_pos] = 199;
                               }
                          }

                          if (screen[screen_pos] > 199) screen[screen_pos] = 199;
                          prof_sens_num ++;
                      } // if ((length_for_cur_sens >= 0) && (length_for_cur_sens < length))
                  } // if (P_trace->Delete_sens_data[sens_counter] != SENSE_DELETE_FLAG)
              } // for sens_counter

              if ((length_counter >= 0) && (length_counter < length)) {
                 memcpy (&koord_data [length_counter], &block_head, sizeof(block_head));
              }
          } // if (length_counter < length)

              length_counter++;
      } // for ( ; local_length_count < end_local_length_count; local_length_count++)

      real_len_first_test_in_block = 0;

      idx_count++;
      if (idx_count >= P_trace->idx_head.num_idx_in_table ) {
         break;
      }

      if ( cur_file_idx != P_trace->idx_trc[idx_count].file_num ) {
          if ( data_file != NULL) fclose (data_file);

          cur_file_idx = P_trace->idx_trc[idx_count].file_num;

          sprintf(file_name, "%sd%05ld.cmp", P_trace->path_data, cur_file_idx);

          data_file = fopen(file_name, "rb");
          if (data_file == NULL) {
              free(ext_sens);
              free(block_data);
              free(block_data_smooth);
              sprintf(drvError, "Ошибка открытия файла %s.(Get_data) ", file_name);
              return KRT_ERR;
          }
      }
  } // while (length_counter < length)

  free(ext_sens);
  free(block_data);
  free(block_data_smooth);

  return KRT_OK;
} // long Get_data( ... )


//////////////////////////////////////////////////////////////////////////
//Callback - Функции
//////////////////////////////////////////////////////////////////////////

long WINAPI krtDrvFillData( KRTHANDLE handle, long group, long start,
                           long length, KRTDATA *screen, long *rowData)
{
  long my_start  = start;
  long my_length = length;

  long cur_trace;
  long i;

  T_Koord_data * koord_data;

#ifdef RAZVOROT_PROSMOTRA
    long tmp_value_sens;
#endif

//  group = 1;

  if (open_trace_counter==0) {
     sprintf (drvError, "нет открытых трасс(krtDrvFillData)");
     return KRT_ERR;
  }

  // найдем открытую трассу в списке:
  for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
     if (handle==trace_list[cur_trace].handle) break;
  }

  my_start = my_start * trace_list[cur_trace].trace->virtual_trace_step /
                        trace_list[cur_trace].trace->trace_step;


#ifdef RAZVOROT_PROSMOTRA
  // Это для разворота просмотра
  my_start  = trace_list[cur_trace].trace->trace_len - my_start -
                length * trace_list[cur_trace].trace->virtual_trace_step /
                         trace_list[cur_trace].trace->trace_step;
#endif

  if (cur_trace >= open_trace_counter) {
     sprintf(drvError, "не найден handle (krtDrvFillData)");
     return KRT_ERR; 
  }

  // проверим корректен ли параметр group
  if (group >= trace_list[cur_trace].trace->group_num) {
     sprintf(drvError, "group неправильный (krtDrvFillData)");
     return KRT_ERR;
  }

   // проверим корректна ли запрошенная начальная дистанция start 
  if ( my_start > trace_list[cur_trace].trace->trace_len) {
      // Обнуляем массив, т.к. все данные дальше, начало пропущено
      for (i=0; i<trace_list[cur_trace].trace->real_number_sensor_in_group[group] * my_length; i++) {
          screen[i]=0;
      }

     return KRT_OK;
  }

//  koord_data = malloc( (my_length + trace_list[cur_trace].trace->max_sens_shift) * sizeof(koord_data[0]) );
  koord_data = malloc( my_length * sizeof(koord_data[0]) );
  if (koord_data == NULL) {
     sprintf(drvError, "Нет памяти под данные одометров (krtDrvFillData)");
     return KRT_ERR;
  }

  if (Get_data(trace_list[cur_trace].trace, my_start, my_length, group, rowData, screen, koord_data) != KRT_OK)
  {
     strcat(drvError, "(krtDrvFillData)");
     return KRT_ERR;
  }

  free(koord_data);

#pragma warning(disable : 4127)  // давим варнинг про константу в условии

             if (PROFIL_ROW_INVERSE == 1)

#pragma warning(default:4127)
  { // Это если надо инвертировать сырые данные
       long length_counter;
       long sens_count_inv;

       for (length_counter=0; length_counter < length; length_counter++)
       {
           for ( sens_count_inv=0;
                 sens_count_inv < trace_list[cur_trace].trace->real_number_sensor_in_group[group];
                 sens_count_inv++ )
           {

              int  begin_pos;

              begin_pos  = (length * sens_count_inv) + length_counter;

              rowData[begin_pos]  = MAX_DATA_CODE - rowData[begin_pos];
           }
       }
  } // Это если надо инвертировать сырые данные

  if (trace_list[cur_trace].trace->virtual_trace_step != trace_list[cur_trace].trace->trace_step)
  {
      // если виртуальный одометр отличается от родного
      KRTDATA *tmp_screen;
      long *tmp_rowData;
      long virtual_length;
      long length_counter;
      long sens_counter;

      tmp_screen = malloc ( sizeof(tmp_screen[0]) * (length + 1) * trace_list[cur_trace].trace->real_number_sensor_in_group[group]);
      tmp_rowData = malloc ( sizeof(tmp_rowData[0]) * (length + 1) * trace_list[cur_trace].trace->real_number_sensor_in_group[group]);

      memcpy(tmp_screen, screen, ( sizeof(tmp_screen[0]) * length *trace_list[cur_trace].trace->real_number_sensor_in_group[group]));
      memcpy(tmp_rowData, rowData, ( sizeof(tmp_rowData[0]) * length * trace_list[cur_trace].trace->real_number_sensor_in_group[group]));

      // растягиваем картинку под ноый шаг одометра
      for (length_counter=0; length_counter < length; length_counter++)
      { 
         virtual_length = length_counter * trace_list[cur_trace].trace->virtual_trace_step / trace_list[cur_trace].trace->trace_step;
         for(sens_counter=0; sens_counter < trace_list[cur_trace].trace->real_number_sensor_in_group[group]; sens_counter++)
         {
             screen[length * sens_counter + length_counter] = 
                         tmp_screen[length * sens_counter + virtual_length];

             rowData[length * sens_counter + length_counter] = 
                         tmp_rowData[length * sens_counter + virtual_length];
         }
      }

      free(tmp_screen);
      free(tmp_rowData);
  }


#ifdef RAZVOROT_PROSMOTRA
  { // Это для разворота просмотра
       long length_counter;
       long sens_counter;

       for (length_counter=0; length_counter < length/2; length_counter++)
       {
           for ( sens_counter=0;
                 sens_counter < trace_list[cur_trace].trace->real_number_sensor_in_group[group];
                 sens_counter++ )
           {

              KRTDATA tmp_screen;
              long    tmp_rowData;
              int     begin_pos;
              int     mirror_pos;


              begin_pos  = (length * sens_counter) + length_counter;
              mirror_pos = (length * sens_counter) + (length - 1 - length_counter);

              tmp_screen         = screen[begin_pos];
              screen[begin_pos]  = screen[mirror_pos];
              screen[mirror_pos] = tmp_screen;

              tmp_rowData         = rowData[begin_pos];
              rowData[begin_pos]  = rowData[mirror_pos];
              rowData[mirror_pos] = tmp_rowData;
           };
       };
       // развернули экран
  }

  {// а тут мы инвертируем порядок датчиков
     long dim_counter;
     long sens_counter;
     long pos_in_screen, invert_pos_in_screen;
     KRTDATA tmp_screen;
     long tmp_rowData;

     for (dim_counter = 0; dim_counter < length; dim_counter++)
     {
         for ( sens_counter = 0;
               sens_counter < trace_list[cur_trace].trace->real_number_sensor_in_group[group]/2;
               sens_counter++)
         {
            pos_in_screen = (length * sens_counter) + dim_counter;
            invert_pos_in_screen = (length * (trace_list[cur_trace].trace->real_number_sensor_in_group[group] - 1 - sens_counter)) + dim_counter;


            tmp_screen = screen[pos_in_screen];
            screen[pos_in_screen] = screen[invert_pos_in_screen];
            screen[invert_pos_in_screen] = tmp_screen;


            tmp_rowData = rowData[pos_in_screen];
            rowData[pos_in_screen] = rowData[invert_pos_in_screen];
            rowData[invert_pos_in_screen] = tmp_rowData;

         }
     }

  } // проинвертировали порядок датчиков
#endif

  if ( trace_list[cur_trace].trace->BendingPlane > 0 )
  {
      T_bending_plane bending_plane;
      long my_start_vog;
      long dimension_counter;
      long bending_plane_color=0;
      long bending_plane_beg_sens;
      long line_thick = 0;
      long LINE_THICK_DEFAULT=4;


      for (dimension_counter = 0; dimension_counter < my_length; dimension_counter++)
      {

#ifdef RAZVOROT_PROSMOTRA
          my_start = start * trace_list[cur_trace].trace->virtual_trace_step /
                             trace_list[cur_trace].trace->trace_step;
#endif
          my_start_vog = (my_start + dimension_counter) * 
                         trace_list[cur_trace].trace->trace_step / 10
                         + (trace_list[cur_trace].trace->PigL3 / 10);

          my_start_vog += trace_list[cur_trace].trace->ShiftNavigation_data;

          if (my_start_vog < 1 ) my_start_vog = 1;

          if ( trace_list[cur_trace].trace->real_number_sensor_in_group[group]
               < 100)
          {
             LINE_THICK_DEFAULT = 2;
          }

          if (bending_plane_data != NULL) {
              if (bending_plane_data->file_data != NULL)
              {
                  Get_bending_plane_Data(my_start_vog, &bending_plane);

                  bending_plane_beg_sens = (long) (bending_plane.Angle * 100
                       * trace_list[cur_trace].trace->real_number_sensor_in_group[group]
                       / 1200);

                  bending_plane_beg_sens += trace_list[cur_trace].trace->real_number_sensor_in_group[group] / 4;
                  bending_plane_beg_sens -= trace_list[cur_trace].trace->real_number_sensor_in_group[group] / 20;

                  for (line_thick = 0; line_thick < LINE_THICK_DEFAULT; line_thick ++ )
                  {
                      if (line_thick == LINE_THICK_DEFAULT/2) {
                          bending_plane_beg_sens += trace_list[cur_trace].trace->real_number_sensor_in_group[group] / 10 - LINE_THICK_DEFAULT/2;
                      }
                      bending_plane_beg_sens += 1;

                      if (bending_plane_beg_sens < 0) 
                          bending_plane_beg_sens = trace_list[cur_trace].trace->real_number_sensor_in_group[group] + bending_plane_beg_sens;
                      if ( bending_plane_beg_sens >= trace_list[cur_trace].trace->real_number_sensor_in_group[group] )
                          bending_plane_beg_sens -= trace_list[cur_trace].trace->real_number_sensor_in_group[group];

                      bending_plane_color = 0;
                      if ( bending_plane.Radius < 500) bending_plane_color = 120;
                      if ( bending_plane.Radius < trace_list[cur_trace].trace->BendingPlane) bending_plane_color = 199;

                      if (bending_plane_color > 0)
                      {
                          screen[length * bending_plane_beg_sens + dimension_counter]
                              = (KRTDATA) bending_plane_color;

                          if ( bending_plane_beg_sens >=
                               trace_list[cur_trace].trace->real_number_sensor_in_group[group]/2)
                          {
                              screen[length * (bending_plane_beg_sens
                                      - trace_list[cur_trace].trace->real_number_sensor_in_group[group]/2)
                                      + dimension_counter]
                                 = (KRTDATA) bending_plane_color;
                          } else {
                              screen[length * (bending_plane_beg_sens
                                      + trace_list[cur_trace].trace->real_number_sensor_in_group[group]/2)
                                      + dimension_counter]
                                 = (KRTDATA) bending_plane_color;
                          }
                      }
                  }
              }
          }
      }
  }
  
  return KRT_OK;
} // krtDrvFillData


long WINAPI krtDrvGetFirstNode ( KRTHANDLE handle, T_NODE *node,        
                                long start, long sensType, long sensIndex,
                                long length, long controlSize )
 {

   long my_start;
   long my_start_vog;
   long my_start_nav;

   long cur_trace;

   T_RECORD_EXTEND_SENS ext_sens;

   if (open_trace_counter==0) {
      sprintf (drvError, "нет открытых трасс(krtDrvGetFirstNode)");
      return KRT_ERR;
   }

   // найдем открытую трассу в списке:
   for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
      if (handle==trace_list[cur_trace].handle) break;
   }

   if (cur_trace >= open_trace_counter) {
      sprintf(drvError, "не найден handle (krtDrvGetFirstNode)");
      return KRT_ERR; 
   }

   // настроим controlSize
   if (controlSize>0 && controlSize<length) {
      trace_list[cur_trace].trace->controlSize = (double)(length)/(double)(controlSize);
   } else {
      trace_list[cur_trace].trace->controlSize = trace_list[cur_trace].trace->virtual_trace_step;
   }

   my_start = (start/trace_list[cur_trace].trace->virtual_trace_step);

   my_start = my_start * trace_list[cur_trace].trace->virtual_trace_step /
              trace_list[cur_trace].trace->trace_step;

   if (trace_list[cur_trace].trace->controlSize < trace_list[cur_trace].trace->virtual_trace_step)
   {
      trace_list[cur_trace].trace->controlSize=trace_list[cur_trace].trace->virtual_trace_step;
   }

   // настроили controlSize и теперь заполним остальные поля для krtDrvGetNextNode
   trace_list[cur_trace].trace->nodeType = sensType;
   trace_list[cur_trace].trace->nodeIndex = sensIndex;
   trace_list[cur_trace].trace->nodePos = start;
   // заполним остальные поля для krtDrvGetNextNode

#ifdef USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS
   my_start += trace_list[cur_trace].trace->max_sens_shift;
#endif

    my_start_vog = my_start * trace_list[cur_trace].trace->trace_step / 10 
                   + (trace_list[cur_trace].trace->PigL3 / 10);

    my_start_vog += trace_list[cur_trace].trace->ShiftNavigation_data;

   if (my_start_vog < 1 ) my_start_vog = 1;

   my_start_nav = my_start_vog;

#ifdef RAZVOROT_PROSMOTRA
      // Это для разворота просмотра
   my_start  = trace_list[cur_trace].trace->trace_len - my_start;

   my_start += trace_list[cur_trace].trace->max_sens_shift;

#endif

   if ( my_start <= 0) my_start = 1;

    // проверим корректна ли запрошенная начальная дистанция start 
   if ( my_start >= trace_list[cur_trace].trace->trace_len) 
   {
      sprintf(drvError, "Не попадает start=%i в трассу (krtDrvGetFirstNode)",start);
      my_start = trace_list[cur_trace].trace->trace_len-1;
      // return KRT_ERR;
   }


   if (trace_list[cur_trace].VogData.file_data!=NULL) {
       // вычисляем и читаем нужную запись в rec.vog
       if (GetVogData(my_start_vog, &trace_list[cur_trace].VogData, drvError)!=KRT_OK)
       {
           strcat(drvError, "(krtDrvGetFirstNode)");
           return KRT_ERR;
       }
   }

   fseek( trace_list[cur_trace].trace->ext_idx_file_data, my_start * sizeof(ext_sens), SEEK_SET );
   fread(&ext_sens, 1, sizeof(ext_sens), trace_list[cur_trace].trace->ext_idx_file_data);

   switch (sensType) {

      case (KRT_SENS_ODO): {     // одометр
         node->Val=start;
         node->Pos=start;
         break;
      }

      case (KRT_SENS_TIMER): {   // таймер
         node->Val = ext_sens.time;

#ifdef RAZVOROT_PROSMOTRA
         // Это для разворота просмотра
         node->Val  = trace_list[cur_trace].trace->trace_time - ext_sens.time;
#endif
         node->Pos = start;
         break;
      }

      case (KRT_SENS_ORIENT): {  // ориентация
         if (trace_list[cur_trace].trace->Orientation_OFF==0) {
           node->Val = ext_sens.orient + trace_list[cur_trace].trace->Orientation_shift;

           while (node->Val < 0) {
              node->Val += trace_list[cur_trace].trace->real_number_sensor_in_group[0];
           };

           while (node->Val >= trace_list[cur_trace].trace->real_number_sensor_in_group[0]) {
              node->Val %= trace_list[cur_trace].trace->real_number_sensor_in_group[0];
           };

         } else {
           node->Val = 0;
         }
         node->Pos = start;
         break;
      }

     case (KRT_SENS_TEMP): {    // температура
        node->Val = ext_sens.termo;
        node->Pos = start;
        break;
       };

     case (KRT_SENS_THICK): {   // толщина
        node->Val = ext_sens.Thick;
        node->Pos = start;
        break;
      };

     case (KRT_SENS_PRESS) : // давление
     {
         byte pressure;

         if (trace_list[cur_trace].trace->pressure_data == 0)
         { 
            node->Val = 0;
            node->Pos = start;
            break;
         }

         fseek( trace_list[cur_trace].trace->pressure_data, my_start, SEEK_SET );
         fread( &pressure, 1, sizeof(pressure), trace_list[cur_trace].trace->pressure_data);

         // кПа разница с атмосферным давлением
         node->Val = (long) (((5000.0 * (double)pressure / 255.0  - 195.0) /6.4 - 101.0) * 10.0);

         node->Pos = start;
         break;
     };

     case (KRT_SENS_SHAKE) : // вибрация
     {
         node->Val=0;
         node->Pos = start;
         break;
     } // case (KRT_SENS_SHAKE)

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

     case (KRT_SENS_UGOL3D) : // угол 3D, (градус * 100)
     {
        double normal_Psi;
        double normal_Teta;

        double h;
        double v;
        double Ugol3D;

        normal_Psi = trace_list[cur_trace].VogData.cur_data.Psi;
//        while (normal_Psi > PI/2)
//        {
//           normal_Psi -= PI/2;
//        }
        normal_Psi += (PI/2);

        normal_Teta = trace_list[cur_trace].VogData.cur_data.Teta;
        normal_Teta += (PI/2);

        h=cos(normal_Psi);
        v=cos(normal_Teta);

        Ugol3D=acos(h*v);

        Ugol3D -= (PI/2);

        node->Val=(long) (Ugol3D * 180 * 100 / PI);
        node->Pos = start;
        break;
     };

     case (KRT_SENS_EXT): {    // вспомогательный

        T_arrow_hd arrow_hd;

        T_bending_plane bending_plane;

        if (trace_list[cur_trace].NavData.file_data != NULL) {
            // вычисляем и читаем нужную запись в rec.mat
            if (GetNavData(my_start_nav, &trace_list[cur_trace].NavData, drvError)!=KRT_OK)
            {
                strcat(drvError, "(krtDrvGetFirstNode)");
                return KRT_ERR;
            };
        } else {
            if (sensIndex > (4 + trace_list[cur_trace].trace->add_ext_sens_ovalnost))
            {
               break;
            }
        };

        // пропускаем овальность если она не заявлена
        if ((trace_list[cur_trace].trace->add_ext_sens_ovalnost == 0) &&
            (sensIndex > 4)
           )
        {
           sensIndex += 1;
        }

        switch (sensIndex) {
           case (0): { // Направление
//              my_start += trace_list[cur_trace].trace->max_sens_shift;
//              if ( my_start >= trace_list[cur_trace].trace->trace_len) 
//              {
//                  my_start = trace_list[cur_trace].trace->trace_len-1;
//              };
//
              node->Val=0;
              if (direct_move_data != NULL)
              {
                 node->Val=(long) direct_move_data[my_start];
              }
              node->Pos = start;
              break;
           }; /* case  0 */

           case (1): { // ведущее колесо
              node->Val=0;
              node->Pos = start;
//              {
//              char tmp[1024];
//              sprintf(tmp, "%d", drive_wheel_data);
//              MessageBox(NULL, tmp,"!!!!!!!!!!!!", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//              }

              if (drive_wheel_data != NULL)
              {
                 node->Val=(long) drive_wheel_data[my_start];
              }
              break;
            }; /* case  1 */

           case (2): { // текущий файл
              int idx_count;

              // Ищем по индексам где искать начало данных
              for (idx_count=0; idx_count < trace_list[cur_trace].trace->idx_head.num_idx_in_table; idx_count++)
              {
                 if ( trace_list[cur_trace].trace->idx_trc[idx_count].beg_trace >= my_start) break;
              };

              node->Val=trace_list[cur_trace].trace->idx_trc[idx_count].file_num;
              node->Pos = start;

              break;
            }; /* case  1 */

           case (3): { // acselerometr1
                node->Val=0;

                if (acselerometr1_data != NULL)
                 {
                    node->Val=(acselerometr1_TYPE_VALUE) acselerometr1_data[my_start];
                 }

                 node->Pos = start;
                 break;
            }

           case (4): { // acselerometr2
                node->Val=0;

                if (acselerometr2_data != NULL)
                 {
                    node->Val=(acselerometr2_TYPE_VALUE) acselerometr2_data[my_start];
                 }

                 node->Pos = start;
                 break;
            }

            case (5) : // овальность
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

           case (6):  // bending_plane.Radius
           case (7):  // bending_plane.Angle
           {
              bending_plane.Radius = 0;
              bending_plane.Angle = 0;
              if  (bending_plane_data != NULL)
                  if (bending_plane_data->file_data != NULL)
                      Get_bending_plane_Data(my_start_vog, &bending_plane);
              node->Pos = start;

              node->Val=(long) (bending_plane.Radius);

              if (sensIndex == 7)
                  node->Val=(long) (bending_plane.Angle);

              break;
           };

           case (8): { // Vog X
              node->Val=(long) (trace_list[cur_trace].NavData.cur_data.VogX * VOG_KOEFF_UMN);
              node->Pos = start;
              break;
            }; /* case  0 */
           case (9): { // Vog Y
                  node->Val=(long) (trace_list[cur_trace].NavData.cur_data.VogY * VOG_KOEFF_UMN);
              node->Pos = start;
              break;
            }; /* case  0 */
           case (10): { // Vog Z
              node->Val=(long) (trace_list[cur_trace].NavData.cur_data.VogZ * VOG_KOEFF_UMN);
              node->Pos = start;
              break;
            }; /* case  0 */
           case (11): { // Accel X
              node->Val=(long) (trace_list[cur_trace].NavData.cur_data.AccelX * ACCEL_KOEFF_UMN);
              node->Pos = start;
              break;
            }; /* case  0 */
           case (12): { // Accel Y
              node->Val=(long) (trace_list[cur_trace].NavData.cur_data.AccelY * ACCEL_KOEFF_UMN);
              node->Pos = start;
              break;
            }; /* case  0 */
           case (13): { // Accel Z
              node->Val=(long) (trace_list[cur_trace].NavData.cur_data.AccelZ * ACCEL_KOEFF_UMN);
              node->Pos = start;
              break;
            }; /* case  0 */

           case (14): { // arrow hd
              node->Val=0;

              arrow_hd.height = 0;
              if  (arrowData != NULL)
                  if (arrowData->file_data != NULL)
                      Get_arrow_hd_Data(my_start_vog, &arrow_hd);
                      node->Val=(long) (arrow_hd.height * 100000);

              if (node->Val < 0) node->Val = 0;
              if (node->Val > 100000) node->Val = 100000;
              node->Pos = start;
              break;
             }; /* case  0 */


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

#ifdef USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS
  my_start += (trace_list[curent_trace].trace->max_sens_shift * trace_list[curent_trace].trace->trace_step) /10;
#endif


#pragma warning(disable : 4127)  // давим варнинг про константу в условии

   /* выбираем действие в зависимости от типа датчика */
  if (sensGroup && KRT_SENS_VOG)

#pragma warning(default:4127)
  {

      my_start_vog = my_start;

#ifdef RAZVOROT_PROSMOTRA
         // Это для разворота просмотра
//      my_start_vog += 20;
#endif
      my_start_vog +=  trace_list[curent_trace].trace->PigL3/10;

      my_start_vog += trace_list[curent_trace].trace->ShiftNavigation_data;

      if (my_start_vog < 1 ) my_start_vog = 1;

      // вычисляем и читаем нужную запись в Vog.mat
      if (GetVogData(my_start_vog, &trace_list[curent_trace].VogData, drvError)!=KRT_OK)
      {
         strcat(drvError, "(krtDrvGetFirstNodeGroup)");
         return KRT_ERR;
      };

      node->vogx   = trace_list[curent_trace].VogData.cur_data.VogX*10;
      node->vogy   = trace_list[curent_trace].VogData.cur_data.VogY*10;
      node->vogz   = trace_list[curent_trace].VogData.cur_data.VogZ*10;
                                                                     
      node->vogext1= trace_list[curent_trace].VogData.cur_data.Psi;
      node->vogext2= trace_list[curent_trace].VogData.cur_data.Teta;
      node->vogext3= trace_list[curent_trace].VogData.cur_data.Gamma;

      node->vogPos = start; //trace_list[curent_trace].VogData.cur_data.Dist*10;
      node->odoPos = start;

   } else {
       sprintf(drvError, "bad sensGroup parameter(krtDrvGetFirstNodeGroup)");
       return KRT_ERR;
   };

   trace_list[curent_trace].cur_par_nodeGroup.sensTypeGroup = sensGroup;

   return KRT_OK;
 }; /* krtDrvGetFirstNodeGroup  */


long WINAPI krtDrvGetNextNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node) {
  int i; /* переменная для индексов в циклах */

  int curent_trace;  /* индекс текущей трассы в списке откр. трасс */
  long start;
  long my_start;

  long my_start_vog;

   /* проверим на корректность handle : */
  if (handle<=0) return KRT_ERR;   // недопустимое значение handle
  if (open_trace_counter==0) return KRT_ERR; // нет открытых трасс
  for (i=0; i<open_trace_counter; i++) {
     if (handle==trace_list[i].handle) break;
   };
  if (i==open_trace_counter) {
     sprintf(drvError, "Unknown handle trace (krtDrvGetNextNodeGroup)");
     return KRT_ERR; // нет  такого handle
   } else curent_trace=i;

   /* попытаемся проверить корректность параметра node */
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

   /* проверим корректна ли запрошенная начальная дистанция start */
  if (my_start<0) my_start=0;
  if ( my_start >= trace_list[curent_trace].trace->trace_len ) {
    my_start = trace_list[curent_trace].trace->trace_len;
   };

  start=my_start*10;

#ifdef USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS
  my_start += (trace_list[curent_trace].trace->max_sens_shift * trace_list[curent_trace].trace->trace_step) /10;
#endif

#pragma warning(disable : 4127)  // давим варнинг про константу в условии

   /* выбираем действие в зависимости от типа датчика */
  if (trace_list[curent_trace].cur_par_nodeGroup.sensTypeGroup && KRT_SENS_VOG)

#pragma warning(default:4127)
  {
      my_start_vog = my_start+1;
      my_start_vog += trace_list[curent_trace].trace->PigL3 / 10;
      my_start_vog += trace_list[curent_trace].trace->ShiftNavigation_data;
      if (my_start_vog < 1 ) my_start_vog = 1;

      // вычисляем и читаем нужную запись в Vog.mat
      if (GetVogData(my_start_vog, &trace_list[curent_trace].VogData, drvError) != KRT_OK)
      {
         strcat(drvError, "(krtDrvGetNextNodeGroup)");
         return KRT_ERR;
      };

      node->vogx   = trace_list[curent_trace].VogData.cur_data.VogX*10;
      node->vogy   = trace_list[curent_trace].VogData.cur_data.VogY*10;
      node->vogz   = trace_list[curent_trace].VogData.cur_data.VogZ*10;
                                                                     
      node->vogext1= trace_list[curent_trace].VogData.cur_data.Psi;
      node->vogext2= trace_list[curent_trace].VogData.cur_data.Teta;
      node->vogext3= trace_list[curent_trace].VogData.cur_data.Gamma;

      node->vogPos = start;
      node->odoPos = start;

   } else {
       sprintf(drvError, "bad sensGroup parameter(krtDrvGetNextNodeGroup)");
       return KRT_ERR;
   };

   return KRT_OK;
 }; /* krtDrvGetNextNodeGroup */



typedef struct
{
   long  trace;
   long  shift;
} T_length_shift;

T_length_shift length_shift[1000000];

/* функция регистрации записи */
long KRTAPI krtDrvRegister (
 const char * datFile,
 const char * trcFile,
 char **errText,
 long (KRTAPI *userBreak) (short percentDone)
 ) 
{
   FILE *add_length;
   long cur_shift=0;
   long cur_pos=0;

   long data_path_len;
   char data_path[_MAX_PATH]; // путь до файлов с данными

   FILE * data_file;
   char file_name[1024];

   FILE *idx_file_data;
   char idx_file_name[1024];

   FILE *ext_idx_file_data;
   char ext_idx_file_name[1024];

   T_RECORD_EXTEND_SENS rec_ext_sens;

   long file_counter;
   long test_counter;
   long test_in_block;

   T_File_Head    file_head;

   T_Koord_data block_head;

   long pred_time = 0;
   long d_time;

   long pred_trace = 0;
   long d_trace;

   T_IDX_TRC idx_rec;
   T_IDX_HEADER idx_head;

   long i;
   char key_name[1024];
   char key_value[1024];

   long first_length = -1;

   double cA, sA;
   double dAy, KAy, dAz, KAz;
   double gipotenuza;


   long my_orient;

   long sens_counter;

   CORROSION_SENS_TYPE* block_data;

   long sens_sort[MAX_CORROZION_NUM];
   long sens_shift[MAX_CORROZION_NUM];

   double Full_Exponent_average;

   double First_Full_Exponent_average;
   int Second_num_sens_for_thick;

   static double Exponent_average[MAGN_SENSORS];
   static long first_Exponent_average = 1;
   static double Exponent_average_koefficient = 0.1;

   unsigned short tmp_sort_data[2 * MAGN_SENSORS * 32];

   long beg_arc = 0;
   long current_trace;

   long local_length_count;

   long num_file_in_trace;
   long search_file_counter;

   u8 pred_num_uvd = 0;

   u16 pred_prioritet_od = 0;

   long first_file_index;
   long persent_value;

   char direct_move = 0;
   char drive_wheel_value = 0;

   long  reset_flag = 0;

   long accel_0_flag = 0;
   long accel_1_flag = 0;


   T_VOG_DATA VogData;

   (void) errText;


   strcpy(file_name, &datFile[strlen(datFile)-9]);
   file_name[5]=0;
   file_counter = idx_head.first_file_index = atoi(file_name);

   // выделим путь до файлов с данными из полного пути до первого файла
   strcpy(data_path, datFile);

   data_path_len=strlen(data_path);

   while ((data_path_len>0) && (data_path[data_path_len-1]!='\\')) {
     data_path[data_path_len - 1] = 0;
     data_path_len--;
   };
   // посчитали длинну строки пути до первого файла (без имени)

  sprintf(idx_file_name, "%strace.idx", data_path);

  idx_file_data = fopen(idx_file_name, "wb");
  if (idx_file_data==NULL) {
      sprintf(drvError, "Ошибка открытия файла %s. \n", idx_file_name);
      return KRT_ERR;
  };

  sprintf(ext_idx_file_name, "%sext_data.idx", data_path);

  ext_idx_file_data = fopen(ext_idx_file_name, "wb");
  if (ext_idx_file_data==NULL) {
      sprintf(drvError, "Ошибка открытия файла %s. \n", ext_idx_file_name);
      return KRT_ERR;
  };


   num_file_in_trace = 0;
   for (search_file_counter = file_counter; search_file_counter < 4096; search_file_counter++)
   {
       sprintf(file_name, "%sd%05ld.cmp", data_path, search_file_counter);
       if ( (data_file = fopen(file_name, "rb")) != NULL )
       {
          fclose(data_file);
          num_file_in_trace ++;
       } else {
          break;
       }
   } // (file_counter*100)/ num_file_in_trace
 
   first_file_index = file_counter;


   sprintf(file_name, "%sd%05ld.cmp", data_path, file_counter);
   // Выясним ID жлеза
   data_file = fopen(file_name, "rb");
   if (data_file == NULL) return KRT_ERR;

   fread( &file_head, 1, sizeof(file_head), data_file);

   if (check_file_ID(file_head.target_name) == KRT_ERR)
   {
       fclose(data_file);
       remove( trcFile );
       return KRT_ERR;
   }
   fclose(data_file);
   // Выяснили ID жлеза


  // запишем данные в trc-файл

  // запишем в trc-файл путь на рабочий каталог
  WritePrivateProfileString(DRIVER_DATA, PATH_DATA_KEY, "",trcFile);

  // запишем в trc-файл индекс первого файла
  sprintf(key_value, "%ld", idx_head.first_file_index);
  WritePrivateProfileString(DRIVER_DATA, FIRST_FILE_INDEX_KEY, key_value,trcFile);

  // запишем в trc-файл общее количество датчиков
  sprintf(key_value, "%ld", MAGN_SENSORS);
  WritePrivateProfileString(DRIVER_DATA, CORROSION_SENS_NUM_KEY, key_value,trcFile);

#pragma warning(disable : 4090)  // давим варнинг про константу-строку при передаче в функцию

  // запишем в trc-файл шаг одометра
  Create_long_key_not_rewrite(TRACE_STEP_KEY, DRIVER_DATA, _TRACE_STEP_, trcFile);

  // запишем в trc-файл шаг виртуального одометра
  Create_long_key_not_rewrite(VIRTUAL_TRACE_STEP_KEY, DRIVER_DATA, _TRACE_STEP_, trcFile);

  // запишем в trc-файл количество поясов
  Create_long_key_not_rewrite(GROUP_NUM_KEY, DRIVER_DATA, GROUP_NUM_IN_DEVICE, trcFile);

  // запишем в trc-файл кол-во датчиков коррозии в каждом поясе
  sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, 0);
  Create_long_key_not_rewrite(key_name, DRIVER_DATA, FIRST_SENSLINE_SIZE, trcFile);

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (GROUP_NUM_IN_DEVICE > 1) {
     sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, 1);
     Create_long_key_not_rewrite(key_name, DRIVER_DATA, THECOND_SENSLINE_SIZE, trcFile);
  }
#pragma warning(default:4127)

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (GROUP_NUM_IN_DEVICE > 2) {
     sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, 2);
     Create_long_key_not_rewrite(key_name, DRIVER_DATA, THORD_SENSLINE_SIZE, trcFile);
  }
#pragma warning(default:4127)

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (GROUP_NUM_IN_DEVICE > 3) {
     sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, 3);
     Create_long_key_not_rewrite(key_name, DRIVER_DATA, FORTH_SENSLINE_SIZE, trcFile);
  }
#pragma warning(default:4127)
  // записали в trc-файл кол-во датчиков коррозии в каждом поясе

  // запишем в trc-файл смещение навигационной записи относительно
  // коррозионной
  Create_long_key_not_rewrite(ShiftNavigation_data_KEY, DRIVER_DATA, 0, trcFile);

  // запишем в trc-файл флаг учета Bending Plane
  Create_long_key_not_rewrite(BendingPlane_KEY, DRIVER_DATA, 0, trcFile);

  // запишем в trc-файл флаг учета ориентации
  Create_long_key_not_rewrite(Orientation_OFF_KEY, DRIVER_DATA, 0, trcFile);

  // запишем в trc-файл коэффициенты акселерометров для ориентации
  dAy = Create_double_key_not_rewrite("orient_dAy", DRIVER_DATA, Orient_dAy_value, trcFile);
  KAy = Create_double_key_not_rewrite("orient_KAy", DRIVER_DATA, Orient_KAy_value, trcFile);
  dAz = Create_double_key_not_rewrite("orient_dAz", DRIVER_DATA, Orient_dAz_value, trcFile);
  KAz = Create_double_key_not_rewrite("orient_KAz", DRIVER_DATA, Orient_KAz_value, trcFile);

  // запишем в trc-файл поправку ориентации
  Create_long_key_not_rewrite(Orientation_shift_KEY, DRIVER_DATA, Orientation_shift_value, trcFile);

  // запишем в trc-файл поправку ориентации для второго пояса
#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (GROUP_NUM_IN_DEVICE > 1) 
       Create_long_key_not_rewrite(Orientation_shift_2_KEY, DRIVER_DATA, Orientation_shift_2_value, trcFile);
#pragma warning(default:4127)

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (GROUP_NUM_IN_DEVICE > 2) 
       Create_long_key_not_rewrite(Orientation_shift_3_KEY, DRIVER_DATA, Orientation_shift_3_value, trcFile);
#pragma warning(default:4127)

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (GROUP_NUM_IN_DEVICE > 3) 
       Create_long_key_not_rewrite(Orientation_shift_4_KEY, DRIVER_DATA, Orientation_shift_4_value, trcFile);
#pragma warning(default:4127)

  // запишем в trc-файл флаг учета математики
  Create_long_key_not_rewrite(Smooth_data_OFF_KEY, DRIVER_DATA, 0, trcFile);

  // запишем в trc-файл усиление по первому поясу
  Create_long_key_not_rewrite(Amplification_Group0_KEY, DRIVER_DATA, 10, trcFile);

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  // запишем в trc-файл усиление по второму поясу
  if (GROUP_NUM_IN_DEVICE > 1) 
       Create_long_key_not_rewrite(Amplification_Group1_KEY, DRIVER_DATA, 10, trcFile);
#pragma warning(default:4127)

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  // запишем в trc-файл усиление по второму поясу
  if (GROUP_NUM_IN_DEVICE > 2) 
       Create_long_key_not_rewrite(Amplification_Group2_KEY, DRIVER_DATA, 10, trcFile);
#pragma warning(default:4127)

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  // запишем в trc-файл усиление по второму поясу
  if (GROUP_NUM_IN_DEVICE > 3) 
       Create_long_key_not_rewrite(Amplification_Group3_KEY, DRIVER_DATA, 10, trcFile);
#pragma warning(default:4127)


  // запишем в trc-файл длинну окна сглаживания по первому поясу
  Create_long_key_not_rewrite("smooth_win_length0", DRIVER_DATA, 4, trcFile);

  // запишем в trc-файл длинну окна сглаживания по второму поясу
#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (GROUP_NUM_IN_DEVICE > 1) 
       Create_long_key_not_rewrite("smooth_win_length1", DRIVER_DATA, 4, trcFile);
#pragma warning(default:4127)

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (GROUP_NUM_IN_DEVICE > 2) 
       Create_long_key_not_rewrite("smooth_win_length2", DRIVER_DATA, 4, trcFile);
#pragma warning(default:4127)

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (GROUP_NUM_IN_DEVICE > 3) 
       Create_long_key_not_rewrite("smooth_win_length3", DRIVER_DATA, 4, trcFile);
#pragma warning(default:4127)

  // запишем в trc-файл максимальное значение сигнала
  Create_long_key_not_rewrite(MAX_DATA_CODE_KEY, DRIVER_DATA, MAX_DATA_CODE, trcFile);

  // запишем в trc-файл таблицу инвертирования сигнала датчиков
  Create_str_key_not_rewrite("invert_sens_data", DRIVER_DATA, Invert_sens_string, trcFile);

  // Выставим удаление для нужных датчиков
  Create_str_key_not_rewrite(Delete_sens_data_KEY, DRIVER_DATA, Delete_sens_string, trcFile);

  // Выставим обнуление для нужных датчиков
  Create_str_key_not_rewrite(Zerro_sens_data_KEY, DRIVER_DATA, Zerro_sens_string, trcFile);


  // Пропишем имена полей для файлов навигации
  Create_str_key_not_rewrite(RecVog_KEY, DRIVER_DATA, "", trcFile);
  Create_str_key_not_rewrite(RecMat_KEY, DRIVER_DATA, "", trcFile);

   // запишем в trc-файл сортировочные данные
   for (i=0; i < MAGN_SENSORS; i++) sens_sort[i] =  i;

   create_sens_sort (sens_sort);

   for (i=0; i < MAGN_SENSORS; i++) {
      sprintf(key_name, "%s%d", SENS_SORT_KEY, i);
      sens_sort[i] = Create_long_key_not_rewrite(key_name, DRIVER_DATA, sens_sort[i], trcFile);
    };
   // записали в trc-файл сортировочные данные

   // запишем в trc-файл данные смещений датчиков
   for (i=0; i < MAGN_SENSORS; i++) sens_shift[i] = 0;

   create_sens_shift (sens_shift);

   for (i=0; i < MAGN_SENSORS; i++) {
      sprintf(key_name, "%s%d", SENS_SHIFT_KEY, i);
      sens_shift[i] = Create_long_key_not_rewrite(key_name, DRIVER_DATA, sens_shift[i], trcFile);
   };
   // записали в trc-файл данные смещений датчиков

  // запишем в trc-файл флаг использования инструментов одометра
  Create_long_key_not_rewrite(Odometers_tools_use_KEY, DRIVER_DATA, Odometers_tools_use_value, trcFile);

  // запишем в trc-файл номер датчика по которому едет 0 одометр
  Create_long_key_not_rewrite(Odometer_0_sens_KEY, DRIVER_DATA, Odometer_0_sens_value, trcFile);

  // запишем в trc-файл номер датчика по которому едет 1 одометр
  Create_long_key_not_rewrite(Odometer_1_sens_KEY, DRIVER_DATA, Odometer_1_sens_value, trcFile);

#pragma warning(default:4090)
   // записали данные в trc-файл


   idx_head.num_idx_in_table = 0;
   idx_head.trace_len        = 0;
   idx_head.trace_time       = 0;


   memset( &VogData, sizeof(VogData), 0);

   VogData.file_data = NULL;

   Init_VogData(&VogData, data_path, (char *) trcFile, drvError);

   open_for_write_file_acselerometr1_data(data_path);
   open_for_write_file_acselerometr2_data(data_path);

   open_for_write_file_direct_move_data(data_path);
   open_for_write_file_drive_wheel_data(data_path);
   drive_wheel_value = 0;

   while ( (data_file = fopen(file_name, "rb")) != NULL ) {

      sprintf(register_log_file_name, "%sReg_Log.txt", data_path);
      sprintf(register_log_info, "%s\n", file_name);
      Reg_Log(register_log_info);

      persent_value = (file_counter-first_file_index)*100 / num_file_in_trace;
      if (persent_value<0)persent_value=0;
      if (persent_value>99)persent_value=99;


      // проверка не пытается ли пользователь прервать нас принудительно и 
      // заодно передадим процент проделанной работы
      if (userBreak((short) persent_value) )
      {
         sprintf (drvError, "Отменено пользователем (krtDrvRegister)");

         fclose(data_file);
         data_file=NULL;

         fclose(idx_file_data);
         idx_file_data=NULL;

         fclose(ext_idx_file_data);
         idx_file_data=NULL;

         return KRT_ERR;
       };


      fread( &file_head, 1, sizeof(file_head), data_file);

      idx_head.num_sens = file_head.num_sens;
      idx_head.num_test_in_block = file_head.num_test_in_block;

      block_data = (CORROSION_SENS_TYPE *) malloc (sizeof(CORROSION_SENS_TYPE) * file_head.num_sens * file_head.num_test_in_block * sizeof(CORROSION_SENS_TYPE));

      while (fread( &block_head, 1, sizeof(block_head), data_file) == sizeof(block_head)) {

           beg_arc = ftell (data_file);

           if ( ( first_length == -1 ) ) // || (file_head.num_uvd != pred_num_uvd) )
           {
               pred_trace = first_length = block_head.odometr_full - file_head.num_test_in_block;
               pred_time = block_head.time - 100;
               first_length = 1;

               pred_prioritet_od = block_head.status & 1;
           };

           pred_num_uvd = file_head.num_uvd;

           d_trace = block_head.odometr_full - pred_trace;
           if((d_trace < 1) ) //|| (d_trace > 1000))
           {
               d_trace = file_head.num_test_in_block;
#ifdef NOT_USE_ARC_SIZE
//               break;

#else
//               fseek(data_file, beg_arc + block_head.arc_size, SEEK_SET);
//               continue;
#endif
           };

#ifdef NANO_VERSION_1
           drive_wheel_value =  block_head.status & 0x1;  // это V1
#else				   
           drive_wheel_value =  block_head.status & 0x20;  // это V3
           drive_wheel_value >>= 5;

#endif
           if ( drive_wheel_value != pred_prioritet_od)  
           {
               pred_prioritet_od = drive_wheel_value;
               idx_rec.property = (u8) pred_prioritet_od;
               d_trace += ADD_THEN_CAHANGE_ODOM;

               length_shift[cur_pos].trace = (idx_head.trace_len - cur_shift) * _TRACE_STEP_;
               cur_shift += ADD_THEN_CAHANGE_ODOM;
               length_shift[cur_pos].shift = cur_shift * _TRACE_STEP_;
               cur_pos++;
           }

           pred_prioritet_od = block_head.status & 0x1;

           if (d_trace != 0)
           {

               idx_rec.beg_trace = idx_head.trace_len;
               idx_rec.shift_in_file = ftell(data_file) - sizeof(block_head);
               idx_rec.file_num = (short)file_counter;
               idx_rec.real_len = d_trace;
//               idx_rec.property = 0;


               #ifdef CALL_LOG
/*                  // Выводим данные акселерометров
                  if (debug_counter == 1)
                  {
                      sprintf(tmp_log_str, "%ld, %d, %d\n", idx_head.trace_len, block_head.accel_1, block_head.accel_2);
                      Log(tmp_log_str);
                      debug_counter=0;
                  };

                 debug_counter++;
*/               #endif
/*
               #ifdef CALL_LOG
                  if (debug_counter == 1)
                  {
                      sprintf(tmp_log_str, "%ld, %ld\n", block_head.odometr_full, block_head.odometr_2);
                      Log(tmp_log_str);
                      debug_counter=0;
                  };

                 debug_counter++;
               #endif
*/

               // Запишем индексы трассы
               if ( fwrite( &idx_rec, 1, sizeof(idx_rec), idx_file_data) != sizeof(idx_rec))
               {
                   sprintf(drvError, "Ошибка записи файла %s. \n", idx_file_name);

                   fclose(data_file);
                   data_file=NULL;

                   fclose(idx_file_data);
                   idx_file_data=NULL;

                   fclose(ext_idx_file_data);
                   idx_file_data=NULL;

                   return KRT_ERR;
               };

               idx_head.num_idx_in_table++;
           }; // if (d_trace != 0)

#ifdef NOT_USE_ARC_SIZE
           Gary_uarc( data_file, block_data, 0,
                      idx_head.num_test_in_block, idx_head.num_sens         
                    );

#else				   
           Gary_uarc( data_file, block_data, block_head.arc_size,
                      idx_head.num_test_in_block, idx_head.num_sens         
                    );
#endif

           if (d_trace == 0)
           {
              continue;
           };

           idx_head.trace_len += d_trace;
           pred_trace = block_head.odometr_full;

           d_time = block_head.time - pred_time;
           pred_time = block_head.time;


// ----------------------------------------------------------------------------------------
           // учтем направление движения
           {
           static long d_Pic_ful_track = 0;
           static long d_odom_forward  = 0;
           static long move_forward_count = 0;
           static long move_bakward_count = 0;
           static long pred_Pic_ful_track = 0;
           static long pred_odom_forward  = 0;

           d_Pic_ful_track = block_head.odometr_full - pred_Pic_ful_track;
           d_odom_forward  = pred_odom_forward - block_head.odometr_3;

           direct_move =  1;
           if ( (d_Pic_ful_track != d_odom_forward) ) {
               if (move_bakward_count > 2 ) direct_move =  -1;
               move_forward_count=0;
               move_bakward_count++;
           } else {
               move_forward_count++;
               move_bakward_count=0;
           };

           pred_Pic_ful_track = block_head.odometr_full;
           pred_odom_forward  = block_head.odometr_3;

           }
// -----------------------------------------------------------------------------------------

           current_trace = (idx_head.trace_len - d_trace) * 5;

           // считаем ориентацию
           cA=0; sA=0;

           block_head.accel_1 &= 0x3ff;
           block_head.accel_2 &= 0x3ff;

//           block_head.accel_1 = Orientation_x_smooth(block_head.accel_1);
//           block_head.accel_2 = Orientation_y_smooth(block_head.accel_2);

#pragma warning(disable : 4127)  // давим варнинг про константу в условии

            if (block_head.accel_1 < 20) accel_0_flag = 1;
            if (block_head.accel_2 < 20) accel_1_flag = 1;


           if (Orientation_shift_direct)

#pragma warning(default:4127)
           {
               //                                 dAz      KAz
               cA=((double)(block_head.accel_2 - dAz)) / (KAz);
               //                                 dAy      KAy
               sA=((double)(block_head.accel_1 - dAy)) / (KAy);
           } else {
               //                                 dAz      KAz
               sA=((double)(block_head.accel_2 - dAz)) / (KAz);
               //                                 dAy      KAy
               cA=((double)(block_head.accel_1 - dAy)) / (KAy);
           };

           gipotenuza = sqrt(cA*cA + sA*sA)*100;

           my_orient = calkulate_orientation(cA, sA,
                        FIRST_SENSLINE_SIZE - Num_Sens_Deleted_From_First_Group);

#ifdef ORIENTATION_FROM_VOG
           my_orient = get_orient_from_VOG( idx_head.trace_len * _TRACE_STEP_ / 10,
                                           &VogData,
                                           FIRST_SENSLINE_SIZE - Num_Sens_Deleted_From_First_Group);
#endif

           // Отсортируем данные
           memcpy(tmp_sort_data, block_data,
                  sizeof(CORROSION_SENS_TYPE) * file_head.num_sens * file_head.num_test_in_block
                 );
           for (test_counter = 0; test_counter < file_head.num_test_in_block; test_counter++)
           {
               for (sens_counter = 0; sens_counter < file_head.num_sens; sens_counter++)
               {
                   block_data[file_head.num_sens * test_counter + sens_counter] =
                       tmp_sort_data[file_head.num_sens * test_counter + sens_sort[sens_counter]];
               };
           };
           // Отсортировали данные


           // Запишем индексы дополнительных датчиков
           for (local_length_count = 0; local_length_count < d_trace; local_length_count++) {

              if (d_time > 0)
                  rec_ext_sens.time = idx_head.trace_time + (long)(((float)d_time*(float)local_length_count)/(float)d_trace);
              else
                  rec_ext_sens.time = idx_head.trace_time + 50 * local_length_count;

              rec_ext_sens.orient = my_orient;

              rec_ext_sens.termo = calc_termo(TERMO_PLACE);//(TERMO_PLACE * 13 - 250) / 28;

//              rec_ext_sens.termo = block_head.accel_2;

//              rec_ext_sens.termo = (long) gipotenuza;

              test_counter = (local_length_count * file_head.num_test_in_block) / d_trace;

              num_sens_for_thick = (MAGN_SENSORS / 8);
              if  ( strncmp(file_head.target_name, "3201010443", 10)==0 ) num_sens_for_thick = (MAGN_SENSORS / 4);

              // Вычислим толщину
              if (first_Exponent_average)
              {
                  for (sens_counter = 0;
                       sens_counter < num_sens_for_thick;
                       sens_counter++)
                  {
                     Exponent_average[sens_counter] =
                          block_data[file_head.num_sens * test_counter + sens_counter];
                  };

                  first_Exponent_average = 0;
              } else {

                  for (sens_counter = 0;
                       sens_counter < num_sens_for_thick;
                       sens_counter++)
                  {
                     Exponent_average[sens_counter] =
                          (Exponent_average[sens_counter] * (1-Exponent_average_koefficient));

                     if (test_counter >= file_head.num_test_in_block)
                     {
                         test_in_block = file_head.num_test_in_block;
                     } else {
                         test_in_block = test_counter;
                     };

                     Exponent_average[sens_counter] +=
                          (block_data[file_head.num_sens * test_in_block + sens_counter] * Exponent_average_koefficient);

                     if (Exponent_average[sens_counter] >= MAX_DATA_CODE) Exponent_average[sens_counter] = Exponent_average[sens_counter-1];

/* для 219 короззионника
                     {
                     static double tmp_data_for_average;

                     tmp_data_for_average = 
                            block_data[file_head.num_sens * test_in_block + sens_counter] * Exponent_average_koefficient;

                     if ((sens_counter >= 12) && (sens_counter <= 15))
                          tmp_data_for_average = 
                                 block_data[file_head.num_sens * test_in_block + 0] * Exponent_average_koefficient;

                     if ((sens_counter >= 28) && (sens_counter <= 31))
                          tmp_data_for_average = 
                                 block_data[file_head.num_sens * test_in_block + 0] * Exponent_average_koefficient;

                     if ((sens_counter >= 44) && (sens_counter <= 47))
                          tmp_data_for_average = 
                                 block_data[file_head.num_sens * test_in_block + 0] * Exponent_average_koefficient;

                     if ((sens_counter >= 60) && (sens_counter <= 63))
                          tmp_data_for_average = 
                                 block_data[file_head.num_sens * test_in_block + 0] * Exponent_average_koefficient;

                     if ((sens_counter >= 76) && (sens_counter <= 79))
                          tmp_data_for_average = 
                                 block_data[file_head.num_sens * test_in_block + 0] * Exponent_average_koefficient;

                     if ((sens_counter >= 92) && (sens_counter <= 95))
                          tmp_data_for_average = 
                                 block_data[file_head.num_sens * test_in_block + 0] * Exponent_average_koefficient;

                     if ((sens_counter >= 108) && (sens_counter <= 111))
                          tmp_data_for_average = 
                                 block_data[file_head.num_sens * test_in_block + 0] * Exponent_average_koefficient;

                     if ((sens_counter >= 124) && (sens_counter <= 127))
                          tmp_data_for_average = 
                                 block_data[file_head.num_sens * test_in_block + 0] * Exponent_average_koefficient;

                     Exponent_average[sens_counter] += tmp_data_for_average;
                     }
*/ // для 219 короззионника закончилось
                  };
              };

              Full_Exponent_average = 0;
              for (sens_counter = 0;
                   sens_counter < num_sens_for_thick;
                   sens_counter++)
              {
                  Full_Exponent_average += Exponent_average[sens_counter];
              };
              Full_Exponent_average /= num_sens_for_thick;

              First_Full_Exponent_average = Full_Exponent_average;

              // второй проход
//              Full_Exponent_average = 0;
//              Second_num_sens_for_thick = num_sens_for_thick;
//              for (sens_counter = 0; sens_counter < num_sens_for_thick; sens_counter++)
//              {
//                  if ((Exponent_average[sens_counter] < First_Full_Exponent_average + 700) &&
//                      (Exponent_average[sens_counter] > First_Full_Exponent_average - 700)
//                     )
//                  {
//                     Full_Exponent_average += Exponent_average[sens_counter];
//                  } else {
//                     Second_num_sens_for_thick --;
//                  }
//              };
//              if (Second_num_sens_for_thick != 0)
//                  Full_Exponent_average /= Second_num_sens_for_thick;
//              else 
//                    Full_Exponent_average = First_Full_Exponent_average;
              // второй проход закончился

              rec_ext_sens.Thick = (long) Full_Exponent_average;

              rec_ext_sens.Thick = MAX_DATA_CODE - rec_ext_sens.Thick;
              // Вычислили толщину

              if ( fwrite( &rec_ext_sens, 1, sizeof(rec_ext_sens), ext_idx_file_data) != sizeof(rec_ext_sens))
              {
                  sprintf(drvError, "Ошибка записи файла %s. \n", ext_idx_file_name);

                  fclose(data_file);
                  data_file=NULL;

                  fclose(idx_file_data);
                  idx_file_data=NULL;

                  fclose(ext_idx_file_data);
                  idx_file_data=NULL;

                 return KRT_ERR;
              };

              write_file_acselerometr1_data(block_head.accel_1);
              write_file_acselerometr2_data(block_head.accel_2);

//              write_file_acselerometr1_data(block_head.status & 2); // направление движения 0 колеса
//              write_file_acselerometr2_data(block_head.status & 4); // направление движения 1 колеса

//              // это для #одометры вместо акселерометров
//              write_file_acselerometr1_data(block_head.odometr_1);
//              write_file_acselerometr2_data(block_head.odometr_1);
//              fprintf(odometer_counter_file, "%ld, %ld\n", data_block[test_counter].odom1_counter,data_block[test_counter].odom2_counter);

//              write_file_acselerometr1_data(block_head.odometr_1 - block_head.odometr_2); // разница между физическими счетчиками одометров
                                            
              write_file_direct_move_data(direct_move);
              write_file_drive_wheel_data(drive_wheel_value);

           }; // for (test_counter = 0; test_counter < d_trace; test_counter++)

           if (d_time >= 0) idx_head.trace_time += d_time;

#ifdef NOT_USE_ARC_SIZE
#else
           fseek(data_file, beg_arc + block_head.arc_size, SEEK_SET);
#endif

       }; // while (fread( &Odometr, 1, sizeof(Odometr), data_file) == sizeof(Odometr))

      free(block_data);

      fclose(data_file);
      data_file=NULL;

      file_counter++;

      sprintf(file_name, "%sd%05ld.cmp",  data_path, file_counter);

  };//  while (data_file = fopen(file_name, "rb"))

  if ( fwrite( &idx_head, 1, sizeof(idx_head), idx_file_data) != sizeof(idx_head))
  {
      sprintf(drvError, "Ошибка записи файла %s. \n", idx_file_name);
      return KRT_ERR;
  };

#pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (ADD_THEN_CAHANGE_ODOM > 0)
#pragma warning(default:4127)
  {
      sprintf(idx_file_name, "%strace_shift.log", data_path);
      add_length = fopen(idx_file_name, "wb");

      length_shift[cur_pos].trace = idx_head.trace_len * _TRACE_STEP_;
      length_shift[cur_pos].shift = cur_shift * _TRACE_STEP_;

      for (i=cur_pos;i >= 0; i--) 
      {
         fwrite( &length_shift[i], 1, sizeof(length_shift[0]), add_length);
      }
      fclose(add_length);
  };

  fclose(idx_file_data);
  idx_file_data=NULL;

  fclose(ext_idx_file_data);
  idx_file_data=NULL;

  if (VogData.file_data != NULL) {
      fclose(VogData.file_data);
      VogData.file_data = NULL;
  };

  close_for_write_file_acselerometr1_data();
  close_for_write_file_acselerometr2_data();

  close_for_write_file_direct_move_data();
  close_for_write_file_drive_wheel_data();

  // запишем в trc-файл длинну трассы в измерениях
  sprintf(key_name, "%s", TRACE_LEN_KEY);
  sprintf(key_value, "%ld", idx_head.trace_len);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value,trcFile);

  if (reset_flag == 1)
  {
      MessageBox(NULL,
     "При записи данных возможно происходили перезапуски!\n Могут быть проблеммы с таймерными маркерами!\n Проверьте этот факт перезапусков в сканлоге!",
     "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
  };

  if (accel_0_flag == 1)
  {
      MessageBox(NULL,
     "Возможно не работает акселерометр 1 ориентации!\n",
     "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
  };

  if (accel_1_flag == 1)
  {
      MessageBox(NULL,
     "Возможно не работает акселерометр 2 ориентации!\n",
     "Предупреждение", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
  };


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

   long i;

   char key_name[1024];
   char key_value[1024];

   FILE *idx_file_data;
   char idx_file_name[1024];
   long idx_table_size;

   char ext_idx_file_name[1024];

   long ext_sens_index;


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

     // прочитаем из trc-файл индекс первого файла
     trace_list[curent_trace].trace->first_file_index = 
                   Get_long_key( FIRST_FILE_INDEX_KEY, DRIVER_DATA, 0, traceFile);

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

     // читаем из trc-файла шаг виртуального одометра
     trace_list[curent_trace].trace->virtual_trace_step =
                   Get_long_key( VIRTUAL_TRACE_STEP_KEY,
                                 DRIVER_DATA,
                                 trace_list[curent_trace].trace->trace_step,
                                 traceFile
                               );

     // читаем из trc-файла кол-во поясов датчиков в снаряде
     trace_list[curent_trace].trace->group_num =
                   Get_long_key( GROUP_NUM_KEY, DRIVER_DATA, GROUP_NUM_IN_DEVICE, traceFile);

     // читаем из trc-файла общее кол-во датчиков коррозии в снаряде
     trace_list[curent_trace].trace->corosion_sens_num =
                   Get_long_key( CORROSION_SENS_NUM_KEY, DRIVER_DATA, -1, traceFile);
     if (trace_list[curent_trace].trace->corosion_sens_num == -1)
     {
        sprintf (drvError, "Ошибка чтения кол-ва датчиков из файла %s.", traceFile);
        return KRT_ERR;
     };

     // читаем из trc-файла кол-во датчиков коррозии в каждом поясе
     for (i=0; i<trace_list[curent_trace].trace->group_num; i++) {
        sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, i);
        trace_list[curent_trace].trace->linesense_size[i] =
                   Get_long_key( key_name, DRIVER_DATA, -1, traceFile);
	trace_list[curent_trace].trace->real_number_sensor_in_group[i] = trace_list[curent_trace].trace->linesense_size[i];
        if (trace_list[curent_trace].trace->real_number_sensor_in_group[i] == 0)
        {
           sprintf (drvError, "Ошибка чтения кол-ва датчиков в поясах из файла %s.", traceFile);
           break;
        };
      }; // for (i=0; i<opened_trace->group_num; i++)

     // читаем из trc-файл смещение навигационной записи относительно
     // коррозионной
     trace_list[curent_trace].trace->ShiftNavigation_data =
                   Get_long_key( ShiftNavigation_data_KEY, DRIVER_DATA, 0, traceFile);

     // читаем из trc-файла флаг BendingPlane
     trace_list[curent_trace].trace->BendingPlane =
                   Get_long_key( BendingPlane_KEY, DRIVER_DATA, 0, traceFile);

     // читаем из trc-файла флаг учета ориентации
     trace_list[curent_trace].trace->Orientation_OFF =
                   Get_long_key( Orientation_OFF_KEY, DRIVER_DATA, 0, traceFile);

     // читаем из trc-файла поправку ориентации
     trace_list[curent_trace].trace->Orientation_shift =
                   Get_long_key( Orientation_shift_KEY, DRIVER_DATA, 0, traceFile);

     // читаем из trc-файла поправку ориентации  для второго пояса
     trace_list[curent_trace].trace->Orientation_shift_2 =
                   Get_long_key( Orientation_shift_2_KEY, DRIVER_DATA, 0, traceFile);

     // читаем из trc-файла поправку ориентации  для второго пояса
     trace_list[curent_trace].trace->Orientation_shift_3 =
                   Get_long_key( Orientation_shift_3_KEY, DRIVER_DATA, 0, traceFile);

     // читаем из trc-файла поправку ориентации  для второго пояса
     trace_list[curent_trace].trace->Orientation_shift_4 =
                   Get_long_key( Orientation_shift_4_KEY, DRIVER_DATA, 0, traceFile);

     // читаем из trc-файла флаг учета математики
     trace_list[curent_trace].trace->Smooth_data_OFF =
                   Get_long_key( Smooth_data_OFF_KEY, DRIVER_DATA, 0, traceFile);

     // читаем из trc-файла усиление по первому поясу
     trace_list[curent_trace].trace->Amplification_Group[0] =
                   Get_long_key( Amplification_Group0_KEY, DRIVER_DATA, 10, traceFile);

     // читаем из trc-файла усиление по второму поясу
     trace_list[curent_trace].trace->Amplification_Group[1] =
                   Get_long_key( Amplification_Group1_KEY, DRIVER_DATA, 10, traceFile);

     // читаем из trc-файла длинну окна сглаживания по первому поясу
     trace_list[curent_trace].trace->smooth_win_length[0] =
                   Get_long_key( Smooth_win_length0_KEY, DRIVER_DATA, 4, traceFile);

     // читаем из trc-файла длинну окна сглаживания по второму поясу
     trace_list[curent_trace].trace->smooth_win_length[1] =
                   Get_long_key( Smooth_win_length1_KEY, DRIVER_DATA, 4, traceFile);

     // прочитаем из trc-файла максимальное показание датчика
     trace_list[curent_trace].trace->max_data_code =
                   Get_long_key( MAX_DATA_CODE_KEY, DRIVER_DATA, MAX_DATA_CODE, traceFile);

     // читаем из trc-файла таблицу удаления датчиков из записи
     read_delete_sens_table( trace_list[curent_trace].trace->corosion_sens_num,
                             trace_list[curent_trace].trace->Delete_sens_data,
                             trace_list[curent_trace].trace->real_number_sensor_in_group,
                             trace_list[curent_trace].trace->linesense_size,
                             trace_list[curent_trace].trace->group_num,
                             traceFile );

#pragma warning(disable : 4127)  // давим варнинг про константу в условии

     if (THIS_PROFIL)

#pragma warning(default:4127)
     {
        trace_list[curent_trace].trace->real_number_sensor_in_group[1] =
              trace_list[curent_trace].trace->real_number_sensor_in_group[0];
        if ( trace_list[curent_trace].trace->group_num > 2 )
        {

            trace_list[curent_trace].trace->real_number_sensor_in_group[2] =
            trace_list[curent_trace].trace->real_number_sensor_in_group[3] =
              trace_list[curent_trace].trace->real_number_sensor_in_group[0];

        };
     };
     // прочитали таблицу  удаления датчиков из записи

     // читаем из trc-файла таблицу инвертирования сигнало датчиков
     read_invert_sens_table ( trace_list[curent_trace].trace->corosion_sens_num,
                              trace_list[curent_trace].trace->invert_sens_data,
                              traceFile );
     // прочитали таблицу инвертирования сигнало датчиков

     // читаем из trc-файла таблицу обнуления датчиков в записи
     read_zerro_sens_table( trace_list[curent_trace].trace->corosion_sens_num,
                             trace_list[curent_trace].trace->Zerro_sens_data,
                             traceFile );
     // прочитали таблицу  удаления датчиков из записи



     // читаем из trc-файла сортировочные данные 
     for (i = 0; i < trace_list[curent_trace].trace->corosion_sens_num; i++) {
        sprintf(key_name, "%s%i", SENS_SORT_KEY, i);
        trace_list[curent_trace].trace->sens_sort[i] =
                   Get_long_key( key_name, DRIVER_DATA, i, traceFile);
     } // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
     // прочитали из trc-файла сортировочные данные 

     // читаем из trc-файла данные смещения датчиков
     for (i = 0; i < trace_list[curent_trace].trace->corosion_sens_num; i++) {
        sprintf(key_name, "%s%i", SENS_SHIFT_KEY, i);

        trace_list[curent_trace].trace->sens_shift[i] = 
                   Get_long_key( key_name, DRIVER_DATA, 0, traceFile);
     } // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {

     // посчитаем максимальное смещение
     trace_list[curent_trace].trace->max_sens_shift = 0;
     for (i = 0; i < trace_list[curent_trace].trace->corosion_sens_num; i++) {

        if ( trace_list[curent_trace].trace->max_sens_shift < 
             trace_list[curent_trace].trace->sens_shift[i] )
        {
           trace_list[curent_trace].trace->max_sens_shift =
                 trace_list[curent_trace].trace->sens_shift[i];
        }
     } // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
     // прочитали из trc-файла данные  смещения датчиков

     // прочитаем из trc-файл пути на навигационные данные
     GetPrivateProfileString(DRIVER_DATA, RecVog_KEY, "", key_value, sizeof(key_value), traceFile);
     strcpy(trace_list[curent_trace].VogData.file_name, key_value);

     GetPrivateProfileString(DRIVER_DATA, RecMat_KEY, "", key_value, sizeof(key_value), traceFile);
     strcpy(trace_list[curent_trace].NavData.file_name, key_value);
     // прочитаем из trc-файл пути на навигационные данные

     // прочитаем из trc-файла ключ PigL3
     trace_list[curent_trace].trace->PigL3 = 0;
     if (GetPrivateProfileString("Trace", "PigL3", "", key_value,
                                 sizeof(key_value), trace_list[curent_trace].trace->trc_file_name) == 0)
      {
        trace_list[curent_trace].trace->PigL3 = 0;
      } else {
        trace_list[curent_trace].trace->PigL3 = atoi(key_value);
      };
     // прочитали из trc-файла ключ PigL3

     // читаем из trc-файла флаг флаг использования инструментов одометра 
     trace_list[curent_trace].trace->Odometers_tools_use =
                   Get_long_key( Odometers_tools_use_KEY, DRIVER_DATA, 0, traceFile);

     // читаем из trc-файла номер датчика по которому едет 0 одометр 
     trace_list[curent_trace].trace->Odometer_0_sens =
                   Get_long_key( Odometer_0_sens_KEY, DRIVER_DATA, 0, traceFile);

     // читаем из trc-файла номер датчика по которому едет 1 одометр 
     trace_list[curent_trace].trace->Odometer_1_sens =
                   Get_long_key( Odometer_1_sens_KEY, DRIVER_DATA, FIRST_SENSLINE_SIZE/2, traceFile);

#pragma warning(default:4090)

     // создаем и подгружаем индексы по открываемой трассе 
     sprintf(idx_file_name, "%strace.idx", trace_list[curent_trace].trace->path_data);

     idx_file_data = fopen(idx_file_name, "rb");
     if (idx_file_data==NULL) {
         sprintf(drvError, "Ошибка открытия файла %s. \n", idx_file_name);
         return KRT_ERR;
     };

     fseek(idx_file_data, 0-sizeof(trace_list[curent_trace].trace->idx_head), SEEK_END);
     fread( &trace_list[curent_trace].trace->idx_head,1,sizeof(trace_list[curent_trace].trace->idx_head), idx_file_data);

     idx_table_size = sizeof(T_IDX_TRC) * trace_list[curent_trace].trace->idx_head.num_idx_in_table;

     trace_list[curent_trace].trace->idx_trc = malloc(idx_table_size);
	 if (trace_list[curent_trace].trace->idx_trc == NULL)
	 {
             fclose(idx_file_data);
             sprintf(drvError, "Ошибка выделения памяти под индексы трассы(krtOpenTrace).\n");
             return KRT_ERR;
	 }


     fseek(idx_file_data, 0, SEEK_SET);
     fread( trace_list[curent_trace].trace->idx_trc,1 ,idx_table_size, idx_file_data);

     fclose(idx_file_data);
     idx_file_data=NULL;

     // создаем и подгружаем индексы по дополнительным датчикам 
     sprintf(ext_idx_file_name, "%sext_data.idx", trace_list[curent_trace].trace->path_data);

     trace_list[curent_trace].trace->ext_idx_file_data = fopen(ext_idx_file_name, "rb");
     if (trace_list[curent_trace].trace->ext_idx_file_data==NULL) {
         sprintf(drvError, "Ошибка открытия файла %s (krtOpenTrace). \n", ext_idx_file_name);
         return KRT_ERR;
     };


#pragma warning(disable : 4127)  // давим варнинг про константу в условии

     if ( (THIS_PROFIL) )

#pragma warning(default:4127)
     {
         // обнулим таблицу калибровки профиля
         long sens_count;
         long calibr_index_count;

         for (sens_count = 0; sens_count < MAX_PROFILE_NUM_SENS; sens_count++)
         {
             for (calibr_index_count = 0; calibr_index_count < MAX_PROFILE_CALIBRATE; calibr_index_count++)
             {
                 trace_list[curent_trace].trace->profil_calibrate[sens_count][calibr_index_count] = 0;
             }
         }

         // прочитаем калибровку профиля
         if (read_data_profil_ini(trace_list[curent_trace].trace) == KRT_ERR)
         {

#pragma warning(disable : 4127)  // давим варнинг про константу в условии

             if (PROFIL_SENS_IS_ENCODER == 0)

#pragma warning(default:4127)
             {
                 // что-то не так с калибровкой профиля
                 strcat(drvError, "(krtOpenTrace)\n");
                 strcat(drvError, "Скопируйте в каталог с данными файл calibrat.prf");
                 return KRT_ERR;
             }

//             MessageBox(NULL, "Нет калибровки энкодеров по шаблону.\n Возможно забыли скопировать.","!!!!!!!!!!!!", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);

         };
     };

     // скока поясов развертки:
     inf->sensGroups = trace_list[curent_trace].trace->group_num; 

     sprintf(ext_idx_file_name, "%sovalnost.idx", trace_list[curent_trace].trace->path_data);

     trace_list[curent_trace].trace->ovalnost_data = fopen(ext_idx_file_name, "rb");
     if (trace_list[curent_trace].trace->ovalnost_data==NULL) {
         sprintf(drvError, "Ошибка открытия файла %s. \n", ext_idx_file_name);
         trace_list[curent_trace].trace->ovalnost_data = NULL;
     } else {
         trace_list[curent_trace].trace->add_ext_sens_ovalnost++;
     };

     // проверим есть ли навигационные данные
     if (Serch_navigete( &trace_list[curent_trace].NavData,
                         trace_list[curent_trace].trace->path_data,
                         trace_list[curent_trace].trace->trc_file_name,
                         drvError
             )==KRT_OK)
     {
         // раз есть надо заявить дополнительные датчики
         inf->extSensors = 14 + trace_list[curent_trace].trace->add_ext_sens_ovalnost;
      } else {
         inf->extSensors = 7 + trace_list[curent_trace].trace->add_ext_sens_ovalnost;
      };

     open_trace_counter++;
     // открыли трассу

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
  if (Init_navigete( &trace_list[curent_trace].VogData,
                     trace_list[curent_trace].trace->path_data,
                     trace_list[curent_trace].trace->trc_file_name,
                     inf, drvError)
       !=KRT_OK)
  {
     // что-то не так с навигацией
  };

  read_file_acselerometr1_data(trace_list[curent_trace].trace->path_data);
  read_file_acselerometr2_data(trace_list[curent_trace].trace->path_data);

  read_file_direct_move_data(trace_list[curent_trace].trace->path_data);
  read_file_drive_wheel_data(trace_list[curent_trace].trace->path_data);

  Init_arrow_hd_Data(trace_list[curent_trace].trace->trc_file_name);

  Init_bending_plane_Data(trace_list[curent_trace].trace->trc_file_name);

  // заполним данные об открываемой трассе
  inf->sensGroups = trace_list[curent_trace].trace->group_num;
  inf->askMetod   = SENS_ASK_DIST;
  inf->stepSize   = trace_list[curent_trace].trace->virtual_trace_step;


  // заполним параметры первого сектора
  inf->group[0].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[0];

  #pragma warning(disable : 4127)  // давим варнинг про константу в условии
  if (THIS_PROFIL)
  #pragma warning(default:4127)
  {
     inf->group[0].type    = SENS_TYPE_PROFIL;
  } else { 
     inf->group[0].type    = SENS_TYPE_MFL;

     #pragma warning(disable : 4127)  // давим варнинг про константу в условии
     if (THIS_STRESS) inf->group[0].type    = SENS_TYPE_TFI;
     #pragma warning(default:4127)

     #pragma warning(disable : 4127)  // давим варнинг про константу в условии
     if (THIS_INTROSCOPE && inf->sensGroups==1) inf->group[0].type    = SENS_TYPE_INTROSCOPE;
     #pragma warning(default:4127)
  }
  inf->group[0].minValue= 0;
  inf->group[0].maxValue= KRT_PALLETE_SIZE;

  inf->group[0].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
  inf->group[0].minRowVal= 0; // минимальное значение сырых данных 
  inf->group[0].maxRowVal= MAX_DATA_CODE; // максимальное значение сырых данных 

  #pragma warning(disable : 4127)  // давим варнинг про константу в условии
  // заполним параметры второго сектора
  if (GROUP_NUM_IN_DEVICE > 1) 
  #pragma warning(default:4127)
  {
      inf->group[1].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[1];

      #pragma warning(disable : 4127)  // давим варнинг про константу в условии
      if (THIS_PROFIL)
      #pragma warning(default:4127)
      {
         inf->group[1].type    = SENS_TYPE_PROFIL;
      } else { 
         inf->group[1].type    = SENS_TYPE_MFL;

         #pragma warning(disable : 4127)  // давим варнинг про константу в условии
         if (THIS_STRESS) inf->group[1].type    = SENS_TYPE_TFI;
         #pragma warning(default:4127)

         #pragma warning(disable : 4127)  // давим варнинг про константу в условии
         if (THIS_INTROSCOPE) inf->group[1].type = SENS_TYPE_INTROSCOPE;
         #pragma warning(default:4127)
      }

      inf->group[1].minValue= 0;
      inf->group[1].maxValue= KRT_PALLETE_SIZE;

      inf->group[1].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
      inf->group[1].minRowVal= 0; // минимальное значение сырых данных 
      inf->group[1].maxRowVal= MAX_DATA_CODE; // максимальное значение сырых данных 
  }

  #pragma warning(disable : 4127)  // давим варнинг про константу в условии
  // заполним параметры второго сектора
  if (GROUP_NUM_IN_DEVICE > 2) 
  #pragma warning(default:4127)
  {
      inf->group[2].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[2];

      #pragma warning(disable : 4127)  // давим варнинг про константу в условии
      if (THIS_PROFIL)
      #pragma warning(default:4127)
      {
         inf->group[2].type    = SENS_TYPE_PROFIL;
      } else { 
         inf->group[2].type    = SENS_TYPE_MFL;

         #pragma warning(disable : 4127)  // давим варнинг про константу в условии
         if (THIS_STRESS) inf->group[2].type    = SENS_TYPE_TFI;
         #pragma warning(default:4127)
      }

      inf->group[2].minValue= 0;
      inf->group[2].maxValue= KRT_PALLETE_SIZE;

      inf->group[2].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
      inf->group[2].minRowVal= 0; // минимальное значение сырых данных 
      inf->group[2].maxRowVal= MAX_DATA_CODE; // максимальное значение сырых данных 
  }

  #pragma warning(disable : 4127)  // давим варнинг про константу в условии
  // заполним параметры второго сектора
  if (GROUP_NUM_IN_DEVICE > 3) 
  #pragma warning(default:4127)
  {
      inf->group[3].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[3];

      #pragma warning(disable : 4127)  // давим варнинг про константу в условии
      if (THIS_PROFIL)
      #pragma warning(default:4127)
      {
         inf->group[3].type    = SENS_TYPE_PROFIL;
      } else { 
         inf->group[3].type    = SENS_TYPE_MFL;

         #pragma warning(disable : 4127)  // давим варнинг про константу в условии
         if (THIS_STRESS) inf->group[3].type    = SENS_TYPE_TFI;
         #pragma warning(default:4127)
      }

      inf->group[3].minValue= 0;
      inf->group[3].maxValue= KRT_PALLETE_SIZE;

      inf->group[3].isRow    = 1; // 1/0 если 0 сырые данные не поддерживаются
      inf->group[3].minRowVal= 0; // минимальное значение сырых данных 
      inf->group[3].maxRowVal= MAX_DATA_CODE; // максимальное значение сырых данных 
  }


  // ха-ха а Витальке дадим на 1 измерение меньше, т.к. считаем и 0 за отсчет 
  inf->length   = (trace_list[curent_trace].trace->trace_len - 1) *
                  trace_list[curent_trace].trace->trace_step;

  inf->time     = trace_list[curent_trace].trace->trace_time ;


  inf->orientNum  = 1;
  inf->orientStep = trace_list[curent_trace].trace->virtual_trace_step;

  inf->timerNum  = 1;
  inf->timerStep = trace_list[curent_trace].trace->virtual_trace_step;

  inf->odoNum  = 1;
  inf->odoStep = trace_list[curent_trace].trace->virtual_trace_step;

  inf->tempNum  = 1;
  inf->tempStep = trace_list[curent_trace].trace->virtual_trace_step;
  inf->tempMin  = -100;
  inf->tempMax  =  100;

    // типа датчик толщины 
  inf->wallThickNum = 1;       // количество каналов
  inf->wallThickMin = 0;       // минимальное значение канала 
  inf->wallThickMax = trace_list[curent_trace].trace->max_data_code;  // максимальное значение канала 


  inf->speedMin = -100;
  inf->speedMax =  100;


  inf->shakeNum  =  1; // вибрация
  inf->shakeStep =  trace_list[curent_trace].trace->virtual_trace_step;
  inf->shakeMin  =  0;
  inf->shakeMax  =  1000;


  inf->pressNum =  1; // давление
  inf->pressStep=  trace_list[curent_trace].trace->virtual_trace_step;
  inf->pressMin = -100;
  inf->pressMax =  100;

  // Подключим вспомогательные датчики
  ext_sens_index=0;
  inf->extSens[ext_sens_index].minValue = -2;
  inf->extSens[ext_sens_index].maxValue = +2;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "Направление движения", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  inf->extSens[ext_sens_index].minValue = -1;
  inf->extSens[ext_sens_index].maxValue = 2;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "Номер приоритетного одометра", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  inf->extSens[ext_sens_index].minValue = 0;
  inf->extSens[ext_sens_index].maxValue = 1024;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "Номер текущего файла", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  inf->extSens[ext_sens_index].minValue = acselerometr1_MIN_VALUE;
  inf->extSens[ext_sens_index].maxValue = acselerometr1_MAX_VALUE;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "Акселерометр 1", 
   EXT_SENS_NAME_LENGTH
  );

  ext_sens_index++;
  inf->extSens[ext_sens_index].minValue = acselerometr2_MIN_VALUE;
  inf->extSens[ext_sens_index].maxValue = acselerometr2_MAX_VALUE;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "Акселерометр 2", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  if (trace_list[curent_trace].trace->add_ext_sens_ovalnost > 0)
  {
      inf->extSens[ext_sens_index].minValue = -100;
      inf->extSens[ext_sens_index].maxValue =  200;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "Овальность, %", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;
  };

  inf->extSens[ext_sens_index].minValue = 0;
  inf->extSens[ext_sens_index].maxValue = 10000;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "Радиус, D", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  inf->extSens[ext_sens_index].minValue = 0;
  inf->extSens[ext_sens_index].maxValue = 10000;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "Угол плоскости изгиба, ч", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  if (trace_list[curent_trace].NavData.file_data!=NULL)
  {
      inf->extSens[ext_sens_index].minValue = -70*VOG_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +70*VOG_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "ВОГ X, 0.01 град/сек",
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -70*VOG_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +70*VOG_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "ВОГ Y, 0.01 град/сек",
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -70*VOG_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +70*VOG_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "ВОГ Z, 0.01 град/сек",
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;


      inf->extSens[ext_sens_index].minValue = -10*ACCEL_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +10*ACCEL_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "Акселерометр X, mg", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -10*ACCEL_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +10*ACCEL_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "Акселерометр Y, mg", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -10*ACCEL_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +10*ACCEL_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "Акселерометр Z, mg", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = 0;
      inf->extSens[ext_sens_index].maxValue = 10000;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "arrow hd", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;
  }; // if (trace_list[curent_trace].NavData.file_data!=NULL)


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
