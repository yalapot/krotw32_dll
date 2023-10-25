// krotnano.c 
// Объявление инструментальных функций драйвера
// просмотра данных електронного блока NANO-внешник программой KrotW32
//


#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <process.h>

#include "KrtAPI2.h"

#include "krotnano.h"

#include "file_buffering.c"

extern int fileIndex;    




// Функция выделения памяти под массив измерений
// (типа конструктор T_INQUIRY)
T_INQUIRY * WINAPI init_inquiry(long  cor_num,
                                long  dim_num)
{
   long i;
   T_INQUIRY *inquiry;


   // выделим место под массив измерений
   inquiry = (T_INQUIRY *) malloc (sizeof(T_INQUIRY) * dim_num);
   if (inquiry == NULL) {
      sprintf(drvError, "Нет памяти под массив измерений(init_inquiry)");
      return inquiry;
    };

   // выделим место под массив корозионных измерений
   inquiry->sens = (SENS_DATA *) malloc (sizeof(SENS_DATA)*cor_num * dim_num);
   if (inquiry->sens == NULL) {
      sprintf(drvError, "Нет памяти под массив корозионных измерений(init_inquiry)");
      free(inquiry);
      inquiry=NULL;
      return inquiry;
    };

   // выделим место под массив ОБМАТЕМАЧЕННЫХ корозионных измерений
   inquiry->math_sens = (SENS_DATA *) malloc (sizeof(SENS_DATA)*cor_num * dim_num);
   if (inquiry->sens == NULL) {
      sprintf(drvError, "Нет памяти под массив  ОБМАТЕМАЧЕННЫХ корозионных измерений(init_inquiry)");
      free(inquiry);
      inquiry=NULL;
      return inquiry;
    };

   // проинициализируем поля sens и math_sens в inquiry_data,
   // заодно обнулим толщину
   for (i=1; i<dim_num; i++) {
      inquiry[i].sens = inquiry[i-1].sens + cor_num;
      inquiry[i].math_sens = inquiry[i-1].math_sens + cor_num;
      inquiry[i].Thick = 0;
      inquiry[i].direct_prod_put = 0;
    };

   return inquiry;
}; // T_INQUIRY * WINAPI init_inquiry(long  cor_num,

// Функция освобождения памяти под массивом измерений
// (типа деструктор T_DESCRIPTOR_TEMPLATE)
T_INQUIRY * WINAPI free_inquiry(T_INQUIRY *p_free) {

  if (p_free != NULL) {

     if (p_free->sens != NULL) {
       free(p_free->sens);
       p_free->sens = NULL;
      };

     if (p_free->math_sens != NULL) {
       free(p_free->math_sens);
       p_free->math_sens = NULL;
      };

     free(p_free);
     p_free = NULL;
   };

  return p_free;
}; //T_INQUIRY * free_inquiry(



// возвращает указатель на массив сумм предыдущих ... или NULL при ошибке
long  smooth_data ( T_OPENED_TRACE *P_trace,
                    T_SPIN_INFO * spin_info
                  ) 
 {
 
  int dimension_counter, sens_counter;

  long translate_res, group;

  static long average_sens[MAX_CORROZION_NUM];
  static long av_sens_old[MAX_CORROZION_NUM][MAX_SMOOTH_WIN_LENGTH];
  static long av_sens_len;


  for (dimension_counter=0;
       dimension_counter < spin_info->itemNum;
       dimension_counter++) 
   {

         av_sens_len--;
         if (av_sens_len<0) {
             av_sens_len = P_trace->smooth_win_length-1;
          }

         for (sens_counter = 0;
              sens_counter < 96;
              sens_counter++) 
         {
                 translate_res = spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter] & 0xfff;
                 translate_res *= 256;
                 average_sens[sens_counter] -= av_sens_old[sens_counter][av_sens_len];

                 average_sens[sens_counter] += translate_res;
                 av_sens_old[sens_counter][av_sens_len] = average_sens[sens_counter];

                 av_sens_old[sens_counter][av_sens_len]  /= P_trace->smooth_win_length;
                 average_sens[sens_counter] -= translate_res;
                 average_sens[sens_counter] += av_sens_old[sens_counter][av_sens_len];

                 translate_res -= av_sens_old[sens_counter][av_sens_len];

                 if (sens_counter <  48)
                 {
                    group = 0;
                 } else {
                    if (sens_counter <  96)
                    {
                       group = 1;
                    } else {
                       group = 2;
                    };
                 };
                 translate_res*=P_trace->Amplification_Group[group];

                 translate_res /= 256;

                 translate_res += P_trace->max_data_code/2;

                 if (translate_res>P_trace->max_data_code) {
                     translate_res=P_trace->max_data_code;
                 } else {
                     if (translate_res<0) translate_res=0;
                 };

                 spin_info->item->math_sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter] = (u16) translate_res;

         }; // for (sens_counter=
