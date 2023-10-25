/*
���� ��������� �������
*/

#include "krotw32.h"
#include "debuglog.h"

/* *************************************************************************
������� ���������� � ���� outFileName ���� ������ ����� ������ ���� 
����� crzIndx � ������ Handle
��� ������  ���������� KRT_OK, KRT_ERR ��� ������.
����������� �������� ������ �������� ����� ������� krotError.
*/
short EXPORT KRTAPI krotZoomDump (
 KRTHANDLE Handle, 
 long crzIndx, 
 LPSTR outFileName, 
 long isRow
) {

T_TRACE *trc;
T_CRZSENS *crz;
T_ZOOM *zoom;
FILE *dump;
int i, j, xSize, indx;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);
 zoom = &(crz->zoom);

 dump = fopen(outFileName, "wt");
 if (dump == NULL) {
  sprintf (lastError, "�� ���� ������� ��� ������ ���� %s", outFileName);
  return KRT_ERR;
 }

 xSize = zoom->xSizeDat;
 for (i=0; i<xSize; i++) {
  for (j=0; j<zoom->ySizeDat; j++) {

   indx = zoom->yStart + j;
   if (indx >= trc->record.group[crzIndx].num) {
     indx -= trc->record.group[crzIndx].num;
   }

   if (isRow) {
    fprintf(dump, "%s%05d", (j ? ", " : ""), zoom->datBuffer[xSize*indx + i]); 
   } else {
    fprintf(dump, "%s%03d", (j ? ", " : ""), zoom->dat0Buffer[xSize*indx + i]);
   }
  }
  fprintf(dump, "\n");
 }

 fclose(dump);
 return KRT_OK;
}

/* *************************************************************************
������� ���������� � ����� outFileName(i), ��� i=1..n, � n - ����� ������ 
���� ������ ����� ������ ���� ��� ������� ����� � ������ Handle
��� ������  ���������� KRT_OK, KRT_ERR ��� ������.
����������� �������� ������ �������� ����� ������� krotError.
*/
short EXPORT KRTAPI krotZoomDumpEx (
 KRTHANDLE Handle, 
 long crzIndx,
 long xStart,
 short xDataSize,
 LPSTR outFileName, 
 long isRow
) {

T_TRACE *trc;
T_CRZSENS *crz;
T_ZOOM *zoom;
FILE *dump;
LPSTR outFileNameI;
char strCrzIndex[2];
int nStrLen, crzIndex;
KRTDATA *dat0Buffer;
KRTROW *datBuffer;

int i, j, ySize, xSize, yStart;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);
 zoom = &(crz->zoom);
 
 xSize = zoom->xSizeDat;
 yStart = zoom->yStart;
 ySize = zoom->ySizeDat+yStart;

 datBuffer = NULL;
 dat0Buffer = NULL;
 
 for(crzIndex = 0; crzIndex < trc->record.sensGroups; crzIndex++)
 {
	 crz = &(trc->crz[crzIndex]);
	 
	 if (datBuffer) free(datBuffer);
	 if (dat0Buffer) free(dat0Buffer);
	 dat0Buffer   = (KRTDATA *) malloc(xDataSize * crz->sNum * sizeof(KRTDATA));
	 datBuffer    = (KRTROW *) malloc(xDataSize * crz->sNum * sizeof(KRTROW));

	 if (readData(trc, crzIndex, xStart / crz->step, xDataSize, dat0Buffer, datBuffer)) return KRT_ERR;
	 
	 
	 //���������� ������ ���� � ����� ��� ������ ������ �� i-��� �����
	 nStrLen = strlen(outFileName) + 1 + 3;//������� ����-���������� ������ � 2 ������� ��� ������ ������
	 outFileNameI = NULL;
	 outFileNameI = (LPSTR) calloc(nStrLen, sizeof(char));
	 
	 strncpy(outFileNameI, outFileName, nStrLen - 8);
	 strcat(outFileNameI, "_");
	 if ((crzIndex < 99) && (crzIndex >= 0))
	 {
		 sprintf(strCrzIndex, "%d", crzIndex + 1);
		 strcat(outFileNameI, strCrzIndex);
	 }
	 strcat(outFileNameI, ".csv");

	 dump = fopen(outFileNameI, "wt");
	 if (dump == NULL) {
	  sprintf (lastError, "�� ���� ������� ��� ������ ���� %s", outFileName);
	  return KRT_ERR;
	 }

	  
	 for (i=0; i<xSize; i++) {
	  for (j=yStart; j<ySize; j++) {
	   if (isRow) {
		fprintf(dump, "%s%05d", (j ? ", " : ""), datBuffer[xSize*j + i]); 
	   } else {
		fprintf(dump, "%s%03d", (j ? ", " : ""), dat0Buffer[xSize*j + i]);
	   }
	  }
	  fprintf(dump, "\n");
	 }

	 fclose(dump);
	 free(outFileNameI);
 }
 if (datBuffer) free(datBuffer);
 datBuffer = NULL;
 if (dat0Buffer) free(dat0Buffer);
 dat0Buffer = NULL;
 return KRT_OK;
}

