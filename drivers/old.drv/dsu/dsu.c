#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <krtapi.h>
#include "dsu.h"

#define MAX_TRACE 3
#define MAX_TRC_NAME 1024

static int initFlag=0;
static char drvError[1024];
static T_KROT_TRACE traces[MAX_TRACE];

static char str[256];
static char drive[MAXDRIVE];
static char dir[MAXDIR];
static char file[MAXFILE];
static char ext[MAXEXT];
static char dest[MAXPATH];


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

long switchVal (long val) {return ((val == 15) ? 0L : ++val);}

/**********************************************/
int KRTAPI krtDrvFillData (
 KRTHANDLE handle, 
 long group, 
 long start, 
 long length, 
 KRTDATA *screen, 
 long *rowData
) {

T_ITEM item;
T_INDX indx;
T_WELD weld;
T_STOP tmp;
int addr, b_addr;
short i, notFound;
long segmNum;
long border;
byte firstShift;
long strnum;
short ctop,strnum1;
static T_KROT_TRACE *trc;

  (void) rowData;

  i = Trace(handle);
  if (i < 0) return KRT_ERR;

  trc=&(traces[i]);
 
  // находим в файле первый сегмент данных, попадающих в этот экран
  segmNum = start / SEGM_LEN;
  fseek(trc->indx, sizeof(T_INDX) * segmNum, SEEK_SET);
  fread(&indx, sizeof(T_INDX), 1, trc->indx);
  // здесь всавить бы проверочку на indx.dist !!!
  fseek(trc->rec, indx.pos, SEEK_SET);

  // ищем внутри этого и следующих сегментов данные попадающие в этот экран
  border = start - indx.dist;
  firstShift = (byte) border;
  i = 0;
  notFound = 1;
  while (notFound) {
    fread(&item, sizeof(T_ITEM), 1, trc->rec);
    if (feof(trc->rec))
      return 0;
    switch (item.sign) {
      case D_DFKT01 :
      case D_DFKT02 :
      case D_DFKT03 :
      case D_DFKT04 :
      case D_DFKT05 :
      case D_DFKT06 :
      case D_DFKT07 :
      case D_DFKT08 :
      case D_DFKT09 :
      case D_DFKT10 :
      case D_DFKT11 :
      case D_DFKT12 :
      case D_DFKT13 :
      case D_DFKT14 :
      case D_DFKT15 :
      case D_DFKT16 :
        if (item.dist >= border)
          notFound = 0;
        break;
      case D_WELD :
        fseek(trc->rec, ftell(trc->rec) - sizeof(T_ITEM), SEEK_SET);
        fread(&weld, sizeof(T_WELD), 1, trc->rec);
        indx.dist = weld.dist;
        ctop = (short) weld.orient;
        border = start - indx.dist;
        i++;
        break;
      case D_STOP:
        break;
      case D_BARDOWN :
      case D_POWERON :
      case D_POWERFAIL :
      case D_DISKFULL :
        fseek(trc->rec, ftell(trc->rec) - sizeof(T_ITEM), SEEK_SET);
        fread(&tmp, sizeof(T_STOP), 1, trc->rec);
        ctop =  (short) tmp.orient;
        break;
    }
  }

  // пишем данные в буфер экрана, идя по файлу до правой границы экрана
  border = start + length - indx.dist;
  notFound = 1;
  while (notFound) {
    switch (item.sign) {
      case D_DFKT01 :
      case D_DFKT02 :
      case D_DFKT03 :
      case D_DFKT04 :
      case D_DFKT05 :
      case D_DFKT06 :
      case D_DFKT07 :
      case D_DFKT08 :
      case D_DFKT09 :
      case D_DFKT10 :
      case D_DFKT11 :
      case D_DFKT12 :
      case D_DFKT13 :
      case D_DFKT14 :
      case D_DFKT15 :
      case D_DFKT16 :
        if (item.dist >= border)
        {
          notFound = 0;
          break;
        }
        b_addr = i * SEGM_LEN - firstShift + item.dist;
        // подстраховка от неверного номера, значения и дистанции датчика
        if
        (
          (item.num >= KROT128_SENSNUM) ||
          (item.val >= KROT128_SENSLEV) ||
          (b_addr < 0)
        )
        {
          break;
        }
        while (item.sign > D_DFKT01) {
          addr = b_addr - item.sign - D_DFKT01;
          if (addr >= 0)
          {
            strnum1 = (((int) item.num) % KROT128_SENSNUM) - (KROT128_SENSNUM - 1);
            strnum = (long) (-strnum1)%KROT128_SENSNUM;
            screen[strnum * length + (long) addr] = (KRTDATA) item.val;
          }
          item.sign--;
        }
        strnum1 = (((int) item.num) % KROT128_SENSNUM) - (KROT128_SENSNUM - 1);
        strnum = (long) (-strnum1)%KROT128_SENSNUM;
        screen[strnum * length + (long) b_addr] = item.val;
        break;
      case D_WELD :
        fseek(trc->rec, ftell(trc->rec) - sizeof(T_ITEM), SEEK_SET);
        fread(&weld, sizeof(T_WELD), 1, trc->rec);
        indx.dist = weld.dist;

        // подстраховка от неверного номера датчика
        if (weld.orient >= KROT128_SENSNUM)
        {
          weld.orient = 0;
        }
        border = start + length - indx.dist;
        i++;
        break;
      case D_STOP:
        break;
      case D_BARDOWN :
      case D_POWERON :
      case D_POWERFAIL :
      case D_DISKFULL :
        fseek(trc->rec, ftell(trc->rec) - sizeof(T_ITEM), SEEK_SET);
        fread(&tmp, sizeof(T_STOP), 1, trc->rec);
        break;
    }
    fread(&item, sizeof(T_ITEM), 1, trc->rec);
    if (feof(trc->rec))
      return 0;
  }
  
  return KRT_OK;
}

