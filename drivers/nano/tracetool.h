#ifndef _TRACETOOL_H_
#define _TRACETOOL_H_


#include "navigate.h"
#include "file_buffering.h"
#include "baypass.h"

#pragma warning(disable : 4996) // for VC 8.00

//#define CALL_LOG


#define PI  3.14159265359


#define KRT_OK  0
#define KRT_ERR 1

#define NUM_BIT_IN_BYTE 8 

#define MAX_TRACE  8  // максимальное количество открытых одновременно записей

#define MAX_GROUP_NUM      16   // максимально возможное кол-во поясов
                                // для данного драйвера                  

#define CORROSION_SENS_TYPE  u16 // тип (размер) данных коррозии

#define MAX_CORROZION_NUM  2048 // максимально возможное кол-во датчиков
                                // для данного драйвера

#define MAX_PROFILE_NUM_SENS  1024 // максимальное кол-во профильных датчиков

#define MAX_PROFILE_CALIBRATE 1024 // максимальное значение калибровочных узлов

#define MAX_SMOOTH_WIN_LENGTH  64 // максимально возможная длинна окна 
                                  // сглаживания данных
                                  // для данного драйвера
                                  // для профильных датчиков

#define SENSE_DELETE_FLAG 0xFFFF


#define PATH_DATA_KEY                "path_data"
#define FIRST_FILE_INDEX_KEY         "first_file_index"
#define TRACE_STEP_KEY               "trace_step"
#define VIRTUAL_TRACE_STEP_KEY       "virtual_trace_step"
#define TRACE_LEN_KEY                "trace_len"
#define CORROSION_SENS_NUM_KEY       "corroson_sens_num"
#define GROUP_NUM_KEY                "group_num"
#define LINESENSE_SIZE_KEY           "linesense_size"
#define Orientation_OFF_KEY          "Orientation_OFF"
#define Orientation_shift_KEY        "Orientation_shift"
#define Orientation_shift_2_KEY      "Orientation_shift_2"
#define Orientation_shift_3_KEY      "Orientation_shift_3"
#define Orientation_shift_4_KEY      "Orientation_shift_4"
#define Delete_sens_data_KEY         "Delete_sens_data"
#define SENS_SORT_KEY                "sens_sort"
#define SENS_SHIFT_KEY               "sens_shift"
#define MAX_DATA_CODE_KEY            "max_data_code"
#define Smooth_data_OFF_KEY          "Smooth_data_OFF"
#define Amplification_Group0_KEY     "Amplification_Group0"
#define Amplification_Group1_KEY     "Amplification_Group1"
#define Amplification_Group2_KEY     "Amplification_Group1"
#define Amplification_Group3_KEY     "Amplification_Group1"
#define Median_Filter_length_KEY     "Median_Filter_length"
#define Smooth_win_length0_KEY       "smooth_win_length0"
#define Smooth_win_length1_KEY       "smooth_win_length1"

#define Odometers_tools_use_KEY       "Odometers_tools_use"
#define Odometer_0_sens_KEY           "Odometer_0_sens"
#define Odometer_1_sens_KEY           "Odometer_1_sens"

#define PROFIL_INI_FILE_NAME      "calibrat.prf"
#define PROFILE_SECTION           "Profile_calidrate"
#define Profil_calibrate_KEY      "profil"

#define BendingPlane_KEY          "BendingPlane"
#define ReversView_KEY            "ReversView"
#define Revers_MATH_KEY           "Revers_MATH"
#define Standart_MATH_KEY         "Standart_MATH"

#define ShiftNavigation_data_KEY  "ShiftNavigation_data"

/*
#define TRACE_TIME_KEY               "trace_time"
#define Orinteation_Direct_count_KEY "Orinteation_Direct_count"
#define Smooth_win_length_KEY        "Smooth_win_length"
#define Sckip_sens_data_KEY          "Sckip_sens_data"
#define sens_for_thick_KEY           "sens_for_thick"
#define sens_for_thick_count_KEY     "sens_for_thick_count"
#define adc2tesla_koef_KEY           "adc2tesla_koef"
*/

#define VOG_KOEFF_UMN         100
#define ACCEL_KOEFF_UMN       1000


///////////////////////////////////////////////////////////
// Описание данных для работы с данными файлов трассы
///////////////////////////////////////////////////////////

// запись индексной информации по дополнительным датчикам:
typedef struct {
   long time;
   long orient;
   long termo;
   long Thick;
} T_RECORD_EXTEND_SENS;


typedef struct {  // описание открытой трассы
   long  trace_len;          // длинна трассы в отсчетах одометра
   long  trace_step;         // размер тика одометра в мм
   long  trace_time;         // время работы на трассе в милисекундах

   char  path_data[_MAX_PATH];   // путь на файлы с данными трассы
   long  first_file_index;   // имя первого файла данных

   char trc_file_name[_MAX_PATH];  // имя trc-файла с полным путем

   T_IDX_HEADER idx_head;
   T_IDX_TRC *  idx_trc;

   T_All_FileData Files_buffers;

   FILE *ext_idx_file_data;
   FILE *pressure_data;

   long corosion_sens_num;  // кол-во корозионных датчиков в записи
   long group_num;          // кол-во поясов           |(определяетя шаблонно в
   long linesense_size[MAX_GROUP_NUM];     // кол-во датчиков в поясе |завис от кол-ва датчиков)
   long Amplification_Group[MAX_GROUP_NUM]; // коэффиц усиления в поясе|завис от кол-ва датчиков)

   long max_data_code;

   long sens_sort[MAX_CORROZION_NUM];

   long Sckip_sens_data[MAX_CORROZION_NUM];

   long Delete_sens_data[MAX_CORROZION_NUM];
   long real_number_sensor_in_group[MAX_GROUP_NUM];

   char invert_sens_data_text[1024];
   long invert_sens_data[MAX_CORROZION_NUM];

   long Zerro_sens_data[MAX_CORROZION_NUM];

   long max_sens_shift;
   long sens_shift[MAX_CORROZION_NUM];

   long Orientation_OFF;
   long Orientation_shift;
   long Orientation_shift_2;
   long Orientation_shift_3;
   long Orientation_shift_4;
   long Orinteation_Direct_count;

   long Smooth_data_OFF;
   long smooth_win_length[MAX_GROUP_NUM];

   long nodeType;
   long nodeIndex;
   long nodePos;
   double controlSize;

   long sens_for_thick;
   long sens_for_thick_count;

   long profil_calibrate[MAX_PROFILE_NUM_SENS][MAX_PROFILE_CALIBRATE];

   char  target_name[16];// название снаряда для которого писалось ПО

   long PigL3;

   long Median_Filter_length;

   FILE *hispead_file_data;

   FILE *thick_II_file_data;

   long Odometers_tools_use;
   long Odometer_0_sens;
   long Odometer_1_sens;

   long virtual_trace_step;

   FILE *ovalnost_data;
   long add_ext_sens_ovalnost;

   long add_ext_sens_bps_pressure;
   long add_ext_sens_thick_II;

   long BendingPlane;
   long ReversView;
   long Revers_MATH;
   long Standart_MATH;

   long ShiftNavigation_data;
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

   T_NAVIGATION_DATA NavData;

   T_VOG_DATA VogData;

   T_BP_DATA BPdata;

} T_TRACE_LIST;

#endif
