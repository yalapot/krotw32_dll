
#ifndef _KROT_512_H_
#define _KROT_512_H_



#define RECORDS_IN_BLOCK      100
#define LENGTH_STR_DEVICE_NAME 15


//#define ORIENTATION_FROM_VOG

  // �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)


// �������� �����
typedef struct
{   
   unsigned long file_version;       // ������ ������� ������ �����
   char  target_name[LENGTH_STR_DEVICE_NAME+1]; // +1 - ��� 0 � ����� ������

   unsigned short magn_sensors_num;        // ���-�� ������������ ��������

   unsigned char compress_method;//����� ������
   unsigned char del_bit; // ����� ������� ����� ��������   
   unsigned char reserved[8];
} �_file_header;

// ��������� �����
typedef struct
{
	unsigned long  file_version;
	unsigned short real_dim;       // �������� ���-�� ��������� � ������. ���
	unsigned long  begin_odom_cnt;      // �����.�� ���.������ �� ������ ��� ��� � �������� �������� 
	unsigned short length_odom_cnt;       // �����.�� ������ �� ����� ��� ��� � �������� ��������
	unsigned long  compressed_block_size;
	unsigned short status;  // 1 value stop
                                // 2 value uvd	
}_compressed_block_header;


typedef struct
{
	unsigned short accel_x;
	unsigned short accel_y;
	unsigned short accel_z;
	unsigned char  temperature;
	unsigned char  pressure;
	unsigned long  odom_result_counter; //����� ����
	unsigned long  odom1_counter;       //���� �� �������� 1
	unsigned long  odom2_counter;       //���� �� �������� 2
	unsigned char  service_bits;  // ����� ������������� ��������   ��� 0
                                      // ����������� �������� 1         ��� 1
                                      // ����������� �������� 2         ��� 2
	unsigned char  rez2;								
	unsigned short time_us;      // ����� � ������������� �� 0 �� 999
	unsigned long  time;
	unsigned long  odom_time;
	unsigned short magn_sensors_data[MAGN_SENSORS];
}_record_data;


typedef struct
{
     _compressed_block_header  header;
     _record_data              records[RECORDS_IN_BLOCK];
}_data_block;


typedef struct
{
     _compressed_block_header  header;
     char                      arc_data [sizeof(_data_block) + 512];
}_arc_block;

typedef struct {
   s32 beg_trace;
   s32 shift_in_file;
   s16 file_num;
   u16 num_test_in_block;
   s32 real_len;
   s32 pred_odom_result_counter;
   u8  property;

   _record_data  *records;
   _record_data  *math_records;
   _record_data  *revers_math_records;

} T_IDX_TRC;

typedef struct {
   s32 num_idx_in_table; // ���������� ��������� ������� ��������
   s32 first_file_index;
   s32 trace_len;          // ������ ������ � �������� ��������
   s32 trace_time;
   s32 num_sens;
} T_IDX_HEADER;

// ������������ � ������������ �� ���������
#pragma pack ()


#endif
