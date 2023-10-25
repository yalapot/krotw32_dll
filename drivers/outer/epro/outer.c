// epro_drv.c - тела callback-функций и функции экспортируемых драйвером
// просмотра данных електронного блока "epro" 
// для программы KrotW32
//
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "winkrt.h"
#include "KrtAPI.h"
#include "KrtAPI2.h"
#include "krotepro.h"
#include "libdafil.h"
#include "heapinsp.h"

#include "reciever.h"
#include "iniTool.h"
#include "fileTool.h"

extern void getDriveDir(const char * fullPath, char *driveDir);


STARTUPINFO startupInfo;
PROCESS_INFORMATION processInfo;
char Command_line[1024];
long Trace_runing_process=0;

long global_flag_client=1;


// функция выводит строку измерений с индексом datIndx из массива измерений оборота spin 
// в строку с индексом rowIndx буферов развертки screen и rowData
__inline void putItemLine(
   T_OPENED_TRACE *trc, T_SPIN_INFO *spin, 
   long spinOffset, long rowIndx, long datIndx, long group, long length, 
   KRTDATA *screen,  KRTROW *rowData,
   long updateThickIndex
) 
{

   long i, baseScreenOffset, scanOffset, lineOffset, totalOffset, realIndx, *thick, thickIndx, thickVal;
   T_INQUIRY *data;
   long x;

    // базовое смещение строки в развертке
    baseScreenOffset = length * rowIndx;

    // смещение в массиве одной строки измерений в зависимости от индекса сканера
    scanOffset = trc->sensInGroup * group;

    // указатель на строку измерений datIndx
    data = &(spin->item[datIndx]);

    // получить величину смещения продольного одометра на строке измерений datIndx
    if (trc->isOdoNotUse) {
        lineOffset = 0;
     } else {
        lineOffset = data->prod_put - spin->odo.start;
     };
    assert(lineOffset>=0);

    if (updateThickIndex >= 0) {
        thick = trc->thick.data;
        thickIndx = updateThickIndex + lineOffset;
        thickVal = thick[thickIndx];
        if (thickVal) {
           thickVal += data->Thick;
           thickVal /= 2;
        } else {
           thickVal = data->Thick;
        }
        thick[thickIndx] = thick[thickIndx+1] = thickVal;
    }

    // если указатели на буфера данных нулевые, то функция используется только для 
    // обновления данных толщины.
    if (!rowData) return;

    // для каждого датчика в сканере с индексом group
    for (i=0; i < (long) ((double)(trc->sensInGroup) * trc->sens_step); i++)
    {
        // получить полную величину смешения датчика от начала буфера развертки
        totalOffset = spinOffset + lineOffset + i;
        // если датчик попадает в развертку
        if ((totalOffset >= 0) && (totalOffset < length)) {
            // вывести его в буфера развертки
            realIndx = scanOffset+(trc->sensInGroup) - 1 - (long)((double)(i)/trc->sens_step);
            screen[baseScreenOffset + totalOffset]  = (KRTDATA) (data->math_sens[realIndx] * KRT_PALLETE_SIZE / trc->max_data_code);

             if (screen[baseScreenOffset + totalOffset] >= KRT_PALLETE_SIZE) {
                screen[baseScreenOffset + totalOffset] = KRT_PALLETE_SIZE-1;
              };

            rowData[baseScreenOffset + totalOffset] = data->sens[realIndx];

            // Заполнить массив с номерами датчиков
            x = (long)((double)(i)/trc->sens_step); //
        }
    } // for (i=0; i < (long)((double)(trc->sensInGroup)*trc->sens_step); i++)

    return;
} // void putItemLine

