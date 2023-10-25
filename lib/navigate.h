
#ifndef _NAVIGATE_H_
#define _NAVIGATE_H_


#define RecVog_KEY                   "RecVog"
#define RecMat_KEY                   "RecMat"

#define PI  3.14159265359

  // отключим всякое выравнивание для данных читаемых из файлов
#pragma pack (1)

typedef struct {   // структура навигационных данных (Rec.mat2)
   long  Time;
   long  Dist; // в Rec.mat2 размерность в мм !!!
               // в Rec.mat размерность в см !!!

   long OdometerTime; // отсутствует в Rec.mat
   long OdometerDist; // отсутствует в Rec.mat


   float VogX;
   float VogY;
   float VogZ;

   float AccelX;
   float AccelY;
   float AccelZ;
} T_NAVIGATION_RECORD;

typedef struct {   // структура воговских данных (Rec.vog)
   long  Time; // сантисекунды
   long  Dist;

   long VogX;  // ордината, см
   long VogY;  // аппликата, см
   long VogZ;  // абсцисса, см

   float Psi;   // азимут, рад
   float Teta;  // тангаж, рад
   float Gamma; // крен, рад
} T_VOG_RECORD;

// Возвращаемся к выравниванию по умолчанию
#pragma pack ()

#define REC_NAV   1
#define REC_NAV2  2

typedef struct {   // структура навигационных данных (Rec.mat)
   char  file_name[_MAX_FNAME];  // имя файла навигационных данных
   FILE *file_data;              // открытый файл навигационных данных
   long  lengt_file_in_nav_rec;  // количество навигационных данных в файле

   long nav_file_version;
   unsigned long  nav_rec_len;

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

extern long Init_VogData(T_VOG_DATA *VogData, char * work_path, char * trc, char drvError[]);
extern long Init_navigete(T_VOG_DATA *VogData, char * work_path, char * trc, T_TRACEINFO *inf, char drvError[]);
extern long GetVogData(long start, T_VOG_DATA *VogData, char drvError[]);
extern long Init_NavData(T_NAVIGATION_DATA *NavData, char * work_path, char * trc, char drvError[]);
extern long Serch_navigete(T_NAVIGATION_DATA *NavData, char * work_path, char * trc, char drvError[]);
extern long GetNavData(long start, T_NAVIGATION_DATA *NavData, char drvError[]);
extern long get_orient_from_VOG(long start, T_VOG_DATA *VogData, long num_sens);

#endif

