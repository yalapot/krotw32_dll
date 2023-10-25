// модуль операций с именами файлов
// (C) 2006 by Vitaly Bogomolov

#pragma warning(disable : 4996) // for VC 8.00


// функция копирует в driveDir часть полного пути fullPath 
// без имени и расширения файла и без завершающего слеша
extern void getDriveDir(const char * fullPath, char *driveDir);

// функция возвращает 1 если файл file находится в каталоге dir.
int isFileInDir(const char *file, const char *dir);

// функция возвращает 1 если файлы f1 и f2, заданные полными именами,
// находятся в одном каталоге.
extern int isSamePlace(const char *f1, const char *f2);

// функция проверяет существование файла
extern int isFileExist(const char *fName);

// функция проверяет существование каталога
extern int isFolderExist(const char *fName);

// функция создает полное имя файла в буфере fullName 
// из полного имени каталога drivePath и
// имени файла fileNAme.
// drivePath может быть с завершающим слешем, а может быть и без него
// если drivePath равен NULL, то предполагается что путь каталога 
// уже находиться в буфере fullName и добавляет туда имя файла fileNAme 
extern char * makeFullPath( 
char * fullName, 
const char *drivePath, 
const char *fileNAme
);
