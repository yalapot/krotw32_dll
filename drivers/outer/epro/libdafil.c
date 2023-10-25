// libdafil.c - �������� �������� epro_drv (� epro_reg).
// ���� ���������������� ������� ������ � ������� *.da ��� ��������
// ��������� ������ ������������ ����� "epro" ���������� KrotW32
//

#include <stdio.h>
#include <stdlib.h>

#include "winkrt.h"
#include "KrtAPI2.h"
#include "libdafil.h"
#include "krotepro.h"
#include "heapinsp.h"
#include "iniTool.h"

//#define CALL_LOG 1

#ifdef CALL_LOG

char tmp_log_str[1024];

#define LOG_FILE "c:\\epro_log.txt"

void Log(char *LogString) {
FILE *call_log;

 call_log = fopen(LOG_FILE, "at");
 fprintf(call_log, "%s\n", LogString);
 fclose(call_log);
}

#endif


long put_code_to_data_buf(

int code, 
T_CODE_SERCH_TABLE *P_code_table,
byte *P_data_buf, 
long *data_count,
long max_data_count

) {

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
} /* put_code_to_data_buf */


// arc_data - �������������� ������, arc_size - ������ �������� ������
// �  ������ (word), unarc_data - ��������� �� ������ ��������� ��� 
long unarc_lzw (

word *arc_data, 
int arc_size,
T_INDEX_SEAM *unarc_data, 
long corros_num

) {
   T_CODE_SERCH_TABLE P_code_table; //������� �����, �������� ����� ����������
   int  current_char;
   word current_code;
   word old_code;

   unsigned long i, j;

   word *P_code_cur;  // ��������� �� ������� ����� � ������ �����
   byte *P_data_buf;  // ���� ������� ����� ��� ����������������� ������ 
   byte *P_data_cur;  // ��������� �� ������� ����� � ����������������� ������

   long max_data_count; // ������ ������ ��� ����������������� ������
   long data_count=0;   // ������� ������ ����������������� ������

   int code_counter=arc_size; // ���������� �������� �����

   
   byte pred_znach; // ��� ������������� ������ � ������ ������� T_RECORD_OF_ONE_CYCLE_INQUIRY

   byte *P_arc_data; // ��������� �� ������� ����� � ����������������� ������
   byte *P_res_data; // ��������� �� ������� ����� � ������������� ������

   // ������� ����� ��� ����������������� ������
   // ������� �������� ����� ����� ���� ��� ����������������� ������
   max_data_count= unarc_data->head_of_condition_seam->real_dim * 
             (PADDING_F011_SIZE+(sizeof(SENS_DATA)*corros_num));

   // ������� ����� ��� ����������������� ������
   P_data_buf = heap_alloc(max_data_count+1);
   if (P_data_buf ==NULL) {
      sprintf(drvError, "��� ������ ��� ����������������� ������(unarc_lzw)");
      return KRT_ERR;
    };

// ������ LZW ���������������� 

   // ������� ������� �����
   for (i=0; i<SOURCE_TABLE_LEN; i++) {
     P_code_table.char_table[i].prefics = CLEARE_CODE;
     P_code_table.char_table[i].last_char = (byte) i;
    };

   P_code_table.char_table_len=SOURCE_TABLE_LEN;
   // �������� ������� �����

   P_code_cur = arc_data;
   P_data_cur = P_data_buf;

   old_code=*P_code_cur;
   current_char = put_code_to_data_buf(old_code, &P_code_table, P_data_cur, 
                                       &data_count, max_data_count);
   if (current_char<0) {
      sprintf(drvError, "�������� ������ ��������� (unarc_lzw)");
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
             sprintf(drvError, "�������� ������ ��������� (unarc_lzw)");
             return KRT_ERR;
           };
         }; /* if (code_counter!=1) */

       } else { /* if (*P_code_cur==CLEARE_CODE) */
         current_code = *P_code_cur;
         current_char = put_code_to_data_buf(current_code, &P_code_table,
                                             P_data_cur, &data_count, 
                                             max_data_count);
         if (current_char<0) {
            sprintf(drvError, "�������� ������ ��������� (unarc_lzw)");
            return KRT_ERR;
          };
         if (current_char==CLEARE_CODE) {
            current_char = put_code_to_data_buf(old_code, &P_code_table,
                                                P_data_cur, &data_count, 
                                                max_data_count);
            if (current_char<0) {
               sprintf(drvError, "�������� ������ ��������� (unarc_lzw)");
               return KRT_ERR;
             };
            P_data_cur[data_count] = (byte) current_char;
            if ( data_count < max_data_count) {
                data_count++;
             } else {
                sprintf(warnString, "array overflow in unarc");
                trcWarn(traceFile);
             };
          };

         P_code_table.char_table[P_code_table.char_table_len].prefics = old_code;
         P_code_table.char_table[P_code_table.char_table_len].last_char = (byte) current_char;
         P_code_table.char_table_len++;

         old_code=current_code;
       }; /* if (*P_code_cur==CLEARE_CODE) */

      P_code_cur++;
    }; /* for ( ; code_counter>0; code_counter--) */

// ��������� LZW ���������������� 
// ������ ����������������� ������ ���������� �� ��������� P_data_buf

// �������� ������������ ������ � ������ ������� T_RECORD_OF_ONE_CYCLE_INQUIRY

   // ������� ����� ��� �������� �������� ���������� ����������� �� �� �������
   unarc_data->inquiry = init_inquiry(corros_num,
                                      unarc_data->head_of_condition_seam->real_dim);

   if (unarc_data->inquiry == NULL) {
      strcat(drvError, "(unarc_lzw)");
      P_data_buf=heap_free(P_data_buf);
      return KRT_ERR;
    };

   // ��������� ��������� �� ������ "���������������" ������ 
   P_arc_data = P_data_buf;

   // ������������ ������ ������������� ���������

   // ��������� ��������� �� ������ ������� ������ 
   P_res_data = (byte *) unarc_data->inquiry;

   for (i=0; i<PADDING_F011_SIZE; i++) {
      pred_znach=0;
      P_data_cur = & P_res_data[i];

      for (j=0 ; j<unarc_data->head_of_condition_seam->real_dim; j++) {
          pred_znach  = (byte) (pred_znach + P_arc_data[0]);
          *P_data_cur = pred_znach;

          P_data_cur += sizeof(T_INQUIRY);
          P_arc_data++;
       };
    };

   // ������������ ������ ����������� ���������
   P_res_data = (byte *) unarc_data->inquiry->sens;

   for (i=0; i<(sizeof(SENS_DATA)*corros_num); i++) {
      pred_znach=0;
      P_data_cur = & P_res_data[i];

      for (j=0 ; j<unarc_data->head_of_condition_seam->real_dim; j++) {
          pred_znach = (byte) (pred_znach + P_arc_data[0]);
          *P_data_cur = (byte) pred_znach;

          P_data_cur += (sizeof(SENS_DATA) *corros_num);
          P_arc_data++;
       };
    };

   P_data_buf=heap_free(P_data_buf);

   return KRT_OK;
} // unarc_lzw 

