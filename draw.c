/*
Модуль отрисовки показаний датчиков.
*/
#include "krotw32.h"
#include "filter.h"

#include "debuglog.h"

// LOG_1 - старая общая отладочная информация
//#define LOG_1

// LOG_BASE_LINE - отладка базовой линии
//#define LOG_BASE_LINE

short ScaleMode = 0;      //задает тип прореживания точек при масштабировании: 0 - максимольное значение
                          //                                                   1 - минимальное значение
                          //                                                   2 - среднее значение
                          //                                                   3 - случайное или первое попавшееся значение
short OldScaleMode = 0;

void krotGraphBlt (
  T_CRZSENS *crz, 
  KRTDATA *data,
  long datX,
  long datY,
  void *bmpBuff,
  void *bmpBuffGrafh,
  HWND pic,
  HBITMAP bmp,
  long bmpX,
  long bmpY,
  long bmpXstart,
  long bmpXend,
  long top
) {
HDC hdc, dc;
HBRUSH brush;
RECT r;
HPEN pen1, pen2;
long i, j, scrollPixels, x, yPlace, y0, evenFlag;
double y, k;

 GetClientRect(pic, &r);
 dc = GetDC(pic);

 hdc = CreateCompatibleDC(dc);
 SelectObject(hdc, bmp);

 brush = CreateSolidBrush(crz->vbGraphs.clrBackGround);
 SelectObject(hdc, brush);
 Rectangle(hdc, bmpXstart-1, r.top-1, bmpXend+1, r.bottom+1); 
 pen1 = CreatePen(PS_SOLID, 0, crz->vbGraphs.clrEven);
 pen2 = CreatePen(PS_SOLID, 0, crz->vbGraphs.clrOdd);
 SelectObject(hdc, pen1);
 DeleteObject(brush);

 y0 = KRT_PALLETE_SIZE / 2;
 k = crz->vbGraphs.amplif;
 k = k * crz->vbGraphs.gap / KRT_PALLETE_SIZE;
 scrollPixels = bmpXend - bmpXstart;
 evenFlag = 0;

 for (j = 0; j < datY; j += crz->vbGraphs.gap) {

  yPlace = (j + (datY - top)) % datY ;
  yPlace = yPlace * bmpY / datY;

  y = yPlace - (data[j*datX] - y0) * k;
  MoveToEx(hdc, bmpXstart, (int) y, NULL); 
  evenFlag ^= 1;
  SelectObject(hdc, (evenFlag ? pen1 : pen2));

  for (i=1; i<datX; i++) {
   y = yPlace - (data[j*datX + i] - y0) * k;
   x = i * scrollPixels / datX;
   LineTo(hdc, bmpXstart+x, (int) y); 
  }
  // last segment - need border data column
  x = i * scrollPixels / datX;
  LineTo(hdc, bmpXstart+x, (int) y); 
 }

 DeleteDC(hdc);
 DeleteObject(pen1);
 DeleteObject(pen2);
 GetBitmapBits(bmp, bmpX * bmpY * bytesPerPixel, bmpBuffGrafh);
 ReleaseDC(pic, dc);

 for (i=0; i < bmpY; i++) {
  j= (i * bmpX + bmpXstart) * bytesPerPixel;
  memmove(((BYTE *) bmpBuff)+j, ((BYTE *) bmpBuffGrafh)+j, scrollPixels * bytesPerPixel);
 }

 return;
}

void krotStretchBlt (
  T_CRZSENS *crz, 
  KRTDATA *data,
  long *ornt,
  long datX,
  long datY,
  void *bmpBuff,
  void *bmpBuffGrafh,
  HWND pic,
  HBITMAP bmp,
  long bmpX,
  long bmpY,
  long bmpXstart,
  long bmpXend,
  long top,
  T_PAL *pal, 
  int smooth
) {
long bmpXout, bx, by, xStart, xEnd, yStart, yEnd, dx, dy, bi, compressX, compressY;
KRTDATA dataVal, dXdY;
long yy, xx;
long A1, A2, A3, A4;
double dltX, dltY, ddd;
int tmp, tmp1, tmp2, tmp3, tmp4, tmpVal, count;     //tmpVal и count для подсчета среднего при значении ScaleMode == 2

long * long_buffer;
long i_counter;

    (void) ornt;

    bmpXout = bmpXend - bmpXstart;

    // выводимый участок данных сжался в размер меньше одной точки.
    // такое бывает при небольшой сдвижке развертки при большом масштабе сжатия (напр 1:64)
    // тогда ничего выводить не надо.
    if (bmpXout == 0) return;

    if (crz->drawMode == ZOOM_LINES) {
        krotGraphBlt(crz, data, datX, datY, bmpBuff, bmpBuffGrafh, pic, bmp, bmpX, bmpY, bmpXstart, bmpXend, top);
        return;
    }

    long_buffer = malloc(bmpX * bmpY * sizeof(long_buffer[0]));

    // вычислить масштабы по X и Y
    compressY = datY > bmpY ? datY / bmpY -1 : 0;
    compressX = datX > bmpXout ? datX / bmpXout -1 : 0;

    // цикл по столбцам битмапа
    for (bx=bmpXstart; bx<bmpXend; bx++) {
        // цикл по строкам битмапа
        for (by=0; by<bmpY; by++) {
            dataVal = 0; // значение данных для пиксела bx:by по умолчанию

            //для подсчета среднего при ScaleMode == 2
            count = 0;  
            tmpVal=0;

            // начальный индекс по X для пиксела bx:by в массиве данных
            xStart = datX * (bx - bmpXstart) /  bmpXout;
            // конечный индекс по Y для пиксела bx:by в массиве данных
            xEnd = xStart + compressX;

            // цикл по столбцам области данных, соответствующей пикселу bx:by
            for (dx=xStart; dx<=xEnd; dx++) {
                // начальный индекс по Y для пиксела bx:by в массиве данных
                yStart = datY * by /  bmpY + top;
                // поправки на циклический поворот через границу кол-ва датчиков
                yStart = (yStart >= datY) ? yStart - datY : yStart;
                // конечный индекс по Y для пиксела bx:by в массиве данных
                yEnd = yStart + compressY;
            	if ((ScaleMode==1)||(ScaleMode==3)) dataVal = (KRTDATA) data[datX * yStart + dx];
            	//данные по умолчанию для вычисления минимального значения при масштабировании с ScaleMode == 1 или 3
                // цикл по столбцу данных в области данных, соответствующей пикселу bx:by
                for (dy=yStart; dy<=yEnd; dy++) {
                    bi = dy;
                    bi = (bi >= datY) ? bi -datY : bi;

//                    if (smooth == 0) {

                        // текущий элемент данных
                        dXdY = (KRTDATA) data[datX * bi + dx];

                        // поправка на базовую линию, если она задана и не включен фильтр
                        if ((crz->vbFilter.active == 0) && (crz->sensor[bi].delta != 0)) {
                          tmp = dXdY + crz->sensor[bi].delta;
                          if (tmp < 0) {
                            dXdY = 0; 
                          } else if (tmp > (KRT_PALLETE_SIZE - 1)) {
                            dXdY = KRT_PALLETE_SIZE - 1;
                          } else {
                            dXdY = (KRTDATA) tmp;
                          }
                        }
//                    }

                    // выбираем точки для нужного режима масштабирования
                    switch (ScaleMode) {
                      case 0: {dataVal = (KRTDATA) ((dXdY > dataVal) ? dXdY : dataVal); break;}   //максимальное значение
                      case 1: {dataVal = (KRTDATA) ((dXdY < dataVal) ? dXdY : dataVal); break;}   //минимальное значение
                      case 2: {tmpVal = tmpVal+dXdY; count++; break;}                             //подсчет среднего
                      case 3: {dataVal = (KRTDATA) dataVal; break;}                               //первое попавшееся
                    }
                }
            }

            // сохраняем найденное значение данных в буфер битмапа
            if (ScaleMode==2) dataVal=(KRTDATA)(tmpVal/count); //вычисленное среднее значение
         	
            long_buffer[bmpX * by + bx] = dataVal;
        }
    }

    if (smooth == 1)
    { // Попробуем пристроить сглаживание
         long sens_counter;
         long length_counter;

         double k = 1;

         #pragma warning(disable : 4204)  // давим варнинг про неконстанту
                                      // при инициализации массива
         // Сглаживание 13x13
         #define matr_size 13
         #define matr_kub (matr_size * matr_size - 40)
         double matrix[matr_size][matr_size]
                         = {{          0,          0,          0,          0, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub,          0,          0,          0,          0 },
                            {          0,          0,          0, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub,          0,          0,          0 },
                            {          0,          0, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub,          0,          0 },
                            {          0, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub,          0 },
                            { k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub },
                            { k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub },
                            { k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub },
                            { k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub },
                            { k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub },
                            {          0, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub,          0 },
                            {          0,          0, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub,          0,          0 },
                            {          0,          0,          0, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub,          0,          0,          0 },
                            {          0,          0,          0,          0, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub, k/matr_kub,          0,          0,          0,          0 } };
         #pragma warning(default : 4204)

         double* Double_bufer;  // length * sens_num
         long matr_x, matr_y;
         double svertka;
         // закончились данные фильтров сверток

         Double_bufer = malloc(bmpX * bmpY * sizeof(Double_bufer[0]));

         for (length_counter = matr_size/2;
              length_counter < bmpX - matr_size/2;
              length_counter++) 
         {
             for (sens_counter = matr_size/2;
                  sens_counter < bmpY - matr_size/2;
                  sens_counter ++)
             {
                 svertka = 0;
                 for ( matr_x = 0; matr_x < matr_size; matr_x++)
                 {
                     for ( matr_y = 0; matr_y < matr_size; matr_y++)
                     {
                         svertka += 
                          (double) long_buffer[ bmpX * (sens_counter + matr_y - matr_size/2)
                                      + length_counter + matr_x - matr_size /2]
                          *
                          matrix [matr_x][matr_y]; 
                     };
                 };
                 Double_bufer[bmpX * sens_counter + length_counter] = svertka;
             };
         };

         for (length_counter = matr_size /2;
              length_counter < bmpX - matr_size /2;
              length_counter++) 
         {
             for (sens_counter = matr_size /2;
                  sens_counter < bmpY - matr_size /2;
                  sens_counter ++)
             {
                 long_buffer[bmpX * sens_counter + length_counter] = (long)
                    Double_bufer[bmpX * sens_counter + length_counter];
             };
         };

         free(Double_bufer);
    } // Пристроили снлаживание

    for (bx=bmpXstart; bx<bmpXend; bx++) {
        // цикл по строкам битмапа
        for (by=0; by<bmpY; by++) {
            putPixel(bmpBuff, bmpX * by + bx, long_buffer[bmpX * by + bx], pal);
        }
    }
    free(long_buffer);
}