// функция выводит данные оборота spin сканера с индексом group в записи trc
// для участка start:length в буфера развертки screen и rowData 
// параметр isPrevSpinComplete указывает, был ли предыдущий оборот полным
void putSpin(
  T_OPENED_TRACE *trc, T_SPIN_INFO *spin, short isPrevSpinComplete, 
  long group, long start, long length, 
  KRTDATA *screen, KRTROW *rowData
)
{

   long i, spinOffset, dataIndx, updateThick, l, rowNum, blackSpace, rowIndx;

    // получить смещение оборота от начала буфера развертки
    spinOffset = spin->odo.start - start;

    updateThick = -1;
    l = spin->item[spin->itemNum - 1].prod_put - spin->odo.start;
    for (i=0; i < l; i++) {
       if (trc->thick.data[spin->odo.start + i] == 0) {
          updateThick = spin->odo.start;
          trc->thick.isChanged = 1;
        break;
       }
    }

    // для каждой строки буфера развертки
    for (i=0; i < trc->virtSens; i++)
    {
         // вычислить соответствующий ей индекс в массиве измерений оборота
         assert(trc->virtSens>0);

         // скорректируем номер строки с учетом верхней мертвой точки
         // и повернем на пол-оборота, если 2 сканер
         rowNum = (trc->secondScanShift * group + i - trc->topShift + trc->virtSens) % trc->virtSens;

         if (spin->isComplete) {
             // если оборот полный, то смасштабировать индекс строки в индекс измерения
             dataIndx = (long) (((double) rowNum) * ((double)spin->itemNum) / ((double)trc->virtSens));
         } else {
             // если оборот не полный, то странслировать индекс в зависимости от того,
             // был ли полным предыдущий оборот
             if (isPrevSpinComplete) {
                if (rowNum > spin->itemNum) {
                   dataIndx = -1;
                 } else {
                   dataIndx = rowNum;
                 };
             } else {
                 blackSpace = trc->virtSens - spin->itemNum;

                 if (blackSpace < 0) blackSpace = 0;
                 if (rowNum < blackSpace) dataIndx = -1;
                                     else dataIndx = rowNum - blackSpace;
             }
         }

         if (dataIndx >= 0) {
             // проверим, что вычесленный индекс не вышел за границу массива показаний
             if (dataIndx >= spin->itemNum) dataIndx--;
             // вывернем 'наизнанку' развертку, для вида снаружи трубы
             dataIndx = spin->itemNum - 1 - dataIndx;
         }

         assert(dataIndx < spin->itemNum);

         if (dataIndx >= 0)
         {
          // вывести найденное измерение в соотв.строку буферов развертки
           if (trc->orient_direct_count!=0) {
                rowIndx = trc->virtSens - i - 1;
            } else {
                rowIndx =  i;
            };
            putItemLine(trc, spin, spinOffset, rowIndx, dataIndx, group,  length, screen, rowData, updateThick);

         } // if (dataIndx >= 0)

    } // for (i=0; i < trc->virtSens; i++)

    return;
} // void putSpin

void updateThickData(T_OPENED_TRACE *trc, long pos) {
T_SPIN_INFO spin;

#ifdef KROT_DEBUG
 fprintf(trc->log, "updateThickData: %ld\n", pos);
#endif

 getFirstSpin(trc, pos, &spin);
 putSpin(trc, &spin, 1, 1, pos, 32, NULL, NULL);
}

