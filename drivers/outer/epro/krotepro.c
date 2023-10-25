// krotepro.c - ������� epro_drv.
// ���������� ���������� ������ � ���� ���������������� ������� ��������
// ��������� ������ ������������ ����� "epro" ���������� KrotW32
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "winkrt.h"
#include "KrtAPI2.h"
#include "krotepro.h"
#include "libdafil.h"
#include "heapinsp.h"
#include "reciever.h"
#include "iniTool.h"
#include "fileTool.h"

//////////////////////////////////////////////////////////////////////////
// ���������� ������ ��������
//////////////////////////////////////////////////////////////////////////

char drvError[1024];

T_TRACE_LIST trace_list[MAX_TRACE];
long open_trace_counter;

char *traceFile;

//////////////////////////////////////////////////////////////////////////
// ����������� ���������� ������ ��������
//////////////////////////////////////////////////////////////////////////

const char * KRTAPI krtDrvError(void) { return drvError; }

/* ������� ������������� �������� ������ �������� */
void initTraces(void) {
  open_trace_counter=0;
  strcpy(drvError, "");
}

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

long init_bort_factor_data (T_OPENED_TRACE * trc) {

 trc->trace_step = getTrcInt(trc->file, TRACE_STEP_KEY, OUTER_STEP);; // ��� ������
 //trc->Amplification_Group[0] = 4;
 //trc->max_data_code=MAX_DAT_VAL;
 // ����� ���� �����������
 trc->smooth_win_length = getTrcInt(trc->file, Smooth_win_length_KEY, 4);
 strcpy(trc->invert_sens_data_text, "");

 return KRT_OK;
}

// ������� ��������� ��������� �� ������ ������ �������� ����� key 
// �� trc ����� file
long errTrc(
const char *trc,
const char *key,
const char *msg
) {
 sprintf (
  drvError, 
  "������ ������ %s ([%s]:%s) �� ����� %s.", 
  msg, 
  DRIVER_DATA,
  key,
  trc
 );
 return KRT_ERR;
}

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

   if (high_range>95) high_range = 95;
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

// ������� ������ ��������� ������ � ����
long save_index_info(T_OPENED_TRACE * P_trace) {
  FILE * idx_file;
  long res_write;

  long file_counter;
  long seam_counter;

  idx_file = fopen(P_trace->idx_file_name, "wb");
  if (idx_file == NULL) {
     sprintf(drvError, "�� ���� ������� ���� %s (save_index_info)", P_trace->idx_file_name);
     return KRT_ERR;
   };

  // ������� ��������� �������� ������
  res_write = fwrite(P_trace, 1, sizeof(T_OPENED_TRACE), idx_file);

  if (res_write != sizeof(T_OPENED_TRACE) ) {
      sprintf(drvError, "������ ������ num_file_data (save_index_info)");
      fclose(idx_file);
      return KRT_ERR;
   };

  // ������� ��� ������� �������� ������
  for (file_counter=0; file_counter<P_trace->num_file_data; file_counter++) {

     // ������� ��������� ������� �� �����
     res_write = fwrite(&P_trace->file_index[file_counter],
                        1, sizeof(T_INDEX_FILE), idx_file);

     if (res_write != sizeof(T_INDEX_FILE) ) {
         sprintf(drvError, "������ ������ file_index[%d] (save_index_info)", file_counter);
         fclose(idx_file);
         return KRT_ERR;
      };

     for (seam_counter = 0; 
          seam_counter < P_trace->file_index[file_counter].num_condition_seam;
          seam_counter++) 
      {

         // ������� ��������� ������� �� ��������� ���
         res_write = fwrite(&P_trace->file_index[file_counter].index_seam[seam_counter],
                            1, sizeof(T_INDEX_SEAM), idx_file);

         if (res_write != sizeof(T_INDEX_SEAM) ) {
             sprintf(drvError, "������ ������ file_index[%d].index_seam[%d] (save_index_info)", 
                                file_counter, seam_counter
                    );
             fclose(idx_file);
             return KRT_ERR;
          };

         // ������� ������ ��������� ������� �� �������� ��������� ���
         res_write = fwrite(&P_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0],
                            1,P_trace->corosion_sens_num * sizeof(P_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0]),
                            idx_file
                           );

         if (res_write != P_trace->corosion_sens_num * (long) sizeof(P_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0]) ) {
             sprintf(drvError, "������ ������ file_index[%d].index_seam[%d].smooth_data_beg (save_index_info)", 
                                file_counter, seam_counter
                    );
             fclose(idx_file);
             return KRT_ERR;
          };

      }; // for (seam_counter=0; seam_counter<P_trace->file_index[file_counter].num_condition_seam; ;seam_counter++)
   }; //   for (file_counter=0; file_counter<P_trace->num_file_data ;file_counter++)


  fclose(idx_file);

  return KRT_OK;
}; // long WINAPI save_index_info(T_OPENED_TRACE * P_trace)