/**********************************************/
long EXPORT KRTAPI krtDriverInfo(T_DRVINFO *drv) {

  if (initFlag == 0) {
   initTraces();
   initFlag = 1;
  }
  drv->apiVer = KRT_APIVER;
  drv->krtDrvRegister  = krtDrvRegister;
  return KRT_OK;
}

/**********************************************/
long EXPORT KRTAPI krtOpenTrace ( 
 const LPSTR traceFile, 
 KRTHANDLE handle, 
 T_TRACEINFO *inf,
 long draft) {

T_INDX indx;
T_ITEM item;
long offs;
int i;
static T_KROT_TRACE *trc;

  // функция сообщений об ошибке нужно передать первой, 
  // чтобы драйвер мог сообщать об ошибках при открытии прогона
  inf->krtDrvError    = krtDrvError;

  if (draft) {
      inf->sensGroups = 1;
      inf->extSensors = 0;
      return KRT_OK;
  }

  inf->group[0].num = 128;
  inf->group[0].type = SENS_TYPE_FERR;
  inf->group[0].minValue = 0;
  inf->group[0].maxValue = 15;
  inf->group[0].isRow = 0L;
  inf->group[0].maxRowVal = 0L;
  inf->group[0].minRowVal = 0L;
  inf->askMetod = SENS_ASK_DIST;
  inf->stepSize = 10;

  /* drv->extSens ? */

  inf->wallThickNum = 0;
  inf->wallThickMin = 0;
  inf->wallThickMax = 0;

  inf->odoNum = 1;
  inf->odoStep = 10;

  inf->orientNum = 1;
  inf->orientStep = 2560;

  inf->timerNum=1;
  inf->timerStep=10;
  
  inf->krtDrvFillData  = krtDrvFillData;
  inf->krtDrvGetFirstNode = krotGetFirstNode;
  inf->krtDrvGetNextNode  = krotGetNextNode;
  
  i = newTrace(handle);
  if (i < 0) return KRT_ERR;
  
  trc=&(traces[i]);

  if (GetPrivateProfileString(KRTINF_SECT_REGISTER, KRTINF_ITEM_PRIMARY, "", str, sizeof(str), traceFile) == 0) {
    sprintf (drvError, "Bad trace file: %s", traceFile);
    return KRT_ERR;
  }
  trc->rec = fopen(str, "rb");
  if (trc->rec == NULL) {
    sprintf (drvError, "Can't open %s", str);
    return KRT_ERR;
  }
  _splitpath (str, drive, dir, file, ext);
  _makepath (str, drive, dir, file, INDEX_EXT);
  trc->indx = fopen(str, "rb");
  if (trc->indx == NULL) {
    sprintf (drvError, "Can't open index file %s", str);
    return KRT_ERR;
  }

  fseek(trc->rec, sizeof(T_KROT_HEAD), SEEK_SET);

  fseek(trc->indx, 0L, SEEK_END);
  offs = ftell(trc->indx);
  fseek(trc->indx, ftell(trc->indx) - sizeof(T_INDX), SEEK_SET);
  fread(&indx, sizeof(T_INDX), 1, trc->indx);
  fseek(trc->rec, indx.pos, SEEK_SET);
  offs = 0L;
  while (!feof(trc->rec)) {
    fread(&item, sizeof(T_ITEM), 1, trc->rec);
    switch (item.sign) {
      case D_DFKT01 :
      case D_DFKT02 :
      case D_DFKT03 :
      case D_DFKT04 :
      case D_DFKT05 :
      case D_DFKT06 :
      case D_DFKT07 :
      case D_DFKT08 :
      case D_DFKT09 :
      case D_DFKT10 :
      case D_DFKT11 :
      case D_DFKT12 :
      case D_DFKT13 :
      case D_DFKT14 :
      case D_DFKT15 :
      case D_DFKT16 :
        offs = (long) item.dist;
      default:
        break;
    }
  }
  trc->dist = 10 * (indx.dist + offs);
  trc->node = 0L;
  inf->length=trc->dist;

  inf->speedMin = 0;
  inf->speedMax = 10;
  inf->shakeMin = 0;
  inf->shakeMax = 100;
  inf->pressMin = 0;
  inf->pressMax = 100;
  inf->tempMin = 0;
  inf->tempMax = 100;
  inf->angleMin = 0;
  inf->angleMax = 100;

  /*
   todo Заполнить данные о времени в пути и скорости
  */
  return KRT_OK;

}

