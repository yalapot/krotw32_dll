#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FLAG_CHANGE_PARAMETER_OF_FILTER_DOWN  0
#define FLAG_CHANGE_PARAMETER_OF_FILTER_UP    1
extern long flag_change_parameters_filter;

///////// ����������� �� krtapi.h ������ 1

// ��������� �������� ������������� �������
typedef struct {      
 long num;           // ����������
 long step;          // ������������ ��������� (��/������� - �� ������ ������)
 long min;           // ����������� �������� (����������� ���������� T_NODEGROUP)
 long max;           // ������������ �������� (����������� ���������� T_NODEGROUP)
} T_SENS;

///////// ����� ����������� �� krtapi.h ������ 1

#include "krtapi.h"
#include "krtapi2.h"
#include "dai.h"
#include "vbapi.h"
#include "pallete.h"
#include "driver.h"

// ��������� �������� �������� ����������� ��������� (����)
typedef struct {

 long            xStart;           // ������ ������� ���� �� X � ��
 short           yStart;           // ����� ������� ���� �� Y � ��������
 short           xSizeDat;         // �����. ������ ���� � ���������� ��������
 short           ySizeDat;         // ������. ������ ���� � ���������� ��������
 long            xSizePix;         // �����. ������ ���� � ��������
 long            ySizePix;         // ������. ������ ���� � ��������
 long            ySizePixPage;     // ������������ ������ �������� � ��������

 long            drawType;         // ��� ���������

 long            maxDat;           // ������ ������ ������ � KRTDATA.
 KRTDATA        *dat0Buffer;       // ��������� �� ����� ������������ ��������� �������� ��� ����
 long           *datOrnt;          // ��������� �� ������ ����������
 KRTROW         *datBuffer;        // ��������� �� ����� ����� ��������� �������� ��� ����

 void           *bmpBuffer;        // ��������� �� ����� �������
 long            maxBmp;           // ������ ������ ������� � ��������.
 HBITMAP         bmp;              // ������ ��� ����

 int             filterMode;       // ��� �������� krotPaintZoom

} T_ZOOM;

// ��������� �������� �������� ������� ����������� ���������
typedef struct {

 int             delta;            // ��������
 long            mode;             // �����
 KRTROW          value;            // �������� �������

} T_SENSOR;

// ��������� ������� ����
typedef struct {

 long            lastPos;          // ��������� ������ ������ �������
 long            bufSize;          // ������� ������ ������� �� X � ����������
 KRTDATA        *dat;              // ��������� �� ����� ������������ ������
 KRTROW         *row;              // ��������� �� ����� ����� ������

} T_WELDSCAN;