/*
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
*/
   }; // for dimension_counter

  return KRT_OK;
}; // long * smooth_data (T_INDEX_SEAM *p_seam,



long av_sens_median [MAX_DAT_VAL+1];

// возвращает KRT_OK
long Use_median_data ( T_OPENED_TRACE *P_trace,
                       T_SPIN_INFO * spin_info
                     ) 
 {
 
  int dimension_counter, sens_counter;
  int nuber_dimension_in_seam;

  static long average_sens[MAX_CORROZION_NUM];

  long tmp_value;

  long median_val_count[MAX_CORROZION_NUM];


  memset(median_val_count, 0, MAX_CORROZION_NUM * sizeof(long) );
  memset(average_sens, 0, MAX_CORROZION_NUM * sizeof(long) );

  nuber_dimension_in_seam = spin_info->itemNum;


  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {
     for (sens_counter=0; 
          sens_counter < 96; 
          sens_counter++) 
      {

         spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter] =
         spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter] & 0xfff;

         // проинвертируем данные если это надо
         if (P_trace->invert_sens_data[sens_counter]==0) {
           spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter] =
                    (MAX_DAT_VAL -
                    spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter]);
          };
       };
   }; // for (dimension_counter=0;


  // Строим гистограммы для всех датчиков
  for (sens_counter=0;
       sens_counter < 96; 
       sens_counter++) 
   {

       tmp_value = 0;

       for (dimension_counter=0;
            dimension_counter < nuber_dimension_in_seam;
            dimension_counter++) 
       {
            tmp_value +=
                spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter];
       }

        average_sens[sens_counter] = tmp_value / nuber_dimension_in_seam;
/*
       memset(av_sens_median, 0, (MAX_DAT_VAL+1) * sizeof(long) );
       for (dimension_counter=0;
            dimension_counter < nuber_dimension_in_seam;
            dimension_counter++) 
        {
            if (spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter]
                 > 4095  )
            {
               av_sens_median [4095] ++;
            } else {
               av_sens_median [spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter]] ++;
            }
        }; // for sens_counter


        // объединим соседние значения гистограм
        for (value_counter=0;
             value_counter <= MAX_DAT_VAL/2 - 2;
             value_counter+=2) 
        {
           av_sens_median [value_counter] += (av_sens_median [value_counter+1]);// + av_sens_median [value_counter-1]);
           av_sens_median [value_counter+1] = 0;
//           av_sens_median [value_counter-1] = 0;
        }


        // ищем максимумы гистограм
        for (value_counter=10;
             value_counter < (MAX_DAT_VAL - 10);
             value_counter++) 
         {
            if (median_val_count[sens_counter] <=
                av_sens_median [value_counter]
               )
             {
                 median_val_count[sens_counter] = av_sens_median [value_counter];
                 average_sens[sens_counter] = value_counter;
             };
         }; // for (value_counter=50;
*/

   }; //   for (sens_counter=0; 
  // Построили гистограммы для всех датчиков


  // собственно усредненние занчений
  for (sens_counter=0; 
       sens_counter < 96; 
       sens_counter++) 
   {

      for (dimension_counter=0;
           dimension_counter < nuber_dimension_in_seam;
           dimension_counter++) 
       {

            tmp_value =
              (
                spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter]
                 -
                average_sens[sens_counter]
              )
              * 1000
              /
              average_sens[sens_counter]
              ;

             tmp_value += MAX_DAT_VAL/2;

             if (tmp_value > MAX_DAT_VAL) tmp_value = MAX_DAT_VAL;
             if (tmp_value < 0)
             {
                tmp_value = 0;
             }

             spin_info->item->math_sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter] =
                   (WORD) tmp_value;

       }; // for dimension_counter
   }; // for sens_counter
  // собственно усредненние занчений закончено

  return KRT_OK;
}; // long * Use_median_data (