/*
Функция выводит полную страницу развертки по подготовленному битмапу
полной страницы
*/
void showBmp(T_CRZSENS *crz, HWND hWnd) {
HDC hdcSrcOld, hdcSrc, hdcDest;

 hdcDest = GetDC(hWnd);
 hdcSrc = CreateCompatibleDC(hdcDest);
 hdcSrcOld = SelectObject(hdcSrc, crz->bmp);
 BitBlt (hdcDest, 0, 0, crz->pixelX, crz->pixelY, hdcSrc, 0, 0, SRCCOPY);
 SelectObject(hdcSrc, hdcSrcOld);
 DeleteDC(hdcSrc);
 ReleaseDC(hWnd, hdcDest);
}

/*
Функция готовит данные развертки
*/
short readData(T_TRACE *trc, long crzIndx, long dStart, long dLength, KRTDATA *buf, KRTROW *row) {
T_CRZSENS *crz;
long arrSize;

 crz = &(trc->crz[crzIndx]);
 // обнулить области данных
 arrSize = crz->sNum * dLength;
 memset(buf, 0, arrSize * sizeof(KRTDATA));
 memset(row, 0, arrSize * sizeof(KRTROW));
 
////////////// debug
#ifdef LOG_1
 sprintf(
  LogString, 
  "readData crzIndx %ld %ld:%ld (page %ld)", 
   crzIndx, 
   dStart,
   dLength,
   crz->pageDat 
 );
 Log();
#endif

 /* запросить у драйвера данные о развертке */

 if ((*(trc->record.krtDrvFillData))(trc->vbHandle, crzIndx, dStart, dLength, buf, row) == KRT_ERR) {
  sprintf (lastError, "Ошибка при вызове krtDrvFillData %s", driverError(trc));
  return 1;
 }
 return 0;

}

/*
Функция транслирует углы поворота снаряда в сотых долях градуса в номера датчиков в векторе ориентации
*/
void degree2sens(
 long *ornt,          // вектор ориентации
 long vLen,           // длина вектора
 long sensNum         // общее кол-во датчиков 
 ) {
long i;

 for (i=0; i<vLen; i++) {
    ornt[i] = (long) (ornt[i] * sensNum / ORNT_MAX_VAL);
 }
}

void fillBitmapPage (T_CRZSENS *crz) {
 krotStretchBlt (
  crz, 
  crz->dat0PageBuff,
  crz->vbScreen.orntOff ? NULL : crz->datPageOrnt,
  crz->pageDat,
  crz->sNum - crz->hide,
  crz->bmpBuff,
  crz->bmpBuffScroll,
  crz->pic,
  crz->bmp,
  crz->pixelX,
  crz->pixelY,
  0,
  crz->pixelX,
  crz->topSens,
  &(crz->pal), 0 );
}