long recalc_prod_put (

T_INDEX_SEAM *p_seam, 
byte *pred_src_prod_put,
long init_direct_prod_put,
long *next_direct_prod_put,
long init_beg_odom

) {
   dword i;
   byte cur_src_prod_put;
   long put_in_seam;

   long start_prod;
   long porerd_per_prod;



   start_prod = init_beg_odom;

   if (p_seam->inquiry[p_seam->head_of_condition_seam->real_dim-1].prod_put -
       p_seam->inquiry[0].prod_put > 0) 
    {
       porerd_per_prod = p_seam->head_of_condition_seam->real_dim /
                         (p_seam->inquiry[p_seam->head_of_condition_seam->real_dim-1].prod_put -
                          p_seam->inquiry[0].prod_put);
    } else {
       porerd_per_prod = p_seam->head_of_condition_seam->real_dim;
    };

   // ��������� ���������� ���� ������ ��� ���� ������ ������� ��������������
    put_in_seam=0;
    *next_direct_prod_put=init_direct_prod_put;
    for (i=0; i<p_seam->head_of_condition_seam->real_dim; i++) {
       cur_src_prod_put = *((byte*) &p_seam->inquiry[i].src_prod_put);
       if (cur_src_prod_put!=*pred_src_prod_put) {
           cur_src_prod_put-=1;
           if ( cur_src_prod_put == *pred_src_prod_put ) {
               put_in_seam+=1;
               *next_direct_prod_put = 1;
            };
           cur_src_prod_put+=2;
           if ( cur_src_prod_put == *pred_src_prod_put ) {
               put_in_seam+=1;
               *next_direct_prod_put = -1;
            };
        };
       p_seam->inquiry[i].prod_put = start_prod+(i/porerd_per_prod);
       p_seam->inquiry[i].direct_prod_put = *next_direct_prod_put;
       *pred_src_prod_put = *((byte*) &p_seam->inquiry[i].src_prod_put);;
     };

    p_seam->head_of_condition_seam->beg_odom = init_beg_odom;
    p_seam->beg_track = init_beg_odom;

    p_seam->head_of_condition_seam->end_odom = 
          p_seam->inquiry[p_seam->head_of_condition_seam->real_dim-1].prod_put;
    p_seam->end_track = 
          p_seam->inquiry[p_seam->head_of_condition_seam->real_dim-1].prod_put;
   // ��������� ���������� ���� ������ ��� ���� ������ ������� ��������������

   return KRT_OK;
}; // long recalc_prod_put (

// ���������� ����� ������ ����� ���� "XXnnnnn�XX":
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
             sprintf(drvError, "������ inc_file_name('%s')", file_name);
             return KRT_ERR;
           };
         };
       };
     };
   };
   return KRT_OK;
} /* inc_file_name(char *file_name) */


// ���������� ��������� �� ������ ���� ���������� ... ��� NULL ��� ������
long * Use_smooth_data (
                         T_INDEX_SEAM *p_seam,
                         T_OPENED_TRACE *opened_trace
                       ) 
 {
 
  int dimension_counter, sens_counter;
  int nuber_dimension_in_seam;

  long translate_res;

  static long average_sens[MAX_CORROZION_NUM];
  static long av_sens_old[MAX_SMOOTH_WIN_LENGTH][MAX_CORROZION_NUM];

  static long av_sens_len=1;
  long *P_average_sens;
  long *P_av_sens_old;

  hyper Averade_for_Thick;

  long tmp_value;

  word tmp_sens[MAX_CORROZION_NUM];

  static SENS_DATA pred_sens_data[96];

/*
  pred_sens_data = heap_alloc(opened_trace->corosion_sens_num * sizeof(SENS_DATA));

  for (sens_counter=0; sens_counter < opened_trace->corosion_sens_num; sens_counter++) {
     average_sens[sens_counter]=p_seam->smooth_data_beg[sens_counter];

     // ����������������� ������ ����������� ���������
     pred_sens_data [sens_counter] = p_seam->smooth_data_beg[sens_counter]/
                                     ( 256 *  opened_trace->smooth_win_length);
     // ������������������� ������ ����������� ���������

     for (av_sens_len=0;
          av_sens_len < opened_trace->smooth_win_length; 
          av_sens_len++)
      {
        av_sens_old[av_sens_len][sens_counter] = 
                    p_seam->smooth_data_beg[sens_counter]
                    /
                    opened_trace->smooth_win_length;
      };
   };
  av_sens_len=1;
*/
  nuber_dimension_in_seam = p_seam->head_of_condition_seam->real_dim;

  // ����������� ������
  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {
     for (sens_counter=0; 
          sens_counter < opened_trace->corosion_sens_num;
          sens_counter++) 
      {

        if(p_seam->inquiry[dimension_counter].sens[sens_counter] == 0){
            tmp_sens[opened_trace->sens_sort[sens_counter]] = 0;
         };

        // �������� �� �������
        if( (p_seam->inquiry[dimension_counter].sens[sens_counter] > 4090) ||
            (p_seam->inquiry[dimension_counter].sens[sens_counter] == 0 ) )
         {
            // ������� �������
            tmp_sens[opened_trace->sens_sort[sens_counter]] =
               pred_sens_data [sens_counter];
         } else {
            tmp_sens[opened_trace->sens_sort[sens_counter]] =
               p_seam->inquiry[dimension_counter].sens[sens_counter];
            pred_sens_data [sens_counter] = 
               p_seam->inquiry[dimension_counter].sens[sens_counter];
         };
      }; //for (sens_counter=0; 

     for (sens_counter=0; 
          sens_counter < opened_trace->corosion_sens_num;
          sens_counter++) 
      {
        p_seam->inquiry[dimension_counter].sens[sens_counter] =
           tmp_sens[sens_counter];

            #ifdef CALL_LOG
            if (sens_counter == 10) {
               sprintf(tmp_log_str, "%d",
                    p_seam->inquiry[dimension_counter].sens[sens_counter]);
               Log(tmp_log_str);
      };
            #endif

      };
   }; //for (dimension_counter=0;
  // ������������� ������

  // ������������� ������� ������� �������
  for (dimension_counter=0;
       dimension_counter < nuber_dimension_in_seam;
       dimension_counter++) 
   {
     if (opened_trace->razvorot_1_skanera!=0) {
         for (sens_counter = 0;
              sens_counter < (opened_trace->corosion_sens_num/2)/2;
              sens_counter++) 
          {
             tmp_value = p_seam->inquiry[dimension_counter].sens[sens_counter];
             p_seam->inquiry[dimension_counter].sens[sens_counter] =
                      p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)-1-sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)-1-sens_counter] =
                      (SENS_DATA) tmp_value;
          };
      };

     // ������������� ������� ������� �������
     if (opened_trace->razvorot_2_skanera!=0) {
         for (sens_counter = 0;
              sens_counter < (opened_trace->corosion_sens_num/2)/2;
              sens_counter++) 
          {
             tmp_value = p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2) + sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)+sens_counter]=
                      p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter] =
                      (SENS_DATA) tmp_value;
          };
      };
   }; //for (dimension_counter=0;


  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {
     // ������������� ������� ������� �������
     if (p_seam->inquiry[dimension_counter].direct_prod_put == -1) {
         for (sens_counter = 0;
              sens_counter < (opened_trace->corosion_sens_num/2)/2;
              sens_counter++) 
          {
             tmp_value=p_seam->inquiry[dimension_counter].sens[sens_counter];
             p_seam->inquiry[dimension_counter].sens[sens_counter]=
                      p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)-1-sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)-1-sens_counter] =
                      (SENS_DATA) tmp_value;
          };
      };

     // ������������� ������� ������� �������
     if (p_seam->inquiry[dimension_counter].direct_prod_put == -1) {
         for (sens_counter = 0;
              sens_counter < (opened_trace->corosion_sens_num/2)/2;
              sens_counter++) 
          {
             tmp_value=p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)+sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)+sens_counter]=
                      p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter] =
                      (SENS_DATA) tmp_value;
          };
      };
   }; //for (dimension_counter=0;

