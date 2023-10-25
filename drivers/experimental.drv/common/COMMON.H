#define COMMON_STEP 10
#define COMMON_SENSORNUM 128

#define ESENS_NUM 100
#define ESENSVAL_MIN 0
#define ESENSVAL_MAX 100

#define TRACE_LENGTH 100000000L

#define MAX_TRACE 3
#define MAX_TRC_NAME 1024

// имя параметра типа записи драйвера common
#define REC_TYPE_ITEM          "RecordType"
// типы записей драйвера common, которые могут быть указаны
// в trc-файле
#define REC_TYPE_STR_CORONLY   "CORONLY"
#define REC_TYPE_STR_VOGONLY   "VOGONLY"
#define REC_TYPE_STR_VOGCOR    "VOGCOR"
// коды этих типов
#define REC_CORONLY            0
#define REC_VOGONLY            1
#define REC_VOGCOR             2

//#define LOGGED  1              // флаг необходимости ведения лога
#define LOG_FILE "krotw32.log" // имя лог-файла
extern char LogString[];       // строка для записи в лог
extern void Log(void);         // Функция записи в лог

typedef struct {
 char traceFile[MAX_TRC_NAME];
 KRTHANDLE handle;
 long lastNodePos;
 long sensType;
 long sensIndex;
 int recType;

 long sensMask;
 long timerPos;      // положение на трассе показаний таймера
 long odoPos;        // положение на трассе показаний одометра
 long orientPos;     // положение на трассе показаний датчика ориентации
 long shakePos;      // положение на трассе показаний датчика ускорения
 long pressPos;      // положение на трассе показаний датчика давления
 long tempPos;       // положение на трассе показаний датчика температуры
 long anglePos;      // положение на трассе показаний датчика угловых скоростей
 long vogPos;        // положение на трассе данных показаний датчиков VOG
 
} COMMON_TRACE;

void initTraces(void);
const char * KRTAPI krtDrvError (void);

long KRTAPI krtDrvFillData (
 KRTHANDLE handle, 
 long group, 
 long start, 
 long length, 
 KRTDATA *screen, 
 long *rowData
);

long KRTAPI krotGetFirstNode (
 KRTHANDLE Handle,
 T_NODE *node,    
 long start,      
 long sensType,   
 long sensIndex,  
 long length,     
 long controlSize 
);

long KRTAPI krotGetNextNode (
 KRTHANDLE Handle,
 T_NODE *node
);

long KRTAPI krotGetFirstNodeGroup (
 KRTHANDLE Handle,
 T_NODEGROUP *node,    
 long start,      
 long sensGroup,   
 long length,     
 long controlSize 
);

long KRTAPI krotGetNextNodeGroup (
 KRTHANDLE Handle,
 T_NODEGROUP *node
);
