
#ifndef _bending_plane_H_
#define _bending_plane_H_


#define bending_plane_KEY                   "bending_plane"

  // отключим всякое выравнивание для данных читаемых из файлов
#pragma pack (1)

typedef struct 
{
    // Расстояние от передней манжеты до датчиков, мм
    long L0;
    // Расстояние от задней манжеты до датчиков, мм
    long L1;
    // Диаметр трубопровода, мм
    long D;
    // Предельное значение, превышение которого не подлежит анализу
    float LimR;
    // Поправка к предельному значению, превышение которой приравнивается к значению
    float dLimR;
} T_bending_plane_file_head;

typedef struct { 
    // Дистанция, м
    float Dist;
    // Радиус, D
    float Radius;
    // Угол плоскости изгиба, ч
    float Angle;
} T_bending_plane;

typedef struct {
   char  file_name[_MAX_FNAME];  // имя файла данных
   FILE *file_data;              // открытый файл данных
   long  lengt_file_in_nav_rec;  // количество записей в файле

   long  cur_pos;     // позиция текущих данных в файле
   long  left_pos;    // позиция левой границы отрезка поиска данных в файле
   long  right_pos;   // позиция правой границы отрезка поиска данных в файле

   T_bending_plane cur_data;   // текущие данных
   T_bending_plane left_data;  // данные левой границы отрезка поиска
   T_bending_plane right_data; // данные правой границы отрезка поиска

} T_bending_plane_DATA;


// Возвращаемся к выравниванию по умолчанию
#pragma pack ()


extern long Init_bending_plane_Data(char * trc);//, char drvError[]);
extern long Get_bending_plane_Data(long start, T_bending_plane *bending_plane);//, char drvError[]);
extern T_bending_plane_DATA * bending_plane_data;

#endif

