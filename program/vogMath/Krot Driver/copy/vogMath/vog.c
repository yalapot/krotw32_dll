//////////////////////////////////////////////////////////////////////////
// ������ �������� ��������� ������ �� ��������� ������������� ������ 
// ��� ����������� ������ (C) 2006 by Vitaly Bogomolov, Alexander Nikonov

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "winkrt.h"
#include "fileTool.h"
#include "iniTool.h"
#include "vogTrc.h"
#include "vogMath.h"

///////////////////////////////////////////////////////
// ��������� � ��������� ������������ ������
char lastVogError[4048];

///////////////////////////////////////////////////////
// ������� ��������� ������ outString ��������� ��������� ������ ������������
// ��� ������ � �������� ��������. ���������� ����� ������ ��������� �� ������.
long EXPORT KRTAPI vogError (char * outString) {
 strcpy(outString, lastVogError);
 return strlen(lastVogError);
}

///////////////////////////////////////////////////////
// ������� ���� � ��������, ��� ���������� primFile ����� ��������� ������������� ������.
// ���� �������, �� ������� ��������� ����� ������������� ������ � �������� indxFolder.
// ����� ����� ���������� ���� �� ��������� ����� � trc-���� trcFile,
// � �����, ������������ � ����� vogTrc.h
// � �������� ������ �������� ������� informUser, �������� ������������ � ���� ������.
long EXPORT KRTAPI krotCreateVogIndex (
 const char * primFile, 
 const char * indxFolder,           
 const char * trcFile, 
 long (KRTAPI *informUser) (short percentDone, const char *msg)
) {

char buf[1024];
char *fl;
FILE * out;
int i;

 // ��������������� ������ ��� ������� ���������� �����  
 sprintf(buf, "%s\\%s", indxFolder, VOG_FILE_FIELD);

 // ���� ���� ���� ���������� � ��� �� ��������, ��� � trc-����
 // ������������ �������� ����� ������, ��� ������ �����
 // ��� ����������� �������� ��������� ����� ������� � ����������.
 fl = (isSamePlace(buf, trcFile) ? VOG_FILE_FIELD : buf);
 setIniItem(trcFile, VOG_DATA, VOG_DATA_FIELD, fl);

 // ����� ��������� � ��������� ���������� ����� ������ ���� ���,
 // ����������� ����������� ���� �������.
 out = fopen(fl, "wb");
 if (!out) {
  sprintf(lastVogError, "�� ���� ������� ���� %s", fl);
  return KRT_ERR; 
 }
 // ... ��� �����
 fclose(out);


 // ����������� ��������� ��� ������� ���������� �����
 sprintf(buf, "%s\\%s", indxFolder, VOG_FILE_COORD);
 fl = (isSamePlace(buf, trcFile) ? VOG_FILE_COORD : buf);
 setIniItem(trcFile, VOG_DATA, VOG_DATA_COORD, fl);
 out = fopen(fl, "wb");
 if (!out) {
  sprintf(lastVogError, "�� ���� ������� ���� %s", fl);
  return KRT_ERR; 
 }
 // ...
 fclose(out);

 // ������������ ���������� ��������� ������ � ��������������
 // �������� ������� �������� ������ ����������� ������ � ���������, 
 // �� ����� �� ������������ ������ ������� ���������� ������

 // �����, ���� �� ���������� �����.������� -> ��������������� ������
 if (!informUser) return KRT_OK;

 for (i = 0; i <= 100; i++) {
  sprintf (buf, "%s proccessing %d", primFile, i);
  if (informUser( (short) i, buf)) {
   sprintf (lastVogError, "�������� �������������.");
   return KRT_ERR;
  }
  Sleep(100);
 }

 return KRT_OK;
}
