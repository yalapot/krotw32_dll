#include <windows.h>
#include <stdio.h>
#include <stdlib.h>


#include "krtapi.h"

#define MAX_TRACE       8

#define MAX_GROUP_NUM   1   // максимально возможное кол-во поясов для данного драйвера                  

  // отключим всякое выравнивание для данных читаемых из файлов
#pragma pack (1)

typedef struct T_BYPASS_HEADER {
    unsigned char file_format_id;  // Зарезервировано
    unsigned char Block_id; // идентификация модуля
    char id_str[24];//текстовая строка
    unsigned char reserv1; // Зарезервировано
    unsigned char reserv2; // Зарезервировано
    unsigned char reserv3; // Зарезервировано
    unsigned char reserv4; // Зарезервировано
    unsigned char reserv5; // Зарезервировано
    unsigned char reserv6; // Зарезервировано
};


typedef struct T_BYPASS_INFO {
    unsigned long Odometr;//общий путь
    unsigned long odom_forward_direction_counter;//общий путь с учетом направления
    unsigned long odom_counter[4];//путь по одометру 1-4
    unsigned short status;
//    unsigned priority_odom:2;//номер приоритетного одометра
//    unsigned dir_odom1:1;
//    unsigned dir_odom2:1;
//    unsigned dir_odom3:1;
//    unsigned dir_odom4:1;
//    unsigned rezerv:10;
    unsigned short abs_pressure;
    short diff_pressure;
    unsigned short internal_temperature;
    unsigned short external_temperature;
    unsigned short speed;
    unsigned char motor_state;
    unsigned char angle;//значение датчика положения в единицах АЦП
    signed char choke_curr_position_ticks;//текущее положение заслонки в импульсах с мотора/60
    signed char choke_curr_position_angle;//положение заслонки по датчику
    signed char choke_position;//положение по датчику к которому стремится заслонка
    unsigned char motor_battery_voltage; //напряжение батареи
    unsigned short motor_battery_current;//потребляемый ток
};



typedef struct {
   short abs_pressure;                        
   short diff_pressure;                    
   short speed;                            
   signed char motor_state;                      
   byte choke_curr_position_ticks;        
   byte choke_curr_position_angle;        
   signed char choke_position;                   
   short motor_battary_current;            
   byte motor_battary_voltage;            

   unsigned long Odometr;

} T_BYPASS_IDX;

#pragma pack ()


typedef struct {
   long handle;

   long nodeType;
   long nodeIndex;
   long nodePos;
   double controlSize;

   long  sens_num;
   long  trace_len;
   long  trace_step;         // размер тика одометра в мм

   char trc_file_name[_MAX_PATH];
   char device_ID[16];

   FILE *bps_idx_file_data;

   T_BYPASS_IDX *bps_idx;

} T_TRACE_LIST;