// ��������� �������� ����� �������� ����������� ���������
typedef struct {

 long            index;            // ������ ����� 
 long            needRedraw;       // ���� ������������� ������������ �������
 long            topSens;          // ������� ��������� (����� �������� �����.�������)
 T_WELDSCAN      scan;             // ��������� ������ ������� ����
 VB_PAINT_INFO   vbScreen;         // ��������� �������� ������ ����������� ��������� �������� ������
 VB_GRAPH_INFO   vbGraphs;         // ��������� �������� ������ ����������� ��������� ���������
 VB_FILTER_INFO  vbFilter;         // ��������� �������� �������� ��� ����������� ��������� �������� ������
 HWND            pic;              // ����� pictureBox ���������
 long            drawMode;         // ����� ������ (����/�������)
 T_PAL           pal;              // �������
 T_ZOOM          zoom;             // ����
 T_SENSOR       *sensor;           // ��������� �� ������ �������� ��������
 long            hide;             // ���-�� ����������� ��������
 void           *bmpBuff;          // ��������� �� ����� �������
 void           *bmpBuffScroll;    // ��������� �� ����� ������������� ���������� �������
 HBITMAP         bmp;              // ������ ��� ��������� �������� �������

 // ��������� ������ ������� ������ ���� ������ ����, ����� ��������� ������ ���
 // ������������� ������ ��� ���� ������� (��. ����������� � ������� changeScreenMode)
 KRTROW         *datScrlBuff;      // ��������� �� ����� ����� ������ ��� ������
 long           *datScrlOrnt;      // ��������� �� ������ ���������� ���������� ������
 KRTROW         *datPageBuff;      // ��������� �� ����� ����� ������ ��� ��������
 long           *datPageOrnt;      // ��������� �� ������ ���������� ����������� ������
 KRTDATA        *dat0ScrlBuff;     // ��������� �� ����� ������������ ������ ��� ������
 KRTDATA        *dat0PageBuff;     // ��������� �� ����� ������������ ������ ��� ��������

 long            oldPos;           // ���������� ��������� �� ������

 // ��������� ��� ���� ������ ������������ �������� �������, ����������� � �������
 // �������� ������ ������. ��� ���������� ��� �������� ������� � �����������������
 // ������� ������� � ������� ����������.
 long            maxDatPage;       // ������������ ������ �������� ������ �� X
 long            maxBmpSize;       // ����������� ������ ������ ������� � ��������

 // ��������� ���� ��������������� �������� changeScreenMode ������ �� ��������
 // �� ���������� vbScreen->hWnd (������ ���� �� X � ��������), vbScreen->xSize � �.�.
 long            pageDat;          // ������ ������������ �������� ������ �� X � ���������� ��������
 long            pixelX;           // ������ ���� ��������� �� X � ��������
 long            pixelY;           // ������ ���� ��������� �� Y � ��������

 // ��� �������� ������� ����� � ���� �����.�������� ����������
 // �� T_TRACEINFO ���� � openTrace
 long            step;             // ��� ������ �����. ��������
 long            sNum;             // ���-�� �����. ��������
 long            sType;            // ��� �������� ����� SENS_TYPE_* �� krtBase.h

} T_CRZSENS;

// ��������� �������� �������
typedef struct {

 KRTHANDLE       vbHandle;         // ���������� �������
 T_DRIVER        drv;              // ��������� �������� �������� �������
 T_TRACEINFO     record;           // ��������� �������� ���������� �������
 T_CRZSENS      *crz;              // ��������� �� ������ ��������,
                                   // ����������� ����� �������� ����������� ���������
 long            lockNodeSeq;      // ���� ���������� ������� *FirstNode* ��� �������
 long            isOnLine;         // ���� ������ ������������ �������� ������
 long            scaleX;           // ������� �� X

} T_TRACE;

// ������ �������� ��������
typedef struct T_TRACELIST {
 T_TRACE trace;
 struct T_TRACELIST *next;
 struct T_TRACELIST *prev;
} T_TRACELIST;

/* ���������� ���������� ���������� */
extern char lastError[];
extern long bytesPerPixel;
extern long bitsPerPixel;

/* ���������� ��������� ������� krotw32.c */
extern T_TRACE *TraceList (KRTHANDLE Handle);
extern const char *driverError(T_TRACE *trc);

extern void closeZoom(T_ZOOM *zoom);
extern void initZoom(T_ZOOM *zoom);

extern void krotStretchBlt (
  T_CRZSENS *crz,
  KRTDATA *data,
  long *ornt,
  long datX,
  long datY,
  void *bmpBuff,
  void *bmpBuffGrafh,
  HWND pic,
  HBITMAP bmp,
  long bmpX,
  long bmpY,
  long bmpXstart,
  long bmpXend,
  long top,
  T_PAL *pal, 
  int smooth
);

extern short readData(
 T_TRACE *trc,
 long crz,
 long dStart,
 long dLength,
 KRTDATA *buf,
 KRTROW *row);

extern void degree2sens(
 long *ornt,          // ������ ����������
 long vLen,           // ����� �������
 long sensNum         // ����� ���-�� �������� 
 );

short allocMem(long bufSize, void **bufAddr, const char *msg);
short makeDatBuff(T_CRZSENS *crz, long xSize, char *callStack);
short makeBmpBuff(T_CRZSENS *crz, long pixelX, long pixelY);
