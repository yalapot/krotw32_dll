#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <krtapi.h>
#include "common.h"

static int initFlag=0;
static char drvError[1024];
static COMMON_TRACE traces[MAX_TRACE];
static char sens_name[EXT_SENS_NAME_LENGTH];

char LogString[1024];          // строка для записи в лог
/*
Функция записи в лог
*/
void Log(void) {
FILE *l;

 l = fopen(LOG_FILE, "at");
 fprintf(l, "DRV %s\n", LogString);
// fflush(l);
 fclose(l);
}

/**************************************************************************
Функция инициализации сегмента данных драйвера */
void initTraces(void) {
int i; 

 for (i=0; i<MAX_TRACE; i++) traces[i].handle = -1;
}

/**************************************************************************
Функция регистрирует новый дескриптор прогона в сегменте данных драйвера 
Возвращает индекс структуры данных прогона в массиве traces. Структура
с этим индексом в дальнейшем используется драйвером для хранения информации
по прогону, адресуемому дескриптором handle. 
Если все структуры массива traces заняты данными открытых прогонов, возвращает
-1 и выводит в строку drvError сообщение об ошибке.
*/
int newTrace(KRTHANDLE handle) {
int i; 

 for (i=0; i < MAX_TRACE; i++) 
  if (traces[i].handle == -1) {
   traces[i].handle = handle;
   return i;
  }
 
 sprintf (
  drvError, 
  "Слишком много открытых прогонов.\nМаксимальное количество %d", 
  MAX_TRACE
 );
 return -1;
}

/**************************************************************************
Функция ищет в массива traces прогон с дескриптором handle. 
Возвращает индекс найденной структуры прогона в этом массиве.
Если структура с заданным дескриптором не найдена, возвращает -1 и выводит в
строку drvError сообщение об ошибке.
*/
int Trace(KRTHANDLE handle) {
int i; 

 for (i=0; i<MAX_TRACE; i++) 
  if (traces[i].handle == handle) return i;

 sprintf(drvError, "Неизвестный дескриптор прогона %d", handle);
 return -1;
}

/**************************************************************************
Функция освобождает структуру прогона заданного дескриптором handle в массиве
traces для дальнейшего использования.
*/
void freeTrace(KRTHANDLE handle) {
int i; 

 i = Trace(handle);
 if (i >= 0) {
  traces[i].handle = -1;
 }
}

/**********************************************/
const char * KRTAPI krtDrvError (void) {
 return drvError;
}

KRTDATA getVal (long y, long x) {
 return (KRTDATA) ((y % 16 + x) % 16);
// return (KRTDATA) y;
}

long getValRow (long y, long x) {
 return (long) ((y % 16 + x) % 1024);
}

/**********************************************/
long KRTAPI krtDrvFillData (
 KRTHANDLE handle, 
 long group, 
 long start, 
 long length, 
 KRTDATA *screen, 
 long *rowData) {

int i, j;
long arrLength;

 (void) group;

#ifdef LOGGED
 sprintf(
  LogString, 
  "krtDrvFillData"
  "(handle, group, start, length, &screen)\n"
  "%ld, %ld, %ld, %ld, ##",
  handle, group, start, length
 );
 Log();
#endif

 i = Trace(handle);
 if (i < 0) return KRT_ERR;
 arrLength = length; 

 switch (group) {

  case 0: {
   for (i=0; i<COMMON_SENSORNUM; i++) {
    for (j=0; j<arrLength; j++) {
     screen[arrLength*i+j] = getVal(i, start + j);
     rowData[arrLength*i+j] = getValRow(i, start + j);
    }
   }
   break;
  }

  case 1: {
   for (i=0; i<(COMMON_SENSORNUM / 2); i++) {
    for (j=0; j<arrLength; j++) {
     screen[arrLength*i+j] = getVal((COMMON_SENSORNUM / 2) - i, start + j);
     rowData[arrLength*i+j] = getValRow((COMMON_SENSORNUM / 2) - i, start + j);
    }
   }
   break;
  }

 }
 return KRT_OK;
}