/**********************************************/
long EXPORT KRTAPI krtCloseTrace(KRTHANDLE handle) {
int i;

 i = Trace(handle);
 if (i < 0) return KRT_ERR;

 fclose(traces[i].rec);
 fclose(traces[i].indx);
 freeTrace(handle);
 return KRT_OK;
}

/**********************************************/
int KRTAPI krotGetFirstNode (
 KRTHANDLE Handle,      // дескриптор прогона
 T_NODE *node,          // указатель на структуру T_NODE
 long start,            // позиция на трассе в мм
 long sensType,         // тип датчика
 long sensIndex,        // индекс датчика (-1L - базовый)
 long length,           // длина участка для следующих вызовов krotGetNextNode
 long controlSize       // размер контрола отрисовки в пикселах.
) {
int i;
T_INDX indx;
long my_start;

 (void) controlSize;
 (void) length;

 i = Trace(Handle);
 if (i < 0) {
  sprintf(drvError, "Handle <0");
//  MessageBox(NULL,drvError,"Error",MB_OK);
  return KRT_ERR;
 }

 my_start = start / 10;
 traces[i].sensType    = sensType;  
 traces[i].sensIndex   = sensIndex;
 traces[i].node        = my_start / SEGM_LEN;
 traces[i].lastNodePos = traces[i].node * SEGM_LEN;

 fseek(traces[i].indx, sizeof(T_INDX) * traces[i].node, SEEK_SET);
 fread(&indx, sizeof(T_INDX), 1, traces[i].indx);

 switch (sensType) {

  case KRT_SENS_ORIENT: 
   node->Val = indx.top;
   node->Pos = indx.dist * 10;
   return KRT_OK;

  case KRT_SENS_TIMER: 
   node->Val = indx.time * 10;
   node->Pos = indx.dist * 10;
   return KRT_OK;

  case KRT_SENS_ODO:
   node->Pos = start;
   node->Val = node->Pos;
   return KRT_OK;

  case KRT_SENS_SHAKE:
  case KRT_SENS_PRESS: case KRT_SENS_ANGLE: case KRT_SENS_VOG: 
  case KRT_SENS_EXT: case KRT_SENS_TEMP:
   sprintf(drvError, "Запрос данных этого типа датчиков не реализован");
//   MessageBox(NULL,drvError,"Error",MB_OK);
   return KRT_ERR;

  default:
   sprintf(drvError, "Запрошен неизвестный тип датчиков");
//   MessageBox(NULL,drvError,"Error",MB_OK); 
   return KRT_ERR;

 }

 return KRT_OK;
}

