// Krotepro.h - заголовок  для модуля Krotepro.c.
// Объявление глобальных констант, данных и инструментальных функций драйвера
// просмотра данных електронного блока "epro" программой KrotW32
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

#define MAX_TRACE  8  // максимальное количество открытых одновременно записей

#define DESCRIPTOR_LEN    32  // размер дескриптора в байтах

// Описание возможных типов дескрипторов:
#define DESCRIPTOR_CONDITION_SEAM  '0' // '0'- заголовок условного шва 
#define DESCRIPTOR_START_PROGRAM   '1' // '1'- сообщение о старте прогр.
#define DESCRIPTOR_OFF_UVD         '2' // '2'- сообщение о выключении УВД
#define DESCRIPTOR_ON_UVD          '3' // '3'- сообщение о включении УВД
#define DESCRIPTOR_BEGIN_STOP      '4' // '4'- сообщение о начале стоянки
#define DESCRIPTOR_END_STOP        '5' // '5'- сообщение об окончании стоянки

#define VER_FILE_EPRO   0x30313046L  // сигнатура версии файлов   
                                     // для ел. блока "epro" : "F010"

#define VER_FILE_EPRO_15  0x35313046L  // сигнатура версии файлов   
                                     // для ел. блока "epro" : "F015"

#define VER_FILE_EPRO_2 0x30323046L  // сигнатура версии файлов   
                                     // для ел. блока "epro" : "F020"

#define VER_FILE_EPRO_3 0x30333046L  // сигнатура версии файлов   
                                     // для ел. блока "epro" : "F030"

#define VER_FILE_EPRO_31 0x31333046L  // сигнатура версии файлов   
                                      // для ел. блока "epro" : "F031"

#define VER_FILE_EPRO_32 0x32333046L  // сигнатура версии файлов   
                                      // для ел. блока "epro" : "F032"

#define EPRO_CORROSION_SENS_TYPE  WORD // тип (размер) данных коррозии
                                       // для ел. блока "epro": F0XX

// размер дополнительных данных в одном цикле измерения для формата "F010": 
#define PADDING_F010_SIZE (2+8+1+1+2+1+4+4+4)//(следом за ними пойдут измерения коррозии)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^
                       //  | | | | | | | | +- путь II од. от Пика
                       //  | | | | | | | +- путь I од. от Пика
                       //  | | | | | | +- общ. путь от Пика
                       //  | | | | | +- вибрация
                       //  | | | | +- ориентация
                       //  | | | +- температура
                       //  | | +- номер одометра
                       //  | +- такты процессора
                       //  +- количество пропусков с прошлого измерения
                       // для ел. блока "epro" : "F010"


// размер дополнительных данных в одном цикле измерения для формата "F020":
#define PADDING_F020_SIZE (2+8+1+1+2+1+4+4+4+4+2+2+1)//(следом за ними пойдут измерения коррозии)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
                       //  | | | | | | | | | | | | + номер од, напрравления одометров
                       //  | | | | | | | | | | | +- accel_y
                       //  | | | | | | | | | | +- accel_x
                       //  | | | | | | | | | +- путь от Пика только вперед
                       //  | | | | | | | | +- путь II од. от Пика
                       //  | | | | | | | +- путь I од. от Пика
                       //  | | | | | | +- общ. путь от Пика
                       //  | | | | | +- вибрация
                       //  | | | | +- ориентация
                       //  | | | +- температура
                       //  | | +- номер одометра
                       //  | +- такты процессора
                       //  +- количество пропусков с прошлого измерения

#define POWER_LINE_NUM 8

