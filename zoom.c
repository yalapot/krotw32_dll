/*
������ ��������� ����
*/
#include "krotw32.h"
#include "debuglog.h"

void drawBitmap(HBITMAP bmp, HWND hwnd) {
HDC hdcSrcOld, hdcSrc, hdcDest;
RECT r;

 GetClientRect(hwnd, &r);
 hdcDest = GetDC(hwnd);
 hdcSrc = CreateCompatibleDC(hdcDest);
 hdcSrcOld = SelectObject(hdcSrc, bmp);
 BitBlt (hdcDest, 0, 0, r.right, r.bottom, hdcSrc, 0, 0, SRCCOPY);
 SelectObject(hdcSrc, hdcSrcOld);
 DeleteDC(hdcSrc);
 ReleaseDC(hwnd, hdcDest);
 return;
}

short makeEmptyBmp(
 void *bmpBuff, 
 long bmpX, 
 long bmpY, 
 T_PAL *pal
) {
int i, j;

 for (i=0; i<bmpY; i++)
  for (j=0; j<bmpX; j++) {
   putPixel(bmpBuff, bmpX*i+j, 0, pal);
  }

 return KRT_OK;
}

short  makeZoomBitmap (
 T_CRZSENS *crz, 
 HWND hwnd
) {
T_ZOOM *z;
HDC hdcDest;

 z = &(crz->zoom);

 // ������� ������ ������ ����
 if (z->bmp) DeleteObject(z->bmp);
 z->bmp = NULL;

 // ����������� ������
 hdcDest = GetDC(hwnd);
 z->bmp = CreateCompatibleBitmap(hdcDest, z->xSizePix, z->ySizePix);
 if (z->bmp == NULL) {
  sprintf(lastError, "������ ��� �������� ������� ����");
  ReleaseDC(hwnd, hdcDest);
  return KRT_ERR;
 }
 ReleaseDC(hwnd, hdcDest);

 switch (z->drawType) {

  case ZOOM_SMOOTH:

   krotStretchBlt (
    crz, 
    z->dat0Buffer,
    crz->vbScreen.orntOff ? NULL : z->datOrnt,
    z->xSizeDat,
    crz->sNum - crz->hide,
    z->bmpBuffer,
    z->bmpBuffer,
	hwnd,
	z->bmp,
    z->xSizePix,
    z->ySizePixPage,
    0,
    z->xSizePix,
    z->yStart,
    &(crz->pal), 1 );
   break;

  case ZOOM_COMMON:
  case ZOOM_LINES:

   krotStretchBlt (
    crz, 
    z->dat0Buffer,
    crz->vbScreen.orntOff ? NULL : z->datOrnt,
    z->xSizeDat,
    crz->sNum - crz->hide,
    z->bmpBuffer,
    z->bmpBuffer,
	hwnd,
	z->bmp,
    z->xSizePix,
    z->ySizePixPage,
    0,
    z->xSizePix,
    z->yStart,
    &(crz->pal), 0 );
   break;
 
  case ZOOM_3D:
  default:

    makeEmptyBmp (
     z->bmpBuffer, 
     z->xSizePix, 
     z->ySizePix, 
     &(crz->pal)
     );

 }

 SetBitmapBits(z->bmp, z->xSizePix * z->ySizePixPage * bytesPerPixel, z->bmpBuffer);
 return KRT_OK;
}

#define KRT_ZOOM_FILTER 2

short isDataInBuffer (
 T_CRZSENS *crz,
 long xStart,
 short xDataSize
) {

 if ((xStart < crz->oldPos) || ((xStart + xDataSize * crz->step) > (crz->oldPos + crz->pageDat * crz->step))) {
  return 0;
 }
 return 1;
}

