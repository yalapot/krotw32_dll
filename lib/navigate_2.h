
#ifndef _NAVIGATE_2_H_
#define _NAVIGATE_2_H_


  // отключим всякое выравнивание для данных читаемых из файлов
#pragma pack (1)

typedef struct {   // структура навигационных данных (Rec.mat2)
   long  Time;
   long  Dist; // размерность в мм !!!

   long OdometerTime;
   long OdometerDist;

   float VogX;
   float VogY;
   float VogZ;

   float AccelX;
   float AccelY;
   float AccelZ;

} T_NAVIGATION_RECORD_2;

// Возвращаемся к выравниванию по умолчанию
#pragma pack ()

typedef struct {   // структура навигационных данных (Rec.mat)
   char  file_name[_MAX_FNAME];  // имя файла навигационных данных
   FILE *file_data;              // открытый файл навигационных данных
   long  lengt_file_in_nav_rec;  // количество навигационных данных в файле

   long  cur_pos;     // позиция текущих данных в файле
   long  left_pos;    // позиция левой границы отрезка поиска данных в файле
   long  right_pos;   // позиция правой границы отрезка поиска данных в файле

   T_NAVIGATION_RECORD_2 cur_data;   // текущие данных
   T_NAVIGATION_RECORD_2 left_data;  // данные левой границы отрезка поиска
   T_NAVIGATION_RECORD_2 right_data; // данные правой границы отрезка поиска

} T_NAVIGATION_DATA_2;


extern long Init_NavData_2(T_NAVIGATION_DATA *NavData, char * work_path, char * trc, char drvError[]);
extern long Serch_navigete(T_NAVIGATION_DATA *NavData, char * work_path, char * trc, char drvError[]);
extern long GetNavData(long start, T_NAVIGATION_DATA *NavData, char drvError[]);

#endif