/*
// ������� ������� ��������

  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {
    for (sens_counter = 0;
         sens_counter < (opened_trace->corosion_sens_num/2);
         sens_counter+=2) 
     {
//         p_seam->inquiry[dimension_counter].sens[sens_counter]=
//           p_seam->inquiry[dimension_counter].sens[sens_counter+1];
         p_seam->inquiry[dimension_counter].sens[sens_counter+(opened_trace->corosion_sens_num/2)]=
           p_seam->inquiry[dimension_counter].sens[sens_counter+(opened_trace->corosion_sens_num/2)+1];
     };
   }; //for (dimension_counter=0;

// ����� ������� ��������
*/


  // �������� �������� ������ �����
  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam-1;
       dimension_counter++) 
   {
     for (sens_counter=1;
          sens_counter < opened_trace->corosion_sens_num/2;
          sens_counter+=2) 
      {
         p_seam->inquiry[dimension_counter].sens[sens_counter] =
           p_seam->inquiry[dimension_counter + 1].sens[sens_counter];

      };

   }; // for (dimension_counter=0;
  // �������� �������� ������ �����

/*
  // �������� ������� ����� ��������� ������� ����� ��������� ����
  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {
      for (sens_counter = opened_trace->corosion_sens_num/2-1;
           sens_counter >= 2;
           sens_counter--) 
       {
           p_seam->inquiry[dimension_counter].sens[sens_counter]=
             p_seam->inquiry[dimension_counter].sens[sens_counter-2];

           p_seam->inquiry[dimension_counter].sens[sens_counter+(opened_trace->corosion_sens_num/2)]=
             p_seam->inquiry[dimension_counter].sens[sens_counter+(opened_trace->corosion_sens_num/2)-2];
       };
   };
  // �������� ������� ����� ��������� ������� ����� ��������� ����
*/

  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {
     av_sens_len--;
     if (av_sens_len<0) av_sens_len = opened_trace->smooth_win_length-1;
     P_average_sens = average_sens;
     P_av_sens_old  = &av_sens_old[av_sens_len][0];


     for (sens_counter=0; 
          sens_counter < opened_trace->corosion_sens_num; 
          sens_counter++) 
      {

        // �������������� ������ ���� ��� ����
        if (opened_trace->invert_sens_data[sens_counter]!=0) {
           p_seam->inquiry[dimension_counter].sens[sens_counter] = (word)
                    (opened_trace->max_data_code -         
                    p_seam->inquiry[dimension_counter].sens[sens_counter]);
         };

        translate_res = p_seam->inquiry[dimension_counter].sens[sens_counter];

        translate_res *= 256;
        *P_average_sens -= *P_av_sens_old;

        *P_average_sens += translate_res;
        *P_av_sens_old = *P_average_sens;

        *P_av_sens_old  /= opened_trace->smooth_win_length;
        *P_average_sens -= translate_res;
        *P_average_sens += *P_av_sens_old;

        translate_res -= *P_av_sens_old;

        if (sens_counter < (opened_trace->corosion_sens_num/2)) {
            translate_res*=opened_trace->Amplification_Group[0];
         } else {
            translate_res*=opened_trace->Amplification_Group[1];
         };

        translate_res /= 256;

        translate_res += opened_trace->max_data_code/2;

        if (translate_res>opened_trace->max_data_code) {
            translate_res=opened_trace->max_data_code;
         } else {
            if (translate_res<0) translate_res=0;
         };

        if (opened_trace->Smooth_data_OFF==0) {
            p_seam->inquiry[dimension_counter].math_sens[sens_counter] = 
                (SENS_DATA) translate_res;
         } else {
            p_seam->inquiry[dimension_counter].math_sens[sens_counter] = 
                p_seam->inquiry[dimension_counter].sens[sens_counter];
         };

        P_average_sens++;
        P_av_sens_old++;
      }; // for sens_counter


     // ��������� �������
     Averade_for_Thick=0;
     for (sens_counter=0; 
          sens_counter<opened_trace->corosion_sens_num;
          sens_counter++) 
      {
         Averade_for_Thick+=average_sens[sens_counter];
      };
     p_seam->inquiry[dimension_counter].Thick = (word)
             (Averade_for_Thick
             /
             ( 256 * opened_trace->corosion_sens_num
               *
               opened_trace->smooth_win_length
             ));
     // ��������� �������

   }; // for dimension_counter

  return average_sens;
} // long * Use_smooth_data (


long av_sens_median [MAX_DAT_VAL+1];

