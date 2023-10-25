// krotepro.c - ������� epro_drv.
// ���������� ���������� ������ � ���� ���������������� ������� ��������
// ��������� ������ ������������ ����� "epro" ���������� KrotW32
//


#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//#include "krtapi.h"
#include "KrtAPI2.h"

#include "krotnano.h"


//#include "iniTool.c"
//#include "reciever.c"
//#include "thick.c"
//#include "fileTool.c"


// ������� ��������� ������ ��� ������ ���������
// (���� ����������� T_INQUIRY)
T_INQUIRY * WINAPI init_inquiry(long  cor_num,
                                long  dim_num)
{
   long i;
   T_INQUIRY *inquiry;


   // ������� ����� ��� ������ ���������
   inquiry = (T_INQUIRY *) malloc (sizeof(T_INQUIRY) * dim_num);
   if (inquiry == NULL) {
      sprintf(drvError, "��� ������ ��� ������ ���������(init_inquiry)");
      return inquiry;
    };

   // ������� ����� ��� ������ ����������� ���������
   inquiry->sens = (SENS_DATA *) malloc (sizeof(SENS_DATA)*cor_num * dim_num);
   if (inquiry->sens == NULL) {
      sprintf(drvError, "��� ������ ��� ������ ����������� ���������(init_inquiry)");
      free(inquiry);
      inquiry=NULL;
      return inquiry;
    };

   // ������� ����� ��� ������ �������������� ����������� ���������
   inquiry->math_sens = (SENS_DATA *) malloc (sizeof(SENS_DATA)*cor_num * dim_num);
   if (inquiry->sens == NULL) {
      sprintf(drvError, "��� ������ ��� ������  �������������� ����������� ���������(init_inquiry)");
      free(inquiry);
      inquiry=NULL;
      return inquiry;
    };

   // ����������������� ���� sens � math_sens � inquiry_data,
   // ������ ������� �������
   for (i=1; i<dim_num; i++) {
      inquiry[i].sens = inquiry[i-1].sens + cor_num;
      inquiry[i].math_sens = inquiry[i-1].math_sens + cor_num;
      inquiry[i].Thick = 0;
      inquiry[i].direct_prod_put = 0;
    };

   return inquiry;
}; // T_INQUIRY * WINAPI init_inquiry(long  cor_num,

// ������� ������������ ������ ��� �������� ���������
// (���� ���������� T_DESCRIPTOR_TEMPLATE)
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



// ���������� ��������� �� ������ ���� ���������� ... ��� NULL ��� ������
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
    // �������� �������
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
    // ��������� �������
*/
   }; // for dimension_counter

  return KRT_OK;
}; // long * smooth_data (T_INDEX_SEAM *p_seam,



long av_sens_median [MAX_DAT_VAL+1];

// ���������� KRT_OK
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

         // �������������� ������ ���� ��� ����
         if (P_trace->invert_sens_data[sens_counter]==0) {
           spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter] =
                    (MAX_DAT_VAL -
                    spin_info->item->sens[P_trace->idx_head.num_sens * (dimension_counter) + sens_counter]);
          };
       };
   }; // for (dimension_counter=0;


  // ������ ����������� ��� ���� ��������
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


        // ��������� �������� �������� ���������
        for (value_counter=0;
             value_counter <= MAX_DAT_VAL/2 - 2;
             value_counter+=2) 
        {
           av_sens_median [value_counter] += (av_sens_median [value_counter+1]);// + av_sens_median [value_counter-1]);
           av_sens_median [value_counter+1] = 0;
//           av_sens_median [value_counter-1] = 0;
        }


        // ���� ��������� ���������
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
  // ��������� ����������� ��� ���� ��������


  // ���������� ����������� ��������
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
  // ���������� ����������� �������� ���������

  return KRT_OK;
}; // long * Use_median_data (



// ������� ��������� ������ ��� ��������� �������� ������ 
//(���� ����������� T_OPENED_TRACE)
T_OPENED_TRACE * WINAPI init_opened_trace() {

  T_OPENED_TRACE *space_for_trace;
  long i;

  space_for_trace = (T_OPENED_TRACE *) malloc(sizeof(T_OPENED_TRACE));
  if (space_for_trace == NULL) {
     sprintf(drvError, "��� ������ ��� �������� ������(init_opened_trace)");
     return space_for_trace;
   };

  // ������� ���� ���� ��� ���������� ��������� (�� ������ ������)
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

  return space_for_trace;
}; // T_OPENED_TRACE * WINAPI init_opened_trace()

// ������� ������������ ������ ��� ���������� �������� ������
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



