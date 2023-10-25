// Krotepro.h - ���������  ��� ������ Krotepro.c.
// ���������� ���������� ��������, ������ � ���������������� ������� ��������
// ��������� ������ ������������ ����� "epro" ���������� KrotW32
//

#ifndef _KROT_EPRO_H_
#define _KROT_EPRO_H_

#pragma warning(disable : 4996) // for VC 8.00

//#define CALL_LOG

#include "int_unit.h"
#include "krtapi2.h"
#include "fileTool.h"
#include "iniTool.h"

#define PI  3.14159265359

// ������� ������ ������ ��������
#define DRIVER_VER_MAX   1
// ������� ������ ������ ��������
#define DRIVER_VER_MIN   0
// ������������ ��������� ������ API 
#define DRIVER_API_VER   KRT_APIVER2


#define KRT_OK  0
#define KRT_ERR 1

#define NUM_BIT_IN_BYTE 8 

#define MAX_TRACE  100  // ������������ ���������� �������� ������������ �������

#define MAX_GROUP_NUM      8   // ����������� ��������� ���-�� ������
                                // ��� ������� ��������                  

#define CORROSION_SENS_TYPE  u16 // ��� (������) ������ ��������

#define MAX_CORROZION_NUM  512  // ����������� ��������� ���-�� ��������
                                // ��� ������� ��������


#define MAX_PROFILE_CALIBRATE 128 // ������������ �������� ������������� �����

#define MAX_SMOOTH_WIN_LENGTH  64 // ����������� ��������� ������ ���� 
                                  // ����������� ������
                                  // ��� ������� ��������
                                  // ��� ���������� ��������

#define SENS_DATA  WORD // ��� (������) ������ ��������


#define OUTER_STEP      10

// ����.�������� ������ �����.��������
#define MAX_DAT_VAL  3993

#define FULL_SPIN           1  // �������� T_SEAM.complete_spin
                               // ���������� ��� � �������� ��� ������ ������
#define NOT_FULL_SPIN       0  // �������� T_SEAM.complete_spin
                               // ���������� ��� � �������� ��� �� ������ ������

// ������ ���� � ������� 12 * 60 ��� = 720 ���
#define FULL_CIRCLE       720

#define SENSE_DELETE_FLAG 0xFFFF

#define EPRO_SECTION    DRIVER_DATA

#define FIRST_FILE_NAME "d00000.cmp"
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


#define MAX_DATA_CODE_KEY            "max_data_code"
#define PATH_DATA_KEY                "path_data"
#define FIRST_FILE_NAME_KEY          "first_file_name"
#define FIRST_FILE_INDEX_KEY         "first_file_index"
#define TRACE_STEP_KEY               "trace_step"
#define TRACE_LEN_KEY                "trace_len"
#define CORROSION_SENS_NUM_KEY       "corroson_sens_num"
#define GROUP_NUM_KEY                "group_num"
#define LINESENSE_SIZE_KEY           "linesense_size"
#define Delete_sens_data_KEY         "Delete_sens_data"
#define SENS_SORT_KEY                "sens_sort"

#define Amplification_Group0_KEY      "Amplification_Group0"
#define Amplification_Group1_KEY      "Amplification_Group1"
#define Amplification_Group2_KEY      "Amplification_Group2"
#define Invert_sens_data_KEY         "Invert_sens_data"
#define Smooth_data_OFF_KEY          "Smooth_data_OFF"
#define Smooth_win_length_KEY        "Smooth_win_length"
#define Median_smooth_KEY            "Median_smooth"
#define razvorot_1_skanera_KEY       "razvorot_1_skanera"
#define razvorot_2_skanera_KEY       "razvorot_2_skanera"
#define razvorot_3_skanera_KEY       "razvorot_3_skanera"
#define Skan_2_Shift_KEY             "Skan_2_Shift"
#define Skan_3_Shift_KEY             "Skan_3_Shift"


#define PROFIL_INI_FILE_NAME   "calibrat.prf"
#define PROFILE_SECTION        "Profile_calidrate"
#define Profil_calibrate_KEY   "profil"

/*
#define TRACE_TIME_KEY               "trace_time"
#define MAX_DATA_CODE_KEY            "max_data_code"
#define SENS_SHIFT_KEY               "sens_shift"
#define Orientation_shift_2_KEY      "Orientation_shift_2"
#define Orinteation_Direct_count_KEY "Orinteation_Direct_count"
#define Amplification_Group_KEY      "Amplification_Group"
#define Invert_sens_data_KEY         "Invert_sens_data"
#define Smooth_win_length_KEY        "Smooth_win_length"
#define Sckip_sens_data_KEY          "Sckip_sens_data"
#define sens_for_thick_KEY           "sens_for_thick"
#define sens_for_thick_count_KEY     "sens_for_thick_count"
#define Smooth_data_OFF_KEY          "Smooth_data_OFF"
#define adc2tesla_koef_KEY           "adc2tesla_koef"
*/



///////////////////////////////////////////////////////////
// �������� ������ ��� ������ � ������� ������ ������
///////////////////////////////////////////////////////////

  // �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)

// �������� �����
typedef struct 
{
    char   str[10];
    u16  num_sens;
    u8   num_test_in_block;
    u8   reserved;
    u8   pressure;
    u8   status_file;   //
                        //
} T_File_Head;