// размер дополнительных данных в одном цикле измерения для формата "F030":
#define PADDING_F030_SIZE (2+8+1+1+2+1+4+4+4+4+2+2+1+POWER_LINE_NUM+1)//(следом за ними пойдут измерения коррозии)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^              ^
                       //  | | | | | | | | | | | | | |              +- Флаги включения линий источника
                       //  | | | | | | | | | | | | | +  Значения тока линий источника 8 штук
                       //  | | | | | | | | | | | | + номер од, напрравления одометров
                       //  | | | | | | | | | | | +- accel_y
                       //  | | | | | | | | | | +- accel_x
                       //  | | | | | | | | | +- путь от Пика только вперед
                       //  | | | | | | | | +- путь II од. от Пика
                       //  | | | | | | | +- путь I од. от Пика
                       //  | | | | | | +- общ. путь от Пика
                       //  | | | | | +- вибрация
                       //  | | | | +- ориентация
                       //  | | | +- температура
                       //  | | +- номер одометра
                       //  | +- такты процессора
                       //  +- количество пропусков с прошлого измерения

#define POWER_LINE_NUM_2 16
// размер дополнительных данных в одном цикле измерения для формата "F031":
#define PADDING_F031_SIZE (2+8+1+1+2+1+4+4+4+4+2+2+1+POWER_LINE_NUM_2+2)//(следом за ними пойдут измерения коррозии)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^                ^
                       //  | | | | | | | | | | | | | |                +- Флаги включения линий источника
                       //  | | | | | | | | | | | | | +  Значения тока линий источника 16 штук
                       //  | | | | | | | | | | | | + номер од, напрравления одометров
                       //  | | | | | | | | | | | +- accel_y
                       //  | | | | | | | | | | +- accel_x
                       //  | | | | | | | | | +- путь от Пика только вперед
                       //  | | | | | | | | +- путь II од. от Пика
                       //  | | | | | | | +- путь I од. от Пика
                       //  | | | | | | +- общ. путь от Пика
                       //  | | | | | +- вибрация
                       //  | | | | +- ориентация
                       //  | | | +- температура
                       //  | | +- номер одометра
                       //  | +- такты процессора
                       //  +- количество пропусков с прошлого измерения

// размер дополнительных данных в одном цикле измерения для формата "F032":
#define PADDING_F032_SIZE (2+8+1+1+2+1+4+4+4+4+2+2+1+4+4+POWER_LINE_NUM_2+2)//(следом за ними пойдут измерения коррозии)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^                ^
                       //  | | | | | | | | | | | | | | | |                +- Флаги включения линий источника
                       //  | | | | | | | | | | | | | | | +-  Значения тока линий источника 16 штук
                       //  | | | | | | | | | | | | | | +- путь IV од. от Пика
                       //  | | | | | | | | | | | | | +- путь III од. от Пика
                       //  | | | | | | | | | | | | + номер од, напрравления одометров
                       //  | | | | | | | | | | | +- accel_y
                       //  | | | | | | | | | | +- accel_x
                       //  | | | | | | | | | +- путь от Пика только вперед
                       //  | | | | | | | | +- путь II од. от Пика
                       //  | | | | | | | +- путь I од. от Пика
                       //  | | | | | | +- общ. путь от Пика
                       //  | | | | | +- вибрация
                       //  | | | | +- ориентация
                       //  | | | +- температура
                       //  | | +- номер одометра
                       //  | +- такты процессора
                       //  +- количество пропусков с прошлого измерения

// размер дополнительных данных в одном цикле измерения для формата "F015":
#define PADDING_F015_SIZE (2+8+1+1+2+1+4+4+4+4+2+2+1+POWER_LINE_NUM+1)//(следом за ними пойдут измерения коррозии)
                       //  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^              ^
                       //  | | | | | | | | | | | | | |              +- Флаги включения линий источника
                       //  | | | | | | | | | | | | | +  Значения тока линий источника 8 штук
                       //  | | | | | | | | | | | | + номер од, напрравления одометров
                       //  | | | | | | | | | | | +- accel_y
                       //  | | | | | | | | | | +- accel_x
                       //  | | | | | | | | | +- путь от Пика только вперед
                       //  | | | | | | | | +- путь II од. от Пика
                       //  | | | | | | | +- путь I од. от Пика
                       //  | | | | | | +- общ. путь от Пика
                       //  | | | | | +- вибрация
                       //  | | | | +- ориентация
                       //  | | | +- температура
                       //  | | +- номер одометра
                       //  | +- такты процессора
                       //  +- количество пропусков с прошлого измерения