/**********************************************/
long EXPORT KRTAPI krtOpenTrace ( 
 const char * traceFile, 
 KRTHANDLE handle, 
 T_TRACEINFO *inf, 
 long draft
) {

int i, recType, indx;
char recordTypeName[256];

#ifdef LOGGED
 sprintf(
  LogString, 
  "krtOpenTrace"
  "(traceFile, handle, &inf, draft)\n"
  "%s, %ld, ##, %ld",
  traceFile, handle, draft
 );
 Log();
#endif

 // функция сообщений об ошибке нужно передать первой, 
 // чтобы драйвер мог сообщать об ошибках при открытии прогона
 inf->krtDrvError    = krtDrvError;

 // проверяем валидность имени trc-файла
 if (strlen(traceFile) > MAX_TRC_NAME) {
  sprintf(drvError, "Слишком длинное имя файла прогона");
  return KRT_ERR;
 }
 // выясняем тип записи из заданного trc-файла
 GetPrivateProfileString (
  DRIVER_DATA,             // секция trc-файла
  REC_TYPE_ITEM,           // имя параметра
  REC_TYPE_STR_VOGCOR,     // значение по умолчанию
  recordTypeName,          // буфер для считываемого значения
  sizeof(recordTypeName),  // размер буфера
  traceFile);              // имя trc-файла

 if (!strcmpi(REC_TYPE_STR_CORONLY, recordTypeName)) {
  recType = REC_CORONLY;
 } else
 if (!strcmpi(REC_TYPE_STR_VOGONLY, recordTypeName)) {
  recType = REC_VOGONLY;
 } else {
  recType = REC_VOGCOR; // значение по умолчанию
 }

 // если это первый вызов, то заполняем первые два поля структуры и выходим
 if (draft) {

  // сначала заполним одинаковую для всех типов записи информацию
  inf->extSensors = ESENS_NUM;  // дополнительные датчики

  // а теперь заполним поля которые отличаются для разных типов записи
  switch (recType) {
    case REC_CORONLY: {   // только корозионная запись
     inf->sensGroups = 2; // два пояса датчиков корозионной развертки
     break;
    }
    case REC_VOGONLY: {   // только навигационная запись 
     inf->sensGroups = 0; // нет датчиков корозионной развертки
     break;
    }
    default: {            // совмещенная навигационно-корозионная запись 
     inf->sensGroups = 2; // два пояса датчиков корозионной развертки
     break;
    }
  } 

  return KRT_OK;
 }

 // второй вызов - передаем полную информацию о записи
 i = newTrace(handle);
 if (i < 0) return KRT_ERR;
 traces[i].recType = recType;

 // сначала заполним одинаковую для всех типов записи информацию
 inf->askMetod = SENS_ASK_DIST;
 inf->stepSize = COMMON_STEP;

 for (indx=0; indx<ESENS_NUM; indx++) {
   inf->extSens[indx].minValue = 0;
   inf->extSens[indx].maxValue = 1000;
   sprintf (sens_name, "Дополнительный датчик %d", indx+1);
   strncpy (inf->extSens[indx].name, sens_name, EXT_SENS_NAME_LENGTH);
 }

 inf->wallThickNum = 4;
 inf->wallThickMin = -4095;
 inf->wallThickMax = 4095;

 inf->odoNum = 3;
 inf->odoStep = 1;

 inf->orientNum = 3;
 inf->orientStep = 2560;

 inf->timerNum = 1;
 inf->timerStep = 1000;

 inf->pressNum = 3;
 inf->pressStep = 1000;
                
 inf->tempNum = 4;
 inf->tempStep = 1000;

 inf->krtDrvError    = krtDrvError;
 inf->krtDrvFillData = krtDrvFillData;
 inf->krtDrvGetFirstNode = krotGetFirstNode;
 inf->krtDrvGetNextNode = krotGetNextNode;
 inf->krtDrvGetFirstNodeGroup = krotGetFirstNodeGroup;
 inf->krtDrvGetNextNodeGroup = krotGetNextNodeGroup;

 // а теперь заполним поля которые отличаются для разных типов записи
 switch (recType) {

   case REC_CORONLY: { // только корозионная запись
    inf->group[0].num = COMMON_SENSORNUM;
    inf->group[0].type = SENS_TYPE_FERR;
    inf->group[0].minValue = 0;
    inf->group[0].maxValue = 15;
    inf->group[0].isRow = 1L;
    inf->group[0].maxRowVal = 4095;
    inf->group[0].minRowVal = -4095;

    inf->group[1].num = COMMON_SENSORNUM / 2;
    inf->group[1].type = SENS_TYPE_FERR;
    inf->group[1].minValue = 0;
    inf->group[1].maxValue = 15;
    inf->group[1].isRow = 1L;
    inf->group[1].maxRowVal = 4095;
    inf->group[1].minRowVal = -4095;

    inf->vog = 0L;
    break;
   }

   case REC_VOGONLY: { // только навигационная запись 
    inf->vog = 1L;
    break;
   }

   default: {          // совмещенная навигационно-корозионная запись 
    inf->group[0].num = COMMON_SENSORNUM;
    inf->group[0].type = SENS_TYPE_FERR;
    inf->group[0].minValue = 0;
    inf->group[0].maxValue = 15;
    inf->group[0].isRow = 1L;
    inf->group[0].maxRowVal = 4095;
    inf->group[0].minRowVal = -4095;

    inf->group[1].num = COMMON_SENSORNUM / 2;
    inf->group[1].type = SENS_TYPE_FERR;
    inf->group[1].minValue = 0;
    inf->group[1].maxValue = 15;
    inf->group[1].isRow = 1L;
    inf->group[1].maxRowVal = 4095;
    inf->group[1].minRowVal = -4095;

    inf->vog = 1L;
    break;
   }
 } 
 // те поля, которые мы не заполняли содержат нулевые значения

 // теперь статистическая информация о записи
 inf->length = TRACE_LENGTH;
 inf->time = TRACE_LENGTH;
 inf->speedMin = 0;
 inf->speedMax = 100;

 inf->pressMin = ESENSVAL_MIN;
 inf->pressMax = ESENSVAL_MAX;
 inf->tempMin  = ESENSVAL_MIN;
 inf->tempMax  = ESENSVAL_MAX;
 inf->shakeMin = ESENSVAL_MIN;
 inf->shakeMax = ESENSVAL_MAX;
 inf->angleMin = ESENSVAL_MIN;
 inf->angleMax = ESENSVAL_MAX;

 strcpy(traces[i].traceFile, traceFile);
 return KRT_OK;
}

