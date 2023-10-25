// Krotepro.h - ���������  ��� ������ Krotepro.c.
// ���������� ���������� ��������, ������ � ���������������� ������� ��������
// ��������� ������ ������������ ����� "epro" ���������� KrotW32
//

#ifndef _KROT_EPRO_H_
#define _KROT_EPRO_H_

#include "navigate.h"

//#define CALL_LOG

#define byte    BYTE
#define short   SHORT
#define word    WORD
#define dword   DWORD

#define KRT_OK  0
#define KRT_ERR 1

#define MAX_TRACE  8  // ������������ ���������� �������� ������������ �������

#define DESCRIPTOR_LEN    32  // ������ ����������� � ������

// �������� ��������� ����� ������������:
#define DESCRIPTOR_CONDITION_SEAM  '0' // '0'- ��������� ��������� ��� 
#define DESCRIPTOR_START_PROGRAM   '1' // '1'- ��������� � ������ �����.
#define DESCRIPTOR_OFF_UVD         '2' // '2'- ��������� � ���������� ���
#define DESCRIPTOR_ON_UVD          '3' // '3'- ��������� � ��������� ���
#define DESCRIPTOR_BEGIN_STOP      '4' // '4'- ��������� � ������ �������
#define DESCRIPTOR_END_STOP        '5' // '5'- ��������� �� ��������� �������

#define VER_FILE_EPRO   0x30313046L  // ��������� ������ ������   
                                     // ��� ��. ����� "epro" : "F010"

#define VER_FILE_EPRO_15  0x35313046L  // ��������� ������ ������   
                                     // ��� ��. ����� "epro" : "F015"

#define VER_FILE_EPRO_2 0x30323046L  // ��������� ������ ������   
                                     // ��� ��. ����� "epro" : "F020"

#define VER_FILE_EPRO_3 0x30333046L  // ��������� ������ ������   
                                     // ��� ��. ����� "epro" : "F030"

#define VER_FILE_EPRO_31 0x31333046L  // ��������� ������ ������   
                                      // ��� ��. ����� "epro" : "F031"

#define VER_FILE_EPRO_32 0x32333046L  // ��������� ������ ������   
                                      // ��� ��. ����� "epro" : "F032"

#define EPRO_CORROSION_SENS_TYPE  WORD // ��� (������) ������ ��������
                                       // ��� ��. ����� "epro": F0XX

// ������ �������������� ������ � ����� ����� ��������� ��� ������� "F010": 
#define PADDING_F010_SIZE (2+8+1+1+2+1+4+4+4)//(������ �� ���� ������ ��������� ��������)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^
                       //  | | | | | | | | +- ���� II ��. �� ����
                       //  | | | | | | | +- ���� I ��. �� ����
                       //  | | | | | | +- ���. ���� �� ����
                       //  | | | | | +- ��������
                       //  | | | | +- ����������
                       //  | | | +- �����������
                       //  | | +- ����� ��������
                       //  | +- ����� ����������
                       //  +- ���������� ��������� � �������� ���������
                       // ��� ��. ����� "epro" : "F010"


// ������ �������������� ������ � ����� ����� ��������� ��� ������� "F020":
#define PADDING_F020_SIZE (2+8+1+1+2+1+4+4+4+4+2+2+1)//(������ �� ���� ������ ��������� ��������)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
                       //  | | | | | | | | | | | | + ����� ��, ������������ ���������
                       //  | | | | | | | | | | | +- accel_y
                       //  | | | | | | | | | | +- accel_x
                       //  | | | | | | | | | +- ���� �� ���� ������ ������
                       //  | | | | | | | | +- ���� II ��. �� ����
                       //  | | | | | | | +- ���� I ��. �� ����
                       //  | | | | | | +- ���. ���� �� ����
                       //  | | | | | +- ��������
                       //  | | | | +- ����������
                       //  | | | +- �����������
                       //  | | +- ����� ��������
                       //  | +- ����� ����������
                       //  +- ���������� ��������� � �������� ���������

#define POWER_LINE_NUM 8