// ���������� ��������� �� ������ ���� ���������� ... ��� NULL ��� ������
long * Use_median_data (
                         T_INDEX_SEAM *p_seam,
                         T_OPENED_TRACE *opened_trace
                       ) 
 {
 
  int dimension_counter, sens_counter;
  int nuber_dimension_in_seam;

  static long average_sens[MAX_CORROZION_NUM];

  hyper Averade_for_Thick;

  long tmp_value;

  word tmp_sens[MAX_CORROZION_NUM];
  word tmp_sens2[MAX_CORROZION_NUM];

  int value_counter;
  long median_val_count[MAX_CORROZION_NUM];


  memset(median_val_count, 0, MAX_CORROZION_NUM * sizeof(long) );
  memset(average_sens, 0, MAX_CORROZION_NUM * sizeof(long) );

  nuber_dimension_in_seam = p_seam->head_of_condition_seam->real_dim;


  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {
     Averade_for_Thick = 0;
     for (sens_counter=0; 
          sens_counter < opened_trace->corosion_sens_num; 
          sens_counter++) 
      {

         if (p_seam->inquiry[dimension_counter].sens[sens_counter]>=4095) {
             p_seam->inquiry[dimension_counter].sens[sens_counter] = 
	         p_seam->inquiry[dimension_counter].sens[sens_counter] & 0xfff;
         };

         // �������������� ������ ���� ��� ����
         if (opened_trace->invert_sens_data[sens_counter]!=0) {
            p_seam->inquiry[dimension_counter].sens[sens_counter] = (word)
                    (opened_trace->max_data_code -
                    p_seam->inquiry[dimension_counter].sens[sens_counter]);
          };
       };
   };


  // ������ ����������� ��� ���� ��������
  for (sens_counter=0;
       sens_counter < opened_trace->corosion_sens_num; 
       sens_counter++) 
   {
       memset(av_sens_median, 0, (MAX_DAT_VAL+1) * sizeof(long) );
       for (dimension_counter=0;
            dimension_counter < nuber_dimension_in_seam;
            dimension_counter++) 
        {
            av_sens_median [p_seam->inquiry[dimension_counter].sens[sens_counter]] ++;
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
        for (value_counter=0;
             value_counter <= MAX_DAT_VAL;
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
   }; //   for (sens_counter=0; 
  // ��������� ����������� ��� ���� ��������


  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {
     Averade_for_Thick = 0;
     for (sens_counter=0; 
          sens_counter < opened_trace->corosion_sens_num; 
          sens_counter++) 
      {
         // ��������� �������
         Averade_for_Thick += average_sens[sens_counter];
      };
     p_seam->inquiry[dimension_counter].Thick = (word)
             (Averade_for_Thick / opened_trace->corosion_sens_num );
   };


  // ���������� ����������� ��������
  for (sens_counter=0; 
       sens_counter < opened_trace->corosion_sens_num; 
       sens_counter++) 
   {
      average_sens[sens_counter]-=(opened_trace->max_data_code/2);

      for (dimension_counter=0;
           dimension_counter<nuber_dimension_in_seam;
           dimension_counter++) 
       {
            p_seam->inquiry[dimension_counter].math_sens[sens_counter] = (word)
                       ( p_seam->inquiry[dimension_counter].sens[sens_counter]
                         -
                         average_sens[sens_counter]);

            if (sens_counter < (opened_trace->corosion_sens_num/2)) {
                p_seam->inquiry[dimension_counter].math_sens[sens_counter] = (word)
                     ( (opened_trace->max_data_code/2) +
                       (p_seam->inquiry[dimension_counter].math_sens[sens_counter]
                        -
                        (opened_trace->max_data_code/2)
                       ) * opened_trace->Amplification_Group[0] / 2);
             } else {
                p_seam->inquiry[dimension_counter].math_sens[sens_counter] = (word)
                     ( (opened_trace->max_data_code/2) +
                       (p_seam->inquiry[dimension_counter].math_sens[sens_counter]
                         -
                        (opened_trace->max_data_code/2)
                       ) * opened_trace->Amplification_Group[1] / 2);
             };
       }; // for dimension_counter
   }; // for sens_counter
  // ���������� ����������� �������� ���������


  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {
     // ����������� ������
     for (sens_counter=0; 
          sens_counter < opened_trace->corosion_sens_num;
          sens_counter++) 
      {
        tmp_sens[opened_trace->sens_sort[sens_counter]] =
           p_seam->inquiry[dimension_counter].sens[sens_counter];

        tmp_sens2[opened_trace->sens_sort[sens_counter]] =
           p_seam->inquiry[dimension_counter].math_sens[sens_counter];
      };

     for (sens_counter=0; 
          sens_counter < opened_trace->corosion_sens_num;
          sens_counter++) 
      {
        p_seam->inquiry[dimension_counter].sens[sens_counter] =
           tmp_sens[sens_counter];

        p_seam->inquiry[dimension_counter].math_sens[sens_counter] =
           tmp_sens2[sens_counter];
      };
     // ������������� ������

     // ������������� ������� ������� �������
     if (opened_trace->razvorot_1_skanera!=0) {
         for (sens_counter = 0;
              sens_counter < (opened_trace->corosion_sens_num/2)/2;
              sens_counter++) 
          {
             tmp_value=p_seam->inquiry[dimension_counter].sens[sens_counter];
             p_seam->inquiry[dimension_counter].sens[sens_counter]=
                      p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)-1-sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)-1-sens_counter] =
                      (SENS_DATA) tmp_value;

             tmp_value=p_seam->inquiry[dimension_counter].math_sens[sens_counter];
             p_seam->inquiry[dimension_counter].math_sens[sens_counter]=
                      p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)-1-sens_counter];
             p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)-1-sens_counter] =
                      (SENS_DATA) tmp_value;
          };
      };

     // ������������� ������� ������� �������
     if (opened_trace->razvorot_2_skanera!=0) {
         for (sens_counter = 0;
              sens_counter < (opened_trace->corosion_sens_num/2)/2;
              sens_counter++) 
          {
             tmp_value=p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)+sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)+sens_counter]=
                      p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter] =
                      (SENS_DATA) tmp_value;

			 tmp_value=p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)+sens_counter];
             p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)+sens_counter]=
                      p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter];
             p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter] =
                      (SENS_DATA) tmp_value;
          };
      };

     // ������������� ������� ������� �������
     if (p_seam->inquiry[dimension_counter].direct_prod_put == -1) {
         for (sens_counter = 0;
              sens_counter < (opened_trace->corosion_sens_num/2)/2;
              sens_counter++) 
          {
             tmp_value=p_seam->inquiry[dimension_counter].sens[sens_counter];
             p_seam->inquiry[dimension_counter].sens[sens_counter]=
                      p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)-1-sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)-1-sens_counter] =
                      (SENS_DATA) tmp_value;

			 tmp_value=p_seam->inquiry[dimension_counter].math_sens[sens_counter];
             p_seam->inquiry[dimension_counter].math_sens[sens_counter]=
                      p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)-1-sens_counter];
             p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)-1-sens_counter] =
                      (SENS_DATA) tmp_value;
          };
      };

     // ������������� ������� ������� �������
     if (p_seam->inquiry[dimension_counter].direct_prod_put == -1) {
         for (sens_counter = 0;
              sens_counter < (opened_trace->corosion_sens_num/2)/2;
              sens_counter++) 
          {
             tmp_value=p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)+sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)+sens_counter]=
                      p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter];
             p_seam->inquiry[dimension_counter].sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter] =
                      (SENS_DATA) tmp_value;

			 tmp_value=p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)+sens_counter];
             p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)+sens_counter]=
                      p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter];
             p_seam->inquiry[dimension_counter].math_sens[(opened_trace->corosion_sens_num/2)*2-1-sens_counter] =
                      (SENS_DATA) tmp_value;
          };
      };

// ������� ������� ��������
/*    for (sens_counter = 0;
         sens_counter < (opened_trace->corosion_sens_num/2);
         sens_counter+=2) 
     {
         p_seam->inquiry[dimension_counter].sens[sens_counter]=
           p_seam->inquiry[dimension_counter].sens[sens_counter+1];
         p_seam->inquiry[dimension_counter].sens[sens_counter+(opened_trace->corosion_sens_num/2)]=
           p_seam->inquiry[dimension_counter].sens[sens_counter+(opened_trace->corosion_sens_num/2)+1];

         p_seam->inquiry[dimension_counter].math_sens[sens_counter]=
           p_seam->inquiry[dimension_counter].math_sens[sens_counter+1];
         p_seam->inquiry[dimension_counter].math_sens[sens_counter+(opened_trace->corosion_sens_num/2)]=
           p_seam->inquiry[dimension_counter].math_sens[sens_counter+(opened_trace->corosion_sens_num/2)+1];
     };
*/
// ����� ������� ��������

   };

/*
  // �������� �������� ������ �����
  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam-1;
       dimension_counter++) 
   {
     for (sens_counter=1;
          sens_counter < opened_trace->corosion_sens_num/2;
          sens_counter+=2) 
      {
         p_seam->inquiry[dimension_counter].sens[sens_counter] =
           p_seam->inquiry[dimension_counter+1].sens[sens_counter];

         p_seam->inquiry[dimension_counter].math_sens[sens_counter] =
           p_seam->inquiry[dimension_counter+1].math_sens[sens_counter];
      };

   };
  // �������� �������� ������ �����
*/
  // �������� ������� ����� ��������� ������� ����� ��������� ����
/*  for (dimension_counter=0;
       dimension_counter<nuber_dimension_in_seam;
       dimension_counter++) 
   {
      for (sens_counter = opened_trace->corosion_sens_num/2-1;
           sens_counter >= 2;
           sens_counter--) 
       {
           p_seam->inquiry[dimension_counter].sens[sens_counter]=
             p_seam->inquiry[dimension_counter].sens[sens_counter-2];

           p_seam->inquiry[dimension_counter].sens[sens_counter+(opened_trace->corosion_sens_num/2)]=
             p_seam->inquiry[dimension_counter].sens[sens_counter+(opened_trace->corosion_sens_num/2)-2];

			 
		   p_seam->inquiry[dimension_counter].math_sens[sens_counter]=
             p_seam->inquiry[dimension_counter].math_sens[sens_counter-2];

           p_seam->inquiry[dimension_counter].math_sens[sens_counter+(opened_trace->corosion_sens_num/2)]=
             p_seam->inquiry[dimension_counter].math_sens[sens_counter+(opened_trace->corosion_sens_num/2)-2];
       };
   };
*/  // �������� ������� ����� ��������� ������� ����� ��������� ����

  return average_sens;
}; // long * Use_median_data (



