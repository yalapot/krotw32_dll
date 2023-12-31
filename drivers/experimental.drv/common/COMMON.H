#define COMMON_STEP 10
#define COMMON_SENSORNUM 128

#define ESENS_NUM 100
#define ESENSVAL_MIN 0
#define ESENSVAL_MAX 100

#define TRACE_LENGTH 100000000L

#define MAX_TRACE 3
#define MAX_TRC_NAME 1024

// ��� ��������� ���� ������ �������� common
#define REC_TYPE_ITEM          "RecordType"
// ���� ������� �������� common, ������� ����� ���� �������
// � trc-�����
#define REC_TYPE_STR_CORONLY   "CORONLY"
#define REC_TYPE_STR_VOGONLY   "VOGONLY"
#define REC_TYPE_STR_VOGCOR    "VOGCOR"
// ���� ���� �����
#define REC_CORONLY            0
#define REC_VOGONLY            1
#define REC_VOGCOR             2

//#define LOGGED  1              // ���� ������������� ������� ����
#define LOG_FILE "krotw32.log" // ��� ���-�����
extern char LogString[];       // ������ ��� ������ � ���
extern void Log(void);         // ������� ������ � ���

typedef struct {
 char traceFile[MAX_TRC_NAME];
 KRTHANDLE handle;
 long lastNodePos;
 long sensType;
 long sensIndex;
 int recType;

 long sensMask;
 long timerPos;      // ��������� �� ������ ��������� �������
 long odoPos;        // ��������� �� ������ ��������� ��������
 long orientPos;     // ��������� �� ������ ��������� ������� ����������
 long shakePos;      // ��������� �� ������ ��������� ������� ���������
 long pressPos;      // ��������� �� ������ ��������� ������� ��������
 long tempPos;       // ��������� �� ������ ��������� ������� �����������
 long anglePos;      // ��������� �� ������ ��������� ������� ������� ���������
 long vogPos;        // ��������� �� ������ ������ ��������� �������� VOG
 
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
