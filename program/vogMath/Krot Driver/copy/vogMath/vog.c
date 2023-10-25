//////////////////////////////////////////////////////////////////////////
// модуль создания индексных файлов по первичным навигационным данным 
// при регистрации записи (C) 2006 by Vitaly Bogomolov, Alexander Nikonov

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "winkrt.h"
#include "fileTool.h"
#include "iniTool.h"
#include "vogTrc.h"
#include "vogMath.h"

///////////////////////////////////////////////////////
// сообщение о последней произошедшей ошибке
char lastVogError[4048];

///////////////////////////////////////////////////////
// Функция заполняет строку outString описанием последней ошибки произошедшей
// при работе с записями прогонов. Возвращает длину строки сообщения об ошибке.
long EXPORT KRTAPI vogError (char * outString) {
 strcpy(outString, lastVogError);
 return strlen(lastVogError);
}

///////////////////////////////////////////////////////
// Функция ищет в каталоге, где расположен primFile файлы первичных навигационных данных.
// если находит, то создает индексные файлы навигационных данных в каталоге indxFolder.
// после этого записывает пути на созданные файлы в trc-файл trcFile,
// в места, определенные в файле vogTrc.h
// в процессе работы вызывает функцию informUser, оповещая пользователя о ходе работы.
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

 // сконструировать полное имя первого индексного файла  
 sprintf(buf, "%s\\%s", indxFolder, VOG_FILE_FIELD);

 // если этот файл находиться в том же каталоге, что и trc-файл
 // использовать короткую форму записи, без полных путей
 // для обеспечения переноса каталогов между дисками и каталогами.
 fl = (isSamePlace(buf, trcFile) ? VOG_FILE_FIELD : buf);
 setIniItem(trcFile, VOG_DATA, VOG_DATA_FIELD, fl);

 // между созданием и закрытием индексного файла должен быть код,
 // заполняющий создаваемый файл данными.
 out = fopen(fl, "wb");
 if (!out) {
  sprintf(lastVogError, "не могу создать файл %s", fl);
  return KRT_ERR; 
 }
 // ... вот здесь
 fclose(out);


 // аналогичные процедуры для второго индексного файла
 sprintf(buf, "%s\\%s", indxFolder, VOG_FILE_COORD);
 fl = (isSamePlace(buf, trcFile) ? VOG_FILE_COORD : buf);
 setIniItem(trcFile, VOG_DATA, VOG_DATA_COORD, fl);
 out = fopen(fl, "wb");
 if (!out) {
  sprintf(lastVogError, "не могу создать файл %s", fl);
  return KRT_ERR; 
 }
 // ...
 fclose(out);

 // демонстрация длительной обработки данных с периодическими
 // вызовами функции передачи обьема проделанной работы и проверкой, 
 // не нажал ли пользователь кнопку команды прерывания работы

 // выйти, если не определена польз.функция -> демонстрировать нечего
 if (!informUser) return KRT_OK;

 for (i = 0; i <= 100; i++) {
  sprintf (buf, "%s proccessing %d", primFile, i);
  if (informUser( (short) i, buf)) {
   sprintf (lastVogError, "Отменено пользователем.");
   return KRT_ERR;
  }
  Sleep(100);
 }

 return KRT_OK;
}