// ������� ������ ��������� ������ � ����
long load_index_info(T_OPENED_TRACE * P_trace) {
  FILE * idx_file;
  long res_read;

  long file_counter;
  long seam_counter;

  char  backup_path_data[_MAX_PATH];
  char  backup_idx_file_name[_MAX_PATH];
  char  backup_file[_MAX_PATH];
  T_INDEX_FILE *backup_file_index;
  T_LOADED_DATA *backup_list_loaded_data;
  char backup_file_name[_MAX_PATH];

  long  (KRTAPI *newDataRegistered) (T_ArrivedData *newData);


  idx_file = fopen(P_trace->idx_file_name, "rb");
  if (idx_file == NULL) {
     sprintf(drvError, "�� ���� ������� ���� %s (load_index_info)", P_trace->idx_file_name);
     return KRT_ERR;
   };


  // ��������� ��������� �������� ������, �������� ������������ ������
  strcpy(backup_path_data,P_trace->path_data);
  strcpy(backup_idx_file_name,P_trace->idx_file_name);
  strcpy(backup_file,P_trace->file);
  backup_file_index=P_trace->file_index;
  backup_list_loaded_data=P_trace->list_loaded_data;
  newDataRegistered=P_trace->newDataRegistered;


  res_read = fread(P_trace, 1, sizeof(T_OPENED_TRACE), idx_file);

  if (res_read != sizeof(T_OPENED_TRACE) ) {
      sprintf(drvError, "������ ������ num_file_data (load_index_info)");
      fclose(idx_file);
      return KRT_ERR;
   };

  P_trace->newDataRegistered=newDataRegistered;
  P_trace->file_index=backup_file_index;
  P_trace->list_loaded_data=backup_list_loaded_data;
  strcpy(P_trace->file,backup_file);
  strcpy(P_trace->idx_file_name,backup_idx_file_name);
  strcpy(P_trace->path_data,backup_path_data);

  if (read_data_from_trc(P_trace)==KRT_ERR) {
      fclose(idx_file);
      return KRT_ERR;
   };
  // ��������� ��������� �������� ������, �������� ������������ ������


  // ��������� ��� ������� ������
  for (file_counter=0; file_counter<P_trace->num_file_data; file_counter++) {

     // ��������� ��������� ������� �� �����
     strcpy(backup_file_name,P_trace->file_index[file_counter].file_name);

     res_read = fread(&P_trace->file_index[file_counter],
                        1, sizeof(T_INDEX_FILE), idx_file);

     if (res_read != sizeof(T_INDEX_FILE) ) {
         sprintf(drvError, "������ ������ file_index[%d] (load_index_info)", file_counter);
         fclose(idx_file);
         return KRT_ERR;
      };
     strcpy(P_trace->file_index[file_counter].file_name,backup_file_name);

     // ������ ����������������� ������� �� ���. ����
     P_trace->file_index[file_counter].index_seam = 
        init_index_seams(P_trace->file_index[file_counter].num_condition_seam);
     if ( P_trace->file_index[file_counter].index_seam == NULL) 
      {
        strcat(drvError, "(load_index_info)");
        fclose(idx_file);
        return KRT_ERR;
      }; //if (init_index_seams(&trace_list[reg_trc].trace->file_index[file_counter])

     for (seam_counter = 0; 
          seam_counter < P_trace->file_index[file_counter].num_condition_seam;
          seam_counter++) 
      {
         // ��������� ��������� ������� �� ��������� ���
         res_read = fread(&P_trace->file_index[file_counter].index_seam[seam_counter],
                            1, sizeof(T_INDEX_SEAM), idx_file);

         if (res_read != sizeof(T_INDEX_SEAM) ) {
             sprintf(drvError,
                     "������ ������ file_index[%d].index_seam[%d] (load_index_info)",
                     file_counter, seam_counter
                    );
             fclose(idx_file);
             return KRT_ERR;
          };

         P_trace->file_index[file_counter].index_seam[seam_counter].head_of_condition_seam=NULL; 
         P_trace->file_index[file_counter].index_seam[seam_counter].inquiry=NULL;

         P_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg = 
                         init_smooth_data_beg(P_trace->corosion_sens_num);

         // ��������� ������ ��������� ������� �� �������� ��������� ���
         res_read = fread(&P_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0],
                          1, P_trace->corosion_sens_num * sizeof(P_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0]),
                          idx_file
                         );

         if (res_read != P_trace->corosion_sens_num * (long) sizeof(P_trace->file_index[file_counter].index_seam[seam_counter].smooth_data_beg[0]) ) {
             sprintf(drvError,
                     "������ ������ file_index[%d].index_seam[%d].smooth_data_beg (load_index_info)",
                     file_counter, seam_counter
                    );
             fclose(idx_file);
             return KRT_ERR;
          };

      }; // for (seam_counter=0; seam_counter<P_trace->file_index[file_counter].num_condition_seam; ;seam_counter++)

   }; //   for (file_counter=0; file_counter<P_trace->num_file_data ;file_counter++)

  fclose(idx_file);
  // �� ��� ��� ������ �� ���������� ����� ��������

  return KRT_OK;
};

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

 // ��� ������� ����� ������
 ret = getTrcItem(file, FIRST_FILE_NAME_KEY, "tm00000.da");
 strcpy(trc->first_file_name, ret);

 // ������������ ��������� ��������� ��������� ������
 trc->max_data_code = getTrcInt(file, MAX_DATA_CODE_KEY, MAX_DAT_VAL);

 // �������� � ������ �����
 trc->Amplification_Group[0] = getTrcInt(file, Amplification_Group0_KEY, 4);
 trc->Amplification_Group[1] = getTrcInt(file, Amplification_Group1_KEY, 4);

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
 trc->razvorot_1_skanera = getTrcInt(file, razvorot_1_skanera_KEY, 1);
 trc->razvorot_2_skanera = getTrcInt(file, razvorot_2_skanera_KEY, 0);

 trc->Skan_2_Shift = getTrcInt(file, Skan_2_Shift_KEY, 0);

 ret = getTrcItem(file, KEY_SENS_STEP, "2.5");
 trc->sens_step = atof(ret);

 trc->orient_direct_count = getTrcInt(file, orient_direct_count_KEY, 0);

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

