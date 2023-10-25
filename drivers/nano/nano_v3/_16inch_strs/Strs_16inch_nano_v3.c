#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>
#include <krotnano_v3.h>
#include <tracetool.h>


#define THIS_PROFIL            0
#define PROFIL_MM_SHIFT_UP     0
#define PROFIL_MM_INVERSE      0
#define PROFIL_SENS_IS_ENCODER 0
#define PROFIL_ROW_INVERSE     0

#define THIS_STRESS            1
#define THIS_INTROSCOPE        0

#define _TRACE_STEP_           4

#define MAGN_SENSORS          320
#define FIRST_SENSLINE_SIZE   320
#define THECOND_SENSLINE_SIZE  0
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    1

#define MAX_DATA_CODE         3943

#define Orient_dAy_value      535.147
#define Orient_KAy_value     -246.822
#define Orient_dAz_value      485.141
#define Orient_KAz_value      235.505


#define Orientation_shift_value   -20
#define Orientation_shift_2_value   0
#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Orientation_shift_direct    1

#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS  1
#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0

#define Invert_sens_string  "0-319"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

char Target_name_driver[32];


void create_sens_sort ( long *sens_sort)
{
   long i;

   long tmp_sens_sort[MAGN_SENSORS];

   long num_sens_in_sektor = MAGN_SENSORS/4;

   memcpy(tmp_sens_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));

   for(i = 0; i < num_sens_in_sektor; i++)
   {
       sens_sort[num_sens_in_sektor * 1 + i] = tmp_sens_sort[num_sens_in_sektor * 3 + i];
       sens_sort[num_sens_in_sektor * 2 + i] = tmp_sens_sort[num_sens_in_sektor * 1 + i];
       sens_sort[num_sens_in_sektor * 3 + i] = tmp_sens_sort[num_sens_in_sektor * 2 + i];
   }
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   long num_sens_in_sektor = MAGN_SENSORS/4;

   for(i = 0; i < num_sens_in_sektor; i++)
   {
       sens_shift[num_sens_in_sektor * 0 + i] = 232;
       sens_shift[num_sens_in_sektor * 2 + i] = 232;
   }
}

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

   // 16"_cor_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}

#include <nano_v1_v3.c>