/**********************************************/
int KRTAPI krotGetNextNode (
 KRTHANDLE Handle,
 T_NODE *node
) {
int i;
T_INDX indx;

 i = Trace(Handle);
 if (i < 0) {
  sprintf(drvError, "Handle <0");
//  MessageBox(NULL,drvError,"Error",MB_OK);
  return KRT_ERR;
 }

 traces[i].node++;

 fseek(traces[i].indx, sizeof(T_INDX) * traces[i].node, SEEK_SET);
 fread(&indx, sizeof(T_INDX), 1, traces[i].indx);
 if (feof(traces[i].indx)) {
  sprintf(drvError, "Неожиданное окончание индексного файла,%d,%d",traces[i].node,sizeof(T_INDX) * traces[i].node);
//  MessageBox(NULL,drvError,"Error",MB_OK);
  return KRT_ERR;
 }

 switch (traces[i].sensType) {

  case KRT_SENS_ORIENT: 
   node->Val = indx.top;
   node->Pos = indx.dist * 10;
   return KRT_OK;

  case KRT_SENS_TIMER: 
   node->Val = indx.time * 10;
   node->Pos = indx.dist * 10;
   return KRT_OK;

  case KRT_SENS_ODO: 
   node->Val = indx.dist * 10;
   node->Pos = node->Val;
   return KRT_OK;

  case KRT_SENS_SHAKE:
  case KRT_SENS_PRESS: case KRT_SENS_ANGLE: case KRT_SENS_VOG: 
  case KRT_SENS_EXT: 
   sprintf(drvError, "Запрос данных этого типа датчиков не реализован");
//   MessageBox(NULL,drvError,"Error",MB_OK);
   return KRT_ERR;

  default:
   sprintf(drvError, "Запрошен неизвестный тип датчиков");
//   MessageBox(NULL,drvError,"Error",MB_OK);
   return KRT_ERR;

 }

 return KRT_OK;
}