long WINAPI krtDrvFillData( 
 KRTHANDLE handle, 
 long group, 
 long start,
 long length, 
 KRTDATA *screen, 
 KRTROW *rowData
 ) {

T_OPENED_TRACE *trace;
T_SPIN_INFO spin;
long screenEnd, currEnd;
short isPrevSpinComplete;

long my_start;

 trace = getTrace(handle);
 if (!trace) return KRT_ERR;

 // проверим корректен ли параметр group
 if ((group > 1) || (group < 0)) {
  sprintf(drvError, "group неправильный %ld (krtDrvFillData)", group);
  return KRT_ERR;
 };

 // проверим корректна ли запрошенная начальная дистанция start 
 if (start < 0) {
  sprintf(drvError, "неправильная дистанция %ld (krtDrvFillData)", start);
  return KRT_ERR;
 };

 // вычислить конец буфера развертки в единицах продольного одометра
 screenEnd = start + length;
 // получить первый оборот на заданной дистанции
 // захватываем предыдущий оборот, если он был для ликвидации черного следа 
 // предыдущего оборота внизу и вначале буфера
 if (start >= (long)((double)(trace->sensInGroup)*trace->sens_step)) {
     my_start = start - (long)((double)(trace->sensInGroup)*trace->sens_step);
  } else {
     my_start = start;
  };

 if ( !getFirstSpin(trace, my_start, &spin) ) 
  { 
     return KRT_ERR; 
  };

 // конец оборота в измерениях вдоль оси трубы
 if (spin.odo.length > 0 ) {
     currEnd = spin.odo.start + trace->sensInGroup;
  }else {
     currEnd = screenEnd;
  };

 isPrevSpinComplete = NOT_FULL_SPIN;

 // крутим цикл пока конец планки сканера в верхней мертвой точке 
 // не наедет на край буфера развертки
 while (currEnd < screenEnd) {
   // вывести текущий оборот в буфер развертки
   putSpin(trace, &spin, isPrevSpinComplete, group, start, length, screen, rowData);
   isPrevSpinComplete = spin.isComplete;

   my_start = spin.odo.start + spin.odo.length;
   if ( !getFirstSpin(trace, my_start, &spin) ) 
    { 
       return KRT_ERR; 
    };

   if (spin.odo.length > 0 ) {
       currEnd = spin.odo.start + trace->sensInGroup;
    }else {
       currEnd = screenEnd;
    };
 }

 if (spin.odo.length > 0) {
  putSpin(trace, &spin, isPrevSpinComplete, group, start, length, screen, rowData);
 }

 return KRT_OK;
}; // krtDrvFillData

