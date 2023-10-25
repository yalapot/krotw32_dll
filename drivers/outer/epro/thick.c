#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <io.h>
#include <fcntl.h>
#include <sys/stat.h>

#include "thick.h"
extern char drvError[];

/////////////////////////////////////////////////////////////
int initThick(const char *fname, long length, T_THICK *thick) {
unsigned long sz;
int fl;

 // сохраняем переданные данные
 strcpy(thick->fname, fname); 
 thick->length = length;

 // выделяем буфер
 sz = length * sizeof(long);
 thick->data = (long *) calloc(length, sizeof(long));
 if (thick->data == NULL) {
  sprintf(drvError, "не достаточно памяти для буфера толщины: %ld байт (initThick)", sz);
  return 1;
 }

 // считываем в буфер данные из файла
 fl = _open(fname, _O_BINARY | _O_CREAT | _O_RANDOM | _O_RDWR, _S_IREAD | _S_IWRITE);
 if (fl == -1) {
  sprintf(drvError, "не могу открыть файл индекса толщины %s (initThick)", fname);
  return 1;
 }
 _lseek(fl, 0, SEEK_SET);
 _read(fl, thick->data, sz);
 thick->isChanged = 0;
 _close(fl);

 return 0;
}

/////////////////////////////////////////////////////////////
int freeThick(T_THICK *thick) {
unsigned long sz;
int fl;

 if (thick->isChanged == 0) {
  free(thick->data);
  return 0;
 }

 fl = _open(thick->fname, _O_BINARY | _O_CREAT | _O_RANDOM | _O_RDWR, _S_IREAD | _S_IWRITE);
 if (fl == -1) {
  sprintf(drvError, "не могу открыть файл индекса толщины %s (freeThick)", thick->fname);
  return 1;
 }

 // изменяем размер файла под виртуальную длину записи
 sz = thick->length * sizeof(long);
 if (_chsize(fl, sz) == -1) {
  _close(fl);
  sprintf(drvError, "не могу изменить размер файла индекса толщины %s на %ld байт(freeThick)", thick->fname, sz);
  return 1;
 }
 _lseek(fl, 0, SEEK_SET);
 _write(fl, thick->data, sz);
 _close(fl);
 free(thick->data);

 return 0;
}
