/*
������ ��������� ������
*/
#include "krotw32.h"
#include "debuglog.h"

static T_PAL palEdit;           // �������, ������������� � ��������� ������
long bytesPerPixel = 0;         // ���-�� ���� �� ������ � ����������� �� �����������
long bitsPerPixel = 0;          // ���-�� ��� �� ������ � ����������� �� �����������

/*
 ������� �������������� ������� pal
*/
short palInit(T_PAL *pal) {

 pal->pic.X                   = 0;
 pal->pic.Y                   = 0;
 pal->pic.maxX                = 0;
 pal->pic.dataVect            = NULL;
 pal->pic.bmp                 = NULL;

 pal->core.Item               = NULL;
 pal->core.changed            = 0;
 pal->core.maxItemNum         = 0;
 pal->color                   = malloc(3 * sizeof(T_PAL_DIAP));
 if (pal->color == NULL) {
  sprintf(lastError, "�� ���� �������� %ld ���� ������ (palInit)", sizeof(T_PAL_DIAP));
  return KRT_ERR;
 }

 pal->core.head.itemNum       = 0;
 pal->core.head.minItem.iPos  = 0;
 pal->core.head.minItem.iVal  = 0;
 pal->core.head.maxItem.iPos  = 0;
 pal->core.head.maxItem.iVal  = 0;

 return KRT_OK;
}

/*
 ������� ����������� ������� �� ������� pal
*/
void palClose(T_PAL *pal) {

 if (pal->pic.dataVect) free(pal->pic.dataVect);
 pal->pic.dataVect = NULL;
 if (pal->core.Item) free(pal->core.Item);
 pal->core.Item = NULL;
 if (pal->color) free(pal->color);
 pal->color = NULL;

 if (pal->pic.bmp) DeleteObject(pal->pic.bmp);
 pal->pic.bmp = NULL;

 pal->pic.maxX        = 0;
 pal->core.maxItemNum = 0;
}

/*
 ������� ������������� ������ ������� plt.
 �������� item ��� ��������� �� ������ ��������� ������� ����� ������ � ���������.
 ������ ���� ������������� �� item->iPos �� �����������.
 ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
*/
static short palSet (
 T_PAL *plt,
 VB_PAL *pal,
 long brdMin,
 long brdMax,
 long usrMin,
 long usrMax,
 VB_PAL_ITEM *item
) {
long i;
double kf;

 // �������� ����� ��� ������� ��������� �������, ���� ����������
 if (plt->core.maxItemNum < pal->itemNum) {
  if (plt->core.Item) {
   free(plt->core.Item);
   plt->core.maxItemNum = 0;
   plt->core.head.itemNum = 0;
  }
  if (plt->color) {
   free(plt->color);
  }
  plt->core.Item = malloc(pal->itemNum * sizeof(VB_PAL_ITEM));
  if (plt->core.Item == NULL) {
   sprintf(lastError, "�� ���� �������� %ld ���� ������ (plt->core.Item)", pal->itemNum * sizeof(VB_PAL_ITEM));
   return KRT_ERR;
  }
  plt->color = malloc((pal->itemNum+3) * sizeof(T_PAL_DIAP));
  if (plt->color == NULL) {
   sprintf(lastError, "�� ���� �������� %ld ���� ������ (plt->color)", (pal->itemNum+1) * sizeof(T_PAL_DIAP));
   return KRT_ERR;
  }
  plt->core.maxItemNum = pal->itemNum;
 }

 plt->core.head.itemNum = pal->itemNum;

 plt->core.head.minItem.iPos = pal->minItem.iPos;
 plt->core.head.minItem.iVal = pal->minItem.iVal;

 plt->core.head.maxItem.iPos = pal->maxItem.iPos;
 plt->core.head.maxItem.iVal = pal->maxItem.iVal;

 // ��������� �������� ������. ���� �������� ������ ������ ������� ���������,
 // �� ��� �������������� ������ ������ �������. ���� ������ ������� �������,
 // �� �������������� ������ ������� �������. ����� ����� ������ ������ �����.
 plt->border.min.iVal = pal->minItem.iVal;
 plt->border.max.iVal = pal->maxItem.iVal;

 plt->border.min.iPos = brdMin;
 plt->border.max.iPos = brdMax;

 plt->usrMin = usrMin;
 plt->usrMax = usrMax;

 // ��������� ������ ���������� � ������ ���������������� ������
 plt->color[0].min.iPos = plt->border.min.iPos;
 plt->color[0].max.iPos = plt->usrMin;
 plt->color[0].min.iVal = plt->border.min.iVal;
 plt->color[0].max.iVal = plt->border.min.iVal;

 plt->color[1].min.iPos = plt->usrMin;
 plt->color[1].min.iVal = plt->border.min.iVal;

 kf = (double) (plt->usrMax - plt->usrMin) /
      (double) (plt->core.head.maxItem.iPos - plt->core.head.minItem.iPos);

 for (i=0; i<pal->itemNum; i++) {
  if (i>0) {
   plt->color[i+1].min.iPos = plt->color[i].max.iPos;
   plt->color[i+1].min.iVal = plt->color[i].max.iVal;
  }
  plt->color[i+1].max.iPos = plt->usrMin + (long) (item[i].iPos * kf);
  plt->color[i+1].max.iVal = item[i].iVal;
  plt->core.Item[i].iPos = item[i].iPos;
  plt->core.Item[i].iVal = item[i].iVal;
 }

 if (i>0) {
  plt->color[i+1].min.iPos = plt->color[i].max.iPos;
  plt->color[i+1].min.iVal = plt->color[i].max.iVal;
 }
 plt->color[i+1].max.iPos = plt->usrMax;
 plt->color[i+1].max.iVal = plt->border.max.iVal;

 plt->color[i+2].min.iPos = plt->usrMax;
 plt->color[i+2].min.iVal = plt->border.max.iVal;
 plt->color[i+2].max.iPos = plt->border.max.iPos;
 plt->color[i+2].max.iVal = plt->border.max.iVal;

 plt->core.changed = 1;
 return KRT_OK;
}