/* функция регистации записи */
long KRTAPI krtDrvRegister (
 LPSTR datFile, 
 LPSTR trcFile, 
 char **errText, 
 long (KRTAPI *userBreak) (short percentDone)
 ) {

FILE *in, *out;

T_INDX indx;
T_KROT_HEAD head;
T_ITEM item;
T_WELD weld;
T_STOP stop;
T_SUMMARY trace;
short stopFlag=0, st_index=0;
long all_time, start_time, end_time, speed, delta_time;
short first_weld = 1;
div_t x;
static char drive[MAXDRIVE];
static char dir[MAXDIR];
static char file[MAXFILE];
static char ext[MAXEXT];
static char ini[MAXPATH];
static char exe[MAXPATH];
static char obj[MAXPATH];
static char inf[MAXPATH];
static char idx[MAXPATH];
long lfsize, lftell;
long weld_count;
double percent;


 fnsplit(datFile, drive, dir, file, ext);
 fnmerge(idx, drive, dir, file, INDEX_EXT);

 in = fopen (datFile, "rb");
 if (in == NULL)
 {
    sprintf (drvError,"Can't open file %s for reading",datFile);
    *errText = &(drvError[0]);
    return KRT_ERR;
 }

 fseek(in,0,SEEK_END);
 lfsize = ftell(in);
 fseek(in,0,SEEK_SET);
 weld_count = 0;

 out = fopen(idx, "wb");
 if (out == NULL)
 {
    sprintf (drvError,"Can't open file %s for writing",idx);
    *errText = &(drvError[0]);
    return KRT_ERR;
 }

 fread(&head, sizeof(T_KROT_HEAD), 1, in);
 if (head.sign != KROT_SIGN)
 {
    sprintf (drvError,"Bad header");
    *errText = &(drvError[0]);
    return KRT_ERR;
 }

 //---------------------Генерим idx-файл--------------------------
 speed = 0L;
 memset(&trace, 0, sizeof(T_SUMMARY));

 trace.serialNo = head.serialNo;

 trace.d_year = head.year;
 trace.d_month = head.month;
 trace.d_day = head.day;
 trace.d_hour = head.hour;
 trace.d_minutes = head.minutes;
 trace.d_second = head.second;

 trace.s_year = head.sinh_year;
 trace.s_month = head.sinh_month;
 trace.s_day = head.sinh_day;
 trace.s_hour = head.sinh_hour;
 trace.s_minutes = head.sinh_minutes;
 trace.s_second = head.sinh_second;

 trace.stop_reson = R_UNKNOWN;

 do {
     fread(&item, sizeof(T_ITEM), 1, in);
     switch (item.sign) {

     case D_WELD :
         lftell = ftell(in);
         fseek(in, lftell - sizeof(T_ITEM), SEEK_SET);
         fread(&weld, sizeof(T_WELD), 1, in);
         if (first_weld == 1)
         {
             first_weld = 0;
             start_time = weld.time;
             end_time = weld.time;
             trace.dist = weld.dist;
         }
         else
         {
             delta_time = weld.time - end_time;
             if (delta_time == 0L)
                 speed = OUT_SPEED;
             else
                 speed = (weld.dist - trace.dist) * TIC_PER_SECOND / delta_time;

             end_time = weld.time;
             trace.dist = weld.dist;
         }

         weld_count++;
         if (weld_count == 50) {
            weld_count = 0;
            percent = 100 * (double) lftell;
            percent = percent / (double) lfsize;

            if (userBreak((short) percent)) {
                sprintf (drvError, "Отменено пользователем.");
                *errText = &(drvError[0]);
                return KRT_ERR;
            }
         }

         indx.dist = weld.dist;
         indx.width = weld.wdist;
         // index.pos будет указывать на первый элемент в этом сегменте
         // или на границу следующего сегмента, если этот сегмент пустой
         indx.pos = ftell(in);
         indx.speed = (short) speed;

         // подстраховка от неверного номера датчика
         if (weld.orient >= KROT128_SENSNUM)
         {
             weld.orient = 0;
         }
         indx.top = weld.orient;

         indx.time = weld.time;
         fwrite(&indx, sizeof(T_INDX), 1, out);

         if (stopFlag == 1)
         {
             stopFlag = 0;
         }
         trace.stop_reson = R_UNKNOWN;

         break;

     case D_STOP :
         if (stopFlag == 0)
         {
             st_index++;
             stopFlag = 1;
         }

         break;

     case D_BARDOWN :
         fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
         fread(&stop, sizeof(T_STOP), 1, in);
         trace.stop_reson = R_BARDOWN;

         break;
     case D_POWERON :
         fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
         fread(&stop, sizeof(T_STOP), 1, in);

         break;
     case D_POWERFAIL :
         fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
         fread(&stop, sizeof(T_STOP), 1, in);
         trace.stop_reson = R_POWERFAIL;

         break;
     case D_DISKFULL :
         fseek(in, ftell(in) - sizeof(T_ITEM), SEEK_SET);
         fread(&stop, sizeof(T_STOP), 1, in);
         trace.stop_reson = R_DISKFULL;

                 break;
     case D_DFKT01 :
     case D_DFKT02 :
     case D_DFKT03 :
     case D_DFKT04 :
     case D_DFKT05 :
     case D_DFKT06 :
     case D_DFKT07 :
     case D_DFKT08 :
     case D_DFKT09 :
     case D_DFKT10 :
     case D_DFKT11 :
     case D_DFKT12 :
     case D_DFKT13 :
     case D_DFKT14 :
     case D_DFKT15 :
     case D_DFKT16 :
         trace.stop_reson = R_UNKNOWN;
         break;
     default:
         trace.unknown_item++;
         break;
    }
 } while (!feof(in));

 if (start_time > end_time)
     all_time = (TIC_PER_SECOND * 60L * 60L * 24L) - start_time + end_time;
     else
     all_time = end_time - start_time;

 all_time = all_time / (TIC_PER_SECOND * 60L); /* время в минутах */
 x = div((short) all_time, 60);
 trace.wt_hour = x.quot;
 trace.wt_minutes = x.rem;

 fclose(in);
 fclose(out);

 // запись необходимой информации в заданный trc-файл
 WritePrivateProfileString(DRIVER_DATA, KRTINF_ITEM_PRIMARY, datFile, trcFile);
 return KRT_OK;
}