// Функция выделения памяти под структуру открытой трассы 
//(типа конструктор T_OPENED_TRACE)
T_OPENED_TRACE * WINAPI init_opened_trace() {

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

  space_for_trace->corosion_sens_num=0;
  space_for_trace->group_num=0;

  space_for_trace->max_data_code=0;

  space_for_trace->Smooth_data_OFF=0;

  for (i=0; i<MAX_GROUP_NUM; i++) {
     space_for_trace->linesense_size[i]=0;
     space_for_trace->Amplification_Group[i]=0;
     space_for_trace->smooth_win_length = 2;
   };


  for (i=0; i<MAX_CORROZION_NUM; i++) {
     space_for_trace->sens_sort[i]=i;
     space_for_trace->invert_sens_data[i]=0;
   };

  space_for_trace->nodeType=0; 
  space_for_trace->nodeIndex=0;            
  space_for_trace->nodePos=0;
  space_for_trace->controlSize=0;

  Init_All_FileData( &(space_for_trace->Files_buf) );

  return space_for_trace;
}; // T_OPENED_TRACE * WINAPI init_opened_trace()

// Функция освобождения памяти под структурой открытой трассы
T_OPENED_TRACE * WINAPI free_opened_trace( T_OPENED_TRACE *p_free) {

  if (p_free != NULL) {
      if ( p_free->idx_trc !=NULL) {
          free(p_free->idx_trc);
          p_free->idx_trc = NULL;
      };

      free(p_free);
      p_free = NULL;
   }; // if ((*p_free)!=NULL) {

  return p_free;
}; //  T_OPENED_TRACE * WINAPI free_opened_trace( T_OPENED_TRACE *p_free)


long Gary_uarc_from_buf( byte * file_buf,
                         long file_size,
                         long * file_pos,
                         CORROSION_SENS_TYPE* block_data,
                         int num_test_in_block,
                         int num_sens
                       )
{
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

   u8  src_table_rec;
   u8* arc_buf;
   ARC_TABLE_REC * arc_table;

   arc_buf = (u8*) malloc ( sizeof(u8) * num_test_in_block * sizeof(CORROSION_SENS_TYPE));
   arc_table = (ARC_TABLE_REC *) malloc(sizeof(ARC_TABLE_REC) * num_test_in_block * sizeof(CORROSION_SENS_TYPE));

   // читаем и разархивируем показания датчиков
   for (sens_counter = 0; sens_counter < num_sens; sens_counter++) {

       // читаем первое показание датчика в блоке
       repeat_counter=0;

       memcpy(&(block_data[sens_counter]), &(file_buf[*file_pos]), sizeof(block_data[sens_counter]));
       (*file_pos) += sizeof(block_data[sens_counter]);

       repeat_counter++;

       // читаем таблицу сжатия данных
       table_counter=0;
       while (repeat_counter < num_test_in_block) {
          src_table_rec = file_buf[*file_pos];
          (*file_pos)++;

          arc_table[table_counter].num_repeat = (src_table_rec & 0xf0) >> 4;
          arc_table[table_counter].num_repeat++;
          arc_table[table_counter].num_bit = src_table_rec & 0xf;

          repeat_counter += arc_table[table_counter].num_repeat;
          table_counter++;
       }; // while (repeat_counter < NUM_TEST_IN_BLOCK)
       num_elem_in_table = table_counter;

       // считаем количество байт архивного блока датчика
       num_bit_in_arc = 0;
       for (table_counter=0; table_counter < num_elem_in_table; table_counter++) {
           num_bit_in_arc += arc_table[table_counter].num_repeat * arc_table[table_counter].num_bit;
       };

       num_byte_in_arc = num_bit_in_arc / NUM_BIT_IN_BYTE;
       if ( num_bit_in_arc % NUM_BIT_IN_BYTE)  num_byte_in_arc++;

       // Читаем архивные данные
       memcpy(arc_buf, &(file_buf[*file_pos]), num_byte_in_arc);
       (*file_pos) += num_byte_in_arc;
       if ((*file_pos) > file_size)
       {
          free(arc_table);
          free(arc_buf);

          return KRT_OK;
       }
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

              if (sign!=0) delta = -delta;

              block_data[num_sens * test_counter + sens_counter] = (WORD)
                   (block_data[num_sens * (test_counter-1) + sens_counter] + delta);

              test_counter++;
              bit_counter += arc_table[table_counter].num_bit;
           }; // for repeat_counter
       }; // for table_counter
   }; // for sens_counter
   
   free(arc_table);
   free(arc_buf);

   return KRT_OK;
} // long Gary_uarc_from_buf()