// ������ �������������� ������ � ����� ����� ��������� ��� ������� "F030":
#define PADDING_F030_SIZE (2+8+1+1+2+1+4+4+4+4+2+2+1+POWER_LINE_NUM+1)//(������ �� ���� ������ ��������� ��������)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^              ^
                       //  | | | | | | | | | | | | | |              +- ����� ��������� ����� ���������
                       //  | | | | | | | | | | | | | +  �������� ���� ����� ��������� 8 ����
                       //  | | | | | | | | | | | | + ����� ��, ������������ ���������
                       //  | | | | | | | | | | | +- accel_y
                       //  | | | | | | | | | | +- accel_x
                       //  | | | | | | | | | +- ���� �� ���� ������ ������
                       //  | | | | | | | | +- ���� II ��. �� ����
                       //  | | | | | | | +- ���� I ��. �� ����
                       //  | | | | | | +- ���. ���� �� ����
                       //  | | | | | +- ��������
                       //  | | | | +- ����������
                       //  | | | +- �����������
                       //  | | +- ����� ��������
                       //  | +- ����� ����������
                       //  +- ���������� ��������� � �������� ���������

#define POWER_LINE_NUM_2 16
// ������ �������������� ������ � ����� ����� ��������� ��� ������� "F031":
#define PADDING_F031_SIZE (2+8+1+1+2+1+4+4+4+4+2+2+1+POWER_LINE_NUM_2+2)//(������ �� ���� ������ ��������� ��������)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^                ^
                       //  | | | | | | | | | | | | | |                +- ����� ��������� ����� ���������
                       //  | | | | | | | | | | | | | +  �������� ���� ����� ��������� 16 ����
                       //  | | | | | | | | | | | | + ����� ��, ������������ ���������
                       //  | | | | | | | | | | | +- accel_y
                       //  | | | | | | | | | | +- accel_x
                       //  | | | | | | | | | +- ���� �� ���� ������ ������
                       //  | | | | | | | | +- ���� II ��. �� ����
                       //  | | | | | | | +- ���� I ��. �� ����
                       //  | | | | | | +- ���. ���� �� ����
                       //  | | | | | +- ��������
                       //  | | | | +- ����������
                       //  | | | +- �����������
                       //  | | +- ����� ��������
                       //  | +- ����� ����������
                       //  +- ���������� ��������� � �������� ���������

// ������ �������������� ������ � ����� ����� ��������� ��� ������� "F032":
#define PADDING_F032_SIZE (2+8+1+1+2+1+4+4+4+4+2+2+1+4+4+POWER_LINE_NUM_2+2)//(������ �� ���� ������ ��������� ��������)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^                ^
                       //  | | | | | | | | | | | | | | | |                +- ����� ��������� ����� ���������
                       //  | | | | | | | | | | | | | | | +-  �������� ���� ����� ��������� 16 ����
                       //  | | | | | | | | | | | | | | +- ���� IV ��. �� ����
                       //  | | | | | | | | | | | | | +- ���� III ��. �� ����
                       //  | | | | | | | | | | | | + ����� ��, ������������ ���������
                       //  | | | | | | | | | | | +- accel_y
                       //  | | | | | | | | | | +- accel_x
                       //  | | | | | | | | | +- ���� �� ���� ������ ������
                       //  | | | | | | | | +- ���� II ��. �� ����
                       //  | | | | | | | +- ���� I ��. �� ����
                       //  | | | | | | +- ���. ���� �� ����
                       //  | | | | | +- ��������
                       //  | | | | +- ����������
                       //  | | | +- �����������
                       //  | | +- ����� ��������
                       //  | +- ����� ����������
                       //  +- ���������� ��������� � �������� ���������

// ������ �������������� ������ � ����� ����� ��������� ��� ������� "F015":
#define PADDING_F015_SIZE (2+8+1+1+2+1+4+4+4+4+2+2+1+POWER_LINE_NUM+1)//(������ �� ���� ������ ��������� ��������)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^              ^
                       //  | | | | | | | | | | | | | |              +- ����� ��������� ����� ���������
                       //  | | | | | | | | | | | | | +  �������� ���� ����� ��������� 8 ����
                       //  | | | | | | | | | | | | + ����� ��, ������������ ���������
                       //  | | | | | | | | | | | +- accel_y
                       //  | | | | | | | | | | +- accel_x
                       //  | | | | | | | | | +- ���� �� ���� ������ ������
                       //  | | | | | | | | +- ���� II ��. �� ����
                       //  | | | | | | | +- ���� I ��. �� ����
                       //  | | | | | | +- ���. ���� �� ����
                       //  | | | | | +- ��������
                       //  | | | | +- ����������
                       //  | | | +- �����������
                       //  | | +- ����� ��������
                       //  | +- ����� ����������
                       //  +- ���������� ��������� � �������� ���������


#define MAX_CORROZION_NUM  4096 // ����������� ��������� ���-�� ��������
                                // ��� ������� ��������

#define MAX_PROFILE_NUM_SENS  256 // ������������ ���-�� ���������� ��������

#define MAX_PROFILE_CALIBRATE 128 // ������������ �������� ������������� �����
                                  // ��� ���������� ��������

#define MAX_GROUP_NUM      16   // ����������� ��������� ���-�� ������
                                // ��� ������� ��������                  

#define MAX_SMOOTH_WIN_LENGTH  64 // ����������� ��������� ������ ���� 
                                  // ����������� ������
                                  // ��� ������� ��������

#define MAX_MEDIAN_FILTER_LENGTH 500


#define MAX_DATA_MEDIAN 4096


#define TARGET_NAME_STRESS1200 "STRESS1200     "
#define TARGET_NAME_CORROS460  "CORROS_460+SIT"
#define TARGET_NAME_COR1400sit "384 EPRO + SIT"
#define TARGET_NAME_COR1000sit "CORROS1000+SIT"
#define TARGET_NAME_STRS700sit "STRESS_700+SIT"
#define TARGET_NAME_PROFIL700  "PROFFILE700+SIT"
#define TARGET_NAME_PROFIL500  "PROFFILE500+SIT"

#define TARGET_NAME_CORROS508  "COROS_508+SIT"
#define TARGET_NAME_CORROS508_2 "CORROS_508+SIT"

#define TARGET_NAME_CORROS426D "CORROS_426+SIT"
#define TARGET_NAME_CORROS426L "PipeScop_426c "
#define TARGET_NAME_PROFIL426  "PROFIL426+SIT"
#define TARGET_NAME_STRESS1400 "PipeScop1400s "
#define TARGET_NAME_COROSS1400 "PipeScop1400c "

#define TARGET_NAME_PROFIL1400  "PipeScop1400p "
#define TARGET_NAME_PROFIL1400D "PROFIL_1400+SIT"

#define TARGET_NAME_COROSS500  "PipeScop500c  "
#define TARGET_NAME_COROSS700  "PipeScop700c  "
#define TARGET_NAME_CORROS300  "CORROS_300+SIT"
#define TARGET_NAME_PROFIL700_2 "PipeScop_700p "
#define TARGET_NAME_PROFIL500_2 "PipeScop_500p "
#define TARGET_NAME_CORROS325   "PipeScop_325c "
#define TARGET_NAME_PROFIL325   "PROFIL_325+SIT"
#define TARGET_NAME_STRESS500   "PipeScop_500s "
#define TARGET_NAME_STRESS1000  "PipeScop_1000s"

#define SENSE_DELETE_FLAG 0xFFFF

#define EPRO_SECTION    DRIVER_DATA //"EPRO_drv_Section"
#define PROFILE_SECTION         "Profile_calidrate"
#define Profile_orient_SECTION  "Orientation_setings"

