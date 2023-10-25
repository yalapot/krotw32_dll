
#ifndef _height_arrow_H_
#define _height_arrow_H_


#define arrow_hd_KEY                   "arrow_hd"

  // отключим вс€кое выравнивание дл€ данных читаемых из файлов
#pragma pack (1)

typedef struct 
{
   char ver[8];
   int ver_n;
   char h_3diam[14];
   float h_3;
   char h_5diam[14];
   float h_5;
   char h_10diam[14];
   float h_10;
   char h_100diam[14];
   float h_100;
} T_arrow_file_head;

typedef struct { 
   float height;
   long  Dist;
} T_arrow_hd;

typedef struct { 
   char  file_name[_MAX_FNAME];  // им€ файла данных
   FILE *file_data;              // открытый файл данных
   long  lengt_file_in_nav_rec;  // количество записей данных в файле

   long  cur_pos;     // позици€ текущих данных в файле
   long  left_pos;    // позици€ левой границы отрезка поиска данных в файле
   long  right_pos;   // позици€ правой границы отрезка поиска данных в файле

   T_arrow_hd cur_data;   // текущие данных
   T_arrow_hd left_data;  // данные левой границы отрезка поиска
   T_arrow_hd right_data; // данные правой границы отрезка поиска

} T_arrow_DATA;


// ¬озвращаемс€ к выравниванию по умолчанию
#pragma pack ()


extern long Init_arrow_hd_Data(char * trc);//, char drvError[]);
extern long Get_arrow_hd_Data(long start, T_arrow_hd *arrow_hd);//, char drvError[]);
extern T_arrow_DATA * arrowData;

#endif

