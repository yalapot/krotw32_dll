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

#define _TRACE_STEP_           4

#define MAGN_SENSORS          288
#define FIRST_SENSLINE_SIZE   288
#define THECOND_SENSLINE_SIZE  0 
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    1

#define MAX_DATA_CODE         3943

#define Orient_dAy_value      457.585
#define Orient_KAy_value      223.848
#define Orient_dAz_value      535.37
#define Orient_KAz_value     -230.77

#define Orientation_shift_value     22
#define Orientation_shift_2_value   0
#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Orientation_shift_direct    0


#define Delete_sens_string  "15,31,46,47,63,79,94,95,111,127,142,143,159,175,190,191,207,223,238,239,255,271,286,287"
#define Num_Sens_Deleted_From_First_Group    24

#define Invert_sens_string  "0-287"
//,241,244,247,250,253,256,259,262,265,268,271,274,277,280,283,286,289,292,295,298,301,304,307,310,313,316,319,322,325,328,331,334,337,340,343,346,349,352,355,358,361,364,367,370,373,376,379,382"

#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 126;
long Odometer_1_sens_value = 246;

void create_sens_sort ( long *sens_sort)
{
    (void) sens_sort;
}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
    (void) sens_shift;

//   long i;
//
//   for(i = 0; i < MAGN_SENSORS; i += 12)
//   {
//       sens_shift[i + 0] = 4;
//       sens_shift[i + 1] = 4;
//       sens_shift[i + 2] = 4;
//       sens_shift[i + 3] = 4;
//   }

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

   // 600_cor_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}

#include <nano_v1_v3.c>


