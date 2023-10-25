#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>
#include <krotnano_v3.h>
#include <tracetool.h>


#define THIS_PROFIL           0
#define PROFIL_MM_SHIFT_UP    0
#define PROFIL_MM_INVERSE     0
#define PROFIL_SENS_IS_ENCODER 0
#define PROFIL_ROW_INVERSE     0

#define THIS_STRESS           1
#define THIS_INTROSCOPE       0

#define _TRACE_STEP_           3

#define MAGN_SENSORS          384
#define FIRST_SENSLINE_SIZE   384
#define THECOND_SENSLINE_SIZE  0 
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    1

#define MAX_DATA_CODE         3943

#define Orient_dAy_value      518.731
#define Orient_KAy_value      242.502
#define Orient_dAz_value      508.351
#define Orient_KAz_value      243.611

#define Orientation_shift_value     165
#define Orientation_shift_2_value    0
#define Orientation_shift_3_value    0
#define Orientation_shift_4_value    0

#define Orientation_shift_direct    1


#define Delete_sens_string "12-15,28-31,44-47,60-63,76-79,92-95,108-111,124-127,140-143,156-159,172-175,188-191,204-207,220-223,236-239,252-255,268-271,284-287,300-303,316-319,332-335,348-351,364-367,380-383"
// "0-3,16-19,32-35,48-51,64-67,80-83,96-99,112-115,128-131,144-147,160-163,176-179,192-195,208-211,224-227,240-243,256-259,272-275,288-291,304-307,320-323,336-339,352-355,368-371"
//  "12-15,28-31,44-47,60-63,76-79,92-95,108-111,124-127,140-143,156-159,172-175,188-191,204-207,220-223,236-239,252-255,268-271,284-287,300-303,316-319,332-335,348-351,364-367,380-383"
#define Num_Sens_Deleted_From_First_Group    96

#define Invert_sens_string  "0-383"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = 12; //FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

char Target_name_driver[32];

void create_sens_sort ( long *sens_sort)
{
   long i;
   long tmp_sort[MAGN_SENSORS];

/*
   long sector_count;
   long tmp_val;
   long sector_size = MAGN_SENSORS / 6;

   // развернем опрос датчиков в секторах
   for (sector_count = 0; sector_count < MAGN_SENSORS; sector_count += sector_size)
   {
       for (i = 0; i < sector_size/2; i++) {
           tmp_val = sens_sort[ sector_count + i];
           sens_sort[ sector_count + i] = sens_sort[ sector_count + (sector_size - 1) - i ];
           sens_sort[ sector_count + (sector_size - 1) - i ] = tmp_val;
       }
   }
*/

//  меняем местами сектора                   
   memcpy(tmp_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));
   for (i=0; i<MAGN_SENSORS/6; i++) {
//                                куда                        откуда
      sens_sort[ (MAGN_SENSORS/6) * 0 + i ] = tmp_sort [ (MAGN_SENSORS/6) * 3 + i ];
      sens_sort[ (MAGN_SENSORS/6) * 1 + i ] = tmp_sort [ (MAGN_SENSORS/6) * 1 + i ];
      sens_sort[ (MAGN_SENSORS/6) * 2 + i ] = tmp_sort [ (MAGN_SENSORS/6) * 0 + i ];
      sens_sort[ (MAGN_SENSORS/6) * 3 + i ] = tmp_sort [ (MAGN_SENSORS/6) * 4 + i ];
      sens_sort[ (MAGN_SENSORS/6) * 4 + i ] = tmp_sort [ (MAGN_SENSORS/6) * 2 + i ];
      sens_sort[ (MAGN_SENSORS/6) * 5 + i ] = tmp_sort [ (MAGN_SENSORS/6) * 5 + i ];
   };

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;
   long sector_size = MAGN_SENSORS / 6;

   for (i = 0; i < sector_size; i++) {
       sens_shift[i + sector_size * 1] = 555; // смещение назад в измерениях
       sens_shift[i + sector_size * 4] = 555; // смещение назад в измерениях
       sens_shift[i + sector_size * 2] = 275; // смещение назад в измерениях
       sens_shift[i + sector_size * 5] = 275; // смещение назад в измерениях
   };


};                 
                  
long Calculate_profil_mm(long src_data, long prof_sens_num, T_OPENED_TRACE *P_trace)
{
   (void) src_data;
   (void) prof_sens_num;
   (void) P_trace;

   return 0;
};

long check_file_ID(char* target_name)
{
    strncpy(Target_name_driver, target_name, 31);

    return KRT_OK;
}

long calc_termo(long adc)
{

   // 200_cor_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}

#include <nano_v1_v3.c>


