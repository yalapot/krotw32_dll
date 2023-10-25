#include <string.h>
#include <stdio.h>
#include <io.h>
#include "fileTool.h"

// ������� �������� � driveDir ����� ������� ���� fullPath 
// ��� ����� � ���������� ����� � ��� ������������ �����
void getDriveDir(const char * fullPath, char *driveDir) {
 char buf[1024];
 char *pt;

 strcpy(buf, fullPath);
 pt = strrchr(buf, '\\');

 if (pt) {
  *pt = 0;
  strcpy(driveDir, buf);
 } else {
  *driveDir = 0;
 }
}

// ������� ���������� 1 ���� ���� file ��������� � �������� dir.
int isFileInDir(const char *file, const char *dir) {
 char b1[1024];

 getDriveDir(file, b1);

 return (strcmp(b1, dir) == 0);
}

// ������� ���������� 1 ���� ����� f1 � f2, �������� ������� �������,
// ��������� � ����� ��������.
int isSamePlace(const char *f1, const char *f2) {
 char b1[1024], b2[1024];

 getDriveDir(f1, b1);
 getDriveDir(f2, b2);

 return (strcmp(b1, b2) == 0);
}

// ������� ��������� ������������� �����
int isFileExist(const char *fName) {
 FILE *f;

 f = fopen(fName, "r");
 if (f) {
  fclose(f);
  return 1;
 }

 return 0;
}

// ������� ��������� ������������� ��������
int isFolderExist(const char *fName) {
struct _finddata_t c_file;
long hFile;
char buf[1024];
char *sym;

 strcpy(buf, fName);
 // �������� ���������� ����, ���� ����
 sym = & buf[strlen(buf)-1]; 
 if (*sym == '\\') { *sym = 0; }

 hFile = _findfirst( buf, &c_file );
 if (hFile == -1L) return 0;

 _findclose( hFile );
 return 1;
}

// ������� ������� ������ ��� ����� � ������ fullName 
// �� ������� ����� �������� drivePath �
// ����� ����� fileNAme.
// drivePath ����� ���� � ����������� ������, � ����� ���� � ��� ����
// ���� drivePath ����� NULL, �� �������������� ��� ���� �������� 
// ��� ���������� � ������ fullName � ��������� ���� ��� ����� fileNAme 
char * makeFullPath( 
char * fullName, 
const char *drivePath, 
const char *fileNAme
) {
char *sym;

 if (drivePath) {
  strcpy(fullName, drivePath);
 }

 // ���������, ���� �� ���������� ����
 // � ��������� ���� ���.
 sym = & fullName[strlen(fullName)-1]; 
 if (sym[0] != '\\') { 
  sym[1] = '\\'; 
  sym[2] = 0; 
 }

 strcat(fullName, fileNAme);
 return fullName;
}
