// scan.h (C) 2006 by Vitaly Bogomolov 
#ifndef KRTAPI
#include "krotw32.h"
#endif

//
// ������ ���� �������� ��������� � �����������, �������� ��������� ���
// ������� ������ ���������� ����, ����������� ���� ����� � ��������� ���������� ����.

// ��������� �������� ���� ����� 

// ����������� ���
#define TUBE_UNKNOWN  -1
// �����������
#define TUBE_DIRECT    0
// �������������
#define TUBE_SPIRAL    1
// ���������
#define TUBE_WITHOUT   2

/* *******************************************
 �������������� ��������
******************************************* */

// ��������� ������� ������ ��� ������ ����
typedef struct {

 long            x;                // ������ �������� ������ �� X
 long            y;                // ������ �������� ������ �� Y
 KRTDATA        *dat;              // ��������� �� ����� ������������ ������
 KRTROW         *row;              // ��������� �� ����� ����� ������

 long            minTubeLen;       // ����������� ����� ����� � ���������� ��������

 long            maskSize;         // ������ ����� � ���������� ��������
 long            listSize;         // ������ ���������� ����� � ���������� ��������
 long            signalLevel;      // ������� �������
 short           slitNum;          // ��������� ���������� ���������� ����
 

 short           weldSensitiv;     // ������� ���������������� ���������� ���� (�� 1 �� 100)
 short           slitSensitiv;     // ������� ���������������� ���������� ���� (�� 1 �� 100) 
                                   // ���� 0, �� ���������� ��� ���������� �� ����.
 short           spirSensitiv;     // �� �� ��� ���������� ����

 short           noDRC;            // ���� 1, �� ����� �� ����� ���� �����������
 short           noSPR;            // --- �������������
 short           noWTO;            // --- ���������

} T_SCAN_INPUT;

// ��������� �������� ������ ���������� ���
typedef struct {
 long            wldIndex;         // ������ ������� ���������� ����������� ��� (-1 ���� �� ������)
 short           wldTyp;           // ��� ����� (���� �� �������� TUBE_* ��.����)
 short           slit1;            // ����� ������� 1 ����������� ��� (-1 ���� ���)
 short           slit2;            // ����� ������� 2 ����������� ��� (-1 ���� ���)
} T_SCAN_OUTPUT;

// ������� ������� ��������� ���������. ���� ������ ��� �� ���� ���������
extern short ProccessPage (const T_SCAN_INPUT *inp, T_SCAN_OUTPUT *out);

/* *******************************************
 �������� 2013
******************************************* */

// ��������� �������� ������ ���������� ���
typedef struct {
 long            wldIndex;         // ������ ������� ���������� ����������� ��� (-1 ���� �� ������)
 short           wldTyp;           // ��� ����� (���� �� �������� TUBE_* ��.����)
 short           slit1;            // ����� ������� 1 ����������� ��� (-1 ���� ���)
 short           slit2;            // ����� ������� 2 ����������� ��� (-1 ���� ���)
 short           crzIndex;         // ����, �� �������� ���������� ���������� ���
} T_SCAN_2013_OUTPUT;

// ������� ������� ��������� ���������. ���� ������ ��� �� ���� ���������
extern short AnalyseData(const T_TRACE *trc, const VB_TUBE_SCAN_IN *inpData, T_SCAN_2013_OUTPUT *out);
