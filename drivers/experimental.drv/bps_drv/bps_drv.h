#include <windows.h>
#include <stdio.h>
#include <stdlib.h>


#include "krtapi.h"


#define MAX_TRACE       8

#define MAX_GROUP_NUM   1   // максимально возможное кол-во поясов для данного драйвера                  

  // отключим всякое выравнивание для данных читаемых из файлов
#pragma pack (1)

typedef struct T_BYPASS_HEADER {
   unsigned long file_version;
   char id_str[16];
   char id2_str[16];
   char reserved[28];
};

typedef struct T_BYPASS_INFO {
   char id_str[2];

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

   unsigned char  dummy_u8;
   unsigned short dummy_u16;

   unsigned long Odometr;
   unsigned long Timer_cpy;

   unsigned long dummy1;
   unsigned long dummy2;
};



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
   long  trace_step;     // шаг опроса в тиках таймера

   char trc_file_name[_MAX_PATH];
   char device_ID[16];

   FILE *bps_idx_file_data;

   T_BYPASS_IDX *bps_idx;

   double odometer_step;

} T_TRACE_LIST;