/*
 ������� ���������� ���� pal � ����� ������� buff �� �������� index
 � ������������ � ������� ������������
*/
static INLINE void putPix(void *buff, long index, RGBQUAD pal) {
short rgbRed, rgbGreen, rgbBlue;
short *bmpHigh;
long *bmpTrue;
BYTE *bmp16k;

 switch (bitsPerPixel) {

  case 32:
   bmpTrue = (long *) buff;
   bmpTrue[index] = *((long *) &pal);
   break;

  case 15:
   bmpHigh        = (short *) buff;
   rgbRed         = (short) (pal.rgbRed >> 3);
   rgbGreen       = (short) (pal.rgbGreen >> 3);
   rgbBlue        = (short) (pal.rgbBlue >> 3);
   bmpHigh[index] = (short) (rgbBlue | (rgbGreen << 5) | (rgbRed << 10));
   break;

  case 16:
   bmpHigh        = (short *) buff;
   rgbRed         = (short) (pal.rgbRed >> 3);
   rgbGreen       = (short) (pal.rgbGreen >> 2);
   rgbBlue        = (short) (pal.rgbBlue >> 3);
   bmpHigh[index] = (short) (rgbBlue | (rgbGreen << 5) | (rgbRed << 11));
   break;

  case 24:
   bmp16k = (BYTE *) buff;
   index = index+index+index;
   bmp16k[index] = pal.rgbBlue;
   bmp16k[index+1] = pal.rgbGreen;
   bmp16k[index+2] = pal.rgbRed;
   break;

  default:
   break;
 }
}

/*
 ������� ��������� ��� ����� ��� �������� val, ������������ � ���������
 color.min.iPos - color.max.iPos  � ���������� ������� color.min.iVal - color.max.iVal
 ��� ����� ������������ ��� ����������� ������� ����� ���������� �������, ��������
 ��������� val ����� ���������� ���������� ��������� color.
*/
static INLINE RGBQUAD getGradientColor(T_PAL_DIAP *color, long v) {
RGBQUAD c, clr;
short rgbRed, rgbGreen, rgbBlue;
__int64 len, val;

 c.rgbRed   = GetRValue(color->min.iVal);
 c.rgbGreen = GetGValue(color->min.iVal);
 c.rgbBlue  = GetBValue(color->min.iVal);

 rgbRed   = (short) (GetRValue(color->max.iVal) - c.rgbRed);
 rgbGreen = (short) (GetGValue(color->max.iVal) - c.rgbGreen);
 rgbBlue  = (short) (GetBValue(color->max.iVal) - c.rgbBlue);

 val = v - color->min.iPos;
 len = color->max.iPos - color->min.iPos;
 if (len == 0) { return c; }

 clr.rgbRed   = (BYTE) (c.rgbRed + rgbRed * val / len);
 clr.rgbGreen = (BYTE) (c.rgbGreen + rgbGreen * val / len);
 clr.rgbBlue  = (BYTE) (c.rgbBlue + rgbBlue * val / len);

 return clr;
}