#define TRACE_LEN_KEY                "trace_len"
#define TRACE_STEP_KEY               "trace_step"
#define TRACE_TIME_KEY               "trace_time"
#define PATH_DATA_KEY                "path_data"
#define FIRST_FILE_NAME_KEY          "first_file_name"
#define NUM_FILE_DATA_KEY            "num_file_data"
#define INDEX_FILE_NAME_KEY          "index_file_name"
#define CORROSION_SENS_NUM_KEY       "corroson_sens_num"
#define GROUP_NUM_KEY                "group_num"
#define MAX_DATA_CODE_KEY            "max_data_code"
#define LINESENSE_SIZE_KEY           "linesense_size"
#define SEKTORS_NUM_KEY              "sektors_num"
#define SENS_NUM_IN_SEKTOR_KEY       "sens_num_in_sektor"
#define SENS_SORT_KEY                "sens_sort"
#define SENS_SHIFT_KEY               "sens_shift"
#define ORIENTATION_MUL_FACTOR_KEY   "orientation_mul_factor"
#define ORIENTATION_dAz_KEY          "Orientation_dAz"
#define ORIENTATION_KAz_KEY          "Orientation_KAz"
#define ORIENTATION_dAy_KEY          "Orientation_dAy"
#define ORIENTATION_KAy_KEY          "Orientation_KAy"
#define Orientation_shift_KEY        "Orientation_shift"
#define Orientation_shift_2_KEY      "Orientation_shift_2"
#define Orinteation_Direct_count_KEY "Orinteation_Direct_count"
#define Orientation_OFF_KEY          "Orientation_OFF"
#define Get_Orient_from_NAV_KEY      "Get_Orient_from_NAV"
#define Get_Orient_from_VOG_KEY      "Get_Orient_from_VOG"
#define Amplification_Group_KEY      "Amplification_Group"
#define Invert_sens_data_KEY         "Invert_sens_data"
#define Smooth_win_length_KEY        "Smooth_win_length"
#define Delete_sens_data_KEY         "Delete_sens_data"
#define Sckip_sens_data_KEY          "Sckip_sens_data"
#define MaxTermo_KEY                 "MaxTermo"
#define MinTermo_KEY                 "MinTermo"
#define sens_for_thick_KEY           "sens_for_thick"
#define sens_for_thick_count_KEY     "sens_for_thick_count"
#define Smooth_data_OFF_KEY          "Smooth_data_OFF"
#define PROFIL_INI_FILE_NAME_KEY     "profil_ini_file_name"
#define Profil_calibrate_KEY         "profil"
#define adc2tesla_koef_KEY           "adc2tesla_koef"
#define Median_Filter_length_KEY     "Median_Filter_length"

#define VogMat_KEY                   "VogMat"
#define VogNav_KEY                   "VogNav"
#define VOG_koeff_umn_KEY            "VOG_koeff_umn"
#define ACCEL_koeff_umn_KEY          "ACCEL_koeff_umn"
#define ShiftNavigation_data_KEY     "ShiftNavigation_data"


#define VogMat_FILE_NAME             "rec.mat"
#define VogNav_FILE_NAME             "rec.vog"

#define IDX_FILE_NAME         "trace.idx"
#define EXT_IDX_FILE_NAME     "ext_idx.idx"
#define PWR_IDX_FILE_NAME     "pwr_idx.idx"
#define BPS_IDX_FILE_NAME     "bypass.idx"
#define PROFIL_INI_FILE_NAME  "calibrat.prf"

#define AVERAGE_LENGTH_ORIENT     16 // ������ ���� ����������� ����������

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

   byte  reserved[14];
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
   byte  cor_num_div;    // �������� ���������� �������� (������ 2)
   dword time_10ms;      // ��������� ���������� �������, ������������ �� 10 ��
   dword arc_size;       // ������ �������� ������ � �����������
} T_CONDITION_SEAM;


typedef struct {        // �������� ������ ������ ����� ������
   word  skip_cycle;    // ������� ����� �������� ������ � ������. ������ 
   hyper proc_tacts;    // ������� ������ ���������� ������ � ������. ������ 
   byte  odom_number;   // ����� ������������� ��������
   byte  termo;         // �����������
   word  orient;        // ����������   
   byte  vibro_1;       // ����������� 1
   dword Pic_ful_track; // �������������� ���� �� ���-����������
   dword Pic_track_1;   // ���� 1-�� �������� �� ���-����������
   dword Pic_track_2;   // ���� 2-�� �������� �� ���-����������
   dword odom_forward;  // ���� �� ���-���������� ������ ������
   word  accel_x;       // ������������ x \  ��� ������� 
   word  accel_y;       // ������������ y /  ����������
   byte service_bit;    // bit0 - ����� ������������� ��������
                        // bit1 - ���� ����������� 1 ��������
                        // bit2 - ���� ����������� 2 ��������
   dword Pic_track_3;   // ���� 1-�� �������� �� ���-����������
   dword Pic_track_4;   // ���� 2-�� �������� �� ���-����������

   byte power_val[POWER_LINE_NUM_2]; // �������� ���� ����� ���������
   word power_flags;                 // ����� ��������� ����� ���������

   EPRO_CORROSION_SENS_TYPE *sens;      // ������� ��������
   EPRO_CORROSION_SENS_TYPE *math_sens; // ������������� ������� ��������

   EPRO_CORROSION_SENS_TYPE Thick;      // �������
} T_RECORD_OF_ONE_CYCLE_INQUIRY;

