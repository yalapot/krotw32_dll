// Krotepro.h - заголовок  для модуля Krotepro.c.
// Объявление глобальных констант, данных и инструментальных функций драйвера
// просмотра данных електронного блока "epro" программой KrotW32
//

#ifndef _KROT_EPRO_H_
#define _KROT_EPRO_H_

//#define KROT_DEBUG

#include "krtapi2.h"
#include "thick.h"

// старший разряд версии драйвера
#define DRIVER_VER_MAX   1
// младший разряд версии драйвера
#define DRIVER_VER_MIN   0
// используемая драйвером версия API 
#define DRIVER_API_VER   KRT_APIVER2
// дискретность измерений вдоль оси трубы в мм 
// длина сканирующей головки 85 мм , датчиков в головке 16 шт
#define OUTER_STEP      10
// макс.значение данных короз.датчиков
#define MAX_DAT_VAL  4095

// полный круг в минутах 12 * 60 мин = 720 мин
#define FULL_CIRCLE       720

#define byte    BYTE
#define short   SHORT
#define word    WORD
#define dword   DWORD

#define KRT_OK  0
#define KRT_ERR 1

#define NOT_EMPTY (0)
#define EMPTY (-1)

#define MAX_TRACE  1000             // максимальное количество открытых одновременно записей

#define MAX_FILE_IN_TRACE  4096

#define MAX_SEAM_LENGTH    5000

#define FIRST_FILE_NAME "tm00000.da"
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


#define FIRST     0  // значение T_FILE_HEADER.flag_file_first_after_start
                     // означающее что файл первый после запуска
#define NOT_FIRST 1  // значение T_FILE_HEADER.flag_file_first_after_start
                     // означающее что файл не первый после запуска          

#define FULL_SPIN           1  // значение T_SEAM.complete_spin
                               // означающее что в условном шве полный оборот
#define NOT_FULL_SPIN       0  // значение T_SEAM.complete_spin
                               // означающее что в условном шве не полный оборот

#define DESCRIPTOR_LEN    32  // размер дескриптора в байтах

// Описание возможных типов дескрипторов:
#define DESCRIPTOR_CONDITION_SEAM  '0' // '0'- заголовок условного шва 
#define DESCRIPTOR_START_PROGRAM   '1' // '1'- сообщение о старте прогр.
#define DESCRIPTOR_OFF_UVD         '2' // '2'- сообщение о выключении УВД
#define DESCRIPTOR_ON_UVD          '3' // '3'- сообщение о включении УВД
#define DESCRIPTOR_BEGIN_STOP      '4' // '4'- сообщение о начале стоянки
#define DESCRIPTOR_END_STOP        '5' // '5'- сообщение об окончании стоянки

#define VER_FILE_VNSHN   0x31313046  // сигнатура версии файлов   
                                     // для ел. блока "vnshn" : "F011"

#define SENS_DATA  WORD // тип (размер) данных коррозии
                                       // для ел. блока "vnshn" : "F011"

#define ProcFrequencyType  hyper

// размер дополнительных данных в одном цикле измерения для формата "F011": 
#define PADDING_F011_SIZE (4+4+8+8+4+4+4)//(следом за ними пойдут измерения коррозии)
                       //  ^ ^ ^ ^ ^ ^ ^ 
                       //  | | | | | | +- dword  orient;  // ориентация рамы от Гошки
                       //  | | | | | +- dword  prod_put;  // счетчик продольного пути от Гошки
                       //  | | | | +- dword  poperd_put; // счетчик попердольного пути от Гошки
                       //  | | | +- hyper takt_in_ADC; // счетчик тактов на текущем измерении
                       //  | | +- hyper takt_in_odom; // счетчик тактов на последнем одометре
                       //  | +- dword ADC_counter;   // счетчик АЦП
                       //  +- dword odom_counter;   // счетчик одометра
                       // для ел. блока "vnshn" : "F011"


#define MAX_CORROZION_NUM  128  // максимально возможное кол-во датчиков
                                // для данного драйвера

#define MAX_GROUP_NUM      8   // максимально возможное кол-во поясов
                                // для данного драйвера                  

#define MAX_SMOOTH_WIN_LENGTH  64 // максимально возможная длинна окна 
                                  // сглаживания данных
                                  // для данного драйвера