long Gary_arc( T_OPENED_TRACE *P_trace, long spin_num, T_SPIN_INFO * spin_info) 
{
  long file_pos;
  long cur_file_idx;

  long sens_counter;
  long test_counter;
  long lenght;
  long lenght_counter;

  T_Koord_data block_head;

  CORROSION_SENS_TYPE block_data [144 * 32];
  CORROSION_SENS_TYPE tmp_sort_data[MAX_CORROZION_NUM];

  long first_test_in_block = 0;
  long block_counter;
  float length_divizor = 1.0;

  cur_file_idx = P_trace->idx_trc[spin_num].file_num;

  block_counter = 0;

  first_test_in_block = P_trace->idx_trc[spin_num].first_test_in_block;

  if (spin_num < P_trace->idx_head.num_idx_in_table-2 )
  {
     spin_info->isComplete = 1;

     spin_info->odo.length = P_trace->idx_trc[spin_num + 1].beg_trace - P_trace->idx_trc[spin_num].beg_trace;
     if (spin_info->odo.length < 0) spin_info->odo.length = P_trace->idx_trc[spin_num].lenght;
     lenght = P_trace->idx_trc[spin_num+1].vmt - P_trace->idx_trc[spin_num].vmt;
	 if (lenght>5000)
	 {
          lenght = P_trace->idx_head.num_test_in_block - first_test_in_block +
               (P_trace->idx_trc[spin_num].num_block_in_spin-1) * P_trace->idx_head.num_test_in_block;
          spin_info->isComplete = 0;
          spin_info->odo.length = 10;
	 }
     if (lenght < 0) {
        lenght = P_trace->idx_head.num_test_in_block - first_test_in_block +
                  (P_trace->idx_trc[spin_num].num_block_in_spin-1) * P_trace->idx_head.num_test_in_block;
        spin_info->isComplete = 1;
     }
  }
  else
  {
     lenght = P_trace->idx_head.num_test_in_block - first_test_in_block +
               (P_trace->idx_trc[spin_num].num_block_in_spin-1) * P_trace->idx_head.num_test_in_block;
     spin_info->isComplete = 0;
     spin_info->odo.length = 10;
  }

  spin_info->odo.start = P_trace->idx_trc[spin_num].beg_trace;

  spin_info->itemNum = lenght;


  spin_info->item = init_inquiry(P_trace->idx_head.num_sens, lenght);

  lenght_counter = 0;

  file_pos = P_trace->idx_trc[spin_num].shift_in_file;

  // вычитываем данные из файла и копируем их в оборот
  while (lenght_counter < lenght) {

      while( P_trace->Files_buf.file[cur_file_idx].file_size - file_pos < sizeof(block_head))
      {
          cur_file_idx++;
          file_pos = sizeof(T_File_Head);

      };
      memcpy( &block_head, & (P_trace->Files_buf.file[cur_file_idx].data[file_pos]),
              sizeof(block_head));
      file_pos += sizeof(block_head);

      Gary_uarc_from_buf(P_trace->Files_buf.file[cur_file_idx].data, P_trace->Files_buf.file[cur_file_idx].file_size,
                        &file_pos, block_data, P_trace->idx_head.num_test_in_block, P_trace->idx_head.num_sens);

      length_divizor = ( (float)lenght) / ( (float)spin_info->odo.length);

      // скопируем данные в оборот
      for (test_counter = first_test_in_block; test_counter < P_trace->idx_head.num_test_in_block; test_counter++)
      {
          if ((spin_info->odo.length == 0) || (P_trace->isOdoNotUse == 1) )
          {
             spin_info->item[lenght_counter].prod_put = spin_info->odo.start * P_trace->trace_step;  
          }
          else
          {
             spin_info->item[lenght_counter].prod_put = spin_info->odo.start + (long)
				       ( ( (float)lenght_counter) / length_divizor );

             spin_info->item[lenght_counter].prod_put *= P_trace->trace_step;
          };

          spin_info->item[lenght_counter].direct_prod_put = 
                                  P_trace->idx_trc[spin_num].direct_prod_put;

          for (sens_counter = 0; sens_counter < P_trace->idx_head.num_sens; sens_counter++)
          {

             if (P_trace->invert_sens_data[sens_counter]==0)
             {
                 spin_info->item->sens[P_trace->idx_head.num_sens * (lenght_counter) + sens_counter] =
                      block_data[P_trace->idx_head.num_sens * test_counter + sens_counter];
             }
             else
             {
                 spin_info->item->sens[P_trace->idx_head.num_sens * (lenght_counter) + sens_counter] =
                    (WORD) (P_trace->max_data_code - block_data[P_trace->idx_head.num_sens * test_counter + sens_counter]);
             };
          };

          lenght_counter++;
          if (lenght_counter >= lenght) break;
      }; // for (test_counter = 0; test_counter < P_trace->idx_head.num_test_in_block; test_counter++)
      // скопировали данные в оборот

      first_test_in_block = 0;

      block_counter++;
      if (block_counter >= P_trace->idx_trc[spin_num].num_block_in_spin )
      {
         break;
      };

  };// while (length_counter < length)
  // вычитали данные из файла и скопировали их в оборот

  // заполняем в обороте направление движения и, если надо, смещение внутри оборота
  while (lenght_counter < lenght)
  {
      for (sens_counter = 0; sens_counter < P_trace->idx_head.num_sens; sens_counter++)
      {
          if ((spin_info->odo.length == 0) || (P_trace->isOdoNotUse == 1) )
          {
             spin_info->item[lenght_counter].prod_put = spin_info->odo.start * P_trace->trace_step;  
          }
          else
          {
             spin_info->item[lenght_counter].prod_put = spin_info->odo.start + (long)
				       ( ( (float)lenght_counter) / length_divizor );

             spin_info->item[lenght_counter].prod_put *= P_trace->trace_step;
          };

          spin_info->item[lenght_counter].direct_prod_put = 
                                  P_trace->idx_trc[spin_num].direct_prod_put;

         spin_info->item->sens[P_trace->idx_head.num_sens * (lenght_counter) + sens_counter] =
               spin_info->item->sens[P_trace->idx_head.num_sens * (lenght_counter-1) + sens_counter];
      };

      lenght_counter++;
  }
  // заполнили в обороте направление движения и, если надо, смещение внутри оборота


  // Отсортируем данные
  for (test_counter = 0; test_counter < spin_info->itemNum ; test_counter++)
  {
      // без математики
      for (sens_counter = 0; sens_counter < P_trace->idx_head.num_sens; sens_counter++)
	  {
             tmp_sort_data[sens_counter] =
                spin_info->item[test_counter].sens[P_trace->sens_sort[sens_counter]];
	  };

      for (sens_counter = 0; sens_counter < P_trace->idx_head.num_sens; sens_counter++)
	  {
             spin_info->item[test_counter].sens[sens_counter] =
                tmp_sort_data[sens_counter];
	  };
  };
  // Отсортировали данные

  // смещение датчиков внутри ласты 1 и 3-й пояса
  if ( spin_info->item[0].direct_prod_put )
  {
      for (test_counter = 0; test_counter < spin_info->itemNum - 1; test_counter ++) 
      {
         for (sens_counter=1; sens_counter < 48; sens_counter+=2) 
         {
             spin_info->item[test_counter].sens[sens_counter] =
               spin_info->item[test_counter+1].sens[sens_counter];

             spin_info->item[test_counter].sens[sens_counter+95] =
               spin_info->item[test_counter+1].sens[sens_counter+95];
         };

      };
  } else {
      for (test_counter = 0; test_counter < spin_info->itemNum - 1; test_counter ++) 
      {
         for (sens_counter=0; sens_counter < 47; sens_counter+=2) 
         {
             spin_info->item[test_counter].sens[sens_counter] =
               spin_info->item[test_counter+1].sens[sens_counter];

             spin_info->item[test_counter].sens[sens_counter+97] =
               spin_info->item[test_counter+1].sens[sens_counter+97];
         };
      };
  };
  // сместили датчиков внутри ласты

  spin_info->odo.length *= P_trace->trace_step;
  spin_info->odo.start *= P_trace->trace_step;

  return KRT_OK;
};

