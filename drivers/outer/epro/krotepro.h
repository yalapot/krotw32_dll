// Krotepro.h - ���������  ��� ������ Krotepro.c.
// ���������� ���������� ��������, ������ � ���������������� ������� ��������
// ��������� ������ ������������ ����� "epro" ���������� KrotW32
//

#ifndef _KROT_EPRO_H_
#define _KROT_EPRO_H_

//#define KROT_DEBUG

#include "krtapi2.h"
#include "thick.h"

// ������� ������ ������ ��������
#define DRIVER_VER_MAX   1
// ������� ������ ������ ��������
#define DRIVER_VER_MIN   0
// ������������ ��������� ������ API 
#define DRIVER_API_VER   KRT_APIVER2
// ������������ ��������� ����� ��� ����� � �� 
// ����� ����������� ������� 85 �� , �������� � ������� 16 ��
#define OUTER_STEP      10
// ����.�������� ������ �����.��������
#define MAX_DAT_VAL  4095

// ������ ���� � ������� 12 * 60 ��� = 720 ���
#define FULL_CIRCLE       720

#define byte    BYTE
#define short   SHORT
#define word    WORD
#define dword   DWORD

#define KRT_OK  0
#define KRT_ERR 1

#define NOT_EMPTY (0)
#define EMPTY (-1)

#define MAX_TRACE  1000             // ������������ ���������� �������� ������������ �������

#define MAX_FILE_IN_TRACE  4096

#define MAX_SEAM_LENGTH    5000

#define FIRST_FILE_NAME "tm00000.da"
#define INDEX_FILE_NAME "trace.idx"

#define INI_SECT         "Settings"
#define INI_DATA         "DataFolder"
#define INI_DATALEN      "RecordLength"
#define INI_SENSNUM      "VirtualSensors"
#define INI_TOPSHIFT     "TopShift"

#define INI_DATALEN_DFLT 10000
#define INI_SENSNUM_DFLT 640
// �������� ������� ������� ����� � ������� (2.5 ���� = 150 ���)
#define TOP_SHIFT_MINUTES 370

#define KEY_DATA         "Data"
#define KEY_DATLEN       "RecordLength"
#define KEY_SENSNUM      "VirtualSensors"
#define KEY_VERT         "NotUseOdo"
#define KEY_SENS_STEP    "Sens_step"


#define FIRST     0  // �������� T_FILE_HEADER.flag_file_first_after_start
                     // ���������� ��� ���� ������ ����� �������
#define NOT_FIRST 1  // �������� T_FILE_HEADER.flag_file_first_after_start
                     // ���������� ��� ���� �� ������ ����� �������          

#define FULL_SPIN           1  // �������� T_SEAM.complete_spin
                               // ���������� ��� � �������� ��� ������ ������
#define NOT_FULL_SPIN       0  // �������� T_SEAM.complete_spin
                               // ���������� ��� � �������� ��� �� ������ ������

#define DESCRIPTOR_LEN    32  // ������ ����������� � ������

// �������� ��������� ����� ������������:
#define DESCRIPTOR_CONDITION_SEAM  '0' // '0'- ��������� ��������� ��� 
#define DESCRIPTOR_START_PROGRAM   '1' // '1'- ��������� � ������ �����.
#define DESCRIPTOR_OFF_UVD         '2' // '2'- ��������� � ���������� ���
#define DESCRIPTOR_ON_UVD          '3' // '3'- ��������� � ��������� ���
#define DESCRIPTOR_BEGIN_STOP      '4' // '4'- ��������� � ������ �������
#define DESCRIPTOR_END_STOP        '5' // '5'- ��������� �� ��������� �������

#define VER_FILE_VNSHN   0x31313046  // ��������� ������ ������   
                                     // ��� ��. ����� "vnshn" : "F011"

#define SENS_DATA  WORD // ��� (������) ������ ��������
                                       // ��� ��. ����� "vnshn" : "F011"

#define ProcFrequencyType  hyper

// ������ �������������� ������ � ����� ����� ��������� ��� ������� "F011": 
#define PADDING_F011_SIZE (4+4+8+8+4+4+4)//(������ �� ���� ������ ��������� ��������)
                       //  ^ ^ ^ ^ ^ ^ ^ 
                       //  | | | | | | +- dword  orient;  // ���������� ���� �� �����
                       //  | | | | | +- dword  prod_put;  // ������� ����������� ���� �� �����
                       //  | | | | +- dword  poperd_put; // ������� ������������� ���� �� �����
                       //  | | | +- hyper takt_in_ADC; // ������� ������ �� ������� ���������
                       //  | | +- hyper takt_in_odom; // ������� ������ �� ��������� ��������
                       //  | +- dword ADC_counter;   // ������� ���
                       //  +- dword odom_counter;   // ������� ��������
                       // ��� ��. ����� "vnshn" : "F011"