/*
Функция готовит данные для полной страницы развертки с отметки start
*/
short readDataPage(T_TRACE *trc, long crzIndx, long start) {
T_CRZSENS *crz;

 crz = &(trc->crz[crzIndx]);

 if (readData(trc, crzIndx, start / crz->step, crz->pageDat, crz->dat0PageBuff, crz->datPageBuff)) return 1;

// {
//     char tmp_info[10240];
//     long i;
//     char num_txt[128];
//
//     sprintf (tmp_info, "crz->datPageOrnt = %ld\n", crz->datPageOrnt[0]);
//     for ( i = 1; i < crz->pageDat; i ++)
//     {
//         sprintf(num_txt, ", %ld", crz->datPageOrnt[i]);
//         strcat(tmp_info, num_txt);
//     }
//     MessageBox(NULL, (LPCSTR)tmp_info, (LPCSTR)"1", MB_OK | MB_ICONERROR);
// }


 switch (crz->vbFilter.active) {

   case 0: // нет фильтра
/*
       fltExponent (
           crz->dat0PageBuff, // указатель на массив обработанных данных страницы развертки
           crz->datPageBuff,  // указатель на буфер сырых данных для страницы
           crz->datPageOrnt,  // указатель на вектор ориентации страничного буфера
           crz->pageDat,      // размер массива по X
           crz->sNum,         // размер массива по Y (количество датчиков)

//           crz->sensor,     // указатель на вектор настроек датчиков. для доступа к элементам базовой линии: crz->sensor[i].delta

           20, // весовой коэффициэнт фильтра (значения от 0 до 100)
           10  // параметр усиления фильтра (значения от 1 до 100)
       );
*/
       break;


   case 1: // cheshka
       fltExponent (
           crz->dat0PageBuff, // указатель на массив обработанных данных страницы развертки
           crz->datPageBuff,  // указатель на буфер сырых данных для страницы
           crz->datPageOrnt,  // указатель на вектор ориентации страничного буфера
           crz->pageDat,      // размер массива по X
           crz->sNum,         // размер массива по Y (количество датчиков)

//           crz->sensor,     // указатель на вектор настроек датчиков. для доступа к элементам базовой линии: crz->sensor[i].delta

           14, // весовой коэффициэнт фильтра (значения от 0 до 100)
           10  // параметр усиления фильтра (значения от 1 до 100)
       );
/*     fltUnweld(
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum, 
       crz->vbFilter.unweldParam
     );
*/
     break;

   case 2: // tselnotyanutaya
     fltRolled(
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum, 
       crz->vbFilter.rolledParam1, 
       crz->vbFilter.rolledParam2,
       crz->vbFilter.rolledAmplifer
     );
     break;

   case 3: // prigruz
     fltPrigruz(
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum
     );
     break;

   case 4: // prodol treschiny
     fltPoligon(
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum, 
       crz->vbFilter.tfiParam1, 
       crz->vbFilter.tfiParam2,
       crz->vbFilter.tfiBase
     );
     break;

   case 5: // no mathematic
     fltNo_math(
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum,
       crz->sensor
     );
     break;

   case 6: // фильтр к центру //2021 // volosok
     flt_k_tsentru_plus_poperek (
//     flt_filament(
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum,
       crz->sensor,
       crz->vbFilter.unweldParam,
       crz->vbFilter.tfiParam1,
       crz->vbFilter.tfiParam2
     );
     break;

   case 7: //фильтр от центра // Фильтр 2019
     flt_ot_tsentra_plus_poperek (
//     flt_Filter2019(
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum,
       crz->sensor,
       crz->vbFilter.unweldParam
     );
     break;

   case 8: // Свертка Лапласиан
     flt_convolution_1(
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum,
       crz->sensor,
       crz->vbFilter.unweldParam
     );
     break;

   case 9: // Свертка Резкость
     flt_Skolz_plus_poperek( // скользящее среднее вдоль потом поперек
//     flt_Cut_big_small( // заменен на обрезание больших и отрицательных значений
//     flt_convolution_2(
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum,
       crz->sensor,
       crz->vbFilter.unweldParam
     );
     break;

   case 10: // Медианное усреднение
//     flt_search_for_anomalies (
//     flt_MHAT ( // MHAT свертка одномерная на каждый датчик

       fltMedianFullScreen ( // медианное усреднение 

//     flt_convolution_3( // Свертка 3 размытие двухмерная
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum,
       100,
       crz->vbFilter.unweldParam,
       crz->vbFilter.tfiParam1,
       crz->vbFilter.tfiParam2
     );
     break;

   case 11: // flt_Cut
     flt_Cut_big_small(
       crz->dat0PageBuff, 
       crz->datPageBuff, 
       crz->datPageOrnt, 
       crz->pageDat, 
       crz->sNum, 
       crz->vbFilter.rolledParam1, 
       crz->vbFilter.rolledParam2,
       crz->vbFilter.rolledAmplifer
     );
     break;
 }

 degree2sens(crz->datPageOrnt, crz->pageDat, crz->sNum);
 fillBitmapPage(crz);
 SetBitmapBits(crz->bmp, crz->pixelX * crz->pixelY * bytesPerPixel, crz->bmpBuff);
 return 0;

}

/*
Функции масштабирует значение value из измерений в пикселы согласно значению масштаба scale
по правилам крота.
*/
long krtScaleX (long data, long scale) {

 if (scale > 1) {
  return  data / scale; 
 } else if (scale < -1) {
  return data * -scale;
 } else {
  return data;
 }
}

long krtScaleY (long value, T_CRZSENS *crz) {
long sizeY;

 sizeY = crz->sNum - crz->hide;
 if (sizeY > crz->pixelY) {
  return value / (sizeY / crz->pixelY);
 } else {
  return value * (crz->pixelY / sizeY);
 }
}

/*
Функции масштабирует значение value из пикселов в измерения согласно значению масштаба scale
по правилам крота.
*/
long krtScaleXback (long pixel, long scale) {
 if (scale > 1) {
  return  pixel * scale;
 } else if (scale < -1) {
  return pixel / -scale;
 } else {
  return pixel;
 }
}

long krtScaleYback (long value, T_CRZSENS *crz) {
long sizeY;

 sizeY = crz->sNum - crz->hide;
 if (sizeY > crz->pixelY) {
  return value * (sizeY / crz->pixelY);
 } else {
  return value / (crz->pixelY / sizeY);
 }
}

/*
Функция готовит данные для буфера скроллинга с отметки start
и актуализирует данные в буфере данных страницы
знак sizeX задает направление сдвига
side = -1 сдвиг влево
side =  1 сдвиг вправо
*/
short readDataShift(T_TRACE *trc, long crzIndx, long start, long sizeX) {
long dStart, dLength, scrollPixels, pageX, pageY, i, j, x1, x2, x3;
KRTDATA *buf, *sbuf;
T_CRZSENS *crz;

 crz = &(trc->crz[crzIndx]);

 dStart  = start / crz->step;
 dLength = abs(sizeX / crz->step);

 if (readData(trc, crzIndx, dStart, dLength, crz->dat0ScrlBuff, crz->datScrlBuff)) return 1;

 degree2sens(crz->datScrlOrnt, dLength, crz->sNum);

 pageX   = crz->pageDat;
 pageY   = crz->sNum;
 buf     = crz->dat0PageBuff;
 sbuf    = crz->dat0ScrlBuff;

 if (sizeX>0) {
  x1 = 0;        x2 = dLength;  x3 = pageX - dLength;
 } else {
  x1 = dLength;  x2 = 0;        x3 = 0;
 }

 // сдвинуть буфер данных страницы и скопировать в него данные из буфера данных сдвига
 for (i=0;i<pageY;i++) {
  j=i*pageX;
  memmove(buf+j+x1, buf+j+x2, (pageX - dLength) * sizeof(KRTDATA));
  memcpy (buf+j+x3, sbuf+i*dLength, dLength * sizeof(KRTDATA));

  memmove(crz->datPageBuff+j+x1, crz->datPageBuff+j+x2, (pageX - dLength) * sizeof(KRTROW));
  memcpy (crz->datPageBuff+j+x3, crz->datScrlBuff+i*dLength, dLength * sizeof(KRTROW));
 }
 // сдвинуть буфер ориентации страницы и скопировать в него данные из буфера ориентации сдвига
 //memmove(crz->datPageOrnt+x1, crz->datPageOrnt+x2, (pageX - dLength) * sizeof(long));
 //memcpy (crz->datPageOrnt+x3, crz->datScrlOrnt, dLength * sizeof(long));

 // сдвинуть буфер битмапа страницы
 x1 = krtScaleX(x1, trc->scaleX) * bytesPerPixel;
 x2 = krtScaleX(x2, trc->scaleX) * bytesPerPixel;
 scrollPixels = crz->pixelX - krtScaleX(dLength, trc->scaleX);
 for (i=0;i<crz->pixelY;i++) {
  j=i*crz->pixelX*bytesPerPixel;
  memmove(((BYTE *) crz->bmpBuff)+j+x1, ((BYTE *) crz->bmpBuff)+j+x2, scrollPixels * bytesPerPixel);
 }
 // отразить в буфер битмапа страницы данные из буфера данных сдвига
 krotStretchBlt (
  crz, 
  crz->dat0ScrlBuff,
  crz->vbScreen.orntOff ? NULL : crz->datScrlOrnt,
  dLength,
  crz->sNum - crz->hide,
  crz->bmpBuff,
  crz->bmpBuffScroll,
  crz->pic,
  crz->bmp,
  crz->pixelX,
  crz->pixelY,
  (sizeX>0 ? scrollPixels : 0),
  (sizeX>0 ? crz->pixelX : crz->pixelX - scrollPixels),
  crz->topSens,
  &(crz->pal), 0 );

 SetBitmapBits(crz->bmp, crz->pixelX * crz->pixelY * bytesPerPixel, crz->bmpBuff);

 return 0;
}