/*
 ������� ���������� ��� ����� ��� �������� val �������� ���������� ������� plt
 ������������ ������ plt->color, ������� ��������, � ������� ������ ���� ��� val
 � ������ �������.
*/
static INLINE RGBQUAD findColor(long val, T_PAL *plt) {
T_PAL_DIAP tmp;
long i;
RGBQUAD zero;

 // ��������� �� �������� ����� ����������� ��������
 if (!((val > plt->color[0].max.iPos) || (val < plt->color[0].min.iPos))) {
  return getGradientColor(&(plt->color[0]), val);
 }

 // �������� � ��������� ����������
 for (i=1; i<(plt->core.head.itemNum+3); i++) {
  if (!((val > plt->color[i].max.iPos) || (val < plt->color[i].min.iPos))) {
   // �������� ��������� �������� ����� � ������ �������.
   tmp = plt->color[i-1];
   plt->color[i-1] = plt->color[i];
   plt->color[i] = tmp;
   return getGradientColor(&(plt->color[i-1]), val);
  }
 }

 // ���������, �� ���������� �� �������� �� ���������
 // ������������� ��������� ��������
 if (val <= plt->border.min.iPos) {
  zero.rgbRed   = GetRValue(plt->border.min.iVal);
  zero.rgbGreen = GetGValue(plt->border.min.iVal);
  zero.rgbBlue  = GetBValue(plt->border.min.iVal);
  return zero;
 }
 if (val >= plt->border.max.iPos) {
  zero.rgbRed   = GetRValue(plt->border.max.iVal);
  zero.rgbGreen = GetGValue(plt->border.max.iVal);
  zero.rgbBlue  = GetBValue(plt->border.max.iVal);
  return zero;
 }

 // ���� �������� �� ������
 zero.rgbRed   = 0;
 zero.rgbGreen = 0;
 zero.rgbBlue  = 0;

 return zero;
}

/*
 ������� ���������� �������� val � ����� ������� buff �� �������� index
 � ������������ � ������� ������������ � ����������� ������� pal
*/
extern INLINE void putPixel(void *buff, long index, long val, T_PAL *plt) {
  putPix(buff, index, findColor(val, plt));
}

/*
 ������� ������ ������� plt � ���� hwnd.
 ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
*/
static short palDraw (
 T_PAL *plt,
 HWND   hwnd
) {
long Y, X, i;
RECT r;
HDC hdcSrc, hdcDest;
double kf;

 hdcDest = GetDC(hwnd);
 hdcSrc = CreateCompatibleDC(hdcDest);

 /* ���������� ������� ������� �������� ������� */
 GetClientRect(hwnd, &r);
 Y = r.bottom - r.top;
 X = r.right - r.left;

 if ((plt->pic.X != X) || (plt->core.changed)) {
  // �������� ������ ��� ������ �������, ���� ����������
  if (plt->pic.maxX < X) {
   if (plt->pic.dataVect) {
    free(plt->pic.dataVect);
    plt->pic.maxX = 0;
    plt->pic.X = 0;
   }
   plt->pic.dataVect = malloc(X * bytesPerPixel);
   if (plt->pic.dataVect == NULL) {
    sprintf(lastError, "�� ���� �������� %ld ���� ������ (plt->pic.dataVect)", X * sizeof(long));
    return KRT_ERR;
   }
   plt->pic.maxX = X;
  }

  plt->pic.X = X;
  plt->pic.Y = Y;

  // ���������� ������� �� ������ ������
  kf =  (double) (plt->border.max.iPos - plt->border.min.iPos) / (double) plt->pic.X;
  for (i=0; i < plt->pic.X; i++) {
   putPixel(plt->pic.dataVect, i, (long) (i * kf), plt);
  }

  // ����������� ������ �������
  if (plt->pic.bmp) {
   DeleteObject(plt->pic.bmp);
   plt->pic.bmp = NULL;
  }
  plt->pic.bmp = CreateCompatibleBitmap(hdcDest, plt->pic.X, 1);
  if (plt->pic.bmp == NULL) {
   sprintf(lastError, "������ ��� �������� ������� �������");
   return KRT_ERR;
  }
  SetBitmapBits(plt->pic.bmp, plt->pic.X * 1 * bytesPerPixel, plt->pic.dataVect);

  plt->core.changed = 0;
 }

 // ������� �������������� ������ ������� � �������� ����
 SelectObject(hdcSrc, plt->pic.bmp);
 StretchBlt(hdcDest, r.left , r.top , r.right, r.bottom, hdcSrc, 0, 0, X, 1, SRCCOPY);
 DeleteDC(hdcSrc);
 ReleaseDC(hwnd, hdcDest);

 return KRT_OK;
}

/*************************************************************
  �������������� � VB �������
**************************************************************/