/**********************************************/
long EXPORT KRTAPI krtCloseTrace(KRTHANDLE handle) {

#ifdef LOGGED
 sprintf(
  LogString, 
  "krtCloseTrace"
  "(handle)\n"
  "%ld",
  handle
 );
 Log();
#endif

 freeTrace(handle);
 return KRT_OK;
}

/**********************************************/
long KRTAPI krotGetFirstNode (
 KRTHANDLE Handle,      // дескриптор прогона
 T_NODE *node,          // указатель на структуру T_NODE
 long start,            // позиция на трассе
 long sensType,         // тип датчика
 long sensIndex,        // индекс датчика (-1L - базовый)
 long length,           // длина участка для следующих вызовов krotGetNextNode
 long controlSize       // размер контрола отрисовки в пикселах.
) {
int i;

 (void) controlSize;
 (void) length;

 i = Trace(Handle);
 if (i < 0) return KRT_ERR;
 traces[i].sensType    = sensType;  
 traces[i].sensIndex   = sensIndex;

 switch (sensType) {

  case KRT_SENS_ORIENT: 
   node->Val = ((start / COMMON_STEP) + 5 * (sensIndex + 1)) % COMMON_SENSORNUM;
   node->Pos = start;
   break;

  case KRT_SENS_AZIMUTH: case KRT_SENS_TANGAZH:
   if (traces[i].recType == REC_CORONLY) {
    sprintf(drvError, "В записи отсутствуют данные VOG");
    return KRT_ERR;
   }
  case KRT_SENS_TEMP: case KRT_SENS_SHAKE: case KRT_SENS_THICK:
  case KRT_SENS_PRESS: case KRT_SENS_ANGLE: case KRT_SENS_EXT:
   node->Val = (start + 5 * (sensIndex + 1)) % ESENSVAL_MAX;
   node->Pos = start;
   break;

  // показания таймера записываются 1 раз в 5 метров
  // снаряд движется с постоянной скоростью 8 м/с
  // показания каждого таймера "впереди" от предыдущего на 1 сек.
  case KRT_SENS_TIMER: 
   start /= 5000;
   node->Pos = start * 5000;
   node->Val = start * 625;
   // поправка на "убегание"
   node->Val += (sensIndex < 0) ? 0 : (1000 * sensIndex);
   break;

  case KRT_SENS_ODO: 
   node->Val = start;
   node->Pos = start;
   break;

  case KRT_SENS_VOG:
   sprintf(drvError, "Запрос данных этого типа датчиков пока не реализован");
   return KRT_ERR;

  default:
   sprintf(drvError, "Запрошен неизвестный тип датчиков");
   return KRT_ERR;

 }

 traces[i].lastNodePos = node->Pos;
 return KRT_OK;
}

