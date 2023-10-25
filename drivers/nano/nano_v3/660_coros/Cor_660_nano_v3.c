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

#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

#define _TRACE_STEP_           5

#define MAGN_SENSORS          576
#define FIRST_SENSLINE_SIZE   384
#define THECOND_SENSLINE_SIZE 192
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    2

#define MAX_DATA_CODE         3943

#define Orient_dAy_value      502.514
#define Orient_KAy_value      173.42
#define Orient_dAz_value      501.923
#define Orient_KAz_value      171.169


#define Orientation_shift_value     180
#define Orientation_shift_2_value   103
#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Orientation_shift_direct    1


#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0

#define Invert_sens_string  "0-575"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

void create_sens_sort ( long *sens_sort)
{
   long i, j;

   j = 0;
   for (i=0; i<FIRST_SENSLINE_SIZE; i++) {

      sens_sort[ i ] = j;
      i++; j++;         
      sens_sort[ i ] = j;
      i++; j++;         
      sens_sort[ i ] = j;
      i++; j++;         
      sens_sort[ i ] = j;
      i++; j++;         
      sens_sort[ i ] = j;
      i++; j++;         
      sens_sort[ i ] = j;
      i++; j++;         
      sens_sort[ i ] = j;
      i++; j++;         
      sens_sort[ i ] = j;
      j+=5;
   };

   j = 8;
   for (i=FIRST_SENSLINE_SIZE; i<MAGN_SENSORS; i++) {

      sens_sort[ i ] = j;
      i++; j++;         
      sens_sort[ i ] = j;
      i++; j++;         
      sens_sort[ i ] = j;
      i++; j++;         
      sens_sort[ i ] = j;
      j+=9;

   };
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
    long sens_counter;

    for (sens_counter = FIRST_SENSLINE_SIZE; sens_counter < MAGN_SENSORS; sens_counter++)
    {
        sens_shift[sens_counter] = 4;
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
    (void) target_name;

    return KRT_OK;
}

long calc_termo(long adc)
{

   // 660_cor_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_v1_v3.c>