/* *************************************************************************
������� ���������� ��� �������� ���������� �������� ����������� � ���������
�� ���� ���������� ������� ���������.
���� ������� ���������� �������� ��� ��������� ��������� ���������� KRT_OK,
� ��������� ������ ���������� KRT_ERR.
����������� �������� ������ �������� ����� ������� krotError.
*/
short EXPORT KRTAPI checkVmode (void) {
HDC hDC;
int allClr;

 hDC = CreateDC ("DISPLAY", NULL, NULL, NULL);
 if (hDC == NULL) {
  sprintf (lastError, "������ ��� ������ CreateDC(DISPLAY, NULL, NULL, NULL)");
  return KRT_ERR;
 }

 allClr = GetDeviceCaps(hDC, BITSPIXEL);
 bitsPerPixel = allClr;

 switch (allClr) {

  case 15:
   bytesPerPixel = 2;
   break;

  case 16:
   bytesPerPixel = 2;
   if (GetProfileInt("Display","HighColor",16) == 15) {
    bitsPerPixel=15;
   }
   break;

  case 24:
   bytesPerPixel = 3;
   break;

  case 32:
   bytesPerPixel = 4;
   break;

  default:
   sprintf (
    lastError,
    "������� ���������� �� ��������������.\n���������� �����������:\n"
    "High Color (16 bps)\nTrue Color (32bps)"
           );
   return KRT_ERR;
 }

 DeleteDC (hDC);
 return KRT_OK;
}

/*
 ������� ���������� ���� �� ���� ������������ ����� colorCode.
 ����� ������������ ������� ������ �������� rgbItem, ������� �����
 ��������� ���� �� ���� �������� RGB_*
*/
short EXPORT KRTAPI rgbColor (long colorCode, short rgbItem) {
 switch (rgbItem) {
  case RGB_RED:
   return GetRValue(colorCode);
  case RGB_GREEN:
   return GetGValue(colorCode);
  case RGB_BLUE:
   return GetBValue(colorCode);
 }
return 0;
}

/*
 ������� �������������� ������� ��� ��������� ������.
*/
short EXPORT KRTAPI krtPalInit (void) {
 // ������� �������� ��� ������� ��������� ����������� signed dword (�� 0 �� 2147483647)
 palEdit.border.min.iPos = 0x0;
 palEdit.border.max.iPos = 0x7FFFFFFF;
 return palInit(&palEdit);
}

/*
 ������� ����������� ������� �� ������� ��� ��������� ������.
*/
void EXPORT KRTAPI krtPalClose (void) { palClose(&palEdit); }

/*
 ������� ������������� ������ ������� ��� �������, ��������� ������������ Handle.
 ���� Handle == -1, �� ������ ��������������� ��� ��������� ������.
 �������� item ��� ��������� �� ������ ��������� ������� ����� ������ � ���������.
 ������ ���� ������������� �� item->iPos �� �����������.
 ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
*/
short EXPORT KRTAPI krtPalSet (
 KRTHANDLE Handle,
 long crzIndx,
 long brdMin,
 long brdMax,
 long usrMin,
 long usrMax,
 VB_PAL *pal,
 VB_PAL_ITEM *item
) {
T_TRACE *trc;
T_PAL *plt;


 if (Handle == -1) {

  plt = &palEdit;

 } else {

  trc = TraceList(Handle);
  if (trc == NULL) return KRT_ERR;
  plt = &(trc->crz[crzIndx].pal);
  trc->crz[crzIndx].needRedraw = 1;

 }

 return palSet(plt, pal, brdMin, brdMax, usrMin, usrMax, item);
}

/*
 ������� ������ ������� ������ �������� ������������ Handle � ���� hwnd.
 ���� Handle == -1, �� �������� ������� ��������� ������.
 ���������� KRT_OK ��� ������, KRT_ERR ��� ������.
*/
short EXPORT KRTAPI krtPalDraw (
 KRTHANDLE Handle,
 long crzIndx,
 HWND    hwnd
) {
T_TRACE *trc;
T_PAL *plt;

 if (Handle == -1) {

  plt = &palEdit;

 } else {

  trc = TraceList(Handle);
  if (trc == NULL) return KRT_ERR;
  plt = &(trc->crz[crzIndx].pal);

 }

 return palDraw(plt, hwnd);
}

/*
 ������� ��������� ������ pallete � ������ ������������ ������
 ������� palUp � palDn �� ������ ������� paldflt.
*/
/*
void setWorkPal(RGBQUAD *paldflt, RGBQUAD *palette, long palUp, long palDn) {
int i;

 // ���������� ������ ������������� ����� ������������ �������
 for (i=0; i<palDn; i++) {
  palette[i] = paldflt[0];
 }
 // ���������� ������� ������������� ����� ������������ �������
 for (i=palUp; i<KRT_PALLETE_SIZE; i++) {
  palette[i] = paldflt[KRT_PALLETE_SIZE-1];
 }
 // ���������� ������� ������ ����� ������������ �������
 for (i=palDn; i<palUp; i++) {
  palette[i] = paldflt[KRT_PALLETE_SIZE * (i - palDn) / (palUp - palDn)];
 }

}
*/