#define SENSE_DELETE_FLAG 0xFFFF


#define EPRO_SECTION    "DriverData"

#define TRACE_STEP_KEY               "trace_step"
#define FIRST_FILE_NAME_KEY          "first_file_name"
#define INDEX_FILE_NAME_KEY          "index_file_name"
#define CORROSION_SENS_NUM_KEY       "corroson_sens_num"
#define GROUP_NUM_KEY                "group_num"
#define MAX_DATA_CODE_KEY            "max_data_code"
#define Amplification_Group0_KEY      "Amplification_Group0"
#define Amplification_Group1_KEY      "Amplification_Group1"
#define Invert_sens_data_KEY         "Invert_sens_data"
#define Smooth_data_OFF_KEY          "Smooth_data_OFF"
#define Smooth_win_length_KEY        "Smooth_win_length"
#define Median_smooth_KEY            "Median_smooth"
#define razvorot_1_skanera_KEY       "razvorot_1_skanera"
#define razvorot_2_skanera_KEY       "razvorot_2_skanera"
#define SENS_SORT_KEY                "sens_sort"
#define orient_direct_count_KEY      "orient_direct_count"
#define Skan_2_Shift_KEY             "Skan_2_Shift"


#define IDX_FILE_NAME                "trace.idx"

#define AVERAGE_LENGTH_ORIENT     8 // длинна окна сглаживания ориентации

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

   byte  flag_file_first_after_start;

   byte  reserved[13];
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
   byte  complete_spin;  // флаг того что оборот внешнетрубника в этом условном шве полный
   dword time_10ms;      // Показания системного таймера, настроенного на 10 мс
   dword arc_size;       // размер архивных данных с измерениями
} T_SEAM;


typedef struct {        // описание записи одного цикла опроса
   dword odom_counter;    // счетчик одометра
   dword ADC_counter;     // счетчик АЦП
   hyper takt_in_odom;    // счетчик тактов на последнем одометре
   hyper takt_in_ADC;     // счетчик тактов на текущем измерении
   dword poperd_put;
   dword prod_put;
   word src_poperd_put;    // счетчик попердольного пути от Гошки  
   word src_prod_put;      // счетчик продольного пути от Гошки  

   SENS_DATA *sens;       // датчики дефектов
   SENS_DATA *math_sens;  // обматемаченые датчики дефектов
   SENS_DATA Thick;       // толщина
   long direct_prod_put;

} T_INQUIRY;

#pragma pack ()
  // Возвращаемся к выравниванию по умолчанию


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
   long  global_number_seam;
   byte pred_src_prod_put;
   long start_seam;
   long init_direct_prod_put;
   long next_direct_prod_put;

   T_SEAM     *head_of_condition_seam; 
                        // ^^^ заголовок условного шва
   T_INQUIRY  *inquiry;
              // ^^^ массив данных условного шва

   long *smooth_data_beg;   // массив индексов сглаживания данных

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

// структура описания полного оборота сканеров внешнетрубника
typedef struct {   
 T_ArrivedData odo; // иформация о продольных дистанции и сдвиге в тиках продольного одометра
 long itemNum;      // количество измерений за оборот (размер массива item)
 short isComplete;  // FULL_SPIN, если оборот полный, 
                    // NOT_FULL_SPIN если неполный (остановка, начало, конец)
 T_INQUIRY *item;   // указатель на первый элемент массива измерений (размером itemNum)
} T_SPIN_INFO;

