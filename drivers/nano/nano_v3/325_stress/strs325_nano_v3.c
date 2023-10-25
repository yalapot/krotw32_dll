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

#define _TRACE_STEP_           4

#define MAGN_SENSORS          256
#define FIRST_SENSLINE_SIZE   256
#define THECOND_SENSLINE_SIZE   0
#define THORD_SENSLINE_SIZE     0 
#define FORTH_SENSLINE_SIZE     0 
#define GROUP_NUM_IN_DEVICE     1

#define MAX_DATA_CODE         3943

// калибровка для старого блока который идет и на корозионник
double Orient_dAy_value =     510.409;
double Orient_KAy_value =    -240.232;
double Orient_dAz_value =     507.826;
double Orient_KAz_value =     244.713;

long Orientation_shift_direct  = 1;
long Orientation_shift_value   = -12;

#define Orientation_shift_2_value   0
#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0
#define Invert_sens_string  "0-255"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

#define USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS

long num_sens_for_thick = 255;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

void create_sens_sort ( long *sens_sort)
{
   long i;

//  меняем местами сектора                   
   for (i=0; i<MAGN_SENSORS/4; i++) {
//                                куда                        откуда
      sens_sort[ (MAGN_SENSORS/4) * 0 + i ] = (MAGN_SENSORS/4) * 0 + i ;
      sens_sort[ (MAGN_SENSORS/4) * 1 + i ] = (MAGN_SENSORS/4) * 3 + i ;
      sens_sort[ (MAGN_SENSORS/4) * 2 + i ] = (MAGN_SENSORS/4) * 1 + i ;
      sens_sort[ (MAGN_SENSORS/4) * 3 + i ] = (MAGN_SENSORS/4) * 2 + i ;
   };

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   for (i=0; i<64; i++) {
       sens_shift[i +64*0] = 200; // смещение назад в измерениях
       sens_shift[i +64*2] = 200; // смещение назад в измерениях
   };


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
      if  ( strncmp(target_name, "3201010443", 10)==0 )
      {
         Orient_dAy_value =     511.6606;
         Orient_KAy_value =    -241.71;
         Orient_dAz_value =     500.315;
         Orient_KAz_value =    -242.138;

         Orientation_shift_direct  = 1;

         Orientation_shift_value   = 76;

         Odometer_0_sens_value = 114;
         Odometer_1_sens_value = 242;

         return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер стресс 325 (Nano v3)","Драйвер Стресс-коррозионник 325 (Nano v3)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;
}

long calc_termo(long adc)
{

   // 325_stress_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}

//#include "calibr_datch_325strs.c"

#include <nano_v1_v3.c>