unsigned __stdcall Thread_Gary_arc( void* pArguments )
{

    T_GARY_ARC_THREAD_ARG * Gary_arc_thread_arg = pArguments;

    Gary_arc( Gary_arc_thread_arg->P_trace,
              Gary_arc_thread_arg->spin_num,
              Gary_arc_thread_arg->spin_info);

    _endthreadex(0);
    return 0;
} 


void Smooth_spin(T_OPENED_TRACE *P_trace, T_SPIN_INFO * spin_info)
{
  long result_long;
  long sens_counter;
  long test_counter;

  if (P_trace->Smooth_data_OFF == 0)
  {
     if (P_trace->Median_smooth>0)
     {
         Use_median_data( P_trace, spin_info );
     } else {
         smooth_data ( P_trace, spin_info);
     };

     // продифференцируем 3 пояс
     for (test_counter = 0; test_counter < spin_info->itemNum - 1; test_counter++)
     {
         for (sens_counter = 96; sens_counter < P_trace->idx_head.num_sens; sens_counter++)
         {

            result_long = (long) spin_info->item[test_counter + 1].sens[sens_counter];
            result_long -= (long) spin_info->item[test_counter    ].sens[sens_counter];

            result_long *= P_trace->Amplification_Group[2];

            result_long += 2048;

            if ( result_long >= MAX_DAT_VAL) result_long = MAX_DAT_VAL-1;
            if ( result_long < 0) result_long = 0;

            spin_info->item[test_counter].math_sens[sens_counter] = (WORD) result_long;

         };
     }; // for (test_counter = 0; test_counter < spin_info->itemNum - 1; test_counter++)

     for (sens_counter = 96; sens_counter < P_trace->idx_head.num_sens; sens_counter++)
     {
        spin_info->item[test_counter].math_sens[sens_counter] =
             spin_info->item[test_counter-1].math_sens[sens_counter];
     };
     // продифференцировали 3 пояс
  } else {

     for (test_counter = 0; test_counter < spin_info->itemNum - 1; test_counter++)
     {
         for (sens_counter = 96; sens_counter < P_trace->idx_head.num_sens; sens_counter++)
         {
            spin_info->item[test_counter].math_sens[sens_counter] =
               spin_info->item[test_counter].sens[sens_counter];
         };
     }; // for (test_counter = 0; test_counter < spin_info->itemNum - 1; test_counter++)

  };

}; // long Gary_arc( ... )


