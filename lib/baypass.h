
#ifndef _BAYPASS_H_
#define _BAYPASS_H_


#define PI  3.14159265359

  // отключим вс€кое выравнивание дл€ данных читаемых из файлов
#pragma pack (1)

typedef struct {
   short abs_pressure;
   short diff_pressure;
   short speed;                            
   signed char motor_state;                      
   byte board_state;                      
   byte choke_curr_position_ticks;        
   byte choke_curr_position_angle;        
   signed char choke_position;                   
   short motor_battary_current;            
   byte motor_battary_voltage;            
   byte chek_sum;                            

   long Odometr;

} T_BYPASS_IDX;

// ¬озвращаемс€ к выравниванию по умолчанию
#pragma pack ()

typedef struct {
   char  file_name[_MAX_FNAME];  // им€ файла BP данных
   FILE *file_data;              // открытый файл BP данных
   long  lengt_file_in_BP_rec;  // количество BP данных в файле

   long  cur_pos;     // позици€ текущих данных в файле
   long  left_pos;    // позици€ левой границы отрезка поиска данных в файле
   long  right_pos;   // позици€ правой границы отрезка поиска данных в файле

   T_BYPASS_IDX cur_data;   // текущие данных
   T_BYPASS_IDX left_data;  // данные левой границы отрезка поиска
   T_BYPASS_IDX right_data; // данные правой границы отрезка поиска

} T_BP_DATA;

extern long Init_BPdata(T_BP_DATA *BPdata, char * work_path, char * trc, char drvError[]);
extern long Get_BPdata(long start, T_BP_DATA *BPdata, char drvError[]);

#endif