/**********************************************/
long KRTAPI krotGetNextNode (
 KRTHANDLE Handle,
 T_NODE *node
) {
int i;

 i = Trace(Handle);
 if (i < 0) return KRT_ERR;

 switch (traces[i].sensType) {

  case KRT_SENS_AZIMUTH: case KRT_SENS_TANGAZH:
   if (traces[i].recType == REC_CORONLY) {
    sprintf(drvError, "В записи отсутствуют данные VOG");
    return KRT_ERR;
   }
  case KRT_SENS_TEMP: case KRT_SENS_SHAKE: case KRT_SENS_THICK:
  case KRT_SENS_PRESS: case KRT_SENS_ANGLE: case KRT_SENS_EXT: case KRT_SENS_ORIENT:
   node->Val = (traces[i].lastNodePos + 5 * (traces[i].sensIndex + 1)) % ESENSVAL_MAX;
   node->Pos = traces[i].lastNodePos + COMMON_STEP;
   break;

  // показания таймера записываются 1 раз в 5 метров
  // снаряд движется с постоянной скоростью 8 м/с
  // показания каждого таймера "впереди" от предыдущего на 1 сек.
  case KRT_SENS_TIMER: 
   node->Pos = traces[i].lastNodePos + 5000;
   node->Val = (node->Pos / 5000) * 625;
   // поправка на "убегание"
   node->Val += (traces[i].sensIndex < 0) ? 0 : (1000 * traces[i].sensIndex);
   break;

  case KRT_SENS_ODO: 
   node->Val = traces[i].lastNodePos + 5 * (traces[i].sensIndex + 1);
   node->Pos = traces[i].lastNodePos + COMMON_STEP;
   break;

  case KRT_SENS_VOG: 
   sprintf(drvError, "Запрос данных этого типа датчиков пока не реализован");
   return KRT_ERR;

  default:
   sprintf(drvError, "Запрошен неизвестный тип датчиков");
   return KRT_ERR;

 }

 traces[i].lastNodePos = node->Pos;
 return KRT_OK;
}