// интерфейсная функция открытия записи
long EXPORT KRTAPI krtOpenTrace(
const char * traceFile, 
KRTHANDLE handle, 
T_TRACEINFO *inf, 
long draft
){
T_OPENED_TRACE * trc;
char thickFile[1024];

HMODULE module_handle;
DWORD get_path_res;
char lpFilename[1024];
long str_length;

 // первый вызов ( draft == 1 )
 if (draft) {
  inf->sensGroups = 2;  // скока поясов развертки
  inf->extSensors = 2;  // дополнительных датчиков 2
  return KRT_OK;
 }

 // второй вызов ( draft == 0 )
 inf->krtDrvError = krtDrvError; // а вдруг ош. кака, надо заполнить заранее

 trc = createTrace(traceFile, handle);
 if (!trc) { return KRT_ERR; }

#ifdef KROT_DEBUG
 trc->log = fopen("c:\\outer.log", "wt");
 fprintf(trc->log, "Start\n");
#endif

 // режим отображения развертки верт/спирал
 trc->isOdoNotUse = getTrcInt(trc->file, KEY_VERT, 0);
 // виртуальная длина записи (в инишнике длина в метрах)
 trc->virtLength = getTrcInt(trc->file, KEY_DATLEN, INI_DATALEN_DFLT) * 1000;
 // кол-во виртуальных датчиков 
 trc->virtSens = getTrcInt(trc->file, KEY_SENSNUM, INI_SENSNUM_DFLT);
 // сдвиг верхней мертвой точки
 trc->topShift = getTrcInt(trc->file, INI_TOPSHIFT, TOP_SHIFT_MINUTES);
 // посчитаем смещение верхней мертвой точки в датчиках
 trc->topShift = trc->virtSens * (FULL_CIRCLE - trc->topShift) / FULL_CIRCLE;
 // посчитаем смещение второго сканера относительно первого в датчиках
 trc->secondScanShift = (trc->virtSens + trc->Skan_2_Shift) * (FULL_CIRCLE / 2) / FULL_CIRCLE;

 // заполним для вторички данные об открываемой трассе
 inf->askMetod   = SENS_ASK_DIST;
 inf->stepSize   = 1;

 // заполним параметры первого сектора
 inf->group[0].num       = trc->virtSens; //trace_list[curent_trace].trace->corosion_sens_num;
 inf->group[0].type      = SENS_TYPE_HOLL;
 inf->group[0].minValue  = 0;
 inf->group[0].maxValue  = KRT_PALLETE_SIZE;

 inf->group[0].isRow     = 1; // 1/0 если 0 сырые данные не поддерживаются
 inf->group[0].minRowVal = 0; // минимальное значение сырых данных 
 inf->group[0].maxRowVal = trc->max_data_code; // максимальное значение сырых данных 

 // заполним параметры второго сектора
 inf->group[1].num       = trc->virtSens; //trace_list[curent_trace].trace->corosion_sens_num;
 inf->group[1].type      = SENS_TYPE_HOLL;
 inf->group[1].minValue  = 0;
 inf->group[1].maxValue  = KRT_PALLETE_SIZE;

 inf->group[1].isRow     = 1; // 1/0 если 0 сырые данные не поддерживаются
 inf->group[1].minRowVal = 0; // минимальное значение сырых данных 
 inf->group[1].maxRowVal = trc->max_data_code; // максимальное значение сырых данных 

 // никаких ха-ха
 inf->length             = trc->virtLength;
 inf->time               = trc->trace_time = trc->virtLength;

 inf->timerNum           = 1;
 inf->timerStep          = inf->stepSize;

 inf->odoNum             = 1;
 inf->odoStep            = inf->stepSize;

 // типа датчик толщины 
 inf->wallThickNum       = 1; // количество каналов
 inf->wallThickMin       = 0; // минимальное значение канала 
 inf->wallThickMax       = trc->max_data_code; // максимальное значение канала 

 inf->speedMin = 0;
 inf->speedMax = 100;

 inf->extSens[0].minValue = 0;
 inf->extSens[0].maxValue = 1000000;
 strncpy (
  inf->extSens[0].name, 
  "Счетчик ВМТ", 
  EXT_SENS_NAME_LENGTH
 );

 inf->extSens[1].minValue = 0;
 inf->extSens[1].maxValue = 1000;
 strncpy (
  inf->extSens[1].name, 
  "Номер .da", 
  EXT_SENS_NAME_LENGTH
 );

 // Инициализируем указатели на Callback - Функции 
 inf->krtDrvFillData          = krtDrvFillData;
 inf->krtDrvGetFirstNode      = krtDrvGetFirstNode;
 inf->krtDrvGetNextNode       = krtDrvGetNextNode;
//  inf->krtDrvGetFirstNodeGroup = krtDrvGetFirstNodeGroup;
//  inf->krtDrvGetNextNodeGroup  = krtDrvGetNextNodeGroup;

 // Обнулим поля в inf, которые не заполнялись нашим драйвером
 inf->vog=0;

 inf->orientNum=0;
 inf->orientStep=0;

 inf->shakeNum=0;
 inf->shakeStep=0;

 inf->pressNum=0;
 inf->pressStep=0;
                     
 inf->tempNum=0;
 inf->tempStep=0;

 inf->angleNum=0;
 inf->angleStep=0;

 inf->shakeMin=0;
 inf->shakeMax=0;

 inf->pressMin=0;
 inf->pressMax=0;

 inf->tempMin=0;
 inf->tempMax=0;

 inf->angleMin=0;
 inf->angleMax=0;
 // Обнулили поля в inf, которые не заполнялись нашим драйвером


 // инициализируем и открываем индексный файл толщины стенки трубы
 getDriveDir(trc->file, thickFile);
 strcat(thickFile, "\\thick.idx");
 if (initThick(thickFile, trc->virtLength / trc->trace_step, &(trc->thick))) { return KRT_ERR; }

 module_handle=GetModuleHandle(NULL);

 get_path_res=GetModuleFileName(module_handle, lpFilename, 1024);

 str_length=strlen(lpFilename);

 if ((strcmp(&lpFilename[str_length-11], "krotw32.exe") != 0) ) {
    if ((strcmp(&lpFilename[str_length-12], "krotw32r.exe") != 0) ) {
        return KRT_OK;
     };
  };

 if (isFileExist("C:\\Program Files\\KrotW32\\out\\client.exe") == 0) {
     return KRT_OK;
  };

 if (global_flag_client == 0) {
     return KRT_OK;
  };


 ZeroMemory( &startupInfo, sizeof(STARTUPINFO) );

 if (
      MessageBox(NULL, " Запускать Client.exe ? \n", "Outer open trace",MB_YESNO | MB_ICONQUESTION | MB_SYSTEMMODAL)
      ==6
    ) 
  {
     strcpy(Command_line, "C:\\Program Files\\KrotW32\\out\\client.exe ");
     strcat(Command_line, "\"");
     strcat(Command_line, traceFile);
     strcat(Command_line, "\"");

     while((strlen(Command_line)>0) && (Command_line[strlen(Command_line)-1]!='\\')) {
        Command_line[strlen(Command_line)-1]=0;
      };

     if (CreateProcess( NULL,
                        Command_line,
                        NULL,
                        NULL,
                        FALSE,
                        NORMAL_PRIORITY_CLASS | CREATE_NEW_CONSOLE,
                        NULL,
                        NULL,
                        &startupInfo,
                        &processInfo
                      ) == TRUE
        )
      {
        Trace_runing_process=handle;
      }; 

  } else {
     global_flag_client = 0; // Ответили не надо клиента, запомним на будущее
  };

  return KRT_OK;
} // krtOpenTrace