long enumerate_work_files( 

char *first_File, 
long *data_path_len,
long *files_num

) {

  char path_first_file[_MAX_PATH];
  FILE *cur_file;
  
  // ��������� ������ ������ ���� �� ������� ����� (��� �����)
  strcpy(path_first_file, first_File);
  *data_path_len=strlen(path_first_file);

  while ((*data_path_len>0) && (path_first_file[*data_path_len-1]!='\\')) {
    path_first_file[(*data_path_len)-1]=0;
    (*data_path_len)--;
   };
  // ��������� ������ ������ ���� �� ������� ����� (��� �����)

  *files_num=0;
  strcat(path_first_file, &first_File[*data_path_len]);

  while ((cur_file=fopen(path_first_file, "rb")) !=NULL) {
     fclose(cur_file);
     (*files_num)++;
     if (inc_file_name(&path_first_file[*data_path_len])!= KRT_OK ){
        strcat(drvError, "(enumerate_work_files)");
        return KRT_ERR;
      };
   }; // while ( (trace_list.trace->file_data=fopen(current_file_data, "rb") !=NULL) {

  return KRT_OK;
} // long WINAPI enumerate_work_files(

long enumerate_seam_in_files( T_INDEX_FILE *index_file) { 

  long read_res;         // ���-�� ������ ����������� fread
  long pos_in_file;      // � ����� ����� ����� ���������

  T_DESCRIPTOR cur_descriptor; // ������ ����������� �����
  T_SEAM cur_seam;

  T_FILE_HEADER file_header;

  // ������� ���� ������
  index_file->file_data = fopen(index_file->file_name, "rb");
  if (index_file->file_data ==NULL) {
    sprintf (drvError, "������ �������� ����� %s(enumerate_seam_in_files)", index_file->file_name);
    return KRT_ERR;
   };

  // ��������� ��������� �����
  read_res=fread(&file_header, 1, sizeof(T_FILE_HEADER), index_file->file_data);

  if (read_res != sizeof(T_FILE_HEADER)) {
    sprintf (drvError, "������ ������ ��������� ����� %s(enumerate_seam_in_files)", index_file->file_name);
    fclose(index_file->file_data);
    index_file->file_data =NULL;
    return KRT_ERR;
   };
  pos_in_file=read_res;

  index_file->num_condition_seam=0;
  // ���� ���� �� ����������, ����� ������ � ������������� ���. ���
  while((read_res=fread(&cur_descriptor, 1, sizeof(T_DESCRIPTOR), index_file->file_data) 
        ) ==  sizeof(T_DESCRIPTOR))
   {
      pos_in_file+=read_res;

      if (cur_descriptor.ver_file==VER_FILE_VNSHN) {
         switch (cur_descriptor.descriptor_type) {
            case (DESCRIPTOR_CONDITION_SEAM): {
               if (cur_descriptor.descriptor_Size!=sizeof(T_SEAM)+sizeof(T_DESCRIPTOR))
                {
                  sprintf (drvError, "������ ������� ����� %s(enumerate_seam_in_files)", index_file->file_name);
                  fclose(index_file->file_data);
                  index_file->file_data =NULL;
                  return KRT_ERR;
                };
              if((read_res=fread(&cur_seam, 1, sizeof(T_SEAM), index_file->file_data) 
                    ) ==  sizeof(T_SEAM)) {
                   pos_in_file+=read_res;
                   index_file->num_condition_seam++;
                   pos_in_file+=cur_seam.arc_size;
                   fseek (index_file->file_data, pos_in_file, SEEK_SET);
                   break;
                } else {
                  sprintf (drvError, "������ ������ ���. ��� %s(enumerate_seam_in_files)", index_file->file_name);
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
                  sprintf (drvError, "������ ������ ������ ����������� %s(enumerate_seam_in_files)", index_file->file_name);
                  fclose(index_file->file_data);
                  index_file->file_data =NULL;
                  return KRT_ERR;
                };
             }; // case (DESCRIPTOR_END_STOP):

            default : {
               sprintf (drvError, "����������� ����������(enumerate_seam_in_files)");
               fclose(index_file->file_data);
               index_file->file_data =NULL;
               return KRT_ERR;
             }; // default :

          }; // switch (cur_descriptor.descriptor_type)

       } else { // if (cur_descriptor.ver_file==VER_FILE_VNSHN)
         sprintf (drvError, "����������� ������ �����(enumerate_seam_in_files)");
         fclose(index_file->file_data);
         index_file->file_data =NULL;
         return KRT_ERR;
       }; // if (cur_descriptor.ver_file==VER_FILE_VNSHN)

      fseek (index_file->file_data, pos_in_file, SEEK_SET);
   }; // while(fread( &cur_descriptor, 1,

  // ������� ���� ������
  fclose(index_file->file_data);
  index_file->file_data = NULL;

  return KRT_OK;
} // long WINAPI enumerate_seam_in_files(

