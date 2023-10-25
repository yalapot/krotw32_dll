#define LOG_FILE "krotw32.log" // имя лог-файла

#define byte        BYTE
#define short       SHORT
#define word        WORD
#define dword       DWORD

#define LOG_SECTION "RegisterLog"
#define KRTINF_SECT_REGISTER DRIVER_DATA
#define KRTINF_ITEM_PRIMARY "Primary"

#define  INDEX_EXT          "idx"
#define  SEGM_LEN           256
#define  KROT128_SENSLEV    16   /* кол-во уровней датчика */
#define  KROT128_SENSNUM    128   /* кол-во датчиков */
#define  KROT_SIGN          0x44555353L /* сигнатура файла данных крота */
#define  MAX_TRACE          3
#define  MAX_MARKER_NUM     100     /* количество маркеров в файле данных */
#define  KROT_TIME_NUM      4       /* количество времен фиксируемых маркером */
#define  KROT128_SENSNUM    128   /* кол-во датчиков */
#define  OUT_SPEED          90000L  /* запредельная скорость */
#define  TIC_PER_SECOND     100L /* частота бортового таймера */

#define R_UNKNOWN   0
#define R_BARDOWN   1
#define R_POWERFAIL 2
#define R_DISKFULL  3

#define  D_WELD             0x50    /* метка условного шва */
#define  D_STOP             0x60    /* метка остановки */
#define  D_BARDOWN          0x70    /* метка сброса давления */
#define  D_POWERFAIL        0x71    /* метка отказа электропитания */
#define  D_DISKFULL         0x72    /* метка переполнения диска */
#define  D_POWERON          0x7F    /* метка включения снаряда */
#define  D_DFKT01           0x90    /* метка дефекта */
#define  D_DFKT02           0x91    /* метка дефекта */
#define  D_DFKT03           0x92    /* метка дефекта */
#define  D_DFKT04           0x93    /* метка дефекта */
#define  D_DFKT05           0x94    /* метка дефекта */
#define  D_DFKT06           0x95    /* метка дефекта */
#define  D_DFKT07           0x96    /* метка дефекта */
#define  D_DFKT08           0x97    /* метка дефекта */
#define  D_DFKT09           0x98    /* метка дефекта */
#define  D_DFKT10           0x99    /* метка дефекта */
#define  D_DFKT11           0x9a    /* метка дефекта */
#define  D_DFKT12           0x9b    /* метка дефекта */
#define  D_DFKT13           0x9c    /* метка дефекта */
#define  D_DFKT14           0x9d    /* метка дефекта */
#define  D_DFKT15           0x9e    /* метка дефекта */
#define  D_DFKT16           0x9f    /* метка дефекта */

typedef struct {
    long dist;
    long pos;
    long time;
    byte top;
    byte width;
    short speed;
} T_INDX;

typedef struct {
    byte sign;
    byte dist;
    byte num;
    byte val;
} T_ITEM;

typedef struct {
  byte id;
  dword time[KROT_TIME_NUM];
} T_KROT_MARKER;

typedef struct {
 long dist;
 FILE *rec;
 FILE *indx;
 long node;
 long synhShift;
 KRTHANDLE handle;
 long lastNodePos;
 long sensType;
 long sensIndex;
} T_KROT_TRACE;

typedef struct {
    dword sign;
    dword serialNo;

    word year;
    byte month;
    byte day;
    byte hour;
    byte minutes;
    byte second;
    byte hsecond;

    word sinh_year;
    byte sinh_month;
    byte sinh_day;
    byte sinh_hour;
    byte sinh_minutes;
    byte sinh_second;
    byte sinh_hsecond;

    T_KROT_MARKER marker[MAX_MARKER_NUM];

} T_KROT_HEAD;


typedef struct {
    byte sign;  
    byte orient; 
    byte wdist; 
    byte odonum;
    dword dist;
    dword time;
} T_WELD;

typedef struct {
    byte sign;
    byte orient;
    byte offs;
    byte reserved;
    dword dist;
    dword time;
} T_STOP;

typedef struct {
    long dist;
    short minutes;
} T_STOPINFO;

typedef struct {
    long dist;
    short speed;
} T_OVERSPEED;

typedef struct {
    long serialNo;
    short d_year;
    short d_month;
    short d_day;
    short d_hour;
    short d_minutes;
    short d_second;
    short s_year;
    short s_month;
    short s_day;
    short s_hour;
    short s_minutes;
    short s_second;
    long dist;
    short wt_hour;
    short wt_minutes;
    short stop_reson;
    long unknown_item;
    T_STOPINFO stop[20];
    T_OVERSPEED overspeed[20];
} T_SUMMARY;


long KRTAPI krtDrvRegister (
 LPSTR datFile, 
 LPSTR trcFile, 
 char **errText, 
 long (KRTAPI *userBreak) (short percentDone)
);

int KRTAPI krotGetFirstNode (
 KRTHANDLE Handle,
 T_NODE *node,    
 long start,      
 long sensType,   
 long sensIndex,  
 long length,     
 long controlSize 
);

int KRTAPI krotGetNextNode (
 KRTHANDLE Handle,
 T_NODE *node
);