#define MAX_CORROZION_NUM  4096 // максимально возможное кол-во датчиков
                                // для данного драйвера

#define MAX_PROFILE_NUM_SENS  256 // максимальное кол-во профильных датчиков

#define MAX_PROFILE_CALIBRATE 128 // максимальное значение калибровочных узлов
                                  // для профильных датчиков

#define MAX_GROUP_NUM      16   // максимально возможное кол-во поясов
                                // для данного драйвера                  

#define MAX_SMOOTH_WIN_LENGTH  64 // максимально возможная длинна окна 
                                  // сглаживания данных
                                  // для данного драйвера

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

#define AVERAGE_LENGTH_ORIENT     16 // длинна окна сглаживания ориентации

///////////////////////////////////////////////////////////
// Описание данных для работы с данными файлов трассы
///////////////////////////////////////////////////////////

  // отключим всякое выравнивание для данных читаемых из файлов
#pragma pack (1)  

// заголовок файла
typedef struct {   
   hyper ver_file;       // версия формата записи файла
   char  target_name[16];// название снаряда для которого писалось ПО
   char  ver_po[16];     // идентификатор и версия бортовой программы создавшей файл

   hyper proc_frequency; // кол-во тактов процессора между вызовами сист. таймера
   word  cor_num;        // кол-во коррозионных датчиков

   byte  reserved[14];
} T_FILE_HEADER;

typedef struct {    // описание дескриптора
   dword ver_file;       // версия формата записи файла
   byte  descriptor_type; // тип дескриптора (DESCRIPTOR_CONDITION_SEAM)
   byte  reserv1;        // пусто
   word  descriptor_Size;// Размер данных дескриптора
} T_DESCRIPTOR;

typedef struct {    // описание заголовка условного шва
   dword real_dim;       // реальное кол-во измерений в условн. шве
   dword beg_odom;       // расст.от нач.записи до НАЧАЛА усл шва в отсчетах одометра 
   dword end_odom;       // расст.от нач.записи до КОНЦА усл шва в отсчетах одометра 
   byte  del_bit;        // скока младших битов обнуляем
   word  skip_dim;       // уровень регулярно пропускаемых измерений
   byte  cor_num_div;    // делитель количества датчиков (кратно 2)
   dword time_10ms;      // Показания системного таймера, настроенного на 10 мс
   dword arc_size;       // размер архивных данных с измерениями
} T_CONDITION_SEAM;


