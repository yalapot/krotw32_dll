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

#define MAGN_SENSORS          256
#define FIRST_SENSLINE_SIZE   192
#define THECOND_SENSLINE_SIZE  64
#define THORD_SENSLINE_SIZE    0 
#define FORTH_SENSLINE_SIZE    0 
#define GROUP_NUM_IN_DEVICE    2

#define MAX_DATA_CODE         4095

// это калибровка для ID 3205010340
double Orient_dAy_value =     510.409;
double Orient_KAy_value =    -240.232;
double Orient_dAz_value =     507.826;
double Orient_KAz_value =     244.713;

int Orientation_shift_direct = 1;

int Orientation_shift_value   = -74;
int Orientation_shift_2_value = -14;

#define Orientation_shift_3_value   0
#define Orientation_shift_4_value   0

#define Delete_sens_string  ""
#define Num_Sens_Deleted_From_First_Group    0
#define Invert_sens_string  "0-191"
#define Zerro_sens_string   ""

#define ADD_THEN_CAHANGE_ODOM 0

long num_sens_for_thick = 192;

long Odometers_tools_use_value = 0;
long Odometer_0_sens_value = 0;
long Odometer_1_sens_value = FIRST_SENSLINE_SIZE/2;

void create_sens_sort ( long *sens_sort)
{
   long i;

   long base_sens_count = 0;
   long ext_sens_count = FIRST_SENSLINE_SIZE;
   long internal_cirkle_counter=0;

   long tmp_sort[MAGN_SENSORS];

//  меняем местами сектора
   memcpy(tmp_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));
   for (i=0; i < 32; i++) {
//                 куда                     откуда
//      sens_sort[ 32 * 0 + i ] = tmp_sort[ 32 * 0 + i] ;
//      sens_sort[ 32 * 1 + i ] = tmp_sort[ 32 * 3 + i] ;
//      sens_sort[ 32 * 2 + i ] = tmp_sort[ 32 * 2 + i] ;
//      sens_sort[ 32 * 3 + i ] = tmp_sort[ 32 * 5 + i] ;
//      sens_sort[ 32 * 4 + i ] = tmp_sort[ 32 * 4 + i] ;
//      sens_sort[ 32 * 5 + i ] = tmp_sort[ 32 * 6 + i] ;
//      sens_sort[ 32 * 6 + i ] = tmp_sort[ 32 * 7 + i] ;
//      sens_sort[ 32 * 7 + i ] = tmp_sort[ 32 * 1 + i] ;
   };

// разделим пояса
   memcpy(tmp_sort, sens_sort, MAGN_SENSORS * sizeof(sens_sort[0]));
   i=0;
   while (1)
   {
      for (internal_cirkle_counter=0; internal_cirkle_counter<6; internal_cirkle_counter++)
      {
         sens_sort[base_sens_count] =  tmp_sort[i];
         i++;
         base_sens_count++;
         if (i>=MAGN_SENSORS) break;
      };
      if (i>=MAGN_SENSORS) break;

      for (internal_cirkle_counter=0; internal_cirkle_counter<2; internal_cirkle_counter++)
      {
         sens_sort[ext_sens_count] =  tmp_sort[i];
         i++;
         ext_sens_count++;
         if (i>=MAGN_SENSORS) break;

      };
      if (i>=MAGN_SENSORS) break;

   };


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

      if  ( strncmp(target_name, "3205010443", 10)==0 )
      {
         // это калибровка для ID 3205010340
         Orient_dAy_value =     519.779;
         Orient_KAy_value =    -243.079;
         Orient_dAz_value =     508.608;
         Orient_KAz_value =    -243.443;

         Orientation_shift_direct = 1;

         Orientation_shift_value   = 111;
         Orientation_shift_2_value = -10;

         return KRT_OK;
      }

      MessageBox(NULL, "Выберете другой драйвер! \nЭто драйвер коррозионник 325 id 32050104 (Nano v3)","Драйвер Стресс-коррозионник 600 (Nano v3)", MB_OK | MB_ICONQUESTION | MB_SYSTEMMODAL);
      return KRT_ERR;
}

long calc_termo(long adc)
{

   // 325_cor_nanoV3
//   return (adc * 3300 / 256 - 250) / 28; // AD22103
   return (adc * 3300/256 - 500) / 10; // TMP36
}


#include <nano_v1_v3.c>