/**************************************************************************
Функция рисует корозионную развертку crzIndx записи Handle с позиции start (мм)
При успехе  возвращает KRT_OK, KRT_ERR при ошибке.
Расширенное описание ошибки доступно через функцию krotError.
*/
short EXPORT KRTAPI krotPaint (
 KRTHANDLE Handle,
 long crzIndx,
 HWND hWnd,
 long start,
 long forceReadData,
 long drawMode
) {

T_TRACE *trc;
T_CRZSENS *crz;
long delta, dStart;
RECT r;
long pixelX, pixelY;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);
 
 // закешировать хендл окна и режим вывода
 crz->pic = hWnd;
 crz->drawMode = drawMode;

  // определить размеры окна отображения в пикселах
 GetClientRect(hWnd, &r);
 pixelX = r.right - r.left;
 pixelY = r.bottom - r.top;

////////////// debug
#ifdef LOG_1
 sprintf(
  LogString, 
  "krotPaint cIndx: %ld, %ld -> %ldx%ld , start %ld", crzIndx, crz->pageDat, pixelX, pixelY, start
 );
 Log();
#endif

 if ((pixelX != crz->pixelX) || (pixelY != crz->pixelY)) { 
  sprintf(lastError, "Saved %ld:%ld not equal current %ld:%ld", crz->pixelX, crz->pixelY, pixelX, pixelY);
  return KRT_ERR;
 }

 delta = (start - crz->oldPos);

 // если фильтр включен, то нужно полное формирование буфера данных
 if (crz->vbFilter.active > 0) {
   forceReadData = 1;
 }

 if (forceReadData || (abs(delta) >= (crz->pageDat * crz->step))) {
  // требуется безусловная перерисовка страницы или
  // прыжок в произвольное место -> полностью перерисовываем страницу
  if (readDataPage(trc, crzIndx, start)) return KRT_ERR;

 } else if ((abs(delta) > 0) && (abs(delta) < (crz->pageDat * crz->step)))  {
  // сдвиг в пределах страницы -> используем механизм скроллинга
  // начало недостающих данных
  dStart = (delta<0) ? start : (crz->oldPos + (crz->pageDat * crz->step));
  if (readDataShift(trc, crzIndx, dStart, delta)) return KRT_ERR;

 } else if (crz->needRedraw)  {
  fillBitmapPage(crz);
  SetBitmapBits(crz->bmp, crz->pixelX * crz->pixelY * bytesPerPixel, crz->bmpBuff);
 }
 else if (OldScaleMode != ScaleMode) {
  OldScaleMode = ScaleMode;
  fillBitmapPage(crz);
  SetBitmapBits(crz->bmp, crz->pixelX * crz->pixelY * bytesPerPixel, crz->bmpBuff);
 }

 showBmp(crz, hWnd);
 crz->needRedraw = 0;
 crz->oldPos = start;
 return KRT_OK;
}

/*
Функция заполняет сырыми и обработанными показаниями датчика sens буфера bufDat и bufRow
из текущей страницы данных. размеры буферов должны соответствовать размеру страницы.
*/
short EXPORT KRTAPI krotGetSingleSens (
 KRTHANDLE Handle,     // дескриптор прогона
 long      crzIndx, 
 long      sens,       // номер датчика
 KRTDATA  *bufDat,     // указатель на буфер обработанных данных
 KRTROW   *bufRow      // указатель на буфер сырых данных
) {
T_TRACE *trc;
T_CRZSENS *crz;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);

 memcpy(bufRow, crz->datPageBuff + (crz->pageDat * sens), crz->pageDat * sizeof(KRTROW));
 memcpy(bufDat, crz->dat0PageBuff + (crz->pageDat * sens), crz->pageDat * sizeof(KRTDATA));
 return KRT_OK;
}

/*
Функция определения показаний корозионного датчика
*/
short EXPORT KRTAPI krotGetVectSens (
  KRTHANDLE Handle,      // дескриптор прогона
  long      crzIndx,
  long      pos,         // позиция в мм.
  KRTDATA  *buf,         // указатель на буфер обработанных данных
  KRTROW   *row          // указатель на буфер сырых данных
) {
T_TRACE *trc;
T_CRZSENS *crz;
long dStart, sz, i;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);

 // если запрашиваемый вектор внутри текущего буфера экрана развертки
 if ((pos >= crz->oldPos) && (pos <= (crz->oldPos + (crz->pageDat * crz->step)))) {
  // заполнить вектор из буфера экрана, не дергая драйвер.
  dStart = (pos - crz->oldPos) / crz->step; // смещение запрашиваемого вектора в буфере экрана
  sz = crz->pageDat;
  for (i=0; i < crz->sNum; i++) {
   buf[i]    = crz->dat0PageBuff[sz*i+dStart];
   row[i]    = crz->datPageBuff[sz*i+dStart];
  }
 } else {
  // иначе запросить данные у драйвера
  dStart  = pos / crz->step;
  if (readData(trc, crzIndx, dStart, 1, buf, row)) {return KRT_ERR;}
 }

 return KRT_OK;
}

/* *************************************************************************
Функция заполняет буфер datBuff значениями показаний датчиков корозионной развертки
пояса crzIndx из записи Handle. Фрагмент развертки записи начинается с отметки xStart (мм)
и имеет длину xLength (мм).
При успехе  возвращает KRT_OK, KRT_ERR при ошибке.
Расширенное описание ошибки доступно через функцию krotError.
*/
short EXPORT KRTAPI krotCorozData (
 KRTHANDLE Handle, 
 long crzIndx, 
 long xStart,     // мм
 long xLength,    // мм
 KRTDATA *datBuff,
 KRTROW *rowBuff
) {
T_TRACE *trc;
T_CRZSENS *crz;
long i, j, y, ornt;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);

 // установить размер страницы, равный длине запрашиваемого фрагмента
 if ( makeDatBuff(crz, xLength / crz->step, "krotCorozData") ) return KRT_ERR;
 // считать данные в буфер страницы
 if (readData(trc, crzIndx, xStart / crz->step, crz->pageDat, crz->dat0PageBuff, crz->datPageBuff)) return 1;
 // перевести вектор ориентации из сотых долей градуса в номера датчиков
 degree2sens(crz->datPageOrnt, crz->pageDat, crz->sNum);

 // странслировать страницу во внешний буфер с учетом ориентации
 for (i=0; i<crz->pageDat; i++) {
  ornt = crz->datPageOrnt[i];
  for (j=0; j<crz->sNum; j++) {
   y = ornt + j;
   y = (y < crz->sNum) ? y : crz->sNum - y;
   datBuff[crz->pageDat * j + i] = crz->dat0PageBuff[crz->pageDat * y + i];
   rowBuff[crz->pageDat * j + i] = crz->datPageBuff[crz->pageDat * y + i];
  }
 }
 return KRT_OK;
}

