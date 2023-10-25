
#define TERMO_PLACE file_head.termo

// отключим всякое выравнивание для данных читаемых из файлов
#pragma pack (1)

typedef struct {
   s8 num_repeat;
   s8 num_bit;
} ARC_TABLE_REC;


// заголвок файла
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
   s32 trace_len;          // длинна трассы в отсчетах одометра
   s32 trace_time;
   s32 num_test_in_block;
   s32 num_sens;
} T_IDX_HEADER;


typedef struct {  // Данные координатного процессора
   u32  odometr_full; // Общий путь
   u32  odometr_1;    // Путь первого колеса
   u32  odometr_2;    // Путь второго колеса
   u32  odometr_3;    // Путь третьего колеса
   u32  odometr_4;    // Путь четвёртого колеса
   u8   status;       // Служебный регистр блока одометров
                      // 0 - резерв
                      // 1 - направл  1 колеса
                      // 2 - направл  2 ---
                      // 3 - направл  3 ---
                      // 4 - направл  4 ---
                      // 5 - приор колеса \
                      // 6 - приор колеса /
                      // 7 - увд (1 - вкл, 0 - выкл)

   u8   V_reserv;     // Резервный регистр блока одометров
   u16  arc_size;     // Регистр размера архива
   u16  accel_1;      // Акселерометр X
   u16  accel_2;      // Акселерометр Y
   u32  time;         // Таймер(по 1 ms)
} T_Koord_data;

typedef struct {
   s32 beg_trace;
   s32 shift_in_file;
   s16 file_num;
   s32  real_len;
   u8  property;
} T_IDX_TRC;

// Возвращаемся к выравниванию по умолчанию
#pragma pack ()

