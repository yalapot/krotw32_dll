#ifndef _TRACETOOL_H_
#define _TRACETOOL_H_


#pragma warning(disable : 4996) // for VC 8.00

//#define CALL_LOG


#define PI  3.14159265359


#define KRT_OK  0
#define KRT_ERR 1

#define NUM_BIT_IN_BYTE 8

#define RECORDS_IN_BLOCK      100

#define MAX_TRACE  8  // ������������ ���������� �������� ������������ �������

#define MAX_GROUP_NUM      16   // ����������� ��������� ���-�� ������
                                // ��� ������� ��������                  

#define CORROSION_SENS_TYPE  unsigned short // ��� (������) ������ ��������

#define MAX_CORROZION_NUM  2048 // ����������� ��������� ���-�� ��������
                                // ��� ������� ��������

#define PATH_DATA_KEY                "PATH_DATA"
#define TRACE_LEN_KEY                "TRACE_LEN"
#define PIPE_DIAMETER_KEY            "PIPE_DIAMETER"

#define ODOMETER_NAME_KEY            "ODOMETER_NAME"
#define ODOMETER_TITLE_KEY           "ODOMETER_TITLE"
#define ODOMETER_SIZE_KEY            "ODOMETER_SIZE"
#define ODOMETER_INT_TYPE_KEY        "ODOMETER_INT_TYPE"

#define TIMER_NAME_KEY               "TIMER_NAME"
#define TIMER_TITLE_KEY              "TIMER_TITLE"
#define TIMER_SIZE_KEY               "TIMER_SIZE"
#define TIMER_INT_TYPE_KEY           "TIMER_INT_TYPE"

#define NUM_ADD_SENSORS_KEY          "NUM_ADD_SENSORS"
#define ADD_SENSOR_NAME_KEY          "ADD_SENSOR_NAME"
#define ADD_SENSOR_TITLE_KEY         "ADD_SENSOR_TITLE"
#define ADD_SENSOR_SIZE_KEY          "ADD_SENSOR_SIZE"
#define ADD_SENSOR_INT_TYPE_KEY      "ADD_SENSOR_INT_TYPE"

#define NUM_LINES_SENSORS_KEY        "NUM_LINES_SENSORS"
#define LINES_SENSORS_NUM_SENS_KEY   "LINES_SENSORS_NUM_SENS"
#define LINES_SENSORS_NAME_KEY       "LINES_SENSORS_NAME"
#define LINES_SENSORS_TITLE_KEY      "LINES_SENSORS_TITLE"
#define LINES_SENSORS_SIZE_KEY       "LINES_SENSORS_SIZE"
#define LINES_SENSORS_INT_TYPE_KEY   "LINES_SENSORS_INT_TYPE"
#define LINES_SENSORS_PALETTE_KEY    "LINES_SENSORS_PALETTE"

#define FULL_RECORD_SIZE_KEY         "FULL_RECORD_SIZE"

#define FIRST_FILE_INDEX_KEY         "first_file_index"
#define TRACE_STEP_KEY               "trace_step"

//#define CORROSION_SENS_NUM_KEY       "corroson_sens_num"
//#define GROUP_NUM_KEY                "group_num"
//#define LINESENSE_SIZE_KEY           "linesense_size"

///////////////////////////////////////////////////////////
// �������� ������ ��� ������ � ������� ������ ������
///////////////////////////////////////////////////////////

  // �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)  

// �������� ���������� ������� (�������, ������, ����������� � ��� ��������������� ...
typedef struct
{   
   char name [128];
   char title[128];
   long size;     // ������ ��������� � ������
   long int_type; // ���� ������������ ����� ����� ��� ������������
                  // 1 -> ����� �����
                  // 0 -> ������������ ����� (double)
   long step;     // ���� ����� ������ ��� ��������
   long shift_in_record;
} �_sens_define;

// �������� ���������� ����� ������������������ �������� 
typedef struct
{   
   char name [128];
   char title[128];
   char palette_name[128];
   long size;     // ������ ��������� � ������
   long int_type; // ���� ������������ ����� ����� ��� ������������
                  // 1 -> ����� ����� �� ������
                  // 2 -> ����� ����� ��� �����
                  // 0 -> ������������ ����� (double)
   long sens_num; //
   long shift_in_record;
} �_sensline_define;

typedef struct
{
   unsigned long  odom_counter; //����� ����
   unsigned long  time;

   long add_sensors[16];

   unsigned char all_sens_data[MAX_CORROZION_NUM];
}_record_data;

typedef struct {
   long num_idx_in_table; // ���������� ��������� ������� ��������
   long first_file_index;
   long trace_len;          // ������ ������ � �������� ��������
   long trace_time;

   long full_record_size;

   long num_all_sens;

   �_sens_define odometer_define;
   �_sens_define timer_define;

   long num_add_sens;
   �_sens_define others_sens_define[16];

   long num_magn_sens_group;
   �_sensline_define senslines_define[8];

} T_IDX_HEADER;

typedef struct {
   long beg_trace;
   long shift_in_file;
   short file_num;
   unsigned short num_test_in_block;
   unsigned short real_len;
   long pred_odometer_value;

   // ������ �������
   _record_data  *records;

} T_IDX_TRC;

// ������������ � ������������ �� ���������
#pragma pack ()


typedef struct { // �������� �������� ������
   long  trace_len;          // ������ ������ � �������� ��������
   long  trace_step;         // ������ ���� �������� � ��
   long  trace_time;         // ����� ������ �� ������ � ������������

   char  path_data[_MAX_PATH];   // ���� �� ����� � ������� ������
   long  first_file_index;       // ����� ������� ����� ������

   char trc_file_name[_MAX_PATH];  // ��� trc-����� � ������ �����

   long Diameter;

   T_IDX_HEADER idx_head;

   T_IDX_TRC * idx_trc;

   long nodeType;
   long nodeIndex;
   long nodePos;
   long controlSize;

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

#endif