/**********************************************/
long KRTAPI krotGetFirstNodeGroup (
 KRTHANDLE Handle,      // дескриптор прогона
 T_NODEGROUP *node,     // указатель на структуру T_NODE
 long start,            // позиция на трассе
 long sensGroup,        // маска группы датчиков
 long length,           // длина участка для следующих вызовов krotGetNextNodeGroup
 long controlSize       // размер контрола отрисовки в пикселах.
) {
int i;

 (void) controlSize;
 (void) length;

#ifdef LOGGED
 sprintf(
  LogString, 
  "krotGetFirstNodeGroup"
  "(Handle, &node, start, sensGroup, length, controlSize)\n"
  "%ld, ##, %ld, %ld, %ld, %ld",
  Handle, start, sensGroup, length, controlSize
 );
 Log();
#endif

 i = Trace(Handle);
 if (i < 0) return KRT_ERR;

 traces[i].sensMask = sensGroup;

 if (sensGroup & KRT_SENS_ORIENT) {
  node->orientPos = start;
  node->orientVal = (start / COMMON_STEP) % COMMON_SENSORNUM;
 }

 if (sensGroup & KRT_SENS_TEMP) {
  node->tempPos = start;
  node->tempVal = (start / COMMON_STEP) % ESENSVAL_MAX;
 }
 if (sensGroup & KRT_SENS_SHAKE) {
  node->shakePos = start;
  node->shakeVal = (start / COMMON_STEP) % ESENSVAL_MAX;
 }
 if (sensGroup & KRT_SENS_PRESS) {
  node->pressPos = start;
  node->pressVal = (start / COMMON_STEP) % ESENSVAL_MAX;
 }
 if (sensGroup & KRT_SENS_ANGLE) {
  node->anglePos = start;
  node->angleVal = (start / COMMON_STEP) % ESENSVAL_MAX;
 }
 if (sensGroup & KRT_SENS_THICK) {
  node->thickPos = start;
  node->thickVal = (start / COMMON_STEP) % ESENSVAL_MAX;
 }

 if (sensGroup & KRT_SENS_VOG) {
  node->vogPos = start;
  node->vogx = start;
  node->vogy = (long) (5000.0 * sin((double) ((float) start / 1000.0)));
  node->vogz = (long) (5000.0 * cos((double) ((float) start / 1000.0)));
  node->vogext1 = 0.0;
  node->vogext2 = 0.0;
  node->vogext3 = 0.0;
 }

 if (sensGroup & KRT_SENS_TIMER) {
   node->timerPos = start;
   node->timerVal = (start / 4);
 }
 if (sensGroup & KRT_SENS_ODO) {
  node->odoPos = start;
  node->odoVal = start;
 }

 return KRT_OK;
}

/**********************************************/
long KRTAPI krotGetNextNodeGroup (
 KRTHANDLE Handle,
 T_NODEGROUP *node
) {
int i;
long sensGroup, start;

#ifdef LOGGED
 sprintf(
  LogString, 
  "krotGetNextNodeGroup"
  "(Handle, &node)\n"
  "%ld, ##",
  Handle
 );
 Log();
#endif

 i = Trace(Handle);
 if (i < 0) return KRT_ERR;

 sensGroup = traces[i].sensMask;

 if (sensGroup & KRT_SENS_ORIENT) {
  node->orientPos += (10 * COMMON_STEP);
  if (node->orientPos > TRACE_LENGTH) {
   node->orientPos = TRACE_LENGTH;
   node->orientVal = 0L;
  } else {
   node->orientVal = (node->orientPos / (10 * COMMON_STEP)) % COMMON_SENSORNUM;
  }
 }

 if (sensGroup & KRT_SENS_TEMP) {
  node->tempPos += (10*COMMON_STEP);
  if (node->tempPos > TRACE_LENGTH) {
   node->tempPos = TRACE_LENGTH;
   node->tempVal = 0L;
  } else {
   node->tempVal = (node->tempPos / (10 * COMMON_STEP)) % 100;
  }
 }

 if (sensGroup & KRT_SENS_SHAKE) {
  node->shakePos += (10*COMMON_STEP);
  if (node->shakePos > TRACE_LENGTH) {
   node->shakePos = TRACE_LENGTH;
   node->shakeVal = 0L;
  } else {
   node->shakeVal = (node->shakePos / (10 * COMMON_STEP)) % 100;
  }
 }
 if (sensGroup & KRT_SENS_PRESS) {
  node->pressPos += (10*COMMON_STEP);
  if (node->pressPos > TRACE_LENGTH) {
   node->pressPos = TRACE_LENGTH;
   node->pressVal = 0L;
  } else {
   node->pressVal = (node->pressPos / (10 * COMMON_STEP)) % 100;
  }
 }
 if (sensGroup & KRT_SENS_ANGLE) {
  node->anglePos += (10*COMMON_STEP);
  if (node->anglePos > TRACE_LENGTH) {
   node->anglePos = TRACE_LENGTH;
   node->angleVal = 0L;
  } else {
   node->angleVal = (node->anglePos / (10 * COMMON_STEP)) % 100;
  }
 }
 if (sensGroup & KRT_SENS_THICK) {
  node->thickPos += (10*COMMON_STEP);
  if (node->thickPos > TRACE_LENGTH) {
   node->thickPos = TRACE_LENGTH;
   node->thickVal = 0L;
  } else {
   node->thickVal = (node->thickPos / (10 * COMMON_STEP)) % 100;
  }
 }

 if (sensGroup & KRT_SENS_TIMER) {
  node->timerPos += (10*COMMON_STEP);
  if (node->timerPos > TRACE_LENGTH) {
   node->timerPos = TRACE_LENGTH;
   node->timerVal = 0L;
  } else {
   node->timerVal = (node->timerPos / 4);
  }
 }

 if (sensGroup & KRT_SENS_ODO) {
  node->odoPos += (10*COMMON_STEP);
  if (node->odoPos > TRACE_LENGTH) {
   node->odoPos = TRACE_LENGTH;
   node->odoVal = 0L;
  } else {
   node->odoVal = node->odoPos;
  }
 }


 if (sensGroup & KRT_SENS_VOG) {
  node->vogPos += 100;
  start = node->vogPos;
  if (start > TRACE_LENGTH) {
   node->vogPos = TRACE_LENGTH;
   node->vogx = 0L;
   node->vogy = 0L;
   node->vogz = 0L;
   node->vogext1 = 0.0;
   node->vogext2 = 0.0;
   node->vogext3 = 0.0;
  } else {
   node->vogx = start;
   node->vogy = (long) (5000.0 * sin((double) ((float) start / 1000.0)));
   node->vogz = (long) (5000.0 * cos((double) ((float) start / 1000.0)));
   node->vogext1 = 0.0;
   node->vogext2 = 0.0;
   node->vogext3 = 0.0;
  }
 }

 return KRT_OK;
}