// ������� ��������� ������ ��� ��������� �������� ������ 
//(���� ����������� T_OPENED_TRACE)
T_OPENED_TRACE * WINAPI init_opened_trace() {

  T_OPENED_TRACE *space_for_trace;
  long i;

  space_for_trace = (T_OPENED_TRACE *) heap_alloc(sizeof(T_OPENED_TRACE));
  if (space_for_trace == NULL) {
     sprintf(drvError, "��� ������ ��� �������� ������(init_opened_trace)");
     return space_for_trace;
   };;

  // ������� ���� ���� ��� ���������� ��������� (�� ������ ������)
  space_for_trace->trace_len=0;
  space_for_trace->trace_step=0;
  space_for_trace->trace_time=0;
  strcpy(space_for_trace->path_data, ""); 
  strcpy(space_for_trace->first_file_name, FIRST_FILE_NAME); 
  strcpy(space_for_trace->file, ""); 
  strcpy(space_for_trace->idx_file_name, ""); 
  space_for_trace->num_file_data=0;

  space_for_trace->corosion_sens_num=0;
  space_for_trace->max_data_code=0;

  space_for_trace->Amplification_Group[0]=1;


  for (i=0; i<MAX_CORROZION_NUM; i++) {
     space_for_trace->invert_sens_data[i]=0;
   };

  space_for_trace->smooth_win_length = 8;

  space_for_trace->file_index=NULL;

  space_for_trace->list_loaded_data=NULL;

  space_for_trace->razvorot_1_skanera=0;
  space_for_trace->razvorot_2_skanera=0;

  space_for_trace->nodeType=0; 
  space_for_trace->nodeIndex=0;            
  space_for_trace->nodePos=0;
  space_for_trace->controlSize=0;

  return space_for_trace;
} // T_OPENED_TRACE * WINAPI init_opened_trace()

// ������� ������������ ������ ��� ���������� �������� ������
T_OPENED_TRACE * WINAPI free_opened_trace( T_OPENED_TRACE *p_free) {

 if (p_free != NULL) {

  if ( p_free->file_index != NULL) {
   p_free->file_index = free_index_files(p_free->file_index, p_free->num_file_data);
  }
  p_free->list_loaded_data = free_list_loaded_data(p_free->list_loaded_data);
  p_free = heap_free(p_free);
 } // if ((*p_free)!=NULL) 

 return p_free;
} //  T_OPENED_TRACE * WINAPI free_opened_trace( T_OPENED_TRACE *p_free)


// ������� ��������� ������ ��� ������ �������� ������ � �������� ������
// (���� ����������� T_INDEX_FILE)
// ��� ���� ���������� ��� ���� file_index
// � ����� ������ ����������� ������ �������  � �������
T_INDEX_FILE * init_index_files(long num_file_data) {
  long i;
  T_INDEX_FILE *file_index;

  (void) num_file_data; // !!! not use!

  file_index = (T_INDEX_FILE *) heap_alloc(sizeof(T_INDEX_FILE)*MAX_FILE_IN_TRACE);
  if (file_index == NULL) {
     sprintf(drvError, "��� ������ ��� ������� ������(init_index_files)");
     return file_index;
   };

  for (i=0; i<MAX_FILE_IN_TRACE; i++) {
     strcpy(file_index[i].file_name, "");
     file_index[i].beg_track=0;
     file_index[i].end_track=0;
     file_index[i].num_condition_seam=0;

     file_index[i].index_seam=NULL;

     file_index[i].file_data=NULL;
   };

  return file_index;
} // T_INDEX_FILE*  WINAPI init_index_files(long num_file_data,

// ������� ������������ ���� � ������� ������
long WINAPI init_name_files(T_OPENED_TRACE *p_trace) {
  long i;
  char *fn;
  char cur_file_name[_MAX_PATH];
  T_INDEX_FILE* file_index;

  file_index = p_trace->file_index;
  makeFullPath(cur_file_name, p_trace->path_data, p_trace->first_file_name);

  for (i=0; i<MAX_FILE_IN_TRACE; i++) {
     strcpy(file_index[i].file_name, cur_file_name);
     fn = strrchr(cur_file_name, '\\');
     fn++;
     if (inc_file_name(fn)==KRT_ERR) {
        strcat(drvError, "(init_name_files)");
        return KRT_ERR;
      };
   };

  return KRT_OK;
}; // long WINAPI init_name_files(


