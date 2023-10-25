
#define TERMO_PLACE block_head.termo
#define NOT_USE_ARC_SIZE


// �������� ������ ������������ ��� ������ �������� �� ������
#pragma pack (1)

typedef struct {
   s8 num_repeat;
   s8 num_bit;
} ARC_TABLE_REC;


// �������� �����
typedef struct 
{
    char target_name[10];
    u16  num_sens;
    u8   num_test_in_block;
    u8   termo;
    u8   pressure;
    u8   num_uvd;
} T_File_Head;

typedef struct {
   s32 num_idx_in_table;
   s32 first_file_index;
   s32 trace_len;          // ������ ������ � �������� ��������
   s32 trace_time;
   s32 num_test_in_block;
   s32 num_sens;
} T_IDX_HEADER;

typedef struct {  // ������ ������������� ����������
   u32  odometr_full; // ����� ����
   u32  odometr_1;    // ���� ������� ������
   u32  odometr_2;    // ���� ������� ������
   u16  accel_1;      // ������������ �     
   u16  accel_2;      // ������������ Y     
   u8   status;    // ��� 0 - ������������ �������
                   // ��� 1 - ����������� �������� 0
                   // ��� 2 - ����������� �������� 1
                   // ��� 7 - ���

   u32  odometr_3;  //���� �������� ������/����� ���� � ������ �����������

   byte termo;     //  \
                   //   ���� ��������� ������/������� ����(1-��) - �����������
   byte reserv;    //  /
   u16  reserv2;   // /

   u32  time;      // ������(�� 1 ms)
} T_Koord_data;

typedef struct {
   s32 beg_trace;
   s32 shift_in_file;
   s16 file_num;
   u32 real_len;
   u8  property;
} T_IDX_TRC;

// ������������ � ������������ �� ���������
#pragma pack ()