long EXPORT KRTAPI krtCloseTrace ( KRTHANDLE handle) {
  int curent_trace; 

  if (open_trace_counter==0) {
     sprintf (drvError, "нет открытых трасс(krtCloseTrace)");
     return KRT_ERR;
   };

  // найдем открытую трассу в списке:
  for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
     if (handle==trace_list[curent_trace].handle) {
        // и закроем ее

	freeThick(&(trace_list[curent_trace].trace->thick));
        if ( free_opened_trace(trace_list[curent_trace].trace) != NULL) {
           sprintf (drvError, "ошибка закрытия трассы(krtCloseTrace)");
           return KRT_ERR;
         };

        open_trace_counter--;

        trace_list[curent_trace].handle = trace_list[open_trace_counter].handle;
        trace_list[curent_trace].trace  = trace_list[open_trace_counter].trace;

        trace_list[open_trace_counter].handle = 0;
        trace_list[open_trace_counter].trace  = NULL; 

        if (processInfo.hProcess>0 && Trace_runing_process==handle ) {
            TerminateProcess(processInfo.hProcess,NO_ERROR); // убрать процесс
            Trace_runing_process=0;
         };

        return KRT_OK;
      };
   };


  sprintf(drvError, "не найден handle (krtCloseTrace)");
  return KRT_ERR; 

}; // krtCloseTrace 

/////////////////////////////////////////////////////
// функция информации о драйвере - заглушка для первого вызова
long EXPORT KRTAPI krtDriverInfo (T_DRVINFO *drv ) {
  if (drv==NULL) return KRT_ERR;

  drv->apiVer = DRIVER_API_VER;
  drv->krtDrvRegister = NULL;
  return KRT_OK;

}; /* krtDriverInfo (T_DRVINFO *drv ) */

/////////////////////////////////////////////////////
// функция установки обработчика сообщения о поступлении новых данных
// если NULL, то динамическое оповещение о поступлении данных не поддерживается.
// если обработчик newDataRegistered успешно установлен и будет вызывываться 
// при поступлении новых данных, должен возвращать 1.
// если обработчик не установлен, должен возвращать 0. 
long KRTAPI krtOnline (
  // дескриптор прогона, для которого устанавливается обработчик
  KRTHANDLE handle, 
  // указатель на callback функцию, вызываемую драйвером при поступлении новых данных.
  // возвращает 1 если блок новых данных подключен к записи и 
  // 0 если блок новых данных не обработан и и его необходимо повторно указать
  // как новые данные при следующем вызове.
  // аргумент newData является указателем на структуру, описывающую блок поступивших данных.
  long (KRTAPI *newDataRegistered) (T_ArrivedData *newData)
  ) {

T_OPENED_TRACE *trc;

 trc = getTrace(handle);
 if (trc == NULL) { return 0; }
 return newDataRegistered ? startDataRecieve(trc, newDataRegistered) : stopDataRecieve(trc);
}