// ������� ������������ ������ ��� ������ �������� ������ � �������� ������
T_INDEX_FILE* WINAPI free_index_files(T_INDEX_FILE* p_free, long num_file_data) {
  long i;

  if (p_free != NULL) {
     for (i=0; i<num_file_data; i++) {
        if (p_free[i].index_seam != NULL) {
            p_free[i].index_seam =
                free_index_seams(p_free[i].index_seam, p_free[i].num_condition_seam);
         };

        if (p_free[i].file_data != NULL) {
            fclose(p_free[i].file_data);
            p_free[i].file_data=NULL;
         };
      };
     p_free = heap_free(p_free);
   };

  return p_free;
}; // T_INDEX_FILE* WINAPI free_index_files(


// ������� ��������� ������ ��� ������ �������� �������� ���� � �������� ������
// (���� ����������� T_INDEX_SEAM)
T_INDEX_SEAM * WINAPI init_index_seams(long num_condition_seam)
{
  long i;
  T_INDEX_SEAM *index_seam;

  index_seam = (T_INDEX_SEAM *) heap_alloc(sizeof(T_INDEX_SEAM) * num_condition_seam);
  if (index_seam == NULL) 
   {
     sprintf(drvError, "��� ������ ��� ������� ���.����(init_index_seams)");
     return index_seam;
   };

  for (i=0; i<num_condition_seam; i++) {
    index_seam[i].beg_track=0;
    index_seam[i].end_track=0;
    index_seam[i].shift_in_file=0;
    index_seam[i].beg_time=0;
    index_seam[i].end_time=0;
    index_seam[i].smooth_orientation_beg=0;

    index_seam[i].smooth_data_beg=NULL;
    index_seam[i].global_number_seam=0;

    index_seam[i].head_of_condition_seam=NULL;
    index_seam[i].inquiry=NULL;

    index_seam[i].pred_src_prod_put=0;
    index_seam[i].start_seam=0;
    index_seam[i].init_direct_prod_put=1;
    index_seam[i].next_direct_prod_put=0;

   }; //  for (i=0; i< p_init->num_condition_seam; i++) {

  return index_seam;
}; // long WINAPI init_index_seams(T_INDEX_FILE* p_init)


// ������� ������������ ������ ��� ������ �������� �������� ���� � �������� ������
T_INDEX_SEAM * WINAPI free_index_seams(T_INDEX_SEAM *p_free, long num_condition_seam) {
  long i;

  if (p_free != NULL) {
     for (i=0; i<num_condition_seam; i++) {

        if (p_free[i].inquiry != NULL) {
            p_free[i].inquiry = free_inquiry( p_free[i].inquiry);
         };

        if (p_free[i].head_of_condition_seam != NULL) {
           p_free[i].head_of_condition_seam = 
                free_condition_seam(p_free[i].head_of_condition_seam);
         };

        if (p_free[i].smooth_data_beg != NULL) {
            p_free[i].smooth_data_beg = 
                free_smooth_data_beg(p_free[i].smooth_data_beg);
         };

      };
     p_free = heap_free(p_free);
   };

  return p_free;
}; // T_INDEX_SEAM * WINAPI free_index_seams(

// ������� ��������� ������ ��� ������ �������� ������������ ���������
// ������������� ���� smooth_data_beg � ��������� T_INDEX_SEAM
long * WINAPI init_smooth_data_beg(long  cor_num)
{
   long * space_smooth_data_beg;

   // ������� ����� ��� ������ �������� ������������ ���������
   space_smooth_data_beg = (long *)
                  heap_alloc (sizeof(long) * cor_num);
   if (space_smooth_data_beg == NULL) {
      sprintf(drvError, "��� ������ ��� ������ �������� ������������ ���������(init_smooth_data_beg)");
      return space_smooth_data_beg;
    };

  return space_smooth_data_beg;
}; // long * WINAPI init_smooth_data_beg(long  cor_num)


// ������� ������������ ������ ��� ������  �������� ������������ ���������
long * WINAPI free_smooth_data_beg(long *p_free) {
                  
  if (p_free != NULL) {
     p_free = heap_free(p_free);
   };

  return p_free;
}; // long * WINAPI free_smooth_data_beg(long *p_free) {


// ������� ��������� ������ ��� ����������
// (���� ����������� T_SEAM)
T_SEAM * WINAPI init_condition_seam() {

  T_SEAM *descriptor;

  descriptor = (T_SEAM *) heap_alloc (sizeof(T_SEAM));
  if (descriptor == NULL) {
     sprintf(drvError, "��� ������ ��� ����������(init_condition_seam)");
     return descriptor;
   };

  return descriptor;
}; // T_SEAM * WINAPI init_condition_seam() {

