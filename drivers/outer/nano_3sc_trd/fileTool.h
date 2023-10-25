// ������ �������� � ������� ������
// (C) 2006 by Vitaly Bogomolov

#pragma warning(disable : 4996) // for VC 8.00


// ������� �������� � driveDir ����� ������� ���� fullPath 
// ��� ����� � ���������� ����� � ��� ������������ �����
extern void getDriveDir(const char * fullPath, char *driveDir);

// ������� ���������� 1 ���� ���� file ��������� � �������� dir.
int isFileInDir(const char *file, const char *dir);

// ������� ���������� 1 ���� ����� f1 � f2, �������� ������� �������,
// ��������� � ����� ��������.
extern int isSamePlace(const char *f1, const char *f2);

// ������� ��������� ������������� �����
extern int isFileExist(const char *fName);

// ������� ��������� ������������� ��������
extern int isFolderExist(const char *fName);

// ������� ������� ������ ��� ����� � ������ fullName 
// �� ������� ����� �������� drivePath �
// ����� ����� fileNAme.
// drivePath ����� ���� � ����������� ������, � ����� ���� � ��� ����
// ���� drivePath ����� NULL, �� �������������� ��� ���� �������� 
// ��� ���������� � ������ fullName � ��������� ���� ��� ����� fileNAme 
extern char * makeFullPath( 
char * fullName, 
const char *drivePath, 
const char *fileNAme
);