/*
Функция проверяет соответствие размера буфера страницы данных размеру xSize и при
необходимости увеличивает буфер страницы данных.
*/
short makeDatBuff(T_CRZSENS *crz, long xSize, char *callStack) {

////////////// debug
#ifndef LOG_1
 (void) callStack;
#endif

 // если запрошенный размер страницы превышает максимальный размер по X
 // текущих буферов, то необходимо увеличить буфера
 if (crz->maxDatPage < xSize) {
  if (!(
   allocMem(xSize * crz->sNum * sizeof(KRTROW), (void**) &(crz->datScrlBuff),  "Буфер сырых данных скроллинга") &
   allocMem(xSize * sizeof(long),               (void**) &(crz->datScrlOrnt),  "Буфер ориентации скроллинга") &
   allocMem(xSize * crz->sNum * sizeof(KRTROW), (void**) &(crz->datPageBuff),  "Буфер сырых данных страницы") &
   allocMem(xSize * sizeof(long),               (void**) &(crz->datPageOrnt),  "Буфер ориентации страницы") &
   allocMem(xSize * crz->sNum * sizeof(KRTDATA), (void**) &(crz->dat0ScrlBuff), "Буфер обработанных данных скроллинга") &
   allocMem(xSize * crz->sNum * sizeof(KRTDATA), (void**) &(crz->dat0PageBuff), "Буфер обработанных данных страницы")
   )) {
   return 1;
  }
  // новый максимальный размер страницы данных по X для текущего сеанса.
  crz->maxDatPage = xSize;
 }

////////////// debug
#ifdef LOG_1
 sprintf(
  LogString, 
  "pageDat %ld -> %ld %s -> %s(%ld, %ld)", crz->pageDat, xSize, callStack, "makeDatBuff", crz->index, xSize
 );
 Log();
#endif

 crz->pageDat = xSize;
 return 0;
}

/*
Функция проверяет соответствие размера буфера битмапа страницы размерам pixelX и pixelY и при
необходимости увеличивает буфер битмапа страницы.
*/
short makeBmpBuff(T_CRZSENS *crz, long pixelX, long pixelY) {
long arrSize;

 // при необходимости перераспределить буфер битмапа
 arrSize = pixelX * pixelY;
 if (crz->maxBmpSize < arrSize) {
  if (crz->bmpBuff) { free(crz->bmpBuff); }
  if (crz->bmpBuffScroll) { free(crz->bmpBuffScroll); }
  crz->maxBmpSize = 0L;
  crz->bmpBuff = (void *) malloc(arrSize * bytesPerPixel);
  crz->bmpBuffScroll = (void *) malloc(arrSize * bytesPerPixel);
  if ((crz->bmpBuff == NULL) || (crz->bmpBuff == NULL)) {
   sprintf (
    lastError, 
    "Не достаточно памяти для буффера битмапа (%ld байт)", 
    arrSize * bytesPerPixel
           );
   return 1;
  }
  // новый максимальный размер буфера битмапа в пикселах
  crz->maxBmpSize = arrSize;
 }

 return 0;
}

/*
Функция пересоздает битмап страницы, если его размеры не сответствуют размерам pixelX и pixelY
*/
short makeBitmap(T_CRZSENS *crz, HWND hWnd, long pixelX, long pixelY) {
HDC hdcDest;

 // при необходимости переопределить битмап страницы
 if ((crz->pixelX != pixelX) || (crz->pixelY != pixelY)) {

  if (crz->bmp) { DeleteObject(crz->bmp); } 
  // Количество пикселов в строке клиентской части экрана развертки
  // всегда четное, это контролируется vb-шной программой.
  // Поэтому не надо заморачиваться обеспечением требования к последнему
  // аргументу функции CreateBitmap :
  // "Each scan line in the rectangle must be word aligned 
  // (scan lines that are not word aligned must be padded with zeros)."
  hdcDest = GetDC(hWnd);
  crz->bmp = CreateCompatibleBitmap(hdcDest, pixelX, pixelY);
  ReleaseDC(hWnd, hdcDest);

  if (crz->bmp == NULL) {
   sprintf(lastError, "Ошибка при создании битмапа экрана");
   return 1;
  }
 }

 return 0;
}

/* *************************************************************************
Функция вызывается при вертикальном скроллинге окна отрисовки развертки пояса crzIndx.
Формирует новый битмап для заданного пояса развертки.
При успехе  возвращает KRT_OK, KRT_ERR при ошибке.
Расширенное описание ошибки доступно через функцию krotError.
*/
short EXPORT KRTAPI krotTopSens (
 KRTHANDLE Handle,
 long crzIndx,
 long topSens) {

T_TRACE *trc;
T_CRZSENS *crz;
long lineLen, shift, i, lineIndex;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);

 if (topSens == crz->topSens) return KRT_OK;

 if (crz->pixelY == 0) {
  crz->topSens = topSens;
  return KRT_OK;
 }
 
 shift = krtScaleY(topSens, crz) - krtScaleY(crz->topSens, crz);
 if (shift == 0) return KRT_OK;
 if (shift<0) { shift += crz->pixelY; }

 lineLen = crz->pixelX * bytesPerPixel;

 for (i = 0; i < crz->pixelY; i ++) {
  lineIndex = shift + i;
  lineIndex = lineIndex < crz->pixelY ? lineIndex : lineIndex - crz->pixelY ;
  memcpy((BYTE *) crz->bmpBuffScroll + (i * lineLen), (BYTE *) crz->bmpBuff + (lineIndex * lineLen), lineLen);
 }

 memcpy((BYTE *) crz->bmpBuff, (BYTE *) crz->bmpBuffScroll, lineLen* crz->pixelY);
 crz->topSens = topSens;
 SetBitmapBits(crz->bmp, crz->pixelX * crz->pixelY * bytesPerPixel, crz->bmpBuff);
 return KRT_OK;
}

