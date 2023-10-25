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

#define MAGN_SENSORS          64
#define FIRST_SENSLINE_SIZE   64
#define THECOND_SENSLINE_SIZE   0
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE   1

#define MAX_DATA_CODE         4095

#define Orient_dAy_value      493.066
#define Orient_KAy_value      241.421
#define Orient_dAz_value      484.246
#define Orient_KAz_value      242.684


#define Orientation_shift_direct    1

#define Orientation_shift_value     0
#define Orientation_shift_2_value   0
#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0
#define Invert_sens_string  "0-64"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

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
   (void) src_data;
   (void) prof_sens_num;
   (void) P_trace;

   return 0;
};


long check_file_ID(char* target_name)
{
      if  ( strncmp(target_name, "01050103", 8)==0 )
      {
         return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер коррозионник 100 (Nano v3)","Драйвер Стресс-коррозионник 600 (Nano v3)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;
}

long calc_termo(long adc)
{

   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_v1_v3.c>


