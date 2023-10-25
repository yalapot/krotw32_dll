
#ifndef _KROT_512_H_
#define _KROT_512_H_



#define RECORDS_IN_BLOCK      100
#define LENGTH_STR_DEVICE_NAME 15


//#define ORIENTATION_FROM_VOG

  // отключим всякое выравнивание для данных читаемых из файлов
#pragma pack (1)


// заголвок файла
typedef struct
{   
   unsigned long file_version;       // версия формата записи файла
   char  target_name[LENGTH_STR_DEVICE_NAME+1]; // +1 - под 0 в конце строки

   unsigned short magn_sensors_num;        // кол-во коррозионных датчиков

   unsigned char compress_method;//метод сжатия
   unsigned char del_bit; // скока младших битов обнуляем   
   unsigned char reserved[8];
} Т_file_header;

// Заголовок блока
typedef struct
{
	unsigned long  file_version;
	unsigned short real_dim;       // реальное кол-во измерений в условн. шве
	unsigned long  begin_odom_cnt;      // расст.от нач.записи до НАЧАЛА усл шва в отсчетах одометра 
	unsigned short length_odom_cnt;       // расст.от НАЧАЛА до КОНЦА усл шва в отсчетах одометра
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
	unsigned long  odom_result_counter; //общий путь
	unsigned long  odom1_counter;       //путь по одометру 1
	unsigned long  odom2_counter;       //путь по одометру 2
	unsigned char  service_bits;  // номер приоритетного одометра   бит 0
                                      // направление одометра 1         бит 1
                                      // направление одометра 2         бит 2
	unsigned char  rez2;								
	unsigned short time_us;      // время в микросекундах от 0 до 999
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
   s32 num_idx_in_table; // количество элементов таблицы индексов
   s32 first_file_index;
   s32 trace_len;          // длинна трассы в отсчетах одометра
   s32 trace_time;
   s32 num_sens;
} T_IDX_HEADER;

// Возвращаемся к выравниванию по умолчанию
#pragma pack ()


#endif