/*
Функция отрабатывает увеличение размера картинки развертки пояса crz, 
увеличивая размер страницы данных, подчитывая недостающие данные, 
увеличивая размер буфера битмапа и добавляя в него подчитанные данные
*/
short increasePage(T_TRACE *trc, T_CRZSENS *crz, long delta, char *callStack) {
long oldSizeDat, oldSizeBmp, i, j1, j2, j3, lineIndex;
long oldPage, newPage, lineLenDat, lineLenRow, lineAddDat, lineAddRow;
long newPixelX, dltPixelX;

char calltrace[10000];

 sprintf(calltrace, "%s -> %s", callStack, "increasePage");


 oldSizeDat = crz->maxDatPage;
 if (makeDatBuff(crz, crz->pageDat + delta, calltrace)) return 1;
 oldSizeBmp = crz->maxBmpSize;
 dltPixelX = krtScaleX(delta, trc->scaleX);
 newPixelX = crz->pixelX + dltPixelX;
 if (makeBmpBuff(crz, newPixelX, crz->pixelY)) return 1;

 if (oldSizeDat != crz->maxDatPage) {

  return readDataPage(trc, crz->index, crz->oldPos);

 } else {

  oldPage = crz->pageDat - delta;
  newPage = crz->pageDat;
  lineLenDat = oldPage * sizeof(KRTDATA);
  lineLenRow = oldPage * sizeof(KRTROW); 
  lineAddDat = delta * sizeof(KRTDATA);
  lineAddRow = delta * sizeof(KRTROW); 

  //подчитать недостающие данные
  if (readData(trc, crz->index, crz->oldPos / crz->step + crz->pageDat - delta, delta, crz->dat0ScrlBuff, crz->datScrlBuff)) return 1;
  //degree2sens(crz->datScrlOrnt, delta, crz->sNum);
  // реорганизовать страницу данных 
  for (i=1; i<crz->sNum; i++) {

   // начинаем с конца, чтобы не затереть имеющиеся данные
   lineIndex = crz->sNum - i;
   j1= lineIndex * oldPage;
   j2= lineIndex * newPage;
   j3= lineIndex * delta;

   memmove(crz->dat0PageBuff+j2, crz->dat0PageBuff+j1, lineLenDat);
   memcpy(crz->dat0PageBuff+j2+oldPage, crz->dat0ScrlBuff+j3, lineAddDat);

   memmove(crz->datPageBuff+j2,  crz->datPageBuff+j1,  lineLenRow);
   memcpy(crz->datPageBuff+j2+oldPage, crz->datScrlBuff+j3, lineAddRow);
  }
  // скопировать первую строку добавляемого буфера
  memcpy(crz->dat0PageBuff+oldPage, crz->dat0ScrlBuff, lineAddDat);
  memcpy(crz->datPageBuff+oldPage, crz->datScrlBuff, lineAddRow);

 }

 if (oldSizeBmp != crz->maxBmpSize) {

  fillBitmapPage(crz);

 } else {

  // реорганизовать буфер битмапа 
  oldPage = crz->pixelX * bytesPerPixel;
  newPage = newPixelX * bytesPerPixel;

  for (i=1; i < crz->pixelY; i++) {
   // начинаем с конца, чтобы не затереть имеющиеся данные
   lineIndex = crz->pixelY - i;
   j1= lineIndex * oldPage;
   j2= lineIndex * newPage;
   memmove(((BYTE *) crz->bmpBuff)+j2, ((BYTE *) crz->bmpBuff)+j1, oldPage);
  }

  // добавить туда вновь считанные данные
  krotStretchBlt (
   crz, 
   crz->dat0ScrlBuff,
   crz->vbScreen.orntOff ? NULL : crz->datScrlOrnt,
   delta,
   crz->sNum - crz->hide,
   crz->bmpBuff,
   crz->bmpBuffScroll,
   crz->pic,
   crz->bmp,
   newPixelX,
   crz->pixelY,
   crz->pixelX,
   newPixelX,
   crz->topSens,
   &(crz->pal), 0 );
 }

 return 0;
}

/*
Функция отрабатывает уменьшение размера картинки развертки пояса crz, 
уменьшая размеры страницы данных и буфера битмапа. 
реорганизует страницу данных и буфер битмапа.
*/
short decreasePage(T_TRACE *trc, T_CRZSENS *crz, long delta) {
long i, j1, j2, pageY, lineLenDat, lineLenRow, oldPage, newPage;
long newPixelX, dltPixelX;

 // буфера данных
 pageY = crz->sNum;
 oldPage = crz->pageDat;
 newPage = crz->pageDat - delta;
 lineLenDat = oldPage * sizeof(KRTDATA);
 lineLenRow = oldPage * sizeof(KRTROW); 

 for (i=1; i<pageY; i++) {
  j1= i * oldPage;
  j2= i * newPage;
  memmove(crz->dat0PageBuff+j2, crz->dat0PageBuff+j1, lineLenDat);
  memmove(crz->datPageBuff+j2,  crz->datPageBuff+j1,  lineLenRow);
 }

 // буфер битмапа
 pageY = crz->pixelY;
 dltPixelX = krtScaleX(delta, trc->scaleX);
 newPixelX = crz->pixelX - dltPixelX;

 oldPage = crz->pixelX * bytesPerPixel;
 newPage = newPixelX * bytesPerPixel;

 for (i=1; i<pageY; i++) {
  j1= i * oldPage;
  j2= i * newPage;
  memmove((BYTE *) crz->bmpBuff+j2, (BYTE *) crz->bmpBuff+j1, newPage);
 }

////////////// debug
#ifdef LOG_1
 sprintf(
  LogString, 
  "pageDat %ld -> %ld %s(%ld, %ld)", crz->pageDat, crz->pageDat - delta, "decreasePage", crz->index, delta
 );
 Log();
#endif

 crz->pageDat = crz->pageDat - delta;
 return 0;
}

/*
Функция реорганизует страницу данных пояса crz в соответствии с новым масштабом по x scale
При необходимости подчитывает недостающие данные.
Заново формирует буфер битмапа страницы.
*/
short changePage(T_TRACE *trc, T_CRZSENS *crz, long scale) {
long newPageDat, oldSizeDat, oldMaxDat, delta, i, j1, j2, j3, lineLenDat, lineLenRow, lineAddDat, lineAddRow, lineIndex;

 trc->scaleX = scale;
 newPageDat = krtScaleXback(crz->pixelX, scale);
 if (newPageDat == crz->pageDat) return 0;

 if (newPageDat < crz->pageDat) {

  // реорганизовать буфер данных с учетом его уменьшения

  lineLenDat = newPageDat * sizeof(KRTDATA);
  lineLenRow = newPageDat * sizeof(KRTROW); 

  for (i=1; i<crz->sNum; i++) {
   j1= i * crz->pageDat;
   j2= i * newPageDat;
   memmove(crz->dat0PageBuff+j2, crz->dat0PageBuff+j1, lineLenDat);
   memmove(crz->datPageBuff+j2,  crz->datPageBuff+j1,  lineLenRow);
  }

////////////// debug
#ifdef LOG_1
 sprintf(
  LogString, 
  "pageDat %ld -> %ld %s(%ld, %ld)", crz->pageDat, newPageDat, "changePage", crz->index, scale
 );
 Log();
#endif

  crz->pageDat = newPageDat;

 } else {

  oldSizeDat = crz->pageDat;
  oldMaxDat = crz->maxDatPage;
  if (makeDatBuff(crz, newPageDat, "changePage")) return 1;

  if (oldMaxDat != crz->maxDatPage) {

   return readDataPage(trc, crz->index, crz->oldPos);

  } else {

   // реорганизовать буфер данных с учетом его увеличения
   delta = crz->pageDat - oldSizeDat;
   lineLenDat = oldSizeDat * sizeof(KRTDATA);
   lineLenRow = oldSizeDat * sizeof(KRTROW); 
   lineAddDat = delta * sizeof(KRTDATA);
   lineAddRow = delta * sizeof(KRTROW); 

   //подчитать недостающие данные
   if (readData(trc, crz->index, crz->oldPos / crz->step + oldSizeDat, crz->pageDat - oldSizeDat, crz->dat0ScrlBuff, crz->datScrlBuff)) return 1;
   //degree2sens(crz->datScrlOrnt, delta, crz->sNum);
   // реорганизовать страницу данных 
   for (i=1; i<crz->sNum; i++) {
    // начинаем с конца, чтобы не затереть имеющиеся данные
    lineIndex = crz->sNum - i;
    j1= lineIndex * oldSizeDat;
    j2= lineIndex * crz->pageDat;
    j3= lineIndex * delta;

    memmove(crz->dat0PageBuff+j2, crz->dat0PageBuff+j1, lineLenDat);
    memcpy(crz->dat0PageBuff+j2+oldSizeDat, crz->dat0ScrlBuff+j3, lineAddDat);

    memmove(crz->datPageBuff+j2,  crz->datPageBuff+j1,  lineLenRow);
    memcpy(crz->datPageBuff+j2+oldSizeDat, crz->datScrlBuff+j3, lineAddRow);
   }
   // скопировать первую строку добавляемого буфера
   memcpy(crz->dat0PageBuff+oldSizeDat, crz->dat0ScrlBuff, lineAddDat);
   memcpy(crz->datPageBuff+oldSizeDat, crz->datScrlBuff, lineAddRow);

  }

 }

 // актуализировать битмап страницы
 fillBitmapPage(crz);
 SetBitmapBits(crz->bmp, crz->pixelX * crz->pixelY * bytesPerPixel, crz->bmpBuff);
 return 0;
}