typedef struct {        // описание записи одного цикла опроса
   word  skip_cycle;    // сколько тиков одометра прошло с предыд. опроса 
   hyper proc_tacts;    // сколько тактов процессора прошло с предыд. опроса 
   byte  odom_number;   // номер приоритетного одометра
   byte  termo;         // температура
   word  orient;        // ориентация   
   byte  vibro_1;       // вибродатчик 1
   dword Pic_ful_track; // Результирующий путь от пик-процессора
   dword Pic_track_1;   // Путь 1-го одометра от пик-процессора
   dword Pic_track_2;   // Путь 2-го одометра от пик-процессора
   dword odom_forward;  // Путь от пик-процессора только вперед
   word  accel_x;       // акселерометр x \  для расчета 
   word  accel_y;       // акселерометр y /  ориентации
   byte service_bit;    // bit0 - номер приоритетного одометра
                        // bit1 - флаг направления 1 одометра
                        // bit2 - флаг направления 2 одометра
   dword Pic_track_3;   // Путь 1-го одометра от пик-процессора
   dword Pic_track_4;   // Путь 2-го одометра от пик-процессора

   byte power_val[POWER_LINE_NUM_2]; // Значения тока линий источника
   word power_flags;                 // Флаги включения линий источника

   EPRO_CORROSION_SENS_TYPE *sens;      // датчики дефектов
   EPRO_CORROSION_SENS_TYPE *math_sens; // обматемаченые датчики дефектов

   EPRO_CORROSION_SENS_TYPE Thick;      // толщина
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

// Возвращаемся к выравниванию по умолчанию
#pragma pack ()


// структура одного поля списка индексов загруженных данных
typedef struct T_LOADED_DATA { 
   long file; // номер файл из которого загружены данные
   long seam; // номер усл.шва в файле из которого загружены данные

   struct T_LOADED_DATA *Next_element;
} T_LOADED_DATA;


// запись индексной информации по условному шву:
typedef struct { 
   long  beg_track; // расст. от нач.записи до НАЧАЛА усл.шва в отсчетах одометра
   long  end_track; // расст. от нач.записи до КОНЦА усл.шва в отсчетах одометра
   long  shift_in_file;   // смещение информации усл.шва в файле записи
   hyper beg_time;  // время в тактах процессора от начала записи на ПЕРВОМ измерении усл. шва
   hyper end_time;  // время в тактах процессора от начала записи на ПОСЛЕДНЕМ измерении усл. шва

   long  smooth_orientation_beg;

   T_CONDITION_SEAM               *head_of_condition_seam; 
                                  // ^^^ заголовок условного шва
   T_RECORD_OF_ONE_CYCLE_INQUIRY  *inquiry;
                                  // ^^^ массив данных условного шва

//---------------------------------------------------------------
   long *smooth_data_beg;   // массив индексов сглаживания данных
//------------------------------------------------------------------
} T_INDEX_SEAM;

// запись индексной информации по файлу:
typedef struct {
   char  file_name[_MAX_PATH];  // имя файла данных
   long  beg_track; // расст. от нач.записи до НАЧАЛА файла в отсчетах одометра
   long  end_track; // расст. от нач.записи до КОНЦА файла в отсчетах одометра
   long  num_condition_seam;  // количество условных швов в файле

   T_INDEX_SEAM *index_seam;  // указатель на массив индексных данных по усл.швам

   FILE *file_data;          // дескриптор открытого файла данных
} T_INDEX_FILE;


// запись индексной информации по дополнительным датчикам:
typedef struct {
   long time;
   long orient;
   long termo;
   long Thick;
} T_RECORD_EXTEND_SENS;

// запись индексной информации по дополнительным датчикам:
typedef struct {
   T_RECORD_EXTEND_SENS extend_sens;

   char  file_name[_MAX_PATH];  // имя файла данных
   FILE *file_data;          // дескриптор открытого файла данных


 //  HANDLE hFileMap;
 //  char *map_area_mem;
} T_INDEX_EXTEND_SENS;

// запись индексной информации по линиям питания:
typedef struct {
   byte power_lines[POWER_LINE_NUM];
   byte power_flags;
} T_RECORD_POWER_DATA;

typedef struct {
   T_RECORD_POWER_DATA power_data;


   char  file_name[_MAX_PATH];  // имя файла данных
   FILE *file_data;          // дескриптор открытого файла данных

  // HANDLE hFileMap;
  // char *map_area_mem;
} T_INDEX_POWER_LINES;

typedef struct {
   T_BYPASS_IDX bypass_data;

   char  file_name[_MAX_PATH];  // имя файла данных
   FILE * file_data;             /* дескриптор открытого файла данных      */

  // HANDLE hFileMap;
  // char *map_area_mem;
} T_INDEX_BYPASS;

typedef struct {  // описание открытой трассы
   long  trace_len;          // длинна трассы в отсчетах одометра
   long  trace_step;         // размер тика одометра в мм
   long  trace_time;         // время работы на трассе в милисекундах

   char  path_data[_MAX_PATH];   // путь на файлы с данными трассы
   char  first_file_name[_MAX_PATH];   // имя первого файла данных

   char  idx_file_name[_MAX_PATH];  // имя файла индексов c полным путем

   long  num_file_data;        // количество файлов в записи

   char trc_file_name[_MAX_PATH];  // имя trc-файла с полным путем

   dword frequency_processor;

   long corosion_sens_num;  // кол-во корозионных датчиков в записи
   long group_num;          // кол-во поясов           |(определяетя шаблонно в
   long linesense_size[MAX_GROUP_NUM];     // кол-во датчиков в поясе |завис от кол-ва датчиков)
   long Amplification_Group[MAX_GROUP_NUM]; // коэффиц усиления в поясе|завис от кол-ва датчиков)

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

   T_INDEX_FILE *file_index; // указатель на массив индексных данных  по файлам
   
   T_LOADED_DATA *list_loaded_data;

   long nodeType;
   long nodeIndex;
   long nodePos;
   double controlSize;

   T_INDEX_EXTEND_SENS index_extend_sens;
   long sens_for_thick;
   long sens_for_thick_count;
   long profil_calibrate[MAX_PROFILE_NUM_SENS][MAX_PROFILE_CALIBRATE];

   char  target_name[16];// название снаряда для которого писалось ПО

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
   long  sensTypeGroup;     // текущий тип дополнительного датчика
   long  sensPos;           // текущая позиция показаний доп. датчика
   float controlSize;       // шаг перемещения внутри файла
   long  startPos;
} T_PAR_NODEGROUP;


typedef struct { // структура одного поля списка открытых трасс
   long handle;            // числовой идентификатор открытой трассы
   T_OPENED_TRACE * trace; // указатель на данные открытой трассы

   // объявление структур необходимых для работы с навигационными данными
   T_PAR_NODEGROUP cur_par_nodeGroup;
   T_NAVIGATION_DATA NavData;
   T_VOG_DATA VogData;
} T_TRACE_LIST;


///////////////////////////////////////////////////////
// Описание данных для разархиватора LZW
///////////////////////////////////////////////////////
#define CLEARE_CODE        256              /* Код очистки таблицы кодов  */
#define END_DATA_CODE      (CLEARE_CODE+1)  /* Код конца данных (не исп.) */
#define SOURCE_TABLE_LEN   (END_DATA_CODE+1)/* Начальная длинна таблицы   */
                                            /* (после очистки)            */ 

#define MAX_CODE           65535            /* длинна таблицы кодов       */

#define ARC_SIZE_FIELD_LEN 4  // размер в байтах поля с длинной (в байтах)
                              // получившейся последовательности архивных
                              // данных (поле пишется в файл за усл. швом)

typedef struct {   /* одно поле таблицы кодов */
  word prefics;    /* префикс кодовой последовательности            */
  byte last_char;  /* последний символ в кодовой последовательности */
} T_CODE_SERCH_REC;
  
typedef struct {   /* описание таблицы кодов */
  word char_table_len;          /* текущая длинна таблицы кодов     */
  T_CODE_SERCH_REC char_table[MAX_CODE+1];  /* массив описаний кодов  */
} T_CODE_SERCH_TABLE;



extern char warnString[];
extern char *traceFile; // глобальное имя файла trc
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

// Функция выделения памяти под структуру открытой трассы
//(типа конструктор T_OPENED_TRACE)
// при этом обнуляются все поля в том числе и все указатели 
extern T_OPENED_TRACE * WINAPI init_opened_trace();

// Функция освобождения памяти под структурой открытой трассы
//(типа деструктор T_OPENED_TRACE)
// возвращает NULL, если все хорошо, иначе - тот же адрес
extern T_OPENED_TRACE * WINAPI free_opened_trace
    (
     T_OPENED_TRACE *p_free
    );

// Функция выделения памяти под массив индексов файлов в открытой трассе
// (типа конструктор T_INDEX_FILE)
// при этом обнуляются все поля file_index
// а имена файлов заполняются подряд начиная  с первого
extern T_INDEX_FILE*  WINAPI init_index_files
    (
     long num_file_data
    );

// Функция освобождения памяти под структурой индексов файлов в открытой трассе
//(типа деструктор T_INDEX_FILE)
// возвращает NULL, если все хорошо, иначе - тот же адрес
extern T_INDEX_FILE* WINAPI free_index_files
    (
     T_INDEX_FILE* p_free,
     long num_file_data
    );

// функция прописывания имен в индексы файлов
extern long WINAPI init_name_files
    (
     T_OPENED_TRACE *p_trace,
     char *first_file_name, 
     long data_path_len
    );


// Функция выделения памяти под массив индексов условных швов в индексах файлов
// (типа конструктор T_INDEX_SEAM)
// при этом обнуляются все поля  T_INDEX_SEAM
extern T_INDEX_SEAM * WINAPI init_index_seams
    (
     long num_condition_seam
    );

// Функция освобождения памяти под массив индексов условных швов в индексах файлов
//(типа деструктор T_INDEX_SEAM)
// возвращает NULL, если все хорошо, иначе - тот же адрес
extern T_INDEX_SEAM * WINAPI free_index_seams
    (
     T_INDEX_SEAM *p_free,
     long num_condition_seam
    );

// Функция выделения памяти под массив индексов выравнивания измерений
// инициализация поля smooth_data_beg в структуре T_INDEX_SEAM
long * WINAPI init_smooth_data_beg
    (
      long  cor_num
    );

// Функция освобождения памяти под массив  индексов выравнивания измерений
long * WINAPI free_smooth_data_beg
    (
      long *p_free
    );

// Функция выделения памяти под дескриптор
// (типа конструктор T_DESCRIPTOR_TEMPLATE)
// поля НЕ обнуляются только выделение памяти
extern T_CONDITION_SEAM * WINAPI init_condition_seam();

// Функция освобождения памяти под дескриптором
// (типа деструктор T_DESCRIPTOR_TEMPLATE)
// возвращает NULL, если все хорошо, иначе - тот же адрес
extern T_CONDITION_SEAM * WINAPI free_condition_seam
    (
     T_CONDITION_SEAM *p_free
    );

// Функция выделения памяти под массив измерений
// (типа конструктор T_RECORD_OF_ONE_CYCLE_INQUIRY)
// поля НЕ обнуляются только выделение памяти
extern T_RECORD_OF_ONE_CYCLE_INQUIRY * WINAPI init_inquiry
    (
     long  cor_num,
     long  dim_num
    );

// Функция освобождения памяти под массивом измерений
// (типа деструктор T_DESCRIPTOR_TEMPLATE)
// возвращает NULL, если все хорошо, иначе - тот же адрес
extern T_RECORD_OF_ONE_CYCLE_INQUIRY * WINAPI free_inquiry
    (
     T_RECORD_OF_ONE_CYCLE_INQUIRY *p_free
    );

// функция записи индексных данных в файл
extern long WINAPI save_index_info
    (
     T_OPENED_TRACE * P_trace // указатель на проиндексированную трассу
    );

// функция создания открытой трассы с загрузкой индексных данных из файла
extern T_OPENED_TRACE * WINAPI creation_trace_with_a_loading_index_info
    (
      char *trc_file
    );

// Функция выделения памяти под под поле загруженных данных
// (типа конструктор T_LOADED_DATA)
extern T_LOADED_DATA *init_loaded_data ();

// Функция освобождения памяти под полем загруженных данных
// (типа деструктор T_LOADED_DATA )
extern T_LOADED_DATA *free_loaded_data 
    (
      T_LOADED_DATA * p_free
    );

// Функция добавления поля загруженных данных в конец списка
extern long add_loaded_data_in_list
    (
      T_LOADED_DATA * list,
      long file,
      long seam
    );

// Функция удаления поля загруженных данных из конец списка
extern T_LOADED_DATA * del_loaded_data_in_list(T_LOADED_DATA * list);

// Функция освобождения памяти под списком загруженных данных
// (типа деструктор цепочки T_LOADED_DATA )
extern T_LOADED_DATA *free_list_loaded_data (T_LOADED_DATA * p_free);


extern long read_data_profil_ini(T_OPENED_TRACE * opened_trace);

 // Ищем навигационные данные
extern long Serch_navigete(T_TRACE_LIST * p_trace_list);

extern long Init_NavData(T_TRACE_LIST * p_trace_list);

extern long Init_VogData(T_TRACE_LIST * p_trace_list);

  // подготовим структуру работы с навигационными данными
extern long Init_navigete(T_TRACE_LIST * p_trace_list, T_TRACEINFO *inf);


#endif
