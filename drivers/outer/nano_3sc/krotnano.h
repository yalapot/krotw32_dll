// Krotepro.h - заголовок  для модуля Krotepro.c.
// Объявление глобальных констант, данных и инструментальных функций драйвера
// просмотра данных електронного блока "epro" программой KrotW32
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

// старший разряд версии драйвера
#define DRIVER_VER_MAX   1
// младший разряд версии драйвера
#define DRIVER_VER_MIN   0
// используемая драйвером версия API 
#define DRIVER_API_VER   KRT_APIVER2


#define KRT_OK  0
#define KRT_ERR 1

#define NUM_BIT_IN_BYTE 8 

#define MAX_TRACE  100  // максимальное количество открытых одновременно записей

#define MAX_GROUP_NUM      8   // максимально возможное кол-во поясов
                                // для данного драйвера                  

#define CORROSION_SENS_TYPE  u16 // тип (размер) данных коррозии

#define MAX_CORROZION_NUM  512  // максимально возможное кол-во датчиков
                                // для данного драйвера


#define MAX_PROFILE_CALIBRATE 128 // максимальное значение калибровочных узлов

#define MAX_SMOOTH_WIN_LENGTH  64 // максимально возможная длинна окна 
                                  // сглаживания данных
                                  // для данного драйвера
                                  // для профильных датчиков

#define SENS_DATA  WORD // тип (размер) данных коррозии


#define OUTER_STEP      10

// макс.значение данных короз.датчиков
#define MAX_DAT_VAL  3993

#define FULL_SPIN           1  // значение T_SEAM.complete_spin
                               // означающее что в условном шве полный оборот
#define NOT_FULL_SPIN       0  // значение T_SEAM.complete_spin
                               // означающее что в условном шве не полный оборот

// полный круг в минутах 12 * 60 мин = 720 мин
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
// смещение верхней мертвой точки в минутах (2.5 часа = 150 мин)
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
// Описание данных для работы с данными файлов трассы
///////////////////////////////////////////////////////////

  // отключим всякое выравнивание для данных читаемых из файлов
#pragma pack (1)

// заголвок файла
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

typedef struct {  // Данные координатного процессора
   u32  odometr;
   u8  odometr_1;
   u8  check_sum;
   u16 reserved;
   u32  vmt;
   u16  voltag_battery;
   u16  num_poweron;
   u8   status; // bit 7 - типа УВД
                // bit 0 - направление

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
   s32 trace_len;          // длинна трассы в отсчетах одометра
   s32 trace_time;
   s32 num_test_in_block;
   s32 num_sens;
} T_IDX_HEADER;


// Возвращаемся к выравниванию по умолчанию
#pragma pack ()

// запись индексной информации по дополнительным датчикам:
typedef struct {
   long time;
   long orient;
   long termo;
   long Thick;
} T_RECORD_EXTEND_SENS;
// запись индексной информации по файлу:

typedef struct {        // описание записи одного цикла опроса
   DWORD poperd_put;
   DWORD prod_put;

   SENS_DATA *sens;       // датчики дефектов
   SENS_DATA *math_sens;  // обматемаченые датчики дефектов
   SENS_DATA Thick;       // толщина
   long direct_prod_put;

} T_INQUIRY;


// структура описания полного оборота сканеров внешнетрубника
typedef struct {   
 T_ArrivedData odo; // иформация о продольных дистанции и сдвиге в тиках продольного одометра
 long itemNum;      // количество измерений за оборот (размер массива item)
 short isComplete;  // FULL_SPIN, если оборот полный, 
                    // NOT_FULL_SPIN если неполный (остановка, начало, конец)
 T_INQUIRY * item;
} T_SPIN_INFO;


typedef struct {  // описание открытой трассы

   // указатель на калбек-функцию оповещения о поступлении новых данных
   long  (KRTAPI *newDataRegistered) (T_ArrivedData *newData);
   long virtSens;            // кол-во виртуальных датчиков (опросов за оборот)
   long virtLength;          // виртуальная длина записи
   long isOdoNotUse;         // режим отображения развертки верт/спирал
   long topShift;            // смещение верхней мертвой точки в датчиках
//   long orient_direct_count; // направление пересчета ориентации
   long secondScanShift;     // смещение второго сканера относительно первого в датчиках
   long thirdScanShift;      // смещение третьего сканера относительно первого в датчиках
   long  trace_len;          // длинна трассы в отсчетах одометра
   long  trace_step;         // размер тика одометра в мм
   long  trace_time;         // время работы на трассе в милисекундах
//   T_THICK thick;            // данные толщины

   char trc_file_name[_MAX_PATH];

   double sens_step; // Шаг датчиков

   char  path_data[_MAX_PATH];       // путь на файлы с данными трассы
   char  first_file_name[_MAX_PATH]; // имя первого файла данных

   char  idx_file_name[_MAX_PATH];   // имя файла индексов c полным путем

//   long  num_file_data;      // количество файлов в записи

   char file[_MAX_PATH];     // имя trc-файла с полным путем

//   long frequency_processor;

   long group_num;

   long linesense_size[MAX_GROUP_NUM];

   long sens_sort[MAX_CORROZION_NUM];

   // ДОЛЖНО СТАТЬ ПОЛЕМ СТРУКТУРЫ САНЕРА И БРАТЬСЯ ИЗ МАССИВА СТРУКТУР СКАНЕРОВ !!!
   long sensInGroup;  // кол-во корозионных датчиков в одном сканере. 

   long corosion_sens_num;  // кол-во корозионных датчиков в записи
   long Amplification_Group[MAX_GROUP_NUM]; // коэффиц усиления в поясе|завис от кол-ва датчиков)

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

 // после последнего запросаg etFirstSpin и getNextSpin заполняются данные:
//   T_SPIN_INFO current_spin; // текущие загруженные данные одного оборота
//   long current_file;        // текущий файл с данными
//   long current_seam;        // текущий условный шов (оборот) внутри файла

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