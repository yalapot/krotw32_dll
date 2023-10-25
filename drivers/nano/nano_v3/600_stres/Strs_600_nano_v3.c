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

#define _TRACE_STEP_           5

#define MAGN_SENSORS          384
#define FIRST_SENSLINE_SIZE   384
#define THECOND_SENSLINE_SIZE  0
#define THORD_SENSLINE_SIZE    0
#define FORTH_SENSLINE_SIZE    0
#define GROUP_NUM_IN_DEVICE    1

#define MAX_DATA_CODE         3943

#define Orient_dAy_value      400.737
#define Orient_KAy_value      176.764
#define Orient_dAz_value      536.471
#define Orient_KAz_value      176.649

#define Orientation_shift_direct    0

#define Orientation_shift_value     (-47)
#define Orientation_shift_2_value   0
#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0
#define Invert_sens_string  "0-383"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = FIRST_SENSLINE_SIZE;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

void create_sens_sort ( long *sens_sort)
{
   long i;

//  меняем местами сектора                   
   for (i=0; i<MAGN_SENSORS/4; i++) {
//                                куда                        откуда
      sens_sort[ (MAGN_SENSORS/4) * 0 + i ] = (MAGN_SENSORS/4) * 1 + i ;

      sens_sort[ (MAGN_SENSORS/4) * 1 + i ] = (MAGN_SENSORS/4) * 3 + i ;

      sens_sort[ (MAGN_SENSORS/4) * 2 + i ] = (MAGN_SENSORS/4) * 0 + i ;

      sens_sort[ (MAGN_SENSORS/4) * 3 + i ] = (MAGN_SENSORS/4) * 2 + i ;
    };

}; // void create_sens_sort ( long *sens_sort)


void create_sens_shift ( long *sens_shift)
{
   long i;

   for (i=0; i< MAGN_SENSORS/4  ; i++) {
       sens_shift[i+ (MAGN_SENSORS/4) * 1] = 224; // смещение 2 сектора
       sens_shift[i+ (MAGN_SENSORS/4) * 3] = 224; // смещение 4 сектора
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
      if  ( strncmp(target_name, "60100103", 8)==0 )
      {
         return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер Стресс-коррозионник 600 (Nano v3)","Драйвер Стресс-коррозионник 600 (Nano v3)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;
}

long calc_termo(long adc)
{

   // 600_stress_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}

#include <nano_v1_v3.c>