u16 calkulate_orientation (double cA, double sA, double orient_scale) {
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


// функция настраивает таблицу инвертирования сигналов датчиков записи
// согласно текстовой строке, содержащейся в поле invert_sens_data_text 
// структуры trc.
void setupInvertTable(T_OPENED_TRACE * trc) {
char key_value[1024];
char seps[]   = " ,\t\n";
char sub_seps[]   = " -\t\n";
char *token;
char *sub_token;
long low_range, high_range, next_token, i; 

 strcpy(key_value, trc->invert_sens_data_text);
 token = strtok(key_value, seps );
 next_token=1;

 while (token!=NULL) {

  sub_token = strtok(token, sub_seps );
  low_range = sub_token ? atoi(sub_token) : 0;

  sub_token = strtok(NULL, seps );
  high_range = sub_token ? atoi(sub_token) : low_range;

  if (high_range>=low_range) {
   for (i=low_range; i<=high_range; i++) {
    trc->invert_sens_data[i]=1;
   }
  }

  strcpy(key_value, trc->invert_sens_data_text);
  token = strtok(key_value, seps);
  for (i=0; i<next_token; i++) {
   token = strtok(NULL, seps);
  }
  next_token++;
 }

} // void setupInvertTable(T_OPENED_TRACE * trc)



long read_data_from_trc(T_OPENED_TRACE * trc) {
const char *file, *ret;
   char key_name[1024];
   char key_value[1024];
   long i;

 file = trc->file;
 
 // шаг одометра
 trc->trace_step = getTrcInt(file, TRACE_STEP_KEY, OUTER_STEP);

 // путь на рабочий каталог
 ret = getTrcItem(file, KEY_DATA, "");
 if (*ret == 0) {
   strcpy(trc->path_data, file);
   while((strlen(trc->path_data)>0) && (trc->path_data[strlen(trc->path_data)-1]!='\\')) {
     trc->path_data[strlen(trc->path_data)-1]=0;
   };
 } else {
   strcpy(trc->path_data, ret);
 };

 // виртуальная длина записи (в инишнике длина в метрах)
 trc->virtLength = getTrcInt(trc->file, KEY_DATLEN, INI_DATALEN_DFLT) * 1000;

 // имя первого файла записи
 ret = getTrcItem(file, FIRST_FILE_NAME_KEY, "d00000.cmp");
 strcpy(trc->first_file_name, ret);

 // максимальное возможное показание магнитных данных
 trc->max_data_code = getTrcInt(file, MAX_DATA_CODE_KEY, MAX_DAT_VAL);

 // усиление в каждом поясе
 trc->Amplification_Group[0] = getTrcInt(file, Amplification_Group0_KEY, 4);
 trc->Amplification_Group[1] = getTrcInt(file, Amplification_Group1_KEY, 4);
 trc->Amplification_Group[2] = getTrcInt(file, Amplification_Group2_KEY, 4);

 // флаг выключения математики
 trc->Smooth_data_OFF = getTrcInt(file, Smooth_data_OFF_KEY, 0);

 // длина окна сглаживания
 trc->smooth_win_length = getTrcInt(file, Smooth_win_length_KEY, 8);

 // флаг использования медианного усреднения
 trc->Median_smooth = getTrcInt(file, Median_smooth_KEY, 0);

 // таблица инвертирования сигналов датчиков
 ret = getTrcItem(file, Invert_sens_data_KEY, "");
 if (*ret != 0) {
  strcpy(trc->invert_sens_data_text, ret);
  setupInvertTable(trc);
 }

 // разворот порядка датчиков сканеров
 trc->razvorot_1_skanera = getTrcInt(file, razvorot_1_skanera_KEY, 0);
 trc->razvorot_2_skanera = getTrcInt(file, razvorot_2_skanera_KEY, 0);
 trc->razvorot_3_skanera = getTrcInt(file, razvorot_3_skanera_KEY, 0);

 trc->Skan_2_Shift = getTrcInt(file, Skan_2_Shift_KEY, 0);
 trc->Skan_3_Shift = getTrcInt(file, Skan_3_Shift_KEY, 0);


 ret = getTrcItem(file, KEY_SENS_STEP, "2.5");
 trc->sens_step = atof(ret);


  // читаем из trc-файла сортировочные данные первого сектора
 for (i=0; i<MAX_CORROZION_NUM; i++) {
    sprintf(key_name, "%s%i", SENS_SORT_KEY, i);
    if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                                sizeof(key_value), trc->file) == 0)
     {
       sprintf (drvError, "Ошибка чтения сортировки из файла %s.", trc->file);
       trc->sens_sort[i]=i;
     } else {
       trc->sens_sort[i]=atoi(key_value);
     };
  }; // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
 // прочитали из trc-файла сортировочные данные первого сектора

 return KRT_OK;
} // long WINAPI read_data_from_trc