short EXPORT KRTAPI krotPaintZoom (
 KRTHANDLE Handle, 
 long crzIndx, 
 HWND hwnd,
 long xStart,
 short xDataSize,
 short yStart,
 short yDataSize, 
 short *dataBuff, 
 KRTROW  *rowBuff, 
 long drawType
) {

 T_TRACE *trc;
 T_CRZSENS *crz;
 T_ZOOM *z;
 RECT r;
 long szBmp, pageY, i, j, curY;
 long offset;

 static long crz_vbFilter_active_pred = 0;
 static long crz_vbScreen_baseLine_pred = 0;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);
 z = &(crz->zoom);

 crz->pic = hwnd;
 crz->drawMode = drawType;


 // �������� ������ ���� ��������� �������
 GetClientRect(hwnd, &r);
 // ���� ����� ��������� ����������� �� ������ ������� ������� ������

 if (
     (xStart    == z->xStart)   && 
     (yStart    == z->yStart)   && 
     (xDataSize == z->xSizeDat) && 
     (yDataSize == z->ySizeDat) &&
     (r.right   == z->xSizePix) &&
     (r.bottom  == z->ySizePix) &&
     (crz_vbFilter_active_pred == crz->vbFilter.active) &&
     (flag_change_parameters_filter == FLAG_CHANGE_PARAMETER_OF_FILTER_DOWN) &&
     (crz_vbScreen_baseLine_pred == crz->vbScreen.baseLine)
 ) {
     if (drawType != z->drawType) {
      z->drawType = drawType;
      if (makeZoomBitmap(crz, hwnd) == KRT_ERR) { return KRT_ERR; }
     }
     drawBitmap(z->bmp, hwnd);
     return (short) z->filterMode;
 }

 crz_vbFilter_active_pred = crz->vbFilter.active;
 flag_change_parameters_filter = FLAG_CHANGE_PARAMETER_OF_FILTER_DOWN;
 crz_vbScreen_baseLine_pred = crz->vbScreen.baseLine;

 // �������������� ������� ������ � ����������, ���� ����������
 if (z->maxDat < xDataSize) {
  if (z->datOrnt)   free(z->datOrnt);
  if (z->datBuffer) free(z->datBuffer);
  if (z->dat0Buffer) free(z->dat0Buffer);
  z->dat0Buffer   = (KRTDATA *) malloc(xDataSize * crz->sNum * sizeof(KRTDATA));
  z->datBuffer    = (KRTROW *) malloc(xDataSize * crz->sNum * sizeof(KRTROW));
  z->datOrnt      = (long *) malloc(xDataSize * sizeof(long));
  if ((z->datBuffer == NULL) || (z->dat0Buffer == NULL) || (z->datOrnt == NULL)) {
   z->maxDat = 0L;
   sprintf(lastError, 
    "�� ���� �������� ��� ������� ������ ���� %ld ����", 
    xDataSize * (crz->sNum + 1) * (sizeof(KRTDATA) + sizeof(KRTROW) + sizeof(long))
          );
   return KRT_ERR;
  }
  z->maxDat = xDataSize;
 }

 // ���-�� ���������� ��������
 pageY = crz->sNum - crz->hide; 
 // ������ ������� �������� �� Y
 pageY = r.bottom > yDataSize ? pageY * (r.bottom / yDataSize) : pageY / (yDataSize / r.bottom);
 // ���������� ������ ������� ����������� ������ krotStretchBlt
 szBmp = pageY * r.right;

 // �������������� ������ ������� ����������� ������, ���� ����������
 if (z->maxBmp < szBmp) {
  if (z->bmpBuffer) free(z->bmpBuffer);
  z->bmpBuffer = (void *) malloc(szBmp * bytesPerPixel);
  if (z->bmpBuffer == NULL) {
   z->maxBmp = 0L;
   sprintf (lastError, 
    "�� ���� �������� ������ ��� ������� ������� ���� (%ld ����)", 
    szBmp * bytesPerPixel
           );
   return KRT_ERR;
  }
  z->maxBmp = szBmp;
 }

 // ��������� ����� ��������� ����
 z->xStart = xStart;
 z->yStart = yStart;
 z->xSizeDat = xDataSize;
 z->ySizeDat = yDataSize;
 z->xSizePix = r.right;
 z->ySizePix = r.bottom;
 z->ySizePixPage = pageY;
 z->drawType = drawType;

 if ( isDataInBuffer(crz, xStart, xDataSize) ) {

   offset = (xStart - crz->oldPos) / crz->step;

   for (i=0; i<crz->sNum; i++) {
    for (j=0; j<xDataSize; j++) {
     z->dat0Buffer[xDataSize * i + j] = crz->dat0PageBuff[crz->pageDat * i + j + offset];
     z->datBuffer[xDataSize * i + j] = crz->datPageBuff[crz->pageDat * i + j + offset];
    }
   }

   z->filterMode = KRT_ZOOM_FILTER;

 } else {

   // ��������� ������ ���� � ������ ����������� ������ � ��������
   if (readData(trc, crzIndx, xStart / crz->step, xDataSize, z->dat0Buffer, z->datBuffer)) return 1;
   z->filterMode = KRT_OK;
 }

 // ���������� ������ ����������
 degree2sens(z->datOrnt, xDataSize, crz->sNum);

 // ����������� ������ ��� ������� �������
 for (i=0; i<yDataSize; i++) {
  // ����� ������� � ���������� ������
  curY = (yStart + i) % crz->sNum;
  for (j=0; j<xDataSize; j++) {
   dataBuff[xDataSize * i + j] = z->dat0Buffer[xDataSize * curY + j];
   rowBuff[xDataSize * i + j]  = z->datBuffer[xDataSize * curY + j];
  }
 }

 // �������������� � ���������� ������ � ����������� yStart
 if (makeZoomBitmap(crz, hwnd) == KRT_ERR) { return KRT_ERR; }
 // ������� ������ ����� ����������� ������� � ���� ����
 drawBitmap(z->bmp, hwnd);
 return (short) z->filterMode;
}

/*
������� �������������� �����
*/
void initZoom(T_ZOOM *zoom) {

 zoom->xStart = 0;
 zoom->yStart = 0;
 zoom->xSizeDat = 0;
 zoom->ySizeDat = 0;

 zoom->drawType = 0;
 zoom->xSizePix = 0;
 zoom->ySizePix = 0;

 zoom->maxDat = 0;
 zoom->datBuffer = NULL;
 zoom->datOrnt = NULL;

 zoom->maxBmp = 0;     
 zoom->bmpBuffer = NULL; 

 zoom->bmp = NULL;     

}

/*
������� ����������� ������� �����
*/
void closeZoom(T_ZOOM *zoom) {

 zoom->xStart = 0;
 zoom->yStart = 0;

 zoom->drawType = 0;
 zoom->xSizeDat = 0;
 zoom->ySizeDat = 0;
 zoom->xSizePix = 0;
 zoom->ySizePix = 0;

 zoom->maxDat = 0;
 if (zoom->datBuffer) free(zoom->datBuffer);
 zoom->datBuffer = NULL;
 if (zoom->datOrnt) free(zoom->datOrnt);
 zoom->datOrnt = NULL;

 zoom->maxBmp = 0;     
 if (zoom->bmpBuffer) free(zoom->bmpBuffer);
 zoom->bmpBuffer = NULL;

 if (zoom->bmp) DeleteObject(zoom->bmp);
 zoom->bmp = NULL;     
}