// ������� ������������ ������ ��� ������������
// (���� ���������� T_SEAM)
T_SEAM * WINAPI free_condition_seam(T_SEAM *p_free) {

  if (p_free != NULL) {
     p_free = heap_free(p_free);
   };

  return p_free;
}; // T_SEAM * WINAPI free_index_seams(T_SEAM *p_free)


// ������� ��������� ������ ��� ������ ���������
// (���� ����������� T_INQUIRY)
T_INQUIRY * WINAPI init_inquiry(long  cor_num,
                                long  dim_num)
{
   long i;
   T_INQUIRY *inquiry;


   // ������� ����� ��� ������ ���������
   inquiry = (T_INQUIRY *) heap_alloc (sizeof(T_INQUIRY) * dim_num);
   if (inquiry == NULL) {
      sprintf(drvError, "��� ������ ��� ������ ���������(init_inquiry)");
      return inquiry;
    };

   // ������� ����� ��� ������ ����������� ���������
   inquiry->sens = (SENS_DATA *) heap_alloc (sizeof(SENS_DATA)*cor_num * dim_num);
   if (inquiry->sens == NULL) {
      sprintf(drvError, "��� ������ ��� ������ ����������� ���������(init_inquiry)");
      inquiry=heap_free(inquiry);
      return inquiry;
    };

   // ������� ����� ��� ������ �������������� ����������� ���������
   inquiry->math_sens = (SENS_DATA *) heap_alloc (sizeof(SENS_DATA)*cor_num * dim_num);
   if (inquiry->sens == NULL) {
      sprintf(drvError, "��� ������ ��� ������  �������������� ����������� ���������(init_inquiry)");
      inquiry=heap_free(inquiry);
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
       p_free->sens = heap_free(p_free->sens);
      };

     if (p_free->math_sens != NULL) {
       p_free->math_sens = heap_free(p_free->math_sens);
      };

     p_free = heap_free(p_free);
   };

  return p_free;
}; //T_INQUIRY * free_inquiry(


// ������� ������ ��������� ������ � ����
// ������� �������� �������� ������ � ��������� ��������� ������ �� �����
T_OPENED_TRACE * creation_trace(const char * trc_file) {
  T_OPENED_TRACE * new_trace;
  
  char current_path[_MAX_PATH];

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

  // ������ ����������������� ������� �� ������
  new_trace->file_index = init_index_files(MAX_FILE_IN_TRACE);
  if (new_trace->file_index == NULL) {
     strcat(drvError, "(creation_trace)");
     new_trace = free_opened_trace(new_trace);
     return NULL;
   };

  // ������� �� ���� ������ ������ ���� �� ���
  makeFullPath(current_path, new_trace->path_data, new_trace->first_file_name);

  if (init_name_files(new_trace) == KRT_ERR) {
     strcat(drvError, "(creation_trace)");
     new_trace = free_opened_trace(new_trace);
     return NULL;
   };

  return new_trace;
}; // T_OPENED_TRACE * creation_trace


// ������� ��������� ������ ��� ��� ���� ����������� ������
// (���� ����������� T_LOADED_DATA)
T_LOADED_DATA *init_loaded_data () {
  T_LOADED_DATA * new_loaded_data;

  new_loaded_data = (T_LOADED_DATA *) heap_alloc (sizeof(T_LOADED_DATA));
  if (new_loaded_data == NULL) {
     sprintf(drvError, "��� ������ ��� ...(init_loaded_data)");
     return new_loaded_data;
   };

  new_loaded_data->file=0;
  new_loaded_data->seam=0;

  new_loaded_data->Next_element=NULL;

  return new_loaded_data;
}; // T_LOADED_DATA *init_loaded_data () {

// ������� ������������ ������ ��� ����� ����������� ������
// (���� ���������� T_LOADED_DATA )
T_LOADED_DATA *free_loaded_data (T_LOADED_DATA * p_free) {

  if (p_free != NULL) {
     p_free = heap_free(p_free);
   };

  return  p_free;
};// T_LOADED_DATA *free_loaded_data (T_LOADED_DATA * p_free) {


// ������� ���������� ���� ����������� ������ � ����� ������
long add_loaded_data_in_list(T_LOADED_DATA * list, long file, long seam) {
  T_LOADED_DATA * cur_item;

  // �������� � ����� ������
  cur_item = list;

  while (cur_item->Next_element != NULL) {
     cur_item = cur_item->Next_element;
   };
  // ������� � ����� ������

  cur_item->Next_element = init_loaded_data();
  if (cur_item->Next_element == NULL) {
     strcat(drvError, "(add_loaded_data_in_list)");
     return KRT_ERR;
   };

  cur_item->Next_element->file = file;
  cur_item->Next_element->seam = seam;

 return KRT_OK;
}; // long add_loaded_data_in_list(T_LOADED_DATA * list, long file, long seam)