/* *************************************************************************
Функция вызывается при изменении горизонтального масштаба развертки.
Формирует актуальные страницы данных и битмапы для всех поясов развертки.
При успехе  возвращает KRT_OK, KRT_ERR при ошибке.
Расширенное описание ошибки доступно через функцию krotError.
*/
short EXPORT KRTAPI krotPageScale (
 KRTHANDLE Handle,
 long scale) {

T_TRACE *trc;
long i;

////////////// debug
#ifdef LOG_1
long dbgOldScale, dbgOldPage;
#endif

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;

 
////////////// debug
#ifdef LOG_1
 dbgOldPage = trc->crz[0].pageDat;
 dbgOldScale = trc->scaleX;
#endif

 for (i=0; i < trc->record.sensGroups; i++) {
  if (changePage(trc, &(trc->crz[i]), scale)) return KRT_ERR;
 }

////////////// debug
#ifdef LOG_1
 sprintf(
  LogString, 
  "krotPageScale %ld -> %ld page: (%ld -> %ld)", dbgOldScale, trc->scaleX, dbgOldPage, trc->crz[0].pageDat
 );
 Log();
#endif

 return KRT_OK;
}

/* *************************************************************************
Функция вызывается при изменении размеров окна отрисовки развертки пояса crzIndx.
Формирует актуальную страницу данных и битмап для заданного пояса развертки.
При успехе  возвращает KRT_OK, KRT_ERR при ошибке.
Расширенное описание ошибки доступно через функцию krotError.
*/
short EXPORT KRTAPI krotChangePic (
 KRTHANDLE Handle,
 long crzIndx,
 HWND hWnd) {

T_TRACE *trc;
T_CRZSENS *crz;
RECT r;
long pixelX, pixelY, shift, ret;

////////////// debug
#ifdef LOG_1
long dbgOldPixelX, dbgOldPixelY, dbgOldPage;
#endif


 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);

////////////// debug
#ifdef LOG_1
 dbgOldPixelX = crz->pixelX;
 dbgOldPixelY = crz->pixelY;
 dbgOldPage = crz->pageDat;
#endif

 // определить размеры окна отображения в пикселах
 GetClientRect(hWnd, &r);
 pixelX = r.right - r.left;
 pixelY = r.bottom - r.top;

 if (pixelX == crz->pixelX) {

  if (pixelY == crz->pixelY) { 
	  
	  return KRT_OK;

  } else {

   if (makeBmpBuff(crz, pixelX, pixelY) || makeBitmap(crz, hWnd, pixelX, pixelY)) return KRT_ERR;
   crz->pixelX = pixelX;
   crz->pixelY = pixelY;
   fillBitmapPage(crz);

  }

 } else {

  if (crz->pixelX > 0) {

   shift = krtScaleXback(pixelX, trc->scaleX) - krtScaleXback(crz->pixelX, trc->scaleX);
   if (makeBitmap(crz, hWnd, pixelX, pixelY)) return KRT_ERR;
   ret = (shift<0) ? decreasePage(trc, crz, -shift) : increasePage(trc, crz, shift, "krotChangePic");
   if (ret) return KRT_ERR;
   crz->pixelX = pixelX;
   crz->pixelY = pixelY;

  } else {

   shift = krtScaleXback(pixelX, trc->scaleX);
   if (makeDatBuff(crz, shift, "krotChangePic")) return KRT_ERR;
   if (makeBmpBuff(crz, pixelX, pixelY)) return KRT_ERR;
   if (makeBitmap(crz, hWnd, pixelX, pixelY)) return KRT_ERR;
   crz->pixelY = pixelY;
   crz->pixelX = pixelX;
   if (readDataPage(trc, crz->index, crz->oldPos)) return KRT_ERR;
   return KRT_OK;

  }

 }

////////////// debug
#ifdef LOG_1
 sprintf(
  LogString, 
  "krotChangePic crzIndx %ld bmp %ldx%ld -> %ldx%ld page: %ld -> %ld", 
   crzIndx, 
   dbgOldPixelX,
   dbgOldPixelY,
   crz->pixelX,
   crz->pixelY,
   dbgOldPage, 
   crz->pageDat
 );
 Log();
#endif

 SetBitmapBits(crz->bmp, crz->pixelX * crz->pixelY * bytesPerPixel, crz->bmpBuff);
 return KRT_OK;
}

/* *************************************************************************
Функция вызывается при изменении параметров фильтров отрисовки развертки.
Вносит изменения во внутренние структуры прогона.
При успехе  возвращает KRT_OK, KRT_ERR при ошибке.
Расширенное описание ошибки доступно через функцию krotError.
*/
short EXPORT KRTAPI krotScreenFilter (
 KRTHANDLE Handle, 
 long crzIndx, 
 VB_FILTER_INFO *vbFilter
) {
T_TRACE *trc;
T_CRZSENS *crz;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);

 // сохранить переданные из VB параметры
 crz->vbFilter = *vbFilter;
 // выставить флаг безусловной перерисовки изображения
 crz->needRedraw = 1;

 return KRT_OK;
}


