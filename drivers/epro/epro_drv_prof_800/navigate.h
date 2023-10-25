// navigat.h - заголовок  для модуля navigate.c.
// Объявление констант, данных и инструментальных функций работы с навигацией
// при просмотре данных електронного блока "epro" программой KrotW32
//

#ifndef _NAVIGATE_H_
#define _NAVIGATE_H_

#define VOG_FILE_KEY          "VogNav"
#define NAVIGATION_FILE_KEY   "VogMat"
#define VOG_KOEFF_UMN         100
#define ACCEL_KOEFF_UMN       1000

#define PI  3.14159265359

#pragma warning(disable : 4996) // for VC 8.00

  // отключим всякое выравнивание для данных читаемых из файлов
#pragma pack (1)  

typedef struct {   // структура навигационных данных (Rec.mat)
   long  Time;
   long  Dist;

   float VogX;
   float VogY;
   float VogZ;

   float AccelX;
   float AccelY;
   float AccelZ;
} T_NAVIGATION_RECORD;

typedef struct {   // структура воговских данных (Rec.vog)
   long  Time;
   long  Dist;

   long VogX;  // ордината, см
   long VogY;  // аппликата, см
   long VogZ;  // абсцисса, см

   float Psi;   // азимут, рад
   float Teta;  // тангаж, рад
   float Gamma; // крен, рад
} T_VOG_RECORD;

#pragma pack ()
  // Возвращаемся к выравниванию по умолчанию


typedef struct {   // структура навигационных данных (Rec.mat)
   char  file_name[_MAX_FNAME];  // имя файла навигационных данных
   FILE *file_data;              // открытый файл навигационных данных
   long  lengt_file_in_nav_rec;  // количество навигационных данных в файле

   long  cur_pos;     // позиция текущих данных в файле
   long  left_pos;    // позиция левой границы отрезка поиска данных в файле
   long  right_pos;   // позиция правой границы отрезка поиска данных в файле

   T_NAVIGATION_RECORD cur_data;   // текущие данных
   T_NAVIGATION_RECORD left_data;  // данные левой границы отрезка поиска
   T_NAVIGATION_RECORD right_data; // данные правой границы отрезка поиска

} T_NAVIGATION_DATA;

typedef struct {   // структура навигационных данных (Rec.mat)
   char  file_name[_MAX_FNAME];  // имя файла навигационных данных
   FILE *file_data;              // открытый файл навигационных данных
   long  lengt_file_in_nav_rec;  // количество навигационных данных в файле

   long  cur_pos;     // позиция текущих данных в файле
   long  left_pos;    // позиция левой границы отрезка поиска данных в файле
   long  right_pos;   // позиция правой границы отрезка поиска данных в файле

   T_VOG_RECORD cur_data;   // текущие данных
   T_VOG_RECORD left_data;  // данные левой границы отрезка поиска
   T_VOG_RECORD right_data; // данные правой границы отрезка поиска

} T_VOG_DATA;

extern char drvError[];

 // вычисляем и читаем нужную запись из rec.mat
extern long WINAPI GetNavData(long start, T_NAVIGATION_DATA *NavData);

 // вычисляем и читаем нужную запись из rec.vog
extern long WINAPI GetVogData(long start, T_VOG_DATA *VogData);


extern long get_orient_from_VOG(long start,
                                T_VOG_DATA *VogData,
                                long num_sens);

extern long get_orient_from_NAV(long start,
                                T_NAVIGATION_DATA *NavData,
                                long num_sens);
#endif