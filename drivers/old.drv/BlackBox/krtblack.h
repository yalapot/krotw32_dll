// Krot386e.h - заголовк  дл€ модул€ Krot384e.c.
// ќбъ€вление глобальных констант, данных и инструментальных функций драйвера
// просмотра данных електронного блока "384 epro" программой KrotW32
//

#ifndef _KROT384e_H_
#define _KROT384e_H_

#define byte        BYTE
#define short       SHORT
#define word        WORD
#define dword       DWORD

#define KRT_OK  0
#define KRT_ERR 1

#define KROT_BLACK_BOX_SECTION  "KROT_BLACK_BOX_Section"
#define DATA_PATH_KEY      "Path_to_data_KROT_BLACK_BOX"
#define PERIOD_KEY "Period"
#define PHASE_KEY  "Phase"
#define AVERAGE_LENGTH_KEY "Average_length"

#define KROT_BLACK_BOX_SORT_SECTION "BLACK_BOX_SORT"
#define senssortFile "senssort.ini"

#define  MAX_VALUE_DATA 0x0fff

#define  MAX_TRACE          8     /* максимальное количество открытых    */
                                  /* одновременно записей                */

#ifdef SENS64
#define  KROT_BLACK_BOX_ALL_SENS   64
#endif

#ifdef SENS128
  #define  KROT_BLACK_BOX_ALL_SENS   128
#endif
           /* ^^^^ кол-во датчиков дефектов во всей записи */

#define  CYCLE_INQUIRY   (6+KROT_BLACK_BOX_ALL_SENS*2)   /* размер цикла опроса в байтах */


#define  CONDITIONAL_SEAM_HEADER_LEN  16  /* размер заголовка условного шва */
                                          /* в байтах                       */
#define  CONDITIONAL_SEAM_STD_LEN    200  /* стандартное рассто€ние между   */
                                          /* условными швами в отсчетах     */
                                          /* одометра (не больше)           */
                                          /* условн. швов в файле   */

///////////////////////////////////////////////////////////
// ќписание данных дл€ блока математической обработки
///////////////////////////////////////////////////////////
#define MAX_AVERAGE_LENGTH  1024 // максимальное значение

///////////////////////////////////////////////////////////
// ќписание данных дл€ работы с трассой
///////////////////////////////////////////////////////////

#pragma pack (1)

typedef struct {      /* описание записи одного цикла опроса (10 мм) */
   word skip_cycle;   /* сколько тиков од. прошло с предыд цикла опроса  */
   byte odom_number;  /* номер приоритетного одометра */
   byte vibro_1;      /* вибродатчик 1 */
   byte vibro_2;      /* вибродатчик 2 */
   byte vibro_3;      /* вибродатчик 3 */
   word sens[KROT_BLACK_BOX_ALL_SENS];  /* датчики дефектов */
} T_RECORD_OF_ONE_CYCLE_INQUIRY;

typedef struct {    /* описание заголовка условного шва (2 м) */
    byte  arc_mode;     /* режим архивировани€ (кол-во обрезанных битов) */
    byte  orientation;  /* показание дачика ориентации                   */
    dword time;         /* врем€ движени€ в сотых секунды                */
    dword track;        /* расст. от нач. записи в отсчетах одометра     */
    byte  real_inquiry; /* реальное кол-во измерений между условн. швами */
    dword ver_file;     /* верси€ формата записи файла                   */
    byte  termo;        /* показание термодатчика                        */
} T_HEAD_OF_CONDITION_SEAM;

#pragma pack ()


typedef struct {
  long handle;
  long full_trace_len;
  long amplification_1_poyas;
  long start;
  T_RECORD_OF_ONE_CYCLE_INQUIRY* trace;
  T_RECORD_OF_ONE_CYCLE_INQUIRY* math_trace;

  long invert_data[KROT_BLACK_BOX_ALL_SENS];
} T_TRACE_LIST;


extern char warnString[];
extern void trcWarn(char *trcFile);
extern char *traceFile;

extern char drvError[];
extern T_TRACE_LIST trace_list[];
extern int open_trace_counter;

extern void debugPoint(char *msg);
extern void WINAPI initTraces(void);

#endif