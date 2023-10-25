/* байтовое выравнивание для структур! */
/* #pragma option -a */

/* #include <computer.h> */
#ifndef _COMPUTER_

#define _COMPUTER_

typedef unsigned char byte;
typedef unsigned short word;
typedef unsigned long dword;

#endif
/* end <computer.h> */

/* #include <markers.h> */
#define  EMPTY_MARKER		0xFF	/* значение пустого маркера */
#define  EMPTY_TIME			0xFFFFFFFFL	/* значение пустого маркера */
#define  SINHRONIZE			0		/* метка маркера времени синхрониз-ции */
#define  MAX_MARKER_NUM		100		/* количество маркеров в файле данных */
#define  KROT_TIME_NUM		4		/* количество времен фиксируемых маркером */

typedef struct {
  byte id;
  dword time[KROT_TIME_NUM];
} T_KROT_MARKER;

typedef union {
  dword	l;
  word	i[2];
  byte	b[4];
} KRT_TIME;
/* end <markers.h> */

/* инициализирующие значения */
#define  INIT1_PORT			0x103
#define  INIT1_VALUE		0x92
#define  INIT2_PORT			0x107
#define  INIT2_VALUE		0x89
#define  INIT4_PORT			0x10F
#define  INIT4_VALUE		0x9B

/* прерывание одометра */

/* irq 11 */

#define  ODOMETR_INTERRUPT	0x73
#define  IRQ_MASK 			0xF7


/* irq 15 */
/*
#define  ODOMETR_INTERRUPT	0x77
#define  IRQ_MASK 			0x7F
*/

/* порты */
#define  DIOD_PORT			0x104
#define  STATUS_PORT		0x106
#define  ORIENTATION_PORT	0x170
#define  REQUEST_DATA_PORT	0x102
#define  PORT_2_3_SECTOR	0x101
#define  PORT_0_1_SECTOR	0x100
#define  CONTROL_PORT		0x105
#define  DATA_READY_PORT	0x10D

/* переключатель режимов */
#define  MODE_MASK			0x3e /* 00111110b */
#define  MODE_SINHRO		0x2 /* 00000010b */
#define  MODE_WORK			0x4 /* 00000100b */
#define  MODE_READ			0x8 /* 00001000b */
#define  MODE_REPORT		0x10 /* 00010000b */
#define  MODE_TEST			0x20 /* 00100000b */

/* светодиоды */
#define  DIOD_OK			0x1 /* 00000001b */
#define  DIOD_READY			0x2 /* 00000010b */
#define  DIOD_WORK			0x4 /* 00000100b */
#define  DIOD_READ			0x8 /* 00001000b */
#define  DIOD_CANCEL		0x10 /* 00010000b */

/* бит изменение которого указывает момент синхронизации */
#define  SINHRO_IMPULS		0x80 /* 10000000b */
/* бит переключающий шаг опроса одометра */
#define  ODOMETR_1CM		0x4 /* 0100b */
#define  ODOMETR_2CM		0x0 /* 0000b */
/* бит переключение которого запрашивает наличие давления в трубе */
#define  BAR_REQUEST_ON		0x2 /* 010b */
#define  BAR_REQUEST_OFF	0x0 /* 000b */
/* бит показывающий наличие давления в трубе */
#define  BAR_PRESENT		0x1 /* 01b */
/* бит показывающий работает реле давления или имитатор РД */
#define  REAL_BAR			0x40 /* 01000000b */
/* бит показывающий готовы ли данные с датчиков */
#define  DATA_READY_BIT		0x80 /* 10000000b */

/* перевернутый датчик ориентации 19.06.97 */
/*#define ORIENT_SHIFT 0x80*/
/* #define ORIENT_SHIFT 0 */

/* мигание лампочки и звуковой тон для режима синхронизации */
#define SINHRO_SWITCH_PERIOD 20000
#define SINHRO_WAIT_PERIOD 2000
#define SINHRO_TONE 100

#define  RECORD_NAME		"trace.krt"
#define  SINHRO_FILE		"sinhro.krt"

