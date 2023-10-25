
#define TERMO_PLACE file_head.termo

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
   u32  odometr_3;    // ���� �������� ������
   u32  odometr_4;    // ���� ��������� ������
   u8   status;       // ��������� ������� ����� ���������
                      // 0 - ������
                      // 1 - �������  1 ������
                      // 2 - �������  2 ---
                      // 3 - �������  3 ---
                      // 4 - �������  4 ---
                      // 5 - ����� ������ \
                      // 6 - ����� ������ /
                      // 7 - ��� (1 - ���, 0 - ����)

   u8   V_reserv;     // ��������� ������� ����� ���������
   u16  arc_size;     // ������� ������� ������
   u16  accel_1;      // ������������ X
   u16  accel_2;      // ������������ Y
   u32  time;         // ������(�� 1 ms)
} T_Koord_data;

typedef struct {
   s32 beg_trace;
   s32 shift_in_file;
   s16 file_num;
   s32  real_len;
   u8  property;
} T_IDX_TRC;

// ������������ � ������������ �� ���������
#pragma pack ()