#define MAX_CORROZION_NUM  128  // ����������� ��������� ���-�� ��������
                                // ��� ������� ��������

#define MAX_GROUP_NUM      8   // ����������� ��������� ���-�� ������
                                // ��� ������� ��������                  

#define MAX_SMOOTH_WIN_LENGTH  64 // ����������� ��������� ������ ���� 
                                  // ����������� ������
                                  // ��� ������� ��������

#define SENSE_DELETE_FLAG 0xFFFF


#define EPRO_SECTION    "DriverData"

#define TRACE_STEP_KEY               "trace_step"
#define FIRST_FILE_NAME_KEY          "first_file_name"
#define INDEX_FILE_NAME_KEY          "index_file_name"
#define CORROSION_SENS_NUM_KEY       "corroson_sens_num"
#define GROUP_NUM_KEY                "group_num"
#define MAX_DATA_CODE_KEY            "max_data_code"
#define Amplification_Group0_KEY      "Amplification_Group0"
#define Amplification_Group1_KEY      "Amplification_Group1"
#define Invert_sens_data_KEY         "Invert_sens_data"
#define Smooth_data_OFF_KEY          "Smooth_data_OFF"
#define Smooth_win_length_KEY        "Smooth_win_length"
#define Median_smooth_KEY            "Median_smooth"
#define razvorot_1_skanera_KEY       "razvorot_1_skanera"
#define razvorot_2_skanera_KEY       "razvorot_2_skanera"
#define SENS_SORT_KEY                "sens_sort"
#define orient_direct_count_KEY      "orient_direct_count"
#define Skan_2_Shift_KEY             "Skan_2_Shift"


#define IDX_FILE_NAME                "trace.idx"

#define AVERAGE_LENGTH_ORIENT     8 // ������ ���� ����������� ����������

///////////////////////////////////////////////////////////
// �������� ������ ��� ������ � ������� ������ ������
///////////////////////////////////////////////////////////

  // �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)  

// ��������� �����
typedef struct {   
   hyper ver_file;       // ������ ������� ������ �����
   char  target_name[16];// �������� ������� ��� �������� �������� ��
   char  ver_po[16];     // ������������� � ������ �������� ��������� ��������� ����

   hyper proc_frequency; // ���-�� ������ ���������� ����� �������� ����. �������
   word  cor_num;        // ���-�� ������������ ��������

   byte  flag_file_first_after_start;

   byte  reserved[13];
} T_FILE_HEADER;

typedef struct {    // �������� �����������
   dword ver_file;       // ������ ������� ������ �����
   byte  descriptor_type; // ��� ����������� (DESCRIPTOR_CONDITION_SEAM)
   byte  reserv1;        // �����
   word  descriptor_Size;// ������ ������ �����������
} T_DESCRIPTOR;

typedef struct {    // �������� ��������� ��������� ���
   dword real_dim;       // �������� ���-�� ��������� � ������. ���
   dword beg_odom;       // �����.�� ���.������ �� ������ ��� ��� � �������� �������� 
   dword end_odom;       // �����.�� ���.������ �� ����� ��� ��� � �������� �������� 
   byte  del_bit;        // ����� ������� ����� ��������
   word  skip_dim;       // ������� ��������� ������������ ���������
   byte  complete_spin;  // ���� ���� ��� ������ �������������� � ���� �������� ��� ������
   dword time_10ms;      // ��������� ���������� �������, ������������ �� 10 ��
   dword arc_size;       // ������ �������� ������ � �����������
} T_SEAM;


typedef struct {        // �������� ������ ������ ����� ������
   dword odom_counter;    // ������� ��������
   dword ADC_counter;     // ������� ���
   hyper takt_in_odom;    // ������� ������ �� ��������� ��������
   hyper takt_in_ADC;     // ������� ������ �� ������� ���������
   dword poperd_put;
   dword prod_put;
   word src_poperd_put;    // ������� ������������� ���� �� �����  
   word src_prod_put;      // ������� ����������� ���� �� �����  

   SENS_DATA *sens;       // ������� ��������
   SENS_DATA *math_sens;  // ������������� ������� ��������
   SENS_DATA Thick;       // �������
   long direct_prod_put;

} T_INQUIRY;