// ������� �������� ���� ����������� ������ �� ����� ������
T_LOADED_DATA * del_loaded_data_in_list(T_LOADED_DATA * list) {
  T_LOADED_DATA * cur_item;

  // �������� � ����� ������
  if (list!=NULL) {
     if (list->Next_element != NULL) {
        cur_item = list;

        while (cur_item->Next_element->Next_element != NULL) {
           cur_item = cur_item->Next_element;
         };
        // ������� � ����� ������

        cur_item->Next_element = heap_free(cur_item->Next_element);
        if (cur_item->Next_element != NULL) {
           strcat(drvError, "(del_loaded_data_in_list)");
           return list;
         };

      } else {
        list = heap_free(list);
        if (list != NULL) {
           strcat(drvError, "(del_loaded_data_in_list)");
           return list;
         };
      };
   };

 return list;
};// long del_loaded_data_in_list(T_LOADED_DATA * list) {


// ������� ������������ ������ ��� ������� ����������� ������
// (���� ���������� ������� T_LOADED_DATA )
T_LOADED_DATA *free_list_loaded_data (T_LOADED_DATA * p_free) {

  T_LOADED_DATA * next_item;

  while (p_free != NULL) {
     next_item = p_free ->Next_element;
     p_free = heap_free(p_free);
     p_free = next_item;
   };

  return  p_free;
};// T_LOADED_DATA *free_loaded_data (T_LOADED_DATA * p_free) {


// ������� ��������� ����������� � ����� ������ fileName ��������� info
// ���������� 1 ��� ������, 0 ��� ������. �������� ������ � drvError
long getFileInfo(
 T_OPENED_TRACE *trace,
 const char *fileName,  
 long fileIndex, 
 T_ArrivedData *info
 ) {

  (void)  fileName; // !!!!!!!! not use!

  if (fileIndex > trace->num_file_data) {
     strcpy(drvError, "Error maintenance files (getFileInfo)");
     return 0;
   };

  while (fileIndex >= trace->num_file_data) {

     // �������� ����� ���� � �������
     if (enumerate_seam_in_files(&trace->file_index[trace->num_file_data])==KRT_ERR)
      {
        strcat(drvError, "(getFileInfo)");
        return 0;
      };// if (enumerate_seam_in_files(&trace->file_index[cur_file])


     trace->file_index[trace->num_file_data].index_seam = 
           init_index_seams(trace->file_index[trace->num_file_data].num_condition_seam);
     if ( trace->file_index[trace->num_file_data].index_seam == NULL) 
      {
        strcat(drvError, "(getFileInfo)");
        return 0;
      }; //if (init_index_seams(&trace->file_index[file_counter])

     if ( calkulate_index_files_and_sems(trace, trace->num_file_data) == KRT_ERR ) {
        strcat(drvError, "(getFileInfo)");
        return 0;
      };

     // �������� ����� ������
     trace->trace_len = trace->file_index[trace->num_file_data].end_track;

     // �������� ����� ������ �� ������
     trace->trace_time = (long)
                trace->file_index[trace->num_file_data].index_seam
                          [
                            trace->file_index[trace->num_file_data].num_condition_seam-1
                          ].end_time;
     // ��������� ����� ������ �� ������

     trace->num_file_data++;
     // �������� ����� ����
   };

  info->start  = trace->file_index[fileIndex].beg_track;
  info->length = trace->file_index[fileIndex].end_track - info->start;

  if (save_index_info(trace) != KRT_OK ) {
     strcat(drvError, "(getFileInfo)");
     return 0;
   };

  return 1;
}; // long getFileInfo(T_OPENED_TRACE *trace, const char *fileName, 


// ������� ���� ������ ������ �������� �������������� ��� �������� traceDist 
// (� ����� ����������� �������� �� ������ ������) � ��������� ����������� � 
// ��� ��������� spin
// ��� ������� ���������� ���������� 1, ��� ������ 0. �������� ������ ����������
// � ���������� drvError
short getFirstSpin(T_OPENED_TRACE *trace, long traceDist, T_SPIN_INFO *spin) {
  long my_traceDist=traceDist/trace->trace_step;

  if ( my_traceDist >= trace->trace_len ||
       my_traceDist < trace->file_index[0].beg_track ||
       trace->trace_len==0)
   {
      trace->current_spin.odo.start  = 0;
      trace->current_spin.odo.length = 0;
      trace->current_spin.itemNum = 0;
      trace->current_spin.item = NULL;
      trace->current_spin.isComplete=NOT_FULL_SPIN;
      trace->current_file=0;
      trace->current_seam=0;
   } else {
      if (get_data(trace, my_traceDist, 1) == KRT_ERR) {
         strcat (drvError, "(krtDrvFillData)");
         return 0;
       };

      trace->current_spin.odo.start
           =trace->file_index[trace->current_file].index_seam[trace->current_seam].beg_track;
      trace->current_spin.odo.length 
           = trace->file_index[trace->current_file].index_seam[trace->current_seam].end_track
             -
             trace->current_spin.odo.start
             + 1;

      trace->current_spin.itemNum
           = trace->file_index[trace->current_file].index_seam[trace->current_seam].head_of_condition_seam->real_dim;

      trace->current_spin.item
           = trace->file_index[trace->current_file].index_seam[trace->current_seam].inquiry;

      if (trace->current_file==0 && trace->current_seam==0) {
          trace->current_spin.isComplete=NOT_FULL_SPIN;
       } else {
          trace->current_spin.isComplete
                 = trace->file_index[trace->current_file].index_seam[trace->current_seam].head_of_condition_seam->complete_spin;
       };
   };


  spin->odo.start  = trace->current_spin.odo.start * trace->trace_step;
  spin->odo.length = trace->current_spin.odo.length * trace->trace_step;
  spin->itemNum    = trace->current_spin.itemNum;
  spin->item       = trace->current_spin.item;
  spin->isComplete = trace->current_spin.isComplete;

  return 1;
};