typedef struct {
   word abs_pressure;
   word diff_pressure;
   word speed;
   byte motor_state;
   byte board_state;
   byte choke_curr_position_ticks;
   byte choke_curr_position_angle;
   byte choke_position;
} T_BYPASS_IDX ;

// ������������ � ������������ �� ���������
#pragma pack ()


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

   T_CONDITION_SEAM               *head_of_condition_seam; 
                                  // ^^^ ��������� ��������� ���
   T_RECORD_OF_ONE_CYCLE_INQUIRY  *inquiry;
                                  // ^^^ ������ ������ ��������� ���

//---------------------------------------------------------------
   long *smooth_data_beg;   // ������ �������� ����������� ������
//------------------------------------------------------------------
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


// ������ ��������� ���������� �� �������������� ��������:
typedef struct {
   long time;
   long orient;
   long termo;
   long Thick;
} T_RECORD_EXTEND_SENS;

// ������ ��������� ���������� �� �������������� ��������:
typedef struct {
   T_RECORD_EXTEND_SENS extend_sens;

   char  file_name[_MAX_PATH];  // ��� ����� ������
   FILE *file_data;          // ���������� ��������� ����� ������


 //  HANDLE hFileMap;
 //  char *map_area_mem;
} T_INDEX_EXTEND_SENS;

// ������ ��������� ���������� �� ������ �������:
typedef struct {
   byte power_lines[POWER_LINE_NUM];
   byte power_flags;
} T_RECORD_POWER_DATA;

typedef struct {
   T_RECORD_POWER_DATA power_data;


   char  file_name[_MAX_PATH];  // ��� ����� ������
   FILE *file_data;          // ���������� ��������� ����� ������

  // HANDLE hFileMap;
  // char *map_area_mem;
} T_INDEX_POWER_LINES;

typedef struct {
   T_BYPASS_IDX bypass_data;

   char  file_name[_MAX_PATH];  // ��� ����� ������
   FILE * file_data;             /* ���������� ��������� ����� ������      */

  // HANDLE hFileMap;
  // char *map_area_mem;
} T_INDEX_BYPASS;