#pragma pack ()
  // ������������ � ������������ �� ���������


// ��������� ������ ���� ������ �������� ����������� ������
typedef struct T_LOADED_DATA { 
   long file; // ����� ���� �� �������� ��������� ������
   long seam; // ����� ���.��� � ����� �� �������� ��������� ������

   struct T_LOADED_DATA *Next_element;
} T_LOADED_DATA;


// ������ ��������� ���������� �� ��������� ���:
typedef struct { 
   long  beg_track; // �����. �� ���.������ �� ������ ���.��� � �������� ��������
   long  end_track; // �����. �� ���.������ �� ����� ���.��� � �������� ��������
   long  shift_in_file;   // �������� ���������� ���.��� � ����� ������
   hyper beg_time;  // ����� � ������ ���������� �� ������ ������ �� ������ ��������� ���. ���
   hyper end_time;  // ����� � ������ ���������� �� ������ ������ �� ��������� ��������� ���. ���

   long  smooth_orientation_beg;
   long  global_number_seam;
   byte pred_src_prod_put;
   long start_seam;
   long init_direct_prod_put;
   long next_direct_prod_put;

   T_SEAM     *head_of_condition_seam; 
                        // ^^^ ��������� ��������� ���
   T_INQUIRY  *inquiry;
              // ^^^ ������ ������ ��������� ���

   long *smooth_data_beg;   // ������ �������� ����������� ������

} T_INDEX_SEAM;

// ������ ��������� ���������� �� �����:
typedef struct {
   char  file_name[_MAX_PATH];  // ��� ����� ������
   long  beg_track; // �����. �� ���.������ �� ������ ����� � �������� ��������
   long  end_track; // �����. �� ���.������ �� ����� ����� � �������� ��������
   long  num_condition_seam;  // ���������� �������� ���� � �����

   T_INDEX_SEAM *index_seam;  // ��������� �� ������ ��������� ������ �� ���.����

   FILE *file_data;          // ���������� ��������� ����� ������
} T_INDEX_FILE;

// ��������� �������� ������� ������� �������� ��������������
typedef struct {   
 T_ArrivedData odo; // ��������� � ���������� ��������� � ������ � ����� ����������� ��������
 long itemNum;      // ���������� ��������� �� ������ (������ ������� item)
 short isComplete;  // FULL_SPIN, ���� ������ ������, 
                    // NOT_FULL_SPIN ���� �������� (���������, ������, �����)
 T_INQUIRY *item;   // ��������� �� ������ ������� ������� ��������� (�������� itemNum)
} T_SPIN_INFO;

typedef struct {  // �������� �������� ������

   // ��������� �� ������-������� ���������� � ����������� ����� ������
   long  (KRTAPI *newDataRegistered) (T_ArrivedData *newData);
   long virtSens;            // ���-�� ����������� �������� (������� �� ������)
   long virtLength;          // ����������� ����� ������
   long isOdoNotUse;         // ����� ����������� ��������� ����/������
   long topShift;            // �������� ������� ������� ����� � ��������
   long orient_direct_count; // ����������� ��������� ����������
   long secondScanShift;     // �������� ������� ������� ������������ ������� � ��������
   long  trace_len;          // ������ ������ � �������� ��������
   long  trace_step;         // ������ ���� �������� � ��
   long  trace_time;         // ����� ������ �� ������ � ������������
   T_THICK thick;            // ������ �������

   double sens_step; // ��� ��������


   char  path_data[_MAX_PATH];       // ���� �� ����� � ������� ������
   char  first_file_name[_MAX_PATH]; // ��� ������� ����� ������

   char  idx_file_name[_MAX_PATH];   // ��� ����� �������� c ������ �����

   long  num_file_data;      // ���������� ������ � ������

   char file[_MAX_PATH];     // ��� trc-����� � ������ �����

   dword frequency_processor;

   long sens_sort[MAX_CORROZION_NUM];

   // ������ ����� ����� ��������� ������ � ������� �� ������� �������� �������� !!!
   long sensInGroup;  // ���-�� ����������� �������� � ����� �������. 

   long corosion_sens_num;  // ���-�� ����������� �������� � ������
   long Amplification_Group[MAX_GROUP_NUM]; // ������� �������� � �����|����� �� ���-�� ��������)

   long max_data_code;

   char invert_sens_data_text[1024];
   long invert_sens_data[MAX_CORROZION_NUM];

   long Smooth_data_OFF;
   long smooth_win_length;
   long Median_smooth;

   long razvorot_1_skanera;
   long razvorot_2_skanera;

   long Skan_2_Shift;

   T_INDEX_FILE *file_index; // ��������� �� ������ ��������� ������  �� ������

   T_LOADED_DATA *list_loaded_data;

   long nodeType;
   long nodeIndex;
   long nodePos;
   double controlSize;

 // ����� ���������� �������g etFirstSpin � getNextSpin ����������� ������:
   T_SPIN_INFO current_spin; // ������� ����������� ������ ������ �������
   long current_file;        // ������� ���� � �������
   long current_seam;        // ������� �������� ��� (������) ������ �����

#ifdef KROT_DEBUG
   FILE *log;
#endif
   
} T_OPENED_TRACE;