long Gary_not_arc( T_OPENED_TRACE *P_trace,
                   long spin_num,
                   T_SPIN_INFO * spin_info
                  ) 
{
  static long cur_file_idx = -1;
  static FILE * data_file = NULL;
  static char file_name[1024];

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

  u8   arc_buf [32*2*2];

  ARC_TABLE_REC arc_table [32*2];

  u8  src_table_rec;

  long lenght;

  long lenght_counter;

  T_Koord_data block_head;

  CORROSION_SENS_TYPE block_data [144 * 32];
  CORROSION_SENS_TYPE tmp_sort_data[MAX_CORROZION_NUM];

  long first_test_in_block = 0;

  long block_counter;

  long result_long;

  float length_divizor = 1.0;


  if ( cur_file_idx != P_trace->idx_trc[spin_num].file_num )
  {
      if ( data_file != NULL) {
          fclose (data_file);
          data_file = NULL;
      };

      cur_file_idx = P_trace->idx_trc[spin_num].file_num;

      sprintf(file_name, "%sd%05ld.cmp", P_trace->path_data, cur_file_idx);

      data_file = fopen(file_name, "rb");
      if (data_file == NULL) {
          sprintf(drvError, "������ �������� ����� %s.(Gary_not_arc) ", file_name);
          return KRT_ERR;
      };
  };

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

  fseek(data_file, P_trace->idx_trc[spin_num].shift_in_file, SEEK_SET);

  while (lenght_counter < lenght) {

      while(fread( &block_head, 1, sizeof(block_head), data_file) != sizeof(block_head))
      {
          fclose(data_file);
          data_file=NULL;

          cur_file_idx++;

          sprintf(file_name, "%sd%05ld.cmp", P_trace->path_data, cur_file_idx);

          data_file = fopen(file_name, "rb");
          if (data_file == NULL) {

              sprintf(drvError, "������ �������� ����� %s.(Gary_not_arc) ", file_name);
              return KRT_ERR;
          };

          fseek(data_file, sizeof(T_File_Head), SEEK_SET);

      }; // while(fread( &block_head, 1, sizeof(block_head), data_file) != sizeof(block_head))

      // ������ � ������������� ��������� ��������
      for (sens_counter = 0; sens_counter < P_trace->idx_head.num_sens; sens_counter++) {

          // ������ ������ ��������� ������� � �����
          repeat_counter=0;
          fread( &block_data[sens_counter],1,sizeof(CORROSION_SENS_TYPE),data_file);
          repeat_counter++;

          // ������ ������� ������ ������
          table_counter=0;
          while (repeat_counter < P_trace->idx_head.num_test_in_block) {
             fread( &src_table_rec, 1, sizeof(src_table_rec), data_file);

             arc_table[table_counter].num_repeat = (src_table_rec & 0xf0) >> 4;
             arc_table[table_counter].num_repeat++;
             arc_table[table_counter].num_bit = src_table_rec & 0xf;

            repeat_counter += arc_table[table_counter].num_repeat;
             table_counter++;
           }; // while (repeat_counter < NUM_TEST_IN_BLOCK)
          num_elem_in_table = table_counter;

          // ������� ���������� ���� ��������� ����� �������
          num_bit_in_arc = 0;
          for (table_counter=0; table_counter < num_elem_in_table; table_counter++) {
              num_bit_in_arc += arc_table[table_counter].num_repeat * arc_table[table_counter].num_bit;
           };

          num_byte_in_arc = num_bit_in_arc / NUM_BIT_IN_BYTE;
          if ( num_bit_in_arc % NUM_BIT_IN_BYTE)  num_byte_in_arc++;

          // ������ �������� ������
          fread( arc_buf, 1, num_byte_in_arc, data_file);

          bit_counter=0;
          test_counter = 1;
          for (table_counter=0; table_counter < num_elem_in_table; table_counter++) {

              for (repeat_counter = 0; repeat_counter < arc_table[table_counter].num_repeat; repeat_counter++) {
                 first_arc_byte_in_buf = bit_counter / NUM_BIT_IN_BYTE;
                 shift_bit_data = bit_counter % NUM_BIT_IN_BYTE;

                 sign = arc_buf[first_arc_byte_in_buf] + arc_buf[first_arc_byte_in_buf+1] * 256 +
                        arc_buf[first_arc_byte_in_buf+2] * 65536;// + arc_buf[first_arc_byte_in_buf+3] * 16777216;

                 sign  = sign << (32 - shift_bit_data - arc_table[table_counter].num_bit);
                 delta = sign & 0x7fffffff;
                 sign  = sign & 0x80000000;
                 sign  = sign >> 31;

                 delta = delta >> (32 - arc_table[table_counter].num_bit);

                 if (sign != 0) delta = -delta;

                 block_data[P_trace->idx_head.num_sens * test_counter + sens_counter] = (WORD)
                     (block_data[P_trace->idx_head.num_sens * (test_counter-1) + sens_counter] + delta);

                 test_counter++;
                 bit_counter += arc_table[table_counter].num_bit;
               }; // for repeat_counter
           }; // for table_counter

       }; // for sens_counter
      // ��������� � ��������������� ��������� ��������

      length_divizor = ( (float)lenght) / ( (float)spin_info->odo.length);

      // ��������� ������ � ������
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
      // ����������� ������ � ������

      first_test_in_block = 0;

      block_counter++;
      if (block_counter >= P_trace->idx_trc[spin_num].num_block_in_spin )
      {
         break;
      };

  };// while (length_counter < length)

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


  // ����������� ������
  for (test_counter = 0; test_counter < spin_info->itemNum ; test_counter++)
  {
      // ��� ����������
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
  // ������������� ������

  // �������� �������� ������ ����� 1 � 3-� �����
  if ( spin_info->item[0].direct_prod_put )
  {
      for (test_counter = 0;
           test_counter < spin_info->itemNum - 1;
           test_counter ++) 
      {

         for (sens_counter=1;
              sens_counter < 48;
              sens_counter+=2) 
          {
             spin_info->item[test_counter].sens[sens_counter] =
               spin_info->item[test_counter+1].sens[sens_counter];
          };

         for (sens_counter=96;
              sens_counter < 143;
              sens_counter+=2) 
          {
             spin_info->item[test_counter].sens[sens_counter] =
               spin_info->item[test_counter+1].sens[sens_counter];
          };

      };
  } else {
      for (test_counter = 0;
           test_counter < spin_info->itemNum - 1;
           test_counter ++) 
      {

         for (sens_counter=0;
              sens_counter < 47;
              sens_counter+=2) 
          {
             spin_info->item[test_counter].sens[sens_counter] =
               spin_info->item[test_counter+1].sens[sens_counter];
          };

         for (sens_counter=97;
              sens_counter < 144;
              sens_counter+=2) 
          {
             spin_info->item[test_counter].sens[sens_counter] =
               spin_info->item[test_counter+1].sens[sens_counter];
          };

      };
  };
  // �������� �������� ������ �����


  spin_info->odo.length *= P_trace->trace_step;

  spin_info->odo.start *= P_trace->trace_step;

  if (P_trace->Smooth_data_OFF == 0)
  {
     if (P_trace->Median_smooth>0)
     {
         Use_median_data( P_trace, spin_info );
     } else {
         smooth_data ( P_trace, spin_info);
     };

     // ����������������� 3 ����
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
     // ������������������� 3 ����
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


  return KRT_OK;
}; // long Gary_not_arc( ... )


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


// ������� ����������� ������� �������������� �������� �������� ������
// �������� ��������� ������, ������������ � ���� invert_sens_data_text 
// ��������� trc.
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
 
 // ��� ��������
 trc->trace_step = getTrcInt(file, TRACE_STEP_KEY, OUTER_STEP);

 // ���� �� ������� �������
 ret = getTrcItem(file, KEY_DATA, "");
 if (*ret == 0) {
   strcpy(trc->path_data, file);
   while((strlen(trc->path_data)>0) && (trc->path_data[strlen(trc->path_data)-1]!='\\')) {
     trc->path_data[strlen(trc->path_data)-1]=0;
   };
 } else {
   strcpy(trc->path_data, ret);
 };

 // ����������� ����� ������ (� �������� ����� � ������)
 trc->virtLength = getTrcInt(trc->file, KEY_DATLEN, INI_DATALEN_DFLT) * 1000;

 // ��� ������� ����� ������
 ret = getTrcItem(file, FIRST_FILE_NAME_KEY, "d00000.cmp");
 strcpy(trc->first_file_name, ret);

 // ������������ ��������� ��������� ��������� ������
 trc->max_data_code = getTrcInt(file, MAX_DATA_CODE_KEY, MAX_DAT_VAL);

 // �������� � ������ �����
 trc->Amplification_Group[0] = getTrcInt(file, Amplification_Group0_KEY, 4);
 trc->Amplification_Group[1] = getTrcInt(file, Amplification_Group1_KEY, 4);
 trc->Amplification_Group[2] = getTrcInt(file, Amplification_Group2_KEY, 4);

 // ���� ���������� ����������
 trc->Smooth_data_OFF = getTrcInt(file, Smooth_data_OFF_KEY, 0);

 // ����� ���� �����������
 trc->smooth_win_length = getTrcInt(file, Smooth_win_length_KEY, 8);

 // ���� ������������� ���������� ����������
 trc->Median_smooth = getTrcInt(file, Median_smooth_KEY, 0);

 // ������� �������������� �������� ��������
 ret = getTrcItem(file, Invert_sens_data_KEY, "");
 if (*ret != 0) {
  strcpy(trc->invert_sens_data_text, ret);
  setupInvertTable(trc);
 }

 // �������� ������� �������� ��������
 trc->razvorot_1_skanera = getTrcInt(file, razvorot_1_skanera_KEY, 0);
 trc->razvorot_2_skanera = getTrcInt(file, razvorot_2_skanera_KEY, 0);
 trc->razvorot_3_skanera = getTrcInt(file, razvorot_3_skanera_KEY, 0);

 trc->Skan_2_Shift = getTrcInt(file, Skan_2_Shift_KEY, 0);
 trc->Skan_3_Shift = getTrcInt(file, Skan_3_Shift_KEY, 0);


 ret = getTrcItem(file, KEY_SENS_STEP, "2.5");
 trc->sens_step = atof(ret);


  // ������ �� trc-����� ������������� ������ ������� �������
 for (i=0; i<MAX_CORROZION_NUM; i++) {
    sprintf(key_name, "%s%i", SENS_SORT_KEY, i);
    if (GetPrivateProfileString(EPRO_SECTION, key_name, "", key_value,
                                sizeof(key_value), trc->file) == 0)
     {
       sprintf (drvError, "������ ������ ���������� �� ����� %s.", trc->file);
       trc->sens_sort[i]=i;
     } else {
       trc->sens_sort[i]=atoi(key_value);
     };
  }; // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
 // ��������� �� trc-����� ������������� ������ ������� �������

 return KRT_OK;
} // long WINAPI read_data_from_trc


// ������� ������ ��������� ������ � ����
// ������� �������� �������� ������ � ��������� ��������� ������ �� �����
T_OPENED_TRACE * creation_trace(const char * trc_file) {
  T_OPENED_TRACE * new_trace;
  
//  char current_path[_MAX_PATH];

  new_trace = init_opened_trace();
  if (new_trace == NULL) {
     strcat(drvError, "(creation_trace)");
     return  NULL;
   };

  // �������� ��� ���� � �������� ������ ���� �� trc-����
  strcpy(new_trace->file, trc_file);

    // ������ �� trc-����� ������
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

 char data_path[_MAX_PATH]; // ���� �� ������ � �������

 long file_counter;
 FILE * data_file;
 char file_name[1024];

 T_ArrivedData info;


 // �������� �� ������������ handle
 if (handle<=0) {
  sprintf (drvError, "handle �� ������ ����(createTrace)");
  return NULL;
 }

 if (open_trace_counter>=MAX_TRACE) {
  sprintf (drvError, "��� ������� ������� ����� �����.(createTrace)");
  return NULL;
 }

 for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
  if (handle==trace_list[curent_trace].handle) {
   sprintf (drvError, "��������� ������������� handle.(createTrace)");
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

 // ���� �� ������� �������
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

 // ��������� ��� �������������
 if (!isFolderExist(path_data)) {
  sprintf(drvError, 
   "��������� � ����� %s ([%s]:%s) ������� %s �� ����������.",
   trc->file, 
   DRIVER_DATA, 
   KEY_DATA,
   path_data
   );
  return NULL;
 }

 // ��������� ����� ��������, ���� �� ����

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

     };//  while (data_file = fopen(file_name, "rb"))

     trc->trace_len = trc->idx_head.trace_len;
     trc->corosion_sens_num = trc->idx_head.num_sens;

     
 open_trace_counter++;
 // ������� ������

 return trc;
} // T_OPENED_TRACE *createTrace(


/* 
 ������� ���������� ��������� �� ������, ��������������� ����������� handle 
 ���� �����.������ �� �������, ������������ NULL, �������� ������ � drvError
*/
T_OPENED_TRACE * getTrace(KRTHANDLE handle) {
int i;

  if (open_trace_counter==0) {
   sprintf (drvError, "��� �������� �����");
   return NULL;
  }

  // ������ �������� ������ � ������:
  for (i=0; i<open_trace_counter; i++) {
   if (handle == trace_list[i].handle) {
    return trace_list[i].trace;
   }
  }

  sprintf(drvError, "�� ������ handle %ld", handle);
  return NULL;
}