typedef struct {  // ������ ������������� ����������
   u32  odometr;
   u8  odometr_1;
   u8  check_sum;
   u16 reserved;
   u32  vmt;
   u16  voltag_battery;
   u16  num_poweron;
   u8   status; // bit 7 - ���� ���
                // bit 0 - �����������

   u32  reserved1;
   u32  size_arc;
   u32  time;
} T_Koord_data;

typedef struct {
   s8 num_repeat;
   s8 num_bit;
} ARC_TABLE_REC;

typedef struct {
   s32 beg_trace;
   s32 lenght;
   s32 beg_poperd;
   s32 first_test_in_block;
   s32 vmt;
   s32 time;
   s32 direct_prod_put;
   s32 shift_in_file;
   s32 file_num;
   s32 num_block_in_spin;
   s32 property;
} T_IDX_TRC;

typedef struct {
   s32 num_idx_in_table;
   s32 MAX_num_idx_in_table;

   s32 first_file_index;
   s32 trace_len;          // ������ ������ � �������� ��������
   s32 trace_time;
   s32 num_test_in_block;
   s32 num_sens;
} T_IDX_HEADER;


// ������������ � ������������ �� ���������
#pragma pack ()

// ������ ��������� ���������� �� �������������� ��������:
typedef struct {
   long time;
   long orient;
   long termo;
   long Thick;
} T_RECORD_EXTEND_SENS;
// ������ ��������� ���������� �� �����:

typedef struct {        // �������� ������ ������ ����� ������
   DWORD poperd_put;
   DWORD prod_put;

   SENS_DATA *sens;       // ������� ��������
   SENS_DATA *math_sens;  // ������������� ������� ��������
   SENS_DATA Thick;       // �������
   long direct_prod_put;

} T_INQUIRY;


// ��������� �������� ������� ������� �������� ��������������
typedef struct {   
 T_ArrivedData odo; // ��������� � ���������� ��������� � ������ � ����� ����������� ��������
 long itemNum;      // ���������� ��������� �� ������ (������ ������� item)
 short isComplete;  // FULL_SPIN, ���� ������ ������, 
                    // NOT_FULL_SPIN ���� �������� (���������, ������, �����)
 T_INQUIRY * item;
} T_SPIN_INFO;


typedef struct {  // �������� �������� ������

   // ��������� �� ������-������� ���������� � ����������� ����� ������
   long  (KRTAPI *newDataRegistered) (T_ArrivedData *newData);
   long virtSens;            // ���-�� ����������� �������� (������� �� ������)
   long virtLength;          // ����������� ����� ������
   long isOdoNotUse;         // ����� ����������� ��������� ����/������
   long topShift;            // �������� ������� ������� ����� � ��������
//   long orient_direct_count; // ����������� ��������� ����������
   long secondScanShift;     // �������� ������� ������� ������������ ������� � ��������
   long thirdScanShift;      // �������� �������� ������� ������������ ������� � ��������
   long  trace_len;          // ������ ������ � �������� ��������
   long  trace_step;         // ������ ���� �������� � ��
   long  trace_time;         // ����� ������ �� ������ � ������������
//   T_THICK thick;            // ������ �������

   char trc_file_name[_MAX_PATH];

   double sens_step; // ��� ��������

   char  path_data[_MAX_PATH];       // ���� �� ����� � ������� ������
   char  first_file_name[_MAX_PATH]; // ��� ������� ����� ������

   char  idx_file_name[_MAX_PATH];   // ��� ����� �������� c ������ �����

//   long  num_file_data;      // ���������� ������ � ������

   char file[_MAX_PATH];     // ��� trc-����� � ������ �����

//   long frequency_processor;

   long group_num;

   long linesense_size[MAX_GROUP_NUM];

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
   long razvorot_3_skanera;

   long Skan_2_Shift;
   long Skan_3_Shift;

   T_IDX_HEADER idx_head;
   T_IDX_TRC *idx_trc;


   long nodeType;
   long nodeIndex;
   long nodePos;
   double controlSize;

 // ����� ���������� �������g etFirstSpin � getNextSpin ����������� ������:
//   T_SPIN_INFO current_spin; // ������� ����������� ������ ������ �������
//   long current_file;        // ������� ���� � �������
//   long current_seam;        // ������� �������� ��� (������) ������ �����

} T_OPENED_TRACE;


typedef struct {  /* curent parametrs for group external sensors*/
   long  sensTypeGroup;     // ������� ��� ��������������� �������
   long  sensPos;           // ������� ������� ��������� ���. �������
   float controlSize;       // ��� ����������� ������ �����
   long  startPos;
} T_PAR_NODEGROUP;



typedef struct { // ��������� ������ ���� ������ �������� �����
   long handle;            // �������� ������������� �������� ������
   T_OPENED_TRACE * trace; // ��������� �� ������ �������� ������

   T_PAR_NODEGROUP cur_par_nodeGroup;

} T_TRACE_LIST;

extern char drvError[];

extern T_TRACE_LIST trace_list[];
extern long open_trace_counter;

extern long Gary_not_arc( T_OPENED_TRACE *P_trace, long spin_num, T_SPIN_INFO * spin_info);
extern T_OPENED_TRACE *createTrace(const char * traceFile, KRTHANDLE handle);
extern T_OPENED_TRACE * getTrace(KRTHANDLE handle);


extern T_INQUIRY * WINAPI free_inquiry(T_INQUIRY *p_free);
extern T_OPENED_TRACE * WINAPI free_opened_trace( T_OPENED_TRACE *p_free);

#include "reciever.h"


#endif