typedef struct {  // �������� �������� ������
   long  trace_len;          // ������ ������ � �������� ��������
   long  trace_step;         // ������ ���� �������� � ��
   long  trace_time;         // ����� ������ �� ������ � ������������

   char  path_data[_MAX_PATH];   // ���� �� ����� � ������� ������
   char  first_file_name[_MAX_PATH];   // ��� ������� ����� ������

   char  idx_file_name[_MAX_PATH];  // ��� ����� �������� c ������ �����

   long  num_file_data;        // ���������� ������ � ������

   char trc_file_name[_MAX_PATH];  // ��� trc-����� � ������ �����

   dword frequency_processor;

   long corosion_sens_num;  // ���-�� ����������� �������� � ������
   long group_num;          // ���-�� ������           |(����������� �������� �
   long linesense_size[MAX_GROUP_NUM];     // ���-�� �������� � ����� |����� �� ���-�� ��������)
   long Amplification_Group[MAX_GROUP_NUM]; // ������� �������� � �����|����� �� ���-�� ��������)

   long sektors_num;
   long sens_num_in_sektor;

   long max_data_code;

   long sens_sort[MAX_CORROZION_NUM];

   long Sckip_sens_data[MAX_CORROZION_NUM];

   long Delete_sens_data[MAX_CORROZION_NUM];
   long real_number_sensor_in_group[MAX_GROUP_NUM];

   char invert_sens_data_text[1024];
   long invert_sens_data[MAX_CORROZION_NUM];

   long max_sens_shift;
   long sens_shift[MAX_CORROZION_NUM];

   double orientation_mul_factor;
   long Orientation_OFF;
   long Orientation_shift;
   long Orientation_shift_2;
   long Orinteation_Direct_count;
   long Get_Orient_from_NAV;
   long Get_Orient_from_VOG;

   long Smooth_data_OFF;
   long smooth_win_length[MAX_GROUP_NUM];
   long Median_Filter_length;

   long MaxTermo;        
   long MinTermo;

   T_INDEX_FILE *file_index; // ��������� �� ������ ��������� ������  �� ������
   
   T_LOADED_DATA *list_loaded_data;

   long nodeType;
   long nodeIndex;
   long nodePos;
   double controlSize;

   T_INDEX_EXTEND_SENS index_extend_sens;
   long sens_for_thick;
   long sens_for_thick_count;
   long profil_calibrate[MAX_PROFILE_NUM_SENS][MAX_PROFILE_CALIBRATE];

   char  target_name[16];// �������� ������� ��� �������� �������� ��

   long VOG_koeff_umn;
   long ACCEL_koeff_umn;

   T_INDEX_POWER_LINES index_power_lines;

   T_INDEX_BYPASS index_bypass;

   long PigL3;

   double  dAz;
   double  KAz;
   double  dAy;
   double  KAy;

   long ShiftNavigation_data;

   FILE *ovalnost_data;
   long add_ext_sens_ovalnost;

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

   // ���������� �������� ����������� ��� ������ � �������������� �������
   T_PAR_NODEGROUP cur_par_nodeGroup;
   T_NAVIGATION_DATA NavData;
   T_VOG_DATA VogData;
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



extern char warnString[];
extern char *traceFile; // ���������� ��� ����� trc
extern void trcWarn(char *trcFile);

extern char drvError[];
extern T_TRACE_LIST trace_list[];
extern long open_trace_counter;

extern void debugPoint(char *msg);
extern void WINAPI initTraces(void);


extern long WINAPI init_bort_factor_data 
    (
     T_OPENED_TRACE * opened_trace,
     char *target_name,
     long file_counter
  );

extern long WINAPI write_data_to_trc
    (
     T_OPENED_TRACE * opened_trace
    );

extern long WINAPI read_data_from_trc
    (
     T_OPENED_TRACE * opened_trace
    );

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

// ������� ��������� ������ ��� ������ �������� ������ � �������� ������
// (���� ����������� T_INDEX_FILE)
// ��� ���� ���������� ��� ���� file_index
// � ����� ������ ����������� ������ �������  � �������
extern T_INDEX_FILE*  WINAPI init_index_files
    (
     long num_file_data
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
     T_OPENED_TRACE *p_trace,
     char *first_file_name, 
     long data_path_len
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
extern T_CONDITION_SEAM * WINAPI init_condition_seam();

// ������� ������������ ������ ��� ������������
// (���� ���������� T_DESCRIPTOR_TEMPLATE)
// ���������� NULL, ���� ��� ������, ����� - ��� �� �����
extern T_CONDITION_SEAM * WINAPI free_condition_seam
    (
     T_CONDITION_SEAM *p_free
    );

// ������� ��������� ������ ��� ������ ���������
// (���� ����������� T_RECORD_OF_ONE_CYCLE_INQUIRY)
// ���� �� ���������� ������ ��������� ������
extern T_RECORD_OF_ONE_CYCLE_INQUIRY * WINAPI init_inquiry
    (
     long  cor_num,
     long  dim_num
    );

// ������� ������������ ������ ��� �������� ���������
// (���� ���������� T_DESCRIPTOR_TEMPLATE)
// ���������� NULL, ���� ��� ������, ����� - ��� �� �����
extern T_RECORD_OF_ONE_CYCLE_INQUIRY * WINAPI free_inquiry
    (
     T_RECORD_OF_ONE_CYCLE_INQUIRY *p_free
    );

// ������� ������ ��������� ������ � ����
extern long WINAPI save_index_info
    (
     T_OPENED_TRACE * P_trace // ��������� �� ������������������ ������
    );

// ������� �������� �������� ������ � ��������� ��������� ������ �� �����
extern T_OPENED_TRACE * WINAPI creation_trace_with_a_loading_index_info
    (
      char *trc_file
    );

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


extern long read_data_profil_ini(T_OPENED_TRACE * opened_trace);

 // ���� ������������� ������
extern long Serch_navigete(T_TRACE_LIST * p_trace_list);

extern long Init_NavData(T_TRACE_LIST * p_trace_list);

extern long Init_VogData(T_TRACE_LIST * p_trace_list);

  // ���������� ��������� ������ � �������������� �������
extern long Init_navigete(T_TRACE_LIST * p_trace_list, T_TRACEINFO *inf);


#endif
