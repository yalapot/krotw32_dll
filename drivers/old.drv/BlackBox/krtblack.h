// Krot386e.h - ��������  ��� ������ Krot384e.c.
// ���������� ���������� ��������, ������ � ���������������� ������� ��������
// ��������� ������ ������������ ����� "384 epro" ���������� KrotW32
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

#define  MAX_TRACE          8     /* ������������ ���������� ��������    */
                                  /* ������������ �������                */

#ifdef SENS64
#define  KROT_BLACK_BOX_ALL_SENS   64
#endif

#ifdef SENS128
  #define  KROT_BLACK_BOX_ALL_SENS   128
#endif
           /* ^^^^ ���-�� �������� �������� �� ���� ������ */

#define  CYCLE_INQUIRY   (6+KROT_BLACK_BOX_ALL_SENS*2)   /* ������ ����� ������ � ������ */


#define  CONDITIONAL_SEAM_HEADER_LEN  16  /* ������ ��������� ��������� ��� */
                                          /* � ������                       */
#define  CONDITIONAL_SEAM_STD_LEN    200  /* ����������� ���������� �����   */
                                          /* ��������� ����� � ��������     */
                                          /* �������� (�� ������)           */
                                          /* ������. ���� � �����   */

///////////////////////////////////////////////////////////
// �������� ������ ��� ����� �������������� ���������
///////////////////////////////////////////////////////////
#define MAX_AVERAGE_LENGTH  1024 // ������������ ��������

///////////////////////////////////////////////////////////
// �������� ������ ��� ������ � �������
///////////////////////////////////////////////////////////

#pragma pack (1)

typedef struct {      /* �������� ������ ������ ����� ������ (10 ��) */
   word skip_cycle;   /* ������� ����� ��. ������ � ������ ����� ������  */
   byte odom_number;  /* ����� ������������� �������� */
   byte vibro_1;      /* ����������� 1 */
   byte vibro_2;      /* ����������� 2 */
   byte vibro_3;      /* ����������� 3 */
   word sens[KROT_BLACK_BOX_ALL_SENS];  /* ������� �������� */
} T_RECORD_OF_ONE_CYCLE_INQUIRY;

typedef struct {    /* �������� ��������� ��������� ��� (2 �) */
    byte  arc_mode;     /* ����� ������������� (���-�� ���������� �����) */
    byte  orientation;  /* ��������� ������ ����������                   */
    dword time;         /* ����� �������� � ����� �������                */
    dword track;        /* �����. �� ���. ������ � �������� ��������     */
    byte  real_inquiry; /* �������� ���-�� ��������� ����� ������. ����� */
    dword ver_file;     /* ������ ������� ������ �����                   */
    byte  termo;        /* ��������� ������������                        */
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