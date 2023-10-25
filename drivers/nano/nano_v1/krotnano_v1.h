
#define TERMO_PLACE block_head.termo
#define NOT_USE_ARC_SIZE


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
   u16  accel_1;      // Акселерометр Х     
   u16  accel_2;      // Акселерометр Y     
   u8   status;    // бит 0 - приоритетный одометр
                   // бит 1 - направление одометра 0
                   // бит 2 - направление одометра 1
                   // бит 7 - УВД

   u32  odometr_3;  //Путь третьего колеса/общий путь с учетом направления

   byte termo;     //  \
                   //   Путь четвёртого колеса/младший байт(1-ый) - температура
   byte reserv;    //  /
   u16  reserv2;   // /

   u32  time;      // Таймер(по 1 ms)
} T_Koord_data;

typedef struct {
   s32 beg_trace;
   s32 shift_in_file;
   s16 file_num;
   u32 real_len;
   u8  property;
} T_IDX_TRC;

// Возвращаемся к выравниванию по умолчанию
#pragma pack ()