#define  M_DOS			5
#define  M_SINHRO		4
#define  M_REPORT		3
#define  M_TEST			2
#define  M_READ			1
#define  M_WORK			0

extern void Lamp(unsigned char val);

/* параметры оборудования */
#define  INDX_RATE128		100 /* частота вызова прогресс-бара при регистрации */
#define  EQUIP_ID			"krot128"
#define  KROT128_COPYRIGHT	"Krot 128 sensors translator by Vitaly Bogomolov (C) 1996"
#define  KROT128_SENSNUM	128   /* кол-во датчиков */
#define  KROT128_SENSLEV	16   /* кол-во уровней датчика */
#define  KROT128_MINSPEED	50   /* мин.скорость 0.5 м/с */
#define  KROT128_MAXSPEED	800 /* критич.скорость 6.0 м/с */
#define  KROT128_TOPSPEED	1200 /* макс.скорость 20.0 м/с */
#define  KROT128_FLAGS		0

/* константы файла данных получаемого с КРОТа */
#define  SEGM_LEN			256
#define  KROT_SIGN			0x44555353L	/* сигнатура файла данных крота */

#define  D_WELD				0x50	/* метка условного шва */
#define  D_STOP				0x60	/* метка остановки */
#define  D_BARDOWN			0x70	/* метка сброса давления */
#define  D_POWERFAIL		0x71	/* метка отказа электропитания */
#define  D_DISKFULL			0x72	/* метка переполнения диска */
#define  D_POWERON			0x7F	/* метка включения снаряда */
#define  D_DFKT01			0x90	/* метка дефекта */
#define  D_DFKT02			0x91	/* метка дефекта */
#define  D_DFKT03			0x92	/* метка дефекта */
#define  D_DFKT04			0x93	/* метка дефекта */
#define  D_DFKT05			0x94	/* метка дефекта */
#define  D_DFKT06			0x95	/* метка дефекта */
#define  D_DFKT07			0x96	/* метка дефекта */
#define  D_DFKT08			0x97	/* метка дефекта */
#define  D_DFKT09			0x98	/* метка дефекта */
#define  D_DFKT10			0x99	/* метка дефекта */
#define  D_DFKT11			0x9a	/* метка дефекта */
#define  D_DFKT12			0x9b	/* метка дефекта */
#define  D_DFKT13			0x9c	/* метка дефекта */
#define  D_DFKT14			0x9d	/* метка дефекта */
#define  D_DFKT15			0x9e	/* метка дефекта */
#define  D_DFKT16			0x9f	/* метка дефекта */

#define  OUT_SPEED			90000L	/* запредельная скорость */
#define  TIC_PER_SECOND		100L /* частота бортового таймера */

#define R_UNKNOWN	0
#define R_BARDOWN	1
#define R_POWERFAIL	2
#define R_DISKFULL	3

#define INDEX_EXT "idx"

typedef struct {
	long dist;
	short minutes;
} T_STOPINFO;

typedef struct {
	long dist;
	long pos;
	long time;
	short top;
	short speed;
} T_INDX;

typedef struct {
	long dist;
	short speed;
} T_OVERSPEED;

typedef struct {
	long dist;
	FILE *rec;
	FILE *indx;
	long node;
	long synhShift;
} T_128TRACE;

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

typedef struct {
	word year;
	byte month;
	byte day;
	byte hour;
	byte minutes;
	byte second;
	byte hsecond;
} T_SINHTIME;

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
	byte dist;
	byte num;
	byte val;
} T_ITEM;

typedef struct {
	byte sign;
	byte dist;
	word sec;
} T_ITEMSTOP;

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
	dword dist;
	dword time;
} T_2HALF_WELD;

extern void VoiceReport(char *tr_file);
extern short WaitModeChange(short oldmode);
extern short InitBort(void);
extern void Sinhronize(void);
extern void Lamp(unsigned char val);
extern void Say (const char *msg);
extern void ReadReady(void);
extern short Diags(void);