typedef struct {  // описание открытой трассы

   // указатель на калбек-функцию оповещения о поступлении новых данных
   long  (KRTAPI *newDataRegistered) (T_ArrivedData *newData);
   long virtSens;            // кол-во виртуальных датчиков (опросов за оборот)
   long virtLength;          // виртуальная длина записи
   long isOdoNotUse;         // режим отображения развертки верт/спирал
   long topShift;            // смещение верхней мертвой точки в датчиках
   long orient_direct_count; // направление пересчета ориентации
   long secondScanShift;     // смещение второго сканера относительно первого в датчиках
   long  trace_len;          // длинна трассы в отсчетах одометра
   long  trace_step;         // размер тика одометра в мм
   long  trace_time;         // время работы на трассе в милисекундах
   T_THICK thick;            // данные толщины

   double sens_step; // Шаг датчиков


   char  path_data[_MAX_PATH];       // путь на файлы с данными трассы
   char  first_file_name[_MAX_PATH]; // имя первого файла данных

   char  idx_file_name[_MAX_PATH];   // имя файла индексов c полным путем

   long  num_file_data;      // количество файлов в записи

   char file[_MAX_PATH];     // имя trc-файла с полным путем

   dword frequency_processor;

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

   long Skan_2_Shift;

   T_INDEX_FILE *file_index; // указатель на массив индексных данных  по файлам

   T_LOADED_DATA *list_loaded_data;

   long nodeType;
   long nodeIndex;
   long nodePos;
   double controlSize;

 // после последнего запросаg etFirstSpin и getNextSpin заполняются данные:
   T_SPIN_INFO current_spin; // текущие загруженные данные одного оборота
   long current_file;        // текущий файл с данными
   long current_seam;        // текущий условный шов (оборот) внутри файла

#ifdef KROT_DEBUG
   FILE *log;
#endif
   
} T_OPENED_TRACE;


typedef struct { // структура одного поля списка открытых трасс
   long handle;            // числовой идентификатор открытой трассы
   T_OPENED_TRACE * trace; // указатель на данные открытой трассы
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

extern char *traceFile; // глобальное имя файла trc

extern char drvError[];
extern T_TRACE_LIST trace_list[];
extern long open_trace_counter;

extern void initTraces(void);
extern long init_bort_factor_data(T_OPENED_TRACE *trc);
extern long read_data_from_trc(T_OPENED_TRACE *trc);

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
     T_OPENED_TRACE *p_trace
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
extern T_SEAM * WINAPI init_condition_seam();

// Функция освобождения памяти под дескриптором
// (типа деструктор T_DESCRIPTOR_TEMPLATE)
// возвращает NULL, если все хорошо, иначе - тот же адрес
extern T_SEAM * WINAPI free_condition_seam
    (
     T_SEAM *p_free
    );

// Функция выделения памяти под массив измерений
// (типа конструктор T_RECORD_OF_ONE_CYCLE_INQUIRY)
// поля НЕ обнуляются только выделение памяти
extern T_INQUIRY * WINAPI init_inquiry
    (
     long  cor_num,
     long  dim_num
    );

// Функция освобождения памяти под массивом измерений
// (типа деструктор T_DESCRIPTOR_TEMPLATE)
// возвращает NULL, если все хорошо, иначе - тот же адрес
extern T_INQUIRY * WINAPI free_inquiry
    (
     T_INQUIRY *p_free
    );

// функция создания открытой трассы с загрузкой индексных данных из файла
extern T_OPENED_TRACE *creation_trace(const char * trc_file);

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

// функция заполняет информацией о файле данных fileName структуру info
// возвращает 1 при успехе, 0 при ошибке. Описание ошибки в drvError
extern long getFileInfo ( 
 T_OPENED_TRACE *trace, 
 const char *fileName,  
 long fileIndex, 
 T_ArrivedData *info
 );

// функция ищет первый оборот сканеров внешнетрубника над отметкой traceDist 
// (в тиках продольного одометра от начала записи) и заполняет информацией о 
// нем структуру spin
// при удачном завершении возвращает 1, при ошибке 0. Описание ошибки помещается
// в переменную drvError
extern short getFirstSpin(
  T_OPENED_TRACE *trace,
  long traceDist,
  T_SPIN_INFO *spin
);

// функция заполняет структуру spin информацией о следуюшем по порядку обороте 
// (после предыдущего вызова getFirstSpin или getNextSpin)
// при удачном завершении возвращает 1, при ошибке 0. Описание ошибки помещается
// в переменную drvError
extern short getNextSpin(T_OPENED_TRACE *trace, T_SPIN_INFO *spin);

extern const char * KRTAPI krtDrvError(void);
extern T_OPENED_TRACE * getTrace(KRTHANDLE handle);
extern long WINAPI krtDrvGetNextNode ( KRTHANDLE handle, T_NODE *node);
extern long WINAPI krtDrvGetFirstNode (KRTHANDLE handle, T_NODE *node, long start, long sensType, long sensIndex, long length, long controlSize );
extern T_OPENED_TRACE *createTrace(const char * traceFile, KRTHANDLE handle);
extern void updateThickData(T_OPENED_TRACE *trc, long pos);

#endif