/* функция регистации записи */
long KRTAPI krtDrvRegister (
 const char * datFile, 
 const char * trcFile, 
 char **errText, 
 long (KRTAPI *userBreak) (short percentDone)
 ) {

char *typ;
short i;

 // демонстрация возврата ошибки:
 // если аргумент datFile == "FUCK", то считать это за ошибку
 if (!strcmpi(datFile, "FUCK")) {

  sprintf (
   drvError, 
   "Не фига!!!" 
  );
  *errText = &(drvError[0]);
  return KRT_ERR;

 } else if (!strcmpi(datFile, REC_TYPE_STR_CORONLY)) {
  typ = REC_TYPE_STR_CORONLY; // если аргумент datFile == REC_TYPE_STR_CORONLY, 
                              // установить тип записи "только корозионник"
 } else if (!strcmpi(datFile, REC_TYPE_STR_VOGONLY)) {
  typ = REC_TYPE_STR_VOGONLY; // если аргумент datFile == REC_TYPE_STR_VOGONLY, 
                              // установить тип записи "только вог"
 } else {
  typ = REC_TYPE_STR_VOGCOR;  // в любом другом случае установить тип записи
                              // "совмещенный вог-корозионник"
 }

 // демонстрация длительной обработки данных с периодическими
 // вызовами функции передачи обьема проделанной работы и проверкой, 
 // не нажал ли пользователь кнопку команды прерывания работы
 for (i=0; i<=100; i++) {
  if (userBreak(i)) {
   sprintf (
    drvError, 
    "Отменено пользователем." 
   );
   *errText = &(drvError[0]);
   return KRT_ERR;
  }
  Sleep(100);
 }

 // запись необходимой информации в заданный trc-файл
 WritePrivateProfileString(DRIVER_DATA, REC_TYPE_ITEM, typ, trcFile);
 return KRT_OK;
}

/**********************************************/
long EXPORT KRTAPI krtDriverInfo(T_DRVINFO *drv) {

#ifdef LOGGED
 sprintf(
  LogString, 
  "krtDriverInfo"
 );
 Log();
#endif

 if (initFlag == 0) {
  initTraces();
  initFlag = 1;
 }

 drv->apiVer         = KRT_APIVER;
 drv->krtDrvRegister = krtDrvRegister;
// drv->krtDrvRegister = NULL;
 return KRT_OK;
}