// 
long calkulate_index_files_and_sems(

T_OPENED_TRACE *opened_trace,
long file_counter

) {

  static long pred_cur_orient;
  static long smooth_beg[MAX_CORROZION_NUM];
  long *smooth_data_result;

  unsigned long read_res;         // ���-�� ������ ����������� fread
  unsigned long sum_read_res;

  long pos_in_file;      // � ����� ����� ����� ���������
  long seam_counter;     // ������� ���. ���
  long sens_counter;

  static  long global_seam_counter=0;

  T_DESCRIPTOR cur_descriptor; // ������ �����������

  T_FILE_HEADER file_header;

  word *arc_data;

  T_INDEX_FILE *index_file;

  index_file = &opened_trace->file_index[file_counter];

  // ������� ���� ������
  index_file->file_data = fopen(index_file->file_name, "rb");
  if (index_file->file_data ==NULL) {
    sprintf (drvError, "������ �������� ����� %s(calkulate_index_files_and_sems)", index_file->file_name);
    return KRT_ERR;
   };

  // ��������� ��������� �����
  read_res=fread(&file_header, 1, sizeof(T_FILE_HEADER), index_file->file_data);

  if (read_res != sizeof(T_FILE_HEADER)) {
    sprintf (drvError, "������ ������ ��������� ����� %s(calkulate_index_files_and_sems)", index_file->file_name);
    fclose(index_file->file_data);
    index_file->file_data =NULL;
    return KRT_ERR;
   };
  pos_in_file=read_res;

  // �������� ���� ���������� �������� � ������� ����������:
  // �������� ���� ��� ��� � �������������, ����� ��������
  // �� ���������� ������, �� ���� � ��� ������.
  opened_trace->corosion_sens_num = file_header.cor_num;
  opened_trace->frequency_processor = (dword) file_header.proc_frequency;

  opened_trace->sensInGroup = opened_trace->corosion_sens_num / 2; // !!! ����� ����� �� outer.ini

  seam_counter=0;
  // ���� ���� �� ����������, ����� ������ � �������������
  while((read_res=fread(&cur_descriptor, 1, sizeof(T_DESCRIPTOR), index_file->file_data) 
        ) ==  sizeof(T_DESCRIPTOR))
   {
      sum_read_res=read_res;
      if (cur_descriptor.ver_file==VER_FILE_VNSHN) {
         switch (cur_descriptor.descriptor_type) {
            case (DESCRIPTOR_CONDITION_SEAM): {
               if (cur_descriptor.descriptor_Size!=sizeof(T_SEAM)+sizeof(T_DESCRIPTOR))
                {
                  sprintf (drvError, "������ ������� ����� %s(calkulate_index_files_and_sems)", index_file->file_name);
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
                                  1, sizeof(T_SEAM), index_file->file_data
                                 ) 
                  ) !=  sizeof(T_SEAM)) 
                {
                  sprintf (drvError, "������ ������ ���. ��� %s(calkulate_index_files_and_sems)", index_file->file_name);
                  fclose(index_file->file_data);
                  index_file->file_data =NULL;
                  return KRT_ERR;
                };
               sum_read_res+=read_res;

               // �������� ������ ��������� �� ����������� ���-�� ��������
               init_bort_factor_data (opened_trace);

               index_file->index_seam[seam_counter].global_number_seam =
                       global_seam_counter;
               index_file->index_seam[seam_counter].shift_in_file=pos_in_file;

               pos_in_file+=sum_read_res;

               // � ��� ���� ���� ��������� �����, ���������������, ����������
               // � ��������� trace_info
               arc_data=(word *) heap_alloc(index_file->index_seam[seam_counter].head_of_condition_seam->arc_size);

               if (arc_data==NULL) {
                  sprintf (drvError, "������ ��������� ������ ��� �������� ������(calkulate_index_files_and_sems)");
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
                  sprintf (drvError, "������ ������ �����(calkulate_index_files_and_sems)");
                  index_file->index_seam[seam_counter].head_of_condition_seam = 
                          free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);
                  arc_data=heap_free(arc_data);
                  fclose(index_file->file_data);
                  index_file->file_data =NULL;
                  return KRT_ERR;
                };

               pos_in_file+=index_file->index_seam[seam_counter].head_of_condition_seam->arc_size;

               // ������������� ������
               if (unarc_lzw(arc_data, 
                             index_file->index_seam[seam_counter].head_of_condition_seam->arc_size/2, 
                             &index_file->index_seam[seam_counter],
                             opened_trace->corosion_sens_num
                            )
                    == KRT_ERR) 
                {
                  strcat (drvError, "(calkulate_index_files_and_sems)");
                  arc_data=heap_free(arc_data);

                  // ��������� ���� �������� ���
                  index_file->index_seam[seam_counter].inquiry =
                       free_inquiry(index_file->index_seam[seam_counter].inquiry);

                  index_file->index_seam[seam_counter].head_of_condition_seam = 
                          free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);
                  fclose(index_file->file_data);
                  index_file->file_data =NULL;
                  return KRT_ERR;
                };
               // ��������������� ������ 

               arc_data=heap_free(arc_data);

               if (seam_counter==0) {
                  if ( file_counter==0 ) {
                      index_file->index_seam[seam_counter].start_seam = 0;
                      index_file->index_seam[seam_counter].pred_src_prod_put=0;
                      index_file->index_seam[seam_counter].init_direct_prod_put=1;
                   } else {
                      index_file->index_seam[seam_counter].start_seam =
                          opened_trace->file_index[file_counter-1].index_seam[opened_trace->file_index[file_counter-1].num_condition_seam-1].end_track;
                      index_file->index_seam[seam_counter].pred_src_prod_put=
                          opened_trace->file_index[file_counter-1].index_seam[opened_trace->file_index[file_counter-1].num_condition_seam-1].pred_src_prod_put;
                      index_file->index_seam[seam_counter].init_direct_prod_put=
                         opened_trace->file_index[file_counter-1].index_seam[0].next_direct_prod_put;
                   };
                } else {
                   index_file->index_seam[seam_counter].start_seam =
                       index_file->index_seam[seam_counter-1].end_track;
                   index_file->index_seam[seam_counter].pred_src_prod_put=
                       index_file->index_seam[seam_counter-1].pred_src_prod_put;
                   index_file->index_seam[seam_counter].init_direct_prod_put=
                      index_file->index_seam[seam_counter-1].next_direct_prod_put;
                };

               if (recalc_prod_put (&index_file->index_seam[seam_counter],
                                    &index_file->index_seam[seam_counter].pred_src_prod_put,
                                    index_file->index_seam[seam_counter].init_direct_prod_put,
                                    &index_file->index_seam[seam_counter].next_direct_prod_put,
                                    index_file->index_seam[seam_counter].start_seam
                                   )
                    ==KRT_ERR 
                  )
                {
                  strcat (drvError, "(calkulate_index_files_and_sems)");
                  // ��������� ���� �������� ���
                  index_file->index_seam[seam_counter].inquiry =
                       free_inquiry(index_file->index_seam[seam_counter].inquiry);

                  index_file->index_seam[seam_counter].head_of_condition_seam = 
                          free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);
                  fclose(index_file->file_data);
                  index_file->file_data =NULL;
                  return KRT_ERR;
                };

               index_file->index_seam[seam_counter].beg_track = 
                       index_file->index_seam[seam_counter].head_of_condition_seam->beg_odom;
               index_file->index_seam[seam_counter].end_track =
                       index_file->index_seam[seam_counter].head_of_condition_seam->end_odom;

               if (seam_counter==0) {  // ���� ��� ������ ��������� ���.���
                  // ������� ������ ������ � ����� �� ������ ������
                  index_file->beg_track =
                     index_file->index_seam[seam_counter].head_of_condition_seam->beg_odom;
                };

               if (seam_counter == index_file->num_condition_seam-1) { // ���� ��� ��������� ��������� ���.���
                  // ������� ����� ������ � ����� �� ������ ������
                  index_file->end_track=index_file->index_seam[seam_counter].head_of_condition_seam->end_odom;
                };
                // ������ �� ���� ����������

               // �������������� �����
               // ����� ������� ��������� � ���. ���
               index_file->index_seam[seam_counter].beg_time =
                   index_file->index_seam[seam_counter].inquiry[0].takt_in_ADC;
               index_file->index_seam[seam_counter].beg_time *= 32768;
               index_file->index_seam[seam_counter].beg_time /= 59659;
               index_file->index_seam[seam_counter].beg_time *= 100;
               index_file->index_seam[seam_counter].beg_time /=
                                            opened_trace->frequency_processor;
               
               // ����� ���������� ��������� � ���. ���
               index_file->index_seam[seam_counter].end_time =
                   index_file->index_seam[seam_counter].inquiry[
                     index_file->index_seam[seam_counter].head_of_condition_seam->real_dim-1
                    ].takt_in_ADC;
               index_file->index_seam[seam_counter].end_time *= 32768;
               index_file->index_seam[seam_counter].end_time /= 59659;
               index_file->index_seam[seam_counter].end_time *= 100;
               index_file->index_seam[seam_counter].end_time /=
                                            opened_trace->frequency_processor;
               // ���������������� �����

               // �������������� ��������� �������� �����������
               index_file->index_seam[seam_counter].smooth_data_beg = 
                         init_smooth_data_beg(opened_trace->corosion_sens_num);
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

               smooth_data_result = 
                       Use_smooth_data( &index_file->index_seam[seam_counter],
                                        opened_trace
                                      );
               if (smooth_data_result  == NULL) 
                {
                  strcat (drvError, "(calkulate_index_files_and_sems)");

                  // ��������� ���� �������� ���
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
                  smooth_beg[sens_counter] = smooth_data_result[sens_counter];
                };
               // ���������������� ��������� �������� �����������


               // ����� ����������

               // ��������� ������������������ �������� ��� �� ������
               index_file->index_seam[seam_counter].inquiry = 
                  free_inquiry(index_file->index_seam[seam_counter].inquiry);
               if (index_file->index_seam[seam_counter].inquiry != NULL) {
                  strcat (drvError, "(calkulate_index_files_and_sems)");
                  arc_data=heap_free(arc_data);

                  fclose(index_file->file_data);
                  index_file->file_data =NULL;

                  index_file->index_seam[seam_counter].head_of_condition_seam=
                         free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);

                  return KRT_ERR;
                };

               index_file->index_seam[seam_counter].head_of_condition_seam = 
                       free_condition_seam(index_file->index_seam[seam_counter].head_of_condition_seam);
               // ���������� ������������������ �������� ��� �� ������
               // ��� ���� ���� smooth_data_beg �� � ���� ������ �� �������
               // �.�. ��� ���� �������

               seam_counter++;
               global_seam_counter++;
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
               sprintf (drvError, "����������� ����������(calkulate_index_files_and_sems)");
               fclose(index_file->file_data);
               index_file->file_data =NULL;
               return KRT_ERR;
             }; // default :
          }; // switch (cur_descriptor.descriptor_type)
       } else { // if (cur_descriptor.ver_file==VER_FILE_VNSHN)
         sprintf (drvError, "������ ������ �����(calkulate_index_files_and_sems)");
         fclose(index_file->file_data);
         index_file->file_data =NULL;
         return KRT_ERR;
       }; // if (cur_descriptor.ver_file==VER_FILE_VNSHN)

    sum_read_res=0;
   }; // while(fread( &cur_descriptor, 1, DESCRIPTOR_LEN

  if (seam_counter != index_file->num_condition_seam) {
     // ���������� ���������� ����������� �� ��� ���. ���
     sprintf (drvError, "������ ��������� ���. ����(calkulate_index_files_and_sems)");
     fclose(index_file->file_data);
     index_file->file_data = NULL;
     return KRT_ERR;
   };
  //���� ����������, ��������� � ����������������

  // ������� ���� ������
  fclose(opened_trace->file_index[file_counter].file_data);
  opened_trace->file_index[file_counter].file_data=NULL;

  return KRT_OK;
} // long WINAPI calkulate_index_files_and_sems