/////////////////////////////////////////////////////
// функция регистрации записи
long KRTAPI krtDrvRegister (
 const char * outIniFile, 
 const char * trcFile, 
 const char * indxPath,
 char **errText, 
 long (KRTAPI *informUser) (short percentDone, const char *msg)
 ) {

long recordLength, virtSens, topInMinutes;
long NotUseOdo, trace_step, max_data_code, orient_direct_count;
long Amplification_Group0, Amplification_Group1;
char Invert_sens_data[1024];
long razvorot_1_skanera,razvorot_2_skanera, Smooth_win_length, Skan_2_Shift;
char Sens_step[32];


char data_path[_MAX_PATH];
char *sym;
   char key_name[1024];
   char key_value[1024];
   long i;


 (void) indxPath;
 (void) informUser;

 *errText = &(drvError[0]);

 /////////////////////////////////////////////////////////
 // читаем из ini-файла
 /////////////////////////////////////////////////////////

 // путь на каталог с данными 
 getDriveDir(trcFile, data_path);  // по умолчанию каталог trc файла
 sym = getIniItem(outIniFile, INI_SECT, INI_DATA, "");
 if (*sym) strcpy(data_path, sym);
 sym = & data_path[strlen(data_path)-1]; // отсекаем замыкающий слеш, если есть
 if (*sym == '\\') { *sym = 0; }
 
 if (!isFolderExist(data_path)) {
  sprintf(drvError, 
   "Указанный в файле %s ([%s]:%s) каталог %s не существует.",
   outIniFile, 
   INI_SECT, 
   INI_DATA,
   data_path
   );
   *errText = &(drvError[0]);
   return KRT_ERR;
 }

 // виртуальная длина записи 
 recordLength = getIniInt(outIniFile, INI_SECT, INI_DATALEN, INI_DATALEN_DFLT);
 // кол-во виртуальных датчиков
 virtSens = getIniInt(outIniFile, INI_SECT, INI_SENSNUM, INI_SENSNUM_DFLT);
 // положение ВМТ
 topInMinutes = getIniInt(outIniFile, INI_SECT, INI_TOPSHIFT, TOP_SHIFT_MINUTES);


 NotUseOdo=getIniInt(outIniFile, INI_SECT, KEY_VERT, 0);
 trace_step=getIniInt(outIniFile, INI_SECT, TRACE_STEP_KEY, 10);
 max_data_code=getIniInt(outIniFile, INI_SECT, MAX_DATA_CODE_KEY, MAX_DAT_VAL);
 Amplification_Group0=getIniInt(outIniFile, INI_SECT, Amplification_Group0_KEY, 4);
 Amplification_Group1=getIniInt(outIniFile, INI_SECT, Amplification_Group1_KEY, 8);
 Smooth_win_length=getIniInt(outIniFile, INI_SECT, Smooth_win_length_KEY, 8);

 sym=getIniItem(outIniFile, INI_SECT, Invert_sens_data_KEY, "");
 strcpy(Invert_sens_data, sym);

 razvorot_1_skanera=getIniInt(outIniFile, INI_SECT, razvorot_1_skanera_KEY, 0);
 razvorot_2_skanera=getIniInt(outIniFile, INI_SECT, razvorot_2_skanera_KEY, 0);
 sym=getIniItem(outIniFile, INI_SECT, KEY_SENS_STEP, "2.5");
 strcpy(Sens_step, sym);
 orient_direct_count=getIniInt(outIniFile, INI_SECT, orient_direct_count_KEY, 0);

 Skan_2_Shift = getIniInt(outIniFile, INI_SECT, Skan_2_Shift_KEY, 0);


 /////////////////////////////////////////////////////////
 // запись необходимой информации в заданный trc-файл
 /////////////////////////////////////////////////////////
 setTrcInt(trcFile, KEY_DATLEN, recordLength);
 setTrcInt(trcFile, KEY_SENSNUM, virtSens);
 sym = isFileInDir(trcFile, data_path) ? "" : data_path;
 setTrcItem(trcFile, KEY_DATA, sym);
 setTrcInt(trcFile, INI_TOPSHIFT, topInMinutes);
 setTrcInt(trcFile, KEY_VERT, NotUseOdo);

 setTrcInt(trcFile, TRACE_STEP_KEY, trace_step);
 setTrcItem(trcFile, FIRST_FILE_NAME_KEY, "tm00000.da");
 setTrcInt(trcFile, MAX_DATA_CODE_KEY, max_data_code);
 setTrcInt(trcFile, Amplification_Group0_KEY, Amplification_Group0);
 setTrcInt(trcFile, Amplification_Group1_KEY, Amplification_Group1);

 setTrcItem(trcFile, Invert_sens_data_KEY, Invert_sens_data);
 setTrcInt(trcFile, razvorot_1_skanera_KEY, razvorot_1_skanera);
 setTrcInt(trcFile, razvorot_2_skanera_KEY, razvorot_2_skanera);
 setTrcItem(trcFile, KEY_SENS_STEP, Sens_step);
 setTrcInt(trcFile, orient_direct_count_KEY, orient_direct_count);

 setTrcInt(trcFile, Smooth_data_OFF_KEY, 0);
 setTrcInt(trcFile, Smooth_win_length_KEY, Smooth_win_length);
 setTrcInt(trcFile, Median_smooth_KEY, 0);

 setTrcInt(trcFile, Skan_2_Shift_KEY, Skan_2_Shift);

 // запишем в trc-файл сортировочные данные первого сектора
 for (i=0; i<96; i++) {
    sprintf(key_name, "%s%d", SENS_SORT_KEY, i);
    sprintf(key_value, "%i", i);
    setTrcItem(trcFile, key_name, key_value);
  };
 // записали в trc-файл сортировочные данные первого сектора


 // демонстрация длительной обработки данных с периодическими
 // вызовами функции передачи обьема проделанной работы и проверкой, 
 // не нажал ли пользователь кнопку команды прерывания работы
/*
 for (topInMinutes=0; topInMinutes<=100; topInMinutes++) {
  sprintf (data_path, "цикл %ld", topInMinutes);
  if (informUser( (short) topInMinutes, data_path)) {
   sprintf (
    drvError, 
    "Отменено пользователем." 
   );
   *errText = &(drvError[0]);
   return KRT_ERR;
  }
  Sleep(100);
 }
*/


 strcpy(key_name, data_path);
 strcat(key_name, "trace.idx");
 DeleteFile(key_name);

 strcpy(key_name, data_path);
 strcat(key_name, "thick.idx");
 DeleteFile(key_name);

 return KRT_OK;
} /* krtDrvRegister */

/////////////////////////////////////////////////////
// функция информации о драйвере - реальная информация для второго вызова
long EXPORT KRTAPI krtDriverInfoExt (long apiVer, void *drvInfoStruct) {
T_DRVINFO2 *drv2;

 (void) apiVer;

 drv2 = (T_DRVINFO2 *) drvInfoStruct;

 drv2->apiVer = KRT_APIVER2;
 drv2->pigType = PIG_SPIRAL;

 strcpy(drv2->drvSign,   "OUTER");
 strcpy(drv2->drvName,   "Универсальный драйвер ВНТД");
 strcpy(drv2->drvCopyRt, "(C) 2005-2006 by Dmitry Svintsov & Vitaly Bogomolov");

 drv2->drvVerMax = DRIVER_VER_MAX;
 drv2->drvVerMin = DRIVER_VER_MIN;
 drv2->krtDrvRegister = NULL;
 drv2->krtOnline = krtOnline;

 drv2->krtDrvRegister = krtDrvRegister;

 return KRT_OK;
}
