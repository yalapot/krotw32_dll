#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include <int_unit.h>
#include <krtapi.h>
#include <krotnano_v1.h>
#include <tracetool.h>

#define NANO_VERSION_1

#define THIS_PROFIL            1
#define PROFIL_MM_SHIFT_UP     0
#define PROFIL_MM_INVERSE      0
#define PROFIL_ROW_INVERSE     1
#define PROFIL_SENS_IS_ENCODER 0

#define THIS_STRESS           0
#define THIS_INTROSCOPE       0

#define _TRACE_STEP_           5

#define MAGN_SENSORS          32
#define FIRST_SENSLINE_SIZE   32
#define THECOND_SENSLINE_SIZE 32 
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    2

#define MAX_DATA_CODE         4095

#define Orient_dAy_value      497.323
#define Orient_KAy_value     -241.329
#define Orient_dAz_value      489.365
#define Orient_KAz_value      241.871

#define Orientation_shift_value     10
#define Orientation_shift_2_value   0
#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Orientation_shift_direct    0


#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0

#define Invert_sens_string  ""
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 4

long num_sens_for_thick = FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 8;
long Odometer_1_sens_value = 26;

void create_sens_sort ( long *sens_sort)
{
   (void) sens_sort;
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   (void) sens_shift;
}

long Calculate_profil_mm(long src_data, long prof_sens_num, T_OPENED_TRACE *P_trace)
{
    long translate_res;
    long prof_calibr_index;

    translate_res = src_data; 

    prof_calibr_index=0;
    while (translate_res < (P_trace->profil_calibrate[prof_sens_num][prof_calibr_index]) )
    {
       prof_calibr_index++;
    }; //while (translate_res ...

    if (prof_calibr_index <= 1) {
        translate_res = PROFIL_MM_SHIFT_UP;
    } else {
        translate_res = 10*(prof_calibr_index)
        + 10 *
        (
         P_trace->profil_calibrate[prof_sens_num][prof_calibr_index-1]
         - 
         translate_res
        )
         /
        (
         P_trace->profil_calibrate[prof_sens_num][prof_calibr_index-1]
         -
         P_trace->profil_calibrate[prof_sens_num][prof_calibr_index]
        );

        translate_res = PROFIL_MM_SHIFT_UP + translate_res;
    };

    if ( translate_res > 199 ) translate_res = 199;
    if ( translate_res <   0 ) translate_res =   0;

   if (PROFIL_MM_INVERSE > 0)
   {
        translate_res = PROFIL_MM_INVERSE - translate_res;
   }

   return translate_res;
};

long check_file_ID(char* target_name)
{
    (void) target_name;

    return KRT_OK;
}

long calc_termo(long adc)
{

   // 700_profil_nanoV1
   return (adc * 3300 / 256 - 250) / 28; // AD22103
//   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_v1_v3.c>


