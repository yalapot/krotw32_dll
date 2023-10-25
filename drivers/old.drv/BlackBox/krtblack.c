// Krot384e.c - компонет драйвера 384e_drv (и 384e_reg).
// Объявление глобальных данных и тела инструментальных функций драйвера
// просмотра данных електронного блока "384 epro" программой KrotW32
//

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <KrtAPI.h>
#include "krtblack.h"

//////////////////////////////////////////////////////////////////////////
// Глобальные данные драйвера
//////////////////////////////////////////////////////////////////////////

char drvError[256];

T_TRACE_LIST trace_list[MAX_TRACE];
char *traceFile;

int open_trace_counter;

//////////////////////////////////////////////////////////////////////////
// Закончились глобальные данные драйвера
//////////////////////////////////////////////////////////////////////////

/* Функция инициализации сегмента данных драйвера */
void WINAPI initTraces(void) {
  open_trace_counter=0;
  strcpy(drvError, "");
 };

/* Функция для вывода отладочных сообщений */
void debugPoint(char *msg) {
 MessageBox (
  NULL,
  msg,
  "krotDebug",
  (MB_APPLMODAL|MB_ICONINFORMATION|MB_OK)
 );
}