// ������� ��������� ��������� spin ����������� � ��������� �� ������� ������� 
// (����� ����������� ������ getFirstSpin ��� getNextSpin)
// ��� ������� ���������� ���������� 1, ��� ������ 0. �������� ������ ����������
// � ���������� drvError
short getNextSpin(T_OPENED_TRACE *trace, T_SPIN_INFO *spin) {

 long next_traceDist;

   if ((trace->current_file<trace->num_file_data) && 
       (trace->current_seam<trace->file_index[trace->current_file].num_condition_seam)
      )
   {
      next_traceDist =
           trace->file_index[trace->current_file].index_seam[trace->current_seam].end_track+1;
   } else {
     trace->current_spin.odo.start  = 0;
     trace->current_spin.odo.length = 0;
     trace->current_spin.itemNum = 0;
     trace->current_spin.item = NULL;
     trace->current_spin.isComplete=NOT_FULL_SPIN;

     spin->odo.start  = trace->current_spin.odo.start;
     spin->odo.length = trace->current_spin.odo.length;
     spin->itemNum    = trace->current_spin.itemNum;
     spin->item       = trace->current_spin.item;
     spin->isComplete = trace->current_spin.isComplete;

     return 1;
   };

  if ( next_traceDist >= trace->trace_len ||
       next_traceDist < trace->file_index[0].beg_track ||
       trace->trace_len==0)
   {
      trace->current_spin.odo.start  = 0;
      trace->current_spin.odo.length = 0;
      trace->current_spin.itemNum = 0;
      trace->current_spin.item = NULL;
	  trace->current_spin.isComplete=NOT_FULL_SPIN;
      trace->current_file=trace->num_file_data;
      trace->current_seam=trace->file_index[trace->current_file].num_condition_seam;
   } else {
      if (get_data(trace, next_traceDist,1) == KRT_ERR) {
         strcat (drvError, "(krtDrvFillData)");
         return 0;
       };

      trace->current_spin.odo.start
           =trace->file_index[trace->current_file].index_seam[trace->current_seam].beg_track;
      trace->current_spin.odo.length 
           = trace->file_index[trace->current_file].index_seam[trace->current_seam].end_track
             -
             trace->current_spin.odo.start
             + 1;

      trace->current_spin.itemNum
           = trace->file_index[trace->current_file].index_seam[trace->current_seam].head_of_condition_seam->real_dim;

      trace->current_spin.item
           = trace->file_index[trace->current_file].index_seam[trace->current_seam].inquiry;
	  trace->current_spin.isComplete
		   = trace->file_index[trace->current_file].index_seam[trace->current_seam].head_of_condition_seam->complete_spin;
   };

  spin->odo.start  = trace->current_spin.odo.start * trace->trace_step;
  spin->odo.length = trace->current_spin.odo.length * trace->trace_step;
  spin->itemNum    = trace->current_spin.itemNum;
  spin->item       = trace->current_spin.item;
  spin->isComplete = trace->current_spin.isComplete;

  return 1;
}