/*
Функция вызывается при вызове krotScreenMode (запомнить срез базовой линии выравнивания)
аналог switch_filters(T_TRACE *trc, long crzIndx), но для собственного левого буфера,
а не для реальной развертки
*/
void base_switch_filters(T_TRACE *trc, long crzIndx,
                         long xSize, KRTDATA* data_tmp, KRTROW* rowData_tmp, long* tmp_orient)
{
 T_CRZSENS *crz = &(trc->crz[crzIndx]);

/*
      {  // ------ DEBUG ------ DEBUG ------ DEBUG ------ DEBUG ------
          char tmp_info[10240];

          sprintf (tmp_info, "crz->vbFilter.active = %ld\n", crz->vbFilter.active);
          MessageBox(NULL, (LPCSTR)tmp_info, (LPCSTR)"2", MB_OK | MB_ICONERROR);
      } // ------ DEBUG ------ DEBUG ------ DEBUG ------ DEBUG ------
*/

     switch (crz->vbFilter.active) {

       case 1: // cheshka
           fltExponent (
               data_tmp, // указатель на массив обработанных данных страницы развертки
               rowData_tmp,  // указатель на буфер сырых данных для страницы
               tmp_orient,  // указатель на вектор ориентации страничного буфера
               xSize,      // размер массива по X
               crz->sNum,         // размер массива по Y (количество датчиков)

    //           crz->sensor,     // указатель на вектор настроек датчиков. для доступа к элементам базовой линии: crz->sensor[i].delta

               14, // весовой коэффициэнт фильтра (значения от 0 до 100)
               10  // параметр усиления фильтра (значения от 1 до 100)
           );
    /*     fltUnweld(
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum, 
           crz->vbFilter.unweldParam
         );
    */
         break;

       case 2: // tselnotyanutaya
         fltRolled(
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum, 
           crz->vbFilter.rolledParam1, 
           crz->vbFilter.rolledParam2,
           crz->vbFilter.rolledAmplifer
         );
         break;

       case 3: // prigruz
         fltPrigruz(
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum
         );
         break;

       case 4: // prodol treschiny
         fltPoligon(
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum, 
           crz->vbFilter.tfiParam1, 
           crz->vbFilter.tfiParam2,
           crz->vbFilter.tfiBase
         );
         break;

       case 5: // no mathematic
         fltNo_math(
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum,
           crz->sensor
         );
         break;

       case 6: // фильтр к центру //2021 // volosok
    //     flt_k_tsentru_plus_poperek (
         flt_filament(
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum,
           crz->sensor,
           crz->vbFilter.unweldParam,
           crz->vbFilter.tfiParam1,
           crz->vbFilter.tfiParam2
         );
         break;

       case 7: //фильтр от центра // Фильтр 2019
         flt_ot_tsentra_plus_poperek (
//         flt_Filter2019(
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum,
           crz->sensor,
           crz->vbFilter.unweldParam
         );
         break;

       case 8: // Свертка 1 // Лапласиан
         flt_convolution_1(
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum,
           crz->sensor,
           crz->vbFilter.unweldParam
         );
         break;

       case 9: // Свертка 2 // Резкость
         flt_Skolz_plus_poperek( // скользящее среднее вдоль потом поперек
    //     flt_Cut_big_small( // заменен на обрезание больших и отрицательных значений
    //     flt_convolution_2(
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum,
           crz->sensor,
           crz->vbFilter.unweldParam
         );
         break;

       case 10: // медианное усредние
    //     flt_MHAT ( // MHAT свертка одномерная на каждый датчик
         fltMedianFullScreen ( // медианное усреднение
    //     flt_convolution_3( // Свертка 3 размытие двухмерная
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum,
           100,
           crz->vbFilter.unweldParam,
           crz->vbFilter.tfiParam1,
           crz->vbFilter.tfiParam2
         );
         break;

       case 11: // фильтр ХЗ
         flt_Cut_big_small(
           data_tmp, 
           rowData_tmp, 
           tmp_orient, 
           xSize, 
           crz->sNum, 
           crz->vbFilter.rolledParam1, 
           crz->vbFilter.rolledParam2,
           crz->vbFilter.rolledAmplifer
         );
         break;
     } // switch (crz->vbFilter.active) {
} // void base_switch_filters(T_TRACE *trc, long crzIndx)



/* *************************************************************************
Функция вызывается при изменении параметров отрисовки развертки.
Вносит изменения во внутренние структуры прогона.
При успехе  возвращает KRT_OK, KRT_ERR при ошибке.
Расширенное описание ошибки доступно через функцию krotError.
*/
short EXPORT KRTAPI krotScreenMode (
 KRTHANDLE Handle, 
 long crzIndx, 
 long *sens,         
 VB_PAINT_INFO *vbScreen,
 VB_GRAPH_INFO *vbGraphs
) {

T_TRACE *trc;
T_PAL *pal;
T_CRZSENS *crz;
long i, back;

// временные буфера для запроса развертки под данные базовой линии
#define LENGTH_FOR_LOAD_DATA 512

KRTDATA* data_tmp;
KRTROW *rowData_tmp;
long tmp_orient[LENGTH_FOR_LOAD_DATA];
long xDataSize = LENGTH_FOR_LOAD_DATA;

 trc = TraceList(Handle);
 if (trc == NULL) return KRT_ERR;
 crz = &(trc->crz[crzIndx]);

 pal = &(crz->pal);

 // установить режим датчиков
 if (sens) {
  crz->hide = 0;
  for (i=0; i < crz->sNum; i++) { 
   crz->sensor[i].mode = sens[i]; 
   if (sens[i] == SMODE_DELETE) { crz->hide++; }
  }
 }

 // настроить базовую линию
 if (vbScreen->baseLine < 0) {

////////////// debug
#ifdef LOG_BASE_LINE
 sprintf(
  LogString, 
  "Clear bl for %ld sensors", 
   crz->sNum
 );
 Log();
#endif

  for (i=0; i < crz->sNum; i++) {
    crz->sensor[i].delta = 0;
    crz->sensor[i].value = 0;
  }

 } else {

  if (vbScreen->baseLine != crz->vbScreen.baseLine) {

////////////// debug
#ifdef LOG_BASE_LINE
 sprintf(
  LogString, 
  "Set bl at dist %ld mm (%ld step)", 
   vbScreen->baseLine,
   vbScreen->baseLine / crz->step
 );
 Log();
#endif

/*
      {  // ------ DEBUG ------ DEBUG ------ DEBUG ------ DEBUG ------
          char tmp_info[10240];

          sprintf(
           tmp_info, 
           "Set bl at dist %ld mm (%ld step)", 
            vbScreen->baseLine,
            vbScreen->baseLine / crz->step
          );
          MessageBox(NULL, (LPCSTR)tmp_info, (LPCSTR)"2", MB_OK | MB_ICONERROR);
      } // ------ DEBUG ------ DEBUG ------ DEBUG ------ DEBUG ------
*/

       data_tmp   = (KRTDATA *) malloc(xDataSize * crz->sNum * sizeof(KRTDATA));
       rowData_tmp = (KRTROW *) malloc(xDataSize * crz->sNum * sizeof(KRTROW));

       if (readData(trc, crzIndx, vbScreen->baseLine / crz->step, xDataSize, data_tmp, rowData_tmp)) return KRT_ERR;

       base_switch_filters(trc, crzIndx, xDataSize, data_tmp, rowData_tmp, tmp_orient);


       back = KRT_PALLETE_SIZE / 2;
       for (i=0; i < crz->sNum; i++) { 
          crz->sensor[i].delta = back - data_tmp[i*xDataSize]; 
          crz->sensor[i].value = rowData_tmp[i*xDataSize]; 

////////////// debug
#ifdef LOG_BASE_LINE
 sprintf(
  LogString, 
  "[%ld] = %ld -> %ld", 
   i,
   crz->dat0ScrlBuff[i],
   crz->sensor[i].delta
 );
 Log();
#endif

      }

      free(data_tmp);
      free(rowData_tmp);
  }

 }
 
 // сохранить переданные из VB параметры
 crz->vbScreen  = *vbScreen;
 crz->vbGraphs = *vbGraphs;

 // выставить флаг безусловной перерисовки изображения
 crz->needRedraw = 1;

 return KRT_OK;
} // short EXPORT KRTAPI krotScreenMode (

/*
Функция задает тип прореживания точек при изменении масштаба изображения
i = 0 - выбирается максимальное значение
i = 1 - выбирается минимальное значение
i = 2 - выбирается среднее значение
i = 3 - выбирается первое попавшееся значение

*/
void EXPORT KRTAPI SetScaleMode (short i)
{
	ScaleMode = i;
}

/*
Функция возвращает тип используемого масштабирования
*/
short EXPORT KRTAPI GetScaleMode ()
{
	return ScaleMode;
}

#include "draw_my.c"