long load_seam_data(T_OPENED_TRACE *opened_trace, long file, long seam) {

  T_DESCRIPTOR cur_descriptor; // ������ �����������

  word *arc_data;


  if( fseek (opened_trace->file_index[file].file_data, 
              opened_trace->file_index[file].index_seam[seam].shift_in_file,
              SEEK_SET
             )
       !=  0)
   {
     sprintf (drvError, "�� ������������ ��������� � �����(load_seam_data)");
     return KRT_ERR;
   };

  if (fread(&cur_descriptor, 1, sizeof(T_DESCRIPTOR), opened_trace->file_index[file].file_data) 
        !=  sizeof(T_DESCRIPTOR))
   {
     sprintf (drvError, "������ ������ �����������(load_seam_data)");
     return KRT_ERR;
   };

  if ((cur_descriptor.ver_file != VER_FILE_VNSHN)   ||
      (cur_descriptor.descriptor_type !=DESCRIPTOR_CONDITION_SEAM) ||
      (cur_descriptor.descriptor_Size!=sizeof(T_SEAM)+sizeof(T_DESCRIPTOR))
     )
   {
     sprintf (drvError, "����������� ������ ����� (load_seam_data)");
     return KRT_ERR;
   }; //  if (cur_descriptor.ver_file != VER_FILE_VNSHN) {

  opened_trace->file_index[file].index_seam[seam].head_of_condition_seam = 
         init_condition_seam();
  if (opened_trace->file_index[file].index_seam[seam].head_of_condition_seam==NULL) {
     strcat (drvError, "(load_seam_data)");
     return KRT_ERR;
   };

  if( (fread(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam,
             1, sizeof(T_SEAM), opened_trace->file_index[file].file_data) 
      ) != sizeof(T_SEAM))
   {
     sprintf (drvError, "������ ������ ��������� ���. ���(load_seam_data)");
     opened_trace->file_index[file].index_seam[seam].head_of_condition_seam =
       free_condition_seam(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam);
     return KRT_ERR;
   };

  arc_data=(word *) heap_alloc(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam->arc_size);

  if (arc_data==NULL) {
     sprintf (drvError, "������ ��������� ������ ��� �������� ������(load_seam_data)");
     opened_trace->file_index[file].index_seam[seam].head_of_condition_seam =
       free_condition_seam(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam);
     return KRT_ERR;
   };

  if(fread(arc_data, 1, 
           opened_trace->file_index[file].index_seam[seam].head_of_condition_seam->arc_size,
           opened_trace->file_index[file].file_data
          ) 
         != opened_trace->file_index[file].index_seam[seam].head_of_condition_seam->arc_size
    )
   {
     sprintf (drvError, "������ ������ �����(load_seam_data)");
     opened_trace->file_index[file].index_seam[seam].head_of_condition_seam =
       free_condition_seam(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam);
     arc_data=heap_free(arc_data);
     return KRT_ERR;
   };

  // ������������� ������
  if (unarc_lzw(arc_data, 
                opened_trace->file_index[file].index_seam[seam].head_of_condition_seam->arc_size/2, 
                &opened_trace->file_index[file].index_seam[seam],
                opened_trace->corosion_sens_num
               )
       == KRT_ERR) 
   {
     strcat (drvError, "(load_seam_data)");
     arc_data=heap_free(arc_data);

     // ��������� ���� �������� ���
     opened_trace->file_index[file].index_seam[seam].inquiry =
        free_inquiry(opened_trace->file_index[file].index_seam[seam].inquiry);
     opened_trace->file_index[file].index_seam[seam].head_of_condition_seam =
       free_condition_seam(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam);
     return KRT_ERR;
   };
   // ��������������� ������ 
  arc_data=heap_free(arc_data);

  if (recalc_prod_put (&opened_trace->file_index[file].index_seam[seam],
                       &opened_trace->file_index[file].index_seam[seam].pred_src_prod_put,
                       opened_trace->file_index[file].index_seam[seam].init_direct_prod_put,
                       &opened_trace->file_index[file].index_seam[seam].next_direct_prod_put,
                       opened_trace->file_index[file].index_seam[seam].start_seam
                      )
       ==KRT_ERR 
     )
   {
     strcat (drvError, "(load_seam_data)");

     // ��������� ���� �������� ���
     opened_trace->file_index[file].index_seam[seam].inquiry =
        free_inquiry(opened_trace->file_index[file].index_seam[seam].inquiry);
     opened_trace->file_index[file].index_seam[seam].head_of_condition_seam =
       free_condition_seam(opened_trace->file_index[file].index_seam[seam].head_of_condition_seam);
     return KRT_ERR;
   };


/*
       // ������� ��������������� ��������� ����� ��������� �����������
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
               result_value +=2024;

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


  if( (opened_trace->Median_smooth>0)
        && 
      (opened_trace->Smooth_data_OFF==0)
    )
   {
      Use_median_data(&opened_trace->file_index[file].index_seam[seam], opened_trace);
   } else {
      Use_smooth_data(&opened_trace->file_index[file].index_seam[seam], opened_trace);
   };


  return KRT_OK;
} // long load_seam_data(T_OPENED_TRACE *opened_trace, long file, long seam) {


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
  unsigned long i;

  if (start+length<opened_trace->file_index[0].beg_track) {
     length = 0;
   };

  if (start+length>opened_trace->file_index[opened_trace->num_file_data-1].end_track) {
     length=opened_trace->file_index[opened_trace->num_file_data-1].end_track-start;
   };

  // �������� ������ ��������� ��� �������� ������ ���� ������ � ������ ����������

  // ������ ���� � ������� ������ ����������� �������
  for (file_counter=0; file_counter<opened_trace->num_file_data; file_counter++) {
     if ( (start >= opened_trace->file_index[file_counter].index_seam[0].beg_track) &&
          (start <= opened_trace->file_index[file_counter].index_seam[opened_trace->file_index[file_counter].num_condition_seam-1].end_track)
        ) break;
   }; // for (file_counter

  if (file_counter >= opened_trace->num_file_data) {
      // ������ �� �������� ������, �� � ���� ����
     sprintf (drvError, "������ ������� ������-�� �� ����� � ������(get_data)");
     return KRT_ERR;
   };
  // ����� ���� � ������� ������ ����������� �������

  opened_trace->current_file=file_counter;

  // �������� ��� ���� ������, ����� ��� �������
  if (opened_trace->file_index[file_counter].file_data==NULL) {
     opened_trace->file_index[file_counter].file_data = 
            fopen(opened_trace->file_index[file_counter].file_name, "rb");
     if (opened_trace->file_index[file_counter].file_data ==NULL) {
       sprintf (drvError, "������ �������� ����� %s(get_data)",
                opened_trace->file_index[file_counter].file_name
               );
       opened_trace = free_opened_trace(opened_trace);
       return KRT_ERR;
      };
   };

  // ������ ���.��� � ������� ������ ����������� �������
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
      // ������ �� �������� ������, �� � ���� ����
     sprintf (drvError, "������ ������� ������-�� �� ����� � ����(get_data)");
	 return KRT_ERR;
   };
  // ����� ����� ����� � ��������� ��� ��� ������� ������������ �������

  opened_trace->current_seam=seam_counter;

  loaded_data=init_loaded_data();
  cur_item=loaded_data;
  pred_item = NULL;

  cur_item->file = file_counter;
  cur_item->seam = seam_counter;

  length -= (opened_trace->file_index[file_counter].index_seam[seam_counter].end_track - 
             start);

  // ��������� ��������� �������� ���, ���� ��� �����
  while (length > 0) {
     seam_counter++;
     if (seam_counter >= opened_trace->file_index[file_counter].num_condition_seam) {
       // � ������� ����� �������� ��� ����������� ...
       seam_counter = 0;

       file_counter++;
       if (file_counter >= opened_trace->num_file_data) {
           // ������ �� �������� ������, �� � ���� ����
          sprintf (drvError, "����� ������� ������-�� �� ����� � ������(get_data)");
          return KRT_ERR;
        };

        // �������� ��� ���� ������, ����� ��� �������
        if (opened_trace->file_index[file_counter].file_data==NULL) {
           opened_trace->file_index[file_counter].file_data = 
                  fopen(opened_trace->file_index[file_counter].file_name, "rb");
           if (opened_trace->file_index[file_counter].file_data ==NULL) {
             sprintf (drvError, "������ �������� ����� %s(get_data)",
                      opened_trace->file_index[file_counter].file_name
                     );
             opened_trace = free_opened_trace(opened_trace);
             return KRT_ERR;
            };
         };
      };

     // ������� ��������� �������� ���
     pred_item = cur_item;
     cur_item = init_loaded_data();
     pred_item->Next_element = cur_item;

     cur_item->file = file_counter;
     cur_item->seam = seam_counter;

     length -= (opened_trace->file_index[file_counter].index_seam[seam_counter].end_track - 
                opened_trace->file_index[file_counter].index_seam[seam_counter].beg_track+1);
   }; //   while (length > 0) {
  // ��������� ������ ��������� ��� �������� ������ ���� ������ � ������ ����������

  // �������� ���� �� ��� ����������� ������, � ���� ���, �� ��������
  cur_item = loaded_data;
  pred_item = NULL;

  while (cur_item != NULL) {
     seam_loaded_res = KRT_ERR;

     trace_item = opened_trace->list_loaded_data;
     pred_trace_item = NULL;

     while (trace_item != NULL) {
        if ( (cur_item->file == trace_item->file) &&
             (cur_item->seam == trace_item->seam) )
         {   // ����� ����������� ���. ���
            seam_loaded_res = KRT_OK;

            // ���� ������ ���� ���. ��� ���������� �� ���������� ������
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
         // �� ����� ����������� ���. ���, ���� ���������
        if (load_seam_data(opened_trace, cur_item->file, cur_item->seam) == KRT_ERR) {
           strcat (drvError, "(get_data)");


           // ��� ���� ����������� �������� ��� ����������� ������ 
           // �� ����� ������ ��� ����������� ������,
           // ����� ����� ����������� ��������� �� ��� ���������,
           // ���� � ������ �������� ������ ������ ��������, ������ �����������
           // ����������� ������ ������ ����� ������ ��������

           return KRT_ERR;
         };

        // �������� ��� �������� ����������� ������� � ���������� ��������� ���,
        // � ������������ � ->trace_step
        for (i=0;
             i<opened_trace->file_index[cur_item->file].index_seam[cur_item->seam].head_of_condition_seam->real_dim;
             i++)
         {
            opened_trace->file_index[cur_item->file].index_seam[cur_item->seam].inquiry[i].prod_put*=opened_trace->trace_step;
         };
      };

     pred_item = cur_item;
     cur_item = cur_item->Next_element;
   }; // while (cur_item != NULL) {
  // ��������� ���� �� ��� ����������� ������, � ��������� �����������

  // ��������� �� ������ ����������� ������ ����������� ����
  // ���������� ��� ��������� ���� �� ����������� ������ (�� ����� bonus_seam_counter)
  bonus_seam_counter=10; // 10 - ��� 8 ������

  cur_item = pred_item; // ���� ��������� �� ��������� ����� ����������� �����

  trace_item = opened_trace->list_loaded_data; // ������ ���������� ����������� ������ ������

  while (trace_item != NULL && bonus_seam_counter>0) {

     // ��������� ��������� �������� ���
     cur_item->Next_element=trace_item;

     opened_trace->list_loaded_data=trace_item->Next_element;
     trace_item=opened_trace->list_loaded_data;

     cur_item = cur_item->Next_element;
     cur_item->Next_element = NULL;
     // ��������� ��������� �������� ���


     bonus_seam_counter--;
   }; // while (trace_item != NULL && bonus_seam_counter>0) {
  // ����������� ��� ��������� ���� �� ����������� ������ (�� ����� bonus_seam_counter)


// �������� ���������� ������ � ���������� � ������ !
//  pred_item->Next_element = opened_trace->list_loaded_data;
//  opened_trace->list_loaded_data = loaded_data;


   // ���� ��������� ������ ���. ���, ����� �� �������� ������
  cur_item = opened_trace->list_loaded_data;
  while (cur_item!=NULL) {
     // ��������� ���� �������� ���
     opened_trace->file_index[cur_item->file].index_seam[cur_item->seam].inquiry =
        free_inquiry(opened_trace->file_index[cur_item->file].index_seam[cur_item->seam].inquiry);
     opened_trace->file_index[cur_item->file].index_seam[cur_item->seam].head_of_condition_seam =
        free_condition_seam(opened_trace->file_index[cur_item->file].index_seam[cur_item->seam].head_of_condition_seam);

     cur_item=cur_item->Next_element;
   };

  cur_item = free_list_loaded_data (opened_trace->list_loaded_data);
   // ���������� ������ ���. ���, ����� �� �������� ������

  opened_trace->list_loaded_data = loaded_data;

  // ������� ��� �������� ����� ������
  for (serch_file_counter=0; serch_file_counter<opened_trace->num_file_data;serch_file_counter++) {
     if (opened_trace->file_index[serch_file_counter].file_data!=NULL) {
        fclose(opened_trace->file_index[serch_file_counter].file_data);
        opened_trace->file_index[serch_file_counter].file_data=NULL;
      };
   };

  return KRT_OK;
} // T_LOADED_DATA * get_data(long beg_length, long end_length)