/* *************************************************************************
������� ���������� � ���� outFileName ���� ������ ����� ������ ������� ��������
����� crzIndx � ������ Handle
��� ������  ���������� KRT_OK, KRT_ERR ��� ������.
����������� �������� ������ �������� ����� ������� krotError.
*/
short EXPORT KRTAPI krotCorozDump (
 KRTHANDLE Handle, 
 long crzIndx, 
 LPSTR outFileName, 
 long isRow
) {

T_TRACE *trc;
T_CRZSENS *crz;
FILE *dump;
int i, j, ySize, xSize;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);

 ySize = trc->record.group[crzIndx].num;
 xSize = crz->pageDat;

 dump = fopen(outFileName, "wt");
 if (dump == NULL) {
  sprintf (lastError, "�� ���� ������� ��� ������ ���� %s", outFileName);
  return KRT_ERR;
 }

 for (i=0; i<xSize; i++) {
  for (j=0; j<ySize; j++) {
   if (isRow) {
    fprintf(dump, "%s%05d", (j ? ", " : ""), crz->datPageBuff[xSize*j + i]); 
   } else {
    fprintf(dump, "%s%03d", (j ? ", " : ""), crz->dat0PageBuff[xSize*j + i]);
   }
  }
  fprintf(dump, "\n");
 }

 fclose(dump);
 return KRT_OK;
}

/* *************************************************************************
������� ���������� � ����� ������ ������ �� ���� src
��� ������  ���������� KRT_OK, KRT_ERR ��� ������.
����������� �������� ������ �������� ����� ������� krotError.
*/
short EXPORT KRTAPI krotSetClipboard (
  HWND      src          // hwnd ���� ��������� ������
) {

HBITMAP newBmp;
HDC hdcSrc, hdcDest;
RECT r;

 // ����������� ������
 hdcSrc = GetDC(src);
 GetClientRect(src, &r);
 newBmp = CreateCompatibleBitmap(hdcSrc, (r.right - r.left ), (r.bottom - r.top));
 if (newBmp == NULL) {
  sprintf(lastError, "������ ��� �������� ������� ������");
  return KRT_ERR;
 }
 hdcDest = CreateCompatibleDC(hdcSrc);
 SelectObject(hdcDest, newBmp);
 BitBlt(hdcDest, r.left , r.top , (r.right - r.left ), (r.bottom - r.top), hdcSrc, r.left , r.top, SRCCOPY);
 
 if (!OpenClipboard(NULL)) {
   sprintf(lastError, "������ OpenClipboard(NULL)");
   return KRT_ERR;
 }

 EmptyClipboard(); 
 SetClipboardData(CF_BITMAP, newBmp); 
 CloseClipboard();

 DeleteDC(hdcDest);
 ReleaseDC(src, hdcSrc);

 return KRT_OK;
}