typedef struct { // ��������� ������ ���� ������ �������� �����
   long handle;            // �������� ������������� �������� ������
   T_OPENED_TRACE * trace; // ��������� �� ������ �������� ������
} T_TRACE_LIST;


///////////////////////////////////////////////////////
// �������� ������ ��� ������������� LZW
///////////////////////////////////////////////////////
#define CLEARE_CODE        256              /* ��� ������� ������� �����  */
#define END_DATA_CODE      (CLEARE_CODE+1)  /* ��� ����� ������ (�� ���.) */
#define SOURCE_TABLE_LEN   (END_DATA_CODE+1)/* ��������� ������ �������   */
                                            /* (����� �������)            */ 

#define MAX_CODE           65535            /* ������ ������� �����       */

#define ARC_SIZE_FIELD_LEN 4  // ������ � ������ ���� � ������� (� ������)
                              // ������������ ������������������ ��������
                              // ������ (���� ������� � ���� �� ���. ����)

typedef struct {   /* ���� ���� ������� ����� */
  word prefics;    /* ������� ������� ������������������            */
  byte last_char;  /* ��������� ������ � ������� ������������������ */
} T_CODE_SERCH_REC;
  
typedef struct {   /* �������� ������� ����� */
  word char_table_len;          /* ������� ������ ������� �����     */
  T_CODE_SERCH_REC char_table[MAX_CODE+1];  /* ������ �������� �����  */
} T_CODE_SERCH_TABLE;

extern char *traceFile; // ���������� ��� ����� trc

extern char drvError[];
extern T_TRACE_LIST trace_list[];
extern long open_trace_counter;

extern void initTraces(void);
extern long init_bort_factor_data(T_OPENED_TRACE *trc);
extern long read_data_from_trc(T_OPENED_TRACE *trc);

// ������� ��������� ������ ��� ��������� �������� ������
//(���� ����������� T_OPENED_TRACE)
// ��� ���� ���������� ��� ���� � ��� ����� � ��� ��������� 
extern T_OPENED_TRACE * WINAPI init_opened_trace();

// ������� ������������ ������ ��� ���������� �������� ������
//(���� ���������� T_OPENED_TRACE)
// ���������� NULL, ���� ��� ������, ����� - ��� �� �����
extern T_OPENED_TRACE * WINAPI free_opened_trace
    (
     T_OPENED_TRACE *p_free
    );

// ������� ������������ ������ ��� ���������� �������� ������ � �������� ������
//(���� ���������� T_INDEX_FILE)
// ���������� NULL, ���� ��� ������, ����� - ��� �� �����
extern T_INDEX_FILE* WINAPI free_index_files
    (
     T_INDEX_FILE* p_free,
     long num_file_data
    );

// ������� ������������ ���� � ������� ������
extern long WINAPI init_name_files
    (
     T_OPENED_TRACE *p_trace
    );


// ������� ��������� ������ ��� ������ �������� �������� ���� � �������� ������
// (���� ����������� T_INDEX_SEAM)
// ��� ���� ���������� ��� ����  T_INDEX_SEAM
extern T_INDEX_SEAM * WINAPI init_index_seams
    (
     long num_condition_seam
    );

// ������� ������������ ������ ��� ������ �������� �������� ���� � �������� ������
//(���� ���������� T_INDEX_SEAM)
// ���������� NULL, ���� ��� ������, ����� - ��� �� �����
extern T_INDEX_SEAM * WINAPI free_index_seams
    (
     T_INDEX_SEAM *p_free,
     long num_condition_seam
    );