long WINAPI krtDrvGetFirstNode ( 
KRTHANDLE handle, 
T_NODE *node,        
long start, 
long sensType, 
long sensIndex,
long length, 
long controlSize 
) {

long my_start, cur_file, cur_seam, cur_dim, thickIndx;
hyper timer_ms;
T_OPENED_TRACE *trc;
long number_file;
char number_file_str[8];

 trc = getTrace(handle);
 if (!trc) return KRT_ERR;

 my_start = (start / trc->trace_step );
 // �������� ��������� �� ����������� ��������� ��������� start 
 if ( my_start >= trc->trace_len || my_start < trc->file_index[0].beg_track) {
  node->Val=0;
  node->Pos=start;
  return KRT_OK;
 }

 // �������� controlSize
 if ((controlSize > 0)  &&  (controlSize < length)) {
  trc->controlSize = (double) (length) / (double) (controlSize);
 } else {
  trc->controlSize = trc->trace_step;
 }
 if (trc->controlSize < trc->trace_step) {
  trc->controlSize = trc->trace_step;
 }

 // �������� ��������� ���� ��� krtDrvGetNextNode
 trc->nodeType = sensType;
 trc->nodeIndex = sensIndex;
 trc->nodePos = start;

 if (get_data(trc, my_start, 1) == KRT_ERR) {
  strcat (drvError, "(krtDrvGetFirstNode)");
  return KRT_ERR;
 }
                                                       
 cur_file = trc->list_loaded_data->file;
 cur_seam = trc->list_loaded_data->seam;
 cur_dim = my_start - trc->file_index[cur_file].index_seam[cur_seam].beg_track;

 switch (sensType) {

  case KRT_SENS_ODO: // �������
   node->Val=start;
   node->Pos=start;
   break;

  case KRT_SENS_TIMER: // ������
   timer_ms = trc->file_index[cur_file].index_seam[cur_seam].inquiry[cur_dim].takt_in_ADC;
   timer_ms *= 32768;
   timer_ms /= 59659;
   timer_ms *= 100;
   timer_ms /= trc->frequency_processor;
   node->Val =(long) (timer_ms);
   node->Pos = start;
   break;

  case KRT_SENS_THICK: // �������
   if (my_start < trc->trace_len) {
    thickIndx = my_start * 2;
    node->Val = trc->thick.data[thickIndx];
    if (node->Val == 0) {
     updateThickData(trc, my_start);
     node->Val = trc->thick.data[thickIndx];
    }
   } else {
    node->Val = 0;
   }
   node->Pos = start;
   break;

  case KRT_SENS_EXT: // ���������������

    switch (sensIndex) {

     case 0:  // ������� ���
      node->Val = trc->file_index[cur_file].index_seam[cur_seam].global_number_seam;
      node->Pos = start;
      break;

     case 1:  // ����� .da

      number_file = strlen(trc->file_index[cur_file].file_name);
      number_file_str[0] = trc->file_index[cur_file].file_name[number_file-8];
      number_file_str[1] = trc->file_index[cur_file].file_name[number_file-7];
      number_file_str[2] = trc->file_index[cur_file].file_name[number_file-6];
      number_file_str[3] = trc->file_index[cur_file].file_name[number_file-5];
      number_file_str[4] = trc->file_index[cur_file].file_name[number_file-4];
      number_file_str[5] = 0;
      number_file = atoi(number_file_str);

      node->Val = number_file;
      node->Pos = start;
      break;

     default:
      sprintf(drvError, "bad sensIndex parameter(krtDrvGetFirstNode)");
      return KRT_ERR;

    } // switch (sensIndex) 
    break;

  default :
   node->Val=0;
   node->Pos=start;
   sprintf(drvError, "bad sensType parameter(krtDrvGetFirstNode)");
   return KRT_ERR;

 }

 return KRT_OK;
} /* krtDrvGetFirstNode */

long WINAPI krtDrvGetNextNode ( 
KRTHANDLE handle, 
T_NODE *node
) {
T_OPENED_TRACE *trc;

 trc = getTrace(handle);
 if (!trc) return KRT_ERR;

 trc->nodePos += (long) trc->controlSize;

 if (krtDrvGetFirstNode (
  handle, node, trc->nodePos, trc->nodeType, trc->nodeIndex, (long) trc->controlSize, 1
                        ) == KRT_ERR)  {
      strcat(drvError, "(krtDrvGetNextNode)");
      return KRT_ERR; 
 }

 return KRT_OK;
} /* krtDrvGetNextNode */


T_OPENED_TRACE *createTrace(
const char * traceFile, 
KRTHANDLE handle
) {
T_OPENED_TRACE * trc;
char *itm;
char path_data[_MAX_PATH];
T_ArrivedData info;
long file_counter, curent_trace, data_path_len, num_work_files;
FILE *index_file;

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

 // ��� ������� ����� ������
 itm = getTrcItem(trc->file, FIRST_FILE_NAME_KEY, "");
 if (*itm == 0) { itm = FIRST_FILE_NAME; }
 makeFullPath(path_data, NULL, itm);
 if (enumerate_work_files(path_data, &data_path_len, &num_work_files)==KRT_ERR) {
  strcat(drvError, "(createTrace)");
  return NULL;
 }

 // ��������� ����� ��������, ���� �� ����
 strcpy(trc->idx_file_name, trc->path_data);
 makeFullPath(trc->idx_file_name, NULL, INDEX_FILE_NAME);


 index_file = fopen(trc->idx_file_name, "rb");
 if (index_file!=NULL) {
    fclose(index_file);
    if (load_index_info(trc) != KRT_OK ) {
       strcat(drvError, "(createTrace)");
       trc->num_file_data = 0;
     };
  };


 if (trc->num_file_data<num_work_files-1) {
    for (file_counter=trc->num_file_data; file_counter<(num_work_files-1); file_counter++) 
    {
       if ( getFileInfo(trc, trc->file_index[file_counter].file_name, file_counter, &info) != 1 ) 
       {
         strcat(drvError, "(createTrace)");
         trc = free_opened_trace(trc);
         return NULL;
       }
    }
 }
 // ����������������� ������ ����� ����������� ��������� ������ �����������
 // ��� ���������� ���������� ������������ ����� ������
     
 open_trace_counter++;
 // ������� ������

  for (file_counter=0; file_counter<trc->num_file_data; file_counter++) {
   
        trc->file_index[file_counter].file_data = NULL;
   }; //   for (file_counter=0; file_counter<P_trace->num_file_data ;file_counter++)



 return trc;
} // T_OPENED_TRACE *createTrace(

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
    initTraces();
   default:
    break;
  };
 return TRUE;
}