// функция записи индексных данных в файл
// функция создания открытой трассы с загрузкой индексных данных из файла
T_OPENED_TRACE * creation_trace(const char * trc_file) {
  T_OPENED_TRACE * new_trace;
  
//  char current_path[_MAX_PATH];

  new_trace = init_opened_trace();
  if (new_trace == NULL) {
     strcat(drvError, "(creation_trace)");
     return  NULL;
   };

  // запомним для себя в открытой трассе путь на trc-файл
  strcpy(new_trace->file, trc_file);

    // читаем из trc-файла данные
  if (read_data_from_trc(new_trace) == KRT_ERR)
   {
     strcat(drvError, "(creation_trace)");
     new_trace = free_opened_trace(new_trace);
     return NULL;
   };

  return new_trace;
}; // T_OPENED_TRACE * creation_trace


T_OPENED_TRACE *createTrace(
const char * traceFile, 
KRTHANDLE handle
) {
T_OPENED_TRACE * trc;
char *itm;
char path_data[_MAX_PATH];
long curent_trace;

 long idx_table_size;

 char data_path[_MAX_PATH]; // путь до файлов с данными

 long file_counter;
 FILE * data_file;
 char file_name[1024];

 T_ArrivedData info;


 // Проверим на корректность handle
 if (handle<=0) {
  sprintf (drvError, "handle не больше нуля(createTrace)");
  return NULL;
 }

 if (open_trace_counter>=MAX_TRACE) {
  sprintf (drvError, "Уже открыто слишком много трасс.(createTrace)");
  return NULL;
 }

 for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
  if (handle==trace_list[curent_trace].handle) {
   sprintf (drvError, "Повторное использование handle.(createTrace)");
   return NULL;
  }
 }

 curent_trace = open_trace_counter;
 trace_list[curent_trace].handle=handle;

 trace_list[curent_trace].trace =  creation_trace(traceFile);
 trc = trace_list[curent_trace].trace;
 if (trc == NULL) {
  strcat (drvError, "(createTrace)");
  return NULL;
 }

 strcpy(trc->trc_file_name, traceFile);

 // путь на рабочий каталог
 itm = getTrcItem(trc->file, KEY_DATA, "");
 if (!itm) { getDriveDir(trc->file, itm); }
 if (!itm) { return NULL; }
 if (*itm==0) {
   strcpy(path_data, trc->file);
   while((strlen(path_data)>0) && (path_data[strlen(path_data)-1]!='\\')) {
     path_data[strlen(path_data)-1]=0;
   };
 } else {
   strcpy(path_data, itm);
 };

 // проверяем его существование
 if (!isFolderExist(path_data)) {
  sprintf(drvError, 
   "Указанный в файле %s ([%s]:%s) каталог %s не существует.",
   trc->file, 
   DRIVER_DATA, 
   KEY_DATA,
   path_data
   );
  return NULL;
 }

 // обработка файла индексов, если он есть

     trc->idx_head.num_idx_in_table = 0;

     trc->idx_head.first_file_index=0;
     trc->idx_head.trace_len=0;
     trc->idx_head.trace_time=0;
     trc->idx_head.num_test_in_block=0;
     trc->idx_head.num_sens=0;

     trc->idx_head.MAX_num_idx_in_table = trc->virtLength / 100;

     idx_table_size = sizeof(T_IDX_TRC) * (trc->idx_head.MAX_num_idx_in_table);

     trc->idx_trc = malloc(idx_table_size);


     getDriveDir(trc->file, data_path);

     sprintf(trc->idx_file_name, "%s\\trace.idx", data_path);

     file_counter = 0;
     sprintf(file_name, "%s\\d%05ld.cmp", data_path, file_counter);

     while ((data_file = fopen(file_name, "rb")) != NULL) {

         fclose(data_file);
         data_file=NULL;

         getFileInfo( trc, "", file_counter, &info);
         file_counter++;

         sprintf(file_name, "%s\\d%05ld.cmp",  data_path, file_counter);

         fileIndex++;
     };//  while (data_file = fopen(file_name, "rb"))

     trc->trace_len = trc->idx_head.trace_len;
     trc->corosion_sens_num = trc->idx_head.num_sens;

     
 open_trace_counter++;
 // открыли трассу

 return trc;
} // T_OPENED_TRACE *createTrace(


/* 
 Функция возвращает указатель на трассу, соответствующую дескриптору handle 
 Если соотв.трасса не найдена, возвращается NULL, описание ошибки в drvError
*/
T_OPENED_TRACE * getTrace(KRTHANDLE handle) {
int i;

  if (open_trace_counter==0) {
   sprintf (drvError, "нет открытых трасс");
   return NULL;
  }

  // найдем открытую трассу в списке:
  for (i=0; i<open_trace_counter; i++) {
   if (handle == trace_list[i].handle) {
    return trace_list[i].trace;
   }
  }

  sprintf(drvError, "не найден handle %ld", handle);
  return NULL;
}