// ������� ��������� ������ ��� ������ �������� ������������ ���������
// ������������� ���� smooth_data_beg � ��������� T_INDEX_SEAM
long * WINAPI init_smooth_data_beg
    (
      long  cor_num
    );

// ������� ������������ ������ ��� ������  �������� ������������ ���������
long * WINAPI free_smooth_data_beg
    (
      long *p_free
    );

// ������� ��������� ������ ��� ����������
// (���� ����������� T_DESCRIPTOR_TEMPLATE)
// ���� �� ���������� ������ ��������� ������
extern T_SEAM * WINAPI init_condition_seam();

// ������� ������������ ������ ��� ������������
// (���� ���������� T_DESCRIPTOR_TEMPLATE)
// ���������� NULL, ���� ��� ������, ����� - ��� �� �����
extern T_SEAM * WINAPI free_condition_seam
    (
     T_SEAM *p_free
    );

// ������� ��������� ������ ��� ������ ���������
// (���� ����������� T_RECORD_OF_ONE_CYCLE_INQUIRY)
// ���� �� ���������� ������ ��������� ������
extern T_INQUIRY * WINAPI init_inquiry
    (
     long  cor_num,
     long  dim_num
    );

// ������� ������������ ������ ��� �������� ���������
// (���� ���������� T_DESCRIPTOR_TEMPLATE)
// ���������� NULL, ���� ��� ������, ����� - ��� �� �����
extern T_INQUIRY * WINAPI free_inquiry
    (
     T_INQUIRY *p_free
    );

// ������� �������� �������� ������ � ��������� ��������� ������ �� �����
extern T_OPENED_TRACE *creation_trace(const char * trc_file);

// ������� ��������� ������ ��� ��� ���� ����������� ������
// (���� ����������� T_LOADED_DATA)
extern T_LOADED_DATA *init_loaded_data ();

// ������� ������������ ������ ��� ����� ����������� ������
// (���� ���������� T_LOADED_DATA )
extern T_LOADED_DATA *free_loaded_data 
    (
      T_LOADED_DATA * p_free
    );

// ������� ���������� ���� ����������� ������ � ����� ������
extern long add_loaded_data_in_list
    (
      T_LOADED_DATA * list,
      long file,
      long seam
    );

// ������� �������� ���� ����������� ������ �� ����� ������
extern T_LOADED_DATA * del_loaded_data_in_list(T_LOADED_DATA * list);

// ������� ������������ ������ ��� ������� ����������� ������
// (���� ���������� ������� T_LOADED_DATA )
extern T_LOADED_DATA *free_list_loaded_data (T_LOADED_DATA * p_free);

// ������� ��������� ����������� � ����� ������ fileName ��������� info
// ���������� 1 ��� ������, 0 ��� ������. �������� ������ � drvError
extern long getFileInfo ( 
 T_OPENED_TRACE *trace, 
 const char *fileName,  
 long fileIndex, 
 T_ArrivedData *info
 );

// ������� ���� ������ ������ �������� �������������� ��� �������� traceDist 
// (� ����� ����������� �������� �� ������ ������) � ��������� ����������� � 
// ��� ��������� spin
// ��� ������� ���������� ���������� 1, ��� ������ 0. �������� ������ ����������
// � ���������� drvError
extern short getFirstSpin(
  T_OPENED_TRACE *trace,
  long traceDist,
  T_SPIN_INFO *spin
);

// ������� ��������� ��������� spin ����������� � ��������� �� ������� ������� 
// (����� ����������� ������ getFirstSpin ��� getNextSpin)
// ��� ������� ���������� ���������� 1, ��� ������ 0. �������� ������ ����������
// � ���������� drvError
extern short getNextSpin(T_OPENED_TRACE *trace, T_SPIN_INFO *spin);

extern const char * KRTAPI krtDrvError(void);
extern T_OPENED_TRACE * getTrace(KRTHANDLE handle);
extern long WINAPI krtDrvGetNextNode ( KRTHANDLE handle, T_NODE *node);
extern long WINAPI krtDrvGetFirstNode (KRTHANDLE handle, T_NODE *node, long start, long sensType, long sensIndex, long length, long controlSize );
extern T_OPENED_TRACE *createTrace(const char * traceFile, KRTHANDLE handle);
extern void updateThickData(T_OPENED_TRACE *trc, long pos);

#endif